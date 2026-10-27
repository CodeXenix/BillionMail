<template>
	<div>
		<bt-table-layout>
			<template #toolsLeft>
				<n-button type="primary" @click="handleAdd">
					{{ t('market.task.actions.add') }}
				</n-button>
			</template>
			<template #toolsRight>
				<bt-search
					v-model:value="tableParams.keyword"
					:width="320"
					:placeholder="t('market.task.search.subjectPlaceholder')"
					@search="() => getTableData(true)">
				</bt-search>
			</template>
			<template #table>
				<n-data-table :loading="loading" :columns="columns" :data="tableList" :scroll-x="1410">
					<template #empty>
						<bt-table-help>
							<n-button type="primary" size="small" @click="handleAdd">
								{{ t('market.task.actions.add') }}
							</n-button>
						</bt-table-help>
					</template>
				</n-data-table>
			</template>
			<template #pageRight>
				<bt-table-page
					v-model:page="tableParams.page"
					v-model:page-size="tableParams.page_size"
					:item-count="tableTotal"
					@refresh="getTableData">
				</bt-table-page>
			</template>
			<template #modal>
				<status-modal />
				<detail-modal />
			</template>
		</bt-table-layout>
	</div>
</template>

<script lang="tsx" setup>
import { DataTableColumns, NButton, NEllipsis, NFlex, NProgress } from 'naive-ui'
import { useModal } from '@/hooks/modal/useModal'
import { useTableData } from '@/hooks/useTableData'
import { confirm, formatDurationHighest, formatTime } from '@/utils'
import { deleteTask, getTaskList, pauseTask, resumeTask } from '@/api/modules/market/task'
import type { Task, TaskParams } from './interface'

import BtIconAction from '@/components/base/bt-icon-action/index.vue'
import BtStatus from '@/components/base/bt-status/index.vue'
import TaskDetail from './components/TaskDetail.vue'
import TaskStatus from './components/TaskStatus.vue'

const { t } = useI18n()

const { loading, tableParams, tableList, tableTotal, getTableData } = useTableData<
	Task,
	TaskParams
>({
	loading: true,
	immediate: true,
	params: {
		page: 1,
		page_size: 10,
		keyword: '',
	},
	fetchFn: getTaskList,
})

// Table columns
// task_process: 0 not started, 1 sending, 2 completed, 3 paused
const columns = ref<DataTableColumns<Task>>([
	{
		key: 'subject',
		title: t('market.task.columns.subject'),
		// pinned, like the actions, so the campaign stays in view when the table scrolls
		width: 240,
		fixed: 'left',
		// The remark is an internal note, shown under the subject it describes
		render: row => (
			<div>
				<div>
					<NEllipsis>{row.subject}</NEllipsis>
				</div>
				{row.remark && (
					<div class="text-12px text-desc">
						<NEllipsis>{row.remark}</NEllipsis>
					</div>
				)}
			</div>
		),
	},
	{
		key: 'active',
		title: t('market.task.columns.status'),
		width: 110,
		render: row => {
			if (row.task_process === 2)
				return <BtStatus type="success">{t('market.task.status.done')}</BtStatus>
			if (row.task_process === 3)
				return <BtStatus type="warning">{t('market.task.status.paused')}</BtStatus>
			if (row.task_process === 1)
				return <BtStatus type="info">{t('market.task.status.processing')}</BtStatus>
			if (row.start_time * 1000 > Date.now())
				return <BtStatus>{t('market.task.status.scheduled')}</BtStatus>
			return <BtStatus>{t('market.task.status.pending')}</BtStatus>
		},
	},
	{
		key: 'progress',
		title: t('market.task.columns.progress'),
		width: 150,
		render: row => (
			<div class="flex items-center gap-8px">
				<NProgress
					class="flex-1"
					type="line"
					status="success"
					processing={row.task_process === 1}
					percentage={row.progress}
					show-indicator={false}
				/>
				<span class="w-36px text-right">{row.progress}%</span>
			</div>
		),
	},
	{
		key: 'recipient_count',
		title: t('market.task.columns.recipients'),
		width: 90,
	},
	{
		key: 'success_count',
		title: t('market.task.columns.success'),
		width: 90,
	},
	{
		key: 'error_count',
		title: t('market.task.columns.failed'),
		width: 90,
		render: row => (
			<NButton
				type="error"
				text
				onClick={() => {
					handleShowError(row)
				}}>
				{row.error_count}
			</NButton>
		),
	},
	{
		key: 'addresser',
		title: t('market.task.columns.sender'),
		minWidth: 170,
		ellipsis: {
			tooltip: true,
		},
	},
	{
		key: 'start_time',
		title: t('market.task.edit.sendTime'),
		width: 170,
		render: row => formatTime(row.start_time),
	},
	{
		key: 'estimated_time_with_warmup',
		title: t('market.task.columns.estimatedTime'),
		minWidth: 120,
		ellipsis: {
			tooltip: true,
		},
		render: row => {
			// 已完成
			if (row.task_process === 2) {
				return '--'
			}
			// 显示预计时间
			if (row.estimated_time_with_warmup >= 0) {
				return formatDurationHighest(row.estimated_time_with_warmup)
			}
			return t('market.task.status.noIpWarmup')
		},
	},
	{
		title: t('common.columns.actions'),
		key: 'actions',
		align: 'right',
		// up to 5 icon buttons: 5 × 28 + 4 × 4 + 24; pinned so it stays visible when the table scrolls
		width: 180,
		fixed: 'right',
		render: row => (
			<NFlex inline={true} size={4}>
				{(row.task_process === 1 || row.task_process === 3) && (
					<BtIconAction
						icon={row.task_process === 3 ? 'i-lucide-send' : 'i-lucide-pause'}
						label={
							row.task_process === 3
								? t('market.task.actions.send')
								: t('market.task.actions.pause')
						}
						onClick={() => {
							handleSetStatus(row)
						}}
					/>
				)}
				{row.task_process !== 2 && (
					<BtIconAction
						icon="i-lucide-pencil"
						label={t('common.actions.edit')}
						onClick={() => {
							handleEdit(row)
						}}
					/>
				)}
				<BtIconAction
					icon="i-lucide-chart-column"
					label={t('market.task.actions.analytics')}
					onClick={() => {
						handleGoAnalytics(row)
					}}
				/>
				{row.task_process === 2 && (
					<BtIconAction
						icon="i-lucide-file-text"
						label={t('market.task.actions.detail')}
						onClick={() => {
							handleDetail(row)
						}}
					/>
				)}
				<BtIconAction
					icon="i-lucide-copy"
					label={t('common.actions.copy')}
					onClick={() => {
						handleCopy(row)
					}}
				/>
				<BtIconAction
					icon="i-lucide-trash-2"
					label={t('common.actions.delete')}
					type="error"
					onClick={() => {
						handleDelete(row)
					}}
				/>
			</NFlex>
		),
	},
])

const router = useRouter()

// 添加任务
const handleAdd = () => {
	router.push('/market/task/edit')
}

// 前往分析
const handleGoAnalytics = (row: Task) => {
	router.push(`/market/task/analytics/${row.id}`)
}

// 复制任务
const handleCopy = (row: Task) => {
	router.push(`/market/task/edit?task_id=${row.id}`)
}

// 暂停/发送任务
const handleSetStatus = (row: Task) => {
	confirm({
		title: t('market.task.changeStatus.title', { subject: row.subject }),
		content:
			row.task_process === 3
				? t('market.task.changeStatus.startConfirm')
				: t('market.task.changeStatus.pauseConfirm'),
		onConfirm: async () => {
			if (row.task_process === 3) {
				await resumeTask({ task_id: row.id })
			} else {
				await pauseTask({ task_id: row.id })
			}
			getTableData()
		},
	})
}

const [StatusModal, statusModalApi] = useModal({
	component: TaskStatus,
})

// 查看任务详情
const handleShowError = (row: Task) => {
	statusModalApi.setState({ row })
	statusModalApi.open()
}

const [DetailModal, detailModalApi] = useModal({
	component: TaskDetail,
})

// 查看任务详情
const handleDetail = (row: Task) => {
	detailModalApi.setState({ row })
	detailModalApi.open()
}

// 删除任务
const handleDelete = (row: Task) => {
	confirm({
		title: t('market.task.delete.title'),
		content: t('market.task.delete.confirm', { subject: row.subject }),
		confirmText: t('common.actions.delete'),
		confirmType: 'error',
		onConfirm: async () => {
			await deleteTask({ id: row.id })
			getTableData()
		},
	})
}

const handleEdit = (row: Task) => {
	const goEdit = () => router.push(`/market/task/edit?task_id=${row.id}&type=edit`)
	if (row.task_process !== 1) {
		goEdit()
		return
	}
	// A sending campaign has to be paused before it can change
	confirm({
		title: t('market.task.pauseToEdit.title'),
		content: t('market.task.pauseToEdit.content'),
		onConfirm: async () => {
			await pauseTask({ task_id: row.id })
			goEdit()
		},
	})
}
</script>

<style lang="scss" scoped></style>

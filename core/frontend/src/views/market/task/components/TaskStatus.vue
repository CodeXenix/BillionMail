<template>
	<modal :title="title" :width="600" :footer="false">
		<bt-table-layout>
			<template #toolsLeft>
				<!-- <n-radio-group>
					<n-radio-button>Domain</n-radio-button>
					<n-radio-button>Status</n-radio-button>
				</n-radio-group> -->
			</template>
			<template #toolsRight> </template>
			<template #table>
				<n-data-table :bordered="false" :loading="loading" :columns="columns" :data="tableList">
					<template #empty>
						<bt-table-help> </bt-table-help>
					</template>
				</n-data-table>
			</template>
			<template #modal>
				<details-modal />
			</template>
		</bt-table-layout>
	</modal>
</template>

<script lang="tsx" setup>
import { DataTableColumns, NFlex } from 'naive-ui'
import { isArray } from '@/utils'
import { useModal } from '@/hooks/modal/useModal'
import { getMailProvider } from '@/api/modules/market/task'
import type { Task, TaskStatus } from '../interface'

import BtIconAction from '@/components/base/bt-icon-action/index.vue'
import TaskStatusDetails from './TaskStatusDetails.vue'

const title = ref('Error tasks')

const loading = ref(false)

const search = reactive({
	status: 0,
	task_id: 0,
})

const tableList = ref<TaskStatus[]>([])

const columns = ref<DataTableColumns<TaskStatus>>([
	{
		key: 'domain',
		title: 'Domain',
		ellipsis: {
			tooltip: true,
		},
	},
	{
		key: 'count',
		title: 'Count',
	},
	{
		key: 'active',
		title: 'Operator',
		align: 'right',
		// 1 icon button (28 + 24), widened so the "Operator" header fits
		width: 88,
		render: row => (
			<NFlex inline={true} size={4}>
				<BtIconAction
					icon="i-lucide-file-text"
					label="Details"
					onClick={() => {
						handleShowDetails(row)
					}}
				/>
			</NFlex>
		),
	},
])

const [DetailsModal, detailsModalApi] = useModal({
	component: TaskStatusDetails,
})

const handleShowDetails = (row: TaskStatus) => {
	detailsModalApi.setState({ taskId: search.task_id, status: search.status, row })
	detailsModalApi.open()
}

const getTableData = async () => {
	const res = await getMailProvider(toRaw(search))
	if (isArray<TaskStatus>(res)) {
		tableList.value = res
	}
}

const [Modal, modalApi] = useModal({
	onChangeState: isOpen => {
		if (isOpen) {
			const state = modalApi.getState<{ row: Task }>()
			const { row } = state
			if (row) {
				tableList.value = []
				search.task_id = row.id
				title.value = `Error tasks [${row.subject}]`
				getTableData()
			}
		} else {
			tableList.value = []
		}
	},
})
</script>

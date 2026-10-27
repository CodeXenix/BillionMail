<template>
	<bt-table-layout>
		<template #toolsLeft>
			<n-button type="primary" @click="handleAdd">{{ $t('settings.bcc.add') }}</n-button>
		</template>
		<template #toolsRight>
			<n-button @click="handleRefresh">
				{{ $t('common.actions.refresh') }}
			</n-button>
		</template>
		<template #table>
			<n-data-table :loading="loading" :columns="columns" :data="tableList">
				<template #empty>
					<bt-table-help>
						<n-button type="primary" size="small" @click="handleAdd">
							{{ $t('settings.bcc.add') }}
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
			<form-modal />
		</template>
	</bt-table-layout>
</template>

<script lang="tsx" setup>
import { DataTableColumns, NFlex } from 'naive-ui'
import { confirm } from '@/utils'
import { useTableData } from '@/hooks/useTableData'
import { useModal } from '@/hooks/modal/useModal'
import BtIconAction from '@/components/base/bt-icon-action/index.vue'
import BtStatus from '@/components/base/bt-status/index.vue'
import { deleteBcc, getBccList } from '@/api/modules/settings/bcc'
import type { Bcc, BccParams } from './type/base'
import BccForm from './components/BccForm.vue'

const { t } = useI18n()

const { tableParams, tableList, loading, tableTotal, getTableData } = useTableData<Bcc, BccParams>({
	loading: true,
	immediate: true,
	params: {
		page: 1,
		page_size: 10,
		domain: '',
		keyword: '',
	},
	fetchFn: getBccList,
})

const columns = ref<DataTableColumns<Bcc>>([
	{
		key: 'address',
		title: () => t('settings.bcc.needCopy'),
		ellipsis: {
			tooltip: true,
		},
	},
	{
		key: 'goto',
		title: () => t('settings.bcc.copyTo'),
		ellipsis: {
			tooltip: true,
		},
	},
	{
		key: 'domain',
		title: () => t('settings.bcc.domain'),
		ellipsis: {
			tooltip: true,
		},
	},
	{
		key: 'type',
		title: () => t('settings.bcc.type'),
		render: row => t(`settings.bcc.types.${row.type}`),
	},
	{
		key: 'active',
		title: () => t('settings.bcc.status'),
		render: row => (
			<BtStatus type={row.active === 1 ? 'success' : 'warning'}>
				{row.active === 1 ? t('settings.bcc.active') : t('settings.bcc.inactive')}
			</BtStatus>
		),
	},
	{
		title: t('common.columns.actions'),
		key: 'actions',
		align: 'right',
		width: 88, // wide enough for the column header
		render: row => (
			<NFlex inline={true} size={4}>
				<BtIconAction
					icon="i-lucide-pencil"
					label={t('common.actions.edit')}
					onClick={() => {
						handleEdit(row)
					}}
				/>
				<BtIconAction
					icon="i-lucide-trash-2"
					type="error"
					label={t('common.actions.delete')}
					onClick={() => {
						handleDelete(row)
					}}
				/>
			</NFlex>
		),
	},
])

const [FormModal, formModalApi] = useModal({
	component: BccForm,
	state: {
		isEdit: false,
		refresh: getTableData,
	},
})

const handleAdd = () => {
	formModalApi.setState({ isEdit: false, row: null })
	formModalApi.open()
}

const handleRefresh = () => {
	getTableData(true)
}

const handleEdit = (row: Bcc) => {
	formModalApi.setState({ isEdit: true, row })
	formModalApi.open()
}

const handleDelete = (row: Bcc) => {
	confirm({
		title: t('settings.bcc.delete.title', { address: row.address }),
		content: t('settings.bcc.delete.content'),
		confirmText: t('common.actions.delete'),
		confirmType: 'error',
		onConfirm: async () => {
			await deleteBcc({ id: row.id })
			getTableData()
		},
	})
}
</script>

<style lang="scss" scoped></style>

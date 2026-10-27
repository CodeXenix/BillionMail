<template>
	<div class="p-24px">
		<h1 class="bt-title">{{ t('template.template') }}</h1>
		<bt-table-layout>
			<template #toolsLeft>
				<n-button type="primary" @click="handleAdd">
					{{ t('market.template.actions.add') }}
				</n-button>
			</template>
			<template #toolsRight>
				<bt-search v-model:value="tableParams.keyword" :width="240"
					:placeholder="t('market.template.search.namePlaceholder')" @search="() => getTableData(true)">
				</bt-search>
			</template>
			<template #table>
				<n-data-table :loading="loading" :columns="columns" :data="tableList">
					<template #empty>
						<bt-table-help>
							<n-button type="primary" size="small" @click="handleAdd">
								{{ t('market.template.actions.add') }}
							</n-button>
						</bt-table-help>
					</template>
				</n-data-table>
			</template>
			<template #pageRight>
				<bt-table-page v-model:page="tableParams.page" v-model:page-size="tableParams.page_size"
					:item-count="tableTotal" @refresh="getTableData">
				</bt-table-page>
			</template>
			<template #modal>
				<form-modal />
				<preview-modal />
			</template>
		</bt-table-layout>
	</div>
	<!-- Create template modal -->
	<CreateTplModal ref="createTemplateModalRef" @confirm-type="handleConfirmTemplateType" />
</template>

<script lang="tsx" setup>
import { DataTableColumns, NButton, NFlex, NTag } from 'naive-ui'
import { useModal } from '@/hooks/modal/useModal'
import { useTableData } from '@/hooks/useTableData'
import { confirm, formatTime } from '@/utils'
import { deleteTemplate, duplicateTemplate, getTemplateList ,updateTemplate} from '@/api/modules/market/template'
import type { Template, TemplateParams } from './interface'

// import TemplateAdd from './components/TemplateAdd.vue'
import BtIconAction from '@/components/base/bt-icon-action/index.vue'
import TemplateForm from './components/TemplateForm.vue'
import TemplatePreview from './components/TemplatePreview.vue'
import CreateTplModal from './components/CreateTplModal.vue'

const router = useRouter()

const { t } = useI18n()
const createTemplateModalRef = ref()
const { tableParams, tableList, loading, tableTotal, getTableData } = useTableData<
	Template,
	TemplateParams
>({
	loading: true,
	immediate: false,
	params: {
		page: 1,
		page_size: 10,
		keyword: '',
	},
	fetchFn: getTemplateList,
})
/**
 * @description Preprocess template data
 */
const getNewTableData = async () => {
	await getTableData()
	tableList.value.forEach(item => {
		item.isEdit = false
		item.edit_name = ""
	})
}

getNewTableData()

// Table columns
const columns = ref<DataTableColumns<Template>>([
	{
		key: 'temp_name',
		title: t('market.template.columns.name'),
		minWidth: 120,
		ellipsis: {
			tooltip: true,
		},
		render: row => {
			if (!row.isEdit) {
				return <div class="flex justify-start gap-4px items-center">
					<NButton
						type="primary"
						text
						onClick={() => {
							handleEdit(row)
						}}>
						{row.temp_name}
					</NButton>
					<i class="i-lucide-pencil-line text-14px cursor-pointer" onClick={()=>{
						row.isEdit = true
						row.edit_name = row.temp_name
						}}></i>
				</div>
			} else {
				return <div class="flex justify-start gap-4px items-center">
					<n-input class="edit-domain-input" v-model:value={row.edit_name}></n-input>
					<n-button text type="info" class="text-12px" onClick={()=>confirmUpdateTemplateName(row)}>{t('market.template.edit.confirm')}</n-button>
					<n-button text type="default" onClick={()=>{
						row.isEdit = false
						row.edit_name = ""
						}}>{t('market.template.edit.cancel')}</n-button>
				</div>
			}
		},
	},
	{
		key: 'add_type',
		title: t('market.template.columns.type'),
		minWidth: 140,
		render: row => {
			if (row.add_type === 1) {
				return (
					<NTag size="small" bordered={false} type="primary">
						{t('market.template.types.drag')}
					</NTag>
				)
			} else if (row.add_type === 0) {
				return (
					<NTag size="small" bordered={false} type="info">
						{t('market.template.types.html')}
					</NTag>
				)
			} else if (row.add_type == 2) {
				return (
					<NTag size="small" bordered={false} type="success">
						{t('market.template.types.ai')}
					</NTag>
				)
			}
		},
	},
	{
		key: 'create_time',
		title: t('market.template.columns.createdAt'),
		minWidth: 140,
		render: row => formatTime(row.create_time),
	},
	{
		title: t('common.columns.actions'),
		key: 'actions',
		align: 'right',
		// 4 icon buttons: 4 × 28 + 3 × 4 + 24
		width: 148,
		render: row => (
			<NFlex inline={true} size={4}>
				<BtIconAction
					icon="i-lucide-eye"
					label={t('common.actions.preview')}
					onClick={() => {
						handlePreview(row.html_content)
					}}
				/>
				<BtIconAction
					icon="i-lucide-pencil"
					label={t('common.actions.edit')}
					onClick={() => {
						handleEdit(row)
					}}
				/>
				<BtIconAction
					icon="i-lucide-copy-plus"
					label={t('market.template.actions.duplicate')}
					disabled={row.add_type == 2}
					onClick={() => {
						handleDuplicate(row)
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

const [FormModal, formModalApi] = useModal({
	component: TemplateForm,
	state: {
		isEdit: false,
		refresh: getTableData,
		preview: (html: string) => {
			handlePreview(html)
		},
	},
})

// Handle add template
const handleAdd = () => {
	createTemplateModalRef.value.open()
}

// Confirm choose template type
const handleConfirmTemplateType = (type: string) => {
	if (type == "Drag") {
		formModalApi.setState({ isEdit: false, type: 1, row: null })
	} else if (type == "HTML") {
		formModalApi.setState({ isEdit: false, type: 0, row: null })
	}
	formModalApi.open()
}

// Confirm update template's name
const confirmUpdateTemplateName = async (row:Template)=>{
	row.temp_name = row.edit_name as string
	await updateTemplate(row)
	row.isEdit = false
}
// Handle edit
const handleEdit = (row: Template) => {
	if (row.add_type == 2 && row.chat_id) {
		router.push({ name: "ai-template", params: { chatId: row.chat_id } })
	} else {
		formModalApi.setState({ isEdit: true, row })
		formModalApi.open()
	}
}

const [PreviewModal, previewModalApi] = useModal({
	component: TemplatePreview,
})

// Handle preview
const handlePreview = (html: string) => {
	previewModalApi.setState({ html })
	previewModalApi.open()
}

// Handle duplicate
const handleDuplicate = async (row: Template) => {
	await duplicateTemplate({ id: row.id })
	getTableData()
}

// Handle delete
const handleDelete = (row: Template) => {
	confirm({
		title: t('market.template.delete.title'),
		content: t('market.template.delete.confirm', { name: row.temp_name }),
		confirmText: t('common.actions.delete'),
		confirmType: 'error',
		onConfirm: async () => {
			await deleteTemplate({ id: row.id })
			getTableData()
		},
	})
}
</script>

<style lang="scss" scoped>
:deep(.edit-domain-input) {
	height: 26px;

	.n-input__input-el {
		height: 26px;
	}
}
</style>

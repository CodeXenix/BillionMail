<template>
	<div>
		<n-data-table :loading="loading" :data="serviceList" :columns="columns">
			<template #empty>
				<bt-table-help></bt-table-help>
			</template>
		</n-data-table>
		<config-modal></config-modal>
	</div>
</template>

<script lang="tsx" setup>
import { DataTableColumns, NFlex } from 'naive-ui'
import { confirm, isArray } from '@/utils'
import { useModal } from '@/hooks/modal/useModal'
import BtIconAction from '@/components/base/bt-icon-action/index.vue'
import BtStatus from '@/components/base/bt-status/index.vue'
import { getServiceList, restartService } from '@/api/modules/settings'
import type { DockerService } from '../types/common'

import ServiceConfig from './ServiceConfig.vue'

const { t } = useI18n()

const router = useRouter()

const loading = ref(false)
const serviceList = ref<DockerService[]>([])

const getConfigDisabled = (name: string) => {
	return name.includes('rspamd') || name.includes('postfix') || name.includes('dovecot')
}

const columns = ref<DataTableColumns<DockerService>>([
	{
		key: 'Names',
		title: t('settings.service.columns.name'),
		ellipsis: {
			tooltip: true,
		},
		render: row => {
			return row.Names[0]
		},
	},
	{
		key: 'State',
		title: t('settings.service.columns.status'),
		render: row => {
			return (
				<BtStatus type={row.State === 'running' ? 'success' : 'error'}>
					{row.State === 'running'
						? t('settings.service.status.running')
						: t('settings.service.status.stopped')}
				</BtStatus>
			)
		},
	},
	{
		key: 'action',
		title: t('common.columns.actions'),
		align: 'right',
		width: 116,
		render: row => (
			<NFlex inline={true} size={4}>
				{row.Names[0].includes('rspamd') ? (
					<BtIconAction
						icon="i-lucide-monitor"
						label="GUI"
						onClick={() => {
							router.push('/settings/rspamd')
						}}
					/>
				) : null}
				<BtIconAction
					icon="i-lucide-sliders-horizontal"
					label={t('common.actions.config')}
					disabled={!getConfigDisabled(row.Names[0])}
					onClick={() => {
						handleShowConfig(row)
					}}
				/>
				<BtIconAction
					icon="i-lucide-rotate-ccw"
					label={t('common.actions.restart')}
					onClick={() => {
						handleRestart(row)
					}}
				/>
			</NFlex>
		),
	},
])

const handleRestart = async (row: DockerService) => {
	confirm({
		title: t('settings.service.restart.title'),
		content: t('settings.service.restart.confirm', { name: row.Names[0] }),
		confirmText: t('common.actions.confirm'),
		onConfirm: async () => {
			await restartService({ container_id: row.Id })
			getList()
		},
	})
}

const [ConfigModal, configModalApi] = useModal({
	component: ServiceConfig,
})

const handleShowConfig = (row: DockerService) => {
	configModalApi.setState({ row: row })
	configModalApi.open()
}

const getList = async () => {
	try {
		loading.value = true
		const res = await getServiceList()
		if (isArray<DockerService>(res)) {
			serviceList.value = res
		}
	} finally {
		loading.value = false
	}
}

getList()
</script>

<style lang="scss" scoped>
.settings-title {
	margin-bottom: 16px;
	font-size: 16px;
	font-weight: 600;
	color: var(--color-text-2);
}
</style>

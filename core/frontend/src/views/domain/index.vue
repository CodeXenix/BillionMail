<template>
	<div class="p-24px">
		<h1 class="bt-title">{{ t('layout.menu.domain') }}</h1>
		<bt-table-layout>
			<template #toolsLeft>
				<n-button type="primary" @click="handleAddDomain">{{ t('domain.addDomain') }}</n-button>
				<span class="self-center text-desc">{{ t('domain.help') }}</span>
			</template>
			<template #table>
				<n-data-table :loading="loading" :columns="columns" :data="tableList">
					<template #empty>
						<bt-table-help>
							<n-button type="primary" size="small" @click="handleAddDomain">
								{{ t('domain.addDomain') }}
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
				<ssl-modal />
				<dns-modal />
				<domain-ip-set-modal />
				<blacklist-modal />
				<check-logs-modal />
			</template>
		</bt-table-layout>
	</div>
</template>

<script lang="tsx" setup>
import { DataTableColumns, NFlex, NButton, NTag } from 'naive-ui'
import { confirm, getByteUnit } from '@/utils'
import BtIconAction from '@/components/base/bt-icon-action/index.vue'
import BtStatus from '@/components/base/bt-status/index.vue'
import { useModal } from '@/hooks/modal/useModal'
import { useTableData } from '@/hooks/useTableData'
import { deleteDomain, getDomainList, setDefaultDomain } from '@/api/modules/domain'
import type { MailDomain, MailDomainParams } from './interface'

import DomainForm from './components/DomainForm.vue'
import DomainSsl from './components/DomainSsl/index.vue'
import DomainDns from './components/DomainDns.vue'
import DomainIpSet from './components/DomainIpSet.vue'
import IpStatus from './components/IpStatus.vue'
import NotSpam from './components/NotSpam.vue'
import BlacklistDetection from './components/BlacklistDetection.vue'
import CheckLogs from './components/CheckLogs.vue'

const { t } = useI18n()

const { tableParams, tableList, loading, tableTotal, getTableData } = useTableData<
	MailDomain,
	MailDomainParams
>({
	immediate: true,
	params: {
		page: 1,
		page_size: 10,
		keyword: '',
	},
	fetchFn: getDomainList,
})

const route = useRoute()
const router = useRouter()

// Table columns
// The SSL pill opens the SSL dialog by mouse or keyboard
const sslTrigger = (row: MailDomain) => ({
	class: 'cursor-pointer',
	role: 'button',
	tabindex: 0,
	onClick: () => handleShowSsl(row),
	onKeydown: (e: KeyboardEvent) => {
		if (e.key === 'Enter' || e.key === ' ') {
			e.preventDefault()
			handleShowSsl(row)
		}
	},
})

const columns = ref<DataTableColumns<MailDomain>>([
	{
		key: 'domain',
		title: t('domain.columns.domain'),
		minWidth: 130,
		ellipsis: {
			tooltip: true,
		},
		render: row => {
			return (
				<div class="inline-flex items-center">
					{row.hasbrandinfo == 1 && <i class="i-lucide-badge-info w-4 h-4 mr-4px"></i>}
					<NButton text type="primary" onClick={() => handleEdit(row)}>
						{row.domain}
					</NButton>
					{row.default === 1 && (
						<NTag size="small" class="ml-8px" bordered={false}>
							{t('domain.status.default')}
						</NTag>
					)}
				</div>
			)
		},
	},
	{
		key: 'not_in_spam_list',
		title: 'Not in Spam List',
		render: row => (
			<NotSpam
				record={row.a_record}
				check-result={row.black_check_result}
				onShowCheck={() => {
					blacklistModalApi.setState({ row })
					blacklistModalApi.open()
				}}
				onShowCheckLogs={() => {
					checkLogsModalApi.setState({ row })
					checkLogsModalApi.open()
				}}
			/>
		),
	},
	{
		key: 'quota',
		title: t('domain.columns.quota'),
		render: row => getByteUnit(row.quota),
	},
	{
		key: 'mailboxes',
		title: t('domain.columns.mailboxes'),
	},
	{
		key: 'current_quota',
		title: 'Current usage',
		render: row => getByteUnit(row.current_usage),
	},
	{
		key: 'mailbox_quota',
		title: t('domain.columns.defaultMailboxSize'),
		render: row => getByteUnit(row.mailbox_quota),
	},
	// {
	// 	key: 'catch_all',
	// 	title: 'Catch All',
	// 	render: row => (
	// 		<NSwitch
	// 			value={row.catch_all}
	// 			size="small"
	// 			onUpdateValue={(val: boolean) => {
	// 				if (val) {
	// 					handleOpenCatch(row)
	// 				} else {
	// 					handleCloseCatch(row)
	// 				}
	// 			}}
	// 		/>
	// 	),
	// },
	{
		key: 'multi_ip_domains',
		title: t('domain.columns.dedicatedIp'),
		render: row => {
			if (row.multi_ip_domains) {
				return (
					<div
						class="flex items-center cursor-pointer"
						onClick={() => {
							handleMultiIpDomains(row)
						}}>
						<span class="leading-14px mr-6px">{row.multi_ip_domains.outbound_ip}</span>
						<IpStatus status={row.multi_ip_domains.status}></IpStatus>
					</div>
				)
			}
			return '--'
		},
	},
	{
		key: 'ssl',
		title: 'SSL',
		render: row => {
			if (row.cert_info && row.cert_info.endtime) {
				const ssl = row.cert_info
				const day = Math.floor((ssl.endtime * 1000 - Date.now()) / 1000 / 60 / 60 / 24)
				return (
					<BtStatus type={day < 0 ? 'error' : 'success'} {...sslTrigger(row)}>
						{day < 0 ? t('domain.ssl.expired') : t('domain.ssl.daysLeft', { days: day })}
					</BtStatus>
				)
			}
			return (
				<BtStatus type="warning" {...sslTrigger(row)}>
					{t('domain.ssl.notSet')}
				</BtStatus>
			)
		},
	},
	{
		title: t('domain.columns.actions'),
		key: 'actions',
		align: 'right',
		width: 148,
		render: row => (
			<NFlex inline={true} size={4}>
				<BtIconAction
					icon="i-lucide-network"
					label={t('domain.actions.dnsRecord')}
					onClick={() => {
						handleDNSRecord(row)
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
					icon="i-lucide-star"
					label={t('domain.actions.setDefault')}
					disabled={row.default === 1}
					onClick={() => {
						handleSetDefault(row)
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
	component: DomainForm,
	state: {
		isEdit: false,
		refresh: getTableData,
	},
})

// Handle add domain
const handleAddDomain = () => {
	formModalApi.setState({
		row: null,
		isEdit: false,
	})
	formModalApi.open()
}

// Handle open catch all
// const handleOpenCatch = (row: MailDomain) => {
// 	catchModalApi.setState({ row })
// 	catchModalApi.open()
// }

// Handle close catch all
// const handleCloseCatch = (row: MailDomain) => {
// 	console.log(row)
// }

const [SslModal, sslModalApi] = useModal({
	component: DomainSsl,
	state: {
		refresh: getTableData,
	},
})

// Handle show ssl
const handleShowSsl = (row: MailDomain) => {
	sslModalApi.setState({ row })
	sslModalApi.open()
}

const [DnsModal, dnsModalApi] = useModal({
	component: DomainDns,
	state: {
		refresh: getTableData,
	},
})

// Handle DNS records
const handleDNSRecord = (row: MailDomain) => {
	dnsModalApi.setState({ row })
	dnsModalApi.open()
}

const handleSetDefault = (row: MailDomain) => {
	confirm({
		title: t('domain.setDefault.title', { domain: row.domain }),
		content: t('domain.setDefault.confirm'),
		onConfirm: async () => {
			await setDefaultDomain({ domain: row.domain })
			getTableData()
		},
	})
}

// Handle edit
const handleEdit = (row: MailDomain) => {
	router.push({
		name: 'EditDomain',
		params: {
			domain: row.domain,
		},
	})
}

const [DomainIpSetModal, domainIpSetModalApi] = useModal({
	component: DomainIpSet,
})

// Handle multi ip domains
const handleMultiIpDomains = (row: MailDomain) => {
	domainIpSetModalApi.setState({ row })
	domainIpSetModalApi.open()
}

// Handle delete
const handleDelete = (row: MailDomain) => {
	confirm({
		title: t('domain.delete.title'),
		content: t('domain.delete.confirm', { domain: row.domain }),
		confirmText: t('common.actions.delete'),
		confirmType: 'error',
		onConfirm: async () => {
			await deleteDomain({ domain: row.domain })
			getTableData()
		},
	})
}

const [BlacklistModal, blacklistModalApi] = useModal({
	component: BlacklistDetection,
})

const [CheckLogsModal, checkLogsModalApi] = useModal({
	component: CheckLogs,
})

// Whether should open create modal automic
const initDomainFlag = ref('')

onMounted(() => {
	initDomainFlag.value = route.query.init as string
	if (initDomainFlag.value === 'init-domain') {
		handleAddDomain()
	}
})
</script>

<style lang="scss" scoped></style>

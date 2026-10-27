<template>
	<div class="p-24px">
		<bt-table-layout>
			<template #toolsRight>
				<n-select
					v-model:value="tableParams.tier"
					:options="tierOptions"
					:placeholder="'Filter by tier'"
					clearable
					style="width: 160px; margin-right: 12px"
					@update:value="() => fetchTable(true)"
				/>
			</template>
			<template #table>
				<n-data-table v-bind="tableProps" :columns="columns" :row-key="(row: any) => row.contact_email">
					<template #empty>
						<bt-table-help> </bt-table-help>
					</template>
				</n-data-table>
			</template>
			<template #pageRight>
				<bt-table-page v-bind="pageProps" @refresh="fetchTable"> </bt-table-page>
			</template>
		</bt-table-layout>
	</div>
</template>

<script lang="tsx" setup>
import { DataTableColumns, NTag, NButton } from 'naive-ui'
import { useDataTable } from '@/hooks/useDataTable'
import BtStatus from '@/components/base/bt-status/index.vue'
import { listVideoOutreach } from '@/api/modules/video-outreach'

const tierOptions = [
	{ label: 'Tier 1 (Video)', value: 'tier_1' },
	{ label: 'Tier 2 (Text)', value: 'tier_2' },
]

const { tableProps, pageProps, tableParams, fetchTable } = useDataTable<any>({
	params: {
		page: 1,
		page_size: 20,
		tier: null as string | null,
	},
	fetchFn: listVideoOutreach,
})

const columns: DataTableColumns<any> = [
	{
		title: 'Email',
		key: 'contact_email',
		ellipsis: { tooltip: true },
	},
	{
		title: 'Tier',
		key: 'lead_tier',
		width: 100,
		render: (row) => {
			const typeMap: Record<string, string> = {
				tier_1: 'success',
				tier_2: 'info',
			}
			return <NTag type={typeMap[row.lead_tier] || 'default'} size="small">{row.lead_tier || '-'}</NTag>
		},
	},
	{
		title: 'Score',
		key: 'lead_score',
		width: 80,
	},
	{
		title: 'Status',
		key: 'status',
		width: 120,
		render: (row) => {
			const typeMap: Record<string, 'success' | 'warning' | 'default'> = {
				ready: 'success',
				pending: 'warning',
				not_eligible: 'default',
			}
			return <BtStatus type={typeMap[row.status] || 'default'}>{row.status}</BtStatus>
		},
	},
	{
		title: 'Video',
		key: 'video_url',
		width: 100,
		render: (row) => {
			if (row.video_url) {
				return <NButton text type="primary" tag="a" href={row.landing_page_url} target="_blank">View</NButton>
			}
			return '-'
		},
	},
]
</script>

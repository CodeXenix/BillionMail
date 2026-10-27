<template>
	<div class="p-24px">
		<div class="flex justify-between items-center gap-16px mb-16px">
			<n-breadcrumb>
				<n-breadcrumb-item>
					<router-link to="/market/task">{{ $t('market.task.title') }}</router-link>
				</n-breadcrumb-item>
				<n-breadcrumb-item>{{ $t('market.task.actions.analytics') }}</n-breadcrumb-item>
				<n-breadcrumb-item>
					<n-ellipsis style="max-width: 300px">
						<span class="font-bold text-basic">{{ subject || '--' }}</span>
					</n-ellipsis>
				</n-breadcrumb-item>
			</n-breadcrumb>
			<bt-time-range v-model:value="dateRange" default-type="last7days" @change="fetchOverviewData">
			</bt-time-range>
		</div>

		<!-- Main Metric Cards -->
		<div class="metrics-cards">
			<metric-card
				v-for="item in metrics"
				:key="item.key"
				:title="item.title"
				:value="item.value"
				unit="%"
				:icon="item.icon"
				:caption="item.caption">
			</metric-card>
		</div>

		<!-- Data Details Area -->
		<div class="detail-row">
			<!-- Left: Mail Provider Table -->
			<n-card :title="$t('overview.mailProviders')">
				<provider-table v-model:value="providers" />
			</n-card>

			<!-- Right: Today's Sending Statistics -->
			<n-card :title="$t('overview.sendStats')">
				<send-today-stats :data="sendMail" />
			</n-card>
		</div>

		<!-- Bottom Rate Charts Area -->
		<div class="rate-charts-card">
			<rate-chart-panel :bounce="bounceRate" :click="clickRate" :open="openRate" />
		</div>
	</div>
</template>

<script lang="ts" setup>
import { getDayTimeRange, getNumber, isArray, isObject } from '@/utils'
import { getTaskDetails, getTaskOverview } from '@/api/modules/market/task'
import type { MailDashboard, MailOverview, MailProvider } from '@/views/overview/types'

import MetricCard from '@/views/overview/components/MetricCard.vue'
import ProviderTable from '@/views/overview/components/ProviderTable.vue'
import SendTodayStats from '@/views/overview/components/SendTodayStats.vue'
import RateChartPanel from '@/views/overview/components/RateChartPanel.vue'

const route = useRoute()

const { t, locale } = useI18n()

const id = computed(() => {
	return getNumber(route.params.id || '0')
})

const dateRange = ref(getDayTimeRange())

const providers = ref<MailProvider[]>([])

const dashboard = ref<MailDashboard>({
	sends: 0,
	delivered: 0,
	delivery_rate: 0,
	opened: 0,
	open_rate: 0,
	clicked: 0,
	click_rate: 0,
	bounced: 0,
	bounce_rate: 0,
	delayed_queue: 0,
})

const formatCount = (val: number) => val.toLocaleString(locale.value)

// Each rate card shows the counts behind it: part / whole (as on Overview)
const metrics = computed(() => {
	const d = dashboard.value
	return [
		{
			key: 'delivery_rate',
			title: t('overview.delivered'),
			icon: 'i-lucide-mail-check',
			value: d.delivery_rate,
			caption: `${formatCount(d.delivered)} / ${formatCount(d.sends)}`,
		},
		{
			key: 'open_rate',
			title: t('overview.opened'),
			icon: 'i-lucide-mail-open',
			value: d.open_rate,
			caption: `${formatCount(d.opened)} / ${formatCount(d.delivered)}`,
		},
		{
			key: 'click_rate',
			title: t('overview.clicked'),
			icon: 'i-lucide-mouse-pointer-click',
			value: d.click_rate,
			caption: `${formatCount(d.clicked)} / ${formatCount(d.delivered)}`,
		},
		{
			key: 'bounce_rate',
			title: t('overview.bounced'),
			icon: 'i-lucide-mail-warning',
			value: d.bounce_rate,
			caption: `${formatCount(d.bounced)} / ${formatCount(d.sends)}`,
		},
	]
})

const sendMail = ref<MailOverview['send_mail_chart']>({
	column_type: 'hourly',
	dashboard: {
		delivered: 0,
		delivery_rate: 0,
		failed: 0,
		failure_rate: 0,
		sends: 0,
	},
	data: [],
})

const bounceRate = ref<MailOverview['bounce_rate_chart']>({
	column_type: 'hourly',
	data: [],
})

const clickRate = ref<MailOverview['click_rate_chart']>({
	column_type: 'hourly',
	data: [],
})

const openRate = ref<MailOverview['open_rate_chart']>({
	column_type: 'hourly',
	data: [],
})

// No onMounted fetch: bt-time-range sets its default range during setup and emits change once,
// which is the first load
async function fetchOverviewData() {
	const res = await getTaskOverview({
		task_id: id.value,
		start_time: Math.floor(dateRange.value[0] / 1000),
		end_time: Math.floor(dateRange.value[1] / 1000),
	})

	if (isObject<MailOverview>(res)) {
		dashboard.value = res.dashboard
		providers.value = isArray(res.mail_providers) ? res.mail_providers : []
		sendMail.value = res.send_mail_chart
		bounceRate.value = res.bounce_rate_chart
		clickRate.value = res.click_rate_chart
		openRate.value = res.open_rate_chart
	}
}

const subject = ref('')

const getDetails = async () => {
	const res = await getTaskDetails({ id: id.value })
	if (isObject<{ subject: string }>(res)) {
		subject.value = res.subject
	}
}

getDetails()
</script>

<style lang="scss" scoped>
@use '../../overview/dashboard.scss';
</style>

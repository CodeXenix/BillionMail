<template>
	<div class="p-24px">
		<h1 class="bt-title">{{ t('layout.menu.overview') }}</h1>
		<!-- Top Filter Area -->
		<filter-bar
			v-model:domain="domain"
			v-model:date-range="dateRange"
			@update:domain="handleDataUpdate"
			@update:date-range="handleDataUpdate">
		</filter-bar>

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
			<metric-card
				class="cursor-pointer"
				role="button"
				tabindex="0"
				icon="i-lucide-clock"
				:title="$t('overview.delayedQueue')"
				:value="dashboard.delayed_queue"
				:text-color="dashboard.delayed_queue > 0 ? theme.warningColor : ''"
				@click="onClickDelayedQueue"
				@keydown.enter="onClickDelayedQueue"
				@keydown.space.prevent="onClickDelayedQueue">
				<i
					v-if="dashboard.delayed_queue > 0"
					class="i-lucide-triangle-alert text-20px"
					aria-hidden="true"></i>
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
				<send-today-stats :data="sendMail" @show-fail="handleShowFail" />
			</n-card>
		</div>

		<!-- Bottom Rate Charts Area -->
		<div class="rate-charts-card">
			<rate-chart-panel :bounce="bounceRate" :click="clickRate" :open="openRate" />
		</div>

		<fail-modal />
	</div>
</template>

<script lang="ts" setup>
import { useDebounceFn } from '@vueuse/core'
import { useThemeVars } from 'naive-ui'
import { getDayTimeRange, isArray, isObject } from '@/utils'
import { useModal } from '@/hooks/modal/useModal'
import { getOverviewInfo } from '@/api/modules/overview'
import type { MailDashboard, MailOverview, MailProvider } from './types'

import FilterBar from './components/FilterBar.vue'
import MetricCard from './components/MetricCard.vue'
import ProviderTable from './components/ProviderTable.vue'
import SendTodayStats from './components/SendTodayStats.vue'
import RateChartPanel from './components/RateChartPanel.vue'
import SendFailDetails from './components/SendFailDetails.vue'

const { t, locale } = useI18n()

const theme = useThemeVars()

const domain = ref('')

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

// Each rate card shows the counts behind it: part / whole
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

const router = useRouter()

const onClickDelayedQueue = () => {
	router.push('/settings/send-queue')
}

const [FailModal, failModalApi] = useModal({
	component: SendFailDetails,
})

const handleShowFail = () => {
	failModalApi.setState({
		domain: domain.value,
		startTime: dateRange.value[0],
		endTime: dateRange.value[1],
	})
	failModalApi.open()
}

// Function to fetch overview data
async function fetchOverviewData() {
	const res = await getOverviewInfo({
		domain: domain.value,
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

// Every filter change refetches, debounced. No onMounted fetch: bt-time-range (in FilterBar)
// sets the range once during its setup, and that update is the first load
const handleDataUpdate = useDebounceFn(fetchOverviewData, 300)
</script>

<style lang="scss" scoped>
@use './dashboard.scss';
</style>

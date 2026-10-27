<template>
	<div class="h-180px">
		<bt-charts :options="chartOptions" />
	</div>
</template>

<script setup lang="ts">
import { formatTime } from '@/utils'
import { useThemeStore } from '@/store'

const { chartName, dateType, chartData } = defineProps({
	chartName: {
		type: String,
		required: true,
	},
	dateType: {
		type: String,
		required: true,
	},
	chartData: {
		type: Array as PropType<[string, number][]>,
		required: true,
	},
})

const themeStore = useThemeStore()

const chartOptions = computed(() => {
	// ECharts needs concrete colours: read the tokens again whenever the theme store
	// swaps its overrides (after the light/dark attribute has changed)
	const { textColor1, textColor3 } = themeStore.themeOverrides.common ?? {}
	const css = getComputedStyle(document.documentElement)
	const token = (name: string) => css.getPropertyValue(name).trim()
	const lineColor = token('--color-chart-1')
	const gridColor = token('--color-chart-grid')

	return {
		tooltip: {
			trigger: 'axis',
			axisPointer: {
				type: 'line',
			},
			backgroundColor: token('--color-bg-1'),
			borderColor: token('--color-border-1'),
			textStyle: {
				color: textColor1,
			},
		},
		grid: {
			top: '16%',
			left: '2%',
			right: '2%',
			bottom: '2%',
			containLabel: true,
		},
		xAxis: {
			type: 'category',
			axisLine: {
				lineStyle: {
					color: gridColor,
				},
			},
			axisTick: {
				show: false,
			},
			axisLabel: {
				color: textColor3,
				formatter: (val: string) => {
					if (dateType === 'hourly') {
						return formatTime(val, 'HH:mm')
					}
					return formatTime(val, 'yyyy-MM-dd')
				},
			},
		},
		yAxis: {
			name: '%',
			type: 'value',
			max: 100,
			nameTextStyle: {
				color: textColor3,
			},
			axisLabel: {
				color: textColor3,
			},
			splitLine: {
				show: true,
				lineStyle: {
					type: 'solid',
					width: 1,
					color: gridColor,
				},
			},
		},
		series: [
			{
				name: chartName,
				type: 'line',
				data: chartData,
				itemStyle: {
					color: lineColor,
				},
				lineStyle: {
					width: 2,
				},
				areaStyle: {
					color: lineColor,
					opacity: 0.1,
				},
				smooth: false,
				showSymbol: false,
				sampling: 'average',
			},
		],
	}
})
</script>

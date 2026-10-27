<template>
	<bt-charts :options="chartOptions" />
</template>

<script setup lang="ts">
import { formatTime } from '@/utils'
import { useThemeStore } from '@/store'

type BarPoint = [string, number, string]

const { dateType, chartData } = defineProps({
	dateType: {
		type: String,
		required: true,
	},
	chartData: {
		type: Object as PropType<{
			fail: {
				label: string
				value: BarPoint[]
			}
			success: {
				label: string
				value: BarPoint[]
			}
		}>,
		required: true,
	},
})

const themeStore = useThemeStore()

const chartOptions = computed(() => {
	// ECharts needs concrete colours: read the tokens again whenever the theme store
	// swaps its overrides (after the light/dark attribute has changed)
	const { textColor1, textColor2, textColor3 } = themeStore.themeOverrides.common ?? {}
	const css = getComputedStyle(document.documentElement)
	const token = (name: string) => css.getPropertyValue(name).trim()
	const gridColor = token('--color-chart-grid')
	const surface = token('--color-bg-1')

	const { success, fail } = chartData

	// Stacked bar: only the topmost non-empty segment gets the rounded data end
	const point = (value: BarPoint, isTop: boolean) => ({
		value,
		itemStyle: { borderRadius: isTop ? [4, 4, 0, 0] : 0 },
	})
	const bar = (name: string, color: string, data: ReturnType<typeof point>[]) => ({
		type: 'bar',
		name,
		stack: 'total',
		barMaxWidth: 24,
		itemStyle: { color, borderColor: surface, borderWidth: 1 },
		data,
	})

	return {
		grid: {
			top: '16%',
			left: '2%',
			right: '2%',
			bottom: '4%',
			containLabel: true,
		},
		legend: {
			top: 0,
			itemGap: 16,
			icon: 'circle',
			itemWidth: 8,
			itemHeight: 8,
			textStyle: {
				color: textColor2,
			},
			data: [success.label, fail.label],
		},
		tooltip: {
			trigger: 'axis',
			order: 'seriesDesc',
			axisPointer: {
				type: 'line',
			},
			backgroundColor: surface,
			borderColor: token('--color-border-1'),
			textStyle: {
				color: textColor1,
			},
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
			type: 'value',
			boundaryGap: [0, '6%'],
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
			// Failed sits at the baseline; it is the top segment only where nothing was delivered
			bar(
				fail.label,
				token('--color-chart-2'),
				fail.value.map((item, i) => point(item, !success.value[i]?.[1]))
			),
			bar(
				success.label,
				token('--color-chart-1'),
				success.value.map(item => point(item, true))
			),
		],
	}
})
</script>

<template>
	<n-card class="metric-card">
		<div class="metric-head">
			<span class="metric-title">{{ title }}</span>
			<span v-if="icon" class="metric-icon">
				<i :class="icon"></i>
			</span>
		</div>
		<div class="metric-value" :style="{ color: textColor }">
			{{ value.toLocaleString(locale) }}{{ unit }}
			<!-- Optional marker beside the value, e.g. a warning icon -->
			<slot></slot>
		</div>
		<div v-if="caption" class="metric-caption">{{ caption }}</div>
	</n-card>
</template>

<script setup lang="ts">
const { locale } = useI18n()

defineProps({
	title: {
		type: String,
		default: '',
	},
	value: {
		type: Number,
		default: 0,
	},
	unit: {
		type: String,
		default: '',
	},
	textColor: {
		type: String,
	},
	icon: {
		type: String,
		default: '',
	},
	caption: {
		type: String,
		default: '',
	},
})
</script>

<style lang="scss" scoped>
.metric-head {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 8px;
	margin-bottom: 8px;
}

.metric-title {
	font-size: 13px;
	font-weight: 500;
	color: var(--color-text-2);
}

.metric-icon {
	display: flex;
	flex-shrink: 0;
	align-items: center;
	justify-content: center;
	width: 28px;
	height: 28px;
	border-radius: 8px;
	font-size: 16px;
	color: var(--color-primary-1);
	background-color: var(--color-primary-2);
}

.metric-value {
	display: flex;
	align-items: center;
	gap: 4px;
	font-size: 24px;
	font-weight: 600;
	line-height: 1.2;
	font-variant-numeric: tabular-nums;
	color: var(--color-text-1);
}

.metric-caption {
	margin-top: 4px;
	font-size: 12px;
	font-variant-numeric: tabular-nums;
	color: var(--color-text-3);
}
</style>

<template>
	<n-tag class="bt-status" :type="type" size="small" round :bordered="false">
		<span class="dot"></span>
		<slot></slot>
	</n-tag>
</template>

<script lang="ts" setup>
// Status pill: a soft tag with a dot in the state's colour
withDefaults(
	defineProps<{
		type?: 'default' | 'primary' | 'success' | 'info' | 'warning' | 'error'
	}>(),
	{
		type: 'default',
	}
)
</script>

<style lang="scss" scoped>
.bt-status {
	font-weight: 500;
}

.dot {
	display: inline-block;
	width: 6px;
	height: 6px;
	margin-right: 4px;
	border-radius: 50%;
	background-color: currentColor;
}
</style>

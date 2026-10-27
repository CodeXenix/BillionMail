<template>
	<bt-status :type="value ? 'success' : 'error'" class="whitespace-nowrap">
		{{ value ? $t('smtp.status.online') : $t('smtp.status.offline') }}
	</bt-status>
</template>

<script lang="ts" setup>
defineProps({
	value: {
		type: Boolean,
		default: false,
	},
})
</script>

<style lang="scss" scoped></style>

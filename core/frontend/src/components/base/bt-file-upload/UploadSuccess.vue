<template>
	<div class="drag-icon">
		<i class="i-lucide-file"></i>
	</div>
	<div class="drag-text">{{ fileName }}</div>
</template>

<script lang="ts" setup>
defineProps({
	fileName: {
		type: String,
		default: '',
	},
})
</script>
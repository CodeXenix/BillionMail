<template>
	<div class="inline-flex items-center text-16px">
		<template v-if="status === 'applied'">
			<i class="i-lucide-circle-check text-primary"></i>
		</template>
		<template v-if="status === 'failed'">
			<div class="inline-flex flex-center w-16px h-16px bg-error rounded-full">
				<i class="i-lucide-unlink text-#fff text-10px"></i>
			</div>
		</template>
		<template v-if="status === 'pending'">
			<i class="i-lucide-clock text-desc"></i>
		</template>
		<template v-if="status === 'applying'">
			<n-spin :show="true" :size="16"></n-spin>
		</template>
	</div>
</template>

<script lang="ts" setup>
defineProps({
	status: {
		type: String,
		default: 'pending',
	},
})
</script>

<style lang="scss" scoped></style>

<template>
	<div class="bt-table-help">
		<span class="empty-icon">
			<i class="i-lucide-inbox"></i>
		</span>
		<div class="empty-title">{{ $t('components.tableHelp.title') }}</div>
		<!-- Optional primary action, e.g. the page's "Add …" button -->
		<div v-if="$slots.default" class="empty-action">
			<slot></slot>
		</div>
	</div>
</template>

<style lang="scss" scoped>
.bt-table-help {
	display: flex;
	flex-direction: column;
	align-items: center;
	padding: 24px 16px;
	text-align: center;
}

.empty-icon {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	width: 48px;
	height: 48px;
	margin-bottom: 12px;
	border-radius: 50%;
	font-size: 24px;
	color: var(--color-primary-1);
	background-color: var(--color-primary-2);
}

.empty-title {
	margin-bottom: 4px;
	font-size: 15px;
	font-weight: 600;
	color: var(--color-text-1);
}

.empty-action {
	margin-top: 16px;
}
</style>

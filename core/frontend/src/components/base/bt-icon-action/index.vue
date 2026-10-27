<template>
	<n-tooltip :show="show" :show-arrow="false" placement="top">
		<template #trigger>
			<n-button
				class="bt-icon-action"
				quaternary
				circle
				size="small"
				:type="type"
				:disabled="disabled"
				:aria-label="label"
				@click="onClick"
				@mouseenter="show = true"
				@mouseleave="show = false"
				@focusin="show = true"
				@focusout="show = false">
				<template #icon>
					<i :class="icon"></i>
				</template>
			</n-button>
		</template>
		{{ label }}
	</n-tooltip>
</template>

<script lang="ts" setup>
// Icon-only row action: the label shows as a tooltip (on hover and on keyboard focus) and is the accessible name
withDefaults(
	defineProps<{
		icon: string
		label: string
		type?: 'default' | 'primary' | 'error' | 'warning'
		disabled?: boolean
	}>(),
	{
		type: 'default',
		disabled: false,
	}
)

const emit = defineEmits<{
	click: [event: MouseEvent]
}>()

const show = ref(false)

const onClick = (event: MouseEvent) => {
	emit('click', event)
}
</script>

<style lang="scss" scoped>
.bt-icon-action {
	--n-icon-size: 16px;
}

.bt-icon-action.n-button--default-type {
	--n-text-color: var(--color-text-2);
}
</style>

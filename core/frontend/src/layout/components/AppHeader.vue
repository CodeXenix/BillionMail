<template>
	<n-layout-header ref="headerRef" bordered :style="{ top: `${top}px` }">
		<div class="header-left">
			<n-button class="icon-btn" :bordered="false" @click="handleCollapse">
				<i class="icon" :class="isCollapse ? 'i-lucide-panel-left-open' : 'i-lucide-panel-left-close'"></i>
			</n-button>
		</div>

		<div class="header-right">
			<n-button class="icon-btn" :bordered="false" @click="handleSetTheme">
				<i class="icon" :class="theme === 'light' ? 'i-lucide-sun' : 'i-lucide-moon'"></i>
			</n-button>
			<n-dropdown
				v-if="langOptions.length > 0"
				size="large"
				:options="langOptions"
				@select="handleLangAction">
				<n-button class="icon-btn" :bordered="false">
					<i class="icon i-lucide-languages"></i>
				</n-button>
			</n-dropdown>
			<InstanceSwitcher />
			<n-dropdown size="large" :options="userOptions" @select="handleUserAction">
				<n-button class="icon-btn" :bordered="false">
					<i class="icon i-lucide-user"></i>
				</n-button>
			</n-dropdown>
		</div>
	</n-layout-header>
</template>

<script lang="ts" setup>
import { storeToRefs } from 'pinia'
import { DropdownOption } from 'naive-ui'
import { useUserStore, useGlobalStore, useThemeStore } from '@/store'
import InstanceSwitcher from './InstanceSwitcher.vue'

defineProps({
	top: {
		type: Number,
		default: 0,
	},
})

const { t } = useI18n()

const userStore = useUserStore()

const globalStore = useGlobalStore()
const { isCollapse, langList } = storeToRefs(globalStore)

const themeStore = useThemeStore()
const { theme } = storeToRefs(themeStore)

const handleCollapse = () => {
	globalStore.setCollapse()
}

const langOptions = ref<DropdownOption[]>([])

const userOptions = ref<DropdownOption[]>([
	{
		label: t('layout.menu.logout'),
		key: 'logout',
	},
])

const handleSetTheme = () => {
	themeStore.setTheme(theme.value === 'dark' ? 'light' : 'dark')
}

const handleLangAction = async (key: string) => {
	await globalStore.setLang(key)
	window.location.reload()
}

const handleUserAction = (key: string) => {
	switch (key) {
		case 'logout':
			userStore.logout()
			break
	}
}

const getLangOptions = async () => {
	langOptions.value = langList.value.map(item => {
		return {
			label: item.cn,
			key: item.name,
		}
	})
}

onMounted(() => {
	getLangOptions()
})
</script>

<style lang="scss" scoped>
.n-layout-header {
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	display: flex;
	justify-content: space-between;
	align-items: center;
	height: 48px;
	padding: 0 16px 0 8px;
	z-index: 1000;

	// :deep so InstanceSwitcher's button (a fragment child) gets the same look
	:deep(.icon-btn) {
		--n-width: 36px;
		--n-height: 36px;
		--n-padding: 0;
		--n-font-size: 20px;
		--n-text-color: var(--color-text-4);
		--n-text-color-hover: var(--color-text-1);
		--n-text-color-pressed: var(--color-text-1);
		--n-color-hover: var(--color-bg-2);
		--n-color-pressed: var(--color-bg-2);
		--n-ripple-color: none;
	}
}

.header-left,
.header-right {
	display: flex;
	align-items: center;
	gap: 4px;
}
</style>

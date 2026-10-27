<template>
	<n-layout-sider
		bordered
		collapse-mode="width"
		:collapsed="isCollapse"
		:width="220"
		:collapsed-width="64"
		:content-style="{
			display: 'flex',
			flexDirection: 'column',
			height: '100%',
			overflow: 'hidden',
		}">
		<!-- 应用标志和名称 -->
		<div class="app-logo" :class="{ collapse: isCollapse }">
			<a href="/">
				<img class="logo" src="@/assets/images/logo.svg" alt="Xenix Mail" />
				<span v-show="!isCollapse" class="app-name">Xenix Mail</span>
			</a>
		</div>

		<!-- 导航菜单 -->
		<div class="nav-section">
			<n-menu
				:value="activeMenuKey"
				:collapsed="isCollapse"
				:collapsed-width="64"
				:options="menuOptions"
				:root-indent="20"
				:indent="0"
				@update:value="handleUpdateMenu">
			</n-menu>
		</div>
		<!-- 退出登录 -->
		<div class="footer-section">
			<n-menu
				value=""
				:collapsed="isCollapse"
				:collapsed-width="64"
				:options="logoutOptions"
				:root-indent="20"
				@update:value="handleUpdateMenu">
			</n-menu>
		</div>
	</n-layout-sider>
</template>

<script lang="tsx" setup>
import { VNodeChild } from 'vue'
import { MenuDividerOption, MenuGroupOption, MenuOption } from 'naive-ui'
import { storeToRefs } from 'pinia'
import { RouterLink } from 'vue-router'
import { useMenuStore, useGlobalStore, useUserStore } from '@/store'
import { menuList } from '@/router/router'

const { t } = useI18n()

const route = useRoute()

const menuStore = useMenuStore()
const userStore = useUserStore()
const globalStore = useGlobalStore()

const { isCollapse } = storeToRefs(globalStore)

// 当前菜单名称
const activeMenuKey = computed(() => {
	return String(route.meta?.key || '')
})

// 路由菜单
const routerMenus = computed(() => {
	return menuStore.menuList.filter(route => route.meta && !route.meta.hidden)
})

// 菜单分组（按 route.meta.key）；Overview 置顶，未列出的菜单追加在末尾
const menuGroups: [string, string[]][] = [
	['groupMarketing', ['market', 'template', 'api', 'contacts', 'video-outreach']],
	['groupMailServer', ['domain', 'mailbox', 'smtp']],
	['groupSystem', ['logs', 'settings']],
]

// 导航菜单选项
const menuOptions = computed(() => {
	const items: MenuOption[] = routerMenus.value.map(route => {
		const name = String(route.children?.[0]?.name || '')
		const key = String(route.meta?.key || '')
		const titleKey = String(route.meta?.titleKey || '')
		const title = titleKey ? t(titleKey) : String(route.meta?.title || '')
		return {
			key,
			label: () => renderLabel(name, title),
			icon: () => renderIcon(key),
		}
	})
	const pick = (keys: string[]) => items.filter(item => keys.includes(String(item.key)))
	const groupedKeys = ['overview', ...menuGroups.flatMap(([, keys]) => keys)]
	const groups = menuGroups
		.map(([label, keys]) => ({ type: 'group' as const, key: label, label: t(`layout.menu.${label}`), children: pick(keys) }))
		.filter(group => group.children.length > 0)
	const rest = items.filter(item => !groupedKeys.includes(String(item.key)))

	// 折叠时分组标题无法在 64px 栏中显示，改为平铺 + 分隔线，保持图标居中和 tooltip
	const middle: Array<MenuOption | MenuGroupOption | MenuDividerOption> = isCollapse.value
		? groups.flatMap(group => [{ type: 'divider' as const, key: `${group.key}-divider` }, ...group.children])
		: groups
	return [...pick(['overview']), ...middle, ...rest]
})

const logoutOptions = ref<MenuOption[]>([
	{
		key: 'logout',
		label: () => <span>{t('layout.menu.logout')}</span>,
		icon: () => renderIcon('logout'),
	},
])

const renderLabel = (name: string, title: string) => {
	return (
		<RouterLink class="flex items-center" to={{ name }}>
			<span>{title}</span>
		</RouterLink>
	)
}

const iconMap: Record<string, VNodeChild> = {
	overview: <i class="i-lucide-layout-dashboard"></i>,
	market: <i class="i-lucide-megaphone"></i>,
	api: <i class="i-lucide-code-xml"></i>,
	contacts: <i class="i-lucide-users"></i>,
	sequences: <i class="i-lucide-repeat"></i>,
	leads: <i class="i-lucide-user-search"></i>,
	enrichment: <i class="i-lucide-database-zap"></i>,
	domain: <i class="i-lucide-globe"></i>,
	mailbox: <i class="i-lucide-inbox"></i>,
	smtp: <i class="i-lucide-server-cog"></i>,
	settings: <i class="i-lucide-settings"></i>,
	template: <i class="i-lucide-layout-template"></i>,
	logs: <i class="i-lucide-scroll-text"></i>,
	'video-outreach': <i class="i-lucide-video"></i>,
	logout: <i class="i-lucide-log-out"></i>,
}

const renderIcon = (key: string) => {
	return iconMap[key]
}

const handleUpdateMenu = (key: string) => {
	if (key === 'logout') {
		userStore.logout()
	}
	if (key === 'webmail') {
		const route = routerMenus.value.find(item => item.meta?.key === 'webmail')
		if (route) {
			const href = String(route.meta?.href)
			window.open(href)
		}
	}
}

onMounted(() => {
	menuStore.setMenuList(menuList)
})
</script>

<style lang="scss" scoped>
.app-logo {
	display: flex;
	align-items: center;
	height: 48px;
	padding: 0 16px;
	transition: all 0.3s ease;
	border-bottom: 1px solid var(--color-border-1);

	&.collapse {
		justify-content: center;
		padding: 0;
	}

	a {
		display: flex;
		align-items: center;
		gap: 8px;
	}

	.logo {
		width: 28px;
	}

	.app-name {
		font-size: 16px;
		font-weight: bold;
		white-space: nowrap;
		color: var(--color-text-5);
	}
}

.nav-section {
	flex: 1;
	overflow: auto;
}

.footer-section {
	border-top: 1px solid var(--color-border-1);
	transition: all 0.3s ease;
}

.n-menu {
	padding: 8px 0;

	:deep(.n-menu-item) {
		margin-top: 4px;
	}

	:deep(.n-menu-item-group-title) {
		height: 32px;
		margin-top: 8px;
		font-size: 12px;
		font-weight: 600;
	}

	:deep(.n-menu-divider) {
		margin: 8px 16px;
	}
}
</style>

import { defineStore } from 'pinia'
import { GlobalThemeOverrides } from 'naive-ui'

export default defineStore(
	'ThemeStore',
	() => {
		const theme = ref<'light' | 'dark'>('light')

		const getCssVar = (name: string) => {
			return getComputedStyle(document.documentElement).getPropertyValue(name).trim()
		}

		const getThemeOverrides = (): GlobalThemeOverrides => {
			return {
				common: {
					lineHeight: 'normal',
					fontSize: '14px',
					fontSizeMini: '12px',
					fontSizeTiny: '12px',
					fontSizeSmall: '13px',
					fontSizeMedium: '14px',
					fontSizeLarge: '15px',
					fontSizeHuge: '16px',
					borderRadius: '6px',
					borderRadiusSmall: '4px',
					baseColor: '#fff',
					textColor1: getCssVar('--color-text-1'),
					textColor2: getCssVar('--color-text-2'),
					textColor3: getCssVar('--color-text-3'),
					borderColor: getCssVar('--color-border-1'),
					dividerColor: getCssVar('--color-border-1'),
					cardColor: getCssVar('--color-bg-1'),
					modalColor: getCssVar('--color-bg-1'),
					popoverColor: getCssVar('--color-bg-1'),
					tableColor: getCssVar('--color-bg-1'),
					primaryColor: getCssVar('--color-primary-1'),
					primaryColorHover: getCssVar('--color-primary-hover-1'),
					successColor: getCssVar('--color-primary-1'),
					successColorHover: getCssVar('--color-primary-hover-1'),
					warningColor: getCssVar('--color-warning-1'),
					errorColor: getCssVar('--color-error-1'),
				},
				Layout: {
					color: getCssVar('--color-bg-2'),
					textColor: getCssVar('--color-text-1'),
					headerColor: getCssVar('--color-bg-1'),
					siderColor: getCssVar('--color-bg-1'),
					siderTextColor: getCssVar('--color-sider-text-1'),
					headerBorderColor: getCssVar('--color-border-1'),
					siderBorderColor: getCssVar('--color-border-1'),
				},
				Menu: {
					fontSize: '14px',
					itemHeight: '36px',
					borderRadius: '8px',
					groupTextColor: getCssVar('--color-text-3'),
					itemColorHover: getCssVar('--color-bg-2'),
					itemTextColor: getCssVar('--color-menu-1'),
					itemIconColor: getCssVar('--color-menu-1'),
					itemColorActive: getCssVar('--color-menu-active-1'),
					itemTextColorActive: getCssVar('--color-menu-active-2'),
					itemIconColorActive: getCssVar('--color-menu-active-2'),
					itemColorActiveHover: getCssVar('--color-menu-active-1'),
					itemTextColorActiveHover: getCssVar('--color-menu-active-2'),
					itemIconColorActiveHover: getCssVar('--color-menu-active-2'),
					itemColorActiveCollapsed: getCssVar('--color-menu-active-1'),
				},
				Card: {
					color: getCssVar('--color-bg-1'),
					borderColor: getCssVar('--color-border-1'),
					borderRadius: '12px',
					paddingMedium: '16px 20px',
					titleFontSizeMedium: '15px',
					titleFontWeight: '600',
					titleTextColor: getCssVar('--color-text-1'),
				},
				Form: {
					feedbackHeightMedium: '20px',
					feedbackHeightLarge: '22px',
					feedbackFontSizeMedium: '12px',
					feedbackFontSizeLarge: '12px',
					feedbackPadding: '2px 0 0',
					labelFontSizeTopMedium: '13px',
					labelFontSizeLeftMedium: '13px',
					labelPaddingHorizontal: '0 20px 0 0',
					labelFontWeight: '700',
				},
				Radio: {
					buttonColor: getCssVar('--color-radio-1'),
					buttonColorActive: getCssVar('--color-radio-2'),
					buttonTextColor: getCssVar('--color-text-2'),
					buttonTextColorHover: getCssVar('--color-text-1'),
					buttonTextColorActive: getCssVar('--color-text-1'),
					buttonBorderColor: 'transparent',
					buttonBorderColorHover: 'transparent',
					buttonBorderColorActive: 'transparent',
					buttonBoxShadowHover: 'none',
					buttonBoxShadowFocus: 'none',
					buttonBorderRadius: '6px',
					labelPadding: '0 0 0 8px',
				},
				Dialog: {
					contentMargin: '16px 0',
					textColor: getCssVar('--color-text-1'),
				},
				DataTable: {
					thPaddingMedium: '10px 12px',
					tdPaddingMedium: '10px 12px',
					thColor: getCssVar('--color-table-th-1'),
					tdColor: getCssVar('--color-table-td-1'),
					tdColorHover: getCssVar('--color-table-th-1'),
					thFontWeight: '600',
					thTextColor: getCssVar('--color-text-2'),
					borderColor: getCssVar('--color-border-1'),
					borderRadius: '8px',
				},
				Breadcrumb: {
					fontSize: '14px',
				},
				Switch: {
					railColorActive: getCssVar('--color-primary-1'),
				},
				Tabs: {
					tabBorderRadius: '6px',
				},
				Progress: {
					textColorLineInner: '#fff',
				},
				Button: {
					color: getCssVar('--color-bg-1'),
					colorHover: getCssVar('--color-bg-1'),
					fontWeight: '500',
				},
			}
		}

		const themeOverrides = ref<GlobalThemeOverrides>(getThemeOverrides())

		const setTheme = (val: 'light' | 'dark') => {
			theme.value = val
		}

		const changeTheme = () => {
			const isDarkMode = theme.value === 'dark'
			document.documentElement.setAttribute('theme-mode', isDarkMode ? 'dark' : '')
			nextTick(() => {
				themeOverrides.value = getThemeOverrides()
			})
		}

		return {
			theme,
			themeOverrides,
			setTheme,
			changeTheme,
		}
	},
	{
		persist: {
			pick: ['theme'],
		},
	}
)

<template>
	<div class="login-container">
		<aside class="brand-panel">
			<div class="brand-content">
				<img class="brand-logo" src="@/assets/images/logo-white.svg" alt="" />
				<div class="brand-name">{{ t('login.title') }}</div>
				<p class="brand-tagline">{{ t('login.brand.tagline') }}</p>
				<ul class="brand-features">
					<li v-for="item in brandFeatures" :key="item.key" class="brand-feature">
						<span class="feature-chip">
							<i :class="item.icon"></i>
						</span>
						<span>{{ t(item.key) }}</span>
					</li>
				</ul>
			</div>
		</aside>

		<main class="form-panel">
			<div class="form-box">
				<h1 class="form-title">{{ t('login.welcome') }}</h1>
				<p class="form-subtitle">{{ t('login.subtitle') }}</p>

				<n-form ref="formRef" size="large" :model="form" :rules="rules">
					<n-form-item :show-label="false" path="username">
						<n-input
							v-model:value="form.username"
							:placeholder="t('login.form.usernamePlaceholder')">
							<template #prefix>
								<i class="i-lucide-user input-icon"></i>
							</template>
						</n-input>
					</n-form-item>
					<n-form-item :show-label="false" path="password">
						<n-input
							v-model:value="form.password"
							class="password-input"
							type="password"
							show-password-on="click"
							:placeholder="t('login.form.passwordPlaceholder')"
							@keyup.enter="handleLogin">
							<template #prefix>
								<i class="i-lucide-lock input-icon"></i>
							</template>
						</n-input>
					</n-form-item>
					<n-form-item v-if="isCode" :show-label="false" path="validate_code">
						<n-input
							v-model:value="form.validate_code"
							class="flex-1"
							:placeholder="t('login.form.captcha')"
							:input-props="{ spellcheck: false }"
							@keydown.enter="handleLogin">
							<template #prefix>
								<i class="i-lucide-shield-check input-icon"></i>
							</template>
						</n-input>
						<n-spin size="small" :show="codeLoading">
							<div class="code" @click="getCode()">
								<img
									class="w-full h-full"
									:src="codeUrl"
									:title="t('login.form.changeCaptcha')"
									:alt="t('login.form.captcha')" />
							</div>
						</n-spin>
					</n-form-item>
					<n-form-item :show-label="false" :show-feedback="false">
						<n-button
							type="primary"
							size="large"
							class="font-bold"
							:loading="loading"
							:disabled="loading"
							:block="true"
							@click="handleLogin">
							{{ t('login.form.loginButton') }}
						</n-button>
					</n-form-item>
				</n-form>
			</div>
		</main>
	</div>
</template>

<script lang="ts" setup>
import { useUserStore } from '@/store'
import { isObject } from '@/utils'
import { getValidateCode, login } from '@/api/modules/user'

const { t } = useI18n()

const brandFeatures = [
	{ icon: 'i-lucide-send', key: 'login.brand.feature1' },
	{ icon: 'i-lucide-chart-column', key: 'login.brand.feature2' },
	{ icon: 'i-lucide-users', key: 'login.brand.feature3' },
]

const router = useRouter()
const userStore = useUserStore()

const formRef = useTemplateRef('formRef')

const isCode = ref(false)

const codeUrl = ref('')

const codeLoading = ref(false)

const form = reactive({
	username: '',
	password: '',
	validate_code: '',
	validate_code_id: '',
})

const rules = {
	username: {
		required: true,
		message: t('login.validation.usernameRequired'),
		trigger: ['blur', 'input'],
	},
	password: {
		required: true,
		message: t('login.validation.passwordRequired'),
		trigger: ['blur', 'input'],
	},
	validate_code: {
		required: true,
		trigger: ['blur', 'input'],
		message: t('login.validation.captchaRequired'),
	},
}

interface CodeResponse {
	mustValidateCode: boolean
	validateCodeBase64: string
	validateCodeId: string
}

const getCode = async () => {
	try {
		codeLoading.value = true
		const res = await getValidateCode()
		if (isObject<CodeResponse>(res)) {
			isCode.value = res.mustValidateCode
			if (res.mustValidateCode) {
				codeUrl.value = res.validateCodeBase64
				form.validate_code_id = res.validateCodeId
			}
		}
	} finally {
		codeLoading.value = false
	}
}

const loading = ref(false)

interface LoginResponse {
	token: string
	refresh_token: string
	ttl: number
}

const handleLogin = async () => {
	try {
		await formRef.value?.validate()
		loading.value = true
		const res = await login(toRaw(form))
		if (isObject<LoginResponse>(res)) {
			userStore.setLoginInfo({
				token: res.token,
				refresh_token: res.refresh_token,
				ttl: res.ttl,
			})
			setTimeout(() => {
				router.push('/')
			}, 1000)
		}
	} catch {
		getCode()
	} finally {
		loading.value = false
	}
}

getCode()
</script>

<style lang="scss" scoped>
.login-container {
	display: flex;
	min-height: 100%;
	background: var(--color-bg-1);
}

.brand-panel {
	display: flex;
	position: relative;
	flex: 0 0 44%;
	align-items: center;
	padding: 48px 56px;
	overflow: hidden;
	color: #fff;
	// White/alpha overlay deepens the brand gradient so white text stays readable in both themes
	background:
		linear-gradient(180deg, rgba(0, 0, 0, 0.16) 0%, rgba(0, 0, 0, 0.36) 100%),
		linear-gradient(135deg, var(--color-primary-1) 0%, var(--color-primary-hover-1) 100%);

	&::before {
		content: '';
		position: absolute;
		top: -120px;
		right: -120px;
		width: 360px;
		height: 360px;
		border-radius: 50%;
		background: rgba(255, 255, 255, 0.06);
	}

	&::after {
		content: '';
		position: absolute;
		bottom: -160px;
		left: -96px;
		width: 420px;
		height: 420px;
		border-radius: 50%;
		border: 1px solid rgba(255, 255, 255, 0.12);
	}
}

.brand-content {
	position: relative;
	z-index: 1;
	width: 100%;
	max-width: 400px;
	margin: 0 auto;
}

.brand-logo {
	display: block;
	width: 56px;
	height: 56px;
}

.brand-name {
	margin-top: 24px;
	font-size: 28px;
	font-weight: 600;
	line-height: 36px;
}

.brand-tagline {
	margin-top: 8px;
	font-size: 16px;
	line-height: 24px;
	color: rgba(255, 255, 255, 0.92);
}

.brand-features {
	display: flex;
	flex-direction: column;
	gap: 16px;
	margin-top: 40px;
	list-style: none;
}

.brand-feature {
	display: flex;
	align-items: center;
	gap: 12px;
	font-size: 14px;
	line-height: 20px;
	color: rgba(255, 255, 255, 0.92);
}

.feature-chip {
	display: flex;
	flex-shrink: 0;
	align-items: center;
	justify-content: center;
	width: 36px;
	height: 36px;
	border-radius: 8px;
	font-size: 18px;
	background: rgba(255, 255, 255, 0.14);
}

.form-panel {
	display: flex;
	flex: 1;
	align-items: center;
	justify-content: center;
	padding: 48px;
}

.form-box {
	width: 100%;
	max-width: 360px;
}

.form-title {
	margin: 0;
	font-size: 24px;
	font-weight: 600;
	line-height: 32px;
	color: var(--color-text-1);
}

.form-subtitle {
	margin-top: 8px;
	margin-bottom: 32px;
	font-size: 14px;
	line-height: 20px;
	color: var(--color-text-2);
}

.input-icon {
	font-size: 16px;
	color: var(--color-text-3);
}

.code {
	width: 120px;
	height: 40px;
	margin-left: 12px;
	border-radius: 4px;
	border: 1px solid var(--color-border-1);
	overflow: hidden;
	cursor: pointer;
}
</style>

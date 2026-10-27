<template>
	<div class="filter-bar">
		<div class="w-260px">
			<n-select v-model:value="domain" :options="domainOptions"></n-select>
		</div>
		<bt-time-range v-model:value="dateRange"></bt-time-range>
	</div>
</template>

<script setup lang="ts">
import { isArray } from '@/utils'
import { getDomainAll } from '@/api/modules/domain'
import { MailDomain } from '@/views/domain/interface'

const { t } = useI18n()

const domain = defineModel<string>('domain')

const dateRange = defineModel<[number, number]>('dateRange')

const domainOptions = ref([{ label: t('common.all.domain'), value: '' }])

const getDomainOptions = async () => {
	const res = await getDomainAll()
	if (isArray<MailDomain>(res)) {
		domainOptions.value = res.map(item => ({
			label: item.domain,
			value: item.domain,
		}))
		domainOptions.value.unshift({ label: t('common.all.domain'), value: '' })
	}
}

onMounted(() => {
	getDomainOptions()
})
</script>

<style lang="scss" scoped>
.filter-bar {
	display: flex;
	justify-content: space-between;
	gap: 16px;
	margin-bottom: 16px;
}
</style>

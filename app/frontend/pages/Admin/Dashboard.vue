<template>
  <div class="max-w-6xl mx-auto px-4 py-8">
    <h1 class="text-2xl font-bold text-white mb-6">{{ t('admin.title') }}</h1>

    <div class="flex items-center space-x-1 border-b border-gray-800 mb-6">
      <button
        v-for="tab in tabs"
        :key="tab.key"
        @click="activeTab = tab.key"
        class="px-4 py-2.5 text-sm font-medium border-b-2 transition-colors -mb-px"
        :class="activeTab === tab.key
          ? 'border-indigo-500 text-white'
          : 'border-transparent text-gray-400 hover:text-white'"
      >
        {{ tab.label }}
      </button>
    </div>

    <StatsTab v-if="activeTab === 'stats'" />
    <UsersTab v-else-if="activeTab === 'users'" />
    <SupportTab v-else-if="activeTab === 'support'" />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useI18n } from 'vue-i18n'
import StatsTab from './StatsTab.vue'
import UsersTab from './UsersTab.vue'
import SupportTab from './SupportTab.vue'

const { t } = useI18n()
const activeTab = ref('stats')

const tabs = computed(() => [
  { key: 'stats', label: t('admin.tabStats') },
  { key: 'users', label: t('admin.tabUsers') },
  { key: 'support', label: t('admin.tabSupport') }
])
</script>

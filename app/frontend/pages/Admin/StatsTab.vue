<template>
  <div>
    <div v-if="loading" class="text-gray-400 text-sm">{{ t('common.loading') }}</div>

    <template v-else-if="stats">
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <div class="bg-gray-900 rounded-xl border border-gray-800 p-5">
          <p class="text-xs text-gray-500 mb-1">{{ t('admin.stats.freeUsers') }}</p>
          <p class="text-2xl font-bold text-white">{{ stats.free_users_count }}</p>
        </div>
        <div class="bg-gray-900 rounded-xl border border-gray-800 p-5">
          <p class="text-xs text-gray-500 mb-1">{{ t('admin.stats.paidUsers') }}</p>
          <p class="text-2xl font-bold text-white">{{ stats.paid_users_count }}</p>
        </div>
        <div class="bg-gray-900 rounded-xl border border-gray-800 p-5">
          <p class="text-xs text-gray-500 mb-1">{{ t('admin.stats.totalLogins') }}</p>
          <p class="text-2xl font-bold text-white">{{ stats.total_logins }}</p>
        </div>
        <div class="bg-gray-900 rounded-xl border border-gray-800 p-5">
          <p class="text-xs text-gray-500 mb-1">{{ t('admin.stats.recentLogins') }}</p>
          <p class="text-2xl font-bold text-white">{{ stats.recent_logins_7d }}</p>
        </div>
        <div class="bg-gray-900 rounded-xl border border-gray-800 p-5">
          <p class="text-xs text-gray-500 mb-1">{{ t('admin.stats.totalImages') }}</p>
          <p class="text-2xl font-bold text-white">{{ stats.total_images_generated }}</p>
        </div>
        <div class="bg-gray-900 rounded-xl border border-gray-800 p-5">
          <p class="text-xs text-gray-500 mb-1">{{ t('admin.stats.avgPerBatch') }}</p>
          <p class="text-2xl font-bold text-white">{{ stats.avg_images_per_batch }}</p>
        </div>
        <div class="bg-gray-900 rounded-xl border border-gray-800 p-5">
          <p class="text-xs text-gray-500 mb-1">{{ t('admin.stats.avgPerUser') }}</p>
          <p class="text-2xl font-bold text-white">{{ stats.avg_images_per_user }}</p>
        </div>
        <div class="bg-gray-900 rounded-xl border border-gray-800 p-5">
          <p class="text-xs text-gray-500 mb-1">{{ t('admin.stats.avgSavedPerFolder') }}</p>
          <p class="text-2xl font-bold text-white">{{ stats.avg_saved_images_per_folder }}</p>
        </div>
      </div>

      <div class="bg-gray-900 rounded-xl border border-gray-800 p-5">
        <h2 class="text-sm font-semibold text-white mb-4">{{ t('admin.stats.topActive') }}</h2>
        <div v-if="!stats.top_active_users.length" class="text-sm text-gray-500">{{ t('common.loading') }}</div>
        <div v-else class="space-y-2">
          <div
            v-for="(user, index) in stats.top_active_users"
            :key="user.id"
            class="flex items-center justify-between text-sm py-1.5 border-b border-gray-800 last:border-0"
          >
            <span class="text-gray-300">
              <span class="text-gray-600 mr-2">#{{ index + 1 }}</span>
              {{ user.name || user.email }}
            </span>
            <span class="text-gray-500">{{ user.batch_count }}</span>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useApi } from '../../composables/useApi'

const { t } = useI18n()
const { get } = useApi()

const stats = ref(null)
const loading = ref(true)

onMounted(async () => {
  try {
    stats.value = await get('/admin/stats')
  } finally {
    loading.value = false
  }
})
</script>

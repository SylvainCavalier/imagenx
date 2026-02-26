<template>
  <div class="max-w-5xl mx-auto px-4 py-8">
    <h1 class="text-2xl font-bold text-white mb-6">Generation History</h1>

    <div v-if="generationStore.loading" class="text-gray-400 text-center py-12">Loading...</div>

    <div v-else-if="!generationStore.batches.length" class="text-center py-12">
      <p class="text-gray-500">No generations yet.</p>
      <router-link to="/" class="text-indigo-400 hover:text-indigo-300 text-sm mt-2 inline-block">Create your first batch</router-link>
    </div>

    <div v-else class="space-y-4">
      <div
        v-for="batch in generationStore.batches"
        :key="batch.id"
        class="bg-gray-900 rounded-xl border border-gray-800 p-5 cursor-pointer hover:border-gray-700 transition-colors"
        @click="viewBatch(batch)"
      >
        <div class="flex items-center justify-between mb-3">
          <div>
            <p class="text-white font-medium line-clamp-1">{{ batch.main_prompt }}</p>
            <p class="text-xs text-gray-500 mt-1">{{ formatDate(batch.created_at) }} &middot; {{ batch.items.length }} images &middot; {{ batch.aspect_ratio }}</p>
          </div>
          <span :class="statusClass(batch.status)" class="text-xs font-medium px-2.5 py-1 rounded-full shrink-0">
            {{ batch.status }}
          </span>
        </div>

        <!-- Thumbnails -->
        <div class="flex space-x-2 overflow-x-auto">
          <div
            v-for="item in batch.items.slice(0, 6)"
            :key="item.id"
            class="w-16 h-16 rounded-lg overflow-hidden shrink-0 bg-gray-800"
          >
            <img v-if="item.image_url" :src="item.image_url" class="w-full h-full object-cover" />
          </div>
        </div>
      </div>
    </div>

    <!-- Batch Detail Modal -->
    <div v-if="selectedBatch" class="fixed inset-0 bg-black/70 z-50 flex items-center justify-center p-4" @click.self="selectedBatch = null">
      <div class="bg-gray-900 rounded-2xl border border-gray-800 max-w-4xl w-full max-h-[90vh] overflow-y-auto p-6">
        <div class="flex items-center justify-between mb-4">
          <div>
            <h2 class="text-lg font-semibold text-white">{{ selectedBatch.main_prompt }}</h2>
            <p class="text-xs text-gray-500 mt-1">{{ formatDate(selectedBatch.created_at) }}</p>
          </div>
          <button @click="selectedBatch = null" class="text-gray-500 hover:text-white">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <div v-for="item in selectedBatch.items" :key="item.id" class="rounded-xl overflow-hidden border border-gray-800">
            <div class="aspect-square bg-gray-800">
              <img v-if="item.image_url" :src="item.image_url" :alt="item.prompt" class="w-full h-full object-cover" />
              <div v-else class="w-full h-full flex items-center justify-center text-gray-600 text-sm">
                {{ item.status === 'failed' ? 'Failed' : 'No image' }}
              </div>
            </div>
            <div class="p-3">
              <p class="text-sm text-gray-400 line-clamp-2">{{ item.prompt }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useGenerationStore } from '../stores/generation'

const generationStore = useGenerationStore()
const selectedBatch = ref(null)

onMounted(() => {
  generationStore.fetchBatches()
})

const viewBatch = (batch) => {
  selectedBatch.value = batch
}

const statusClass = (status) => {
  const classes = {
    pending: 'bg-gray-700 text-gray-300',
    processing: 'bg-yellow-900/50 text-yellow-300',
    completed: 'bg-green-900/50 text-green-300',
    failed: 'bg-red-900/50 text-red-300'
  }
  return classes[status] || classes.pending
}

const formatDate = (dateStr) => {
  return new Date(dateStr).toLocaleDateString('en-US', {
    month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit'
  })
}
</script>

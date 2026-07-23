<template>
  <div class="max-w-5xl mx-auto px-4 py-8">
    <h1 class="text-2xl font-bold text-white mb-6">Generate Images</h1>

    <!-- Main Prompt -->
    <div class="bg-gray-900 rounded-xl border border-gray-800 p-6 mb-6">
      <div class="flex items-center justify-between mb-2">
        <label class="block text-sm font-medium text-gray-300">Main prompt (style, mood, format)</label>

        <!-- Presets -->
        <div class="flex items-center space-x-2">
          <select
            v-model="selectedPresetId"
            @change="loadPreset"
            class="px-3 py-1.5 bg-gray-800 border border-gray-700 rounded-lg text-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            <option :value="null">Load preset...</option>
            <option v-for="preset in presetsStore.presets" :key="preset.id" :value="preset.id">
              {{ preset.name }}
            </option>
          </select>
          <button
            @click="showSavePreset = true"
            :disabled="!mainPrompt.trim()"
            class="px-3 py-1.5 bg-gray-800 hover:bg-gray-700 border border-gray-700 text-gray-300 rounded-lg text-sm transition-colors disabled:opacity-40"
            title="Save as preset"
          >
            Save
          </button>
          <button
            v-if="selectedPresetId"
            @click="deletePreset"
            class="px-2 py-1.5 text-gray-500 hover:text-red-400 transition-colors text-sm"
            title="Delete preset"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
      </div>

      <textarea
        v-model="mainPrompt"
        rows="3"
        placeholder="e.g. Cinematic photography, dramatic lighting, 8k, ultra detailed..."
        class="w-full px-4 py-3 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 resize-none"
      />
      <div class="mt-3 flex flex-wrap items-center gap-3">
        <div class="flex items-center space-x-2">
          <label class="text-sm text-gray-400">Aspect ratio</label>
          <select
            v-model="aspectRatio"
            class="px-3 py-1.5 bg-gray-800 border border-gray-700 rounded-lg text-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            <option value="1:1">1:1 (Square)</option>
            <option value="16:9">16:9 (Landscape)</option>
            <option value="9:16">9:16 (Portrait)</option>
            <option value="4:3">4:3</option>
            <option value="3:4">3:4</option>
          </select>
        </div>
        <div class="flex items-center space-x-2">
          <label class="text-sm text-gray-400">Type</label>
          <select v-model="imageType" class="px-3 py-1.5 bg-gray-800 border border-gray-700 rounded-lg text-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500">
            <option value="">None</option>
            <option value="Photography">Photography</option>
            <option value="Illustration">Illustration</option>
            <option value="3D Render">3D Render</option>
            <option value="Digital Art">Digital Art</option>
            <option value="Oil Painting">Oil Painting</option>
            <option value="Watercolor">Watercolor</option>
            <option value="Pencil Sketch">Pencil Sketch</option>
            <option value="Pixel Art">Pixel Art</option>
          </select>
        </div>
        <div class="flex items-center space-x-2">
          <label class="text-sm text-gray-400">Realism</label>
          <select v-model="realism" class="px-3 py-1.5 bg-gray-800 border border-gray-700 rounded-lg text-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500">
            <option value="">None</option>
            <option value="Photorealistic">Photorealistic</option>
            <option value="Hyperrealistic">Hyperrealistic</option>
            <option value="Stylized">Stylized</option>
            <option value="Abstract">Abstract</option>
            <option value="Cartoon">Cartoon</option>
          </select>
        </div>
        <div class="flex items-center space-x-2">
          <label class="text-sm text-gray-400">Lighting</label>
          <select v-model="lighting" class="px-3 py-1.5 bg-gray-800 border border-gray-700 rounded-lg text-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500">
            <option value="">None</option>
            <option value="Natural light">Natural light</option>
            <option value="Studio lighting">Studio lighting</option>
            <option value="Dramatic lighting">Dramatic lighting</option>
            <option value="Golden hour">Golden hour</option>
            <option value="Neon glow">Neon glow</option>
            <option value="Soft diffused">Soft diffused</option>
            <option value="Backlit">Backlit</option>
            <option value="Low-key">Low-key</option>
          </select>
        </div>
        <div class="flex items-center space-x-2">
          <label class="text-sm text-gray-400">Mood</label>
          <select v-model="mood" class="px-3 py-1.5 bg-gray-800 border border-gray-700 rounded-lg text-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500">
            <option value="">None</option>
            <option value="Cinematic">Cinematic</option>
            <option value="Dreamy">Dreamy</option>
            <option value="Dark & moody">Dark & moody</option>
            <option value="Vibrant">Vibrant</option>
            <option value="Minimalist">Minimalist</option>
            <option value="Vintage">Vintage</option>
            <option value="Futuristic">Futuristic</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Save Preset Modal -->
    <div v-if="showSavePreset" class="fixed inset-0 bg-black/70 z-50 flex items-center justify-center p-4" @click.self="showSavePreset = false">
      <div class="bg-gray-900 rounded-xl border border-gray-800 p-6 w-full max-w-sm">
        <h3 class="text-lg font-semibold text-white mb-4">Save Preset</h3>
        <input
          v-model="presetName"
          type="text"
          placeholder="Preset name..."
          class="w-full px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 mb-4"
          @keyup.enter="savePreset"
        />
        <div class="flex justify-end space-x-3">
          <button @click="showSavePreset = false" class="px-4 py-2 text-gray-400 hover:text-white text-sm">Cancel</button>
          <button
            @click="savePreset"
            :disabled="!presetName.trim()"
            class="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-50 text-white rounded-lg text-sm"
          >
            Save
          </button>
        </div>
      </div>
    </div>

    <!-- Sub-prompts -->
    <div class="space-y-3 mb-6">
      <div
        v-for="(item, index) in subPrompts"
        :key="index"
        class="bg-gray-900 rounded-xl border border-gray-800 p-4 flex items-start space-x-3"
      >
        <span class="text-sm text-gray-500 font-mono mt-2.5 w-6 shrink-0">{{ index + 1 }}</span>
        <textarea
          v-model="item.prompt"
          rows="2"
          :placeholder="`Image ${index + 1} - Describe this specific image...`"
          class="flex-1 px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 resize-none"
        />
        <button
          @click="removeSubPrompt(index)"
          class="mt-2 text-gray-500 hover:text-red-400 transition-colors shrink-0"
          title="Remove"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
          </svg>
        </button>
      </div>
    </div>

    <!-- Actions -->
    <div class="flex items-center space-x-3 mb-8">
      <button
        @click="addSubPrompt"
        class="px-4 py-2 bg-gray-800 hover:bg-gray-700 border border-gray-700 text-gray-300 rounded-lg text-sm transition-colors"
      >
        + Add image
      </button>
      <button
        @click="generateAll"
        :disabled="!canGenerate || generationStore.loading"
        class="px-6 py-2 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed text-white font-medium rounded-lg text-sm transition-colors"
      >
        {{ generationStore.loading ? 'Generating...' : `Generate ${validCount} image${validCount > 1 ? 's' : ''}` }}
      </button>
    </div>

    <!-- Error -->
    <div v-if="generationStore.error" class="mb-6 p-4 bg-red-900/50 border border-red-700 rounded-lg text-red-300 text-sm">
      {{ generationStore.error }}
      <button @click="generationStore.clearError()" class="ml-2 underline">Dismiss</button>
    </div>

    <!-- Results -->
    <div v-if="generationStore.currentBatch" class="mb-8">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-semibold text-white">Results</h2>
        <div class="flex items-center space-x-3">
          <span :class="statusClass" class="text-xs font-medium px-2.5 py-1 rounded-full">
            {{ generationStore.currentBatch.status }}
          </span>
          <button
            v-if="completedItems.length > 0"
            @click="downloadSelected"
            :disabled="selectedItems.length === 0 || downloading"
            class="px-4 py-1.5 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-50 text-white rounded-lg text-sm transition-colors"
          >
            {{ downloading ? 'Downloading...' : `Download ${selectedItems.length > 0 ? selectedItems.length : ''} selected` }}
          </button>
          <button
            v-if="completedItems.length > 0"
            @click="saveSelected"
            :disabled="selectedItems.length === 0 || libraryStore.saving"
            class="px-4 py-1.5 bg-emerald-600 hover:bg-emerald-500 disabled:opacity-50 text-white rounded-lg text-sm transition-colors"
          >
            {{ libraryStore.saving ? 'Saving...' : `Save ${selectedItems.length > 0 ? selectedItems.length : ''} selected` }}
          </button>
        </div>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="item in generationStore.currentBatch.items"
          :key="item.id"
          class="bg-gray-900 rounded-xl border overflow-hidden transition-colors"
          :class="isSelected(item.id) ? 'border-emerald-500' : 'border-gray-800'"
        >
          <!-- Loading -->
          <div v-if="item.status === 'pending' || item.status === 'processing'" class="aspect-square flex items-center justify-center bg-gray-800">
            <div class="text-center">
              <svg class="animate-spin h-8 w-8 text-indigo-400 mx-auto mb-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <span class="text-sm text-gray-400">{{ item.status === 'processing' ? 'Generating...' : 'Queued' }}</span>
            </div>
          </div>

          <!-- Completed -->
          <div
            v-else-if="item.status === 'completed'"
            class="aspect-square relative cursor-pointer group"
            @click="toggleSelect(item.id)"
          >
            <img :src="item.image_url" :alt="item.prompt" class="w-full h-full object-cover" />
            <!-- Selection overlay -->
            <div
              class="absolute inset-0 transition-colors"
              :class="isSelected(item.id) ? 'bg-emerald-500/20' : 'bg-transparent group-hover:bg-white/5'"
            />
            <!-- Checkbox -->
            <div class="absolute top-2 right-2">
              <div
                class="w-6 h-6 rounded-full border-2 flex items-center justify-center transition-colors"
                :class="isSelected(item.id) ? 'bg-emerald-500 border-emerald-500' : 'border-white/50 bg-black/30 group-hover:border-white'"
              >
                <svg v-if="isSelected(item.id)" xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5 text-white" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                </svg>
              </div>
            </div>
          </div>

          <!-- Failed -->
          <div v-else-if="item.status === 'failed'" class="aspect-square flex items-center justify-center bg-gray-800">
            <div class="text-center p-4">
              <span class="text-red-400 text-sm">Failed</span>
              <p class="text-xs text-gray-500 mt-1">{{ item.error_message }}</p>
            </div>
          </div>

          <div class="p-3">
            <p class="text-sm text-gray-400 line-clamp-2">{{ item.prompt }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Save to folder modal -->
    <div v-if="showSaveModal" class="fixed inset-0 bg-black/70 z-50 flex items-center justify-center p-4" @click.self="showSaveModal = false">
      <div class="bg-gray-900 rounded-xl border border-gray-800 p-6 w-full max-w-sm">
        <h3 class="text-lg font-semibold text-white mb-4">Save to folder</h3>

        <!-- Existing folders -->
        <div v-if="libraryStore.folders.length" class="space-y-2 mb-4 max-h-48 overflow-y-auto">
          <button
            v-for="folder in libraryStore.folders"
            :key="folder.id"
            @click="saveToFolder(folder.id)"
            class="w-full text-left px-4 py-2.5 bg-gray-800 hover:bg-gray-700 border border-gray-700 rounded-lg text-white text-sm transition-colors"
          >
            {{ folder.name }} <span class="text-gray-500">({{ folder.images_count }})</span>
          </button>
        </div>

        <!-- New folder -->
        <div class="flex space-x-2">
          <input
            v-model="newFolderName"
            type="text"
            :placeholder="defaultFolderName"
            class="flex-1 px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm"
            @keyup.enter="createFolderAndSave"
          />
          <button
            @click="createFolderAndSave"
            class="px-4 py-2.5 bg-emerald-600 hover:bg-emerald-500 text-white rounded-lg text-sm shrink-0"
          >
            New folder
          </button>
        </div>

        <button @click="showSaveModal = false" class="mt-3 w-full text-center text-sm text-gray-500 hover:text-gray-300">Cancel</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useGenerationStore } from '../stores/generation'
import { useLibraryStore } from '../stores/library'
import { usePresetsStore } from '../stores/presets'

const generationStore = useGenerationStore()
const libraryStore = useLibraryStore()
const presetsStore = usePresetsStore()

const mainPrompt = ref('')
const aspectRatio = ref('1:1')
const imageType = ref('')
const realism = ref('')
const lighting = ref('')
const mood = ref('')
const subPrompts = ref([{ prompt: '' }])
const selectedIds = ref(new Set())

// Presets
const selectedPresetId = ref(null)
const showSavePreset = ref(false)
const presetName = ref('')

// Save modal
const showSaveModal = ref(false)
const newFolderName = ref('')
const downloading = ref(false)

const styleOptions = computed(() => {
  const opts = {}
  if (imageType.value) opts.image_type = imageType.value
  if (realism.value) opts.realism = realism.value
  if (lighting.value) opts.lighting = lighting.value
  if (mood.value) opts.mood = mood.value
  return opts
})

const validCount = computed(() => subPrompts.value.filter(s => s.prompt.trim()).length)

const canGenerate = computed(() => {
  return mainPrompt.value.trim() && validCount.value > 0
})

const completedItems = computed(() => {
  return (generationStore.currentBatch?.items || []).filter(i => i.status === 'completed')
})

const selectedItems = computed(() => {
  return completedItems.value.filter(i => selectedIds.value.has(i.id))
})

const defaultFolderName = computed(() => {
  const prompt = mainPrompt.value || generationStore.currentBatch?.main_prompt || ''
  return prompt.substring(0, 50) || 'New folder'
})

const statusClass = computed(() => {
  const status = generationStore.currentBatch?.status
  const classes = {
    pending: 'bg-gray-700 text-gray-300',
    processing: 'bg-yellow-900/50 text-yellow-300',
    completed: 'bg-green-900/50 text-green-300',
    failed: 'bg-red-900/50 text-red-300'
  }
  return classes[status] || classes.pending
})

onMounted(() => {
  presetsStore.fetchPresets()
  libraryStore.fetchFolders()
})

const addSubPrompt = () => {
  subPrompts.value.push({ prompt: '' })
}

const removeSubPrompt = (index) => {
  if (subPrompts.value.length > 1) {
    subPrompts.value.splice(index, 1)
  }
}

const generateAll = async () => {
  const validItems = subPrompts.value.filter(s => s.prompt.trim())
  if (!validItems.length) return

  selectedIds.value = new Set()

  const batch = await generationStore.createBatch({
    mainPrompt: mainPrompt.value,
    aspectRatio: aspectRatio.value,
    styleOptions: styleOptions.value,
    items: validItems
  })

  if (batch) {
    generationStore.pollBatch(batch.id)
  }
}

// Selection
const isSelected = (id) => selectedIds.value.has(id)

const toggleSelect = (id) => {
  const next = new Set(selectedIds.value)
  if (next.has(id)) {
    next.delete(id)
  } else {
    next.add(id)
  }
  selectedIds.value = next
}

// Download
const downloadSelected = () => {
  if (selectedItems.value.length === 0) return
  const batchId = generationStore.currentBatch?.id
  if (!batchId) return
  for (const item of selectedItems.value) {
    const url = `/api/generation_batches/${batchId}/generation_items/${item.id}/download`
    window.open(url, '_blank')
  }
}

// Save
const saveSelected = () => {
  if (selectedItems.value.length === 0) return
  showSaveModal.value = true
}

const saveToFolder = async (folderId) => {
  const items = selectedItems.value.map(i => ({ prompt: i.prompt, image_url: i.image_url }))
  const result = await libraryStore.saveImages(folderId, items)
  if (result) {
    selectedIds.value = new Set()
    showSaveModal.value = false
  }
}

const createFolderAndSave = async () => {
  const name = newFolderName.value.trim() || defaultFolderName.value
  const folder = await libraryStore.createFolder(name)
  if (folder) {
    newFolderName.value = ''
    await saveToFolder(folder.id)
  }
}

// Presets
const loadPreset = () => {
  if (!selectedPresetId.value) return
  const preset = presetsStore.presets.find(p => p.id === selectedPresetId.value)
  if (preset) {
    mainPrompt.value = preset.prompt_text
    if (preset.aspect_ratio) aspectRatio.value = preset.aspect_ratio
    const opts = preset.style_options || {}
    imageType.value = opts.image_type || ''
    realism.value = opts.realism || ''
    lighting.value = opts.lighting || ''
    mood.value = opts.mood || ''
  }
}

const savePreset = async () => {
  if (!presetName.value.trim()) return
  await presetsStore.createPreset({
    name: presetName.value,
    promptText: mainPrompt.value,
    aspectRatio: aspectRatio.value,
    styleOptions: styleOptions.value
  })
  presetName.value = ''
  showSavePreset.value = false
}

const deletePreset = async () => {
  if (!selectedPresetId.value) return
  await presetsStore.deletePreset(selectedPresetId.value)
  selectedPresetId.value = null
}

onUnmounted(() => {
  generationStore.stopPolling()
})
</script>

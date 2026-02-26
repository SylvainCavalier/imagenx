<template>
  <div class="max-w-6xl mx-auto px-4 py-8">
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <div class="flex items-center space-x-3">
        <button
          v-if="libraryStore.currentFolder"
          @click="backToFolders"
          class="text-gray-400 hover:text-white transition-colors"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clip-rule="evenodd" />
          </svg>
        </button>
        <h1 class="text-2xl font-bold text-white">
          {{ libraryStore.currentFolder ? libraryStore.currentFolder.name : 'My Images' }}
        </h1>
      </div>

      <!-- Rename / Delete folder -->
      <div v-if="libraryStore.currentFolder" class="flex items-center space-x-2">
        <button @click="startRename" class="px-3 py-1.5 bg-gray-800 hover:bg-gray-700 border border-gray-700 text-gray-300 rounded-lg text-sm transition-colors">
          Rename
        </button>
        <button @click="confirmDeleteFolder" class="px-3 py-1.5 text-gray-500 hover:text-red-400 transition-colors text-sm">
          Delete folder
        </button>
      </div>
    </div>

    <div v-if="libraryStore.loading" class="text-gray-400 text-center py-12">Loading...</div>

    <!-- Folders view -->
    <div v-else-if="!libraryStore.currentFolder">
      <div v-if="!libraryStore.folders.length" class="text-center py-12">
        <p class="text-gray-500">No saved images yet.</p>
        <router-link to="/" class="text-indigo-400 hover:text-indigo-300 text-sm mt-2 inline-block">Generate some images first</router-link>
      </div>

      <div v-else class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
        <div
          v-for="folder in libraryStore.folders"
          :key="folder.id"
          @click="openFolder(folder.id)"
          class="bg-gray-900 rounded-xl border border-gray-800 overflow-hidden cursor-pointer hover:border-gray-700 transition-colors group"
        >
          <!-- Cover -->
          <div class="aspect-square bg-gray-800 relative">
            <img
              v-if="folder.cover_url"
              :src="folder.cover_url"
              class="w-full h-full object-cover"
            />
            <div v-else class="w-full h-full flex items-center justify-center">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 text-gray-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z" />
              </svg>
            </div>
          </div>
          <div class="p-3">
            <p class="text-white text-sm font-medium line-clamp-1">{{ folder.name }}</p>
            <p class="text-xs text-gray-500 mt-0.5">{{ folder.images_count }} image{{ folder.images_count !== 1 ? 's' : '' }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Folder detail view -->
    <div v-else>
      <div v-if="!libraryStore.currentFolder.images?.length" class="text-center py-12">
        <p class="text-gray-500">This folder is empty.</p>
      </div>

      <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="image in libraryStore.currentFolder.images"
          :key="image.id"
          class="bg-gray-900 rounded-xl border border-gray-800 overflow-hidden group"
        >
          <div class="aspect-square relative">
            <img :src="image.url" :alt="image.prompt" class="w-full h-full object-cover" />
            <!-- Actions overlay -->
            <div class="absolute inset-0 bg-black/0 group-hover:bg-black/30 transition-colors flex items-start justify-end p-2 opacity-0 group-hover:opacity-100">
              <button
                @click.stop="deleteImage(image.id)"
                class="p-1.5 bg-black/50 hover:bg-red-600 rounded-lg text-white transition-colors"
                title="Delete image"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
                </svg>
              </button>
            </div>
          </div>
          <div class="p-3">
            <p class="text-sm text-gray-400 line-clamp-2">{{ image.prompt }}</p>
            <p class="text-xs text-gray-600 mt-1">{{ formatDate(image.created_at) }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Rename modal -->
    <div v-if="showRenameModal" class="fixed inset-0 bg-black/70 z-50 flex items-center justify-center p-4" @click.self="showRenameModal = false">
      <div class="bg-gray-900 rounded-xl border border-gray-800 p-6 w-full max-w-sm">
        <h3 class="text-lg font-semibold text-white mb-4">Rename folder</h3>
        <input
          v-model="renameName"
          type="text"
          class="w-full px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-indigo-500 mb-4"
          @keyup.enter="renameFolder"
        />
        <div class="flex justify-end space-x-3">
          <button @click="showRenameModal = false" class="px-4 py-2 text-gray-400 hover:text-white text-sm">Cancel</button>
          <button @click="renameFolder" class="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg text-sm">Rename</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useLibraryStore } from '../stores/library'

const libraryStore = useLibraryStore()

const showRenameModal = ref(false)
const renameName = ref('')

onMounted(() => {
  libraryStore.currentFolder = null
  libraryStore.fetchFolders()
})

const openFolder = async (id) => {
  await libraryStore.fetchFolder(id)
}

const backToFolders = () => {
  libraryStore.currentFolder = null
  libraryStore.fetchFolders()
}

const startRename = () => {
  renameName.value = libraryStore.currentFolder?.name || ''
  showRenameModal.value = true
}

const renameFolder = async () => {
  if (!renameName.value.trim() || !libraryStore.currentFolder) return
  await libraryStore.renameFolder(libraryStore.currentFolder.id, renameName.value)
  showRenameModal.value = false
}

const confirmDeleteFolder = async () => {
  if (!libraryStore.currentFolder) return
  if (confirm('Delete this folder and all its images?')) {
    await libraryStore.deleteFolder(libraryStore.currentFolder.id)
  }
}

const deleteImage = async (imageId) => {
  if (!libraryStore.currentFolder) return
  await libraryStore.deleteImage(libraryStore.currentFolder.id, imageId)
}

const formatDate = (dateStr) => {
  return new Date(dateStr).toLocaleDateString('en-US', {
    month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit'
  })
}
</script>

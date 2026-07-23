import { defineStore } from 'pinia'
import apiClient from '../plugins/axios'

export const useLibraryStore = defineStore('library', {
  state: () => ({
    folders: [],
    currentFolder: null,
    loading: false,
    saving: false,
    error: null,
  }),

  actions: {
    async fetchFolders() {
      this.loading = true
      try {
        const response = await apiClient.get('/image_folders')
        this.folders = response.data
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to load folders'
      } finally {
        this.loading = false
      }
    },

    async fetchFolder(id) {
      this.loading = true
      try {
        const response = await apiClient.get(`/image_folders/${id}`)
        this.currentFolder = response.data
        return response.data
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to load folder'
        return null
      } finally {
        this.loading = false
      }
    },

    async createFolder(name) {
      try {
        const response = await apiClient.post('/image_folders', { name })
        this.folders.unshift(response.data)
        return response.data
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to create folder'
        return null
      }
    },

    async renameFolder(id, name) {
      try {
        const response = await apiClient.patch(`/image_folders/${id}`, { name })
        const idx = this.folders.findIndex(f => f.id === id)
        if (idx !== -1) this.folders[idx] = response.data
        if (this.currentFolder?.id === id) this.currentFolder.name = name
        return response.data
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to rename folder'
        return null
      }
    },

    async deleteFolder(id) {
      try {
        await apiClient.delete(`/image_folders/${id}`)
        this.folders = this.folders.filter(f => f.id !== id)
        if (this.currentFolder?.id === id) this.currentFolder = null
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to delete folder'
      }
    },

    async saveImages(folderId, items) {
      this.saving = true
      try {
        const response = await apiClient.post(`/image_folders/${folderId}/saved_images`, { items })
        await this.fetchFolders()
        return response.data
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to save images'
        return null
      } finally {
        this.saving = false
      }
    },

    async renameImage(folderId, imageId, prompt) {
      try {
        const response = await apiClient.patch(`/image_folders/${folderId}/saved_images/${imageId}`, { prompt })
        if (this.currentFolder?.id === folderId) {
          const img = this.currentFolder.images.find(i => i.id === imageId)
          if (img) img.prompt = response.data.prompt
        }
        return response.data
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to rename image'
        return null
      }
    },

    async deleteImage(folderId, imageId) {
      try {
        await apiClient.delete(`/image_folders/${folderId}/saved_images/${imageId}`)
        if (this.currentFolder?.id === folderId) {
          this.currentFolder.images = this.currentFolder.images.filter(i => i.id !== imageId)
        }
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to delete image'
      }
    },

    clearError() {
      this.error = null
    }
  }
})

import { defineStore } from 'pinia'
import apiClient from '../plugins/axios'

export const usePresetsStore = defineStore('presets', {
  state: () => ({
    presets: [],
    loading: false,
    error: null,
  }),

  actions: {
    async fetchPresets() {
      this.loading = true
      try {
        const response = await apiClient.get('/prompt_presets')
        this.presets = response.data
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to load presets'
      } finally {
        this.loading = false
      }
    },

    async createPreset({ name, promptText, aspectRatio }) {
      try {
        const response = await apiClient.post('/prompt_presets', {
          name,
          prompt_text: promptText,
          aspect_ratio: aspectRatio
        })
        this.presets.push(response.data)
        this.presets.sort((a, b) => a.name.localeCompare(b.name))
        return response.data
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to create preset'
        return null
      }
    },

    async updatePreset(id, { name, promptText, aspectRatio }) {
      try {
        const response = await apiClient.patch(`/prompt_presets/${id}`, {
          name,
          prompt_text: promptText,
          aspect_ratio: aspectRatio
        })
        const idx = this.presets.findIndex(p => p.id === id)
        if (idx !== -1) this.presets[idx] = response.data
        return response.data
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to update preset'
        return null
      }
    },

    async deletePreset(id) {
      try {
        await apiClient.delete(`/prompt_presets/${id}`)
        this.presets = this.presets.filter(p => p.id !== id)
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to delete preset'
      }
    },

    clearError() {
      this.error = null
    }
  }
})

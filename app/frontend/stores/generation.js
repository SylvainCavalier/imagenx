import { defineStore } from 'pinia'
import apiClient from '../plugins/axios'

export const useGenerationStore = defineStore('generation', {
  state: () => ({
    batches: [],
    currentBatch: null,
    loading: false,
    polling: false,
    error: null,
    _pollTimer: null,
  }),

  actions: {
    async fetchBatches() {
      this.loading = true
      try {
        const response = await apiClient.get('/generation_batches')
        this.batches = response.data
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to load batches'
      } finally {
        this.loading = false
      }
    },

    async fetchBatch(id) {
      try {
        const response = await apiClient.get(`/generation_batches/${id}`)
        this.currentBatch = response.data
        return response.data
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to load batch'
        return null
      }
    },

    async createBatch({ mainPrompt, aspectRatio, styleOptions, items }) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.post('/generation_batches', {
          main_prompt: mainPrompt,
          aspect_ratio: aspectRatio,
          style_options: styleOptions || {},
          items: items.map(i => ({ prompt: i.prompt }))
        })
        this.currentBatch = response.data
        return response.data
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to create batch'
        return null
      } finally {
        this.loading = false
      }
    },

    async pollBatch(id) {
      this.stopPolling()
      this.polling = true
      const poll = async () => {
        if (!this.polling) return
        const batch = await this.fetchBatch(id)
        if (!batch || batch.status === 'completed' || batch.status === 'failed') {
          this.polling = false
          return
        }
        this._pollTimer = setTimeout(poll, 2000)
      }
      await poll()
    },

    stopPolling() {
      this.polling = false
      if (this._pollTimer) {
        clearTimeout(this._pollTimer)
        this._pollTimer = null
      }
    },

    clearError() {
      this.error = null
    }
  }
})

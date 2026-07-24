import { defineStore } from 'pinia'
import apiClient from '../plugins/axios'
import { useAuthStore } from './auth'

export const useBillingStore = defineStore('billing', {
  state: () => ({
    transactions: [],
    loading: false,
    loadingHistory: false,
    error: null,
  }),

  actions: {
    async updateAccount(payload) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.patch('/account', payload)
        useAuthStore().setUser(response.data.user)
        return { success: true }
      } catch (error) {
        const message = error.response?.data?.error || 'Update failed'
        this.error = message
        return { success: false, error: message }
      } finally {
        this.loading = false
      }
    },

    async createCheckout(pack) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.post('/checkout_sessions', { pack })
        return { success: true, url: response.data.url }
      } catch (error) {
        const message = error.response?.data?.error || 'Checkout failed'
        this.error = message
        return { success: false, error: message }
      } finally {
        this.loading = false
      }
    },

    async createPortalSession() {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.post('/portal_sessions')
        return { success: true, url: response.data.url }
      } catch (error) {
        const message = error.response?.data?.error || 'Portal failed'
        this.error = message
        return { success: false, error: message }
      } finally {
        this.loading = false
      }
    },

    async fetchCreditHistory() {
      this.loadingHistory = true
      try {
        const response = await apiClient.get('/credit_transactions')
        this.transactions = response.data
      } catch {
        // ignore
      } finally {
        this.loadingHistory = false
      }
    },

    clearError() {
      this.error = null
    }
  }
})

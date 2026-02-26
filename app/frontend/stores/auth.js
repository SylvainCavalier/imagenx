import { defineStore } from 'pinia'
import apiClient from '../plugins/axios'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    isAuthenticated: false,
    loading: false,
    error: null,
  }),

  getters: {
    currentUser: (state) => state.user,
    isLoggedIn: (state) => state.isAuthenticated,
    isLoading: (state) => state.loading,
    hasError: (state) => !!state.error,
  },

  actions: {
    setUser(user) {
      this.user = user
      this.isAuthenticated = !!user
    },

    clearUser() {
      this.user = null
      this.isAuthenticated = false
    },

    async checkAuth() {
      this.loading = true
      try {
        const response = await apiClient.get('/auth/verify')
        this.setUser(response.data.user)
        return true
      } catch {
        this.clearUser()
        return false
      } finally {
        this.loading = false
      }
    },

    async login(credentials) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.post('/auth/login', credentials)
        this.setUser(response.data.user)
        return { success: true }
      } catch (error) {
        const message = error.response?.data?.error || 'Login failed'
        this.error = message
        return { success: false, error: message }
      } finally {
        this.loading = false
      }
    },

    async register(userData) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.post('/auth/register', userData)
        this.setUser(response.data.user)
        return { success: true }
      } catch (error) {
        const message = error.response?.data?.error || 'Registration failed'
        this.error = message
        return { success: false, error: message }
      } finally {
        this.loading = false
      }
    },

    async logout() {
      try {
        await apiClient.delete('/auth/logout')
      } catch {
        // ignore
      } finally {
        this.clearUser()
      }
    },

    clearError() {
      this.error = null
    }
  }
})

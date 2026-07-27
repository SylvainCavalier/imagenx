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
        return { success: false, error: message, unconfirmed: !!error.response?.data?.unconfirmed }
      } finally {
        this.loading = false
      }
    },

    async register(userData) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.post('/auth/register', userData)
        // No session is created here: the backend requires email confirmation
        // before granting access, so we don't setUser — the caller shows a
        // "check your email" state instead of redirecting into the app.
        // resent: the account already existed unconfirmed and only got a new email —
        // its original password still applies, which the caller warns about.
        return {
          success: true,
          email: response.data.email,
          message: response.data.message,
          resent: response.data.resent === true
        }
      } catch (error) {
        const message = error.response?.data?.error || 'Registration failed'
        this.error = message
        return { success: false, error: message }
      } finally {
        this.loading = false
      }
    },

    async forgotPassword(email) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.post('/auth/forgot_password', { email })
        return { success: true, message: response.data.message }
      } catch (error) {
        const message = error.response?.data?.error || 'Request failed'
        this.error = message
        return { success: false, error: message }
      } finally {
        this.loading = false
      }
    },

    async resetPassword(token, password, passwordConfirmation) {
      this.loading = true
      this.error = null
      try {
        await apiClient.post('/auth/reset_password', {
          reset_password_token: token,
          password,
          password_confirmation: passwordConfirmation
        })
        return { success: true }
      } catch (error) {
        const message = error.response?.data?.error || 'Reset failed'
        this.error = message
        return { success: false, error: message }
      } finally {
        this.loading = false
      }
    },

    async resendConfirmation(email) {
      try {
        await apiClient.post('/auth/resend_confirmation', { email })
        return { success: true }
      } catch {
        return { success: false }
      }
    },

    async confirmEmail(token) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.get('/auth/confirm', { params: { confirmation_token: token } })
        return { success: true, message: response.data.message }
      } catch (error) {
        const message = error.response?.data?.error || 'Confirmation failed'
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

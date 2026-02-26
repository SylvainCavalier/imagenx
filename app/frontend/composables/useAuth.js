import { computed } from 'vue'
import { useAuthStore } from '../stores/auth'

export function useAuth() {
  const authStore = useAuthStore()

  return {
    user: computed(() => authStore.currentUser),
    isAuthenticated: computed(() => authStore.isLoggedIn),
    loading: computed(() => authStore.isLoading),
    error: computed(() => authStore.error),
    hasError: computed(() => authStore.hasError),

    login: (credentials) => authStore.login(credentials),
    register: (userData) => authStore.register(userData),
    logout: () => authStore.logout(),
    checkAuth: () => authStore.checkAuth(),
    clearError: () => authStore.clearError(),
  }
}

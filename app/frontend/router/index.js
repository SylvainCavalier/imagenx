import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import routes from './routes'

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to) => {
  const authStore = useAuthStore()

  // Check auth on first navigation if not already checked
  if (!authStore.isLoggedIn && !authStore.loading) {
    await authStore.checkAuth()
  }

  if (to.meta.requiresAuth && !authStore.isLoggedIn) {
    return '/login'
  }

  if (to.meta.guest && authStore.isLoggedIn) {
    return '/app'
  }

  if (to.name === 'Landing' && authStore.isLoggedIn) {
    return '/app'
  }
})

export default router

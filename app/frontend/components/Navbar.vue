<template>
  <nav class="bg-gray-900 border-b border-gray-800">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-14">
        <div class="flex items-center space-x-6">
          <router-link to="/" class="text-lg font-bold text-white">Imagenx</router-link>
          <router-link
            to="/"
            exact-active-class="text-white"
            class="text-sm text-gray-300 hover:text-white transition-colors"
          >
            Dashboard
          </router-link>
          <router-link
            to="/my-images"
            active-class="text-white"
            class="text-sm text-gray-300 hover:text-white transition-colors"
          >
            My Images
          </router-link>
          <router-link
            to="/history"
            active-class="text-white"
            class="text-sm text-gray-300 hover:text-white transition-colors"
          >
            History
          </router-link>
        </div>
        <div class="flex items-center space-x-4">
          <span class="text-sm text-gray-400">{{ authStore.currentUser?.email }}</span>
          <button
            @click="handleLogout"
            class="text-sm text-gray-400 hover:text-white transition-colors"
          >
            Logout
          </button>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}
</script>

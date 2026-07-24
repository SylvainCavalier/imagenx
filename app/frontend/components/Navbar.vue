<template>
  <nav class="bg-gray-900 border-b border-gray-800">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-14">
        <div class="flex items-center space-x-6">
          <router-link to="/app" class="flex items-center">
            <img :src="logo" :alt="t('nav.brand')" class="h-5" />
          </router-link>
          <router-link
            to="/app"
            exact-active-class="text-white"
            class="text-sm text-gray-300 hover:text-white transition-colors"
          >
            {{ t('nav.dashboard') }}
          </router-link>
          <router-link
            to="/app/my-images"
            active-class="text-white"
            class="text-sm text-gray-300 hover:text-white transition-colors"
          >
            {{ t('nav.myImages') }}
          </router-link>
          <router-link
            to="/app/history"
            active-class="text-white"
            class="text-sm text-gray-300 hover:text-white transition-colors"
          >
            {{ t('nav.history') }}
          </router-link>
          <router-link
            to="/app/account"
            active-class="text-white"
            class="text-sm text-gray-300 hover:text-white transition-colors"
          >
            {{ t('nav.account') }}
          </router-link>
        </div>
        <div class="flex items-center space-x-4">
          <div class="flex items-center space-x-1.5">
            <button
              @click="setLocale('fr')"
              :class="locale === 'fr' ? 'opacity-100 ring-2 ring-indigo-500' : 'opacity-40 hover:opacity-75'"
              class="text-lg leading-none rounded transition-opacity"
              title="Français"
              aria-label="Français"
            >
              🇫🇷
            </button>
            <button
              @click="setLocale('en')"
              :class="locale === 'en' ? 'opacity-100 ring-2 ring-indigo-500' : 'opacity-40 hover:opacity-75'"
              class="text-lg leading-none rounded transition-opacity"
              title="English"
              aria-label="English"
            >
              🇬🇧
            </button>
          </div>
          <router-link to="/app/account" class="text-sm text-gray-500 hover:text-gray-300 transition-colors">
            {{ t('nav.credits', { count: authStore.currentUser?.credits_balance ?? 0 }) }}
          </router-link>
          <span class="text-sm text-gray-400">{{ authStore.currentUser?.email }}</span>
          <button
            @click="handleLogout"
            class="text-sm text-gray-400 hover:text-white transition-colors"
          >
            {{ t('nav.logout') }}
          </button>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '../stores/auth'
import { setLocale } from '../plugins/i18n'
import logo from '../images/logo-text-imagenx-white.png'

const router = useRouter()
const authStore = useAuthStore()
const { t, locale } = useI18n()

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}
</script>

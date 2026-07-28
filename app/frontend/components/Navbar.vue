<template>
  <nav class="relative z-40 bg-gray-900 border-b border-gray-800">
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
            v-if="authStore.currentUser?.admin"
            to="/admin"
            active-class="text-white"
            class="text-sm text-gray-300 hover:text-white transition-colors"
          >
            {{ t('nav.admin') }}
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
          <router-link
            to="/app/account"
            :title="lowCredits ? t('nav.creditsLow') : t('nav.creditsTitle')"
            :class="lowCredits
              ? 'bg-amber-500/10 border-amber-500/40 text-amber-300 hover:bg-amber-500/20'
              : 'bg-indigo-500/10 border-indigo-500/40 text-indigo-300 hover:bg-indigo-500/20'"
            class="flex items-center gap-1.5 pl-2 pr-3 py-1 rounded-full border text-sm font-medium transition-colors"
          >
            <svg class="w-3.5 h-3.5 shrink-0" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M13 2 4 14h6l-1 8 9-12h-6l1-8Z" />
            </svg>
            <span class="tabular-nums">
              {{ t('nav.credits', { count: creditsBalance }) }}
            </span>
          </router-link>
          <div ref="userMenuRef" class="relative">
            <button
              @click="menuOpen = !menuOpen"
              :aria-expanded="menuOpen"
              aria-haspopup="true"
              class="flex items-center gap-1.5 text-sm text-gray-400 hover:text-white transition-colors"
            >
              <span>{{ authStore.currentUser?.email }}</span>
              <svg
                :class="menuOpen ? 'rotate-180' : ''"
                class="w-3.5 h-3.5 shrink-0 transition-transform"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  fill-rule="evenodd"
                  d="M5.23 7.21a.75.75 0 0 1 1.06.02L10 11.17l3.71-3.94a.75.75 0 1 1 1.08 1.04l-4.25 4.5a.75.75 0 0 1-1.08 0l-4.25-4.5a.75.75 0 0 1 .02-1.06Z"
                  clip-rule="evenodd"
                />
              </svg>
            </button>
            <div
              v-if="menuOpen"
              class="absolute right-0 mt-2 w-48 py-1 bg-gray-900 border border-gray-800 rounded-lg shadow-lg shadow-black/40 z-50"
            >
              <router-link
                to="/app/account"
                active-class="text-white bg-gray-800"
                class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-800 hover:text-white transition-colors"
              >
                {{ t('nav.account') }}
              </router-link>
              <router-link
                to="/support"
                active-class="text-white bg-gray-800"
                class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-800 hover:text-white transition-colors"
              >
                {{ t('nav.support') }}
              </router-link>
              <div class="my-1 border-t border-gray-800"></div>
              <button
                @click="handleLogout"
                class="block w-full px-4 py-2 text-left text-sm text-gray-300 hover:bg-gray-800 hover:text-white transition-colors"
              >
                {{ t('nav.logout') }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { computed, ref, watch, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '../stores/auth'
import { setLocale } from '../plugins/i18n'
import logo from '../images/logo-text-imagenx-white.png'

// Mirrors User::GENERATION_COST_PER_IMAGE: below one image's worth of credits,
// the pill switches to a warning colour.
const LOW_CREDITS_THRESHOLD = 8

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const { t, locale } = useI18n()

const creditsBalance = computed(() => authStore.currentUser?.credits_balance ?? 0)
const lowCredits = computed(() => creditsBalance.value < LOW_CREDITS_THRESHOLD)

const menuOpen = ref(false)
const userMenuRef = ref(null)

// Clicking one of the menu's own links navigates without unmounting the navbar,
// so the menu has to be closed on route change as well as on outside click/Escape.
watch(() => route.fullPath, () => { menuOpen.value = false })

const handleOutsideClick = (event) => {
  if (menuOpen.value && !userMenuRef.value?.contains(event.target)) {
    menuOpen.value = false
  }
}

const handleEscape = (event) => {
  if (event.key === 'Escape') menuOpen.value = false
}

onMounted(() => {
  document.addEventListener('click', handleOutsideClick)
  document.addEventListener('keydown', handleEscape)
})

onUnmounted(() => {
  document.removeEventListener('click', handleOutsideClick)
  document.removeEventListener('keydown', handleEscape)
})

const handleLogout = async () => {
  menuOpen.value = false
  await authStore.logout()
  router.push('/login')
}
</script>

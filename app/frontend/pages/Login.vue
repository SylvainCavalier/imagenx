<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-950 px-4">
    <div class="w-full max-w-md">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-white">Imagenx</h1>
        <p class="text-gray-400 mt-2">{{ t('auth.signInSubtitle') }}</p>
      </div>

      <form @submit.prevent="handleLogin" class="bg-gray-900 rounded-2xl p-8 shadow-xl border border-gray-800">
        <div v-if="authStore.error" class="mb-4 p-3 bg-red-900/50 border border-red-700 rounded-lg text-red-300 text-sm">
          {{ authStore.error }}
          <button
            v-if="unconfirmed && !resent"
            type="button"
            @click="handleResend"
            class="block mt-1 text-red-200 underline hover:text-white"
          >
            {{ t('auth.resendConfirmation') }}
          </button>
          <span v-else-if="resent" class="block mt-1 text-red-200">{{ t('auth.resendSuccess') }}</span>
        </div>

        <div class="mb-5">
          <label for="email" class="block text-sm font-medium text-gray-300 mb-1.5">{{ t('auth.email') }}</label>
          <input
            id="email"
            v-model="email"
            type="email"
            required
            autocomplete="email"
            class="w-full px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
            placeholder="you@example.com"
          />
        </div>

        <div class="mb-2">
          <label for="password" class="block text-sm font-medium text-gray-300 mb-1.5">{{ t('auth.password') }}</label>
          <input
            id="password"
            v-model="password"
            type="password"
            required
            autocomplete="current-password"
            class="w-full px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
            placeholder="••••••••"
          />
        </div>

        <div class="mb-6 text-right">
          <router-link to="/forgot-password" class="text-sm text-indigo-400 hover:text-indigo-300">
            {{ t('auth.forgotPassword') }}
          </router-link>
        </div>

        <button
          type="submit"
          :disabled="authStore.isLoading"
          class="w-full py-2.5 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-50 text-white font-medium rounded-lg transition-colors"
        >
          {{ authStore.isLoading ? t('auth.signingIn') : t('auth.signIn') }}
        </button>

        <p class="mt-4 text-center text-sm text-gray-400">
          {{ t('auth.noAccount') }}
          <router-link to="/register" class="text-indigo-400 hover:text-indigo-300">{{ t('auth.signUp') }}</router-link>
        </p>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const authStore = useAuthStore()
const { t } = useI18n()

const email = ref('')
const password = ref('')
const unconfirmed = ref(false)
const resent = ref(false)

const handleLogin = async () => {
  authStore.clearError()
  unconfirmed.value = false
  resent.value = false
  const result = await authStore.login({ email: email.value, password: password.value })
  if (result.success) {
    router.push('/app')
  } else {
    unconfirmed.value = !!result.unconfirmed
  }
}

const handleResend = async () => {
  await authStore.resendConfirmation(email.value)
  resent.value = true
}
</script>

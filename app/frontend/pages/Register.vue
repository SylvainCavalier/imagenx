<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-950 px-4">
    <div class="w-full max-w-md">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-white">Imagenx</h1>
        <p class="text-gray-400 mt-2">{{ t('auth.createSubtitle') }}</p>
      </div>

      <div v-if="registered" class="bg-gray-900 rounded-2xl p-8 shadow-xl border border-gray-800 text-center">
        <p class="text-gray-300">{{ t('auth.checkEmailBody', { email: registeredEmail }) }}</p>
        <router-link to="/login" class="mt-4 inline-block text-indigo-400 hover:text-indigo-300 text-sm">
          {{ t('auth.signIn') }}
        </router-link>
      </div>

      <form v-else @submit.prevent="handleRegister" class="bg-gray-900 rounded-2xl p-8 shadow-xl border border-gray-800">
        <div v-if="authStore.error" class="mb-4 p-3 bg-red-900/50 border border-red-700 rounded-lg text-red-300 text-sm">
          {{ authStore.error }}
        </div>

        <!-- Honeypot: left empty by humans, invisible_captcha rejects submissions where this is filled -->
        <input
          v-model="subtitle"
          type="text"
          name="subtitle"
          tabindex="-1"
          autocomplete="off"
          class="absolute -left-[9999px] w-px h-px opacity-0"
          aria-hidden="true"
        />

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

        <div class="mb-5">
          <label for="password" class="block text-sm font-medium text-gray-300 mb-1.5">{{ t('auth.password') }}</label>
          <input
            id="password"
            v-model="password"
            type="password"
            required
            autocomplete="new-password"
            class="w-full px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
            :placeholder="t('auth.minChars')"
          />
        </div>

        <div class="mb-6">
          <label for="password_confirmation" class="block text-sm font-medium text-gray-300 mb-1.5">{{ t('auth.confirmPassword') }}</label>
          <input
            id="password_confirmation"
            v-model="passwordConfirmation"
            type="password"
            required
            autocomplete="new-password"
            class="w-full px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
            placeholder="••••••••"
          />
        </div>

        <button
          type="submit"
          :disabled="authStore.isLoading"
          class="w-full py-2.5 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-50 text-white font-medium rounded-lg transition-colors"
        >
          {{ authStore.isLoading ? t('auth.creatingAccount') : t('auth.createAccount') }}
        </button>

        <p class="mt-4 text-center text-sm text-gray-400">
          {{ t('auth.hasAccount') }}
          <router-link to="/login" class="text-indigo-400 hover:text-indigo-300">{{ t('auth.signIn') }}</router-link>
        </p>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const { t } = useI18n()

const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')
const subtitle = ref('') // honeypot, must stay empty
const registered = ref(false)
const registeredEmail = ref('')

const handleRegister = async () => {
  authStore.clearError()
  const result = await authStore.register({
    email: email.value,
    password: password.value,
    password_confirmation: passwordConfirmation.value,
    subtitle: subtitle.value
  })
  if (result.success) {
    registered.value = true
    registeredEmail.value = result.email
  }
}
</script>

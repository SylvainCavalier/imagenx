<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-950 px-4">
    <div class="w-full max-w-md">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-white">Imagenx</h1>
      </div>

      <div class="bg-gray-900 rounded-2xl p-8 shadow-xl border border-gray-800 text-center">
        <p v-if="status === 'loading'" class="text-gray-300">{{ t('auth.confirmingEmail') }}</p>

        <template v-else-if="status === 'success'">
          <p class="text-gray-300">{{ t('auth.confirmSuccess') }}</p>
          <router-link to="/login" class="mt-4 inline-block text-indigo-400 hover:text-indigo-300 text-sm">
            {{ t('auth.signIn') }}
          </router-link>
        </template>

        <template v-else>
          <p class="text-red-300">{{ t('auth.confirmError') }}</p>

          <div v-if="resent" class="mt-4 text-sm text-gray-400">{{ t('auth.resendSuccess') }}</div>
          <form v-else @submit.prevent="handleResend" class="mt-4">
            <input
              v-model="email"
              type="email"
              required
              autocomplete="email"
              class="w-full px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
              placeholder="you@example.com"
            />
            <button
              type="submit"
              class="mt-3 w-full py-2.5 bg-indigo-600 hover:bg-indigo-500 text-white font-medium rounded-lg transition-colors"
            >
              {{ t('auth.resendConfirmation') }}
            </button>
          </form>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '../stores/auth'

const route = useRoute()
const authStore = useAuthStore()
const { t } = useI18n()

const status = ref('loading')
const email = ref('')
const resent = ref(false)

onMounted(async () => {
  const token = route.query.confirmation_token
  const result = await authStore.confirmEmail(token)
  status.value = result.success ? 'success' : 'error'
})

const handleResend = async () => {
  await authStore.resendConfirmation(email.value)
  resent.value = true
}
</script>

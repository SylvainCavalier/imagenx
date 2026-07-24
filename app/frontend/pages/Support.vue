<template>
  <div class="max-w-2xl mx-auto px-4 py-8">
    <h1 class="text-2xl font-bold text-white mb-2">{{ t('support.title') }}</h1>
    <p class="text-sm text-gray-400 mb-6">{{ t('support.subtitle') }}</p>

    <div v-if="submitted" class="bg-emerald-900/30 border border-emerald-700 rounded-xl p-6 text-emerald-300 text-sm">
      {{ t('support.successMessage') }}
      <button @click="resetForm" class="ml-2 underline">{{ t('support.newTicket') }}</button>
    </div>

    <template v-else>
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 mb-6">
        <button
          v-for="option in categories"
          :key="option.value"
          @click="category = option.value"
          class="text-left px-4 py-3 rounded-xl border transition-colors"
          :class="category === option.value
            ? 'bg-indigo-600/20 border-indigo-500 text-white'
            : 'bg-gray-900 border-gray-800 text-gray-300 hover:border-gray-700'"
        >
          <span class="block text-sm font-medium">{{ option.label }}</span>
        </button>
      </div>

      <div class="bg-gray-900 rounded-xl border border-gray-800 p-6">
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-300 mb-2">{{ t('support.subjectLabel') }}</label>
          <input
            v-model="subject"
            type="text"
            class="w-full px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-300 mb-2">{{ t('support.messageLabel') }}</label>
          <textarea
            v-model="message"
            rows="6"
            class="w-full px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 resize-none"
          />
        </div>

        <div v-if="error" class="mb-4 p-3 bg-red-900/50 border border-red-700 rounded-lg text-red-300 text-sm">
          {{ error }}
        </div>

        <button
          @click="submit"
          :disabled="!canSubmit || submitting"
          class="px-6 py-2 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed text-white font-medium rounded-lg text-sm transition-colors"
        >
          {{ submitting ? t('support.sending') : t('support.submit') }}
        </button>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useApi } from '../composables/useApi'

const { t } = useI18n()
const { post } = useApi()

const categories = computed(() => [
  { value: 'technical', label: t('support.categoryTechnical') },
  { value: 'billing', label: t('support.categoryBilling') },
  { value: 'idea', label: t('support.categoryIdea') }
])

const category = ref('technical')
const subject = ref('')
const message = ref('')
const submitting = ref(false)
const submitted = ref(false)
const error = ref(null)

const canSubmit = computed(() => subject.value.trim() && message.value.trim())

const submit = async () => {
  if (!canSubmit.value) return
  submitting.value = true
  error.value = null

  try {
    await post('/support_tickets', {
      category: category.value,
      subject: subject.value,
      message: message.value
    })
    submitted.value = true
  } catch (e) {
    error.value = e.response?.data?.error || t('support.submitError')
  } finally {
    submitting.value = false
  }
}

const resetForm = () => {
  subject.value = ''
  message.value = ''
  category.value = 'technical'
  submitted.value = false
}
</script>

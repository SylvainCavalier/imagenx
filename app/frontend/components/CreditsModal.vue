<template>
  <Teleport to="body">
    <Transition
      enter-active-class="transition-opacity duration-150"
      enter-from-class="opacity-0"
      leave-active-class="transition-opacity duration-150"
      leave-to-class="opacity-0"
    >
      <div
        v-if="open"
        class="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/75 backdrop-blur-sm"
        role="dialog"
        aria-modal="true"
        :aria-label="t('creditsModal.title')"
        @click.self="close"
      >
        <div class="w-full max-w-2xl max-h-[90vh] overflow-y-auto bg-gray-900 border border-gray-800 rounded-2xl shadow-2xl">
          <!-- Header -->
          <div class="relative px-6 pt-6 pb-5 border-b border-gray-800">
            <button
              @click="close"
              :aria-label="t('common.close')"
              class="absolute top-4 right-4 p-1 text-gray-500 hover:text-white transition-colors"
            >
              <svg class="w-5 h-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                <path d="M6.28 5.22a.75.75 0 0 0-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 1 0 1.06 1.06L10 11.06l3.72 3.72a.75.75 0 1 0 1.06-1.06L11.06 10l3.72-3.72a.75.75 0 0 0-1.06-1.06L10 8.94 6.28 5.22Z" />
              </svg>
            </button>

            <h2 class="text-xl font-bold text-white">{{ t('creditsModal.title') }}</h2>
            <p class="mt-1.5 text-sm text-gray-400">
              {{ t('creditsModal.balance', { count: balance }) }}
              &middot;
              {{ t('creditsModal.remainingImages', { count: imagesFor(balance) }) }}
            </p>
          </div>

          <div class="px-6 py-5">
            <!-- Top-up packs -->
            <p class="text-sm font-medium text-gray-300 mb-3">{{ t('creditsModal.topupTitle') }}</p>
            <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
              <button
                v-for="pack in TOPUP_PACKS"
                :key="pack.key"
                @click="buy(pack.key)"
                :disabled="billingStore.loading"
                class="group px-3 py-4 bg-gray-800/70 hover:bg-gray-800 border border-gray-700 hover:border-indigo-500/60 disabled:opacity-50 rounded-xl text-center transition-colors"
              >
                <span class="block text-lg font-bold text-white">{{ pack.price }}</span>
                <span class="block text-xs text-indigo-300 mt-1">
                  {{ t('creditsModal.creditsCount', { count: pack.credits }) }}
                </span>
                <span class="block text-xs text-gray-500 mt-0.5">
                  {{ t('creditsModal.imagesApprox', { count: imagesFor(pack.credits) }) }}
                </span>
              </button>
            </div>
            <p class="mt-3 text-xs text-gray-500">
              {{ t('creditsModal.costNote', { cost: CREDITS_PER_IMAGE }) }}
            </p>

            <!-- Subscription -->
            <div class="mt-6 p-5 rounded-xl border border-indigo-500/40 bg-gradient-to-br from-indigo-500/15 to-purple-500/10">
              <div class="flex items-start justify-between gap-4">
                <div>
                  <h3 class="text-base font-semibold text-white">{{ t('creditsModal.subscription.title') }}</h3>
                  <p class="mt-1 text-sm text-gray-300">
                    {{ t('creditsModal.subscription.pitch', { credits: SUBSCRIPTION_CREDITS, images: imagesFor(SUBSCRIPTION_CREDITS) }) }}
                  </p>
                </div>
                <span class="shrink-0 px-2.5 py-1 rounded-full bg-indigo-500/20 border border-indigo-400/40 text-xs font-semibold text-indigo-200">
                  {{ t('creditsModal.subscription.badge') }}
                </span>
              </div>

              <button
                v-if="isSubscribed"
                @click="manageSubscription"
                :disabled="billingStore.loading"
                class="mt-4 w-full px-4 py-2.5 bg-gray-800 hover:bg-gray-700 border border-gray-700 disabled:opacity-50 text-white rounded-lg text-sm font-medium transition-colors"
              >
                {{ t('creditsModal.subscription.manageCta') }}
              </button>
              <button
                v-else
                @click="subscribe"
                :disabled="billingStore.loading"
                class="mt-4 w-full px-4 py-2.5 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-50 text-white rounded-lg text-sm font-medium transition-colors"
              >
                {{ t('creditsModal.subscription.cta') }}
              </button>
            </div>

            <div v-if="billingStore.error" class="mt-4 p-3 bg-red-900/50 border border-red-700 rounded-lg text-red-300 text-sm">
              {{ billingStore.error }}
            </div>

            <router-link
              to="/app/account"
              class="mt-4 block text-center text-xs text-gray-500 hover:text-gray-300 transition-colors"
            >
              {{ t('creditsModal.accountLink') }}
            </router-link>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { computed, watch, onUnmounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '../stores/auth'
import { useBillingStore } from '../stores/billing'
import { CREDITS_PER_IMAGE, TOPUP_PACKS, SUBSCRIPTION_CREDITS, imagesFor } from '../constants/credits'

const props = defineProps({
  open: { type: Boolean, default: false }
})
const emit = defineEmits(['close'])

const { t } = useI18n()
const authStore = useAuthStore()
const billingStore = useBillingStore()

const balance = computed(() => authStore.currentUser?.credits_balance ?? 0)
const isSubscribed = computed(() =>
  ['active', 'trialing', 'past_due'].includes(authStore.currentUser?.subscription_status)
)

const close = () => emit('close')

const handleEscape = (event) => {
  if (event.key === 'Escape') close()
}

// A stale error from a previous attempt would otherwise greet the user on reopen.
watch(() => props.open, (open) => {
  if (open) {
    billingStore.clearError()
    document.addEventListener('keydown', handleEscape)
    document.body.style.overflow = 'hidden'
  } else {
    document.removeEventListener('keydown', handleEscape)
    document.body.style.overflow = ''
  }
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleEscape)
  document.body.style.overflow = ''
})

const buy = async (pack) => {
  const result = await billingStore.createCheckout(pack)
  if (result.success) window.location.href = result.url
}

const subscribe = async () => {
  const result = await billingStore.createCheckout('subscription_monthly')
  if (result.success) window.location.href = result.url
}

const manageSubscription = async () => {
  const result = await billingStore.createPortalSession()
  if (result.success) window.location.href = result.url
}
</script>

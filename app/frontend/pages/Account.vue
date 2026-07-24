<template>
  <div class="max-w-3xl mx-auto px-4 py-8">
    <h1 class="text-2xl font-bold text-white mb-6">{{ t('account.title') }}</h1>

    <div v-if="checkoutBanner" class="mb-6 p-4 bg-indigo-900/50 border border-indigo-700 rounded-lg text-indigo-200 text-sm">
      {{ checkoutBanner }}
    </div>

    <!-- Profile -->
    <div class="bg-gray-900 rounded-xl border border-gray-800 p-6 mb-6">
      <h2 class="text-lg font-semibold text-white mb-4">{{ t('account.profile.title') }}</h2>

      <div class="space-y-3 mb-4">
        <label class="block text-sm font-medium text-gray-300">{{ t('account.profile.nameLabel') }}</label>
        <div class="flex space-x-2">
          <input
            v-model="name"
            type="text"
            class="flex-1 px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
          <button
            @click="saveName"
            :disabled="billingStore.loading"
            class="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-50 text-white rounded-lg text-sm transition-colors"
          >
            {{ t('common.save') }}
          </button>
        </div>
      </div>

      <div class="border-t border-gray-800 pt-4 space-y-3">
        <label class="block text-sm font-medium text-gray-300">{{ t('account.profile.emailLabel') }}</label>
        <input
          v-model="email"
          type="email"
          class="w-full px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />

        <label class="block text-sm font-medium text-gray-300">{{ t('account.profile.newPasswordLabel') }}</label>
        <input
          v-model="newPassword"
          type="password"
          :placeholder="t('account.profile.newPasswordPlaceholder')"
          class="w-full px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />
        <input
          v-if="newPassword"
          v-model="newPasswordConfirmation"
          type="password"
          :placeholder="t('account.profile.passwordConfirmationLabel')"
          class="w-full px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />

        <label class="block text-sm font-medium text-gray-300">{{ t('account.profile.currentPasswordLabel') }}</label>
        <input
          v-model="currentPassword"
          type="password"
          class="w-full px-4 py-2.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />

        <button
          @click="saveSecurity"
          :disabled="billingStore.loading || !currentPassword"
          class="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-50 text-white rounded-lg text-sm transition-colors"
        >
          {{ t('account.profile.saveSecurity') }}
        </button>
        <p v-if="securityMessage" class="text-sm text-emerald-400">{{ securityMessage }}</p>
      </div>

      <div v-if="billingStore.error" class="mt-4 p-3 bg-red-900/50 border border-red-700 rounded-lg text-red-300 text-sm">
        {{ billingStore.error }}
        <button @click="billingStore.clearError()" class="ml-2 underline">{{ t('dashboard.dismiss') }}</button>
      </div>
    </div>

    <!-- Credits -->
    <div class="bg-gray-900 rounded-xl border border-gray-800 p-6 mb-6">
      <h2 class="text-lg font-semibold text-white mb-1">{{ t('account.credits.title') }}</h2>
      <p class="text-3xl font-bold text-white mb-4">{{ authStore.currentUser?.credits_balance ?? 0 }}</p>

      <p class="text-sm text-gray-400 mb-3">{{ t('account.credits.topupTitle') }}</p>
      <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <button
          v-for="pack in topupPacks"
          :key="pack.key"
          @click="buy(pack.key)"
          :disabled="billingStore.loading"
          class="px-4 py-3 bg-gray-800 hover:bg-gray-700 border border-gray-700 disabled:opacity-50 text-white rounded-lg text-sm transition-colors text-center"
        >
          <span class="block font-semibold">{{ pack.price }}</span>
          <span class="block text-xs text-gray-400 mt-0.5">{{ t('account.credits.creditsCount', { count: pack.credits }) }}</span>
        </button>
      </div>
    </div>

    <!-- Subscription -->
    <div class="bg-gray-900 rounded-xl border border-gray-800 p-6 mb-6">
      <h2 class="text-lg font-semibold text-white mb-4">{{ t('account.subscription.title') }}</h2>

      <div v-if="isSubscribed">
        <p class="text-sm text-gray-300">
          {{ t(`account.subscription.status.${subscriptionStatus}`) }}
          <span v-if="renewalDate">
            &middot;
            {{ cancelAtPeriodEnd ? t('account.subscription.cancelingOn', { date: renewalDate }) : t('account.subscription.renewsOn', { date: renewalDate }) }}
          </span>
        </p>
        <button
          @click="manageSubscription"
          :disabled="billingStore.loading"
          class="mt-4 px-4 py-2 bg-gray-800 hover:bg-gray-700 border border-gray-700 disabled:opacity-50 text-white rounded-lg text-sm transition-colors"
        >
          {{ t('account.subscription.manageButton') }}
        </button>
      </div>
      <div v-else>
        <p class="text-sm text-gray-400 mb-4">{{ t('account.subscription.pitch') }}</p>
        <div class="flex items-center space-x-3">
          <button
            @click="subscribe"
            :disabled="billingStore.loading"
            class="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-50 text-white rounded-lg text-sm transition-colors"
          >
            {{ t('account.subscription.subscribeButton') }}
          </button>
          <button
            v-if="authStore.currentUser?.has_stripe_customer"
            @click="manageSubscription"
            :disabled="billingStore.loading"
            class="text-sm text-gray-500 hover:text-gray-300 transition-colors"
          >
            {{ t('account.subscription.billingHistory') }}
          </button>
        </div>
      </div>
    </div>

    <!-- Credit history -->
    <div class="bg-gray-900 rounded-xl border border-gray-800 p-6">
      <h2 class="text-lg font-semibold text-white mb-4">{{ t('account.history.title') }}</h2>

      <div v-if="billingStore.loadingHistory" class="text-gray-400 text-sm">{{ t('common.loading') }}</div>
      <div v-else-if="!billingStore.transactions.length" class="text-gray-500 text-sm">{{ t('account.history.empty') }}</div>
      <div v-else class="space-y-2">
        <div
          v-for="tx in billingStore.transactions"
          :key="tx.id"
          class="flex items-center justify-between text-sm py-2 border-b border-gray-800 last:border-0"
        >
          <div>
            <p class="text-gray-300">{{ t(`account.history.reasons.${camelReason(tx.reason)}`) }}</p>
            <p class="text-xs text-gray-500">{{ formatDate(tx.created_at) }}</p>
          </div>
          <div class="text-right">
            <p :class="tx.amount >= 0 ? 'text-emerald-400' : 'text-red-400'" class="font-medium">
              {{ tx.amount >= 0 ? '+' : '' }}{{ tx.amount }}
            </p>
            <p class="text-xs text-gray-500">{{ t('account.history.balance', { balance: tx.balance_after }) }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useBillingStore } from '../stores/billing'

const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const billingStore = useBillingStore()

const name = ref(authStore.currentUser?.name || '')
const email = ref(authStore.currentUser?.email || '')
const newPassword = ref('')
const newPasswordConfirmation = ref('')
const currentPassword = ref('')
const securityMessage = ref('')
const checkoutBanner = ref('')

const topupPacks = [
  { key: 'topup_300', price: '3€', credits: 300 },
  { key: 'topup_500', price: '5€', credits: 500 },
  { key: 'topup_1000', price: '10€', credits: 1000 },
  { key: 'topup_2000', price: '20€', credits: 2000 },
]

const subscriptionStatus = computed(() => authStore.currentUser?.subscription_status)
const isSubscribed = computed(() => ['active', 'trialing', 'past_due'].includes(subscriptionStatus.value))
const cancelAtPeriodEnd = computed(() => authStore.currentUser?.subscription_cancel_at_period_end)
const renewalDate = computed(() => {
  const raw = authStore.currentUser?.subscription_current_period_end
  return raw ? formatDate(raw) : null
})

const camelReason = (reason) => reason.replace(/_([a-z])/g, (_, c) => c.toUpperCase())

const formatDate = (dateStr) => {
  return new Date(dateStr).toLocaleDateString(locale.value === 'fr' ? 'fr-FR' : 'en-US', {
    year: 'numeric', month: 'short', day: 'numeric'
  })
}

onMounted(async () => {
  billingStore.fetchCreditHistory()

  if (route.query.checkout === 'success') {
    checkoutBanner.value = t('account.checkout.successMessage')
    const before = authStore.currentUser?.credits_balance
    for (let i = 0; i < 5; i++) {
      await new Promise((resolve) => setTimeout(resolve, 2000))
      await authStore.checkAuth()
      if (authStore.currentUser?.credits_balance !== before) break
    }
    billingStore.fetchCreditHistory()
  } else if (route.query.checkout === 'cancel') {
    checkoutBanner.value = t('account.checkout.cancelMessage')
  }

  if (route.query.checkout) {
    router.replace({ query: {} })
  }
})

const saveName = async () => {
  await billingStore.updateAccount({ name: name.value })
}

const saveSecurity = async () => {
  securityMessage.value = ''
  const payload = { current_password: currentPassword.value }
  if (email.value !== authStore.currentUser?.email) payload.email = email.value
  if (newPassword.value) {
    payload.password = newPassword.value
    payload.password_confirmation = newPasswordConfirmation.value
  }

  const result = await billingStore.updateAccount(payload)
  if (result.success) {
    currentPassword.value = ''
    newPassword.value = ''
    newPasswordConfirmation.value = ''
    securityMessage.value = t('account.profile.securityUpdated')
  }
}

const buy = async (pack) => {
  const result = await billingStore.createCheckout(pack)
  if (result.success) {
    window.location.href = result.url
  }
}

const subscribe = async () => {
  const result = await billingStore.createCheckout('subscription_monthly')
  if (result.success) {
    window.location.href = result.url
  }
}

const manageSubscription = async () => {
  const result = await billingStore.createPortalSession()
  if (result.success) {
    window.location.href = result.url
  }
}
</script>

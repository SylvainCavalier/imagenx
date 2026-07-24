<template>
  <div>
    <div class="flex items-center justify-between mb-4">
      <input
        v-model="query"
        @input="debouncedSearch"
        type="text"
        :placeholder="t('admin.users.searchPlaceholder')"
        class="px-3 py-1.5 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 w-64"
      />
      <button
        @click="openCreateModal"
        class="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg text-sm transition-colors"
      >
        {{ t('admin.users.addButton') }}
      </button>
    </div>

    <div class="bg-gray-900 rounded-xl border border-gray-800 overflow-hidden">
      <table class="w-full text-sm">
        <thead>
          <tr class="border-b border-gray-800 text-left text-gray-500">
            <th class="px-4 py-3 font-medium">{{ t('admin.users.email') }}</th>
            <th class="px-4 py-3 font-medium">{{ t('admin.users.name') }}</th>
            <th class="px-4 py-3 font-medium">{{ t('admin.users.confirmed') }}</th>
            <th class="px-4 py-3 font-medium">{{ t('admin.users.subscription') }}</th>
            <th class="px-4 py-3 font-medium">{{ t('admin.users.credits') }}</th>
            <th class="px-4 py-3 font-medium">{{ t('admin.users.signIns') }}</th>
            <th class="px-4 py-3 font-medium">{{ t('admin.users.admin') }}</th>
            <th class="px-4 py-3 font-medium"></th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-800">
          <tr v-for="user in users" :key="user.id" class="text-gray-300">
            <td class="px-4 py-3">{{ user.email }}</td>
            <td class="px-4 py-3">{{ user.name || '—' }}</td>
            <td class="px-4 py-3">
              <span
                class="text-xs font-medium px-2 py-0.5 rounded-full"
                :class="user.confirmed ? 'bg-green-900/50 text-green-300' : 'bg-yellow-900/50 text-yellow-300'"
              >
                {{ user.confirmed ? t('admin.users.confirmedYes') : t('admin.users.confirmedNo') }}
              </span>
            </td>
            <td class="px-4 py-3 text-gray-500">{{ user.subscription_status || '—' }}</td>
            <td class="px-4 py-3">{{ user.credits_balance }}</td>
            <td class="px-4 py-3 text-gray-500">{{ user.sign_in_count }}</td>
            <td class="px-4 py-3">
              <span v-if="user.admin" class="text-xs font-medium px-2 py-0.5 rounded-full bg-indigo-900/50 text-indigo-300">
                {{ t('admin.users.admin') }}
              </span>
              <span v-else class="text-gray-600">—</span>
            </td>
            <td class="px-4 py-3 text-right">
              <button @click="openEditModal(user)" class="text-indigo-400 hover:text-indigo-300 text-sm">
                {{ t('admin.users.editButton') }}
              </button>
            </td>
          </tr>
          <tr v-if="!users.length">
            <td colspan="8" class="px-4 py-6 text-center text-gray-500">{{ t('common.loading') }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="pagy && pagy.pages > 1" class="flex items-center justify-center space-x-3 mt-4 text-sm">
      <button
        @click="changePage(pagy.page - 1)"
        :disabled="pagy.page <= 1"
        class="px-3 py-1.5 bg-gray-800 hover:bg-gray-700 disabled:opacity-40 border border-gray-700 rounded-lg text-gray-300"
      >
        {{ t('admin.users.prevPage') }}
      </button>
      <span class="text-gray-500">{{ pagy.page }} / {{ pagy.pages }}</span>
      <button
        @click="changePage(pagy.page + 1)"
        :disabled="pagy.page >= pagy.pages"
        class="px-3 py-1.5 bg-gray-800 hover:bg-gray-700 disabled:opacity-40 border border-gray-700 rounded-lg text-gray-300"
      >
        {{ t('admin.users.nextPage') }}
      </button>
    </div>

    <!-- Create/Edit modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black/70 z-50 flex items-center justify-center p-4" @click.self="showModal = false">
      <div class="bg-gray-900 rounded-xl border border-gray-800 p-6 w-full max-w-sm">
        <h3 class="text-lg font-semibold text-white mb-4">
          {{ editingUser ? t('admin.users.editButton') : t('admin.users.addButton') }}
        </h3>

        <div class="space-y-3 mb-4">
          <div>
            <label class="block text-xs text-gray-400 mb-1">{{ t('admin.users.email') }}</label>
            <input
              v-model="form.email"
              type="email"
              class="w-full px-3 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <div>
            <label class="block text-xs text-gray-400 mb-1">{{ t('admin.users.name') }}</label>
            <input
              v-model="form.name"
              type="text"
              class="w-full px-3 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <div>
            <label class="block text-xs text-gray-400 mb-1">{{ t('admin.users.credits') }}</label>
            <input
              v-model.number="form.credits_balance"
              type="number"
              class="w-full px-3 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <label class="flex items-center space-x-2 text-sm text-gray-300">
            <input v-model="form.admin" type="checkbox" class="rounded border-gray-700 bg-gray-800 text-indigo-500 focus:ring-indigo-500" />
            <span>{{ t('admin.users.admin') }}</span>
          </label>
        </div>

        <div v-if="formError" class="mb-4 p-3 bg-red-900/50 border border-red-700 rounded-lg text-red-300 text-sm">
          {{ formError }}
        </div>

        <div class="flex justify-end space-x-3">
          <button @click="showModal = false" class="px-4 py-2 text-gray-400 hover:text-white text-sm">
            {{ t('common.cancel') }}
          </button>
          <button
            @click="saveUser"
            class="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg text-sm"
          >
            {{ t('common.save') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useApi } from '../../composables/useApi'

const { t } = useI18n()
const { useCrud } = useApi()
const usersCrud = useCrud('admin/users')

const users = ref([])
const pagy = ref(null)
const query = ref('')
const page = ref(1)

const showModal = ref(false)
const editingUser = ref(null)
const formError = ref(null)
const form = ref({ email: '', name: '', credits_balance: 0, admin: false })

let searchTimeout = null
const debouncedSearch = () => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    page.value = 1
    loadUsers()
  }, 300)
}

const loadUsers = async () => {
  const result = await usersCrud.list({ q: query.value, page: page.value })
  users.value = result.records
  pagy.value = result.pagy
}

const changePage = (newPage) => {
  page.value = newPage
  loadUsers()
}

const openCreateModal = () => {
  editingUser.value = null
  form.value = { email: '', name: '', credits_balance: 0, admin: false }
  formError.value = null
  showModal.value = true
}

const openEditModal = (user) => {
  editingUser.value = user
  form.value = {
    email: user.email,
    name: user.name || '',
    credits_balance: user.credits_balance,
    admin: user.admin
  }
  formError.value = null
  showModal.value = true
}

const saveUser = async () => {
  formError.value = null
  try {
    if (editingUser.value) {
      await usersCrud.update(editingUser.value.id, form.value)
    } else {
      await usersCrud.create(form.value)
    }
    showModal.value = false
    loadUsers()
  } catch (e) {
    formError.value = e.response?.data?.error || t('admin.users.saveError')
  }
}

onMounted(loadUsers)
</script>

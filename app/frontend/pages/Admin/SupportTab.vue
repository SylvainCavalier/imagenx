<template>
  <div>
    <div class="flex items-center space-x-2 mb-4">
      <button
        v-for="option in statusFilters"
        :key="option.value"
        @click="setStatusFilter(option.value)"
        class="px-3 py-1.5 rounded-lg text-sm border transition-colors"
        :class="statusFilter === option.value
          ? 'bg-indigo-600/20 border-indigo-500 text-white'
          : 'bg-gray-900 border-gray-800 text-gray-400 hover:border-gray-700'"
      >
        {{ option.label }}
      </button>
    </div>

    <div class="space-y-3">
      <div
        v-for="ticket in tickets"
        :key="ticket.id"
        class="bg-gray-900 rounded-xl border border-gray-800 p-5"
      >
        <div class="flex items-start justify-between mb-2">
          <div>
            <span class="text-xs font-medium px-2 py-0.5 rounded-full bg-gray-800 text-gray-300 mr-2">
              {{ t(`admin.categoryLabels.${ticket.category}`) }}
            </span>
            <span class="text-sm font-semibold text-white">{{ ticket.subject }}</span>
          </div>
          <select
            v-model="ticket.status"
            @change="updateStatus(ticket)"
            class="px-2 py-1 bg-gray-800 border border-gray-700 rounded-lg text-white text-xs focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            <option v-for="status in statuses" :key="status" :value="status">
              {{ t(`admin.ticketStatus.${status}`) }}
            </option>
          </select>
        </div>

        <p class="text-xs text-gray-500 mb-3">
          {{ ticket.user.name || ticket.user.email }} · {{ formatDate(ticket.created_at) }}
        </p>

        <p class="text-sm text-gray-300 whitespace-pre-wrap mb-3">{{ ticket.message }}</p>

        <textarea
          v-model="ticket.admin_notes"
          @blur="updateNotes(ticket)"
          :placeholder="t('admin.support.notesPlaceholder')"
          rows="2"
          class="w-full px-3 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 resize-none mb-3"
        />

        <div class="flex justify-end">
          <button @click="deleteTicket(ticket)" class="text-red-400 hover:text-red-300 text-xs">
            {{ t('common.delete') }}
          </button>
        </div>
      </div>

      <div v-if="!tickets.length" class="text-center text-gray-500 text-sm py-8">
        {{ t('admin.support.empty') }}
      </div>
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
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useApi } from '../../composables/useApi'

const { t } = useI18n()
const { useCrud } = useApi()
const ticketsCrud = useCrud('admin/support_tickets')

const statuses = ['open', 'in_progress', 'resolved', 'closed']
const tickets = ref([])
const pagy = ref(null)
const statusFilter = ref('')
const page = ref(1)

const statusFilters = computed(() => [
  { value: '', label: t('admin.support.allStatuses') },
  ...statuses.map((s) => ({ value: s, label: t(`admin.ticketStatus.${s}`) }))
])

const loadTickets = async () => {
  const result = await ticketsCrud.list({ status: statusFilter.value, page: page.value })
  tickets.value = result.records
  pagy.value = result.pagy
}

const setStatusFilter = (value) => {
  statusFilter.value = value
  page.value = 1
  loadTickets()
}

const changePage = (newPage) => {
  page.value = newPage
  loadTickets()
}

const updateStatus = async (ticket) => {
  await ticketsCrud.update(ticket.id, { status: ticket.status })
}

const updateNotes = async (ticket) => {
  await ticketsCrud.update(ticket.id, { admin_notes: ticket.admin_notes })
}

const deleteTicket = async (ticket) => {
  await ticketsCrud.destroy(ticket.id)
  tickets.value = tickets.value.filter((t) => t.id !== ticket.id)
}

const formatDate = (value) => new Date(value).toLocaleDateString()

onMounted(loadTickets)
</script>

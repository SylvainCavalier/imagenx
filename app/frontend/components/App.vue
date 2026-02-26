<template>
  <div class="min-h-screen bg-gray-950">
    <Navbar v-if="authStore.isLoggedIn" />
    <router-view />
  </div>
</template>

<script setup>
import Navbar from './Navbar.vue'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
</script>

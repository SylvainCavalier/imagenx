<template>
  <div class="min-h-screen bg-gray-950">
    <Navbar v-if="authStore.isLoggedIn" />
    <PublicHeader v-else />
    <router-view />
  </div>
</template>

<script setup>
import Navbar from './Navbar.vue'
import PublicHeader from './PublicHeader.vue'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
</script>

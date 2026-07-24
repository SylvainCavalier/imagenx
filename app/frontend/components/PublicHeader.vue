<template>
  <nav class="bg-gray-900 border-b border-gray-800">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16">
        <router-link to="/" class="flex items-center">
          <img :src="logo" alt="ImageNX" class="h-7" />
        </router-link>

        <div v-if="route.name === 'Landing'" class="hidden md:flex items-center space-x-6">
          <a href="#how-it-works" class="text-sm text-gray-300 hover:text-white transition-colors">
            {{ t('landing.howItWorks.title') }}
          </a>
          <a href="#features" class="text-sm text-gray-300 hover:text-white transition-colors">
            {{ t('landing.features.title') }}
          </a>
          <a href="#gallery" class="text-sm text-gray-300 hover:text-white transition-colors">
            {{ t('landing.gallery.title') }}
          </a>
        </div>

        <div class="flex items-center space-x-4">
          <div class="flex items-center space-x-1.5">
            <button
              @click="setLocale('fr')"
              :class="locale === 'fr' ? 'opacity-100 ring-2 ring-indigo-500' : 'opacity-40 hover:opacity-75'"
              class="text-lg leading-none rounded transition-opacity"
              title="Français"
              aria-label="Français"
            >
              🇫🇷
            </button>
            <button
              @click="setLocale('en')"
              :class="locale === 'en' ? 'opacity-100 ring-2 ring-indigo-500' : 'opacity-40 hover:opacity-75'"
              class="text-lg leading-none rounded transition-opacity"
              title="English"
              aria-label="English"
            >
              🇬🇧
            </button>
          </div>
          <router-link to="/login" class="text-sm text-gray-300 hover:text-white transition-colors">
            {{ t('auth.signIn') }}
          </router-link>
          <router-link
            to="/register"
            class="text-sm bg-indigo-600 hover:bg-indigo-500 text-white font-medium px-4 py-2 rounded-lg transition-colors"
          >
            {{ t('auth.signUp') }}
          </router-link>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { setLocale } from '../plugins/i18n'
import logo from '../images/logo-text-imagenx-white.png'

const route = useRoute()
const { t, locale } = useI18n()
</script>

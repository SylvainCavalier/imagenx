<template>
  <footer class="border-t border-gray-900">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 flex flex-col gap-6">
      <div class="flex flex-col sm:flex-row items-center justify-between gap-4">
        <div>
          <img :src="logo" alt="ImageNX" class="h-5" />
          <p class="mt-2 text-sm text-gray-500">{{ t('landing.footer.tagline') }}</p>
        </div>
        <div class="flex items-center gap-6 text-sm">
          <router-link to="/login" class="text-gray-400 hover:text-white transition-colors">{{ t('landing.footer.loginLink') }}</router-link>
          <router-link to="/register" class="text-gray-400 hover:text-white transition-colors">{{ t('landing.footer.registerLink') }}</router-link>
        </div>
        <p class="text-sm text-gray-600">{{ t('landing.footer.copyright', { year: currentYear }) }}</p>
      </div>
      <div class="flex flex-wrap items-center justify-center sm:justify-start gap-x-4 gap-y-2 text-sm border-t border-gray-900 pt-6">
        <router-link to="/mentions-legales" class="text-gray-500 hover:text-white transition-colors">{{ t('landing.footer.legalMentions') }}</router-link>
        <span class="text-gray-700">·</span>
        <router-link to="/confidentialite" class="text-gray-500 hover:text-white transition-colors">{{ t('landing.footer.legalPrivacy') }}</router-link>
        <span class="text-gray-700">·</span>
        <router-link to="/cgu-cgv" class="text-gray-500 hover:text-white transition-colors">{{ t('landing.footer.legalTerms') }}</router-link>
      </div>
    </div>
  </footer>
</template>

<script setup>
import { useI18n } from 'vue-i18n'
import logo from '../images/logo-text-imagenx-white.png'

const { t } = useI18n()

const currentYear = new Date().getFullYear()
</script>

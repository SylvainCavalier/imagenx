<template>
  <div class="bg-gray-950">
    <!-- Hero -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-16 pb-20 grid lg:grid-cols-2 gap-12 items-center">
      <div>
        <span class="inline-block text-xs font-medium tracking-wide uppercase text-indigo-400 bg-indigo-500/10 border border-indigo-500/30 rounded-full px-3 py-1">
          {{ t('landing.hero.badge') }}
        </span>
        <h1 class="mt-5 text-4xl sm:text-5xl font-bold text-white leading-tight">
          {{ t('landing.hero.title') }}
        </h1>
        <p class="mt-5 text-lg text-gray-400 max-w-xl">
          {{ t('landing.hero.subtitle') }}
        </p>
        <div class="mt-8 flex flex-wrap items-center gap-4">
          <router-link
            to="/register"
            class="px-6 py-3 bg-indigo-600 hover:bg-indigo-500 text-white font-medium rounded-lg transition-colors"
          >
            {{ t('landing.hero.ctaPrimary') }}
          </router-link>
          <router-link
            to="/login"
            class="px-6 py-3 border border-gray-700 hover:border-gray-500 text-gray-200 font-medium rounded-lg transition-colors"
          >
            {{ t('landing.hero.ctaSecondary') }}
          </router-link>
        </div>
        <p class="mt-4 text-sm text-gray-500">{{ t('landing.hero.creditsNote') }}</p>
      </div>

      <div class="grid grid-cols-2 gap-3">
        <img
          v-for="img in heroPreview"
          :key="img"
          :src="img"
          alt=""
          class="rounded-xl border border-gray-800 shadow-xl object-cover aspect-video"
        />
      </div>
    </section>

    <!-- How it works -->
    <section id="how-it-works" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 border-t border-gray-900">
      <div class="text-center max-w-2xl mx-auto mb-12">
        <h2 class="text-3xl font-bold text-white">{{ t('landing.howItWorks.title') }}</h2>
        <p class="mt-3 text-gray-400">{{ t('landing.howItWorks.subtitle') }}</p>
      </div>
      <div class="grid md:grid-cols-3 gap-6">
        <div class="bg-gray-900 rounded-xl border border-gray-800 p-6">
          <h3 class="text-white font-semibold">{{ t('landing.howItWorks.step1Title') }}</h3>
          <p class="mt-2 text-sm text-gray-400">{{ t('landing.howItWorks.step1Body') }}</p>
        </div>
        <div class="bg-gray-900 rounded-xl border border-gray-800 p-6">
          <h3 class="text-white font-semibold">{{ t('landing.howItWorks.step2Title') }}</h3>
          <p class="mt-2 text-sm text-gray-400">{{ t('landing.howItWorks.step2Body') }}</p>
        </div>
        <div class="bg-gray-900 rounded-xl border border-gray-800 p-6">
          <h3 class="text-white font-semibold">{{ t('landing.howItWorks.step3Title') }}</h3>
          <p class="mt-2 text-sm text-gray-400">{{ t('landing.howItWorks.step3Body') }}</p>
        </div>
      </div>
    </section>

    <!-- Features -->
    <section id="features" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 border-t border-gray-900">
      <h2 class="text-3xl font-bold text-white text-center mb-12">{{ t('landing.features.title') }}</h2>
      <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="feature in features" :key="feature.titleKey" class="bg-gray-900 rounded-xl border border-gray-800 p-6">
          <div class="w-9 h-9 rounded-lg bg-indigo-500/10 flex items-center justify-center text-indigo-400">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" class="w-5 h-5">
              <path stroke-linecap="round" stroke-linejoin="round" :d="feature.path" />
            </svg>
          </div>
          <h3 class="mt-4 text-white font-semibold">{{ t(feature.titleKey) }}</h3>
          <p class="mt-2 text-sm text-gray-400">{{ t(feature.bodyKey) }}</p>
        </div>
      </div>
    </section>

    <!-- Gallery -->
    <section id="gallery" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 border-t border-gray-900">
      <div class="text-center max-w-2xl mx-auto mb-12">
        <h2 class="text-3xl font-bold text-white">{{ t('landing.gallery.title') }}</h2>
        <p class="mt-3 text-gray-400">{{ t('landing.gallery.subtitle') }}</p>
      </div>

      <div class="space-y-10">
        <div>
          <p class="text-sm font-medium text-indigo-400 mb-3">{{ t('landing.gallery.setALabel') }}</p>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <img
              v-for="img in setAImages"
              :key="img"
              :src="img"
              alt=""
              class="rounded-lg border border-gray-800 aspect-video object-cover"
            />
          </div>
        </div>
        <div>
          <p class="text-sm font-medium text-indigo-400 mb-3">{{ t('landing.gallery.setBLabel') }}</p>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <img
              v-for="img in setBImages"
              :key="img"
              :src="img"
              alt=""
              class="rounded-lg border border-gray-800 aspect-square object-cover"
            />
          </div>
        </div>
      </div>
    </section>

    <!-- Pricing / credits teaser -->
    <section class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-20 border-t border-gray-900 text-center">
      <h2 class="text-3xl font-bold text-white">{{ t('landing.pricing.title') }}</h2>
      <p class="mt-3 text-gray-400">{{ t('landing.pricing.body') }}</p>
      <div class="mt-8 inline-block bg-gray-900 rounded-xl border border-gray-800 px-8 py-6">
        <p class="text-2xl font-bold text-white">{{ t('landing.pricing.trialTitle') }}</p>
        <p class="mt-1 text-sm text-gray-400">{{ t('landing.pricing.trialBody') }}</p>
      </div>
      <div class="mt-8">
        <router-link
          to="/register"
          class="px-6 py-3 bg-indigo-600 hover:bg-indigo-500 text-white font-medium rounded-lg transition-colors inline-block"
        >
          {{ t('landing.hero.ctaPrimary') }}
        </router-link>
      </div>
    </section>

    <!-- Footer -->
    <Footer />
  </div>
</template>

<script setup>
import { useI18n } from 'vue-i18n'
import Footer from '../components/Footer.vue'

const { t } = useI18n()

const setAModules = import.meta.glob('../images/gallery/set-a/*.png', { eager: true, import: 'default' })
const setBModules = import.meta.glob('../images/gallery/set-b/*.png', { eager: true, import: 'default' })

const setAImages = Object.values(setAModules)
const setBImages = Object.values(setBModules)
const heroPreview = [...setAImages.slice(0, 2), ...setBImages.slice(0, 2)]

const features = [
  {
    titleKey: 'landing.features.speedTitle',
    bodyKey: 'landing.features.speedBody',
    path: 'M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z'
  },
  {
    titleKey: 'landing.features.coherenceTitle',
    bodyKey: 'landing.features.coherenceBody',
    path: 'M6.429 9.75L2.25 12l4.179 2.25m0-4.5l5.571 3 5.571-3m-11.142 0L2.25 7.5 12 2.25l9.75 5.25-4.179 2.25m0 0L21.75 12l-4.179 2.25m0 0l4.179 2.25L12 21.75 2.25 16.5l4.179-2.25m11.142 0l-5.571 3-5.571-3'
  },
  {
    titleKey: 'landing.features.simpleTitle',
    bodyKey: 'landing.features.simpleBody',
    path: 'M10.5 6h9.75M10.5 6a1.5 1.5 0 11-3 0m3 0a1.5 1.5 0 10-3 0M3.75 6H7.5m3 12h9.75m-9.75 0a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m-3.75 0H7.5m9-6h3.75m-3.75 0a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m-9.75 0h9.75'
  },
  {
    titleKey: 'landing.features.payAsYouGoTitle',
    bodyKey: 'landing.features.payAsYouGoBody',
    path: 'M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a1.5 1.5 0 001.5-1.5V6.75a1.5 1.5 0 00-1.5-1.5h-15a1.5 1.5 0 00-1.5 1.5v10.5a1.5 1.5 0 001.5 1.5z'
  },
  {
    titleKey: 'landing.features.agentsTitle',
    bodyKey: 'landing.features.agentsBody',
    path: 'M17.25 6.75L22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3l-4.5 16.5'
  }
]
</script>

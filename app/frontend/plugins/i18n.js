import { createI18n } from 'vue-i18n'
import fr from '../locales/fr'
import en from '../locales/en'

const STORAGE_KEY = 'imagenx_locale'
const SUPPORTED_LOCALES = ['fr', 'en']

const storedLocale = localStorage.getItem(STORAGE_KEY)
const initialLocale = SUPPORTED_LOCALES.includes(storedLocale) ? storedLocale : 'fr'

const i18n = createI18n({
  legacy: false,
  locale: initialLocale,
  fallbackLocale: 'fr',
  messages: { fr, en }
})

export function setLocale(locale) {
  if (!SUPPORTED_LOCALES.includes(locale)) return
  i18n.global.locale.value = locale
  localStorage.setItem(STORAGE_KEY, locale)
  document.documentElement.setAttribute('lang', locale)
}

document.documentElement.setAttribute('lang', initialLocale)

export default i18n

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from '../router'
import App from '../components/App.vue'
import '../styles/application.css'
import '../plugins/axios'
import i18n from '../plugins/i18n'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.use(i18n)
app.mount('#app')

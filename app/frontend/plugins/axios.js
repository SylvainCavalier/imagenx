import axios from 'axios'

const apiClient = axios.create({
  baseURL: '/api',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  },
  withCredentials: true
})

function getCSRFToken() {
  const token = document.querySelector('meta[name="csrf-token"]')
  return token ? token.getAttribute('content') : null
}

apiClient.interceptors.request.use(
  (config) => {
    const csrfToken = getCSRFToken()
    if (csrfToken) {
      config.headers['X-CSRF-Token'] = csrfToken
    }
    return config
  },
  (error) => Promise.reject(error)
)

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      const isAuthPage = ['/login', '/register'].includes(window.location.pathname)
      if (!isAuthPage) {
        window.location.href = '/login'
      }
    }
    return Promise.reject(error)
  }
)

export { apiClient }
export default apiClient

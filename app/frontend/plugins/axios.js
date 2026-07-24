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
    // /auth/* 401s (verify, login, register, ...) are expected, normal responses that
    // the calling store action already handles inline — never hard-redirect on those,
    // or every anonymous visit to a public page (checkAuth's own verify call) would
    // bounce straight to /login.
    const isAuthEndpoint = error.config?.url?.startsWith('/auth/')
    if (error.response?.status === 401 && !isAuthEndpoint) {
      const publicPaths = ['/', '/login', '/register', '/forgot-password', '/reset-password', '/confirm-email']
      const isPublicPage = publicPaths.includes(window.location.pathname)
      if (!isPublicPage) {
        window.location.href = '/login'
      }
    }
    return Promise.reject(error)
  }
)

export { apiClient }
export default apiClient

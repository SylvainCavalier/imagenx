export default [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../pages/Login.vue'),
    meta: { guest: true }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('../pages/Register.vue'),
    meta: { guest: true }
  },
  {
    path: '/',
    name: 'Dashboard',
    component: () => import('../pages/Dashboard.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/history',
    name: 'History',
    component: () => import('../pages/History.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/my-images',
    name: 'MyImages',
    component: () => import('../pages/MyImages.vue'),
    meta: { requiresAuth: true }
  },
]

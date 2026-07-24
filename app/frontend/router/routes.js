export default [
  {
    path: '/',
    name: 'Landing',
    component: () => import('../pages/Landing.vue'),
  },
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
    path: '/forgot-password',
    name: 'ForgotPassword',
    component: () => import('../pages/ForgotPassword.vue'),
    meta: { guest: true }
  },
  {
    path: '/reset-password',
    name: 'ResetPassword',
    component: () => import('../pages/ResetPassword.vue'),
    meta: { guest: true }
  },
  {
    path: '/confirm-email',
    name: 'ConfirmEmail',
    component: () => import('../pages/ConfirmEmail.vue'),
  },
  {
    path: '/app',
    name: 'Dashboard',
    component: () => import('../pages/Dashboard.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/app/history',
    name: 'History',
    component: () => import('../pages/History.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/app/my-images',
    name: 'MyImages',
    component: () => import('../pages/MyImages.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/app/account',
    name: 'Account',
    component: () => import('../pages/Account.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('../pages/NotFound.vue'),
  },
]

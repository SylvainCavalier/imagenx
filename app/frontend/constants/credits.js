// Mirrors User::GENERATION_COST_PER_IMAGE — used to turn credit amounts into the
// "how many images is that?" figure shown across the navbar, the top-up modal and
// the account page.
export const CREDITS_PER_IMAGE = 8

// Keys must match Api::CheckoutSessionsController::TOPUP_PACKS and the Stripe
// Price lookup_keys of the live catalog.
export const TOPUP_PACKS = [
  { key: 'topup_300', price: '3€', credits: 300 },
  { key: 'topup_500', price: '5€', credits: 500 },
  { key: 'topup_1000', price: '10€', credits: 1000 },
  { key: 'topup_2000', price: '20€', credits: 2000 },
]

export const SUBSCRIPTION_CREDITS = 600

export const imagesFor = (credits) => Math.floor(credits / CREDITS_PER_IMAGE)

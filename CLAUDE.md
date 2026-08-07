# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rails 8.0 monolith with Vue 3 SPA frontend. Single domain architecture where Vue handles all UI and Rails serves as API backend. Uses Vite for frontend build tooling.

## Common Commands

### Development
```bash
# Start both Rails and Vite dev servers (recommended)
foreman start -f Procfile.dev

# Or run separately:
bin/rails s           # Rails server on port 3020 (see PORT in .env)
bin/vite dev          # Vite dev server with HMR

# Demo mode (no database required)
SKIP_DB_CHECKS=true rails server
```

Rails runs on **port 3020** here (not the Rails default 3000), set via `PORT=3020` in `.env` (gitignored, local only) — this lets the server stay up permanently in the background while working on other projects that default to 3000, without a port clash. `bin/rails s` / `foreman start -f Procfile.dev` pick it up automatically via `dotenv-rails`.

### Dependencies
```bash
bundle install        # Ruby gems
npm install          # Node packages
```

### Database
```bash
rails db:create db:migrate
bundle exec annotaterb models  # Update model annotations after migrations (gem is annotaterb, there is no `annotate` binary)
```

### Testing
```bash
rails test                          # Run all tests
rails test test/path/to/file.rb    # Run single test file
rails test test/path/to/file.rb:42 # Run specific test at line
```

### Linting
```bash
npm run lint              # ESLint for Vue/JS
npm run lint:fix          # ESLint with auto-fix
bundle exec rubocop       # RuboCop for Ruby
bundle exec rubocop -a    # RuboCop with auto-fix
```

### Security Audits
```bash
bundle exec brakeman        # Static security analysis
bundle exec bundler-audit  # Gem vulnerability check
```

## Additional Documentation

- `.knowledge/history.md` — chronological session log (most recent first), updated via `/historyupdate`.
- `.knowledge/marketing.md` — product pitch / value-prop reference for landing page and marketing copy.

## Product Overview (What This App Does)

ImageNX is an AI image generation SaaS. Users write text prompts, generate images via an external AI provider, and organize the results into a personal library.

### Core features

- **Auth**: email/password via Devise, session-based (`Api::AuthController` — login/register/logout/verify/confirm/resend_confirmation/forgot_password/reset_password). Email confirmation (`:confirmable`) is required before login/API access — gated explicitly in `Api::BaseController#authenticate_user!` since Devise routes are skipped and Warden's own hooks never run. Password reset (`:recoverable`) is fully wired. Sweego SMTP relay in production (`config/environments/production.rb`, `SMTP_*` env vars); `letter_opener` in dev.
  - **Sending domain**: the domain configured (and DNS-verified) on Sweego is **`mail.imagenx.fr`**, NOT the apex `imagenx.fr`. Every outgoing `From` must be on that subdomain (`MAILER_FROM=noreply@mail.imagenx.fr` on Heroku; same fallback in `ApplicationMailer` and `config/initializers/devise.rb`). Any other sender is rejected by the relay with `550 Unknow domain`.
  - Devise notifications go out via `deliver_later` (`User#send_devise_notification`) so a relay outage can't 500 the signup request after the user row is already committed; `MailDeliveryJob` retries transient SMTP failures.
  - **Credits**: new users get `User::TRIAL_CREDITS` (80) on signup (`credits_balance` column, granted via `after_create`), i.e. 10 free images at `User::GENERATION_COST_PER_IMAGE` (8 credits each). Every movement is written to the `CreditTransaction` ledger (`trial_grant`, `generation_debit`, `generation_refund`, `topup_purchase`, `subscription_grant`, `admin_adjustment`). Debits go through `User.debit_credits` — a single conditional `UPDATE` that only succeeds if the balance covers the amount, so there is no read-then-write race; grants/refunds go through `User#add_credits!` (row lock + ledger entry). A batch is debited **up front** for all its items in `Api::GenerationBatchesController#create`; each item that fails is refunded individually by `GenerateImageJob#refund_credits!`. Paid top-ups and subscription grants arrive via Stripe webhooks (`WebhooksController`, idempotency through `StripeEvent`). See `.knowledge/marketing.md`.
  - **Programmatic access**: `/api/*` also accepts `Authorization: Bearer <token>` (`User#api_token`, `has_secure_token`), for scripts/agents that can't hold a session cookie/CSRF token. CSRF is skipped only when a Bearer token is present (`Api::BaseController#api_token_request?`); the cookie+CSRF flow used by the SPA is untouched. Manage the token with `bin/rails "api_token:show[email]"` / `"api_token:regenerate[email]"` (`lib/tasks/api_token.rake`). Used by the `imagenx-generate` Claude skill (`~/.claude/skills/imagenx-generate/`) to let other local projects trigger image generation.
- **Landing page** (`Landing.vue`, public, at `/`): marketing page for logged-out visitors — hero, how-it-works, features, example gallery, credits teaser. The authenticated app lives under `/app` (`Dashboard.vue` at `/app`, plus `/app/history`, `/app/my-images`); a logged-in user hitting `/` is redirected to `/app` by the router guard.
- **Image generation** (`Dashboard.vue`): user enters a main prompt (style/mood/format), an aspect ratio, optional style options, and one or more per-image sub-prompts. Submitting creates a `GenerationBatch` with one `GenerationItem` per sub-prompt.
  - Each `GenerationItem` is processed by `GenerateImageJob` (GoodJob). Enqueueing goes through `BatchDispatcher`, which staggers jobs 12s apart to respect provider rate limits. The full prompt sent to the provider concatenates style options + main prompt + item prompt.
  - `ImageGenerator` handles the Replicate HTTP calls (create a prediction, retry on HTTP 429 up to 5x, then poll every 2s up to 120s). The model itself is pluggable: `ImageModels::FluxPro` (`black-forest-labs/flux-1.1-pro`, the default) and `ImageModels::NanoBanana` (`google/nano-banana`) each own their endpoint and input shape. Both force `output_format: 'png'`.
  - Item status flow: `pending` → `processing` → `completed`/`failed`. The batch's own status is derived from its items (`GenerationBatch#update_status!`).
  - **Coherence modes** (`generation_batches.coherence_mode`, `GenerationBatch::COHERENCE_MODES`, exposed as a select in the form): `none` (default, flux, only the shared main prompt ties the images together), `style` (the first image guides the artistic style, each scene stays its own) and `variation` (the first image *is* the scene, the others only alter it). Both coherent modes run the whole batch — reference image included — through nano-banana, and pass the reference's output URL as `image_input`.
    - The two modes differ only by what `GenerateImageJob#compose_prompt` prepends (`COHERENCE_INSTRUCTIONS`). nano-banana is an *editing* model: left to itself it repaints the reference, so `style` has to forbid reusing the composition explicitly. In `variation` the follower prompt is deliberately reduced to the item prompt alone — repeating the main prompt reads as "generate that whole scene again" and fights the edit.
    - A coherent batch is no longer a flat fan-out: only the reference item is enqueued at creation, and `GenerateImageJob` enqueues the followers itself once it succeeds. Settlement happens in `ensure`, so a dispatch error can never mark a generated-and-billed image as failed. If the reference fails, `fail_followers!` fails and refunds the remaining items, which were debited upfront — guarded by a conditional `UPDATE`, so a replay cannot refund twice.
    - Cost is unchanged whatever the mode: N images, N calls, N × 8 credits. The mode is forced back to `none` for single-image batches, and is stored on `PromptPreset` too.
- **Prompt presets**: users can save/reuse a named preset (prompt text + aspect ratio + style options) to prefill the generation form.
- **Generation history** (`History.vue`): lists past batches with thumbnails and status; click through to see all items of a batch in a modal.
- **Personal image library** (`MyImages.vue`): generated images can be saved into `ImageFolder`s. Saving triggers `DownloadImageJob`, which fetches the image from its temporary `source_url` and attaches it permanently via Active Storage (so it survives the provider's URL expiring). Folders support rename/delete; images support rename (prompt) and delete. Both generation items and saved images can be downloaded as PNG.

### Data model

`User` → `GenerationBatch` → `GenerationItem` (one prompt/image generation attempt each)
`User` → `PromptPreset` (reusable prompt template, incl. the coherence mode)
`User` → `ImageFolder` → `SavedImage` (permanently kept image, Active Storage attachment)
`User` → `CreditTransaction` (credits ledger, polymorphic `source` → batch or item)
`User` → `SupportTicket`

## Architecture

### Request Flow
1. All HTML requests route to `SpaController#index` via catch-all route (`config/routes.rb:10`)
2. Vue Router handles client-side navigation
3. API endpoints under `/api` namespace return JSON
4. CSRF token from Rails meta tag attached to all Axios requests (`app/frontend/plugins/axios.js`)

### Frontend Structure (`app/frontend/`)
- **entrypoints/application.js** - Vue app bootstrap with Pinia and Router
- **plugins/axios.js** - Axios instance with CSRF and auth token handling
- **stores/** - Pinia stores (auth, api, counter)
- **composables/** - Reusable Vue composition functions (useApi, useAuth)
- **router/** - Vue Router config and route definitions
- **pages/** - Page components
- **components/** - Reusable Vue components

### Backend Patterns
- `ApplicationController` includes Pundit (authorization) and Pagy (pagination)
- Devise pre-configured but not generated by default
- Background jobs via GoodJob (PostgreSQL-based, no Redis)
- Rate limiting configured in `config/initializers/rack_attack.rb`
- Security headers in `config/initializers/secure_headers.rb`

### Pagy 43 Usage
```ruby
# In controllers (include Pagy::Method already in ApplicationController)
@pagy, @records = pagy(:offset, Model.all)
@pagy, @records = pagy(:keyset, Model.order(:id).all)  # faster for large datasets

# In views
@pagy.series_nav              # default styling
@pagy.series_nav(:bootstrap)  # Bootstrap styling
```

## Key Dependencies

**Backend:** Rails 8.0, PostgreSQL, Devise, Pundit, GoodJob, Pagy 43, PaperTrail
**Frontend:** Vue 3.5, Vite 5, Pinia, Vue Router, Axios, Tailwind CSS 3.4
**Requires:** Ruby 3.3.5, Node 20.x

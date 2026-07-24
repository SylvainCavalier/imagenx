# Historique – ImageNX

Journal de bord des sessions de travail, par ordre antéchronologique (le plus récent en haut).
Les nouvelles entrées sont ajoutées par la commande `/historyupdate` en fin de session.

---

### 2026-07-24 — Landing page et système de comptes production-ready
- [feat] Landing page publique à `/` (hero, comment ça marche, bénéfices, galerie d'exemples, teaser crédits, footer) — l'app authentifiée est déplacée sous `/app/*`
- [feat] Confirmation d'email obligatoire avant connexion et accès API (Devise `:confirmable`, gate explicite dans `Api::BaseController` puisque les routes Devise sont désactivées et Warden ne bloque rien automatiquement)
- [feat] Flow mot de passe oublié complet (demande + réinitialisation par email, pages dédiées `ForgotPassword`/`ResetPassword`)
- [feat] Crédits d'essai gratuits à l'inscription (`User::TRIAL_CREDITS` = 20, affichés dans la navbar) — solde minimal seulement, sans logique de débit ni paiement pour l'instant
- [db] Migrations : colonnes confirmable (`confirmation_token`, `confirmed_at`, `confirmation_sent_at`, `unconfirmed_email`) et `credits_balance` sur `users`
- [api] Mailer Sweego en SMTP pour la production (`config.action_mailer.smtp_settings`, variables `SMTP_*`), sans crash au boot tant qu'elles ne sont pas encore renseignées
- [security] Anti-spam sur l'inscription via `invisible_captcha` (honeypot, timestamp désactivé car pas de formulaire server-rendered)
- [security] Règles Rack::Attack corrigées pour cibler les vraies routes `/api/auth/*` — les anciennes règles visaient des routes Devise désactivées (`/users/sign_in`...) et ne s'appliquaient donc jamais
- [fix] L'intercepteur axios redirigeait en dur vers `/login` sur toute réponse 401, y compris le 401 normal du check d'auth anonyme (`checkAuth`) — cassait l'affichage de la landing page pour les visiteurs déconnectés
- [ui] Wordmark recoloré en blanc pour le fond sombre (navbar + landing), favicon et image de partage social régénérés à partir des visuels fournis par Sylvain
- [chore] 8 images d'exemple générées via le skill `imagenx-generate` (2 séries de 4, styles différents) pour la galerie de la landing page
- [chore] Nouveau fichier `.knowledge/marketing.md` (argumentaire produit et pistes de communication), référencé dans `CLAUDE.md`

### 2026-07-23 — Interface bilingue français/anglais
- [feat] Sélecteur de langue dans la navbar (drapeaux FR/EN), français par défaut, choix mémorisé entre les sessions
- [feat] Traduction complète de l'interface Vue (navbar, dashboard, historique, bibliothèque d'images, login/register, 404) via vue-i18n, avec gestion du pluriel et des dates selon la langue active

### 2026-07-23 — Accès API pour agents IA locaux
- [feat] Authentification par token personnel (Bearer) sur l'API, en plus de la session SPA — pensée pour des scripts/agents locaux qui ne peuvent pas porter de cookie de session
- [chore] Tâche rake pour afficher/régénérer le token API (`api_token:show` / `api_token:regenerate`)
- [feat] Nouveau skill Claude global `imagenx-generate` : déclenche des générations d'images (seules ou groupées) depuis n'importe quel autre projet, avec téléchargement local des résultats

### 2026-02-27 — MVP génération d'images (version 1)
- [feat] Authentification email/mot de passe (Devise) avec pages login/register
- [feat] Génération d'images IA par prompt, en solo ou en batch groupé, avec suivi de statut par image
- [api] Intégration Replicate (flux-1.1-pro) pour la génération, avec retry/backoff sur rate-limit
- [feat] Presets de prompts réutilisables (style, ratio, options)
- [feat] Bibliothèque personnelle d'images (dossiers + sauvegarde permanente via Active Storage)
- [feat] Historique des générations passées

### 2026-01-13 — Montée de version Rails
- [chore] Upgrade Rails et dépendances associées

### 2025-10-04 — Passage à npm
- [chore] Changement du gestionnaire de paquets JS (yarn → npm)

### 2025-10-01 — Mise à jour des dépendances front
- [chore] Mise à jour des versions Vite, Vue et Tailwind

### 2025-09-07 — Boilerplate étoffé
- [infra] Complément du boilerplate SPA (structure de base plus complète)

### 2025-05-28 — Démarrage du projet
- [infra] Bootstrap du projet depuis le boilerplate Rails + Vue + Tailwind (SPA)

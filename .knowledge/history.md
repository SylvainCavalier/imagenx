# Historique – ImageNX

Journal de bord des sessions de travail, par ordre antéchronologique (le plus récent en haut).
Les nouvelles entrées sont ajoutées par la commande `/historyupdate` en fin de session.

---

### 2026-07-25 — Dashboard admin et système de support
- [feat] Dashboard admin à `/admin`, réservé au compte administrateur (nouvelle colonne `admin` sur `users`, autorisation par simple booléen sans Pundit) : onglets Statistiques, Utilisateurs, Support
- [feat] Onglet Statistiques : utilisateurs gratuits/payants, connexions totales et récentes, images générées, moyenne d'images par génération/par utilisateur, moyenne d'images sauvegardées par dossier, top utilisateurs actifs
- [feat] Onglet Utilisateurs : liste paginée (première vraie utilisation de Pagy dans le projet), création manuelle d'un compte, édition des infos de base (nom, email, crédits, flag admin)
- [feat] Système de tickets de support basique : page client `/support` (3 thèmes — support technique, facturation et abonnement, boîte à idées) et onglet admin de triage (filtre par statut, notes internes, suppression) ; pas d'historique de suivi côté client, formulaire de soumission uniquement
- [api] Notification email à la création d'un ticket (mailer dédié, `reply_to` = email du client, adresse de destination configurable via `SUPPORT_EMAIL`)
- [db] Migrations : colonne `admin` sur `users`, colonnes Devise `:trackable` (suivi des connexions), nouvelle table `support_tickets`
- [chore] Compte admin seedé de façon idempotente (`mail@sylvaincavalier.com` / `AdminPasswordToChange`, à changer)

### 2026-07-24 — Intégration Stripe : crédits payants et abonnement
- [feat] Système de recharge de crédits via Stripe Checkout : 4 paliers ponctuels (3€/5€/10€/20€) et abonnement à 5€/mois (600 crédits, bonus incitatif vs recharge ponctuelle) ; gestion de l'abonnement (résiliation, moyen de paiement, factures) déléguée au Stripe Customer Portal
- [feat] Page "Mon compte" (`/app/account`) : profil (nom, email, mot de passe), solde et recharge de crédits, statut d'abonnement, historique des mouvements de crédits
- [improve] Première logique de débit de crédits à la génération d'images (jusqu'ici gratuite et illimitée) : coût fixe de 8 crédits/image (~2x le coût réel de l'appel Replicate), débit atomique protégé contre les doubles soumissions concurrentes, remboursement automatique par image en cas d'échec de génération
- [improve] Crédits d'essai à l'inscription relevés de 20 à 80 (~10 images), pour couvrir un vrai test de la génération groupée
- [api] Intégration Stripe complète : webhooks (`checkout.session.completed`, `invoice.payment_succeeded`, `customer.subscription.updated/.deleted`) avec idempotence garantie en base, endpoint dédié hors authentification SPA
- [db] Nouvelles tables `credit_transactions` (ledger d'audit de tous les mouvements de crédits) et `stripe_events` (déduplication des webhooks), nouvelles colonnes de facturation sur `users` (nom, identifiants Stripe, statut d'abonnement)
- [security] Débit de crédits testé sous accès concurrent réel (plusieurs requêtes simultanées ne peuvent jamais faire passer le solde en négatif)
- [chore] Suite de tests RSpec remise en état (l'installation était incomplète, aucun test ne pouvait tourner) et complétée avec la couverture du nouveau système de facturation
- [chore] Tâches rake `stripe:setup` (création idempotente du catalogue Stripe) et `credits:backfill_ledger` (réconciliation du ledger pour les comptes existants)

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

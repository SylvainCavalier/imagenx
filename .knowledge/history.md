# Historique – ImageNX

Journal de bord des sessions de travail, par ordre antéchronologique (le plus récent en haut).
Les nouvelles entrées sont ajoutées par la commande `/historyupdate` en fin de session.

---

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

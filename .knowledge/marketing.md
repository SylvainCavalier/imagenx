# Marketing – ImageNX

Argumentaire produit et pistes de communication. Sert de référence durable pour la landing page,
les emails, et toute future copie marketing — à mettre à jour si le positionnement évolue.

---

## Principe du service

ImageNX est une plateforme SaaS qui génère plusieurs images IA d'un coup, à partir :
- d'un **prompt principal** (style, ambiance, éclairage, format) qui s'applique à toutes les images du lot ;
- d'un **prompt particulier** pour chaque image individuelle (son sujet propre).

Ce mécanisme permet de générer sans effort plusieurs images cohérentes en une seule fois, au lieu
de lancer chaque génération une par une avec le risque de dérive de style entre elles.

## Arguments de vente

- **Rapidité** : la génération groupée évite de relancer manuellement chaque image une par une.
- **Cohérence** : le prompt principal partagé garantit un style homogène sur tout le lot, utile
  quand les images doivent aller ensemble (série, storyboard, déclinaisons d'un même univers).
- **Accessibilité** : le prompt principal peut être composé via des menus déroulants simples
  (format, éclairage, style graphique, ambiance...) plutôt qu'en tapant du jargon technique
  ("ambient light", "3D cel shading"...) — pensé pour des utilisateurs qui ne sont pas des
  prompt engineers spécialistes de l'image.
- **Paiement à l'usage** : pas d'abonnement. Système de crédits/tokens à recharger, on ne paie
  que ce qu'on utilise.
- **Connexion pour profils techniques** : pour les utilisateurs de Claude Code / Claude Desktop /
  autres agents IA, une API avec authentification par token (`User#api_token`, Bearer) permet de
  brancher ses agents directement sur ImageNX. Un skill Claude dédié (`imagenx-generate`) est
  fourni pour se connecter facilement et indiquer à l'agent quoi générer — **fonctionnalité déjà
  réelle aujourd'hui**, pas une promesse.
- **Essai gratuit** : crédits offerts à la création du compte, sans carte bancaire
  (`User::TRIAL_CREDITS`, 80 crédits au lancement — l'équivalent d'une dizaine d'images),
  pour tester le service sans engagement, y compris la génération groupée et la sauvegarde
  d'images.
- **Rechargement de crédits** : 4 paliers ponctuels (3€/5€/10€/20€) via Stripe Checkout,
  au tarif fixe de 8 crédits par image générée (0,08€, environ 2x le coût réel de l'appel
  API Replicate). Le nombre de crédits décrémenté à chaque génération est fixe et visible,
  peu importe les variations de coût réel côté fournisseur.
- **Abonnement optionnel** : 5€/mois pour 600 crédits (bonus par rapport à une recharge
  ponctuelle de même montant), sans quitter l'esprit paiement à l'usage — l'abonnement
  alimente le même solde de crédits, qui ne périme jamais et ne dépend pas d'un
  engagement contractuel au-delà du mois en cours. Gestion (résiliation, moyen de
  paiement, factures) déléguée au Stripe Customer Portal.

## État d'implémentation (2026-07-24)

- Crédits, paiement à l'usage et abonnement : **entièrement implémentés** (modèle `User`,
  ledger `CreditTransaction`, webhooks Stripe, page "Mon compte"). Reste à faire côté
  Sylvain avant mise en prod : lancer `rails stripe:setup` pour créer le catalogue Stripe
  (produits/prix), enregistrer l'endpoint webhook une fois le domaine déployé, et confirmer
  le passage des clés live/test selon le contexte.
- Connexion agents IA (API + skill) : déjà fonctionnelle, utilisée en interne par Sylvain.
- Landing page publique : construite en juillet 2026, ton sobre et élégant sur fond sombre,
  reprenant la palette existante de l'app (gris foncé + accent indigo) pour que la page ressemble
  à un aperçu réel du produit plutôt qu'à un site marketing déconnecté.

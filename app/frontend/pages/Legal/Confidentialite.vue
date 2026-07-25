<template>
  <div class="bg-gray-950">
    <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
      <router-link to="/" class="text-sm text-indigo-400 hover:text-indigo-300 transition-colors">&larr; Retour à l'accueil</router-link>

      <h1 class="mt-6 text-3xl font-bold text-white">Politique de confidentialité</h1>
      <p class="mt-2 text-sm text-gray-500">Dernière mise à jour : 25 juillet 2026</p>

      <p class="mt-8 text-gray-400 leading-relaxed">
        La présente politique décrit la manière dont ImageNX traite les données à caractère personnel
        de ses utilisateurs, conformément au Règlement (UE) 2016/679 (RGPD) et à la loi
        « Informatique et Libertés » n° 78-17 du 6 janvier 1978 modifiée.
      </p>

      <h2 class="text-xl font-semibold text-white mt-10">1. Responsable du traitement</h2>
      <div class="mt-3 text-gray-400 leading-relaxed space-y-1">
        <p>Le responsable du traitement est SBC Labs, entreprise individuelle de Sylvain Bertrand-Cavalier.</p>
        <p>Siège : 114 rue Marceau, 93100 Montreuil, France</p>
        <p>Contact : <a href="mailto:mail@sylvaincavalier.com" class="text-indigo-400 hover:text-indigo-300 transition-colors">mail@sylvaincavalier.com</a></p>
      </div>

      <h2 class="text-xl font-semibold text-white mt-10">2. Données collectées</h2>
      <p class="mt-3 text-gray-400 leading-relaxed">Dans le cadre de l'utilisation du service, nous collectons :</p>
      <ul class="mt-3 text-gray-400 leading-relaxed list-disc list-inside space-y-2">
        <li><span class="text-gray-300">Données de compte</span> : adresse e-mail, mot de passe (stocké sous forme chiffrée / haché), nom d'affichage éventuel, état de confirmation du compte.</li>
        <li><span class="text-gray-300">Données de génération</span> : prompts saisis (prompt principal, prompts particuliers, options de style), paramètres de génération, images générées et images sauvegardées dans votre bibliothèque.</li>
        <li><span class="text-gray-300">Données de facturation</span> : historique des crédits, transactions et abonnement. Les données de paiement (carte bancaire) sont traitées directement par Stripe et ne sont jamais stockées sur nos serveurs.</li>
        <li><span class="text-gray-300">Données techniques</span> : jeton d'accès API (pour l'accès programmatique), données de session, journaux techniques et d'audit nécessaires au fonctionnement et à la sécurité du service.</li>
      </ul>

      <h2 class="text-xl font-semibold text-white mt-10">3. Finalités et bases légales</h2>
      <ul class="mt-3 text-gray-400 leading-relaxed list-disc list-inside space-y-2">
        <li><span class="text-gray-300">Fourniture du service</span> (création de compte, génération et gestion des images) &mdash; exécution du contrat (art. 6.1.b RGPD).</li>
        <li><span class="text-gray-300">Gestion des paiements et des crédits</span> &mdash; exécution du contrat et respect d'obligations légales comptables (art. 6.1.b et 6.1.c RGPD).</li>
        <li><span class="text-gray-300">Sécurité, prévention de la fraude et des abus</span> &mdash; intérêt légitime (art. 6.1.f RGPD).</li>
        <li><span class="text-gray-300">Envoi d'e-mails transactionnels</span> (confirmation de compte, réinitialisation de mot de passe) &mdash; exécution du contrat (art. 6.1.b RGPD).</li>
      </ul>

      <h2 class="text-xl font-semibold text-white mt-10">4. Destinataires et sous-traitants</h2>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Vos données sont accessibles à l'éditeur et à ses sous-traitants techniques, strictement dans
        la mesure nécessaire à la fourniture du service :
      </p>
      <ul class="mt-3 text-gray-400 leading-relaxed list-disc list-inside space-y-2">
        <li><span class="text-gray-300">Replicate, Inc.</span> (États-Unis) &mdash; génération des images à partir de vos prompts (modèle flux-1.1-pro).</li>
        <li><span class="text-gray-300">Stripe</span> (Stripe Payments Europe, Ltd. et Stripe, Inc.) &mdash; traitement des paiements, gestion de l'abonnement et du portail client.</li>
        <li><span class="text-gray-300">Sweego</span> &mdash; acheminement des e-mails transactionnels (relais SMTP).</li>
        <li><span class="text-gray-300">Heroku, Inc. / Salesforce, Inc.</span> (États-Unis) &mdash; hébergement de l'application et de la base de données.</li>
      </ul>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Nous ne vendons ni ne louons vos données personnelles à des tiers.
      </p>

      <h2 class="text-xl font-semibold text-white mt-10">5. Transferts hors de l'Union européenne</h2>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Certains de nos sous-traitants (notamment Replicate, Heroku/Salesforce et Stripe pour sa
        composante américaine) sont situés aux États-Unis. Ces transferts sont encadrés par des
        garanties appropriées au sens du RGPD, telles que les clauses contractuelles types de la
        Commission européenne et, le cas échéant, la certification au titre du Data Privacy Framework
        (DPF) UE&ndash;États-Unis.
      </p>

      <h2 class="text-xl font-semibold text-white mt-10">6. Durée de conservation</h2>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Les données de compte et de génération sont conservées tant que votre compte est actif. Après
        suppression du compte, elles sont effacées ou anonymisées, sous réserve des durées de
        conservation légales applicables (notamment en matière comptable et fiscale, généralement
        10 ans pour les pièces justificatives). Les journaux techniques sont conservés pour une durée
        limitée à des fins de sécurité.
      </p>

      <h2 class="text-xl font-semibold text-white mt-10">7. Cookies</h2>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Le site utilise uniquement des cookies strictement nécessaires à son fonctionnement : cookie
        de session (authentification) et jeton de protection CSRF. Ces cookies ne nécessitent pas de
        consentement préalable. Le site n'utilise pas de cookies publicitaires ni de traceurs de
        mesure d'audience à des fins marketing.
      </p>

      <h2 class="text-xl font-semibold text-white mt-10">8. Vos droits</h2>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Conformément à la réglementation, vous disposez des droits d'accès, de rectification,
        d'effacement, de limitation, d'opposition et de portabilité de vos données, ainsi que du droit
        de définir des directives relatives à leur sort après votre décès. Vous pouvez exercer ces
        droits en écrivant à
        <a href="mailto:mail@sylvaincavalier.com" class="text-indigo-400 hover:text-indigo-300 transition-colors">mail@sylvaincavalier.com</a>.
      </p>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Vous disposez également du droit d'introduire une réclamation auprès de la Commission
        nationale de l'informatique et des libertés (CNIL), 3 place de Fontenoy, TSA 80715, 75334
        Paris Cedex 07 &mdash;
        <a href="https://www.cnil.fr" target="_blank" rel="noopener noreferrer" class="text-indigo-400 hover:text-indigo-300 transition-colors">www.cnil.fr</a>.
      </p>

      <h2 class="text-xl font-semibold text-white mt-10">9. Sécurité</h2>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Nous mettons en œuvre des mesures techniques et organisationnelles appropriées pour protéger
        vos données (chiffrement des mots de passe, connexions sécurisées HTTPS, contrôle des accès).
        Aucune transmission de données sur Internet ne peut toutefois être garantie totalement sécurisée.
      </p>

      <h2 class="text-xl font-semibold text-white mt-10">10. Modifications</h2>
      <p class="mt-3 text-gray-400 leading-relaxed">
        La présente politique peut être mise à jour à tout moment. La date de dernière mise à jour
        figure en haut de cette page. Nous vous invitons à la consulter régulièrement.
      </p>
    </div>

    <Footer />
  </div>
</template>

<script setup>
import Footer from '../../components/Footer.vue'
</script>

<template>
  <div class="bg-gray-950">
    <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
      <router-link to="/" class="text-sm text-indigo-400 hover:text-indigo-300 transition-colors">&larr; Retour à l'accueil</router-link>

      <h1 class="mt-6 text-3xl font-bold text-white">Conditions générales d'utilisation et de vente</h1>
      <p class="mt-2 text-sm text-gray-500">Dernière mise à jour : 25 juillet 2026</p>

      <p class="mt-8 text-gray-400 leading-relaxed">
        Les présentes conditions générales d'utilisation (CGU) et conditions générales de vente (CGV)
        régissent l'accès et l'usage du service ImageNX, édité par SBC Labs, entreprise individuelle
        de Sylvain Bertrand-Cavalier (ci-après « l'Éditeur »). Toute inscription et toute utilisation
        du service impliquent l'acceptation pleine et entière des présentes conditions.
      </p>

      <!-- ============ CGU ============ -->
      <h2 class="text-2xl font-bold text-white mt-12">Conditions générales d'utilisation</h2>

      <h3 class="text-xl font-semibold text-white mt-8">1. Objet du service</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        ImageNX est un service en ligne de génération d'images par intelligence artificielle. À partir
        d'un prompt principal et de prompts particuliers, l'utilisateur génère un ou plusieurs visuels,
        qu'il peut organiser et conserver dans une bibliothèque personnelle. La génération s'appuie sur
        des modèles fournis par des prestataires tiers (notamment Replicate).
      </p>

      <h3 class="text-xl font-semibold text-white mt-8">2. Compte utilisateur</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        L'accès au service nécessite la création d'un compte au moyen d'une adresse e-mail valide et
        d'un mot de passe. La confirmation de l'adresse e-mail est requise avant tout accès au service.
        L'utilisateur est responsable de la confidentialité de ses identifiants et de son jeton d'accès
        API, ainsi que de toute activité effectuée depuis son compte. Toute utilisation frauduleuse
        doit être signalée sans délai à l'Éditeur.
      </p>

      <h3 class="text-xl font-semibold text-white mt-8">3. Usage acceptable</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">L'utilisateur s'engage à ne pas utiliser le service pour générer, diffuser ou stocker des contenus :</p>
      <ul class="mt-3 text-gray-400 leading-relaxed list-disc list-inside space-y-2">
        <li>illicites, diffamatoires, haineux, violents ou incitant à la haine ou à la discrimination ;</li>
        <li>à caractère pédopornographique ou représentant des mineurs de manière inappropriée ;</li>
        <li>portant atteinte aux droits de tiers (droit à l'image, propriété intellectuelle, vie privée), notamment la génération de contenus trompeurs (« deepfakes ») visant des personnes réelles ;</li>
        <li>contraires aux conditions d'utilisation des fournisseurs d'IA tiers.</li>
      </ul>
      <p class="mt-3 text-gray-400 leading-relaxed">
        En cas de manquement, l'Éditeur se réserve le droit de suspendre ou de résilier le compte, sans
        préavis ni remboursement des crédits restants.
      </p>

      <h3 class="text-xl font-semibold text-white mt-8">4. Propriété des contenus générés</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Dans les limites permises par la loi et par les conditions des fournisseurs d'IA, l'utilisateur
        est titulaire des droits d'usage sur les images qu'il génère et demeure seul responsable de leur
        utilisation et de leur conformité à la réglementation applicable. L'utilisateur garantit disposer
        des droits nécessaires sur les éléments qu'il fournit dans ses prompts.
      </p>

      <h3 class="text-xl font-semibold text-white mt-8">5. Responsabilité et absence de garantie sur le résultat</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Le service est fourni « en l'état ». La génération par intelligence artificielle est par nature
        non déterministe : l'Éditeur ne garantit pas que les images produites correspondront précisément
        aux attentes de l'utilisateur, ni qu'elles seront exemptes d'imperfections. L'Éditeur ne saurait
        être tenu responsable des contenus générés à partir des instructions de l'utilisateur, ni des
        interruptions imputables aux prestataires tiers ou à la maintenance du service.
      </p>

      <h3 class="text-xl font-semibold text-white mt-8">6. Disponibilité</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        L'Éditeur s'efforce d'assurer la disponibilité du service 24h/24, mais ne saurait être tenu à
        une obligation de résultat. Le service peut être suspendu temporairement pour maintenance,
        mise à jour ou en raison de contraintes techniques indépendantes de sa volonté.
      </p>

      <!-- ============ CGV ============ -->
      <h2 class="text-2xl font-bold text-white mt-12">Conditions générales de vente</h2>

      <h3 class="text-xl font-semibold text-white mt-8">7. Système de crédits</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        L'utilisation du service repose sur un système de crédits. Chaque image générée consomme un
        nombre fixe de crédits (8 crédits par image), débité du solde de l'utilisateur. Le solde et
        l'historique des transactions sont consultables depuis l'espace « Mon compte ».
      </p>

      <h3 class="text-xl font-semibold text-white mt-8">8. Essai gratuit</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        À la création du compte, l'utilisateur bénéficie de 80 crédits offerts, sans carte bancaire,
        afin de tester le service. Ces crédits offerts ne sont ni rechargeables ni convertibles en
        numéraire.
      </p>

      <h3 class="text-xl font-semibold text-white mt-8">9. Prix et rechargement de crédits</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Les crédits peuvent être rechargés de façon ponctuelle via des paliers de 3 €, 5 €, 10 € ou
        20 € (prix TTC ; TVA non applicable, article 293 B du CGI). Les paiements sont traités de manière
        sécurisée par Stripe. Les crédits achetés sont crédités sur le solde de l'utilisateur après
        confirmation du paiement et ne périment pas.
      </p>

      <h3 class="text-xl font-semibold text-white mt-8">10. Abonnement optionnel</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Un abonnement optionnel de 5 €/mois octroie 600 crédits par mois, crédités sur le même solde.
        L'abonnement est sans engagement au-delà du mois en cours et reconductible mensuellement. La
        gestion de l'abonnement (résiliation, moyen de paiement, factures) s'effectue via le portail
        client Stripe. La résiliation prend effet à la fin de la période en cours ; les crédits déjà
        acquis restent disponibles.
      </p>

      <h3 class="text-xl font-semibold text-white mt-8">11. Droit de rétractation</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Conformément à l'article L.221-28 du Code de la consommation, le droit de rétractation ne peut
        être exercé pour la fourniture d'un contenu numérique non fourni sur un support matériel dont
        l'exécution a commencé avec l'accord préalable exprès du consommateur et renoncement exprès à
        son droit de rétractation. En achetant des crédits et en les utilisant, l'utilisateur demande
        expressément l'exécution immédiate du service et reconnaît perdre son droit de rétractation sur
        les crédits consommés. Les crédits achetés et non encore consommés peuvent faire l'objet d'une
        demande de remboursement dans les 14 jours suivant l'achat, à l'exclusion des crédits déjà
        utilisés.
      </p>

      <h3 class="text-xl font-semibold text-white mt-8">12. Facturation</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Les justificatifs de paiement et factures sont mis à disposition via le portail client Stripe.
        En qualité de micro-entreprise en franchise en base de TVA, l'Éditeur ne facture pas de TVA
        (article 293 B du CGI).
      </p>

      <!-- ============ Dispositions communes ============ -->
      <h2 class="text-2xl font-bold text-white mt-12">Dispositions communes</h2>

      <h3 class="text-xl font-semibold text-white mt-8">13. Données personnelles</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Le traitement des données personnelles est décrit dans la
        <router-link to="/confidentialite" class="text-indigo-400 hover:text-indigo-300 transition-colors">politique de confidentialité</router-link>.
      </p>

      <h3 class="text-xl font-semibold text-white mt-8">14. Réclamations et médiation</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Toute réclamation peut être adressée à
        <a href="mailto:mail@sylvaincavalier.com" class="text-indigo-400 hover:text-indigo-300 transition-colors">mail@sylvaincavalier.com</a>.
        Conformément aux articles L.612-1 et suivants du Code de la consommation, le consommateur peut
        recourir gratuitement à un médiateur de la consommation en vue de la résolution amiable d'un
        litige. Le médiateur compétent est le CM2C (Centre de la Médiation de la Consommation de
        Conciliateurs de justice), 14 rue Saint Jean, 75017 Paris &mdash;
        <a href="https://cm2c.net" target="_blank" rel="noopener noreferrer" class="text-indigo-400 hover:text-indigo-300 transition-colors">cm2c.net</a>.
      </p>

      <h3 class="text-xl font-semibold text-white mt-8">15. Modification des conditions</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        L'Éditeur se réserve le droit de modifier les présentes conditions à tout moment. Les conditions
        applicables sont celles en vigueur au moment de l'utilisation du service. La date de dernière
        mise à jour figure en haut de cette page.
      </p>

      <h3 class="text-xl font-semibold text-white mt-8">16. Droit applicable et juridiction</h3>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Les présentes conditions sont régies par le droit français. À défaut de résolution amiable, tout
        litige sera soumis aux tribunaux français compétents, sous réserve des dispositions protectrices
        applicables aux consommateurs.
      </p>
    </div>

    <Footer />
  </div>
</template>

<script setup>
import Footer from '../../components/Footer.vue'
</script>

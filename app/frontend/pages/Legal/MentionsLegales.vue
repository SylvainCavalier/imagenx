<template>
  <div class="bg-gray-950">
    <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
      <router-link to="/" class="text-sm text-indigo-400 hover:text-indigo-300 transition-colors">&larr; Retour à l'accueil</router-link>

      <h1 class="mt-6 text-3xl font-bold text-white">Mentions légales</h1>
      <p class="mt-2 text-sm text-gray-500">Dernière mise à jour : 25 juillet 2026</p>

      <p class="mt-8 text-gray-400 leading-relaxed">
        Conformément à l'article 6 III de la loi n° 2004-575 du 21 juin 2004 pour la confiance dans
        l'économie numérique (LCEN), il est porté à la connaissance des utilisateurs du site
        <span class="text-gray-300">imagenx.fr</span> les présentes mentions légales.
      </p>

      <h2 class="text-xl font-semibold text-white mt-10">Éditeur du site</h2>
      <div class="mt-3 text-gray-400 leading-relaxed space-y-1">
        <p>Le site ImageNX est édité par :</p>
        <p><span class="text-gray-300">SBC Labs</span>, nom commercial de l'entreprise individuelle de Sylvain Bertrand-Cavalier.</p>
        <p>Entrepreneur individuel : <span class="text-gray-300">Sylvain Cavalier</span></p>
        <p>Forme juridique : entreprise individuelle (micro-entreprise)</p>
        <p>Siège : 114 rue Marceau, 93100 Montreuil, France</p>
        <p>SIREN : 948 848 213 &mdash; SIRET : 948 848 213 00013</p>
        <p>Code APE/NAF : 6201Z (Programmation informatique)</p>
        <p>En qualité de micro-entreprise exerçant une activité de prestation de services, l'éditeur n'est pas immatriculé au Registre du commerce et des sociétés (RCS).</p>
        <p>TVA : TVA non applicable, article 293 B du Code général des impôts (franchise en base).</p>
        <p>Adresse électronique : <a href="mailto:mail@sylvaincavalier.com" class="text-indigo-400 hover:text-indigo-300 transition-colors">mail@sylvaincavalier.com</a></p>
        <p>Téléphone : 06 70 02 37 07</p>
      </div>

      <h2 class="text-xl font-semibold text-white mt-10">Directeur de la publication</h2>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Le directeur de la publication est Sylvain Cavalier, en qualité d'entrepreneur individuel.
      </p>

      <h2 class="text-xl font-semibold text-white mt-10">Hébergement</h2>
      <div class="mt-3 text-gray-400 leading-relaxed space-y-1">
        <p>Le site est hébergé par :</p>
        <p><span class="text-gray-300">Heroku, Inc.</span> (filiale de Salesforce, Inc.)</p>
        <p>415 Mission Street, 3rd Floor, San Francisco, CA 94105, États-Unis</p>
        <p>Site web : <a href="https://www.heroku.com" target="_blank" rel="noopener noreferrer" class="text-indigo-400 hover:text-indigo-300 transition-colors">www.heroku.com</a></p>
      </div>

      <h2 class="text-xl font-semibold text-white mt-10">Propriété intellectuelle</h2>
      <p class="mt-3 text-gray-400 leading-relaxed">
        La structure du site, sa charte graphique, ses textes, son logo ainsi que l'ensemble des
        éléments qui le composent sont la propriété exclusive de SBC Labs, sauf mentions contraires.
        Toute reproduction, représentation, modification ou exploitation, totale ou partielle, sans
        l'autorisation écrite préalable de l'éditeur, est interdite et susceptible de constituer une
        contrefaçon au sens des articles L.335-2 et suivants du Code de la propriété intellectuelle.
      </p>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Les images générées par les utilisateurs via le service leur appartiennent selon les
        conditions précisées dans les
        <router-link to="/cgu-cgv" class="text-indigo-400 hover:text-indigo-300 transition-colors">conditions générales d'utilisation et de vente</router-link>.
      </p>

      <h2 class="text-xl font-semibold text-white mt-10">Responsabilité</h2>
      <p class="mt-3 text-gray-400 leading-relaxed">
        L'éditeur s'efforce d'assurer l'exactitude et la mise à jour des informations diffusées sur
        le site, mais ne peut garantir que celui-ci soit exempt d'erreurs ou d'interruptions. Le
        service repose sur des technologies d'intelligence artificielle fournies par des prestataires
        tiers ; l'éditeur ne saurait être tenu responsable de la nature, de la qualité ou de la
        conformité des contenus générés à partir des instructions fournies par les utilisateurs.
      </p>

      <h2 class="text-xl font-semibold text-white mt-10">Données personnelles</h2>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Le traitement des données personnelles collectées sur le site est détaillé dans la
        <router-link to="/confidentialite" class="text-indigo-400 hover:text-indigo-300 transition-colors">politique de confidentialité</router-link>.
      </p>

      <h2 class="text-xl font-semibold text-white mt-10">Contact</h2>
      <p class="mt-3 text-gray-400 leading-relaxed">
        Pour toute question relative au site ou aux présentes mentions légales, vous pouvez écrire à
        <a href="mailto:mail@sylvaincavalier.com" class="text-indigo-400 hover:text-indigo-300 transition-colors">mail@sylvaincavalier.com</a>.
      </p>
    </div>

    <Footer />
  </div>
</template>

<script setup>
import Footer from '../../components/Footer.vue'
</script>

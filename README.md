# 🌍 Projet DataViz : Impact des Risques Climatiques sur l'Immobilier (Hauts-de-Seine)

**Auteurs :** GAUTRON, GOUSSET, LAFAYE  
**Master 2 ISUP - Datavisualisation**

Ce projet analyse la corrélation entre les prix de l'immobilier et les risques naturels (Retrait-Gonflement des Argiles et Remontée de Nappes Phréatiques) dans le département du 92.

## 🚀 Accès Rapide (Démo en ligne)

L'application est déployée et accessible directement via ce lien :
👉 **[Voir le Dashboard Interactif](https://nathangautron.shinyapps.io/Datavis_GAUTRON_GOUSSET_LAFAYE/)**

---

## ⚠️ Note importante pour l'utilisation

Un bug d'affichage connu (lié à la librairie Leaflet/Flexdashboard) peut faire apparaître les cartes en **gris** lors du changement d'onglet.

✅ **Solution :** Si une carte ne s'affiche pas ou reste grise, **rafraîchissez simplement la page (F5)** ou redimensionnez légèrement la fenêtre de votre navigateur. Cela force le moteur de rendu à redessiner les conteneurs.

---

## 🛠 Installation Locale (Pour lancer le code R)

Si vous souhaitez exécuter le projet localement dans RStudio :

1. **Cloner le dépôt** :
   ```bash
   git clone https://github.com/VOTRE_NOM_UTILISATEUR/NOM_DU_REPO.git
   ```

2. **Ouvrir le projet** :
   Ouvrez le fichier `Projet.Rproj` dans RStudio.

3. **Installer les dépendances** :
   Exécutez la commande suivante dans la console R :
   ```r
   source("dependencies.R")
   ```

4. **Lancer le Dashboard** :
   Ouvrez le fichier `dahsboard_final1.Rmd` et cliquez sur le bouton **"Run Document"** (ou utilisez `rmarkdown::run("dahsboard_final1.Rmd")`).

## 📂 Structure du projet

*   `dahsboard_final1.Rmd` : Le code source principal du dashboard.
*   `communes_scores_92_100pct.rds` : Données pré-calculées des scores de risque (Cache).
*   `data/` : Contient les données géographiques (GeoJSON) et immobilières allégées.
*   `force_data_fix.R` : Script utilisé pour la génération et le nettoyage des données brutes.

---
*Projet réalisé dans le cadre du module de Datavisualisation & Machine Learning - Janvier 2026.*

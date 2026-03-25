# PipelineR 📈

**PipelineR** est un package R conçu pour automatiser l'extraction, la transformation et le chargement (ETL) des données boursières du S&P 500 dans une base de données PostgreSQL.

## 🚀 Fonctionnalités
- **Extraction** : Récupération automatique des tickers S&P 500 depuis la base de données.
- **Yahoo Finance** : Téléchargement des données OHLCV via `tidyquant` avec gestion de lots (batches).
- **Insertion Robuste** : Utilisation de tables temporaires et de la clause `ON CONFLICT` (UPSERT) pour éviter les doublons.
- **Monitoring** : Logging détaillé de chaque étape (durée, statut, nombre de lignes) dans la table `pipeline_logs`.

## 🛠 Configuration

Le package utilise des variables d'environnement pour sécuriser les accès à la base de données. Créez un fichier `.Renviron` à la racine de votre projet :

```env
DB_HOST=votre_hote
DB_NAME=votre_base
DB_USER=votre_utilisateur
DB_PASS=votre_mot_de_passe
DB_PORT=5432

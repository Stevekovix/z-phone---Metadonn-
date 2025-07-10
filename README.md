Reprise du script d'origine

https://github.com/alfaben12/z-phone

# Z-Phone - Changelog Complet

## Version 2.0.0 - Migration vers le Système de Métadonnées

### 🔥 CHANGEMENTS MAJEURS

#### **Système de Métadonnées Téléphone**
- **BREAKING CHANGE** : Migration complète de `citizenid` vers `phone_number`
- **RP Révolutionnaire** : Les données suivent maintenant le téléphone physique
- **Vol de téléphone** = Accès complet aux données (contacts, messages, historique)
- **Téléphones uniques** : Chaque téléphone a son propre numéro et écosystème

### ✅ APPLICATIONS MIGRÉES

#### **📞 Système de Contacts**
- Contacts liés au téléphone physique
- Suppression vérification d'existence des numéros
- Ajout de n'importe quel numéro possible
- Correction bouton "Message" depuis la liste
- Support des contacts inexistants avec avatar par défaut

#### **💬 Système de Messages/Chat**
- Conversations liées au téléphone physique
- Messages envoyés depuis le numéro du téléphone
- Support complet des numéros inexistants
- Suppression de toutes les vérifications d'existence
- Création automatique de conversations

#### **📱 Système d'Appels**
- Historique des appels lié au téléphone
- Appels depuis/vers le numéro du téléphone physique
- Contacts affichés correctement dans l'historique
- Support des numéros non-enregistrés

#### **📧 Système d'Emails**
- Emails liés au numéro de téléphone
- Conservation de l'historique sur le téléphone
- Emails de confirmation bancaire/InetMax

#### **📸 Galerie/Photos**
- Photos sauvegardées sur le téléphone physique
- Galerie personnelle par téléphone
- Suppression sécurisée par téléphone

#### **📢 Système de Publicités**
- Annonces liées au téléphone de l'auteur
- Support des téléphones sans profil utilisateur
- Avatar par défaut pour auteurs inexistants

#### **📰 Système de News**
- Articles liés au téléphone du journaliste
- Création d'articles depuis le téléphone

#### **🛠️ Système de Services**
- Messages de service liés au téléphone
- Résolution par téléphone du technicien
- Historique des demandes par téléphone

#### **🌐 Système InetMax**
- Données internet liées au téléphone
- Historique des achats/consommations
- Emails de confirmation

#### **💰 Système Bancaire**
- Emails de transfert liés au téléphone
- Confirmations de transactions

### 🔧 CORRECTIONS TECHNIQUES

#### **Intégration ox_inventory**
- Correction `GetItemCount` → `Search`
- Support complet des métadonnées
- Vérification d'existence des téléphones
- Génération automatique de numéros uniques

#### **Base de Données**
- Migration de 12 tables principales
- Ajout colonnes `phone_number` partout
- Mise à jour des clés primaires
- Optimisation des index
- Correction des contraintes unique

#### **Scripts Serveur**
- Tous les callbacks utilisent `xCore.GetPhoneItem()`
- Vérification métadonnées avant traitement
- Gestion des erreurs améliorée
- Support téléphones sans profil

### 🎨 AMÉLIORATIONS INTERFACE

#### **Écran de Verrouillage**
- Suppression section "Latest News"
- Interface plus épurée et moderne
- Focus sur heure/date uniquement

### 📋 FICHIERS MODIFIÉS

#### **Core System**
- `server/core/esx.lua` - Intégration ox_inventory
- `client/core/esx.lua` - Support métadonnées
- `server/main.lua` - Callback HasPhone
- `client/main.lua` - Gestion téléphones

#### **Features Server**
- `server/feature/profile.lua` - Profils par téléphone
- `server/feature/contact.lua` - Contacts par téléphone
- `server/feature/chat.lua` - Messages par téléphone
- `server/feature/calls.lua` - Appels par téléphone
- `server/feature/emails.lua` - Emails par téléphone
- `server/feature/photos.lua` - Photos par téléphone
- `server/feature/ads.lua` - Publicités par téléphone
- `server/feature/news.lua` - News par téléphone
- `server/feature/services.lua` - Services par téléphone
- `server/feature/inetmax.lua` - InetMax par téléphone
- `server/feature/bank.lua` - Banque par téléphone

#### **Features Client**
- `client/feature/contact.lua` - Callback messages

#### **Interface Web**
- `web/src/components/LockScreenComponent.jsx` - Suppression news

#### **Configuration**
- `html/static/config.json` - Suppression LATEST_NEWS

#### **Nouveaux Fichiers**
- `server/phone_generator.lua` - Générateur téléphones
- `final_complete_migration.sql` - Script migration complet

### 🚀 NOUVELLES FONCTIONNALITÉS

#### **Commandes Admin**
- `/createphone` - Crée téléphone avec numéro unique

#### **Système de Génération**
- Numéros uniques automatiques
- Métadonnées complètes
- Descriptions dynamiques

### ⚠️ MIGRATION REQUISE

#### **Étapes Obligatoires**
1. **Sauvegarde** base de données
2. **Exécution** `final_complete_migration.sql`
3. **Redémarrage** z-phone
4. **Test** toutes fonctionnalités

#### **Scripts SQL Fournis**
- `final_complete_migration.sql` - Migration complète
- `fix_calls_table.sql` - Correction appels
- `fix_contacts_constraint.sql` - Correction contraintes
- `update_messages_system.sql` - Migration messages

### 🎯 IMPACT ROLEPLAY

#### **Avant (v1.x)**
- Données liées au joueur
- Vol téléphone = aucun impact
- Téléphones identiques
- Pas de persistance physique

#### **Après (v2.0)**
- Données liées au téléphone physique
- Vol téléphone = accès complet aux données
- Chaque téléphone unique
- Échange/vente téléphones possible
- Persistance complète des données

### 🔒 SÉCURITÉ & PERFORMANCE

#### **Améliorations Sécurité**
- Vérification métadonnées systématique
- Protection téléphones sans numéro
- Validation données d'entrée
- Gestion erreurs robuste

#### **Optimisations Performance**
- Index optimisés sur phone_number
- Requêtes SQL améliorées
- LEFT JOIN pour numéros inexistants
- Cache des métadonnées

### 🐛 CORRECTIONS DE BUGS

#### **Bugs Corrigés**
- Erreur `GetItemCount` ox_inventory
- Contrainte unique contacts
- Bouton message contacts non-fonctionnel
- Vérifications numéros trop strictes
- Affichage news écran verrouillage

### 📊 STATISTIQUES MIGRATION

#### **Fichiers Modifiés**
- **20 fichiers Lua** modifiés
- **1 fichier React** modifié  
- **1 fichier JSON** modifié
- **4 scripts SQL** créés

#### **Tables Migrées**
- `zp_users` (clé primaire changée)
- `zp_contacts` + colonnes phone_number
- `zp_contacts_requests` + colonnes phone_number
- `zp_conversation_participants` + colonne phone_number
- `zp_conversation_messages` + colonne sender_phone_number
- `zp_calls_histories` + colonnes phone_number
- `zp_emails` + colonne phone_number
- `zp_inetmax_histories` + colonne phone_number
- `zp_photos` + colonne phone_number
- `zp_service_messages` + colonnes phone_number
- `zp_ads` + colonne phone_number
- `zp_news` + colonne phone_number

### 🔄 COMPATIBILITÉ

#### **Compatible Avec**
- ✅ ESX Framework
- ✅ ox_inventory (toutes versions)
- ✅ ox_lib
- ✅ Téléphones existants (après migration)

#### **Non Compatible Avec**
- ❌ Versions antérieures sans migration
- ❌ Systèmes d'inventaire autres qu'ox_inventory

---

**Version** : 2.0.0  
**Date** : Décembre 2024  
**Type** : Migration Majeure  
**Compatibilité** : Breaking Changes  
**Migration** : Obligatoire

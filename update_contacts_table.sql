-- Mise à jour de la table zp_contacts pour utiliser phone_number

-- Ajouter les nouvelles colonnes
ALTER TABLE zp_contacts ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE zp_contacts ADD COLUMN contact_phone_number VARCHAR(20);

-- Migrer les données existantes (optionnel si vous avez des données)
UPDATE zp_contacts zpc 
JOIN zp_users zpu1 ON zpu1.citizenid = zpc.citizenid 
JOIN zp_users zpu2 ON zpu2.citizenid = zpc.contact_citizenid 
SET zpc.phone_number = zpu1.phone_number, 
    zpc.contact_phone_number = zpu2.phone_number;

-- Supprimer les anciennes colonnes (après avoir vérifié que la migration fonctionne)
-- ALTER TABLE zp_contacts DROP COLUMN citizenid;
-- ALTER TABLE zp_contacts DROP COLUMN contact_citizenid;

-- Ajouter les index pour les performances
ALTER TABLE zp_contacts ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_contacts ADD INDEX idx_contact_phone_number (contact_phone_number);
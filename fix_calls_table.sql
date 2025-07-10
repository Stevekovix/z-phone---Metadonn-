-- Correction de la table zp_calls_histories

-- Ajouter les colonnes phone_number
ALTER TABLE zp_calls_histories ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE zp_calls_histories ADD COLUMN to_phone_number VARCHAR(20);

-- Migrer les données existantes
UPDATE zp_calls_histories zch
JOIN zp_users zpu1 ON zpu1.citizenid = zch.citizenid
JOIN zp_users zpu2 ON zpu2.citizenid = zch.to_citizenid
SET zch.phone_number = zpu1.phone_number,
    zch.to_phone_number = zpu2.phone_number;

-- Ajouter les index
ALTER TABLE zp_calls_histories ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_calls_histories ADD INDEX idx_to_phone_number (to_phone_number);
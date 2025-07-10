-- Script de mise à jour pour le système de métadonnées

-- Supprimer la clé primaire actuelle et en créer une nouvelle basée sur phone_number
ALTER TABLE zp_users DROP PRIMARY KEY;
ALTER TABLE zp_users ADD PRIMARY KEY (phone_number);

-- Ajouter un index sur citizenid pour les recherches
ALTER TABLE zp_users ADD INDEX idx_citizenid (citizenid);

-- Mettre à jour les autres tables pour utiliser phone_number au lieu de citizenid
-- (Optionnel : si vous voulez que les messages soient liés au téléphone et non au joueur)

-- Pour les messages
-- ALTER TABLE zp_conversation_messages ADD COLUMN sender_phone_number VARCHAR(20);
-- ALTER TABLE zp_conversation_participants ADD COLUMN phone_number VARCHAR(20);

-- Pour les contacts  
-- ALTER TABLE zp_contacts CHANGE COLUMN citizenid phone_number VARCHAR(20);
-- ALTER TABLE zp_contacts CHANGE COLUMN contact_citizenid contact_phone_number VARCHAR(20);
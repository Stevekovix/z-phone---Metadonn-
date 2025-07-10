-- Migration complète vers le système de métadonnées (phone_number)

-- 1. Mise à jour de la table zp_contacts
ALTER TABLE zp_contacts ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE zp_contacts ADD COLUMN contact_phone_number VARCHAR(20);

UPDATE zp_contacts zpc 
JOIN zp_users zpu1 ON zpu1.citizenid = zpc.citizenid 
JOIN zp_users zpu2 ON zpu2.citizenid = zpc.contact_citizenid 
SET zpc.phone_number = zpu1.phone_number, 
    zpc.contact_phone_number = zpu2.phone_number;

-- 2. Mise à jour de la table zp_contacts_requests
ALTER TABLE zp_contacts_requests ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE zp_contacts_requests ADD COLUMN from_phone_number VARCHAR(20);

UPDATE zp_contacts_requests zpcr
JOIN zp_users zpu1 ON zpu1.citizenid = zpcr.citizenid
JOIN zp_users zpu2 ON zpu2.citizenid = zpcr.from_citizenid
SET zpcr.phone_number = zpu1.phone_number,
    zpcr.from_phone_number = zpu2.phone_number;

-- 3. Mise à jour de la table zp_conversation_participants
ALTER TABLE zp_conversation_participants ADD COLUMN phone_number VARCHAR(20);

UPDATE zp_conversation_participants zcp
JOIN zp_users zpu ON zpu.citizenid = zcp.citizenid
SET zcp.phone_number = zpu.phone_number;

-- 4. Mise à jour de la table zp_conversation_messages
ALTER TABLE zp_conversation_messages ADD COLUMN sender_phone_number VARCHAR(20);

UPDATE zp_conversation_messages zcm
JOIN zp_users zpu ON zpu.citizenid = zcm.sender_citizenid
SET zcm.sender_phone_number = zpu.phone_number;

-- 5. Mise à jour de la table zp_calls_histories
ALTER TABLE zp_calls_histories ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE zp_calls_histories ADD COLUMN to_phone_number VARCHAR(20);

UPDATE zp_calls_histories zch
JOIN zp_users zpu1 ON zpu1.citizenid = zch.citizenid
JOIN zp_users zpu2 ON zpu2.citizenid = zch.to_citizenid
SET zch.phone_number = zpu1.phone_number,
    zch.to_phone_number = zpu2.phone_number;

-- 6. Mise à jour de la table zp_emails
ALTER TABLE zp_emails ADD COLUMN phone_number VARCHAR(20);

UPDATE zp_emails ze
JOIN zp_users zpu ON zpu.citizenid = ze.citizenid
SET ze.phone_number = zpu.phone_number;

-- 7. Mise à jour de la table zp_inetmax_histories
ALTER TABLE zp_inetmax_histories ADD COLUMN phone_number VARCHAR(20);

UPDATE zp_inetmax_histories zih
JOIN zp_users zpu ON zpu.citizenid = zih.citizenid
SET zih.phone_number = zpu.phone_number;

-- 8. Mise à jour de la table zp_photos
ALTER TABLE zp_photos ADD COLUMN phone_number VARCHAR(20);

UPDATE zp_photos zp
JOIN zp_users zpu ON zpu.citizenid = zp.citizenid
SET zp.phone_number = zpu.phone_number;

-- 9. Mise à jour de la table zp_service_messages
ALTER TABLE zp_service_messages ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE zp_service_messages ADD COLUMN solved_by_phone_number VARCHAR(20);

UPDATE zp_service_messages zsm
JOIN zp_users zpu1 ON zpu1.citizenid = zsm.citizenid
LEFT JOIN zp_users zpu2 ON zpu2.citizenid = zsm.solved_by_citizenid
SET zsm.phone_number = zpu1.phone_number,
    zsm.solved_by_phone_number = zpu2.phone_number;

-- 10. Mise à jour de la table zp_ads
ALTER TABLE zp_ads ADD COLUMN phone_number VARCHAR(20);

UPDATE zp_ads za
JOIN zp_users zpu ON zpu.citizenid = za.citizenid
SET za.phone_number = zpu.phone_number;

-- 11. Mise à jour de la table zp_news
ALTER TABLE zp_news ADD COLUMN phone_number VARCHAR(20);

UPDATE zp_news zn
JOIN zp_users zpu ON zpu.citizenid = zn.citizenid
SET zn.phone_number = zpu.phone_number;

-- 12. Ajout des index pour les performances
ALTER TABLE zp_contacts ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_contacts ADD INDEX idx_contact_phone_number (contact_phone_number);
ALTER TABLE zp_contacts_requests ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_conversation_participants ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_conversation_messages ADD INDEX idx_sender_phone_number (sender_phone_number);
ALTER TABLE zp_calls_histories ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_emails ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_inetmax_histories ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_photos ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_service_messages ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_ads ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_news ADD INDEX idx_phone_number (phone_number);

-- IMPORTANT: Après avoir testé que tout fonctionne, vous pouvez supprimer les anciennes colonnes
-- ALTER TABLE zp_contacts DROP COLUMN citizenid, DROP COLUMN contact_citizenid;
-- ALTER TABLE zp_contacts_requests DROP COLUMN citizenid, DROP COLUMN from_citizenid;
-- etc...
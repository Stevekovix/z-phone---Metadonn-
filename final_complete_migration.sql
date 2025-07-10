-- MIGRATION COMPLÈTE VERS LE SYSTÈME DE MÉTADONNÉES (PHONE_NUMBER)
-- Exécuter ce script pour migrer toutes les tables vers le nouveau système

-- 1. Mise à jour de la table zp_users (clé primaire)
ALTER TABLE zp_users DROP PRIMARY KEY;
ALTER TABLE zp_users ADD PRIMARY KEY (phone_number);
ALTER TABLE zp_users ADD INDEX idx_citizenid (citizenid);

-- 2. Mise à jour de zp_contacts
ALTER TABLE zp_contacts ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE zp_contacts ADD COLUMN contact_phone_number VARCHAR(20);

UPDATE zp_contacts zpc 
JOIN zp_users zpu1 ON zpu1.citizenid = zpc.citizenid 
JOIN zp_users zpu2 ON zpu2.citizenid = zpc.contact_citizenid 
SET zpc.phone_number = zpu1.phone_number, 
    zpc.contact_phone_number = zpu2.phone_number;

ALTER TABLE zp_contacts DROP INDEX unique_contact;
ALTER TABLE zp_contacts ADD UNIQUE INDEX unique_contact (phone_number, contact_phone_number);
ALTER TABLE zp_contacts ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_contacts ADD INDEX idx_contact_phone_number (contact_phone_number);

-- 3. Mise à jour de zp_contacts_requests
ALTER TABLE zp_contacts_requests ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE zp_contacts_requests ADD COLUMN from_phone_number VARCHAR(20);

UPDATE zp_contacts_requests zpcr
JOIN zp_users zpu1 ON zpu1.citizenid = zpcr.citizenid
JOIN zp_users zpu2 ON zpu2.citizenid = zpcr.from_citizenid
SET zpcr.phone_number = zpu1.phone_number,
    zpcr.from_phone_number = zpu2.phone_number;

ALTER TABLE zp_contacts_requests ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_contacts_requests ADD INDEX idx_from_phone_number (from_phone_number);

-- 4. Mise à jour de zp_conversation_participants
ALTER TABLE zp_conversation_participants ADD COLUMN phone_number VARCHAR(20);

UPDATE zp_conversation_participants zcp
JOIN zp_users zpu ON zpu.citizenid = zcp.citizenid
SET zcp.phone_number = zpu.phone_number;

ALTER TABLE zp_conversation_participants DROP PRIMARY KEY;
ALTER TABLE zp_conversation_participants ADD PRIMARY KEY (conversationid, phone_number);
ALTER TABLE zp_conversation_participants ADD INDEX idx_phone_number (phone_number);

-- 5. Mise à jour de zp_conversation_messages
ALTER TABLE zp_conversation_messages ADD COLUMN sender_phone_number VARCHAR(20);

UPDATE zp_conversation_messages zcm
JOIN zp_users zpu ON zpu.citizenid = zcm.sender_citizenid
SET zcm.sender_phone_number = zpu.phone_number;

ALTER TABLE zp_conversation_messages ADD INDEX idx_sender_phone_number (sender_phone_number);

-- 6. Mise à jour de zp_calls_histories
ALTER TABLE zp_calls_histories ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE zp_calls_histories ADD COLUMN to_phone_number VARCHAR(20);

UPDATE zp_calls_histories zch
JOIN zp_users zpu1 ON zpu1.citizenid = zch.citizenid
JOIN zp_users zpu2 ON zpu2.citizenid = zch.to_citizenid
SET zch.phone_number = zpu1.phone_number,
    zch.to_phone_number = zpu2.phone_number;

ALTER TABLE zp_calls_histories ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_calls_histories ADD INDEX idx_to_phone_number (to_phone_number);

-- 7. Mise à jour de zp_emails
ALTER TABLE zp_emails ADD COLUMN phone_number VARCHAR(20);

UPDATE zp_emails ze
JOIN zp_users zpu ON zpu.citizenid = ze.citizenid
SET ze.phone_number = zpu.phone_number;

ALTER TABLE zp_emails ADD INDEX idx_phone_number (phone_number);

-- 8. Mise à jour de zp_inetmax_histories
ALTER TABLE zp_inetmax_histories ADD COLUMN phone_number VARCHAR(20);

UPDATE zp_inetmax_histories zih
JOIN zp_users zpu ON zpu.citizenid = zih.citizenid
SET zih.phone_number = zpu.phone_number;

ALTER TABLE zp_inetmax_histories ADD INDEX idx_phone_number (phone_number);

-- 9. Mise à jour de zp_photos
ALTER TABLE zp_photos ADD COLUMN phone_number VARCHAR(20);

UPDATE zp_photos zp
JOIN zp_users zpu ON zpu.citizenid = zp.citizenid
SET zp.phone_number = zpu.phone_number;

ALTER TABLE zp_photos ADD INDEX idx_phone_number (phone_number);

-- 10. Mise à jour de zp_service_messages
ALTER TABLE zp_service_messages ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE zp_service_messages ADD COLUMN solved_by_phone_number VARCHAR(20);

UPDATE zp_service_messages zsm
JOIN zp_users zpu1 ON zpu1.citizenid = zsm.citizenid
LEFT JOIN zp_users zpu2 ON zpu2.citizenid = zsm.solved_by_citizenid
SET zsm.phone_number = zpu1.phone_number,
    zsm.solved_by_phone_number = zpu2.phone_number;

ALTER TABLE zp_service_messages ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_service_messages ADD INDEX idx_solved_by_phone_number (solved_by_phone_number);

-- 11. Mise à jour de zp_ads
ALTER TABLE zp_ads ADD COLUMN phone_number VARCHAR(20);

UPDATE zp_ads za
JOIN zp_users zpu ON zpu.citizenid = za.citizenid
SET za.phone_number = zpu.phone_number;

ALTER TABLE zp_ads ADD INDEX idx_phone_number (phone_number);

-- 12. Mise à jour de zp_news
ALTER TABLE zp_news ADD COLUMN phone_number VARCHAR(20);

UPDATE zp_news zn
JOIN zp_users zpu ON zpu.citizenid = zn.citizenid
SET zn.phone_number = zpu.phone_number;

ALTER TABLE zp_news ADD INDEX idx_phone_number (phone_number);

-- IMPORTANT: Après avoir testé que tout fonctionne, vous pouvez supprimer les anciennes colonnes
-- Décommentez les lignes ci-dessous SEULEMENT après avoir vérifié que tout fonctionne parfaitement

-- ALTER TABLE zp_contacts DROP COLUMN citizenid, DROP COLUMN contact_citizenid;
-- ALTER TABLE zp_contacts_requests DROP COLUMN citizenid, DROP COLUMN from_citizenid;
-- ALTER TABLE zp_conversation_participants DROP COLUMN citizenid;
-- ALTER TABLE zp_conversation_messages DROP COLUMN sender_citizenid;
-- ALTER TABLE zp_calls_histories DROP COLUMN citizenid, DROP COLUMN to_citizenid;
-- ALTER TABLE zp_emails DROP COLUMN citizenid;
-- ALTER TABLE zp_inetmax_histories DROP COLUMN citizenid;
-- ALTER TABLE zp_photos DROP COLUMN citizenid;
-- ALTER TABLE zp_service_messages DROP COLUMN citizenid, DROP COLUMN solved_by_citizenid;
-- ALTER TABLE zp_ads DROP COLUMN citizenid;
-- ALTER TABLE zp_news DROP COLUMN citizenid;
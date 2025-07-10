-- Migration spécifique pour le système de messages

-- 1. Mise à jour de zp_conversation_participants
ALTER TABLE zp_conversation_participants ADD COLUMN phone_number VARCHAR(20);

UPDATE zp_conversation_participants zcp
JOIN zp_users zpu ON zpu.citizenid = zcp.citizenid
SET zcp.phone_number = zpu.phone_number;

-- 2. Mise à jour de zp_conversation_messages  
ALTER TABLE zp_conversation_messages ADD COLUMN sender_phone_number VARCHAR(20);

UPDATE zp_conversation_messages zcm
JOIN zp_users zpu ON zpu.citizenid = zcm.sender_citizenid
SET zcm.sender_phone_number = zpu.phone_number;

-- 3. Mise à jour de zp_contacts_requests
ALTER TABLE zp_contacts_requests ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE zp_contacts_requests ADD COLUMN from_phone_number VARCHAR(20);

UPDATE zp_contacts_requests zpcr
JOIN zp_users zpu1 ON zpu1.citizenid = zpcr.citizenid
JOIN zp_users zpu2 ON zpu2.citizenid = zpcr.from_citizenid
SET zpcr.phone_number = zpu1.phone_number,
    zpcr.from_phone_number = zpu2.phone_number;

-- 4. Ajout des index pour les performances
ALTER TABLE zp_conversation_participants ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_conversation_messages ADD INDEX idx_sender_phone_number (sender_phone_number);
ALTER TABLE zp_contacts_requests ADD INDEX idx_phone_number (phone_number);
ALTER TABLE zp_contacts_requests ADD INDEX idx_from_phone_number (from_phone_number);

-- 5. Mise à jour de la clé primaire de zp_conversation_participants
ALTER TABLE zp_conversation_participants DROP PRIMARY KEY;
ALTER TABLE zp_conversation_participants ADD PRIMARY KEY (conversationid, phone_number);
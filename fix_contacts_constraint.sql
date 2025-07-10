-- Correction de la contrainte unique pour zp_contacts

-- Supprimer l'ancienne contrainte unique
ALTER TABLE zp_contacts DROP INDEX unique_contact;

-- Ajouter la nouvelle contrainte unique basée sur phone_number
ALTER TABLE zp_contacts ADD UNIQUE INDEX unique_contact (phone_number, contact_phone_number);
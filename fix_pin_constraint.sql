-- Run this in Supabase SQL Editor to fix the PIN code constraint
-- This allows null values and is more lenient for optional fields

ALTER TABLE practice_info
  DROP CONSTRAINT IF EXISTS practice_info_pin_code_check;

ALTER TABLE practice_info
  ADD CONSTRAINT practice_info_pin_code_check
  CHECK (pin_code IS NULL OR pin_code ~ '^[0-9]{6}$');

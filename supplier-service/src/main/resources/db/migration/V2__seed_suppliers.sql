INSERT INTO procurement.suppliers (supplier_code, company_name, contact_person, email, phone, status)
VALUES
  ('SUP-001', 'ChemLabs Pvt Ltd',  'John Wilson', 'Jwilson@Labs.com',  '+727-9876543210', 'ACTIVE'),
  ('SUP-002', 'PharmaRaw Corp',     'Laura Morada', 'LMorada@pharmaraw.com',   '+813-9876543211', 'ACTIVE'),
  ('SUP-003', 'BioSynth Labs',      'Cooper Brookstone',   'CBrookstone@biosynth.com',     '+770-9876543212', 'ACTIVE'),
  ('SUP-004', 'Global APIs Ltd',    'Richard Parker',   'RParker@globalapis.com', '+954-9876543213', 'ACTIVE')
ON CONFLICT DO NOTHING;

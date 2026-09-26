INSERT INTO manufacturing.batches (batch_number, product_name, quantity, scheduled_date, assigned_line, status)
VALUES
  ('BATCH-2027-001', 'Paracetamol 500mg',  10000, '2027-04-10', 'Line A', 'COMPLETED'),
  ('BATCH-2027-002', 'Amoxicillin 250mg',   8000, '2027-04-12', 'Line B', 'COMPLETED'),
  ('BATCH-2027-003', 'Ibuprofen 400mg',     6000, '2027-04-15', 'Line A', 'IN_PROGRESS'),
  ('BATCH-2027-004', 'Metformin 850mg',     5000, '2027-04-18', 'Line C', 'SCHEDULED')
ON CONFLICT DO NOTHING;

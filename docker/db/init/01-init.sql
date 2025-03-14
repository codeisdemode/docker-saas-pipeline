-- Create customers table
CREATE TABLE IF NOT EXISTS customers (
  id SERIAL PRIMARY KEY,
  customer_id VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample customer data
INSERT INTO customers (customer_id, name) VALUES 
  ('dev_local', 'Development Customer'),
  ('customer1', 'Customer One'),
  ('customer2', 'Customer Two'),
  ('customer3', 'Customer Three')
ON CONFLICT (customer_id) DO NOTHING;

-- Create customer_data table
CREATE TABLE IF NOT EXISTS customer_data (
  id SERIAL PRIMARY KEY,
  customer_id VARCHAR(50) REFERENCES customers(customer_id),
  data JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample customer data
INSERT INTO customer_data (customer_id, data) VALUES 
  ('dev_local', '{"plan": "developer", "active": true, "features": ["basic", "advanced"]}'::JSONB),
  ('customer1', '{"plan": "standard", "active": true, "features": ["basic"]}'::JSONB),
  ('customer2', '{"plan": "premium", "active": true, "features": ["basic", "advanced", "premium"]}'::JSONB),
  ('customer3', '{"plan": "standard", "active": false, "features": ["basic"]}'::JSONB)
ON CONFLICT DO NOTHING; 
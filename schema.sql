CREATE TABLE inventories (
  id INTEGER PRIMARY KEY,
  item TEXT,
  price INTEGER,
  quantity INTEGER,
  url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customers (
  id INTEGER PRIMARY KEY,
  name TEXT,
  password TEXT,
  email TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE purchases (
  id INTEGER PRIMARY KEY,
  shirt_id INTEGER references inventory,
  quantity INTEGER,
  customer_id INTEGER references customers
);

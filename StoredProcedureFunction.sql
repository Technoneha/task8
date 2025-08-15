-- Customers table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- Orders table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_amount NUMERIC(10,2),
    order_date DATE DEFAULT CURRENT_DATE
);

--------create procedure---------
-----------------------------------

CREATE OR REPLACE PROCEDURE add_customer_with_order(
    p_name VARCHAR,         
    p_email VARCHAR,        
    p_order_amount NUMERIC  
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insert new customer
    INSERT INTO customers (name, email)
    VALUES (p_name, p_email);

    -- Insert first order for the newly added customer
    INSERT INTO orders (customer_id, order_amount)
    VALUES (
        currval(pg_get_serial_sequence('customers', 'customer_id')), 
        p_order_amount
    );
END;
$$;


-------create function----------
---------------------------------

CREATE OR REPLACE FUNCTION get_total_spent(
    p_customer_id INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    total_spent NUMERIC;
BEGIN
    SELECT SUM(order_amount)
    INTO total_spent
    FROM orders
    WHERE customer_id = p_customer_id;

    RETURN COALESCE(total_spent, 0);
END;
$$;


----------Add data using procedure-----------
CALL add_customer_with_order('Neha Mishra', 'neha@eample.com', 1200.50);
CALL add_customer_with_order('Ravi Kumar', 'ravi@exmple.com', 800);
CALL add_customer_with_order('Priya Sharma', 'priya@exmple.com', 1500.75);

-----------add more orders (Normal Insert)------------------
INSERT INTO orders (customer_id, order_amount) VALUES (1, 500);
INSERT INTO orders (customer_id, order_amount) VALUES (2, 200);


-----get repprt using function
SELECT 
    c.customer_id,
    c.name,
    c.email,
    get_total_spent(c.customer_id) AS total_spent
FROM customers c;


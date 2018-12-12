DROP DATABASE IF EXISTS dblab;

CREATE DATABASE dblab;

use dblab;

create table customers(
    customer_id INT PRIMARY KEY auto_increment,
    user_id VARCHAR(20) NOT null,
    password VARCHAR(130) not null
);

CREATE TABLE customer_accounts(
    customer_account_id INT PRIMARY KEY auto_increment,
    bank_account_number VARCHAR(20) NOT NULL,
    bank_name VARCHAR(20) NOT NULL,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

create table customer_orders(
    customer_order_id INT PRIMARY KEY auto_increment,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    total_price DECIMAL(10,2) not null,
    customer_account_id INT,
    FOREIGN KEY (customer_account_id) REFERENCES customer_accounts(customer_account_id)
);

create table items(
    item_id INT PRIMARY KEY auto_increment,
    name VARCHAR(50) not NULL
);

create table class(
    class_id INT PRIMARY KEY auto_increment,
    item_id INT,
    FOREIGN KEY (item_id) REFERENCES items(item_id),
    max_price DECIMAL(10,2) not null,
    class_type ENUM('A', 'B', 'C')
);

create table suppliers(
    supplier_id INT PRIMARY KEY auto_increment,
    name VARCHAR(50) NOT NULL
);

create table order_items(
    order_item_id INT PRIMARY KEY auto_increment,
    customer_order_id INT,
    FOREIGN KEY (customer_order_id) REFERENCES customer_orders(customer_order_id),
    quantity INT not null,
    price DECIMAL(10,2) not NULL,
    supplier_id INT,
    FOREIGN key (supplier_id) REFERENCES suppliers(supplier_id),
    class_id int,
    FOREIGN KEY (class_id) REFERENCES class(class_id),
    item_id INT,
    FOREIGN KEY (item_id) REFERENCES items(item_id)
);

create table supplier_items(
    supplier_item_id INT PRIMARY KEY auto_increment,
    supplier_id int,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    commission INT not null,
    class_id int,
    FOREIGN KEY (class_id) REFERENCES class(class_id),
    discount INT,
    stock INT DEFAULT 0 ,
    review DECIMAL(10, 4),
    number_reviews INT DEFAULT 0,
    item_id int,
    FOREIGN KEY (item_id) REFERENCES items(item_id)
); 

create table preference_index(
    preference_index_id INT PRIMARY KEY auto_increment,
    supplier_item_id INT,
    FOREIGN key (supplier_item_id) REFERENCES supplier_items(supplier_item_id),
    index_val decimal(10,5)
);

DELIMITER $$
 
CREATE FUNCTION Calculate_preference_index(commission INT, review DECIMAL(10, 4), discount INT) RETURNS DECIMAL(10,2)
    DETERMINISTIC
BEGIN
    RETURN 1 / (1 + exp((-1 * 1.0 * commission) + (-1 * 1.0 * review) + (-1 * discount)));
END
$$

CREATE TRIGGER update_commission
AFTER UPDATE ON supplier_items FOR EACH ROW
begin
       
           UPDATE preference_index
           SET index_val = Calculate_preference_index(new.commission, new.review, new.discount);

       
END;
$$
DELIMITER ;

INSERT INTO customers VALUES(1,'U1','PWD1');
INSERT INTO customers VALUES(2,'U2','PWD2');
INSERT INTO customers VALUES(3,'U3','PWD3');
INSERT INTO customers VALUES(4,'U4','PWD4');
INSERT INTO customers VALUES(5,'U5','PWD5');
INSERT INTO customers VALUES(6,'U6','PWD6');


INSERT INTO customer_accounts VALUES(1,'BA1','BN1',1);
INSERT INTO customer_accounts VALUES(2,'BA2','BN2',2);
INSERT INTO customer_accounts VALUES(3,'BA3','BN3',3);
INSERT INTO customer_accounts VALUES(4,'BA4','BN4',4);
INSERT INTO customer_accounts VALUES(5,'BA5','BN5',5);
INSERT INTO customer_accounts VALUES(6,'BA6','BN6',6);

INSERT into customer_orders VALUES (1,1,1,1);
INSERT into customer_orders VALUES (2,2,2,2);
INSERT into customer_orders VALUES (3,3,3,3);
INSERT into customer_orders VALUES (4,4,4,4);
INSERT into customer_orders VALUES (5,5,5,5);
INSERT into customer_orders VALUES (6,6,6,6);
INSERT INTO items VALUES(1,'ITEM1');
INSERT INTO items VALUES(2,'ITEM2');
INSERT INTO items VALUES(3,'ITEM3');
INSERT INTO items VALUES(4,'ITEM4');
INSERT INTO items VALUES(5,'ITEM5');
INSERT INTO items VALUES(6,'ITEM6');


INSERT INTO class VALUES(1,1,1,'A');
INSERT INTO class VALUES(2,2,2,'A');
INSERT INTO class VALUES(3,3,3,'B');
INSERT INTO class VALUES(4,4,4,'A');
INSERT INTO class VALUES(5,5,5,'C');
INSERT INTO class VALUES(6,6,6,'C');
INSERT INTO suppliers VALUES(1,'supplier1');
INSERT INTO suppliers VALUES(2,'supplier2');
INSERT INTO suppliers VALUES(3,'supplier3');
INSERT INTO suppliers VALUES(4,'supplier4');
INSERT INTO suppliers VALUES(5,'supplier5');
INSERT INTO suppliers VALUES(6,'supplier6');

INSERT INTO order_items VALUES(1,1,1,1,1,1,1);
INSERT INTO order_items VALUES(2,2,2,2,2,2,2);
INSERT INTO order_items VALUES(3,3,3,3,3,3,3);
INSERT INTO order_items VALUES(4,4,4,4,4,4,4);
INSERT INTO order_items VALUES(5,5,5,5,5,5,1);
INSERT INTO order_items VALUES(6,6,6,6,6,6,2);

INSERT INTO supplier_items VALUES(1,1,1,1,1,1,1,1,1);
INSERT INTO supplier_items VALUES(2,2,2,2,2,2,2,2,2);
INSERT INTO supplier_items VALUES(3,3,3,3,3,3,3,3,3);
INSERT INTO supplier_items VALUES(4,4,4,4,4,4,4,4,4);
INSERT INTO supplier_items VALUES(5,5,5,5,5,5,5,5,5);
INSERT INTO supplier_items VALUES(6,6,6,6,6,6,6,6,6);
INSERT INTO preference_index VALUES(1,1,1);
INSERT INTO preference_index VALUES(2,2,2);
INSERT INTO preference_index VALUES(3,3,3);
INSERT INTO preference_index VALUES(4,4,4);
INSERT INTO preference_index VALUES(5,5,5);
INSERT INTO preference_index VALUES(6,6,6);

/* 
ALL THE SELLERS FOR A GIVEN ITEM OF A GIVEN CLASS
*/

SELECT name from suppliers where supplier_id in (
    select supplier_id from supplier_items 
    where class_id = 1 and item_id=1
);

/*
BILL DETAILS
*/
SELECT customers.user_id,customer_accounts.bank_account_number,total_price 
FROM customer_orders
join  customers on customers.customer_id=customer_orders.customer_id
join customer_accounts on customer_accounts.customer_account_id=customer_orders.customer_account_id
where customer_order_id=1;

/*
Bill Order Details
*/
SELECT items.name,class_type,price,suppliers.name 
from order_items 
join class on order_items.item_id=class.item_id 
join suppliers on suppliers.supplier_id=order_items.supplier_id 
join items on items.item_id=order_items.item_id
where customer_order_id=1;

/*
CUstomer Details
*/

select * from customer_accounts where customer_id = 1;

/*
Stock of certain item with its seller name and its class
*/

select items.name,class.class_type,stock
from supplier_items 
join items on items.item_id = supplier_items.item_id
join class on class.class_id = supplier_items.class_id
where supplier_items.item_id = 1;

/*
All the products of a seller
*/

select items.name from items
join supplier_items on supplier_items.item_id = items.item_id
where supplier_id = 1;

/*
Commission details of all the sellers for a particular product
*/

select suppliers.name,commission 
from suppliers
join supplier_items on supplier_items.supplier_id = suppliers.supplier_id
where item_id = 1; 
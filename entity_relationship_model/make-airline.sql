-- [Problem 5]

-- DROP TABLE commands:
DROP TABLE IF EXISTS ticketed_seat;
DROP TABLE IF EXISTS ticketed_traveler;
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS purchase;
DROP TABLE IF EXISTS traveler;
DROP TABLE IF EXISTS purchaser;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS seat;
DROP TABLE IF EXISTS flight;
DROP TABLE IF EXISTS airplane;

-- CREATE TABLE commands:

-- airplane(type_code, manufacturer, model)
-- contains info about the types of planes used
-- specifically the manufacturer (i.e. Boeing), 
-- model (i.e. 747), and unique code used by 
-- airlines to refer to it, the type_code.
CREATE TABLE airplane (
    type_code CHAR(3),
    manufacturer VARCHAR(15),
    model VARCHAR(15),
    PRIMARY KEY (type_code)
);

-- flight(_flight_no_, _date_, time, source, 
-- dest, flight_type, type_code)
-- contains info about flight timings. 
-- locations, and plane used, specifically 
-- the flight number and date (which 
-- together are the unique key since 
-- flight numbers are reused), time of
-- departure, source and destination 
-- airports (by their 3 letter IATA code),
-- whether domestic or international
-- represented by d or i, and the type 
-- of plane used to fly the flight (which 
-- references airplane). If a type of 
-- airplane is retired, the instance of
-- the flight flying that airplane is also
-- deleted since a flight can't occur w/o
-- a plane (cascade delete).
CREATE TABLE flight (
    flight_no VARCHAR(10),
    flight_date DATE,
    flight_time TIME NOT NULL,
    source_airport CHAR(3) NOT NULL,
    dest_airport CHAR(3) NOT NULL,
    flight_type CHAR(1) NOT NULL,
    type_code CHAR(3) NOT NULL,
    PRIMARY KEY (flight_no, flight_date),
    FOREIGN KEY (type_code) 
    REFERENCES  airplane(type_code)
    ON DELETE CASCADE,
    CHECK (flight_type IN ('i', 'd'))
);


-- seat(_type_code_, _seat_no_, class, 
-- type, exit)
-- contains info about the types of seats 
-- available on each type of plane. Since
-- seat numbers are not unique for each 
-- model, the primary key is both the type
-- of plane and the seat number, which is
-- formatted as a letter followed by numbers. 
-- The class is either first, business, or coach
-- represented by f, b, or c, and the seat 
-- type is either aisle, middle, or window, 
-- represented by a, m, or w. Whether the
-- seat is in an exit row is represented by 
-- a boolean flag. If an airplane type is 
-- retired, then naturally all its seats are 
-- now obsolete, so they are deleted
-- on cascade.
CREATE TABLE seat (
    type_code CHAR(3),
    seat_no VARCHAR(5),
    class CHAR(1) NOT NULL,
    seat_type CHAR(1) NOT NULL,
    exit_row BOOLEAN NOT NULL,
    PRIMARY KEY (seat_no, type_code),
    FOREIGN KEY(type_code)
    REFERENCES airplane(type_code)
    ON DELETE CASCADE,
    CHECK (class IN ('f', 'b', 'c')),
    CHECK (seat_type IN ('a', 'm', 'w'))
);

-- customer(_cust_id_, first_name, last_name, 
-- email, phone_nums)
-- contains information about each 
-- customer who engages with the airline, 
-- both purchasers and actual travelers. 
-- It contains an auto-increment unique ID to 
-- keep track of them, along with their
-- first and last name and contact info. 
-- The phone_nums attribute can 
-- hold up to 5 phone numbers separated 
-- by spaces (since there is no multivalue
-- attribute within a set like there is in ER)
CREATE TABLE customer (
     cust_id INT AUTO_INCREMENT,
     first_name VARCHAR(15) NOT NULL,
     last_name VARCHAR(15) NOT NULL,
     email VARCHAR(25) NOT NULL,
     phone_nums VARCHAR(60) NOT NULL,
     PRIMARY KEY (cust_id)
);

-- purchaser(_cust_id_, credit_card_no, 
-- exp_date, verif_no)
-- contains information about customers 
-- who purchase tickets. Since they
-- are customers, all their contact info
-- and names are stored in that table and
-- accessed using foreign key cust_id. 
-- This table may also have their payment 
-- info (i.e. credit card number, expiration
-- date, and verification number) but may
-- be null if they choose not to save it. 
-- Since a purchaser cannot exist
-- without a corresponding customer 
-- instance, it deletes when customer
-- referenced is deleted.
CREATE TABLE purchaser (
    cust_id INT,
    credit_card_no CHAR(16),
    exp_date CHAR(5),
    verif_no CHAR(3),
    PRIMARY KEY (cust_id),
   FOREIGN KEY(cust_id)
   REFERENCES customer(cust_id)
   ON DELETE CASCADE
);

-- traveler(_cust_id_, pass_no, citizen, 
-- emergency_contact, emergency_no, ffn)
-- contains information about customers 
-- who use tickets to fly places. Since they
-- are customers, all their contact info
-- and names are stored in that table and
-- accessed using foreign key cust_id. 
-- This also contains the information 
-- they need for international flights, 
-- which is their passport number 
-- (pass_no), citizenship country 
-- (citizen), an emergency contact's 
-- first and last name (contact), an 
-- emergency contact phone number
-- (contact_no), and if relevant, a 
-- frequent flyer number (ff_no). All
-- of these attributes can be null because 
-- they can be filled in up until the flight, 
-- and once again like purchaser
-- it deletes cascaded from customer.
CREATE TABLE traveler (
    cust_id INT,
    pass_no CHAR(40),
    citizen CHAR(15),
    contact CHAR(30),
    contact_no VARCHAR(12),
    ff_no CHAR(7),
    PRIMARY KEY (cust_id),
    FOREIGN KEY(cust_id)
    REFERENCES customer(cust_id)
    ON DELETE CASCADE
);

-- purchase(_purchase_id_, 
-- cust_id, timestamp, confirm_no)
-- contains information about every purchase
-- logged, specifically an ID that uniquely
-- identifies each transaction. 
-- It also has a customer who made the 
-- transaction which references purchaser,
-- a time_stamp for the transaction wich 
-- defaults to now, and a confirmation
-- number for the customer that is also a 
-- candidate key. If a purchaser/customer is 
-- deleted, then their associated purchase 
-- is also deleted.
CREATE TABLE purchase (
    purchase_id INT AUTO_INCREMENT,
    cust_id INT NOT NULL,
    time_stamp TIMESTAMP NOT NULL DEFAULT NOW(),
    confirm_no CHAR(6) NOT NULL UNIQUE,
    PRIMARY KEY (purchase_id),
    FOREIGN KEY (cust_id) 
    REFERENCES purchaser (cust_id)
    ON DELETE CASCADE
);

-- ticket(_ticket_id_, sale_price, purchase_id)
-- Contains a unique ID identifying
-- every ticket purchased, and a 
-- sales price up to 10,000$ 
-- that must be set (in order to 
-- sell it it must have a price). 
-- This also contains a reference to 
-- purchase_id in order to make sure
-- we can see what tickets were 
-- purchased. This field can be null
-- since some tickets may not have been 
-- purchased yet.
CREATE TABLE ticket (
    ticket_id INT AUTO_INCREMENT,
    sale_price NUMERIC(7, 2) NOT NULL,
    purchase_id INT,
    PRIMARY KEY (ticket_id),
    FOREIGN KEY(purchase_id)
    REFERENCES purchase(purchase_id)
    ON DELETE CASCADE
);

-- ticketed_traveler(_ticket_id_, cust_id)
-- Contains information that 
-- relates one customer_id to each 
-- ticket_id. This allows customers 
-- to hold multiple tickets, but not 
-- tickets to be held by multiple 
-- customers. It references ticket 
-- and cust_id as a result, and if 
-- either the ticket or the 
-- traveler/customer is deleted, 
-- then naturally the instance is 
-- deleted on cascade.
CREATE TABLE ticketed_traveler (
    ticket_id INT,
    cust_id INT NOT NULL,
    PRIMARY KEY (ticket_id),
    FOREIGN KEY (ticket_id)
    REFERENCES ticket (ticket_id)
    ON DELETE CASCADE,
    FOREIGN KEY (cust_id) 
    REFERENCES traveler (cust_id)
    ON DELETE CASCADE
);

-- ticketed_seat(_flight_no_, _date_, 
-- _seat_no_, ticket_id)
-- makes sure that each seat on each 
-- flight is only occuplied by one ticket,
-- by using the flight's identifying 
-- primary key attributes combined with 
-- seat number as a primary key, 
-- which can then be associated with
-- only one ticket. If the ticket_id or
-- flight is deleted, then the deletion
-- cascades downward. If a flight type 
-- is deleted, then the seat gets 
-- deleted, then obviously the 
-- seat ticket is deleted and so 
-- that also cascades.
CREATE TABLE ticketed_seat (
    flight_no VARCHAR(10),
    flight_date DATE,
    seat_no VARCHAR(5),
    ticket_id INT NOT NULL,
    PRIMARY KEY (flight_no, flight_date,
    seat_no),
    FOREIGN KEY (ticket_id)
    REFERENCES ticket (ticket_id)
    ON DELETE CASCADE,
    FOREIGN KEY (flight_no, flight_date) 
    REFERENCES flight (flight_no, flight_date)
    ON DELETE CASCADE,
    FOREIGN KEY (seat_no) 
    REFERENCES seat (seat_no)
    ON DELETE CASCADE
);



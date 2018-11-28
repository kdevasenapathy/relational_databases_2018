-- [Problem 6a]
-- For a person with customer_id 54321, display
-- all their purchases and associated ticket information
-- ordered by purchase date (descending order), flight 
-- date, traveler last name, traveler first name
-- It's a bit unclear what 'all purchases and associated 
-- ticket information' means, so I'm displaying the 
-- purchase ID, customer first and last name, 
-- purchase time stamp and confirmation numbers, 
-- ticket IDs and prices, seat numbers and traveler first and 
-- last names for those tickets, and the flight number, date, 
-- source, and destination for each flight.
-- 
WITH chosen_id AS (SELECT * FROM customer 
WHERE cust_id = 54321),
named_ticket AS (SELECT first_name
AS trav_first, last_name AS trav_last, cust_id AS 
trav_id, ticket_id FROM  customer NATURAL JOIN 
ticketed_traveler)
SELECT first_name, last_name, purchase_id, time_stamp,
confirm_no, ticket_id, sale_price, seat_no, trav_last,
trav_first, flight_no, flight_date, source_airport, 
dest_airport
 FROM (chosen_id NATURAL JOIN 
purchase NATURAL JOIN ticket NATURAL 
JOIN ticketed_seat NATURAL JOIN flight NATURAL 
JOIN named_ticket) ORDER BY time_stamp DESC,
flight_date, trav_last, trav_first;

-- [Problem 6b]
-- Display total ticket sale revenue for each plane 
-- for flights in the last two weeks
WITH two_weeks AS (SELECT * FROM flight 
NATURAL JOIN ticketed_seat NATURAL JOIN
ticket  WHERE flight_date < NOW() 
AND flight_date >= NOW() - INTERVAL 2 WEEK)
SELECT airplane.type_code, SUM(sale_price) FROM 
airplane LEFT JOIN two_weeks ON airplane.type_code 
GROUP BY airplane.type_code;

-- [Problem 6c]
-- Gives the names of all the travelers who are on 
-- international flights who have not filled out
WITH internats AS (SELECT * FROM flight
WHERE flight_type = 'i')
SELECT first_name, last_name FROM 
customer NATURAL JOIN traveler NATURAL 
JOIN ticketed_traveler NATURAL JOIN ticketed_seat
NATURAL JOIN internats WHERE pass_no IS NULL 
OR citizen IS NULL OR contact IS NULL OR
contact_no IS NULL OR ff_no IS NULL;



-- Unspecified field lengths were selected by referencing
-- https://stackoverflow.com/questions/20958/
-- list-of-standard-lengths-for-database-fields

-- [Problem 1]
-- Drop tables if they already exist to prevent errors,
-- respecting referential integrity
DROP TABLE IF EXISTS owns;
DROP TABLE IF EXISTS participated;
DROP TABLE IF EXISTS accident;
DROP TABLE IF EXISTS car;
DROP TABLE IF EXISTS person;

-- person(driver_id, name, address) where 
-- driver_id is primary key and table is referenced 
-- by owns and participated. driver_id is exactly 
-- 10 characters, name is a 80 character varchar, 
-- address is a 200 character varchar, 
-- no fields can be null
CREATE TABLE person (
    driver_id   CHAR(10) PRIMARY KEY,
    name    VARCHAR(80) NOT NULL,
    address VARCHAR(200) NOT NULL
);

-- car(license, model, year) where 
-- license is primary key and the table is referenced by
-- owns, participated. license is exactly 7 characters, 
-- year is 4 digit numeric, and model is a 50 character 
-- varchar . The model and year of the car can be null.
CREATE TABLE car (
    license CHAR(7) PRIMARY KEY,
    model VARCHAR(50),
    year NUMERIC(4, 0)
);


-- accident(report_number, date_occurred, 
-- location, description) where report_number is a
-- primary key and the table is referenced by 
-- participated. report_number is an auto-incremented
-- integer, date_occurred is a timestamp, location is 
-- a 300 character varchar, description is a text. 
-- The description can be null.
-- Note: CLOB registers as a syntax error :(
CREATE TABLE accident (
    report_number INT AUTO_INCREMENT,
    date_occurred TIMESTAMP(6) NOT NULL,
    location VARCHAR(200) NOT NULL,
    description TEXT,
    
    PRIMARY KEY (report_number)
);

-- owns(driver_id, license)
-- where the multi-column primary key is both 
-- driver_id and license. driver_id is referenced
-- from person and license is references from car. 
-- Type is therefore the same as in the referenced 
-- tables. Supports cascaded updates and deletes.
-- No null supported attributes
CREATE TABLE owns (
    driver_id CHAR(10),
    license CHAR(7),
    
    FOREIGN KEY (driver_id) 
    REFERENCES person (driver_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (license) 
    REFERENCES car (license) 
    ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (driver_id, license)
);

-- participated(driver_id, license, report_number, 
-- damage_amount) where the multi-column primary 
-- key is all the attributes except damage_amount.
-- driver_id is from person, license is from car, and
-- report_number is from accident and thus have all
-- the same types as in the referenced tables. 
-- damage_amount is money so it is a numeric(12, 2)
-- that assumes that damage does not exceed a 
-- billion dollars. damage_amount can be null.
-- Supports cascaded updates.
CREATE TABLE participated (
    driver_id CHAR(10),
    license CHAR(7),
    report_number INT,
    damage_amount NUMERIC(12, 2),
    
    FOREIGN KEY (driver_id)
    REFERENCES person (driver_id)
    ON UPDATE CASCADE,
    FOREIGN KEY (license)
    REFERENCES car (license)
    ON UPDATE CASCADE,
    FOREIGN KEY (report_number)
    REFERENCES accident (report_number)
    ON UPDATE CASCADE,
    PRIMARY KEY(driver_id, license, report_number)
);


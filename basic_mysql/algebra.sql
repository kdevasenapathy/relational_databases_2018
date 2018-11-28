-- [Problem 1]
-- PROJECT [A] (r)
SELECT DISTINCT A FROM r;

-- [Problem 2]
-- SELECT [b = 17] (r)
SELECT * FROM r WHERE b = 17;

-- [Problem 3]
-- r CROSS s
SELECT * FROM r, s;

-- [Problem 4]
-- PROJECT [A, F] (SELECT [C=D] (r CROSS s))
SELECT DISTINCT A, F FROM r, s WHERE r.c = s.d;

-- [Problem 5]
-- r1 UNION r2
SELECT * FROM r_1 UNION SELECT * FROM r_2;

-- [Problem 6]
-- r1 INTERSECT r_2;
SELECT * FROM r_1 INTERSECT SELECT * FROM r_2;

-- [Problem 7]
-- r1 MINUS r2;
SELECT * FROM r_1 EXCEPT SELECT * FROM r_2;


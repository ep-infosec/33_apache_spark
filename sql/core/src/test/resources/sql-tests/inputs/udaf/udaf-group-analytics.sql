CREATE OR REPLACE TEMPORARY VIEW testData AS SELECT * FROM VALUES
(1, 1), (1, 2), (2, 1), (2, 2), (3, 1), (3, 2)
AS testData(a, b);

-- CUBE on overlapping columns
SELECT a + b, b, udaf(a - b) FROM testData GROUP BY a + b, b WITH CUBE;

SELECT a, b, udaf(b) FROM testData GROUP BY a, b WITH CUBE;

-- ROLLUP on overlapping columns
SELECT a + b, b, udaf(a - b) FROM testData GROUP BY a + b, b WITH ROLLUP;

SELECT a, b, udaf(b) FROM testData GROUP BY a, b WITH ROLLUP;

CREATE OR REPLACE TEMPORARY VIEW courseSales AS SELECT * FROM VALUES
("dotNET", 2012, 10000), ("Java", 2012, 20000), ("dotNET", 2012, 5000), ("dotNET", 2013, 48000), ("Java", 2013, 30000)
AS courseSales(course, year, earnings);

-- ROLLUP
SELECT course, year, udaf(earnings) FROM courseSales GROUP BY ROLLUP(course, year) ORDER BY course, year;
SELECT course, year, udaf(earnings) FROM courseSales GROUP BY ROLLUP(course, year, (course, year)) ORDER BY course, year;
SELECT course, year, udaf(earnings) FROM courseSales GROUP BY ROLLUP(course, year, (course, year), ()) ORDER BY course, year;

-- CUBE
SELECT course, year, udaf(earnings) FROM courseSales GROUP BY CUBE(course, year) ORDER BY course, year;
SELECT course, year, udaf(earnings) FROM courseSales GROUP BY CUBE(course, year, (course, year)) ORDER BY course, year;
SELECT course, year, udaf(earnings) FROM courseSales GROUP BY CUBE(course, year, (course, year), ()) ORDER BY course, year;

-- GROUPING SETS
SELECT course, year, udaf(earnings) FROM courseSales GROUP BY course, year GROUPING SETS(course, year);
SELECT course, year, udaf(earnings) FROM courseSales GROUP BY course, year GROUPING SETS(course, year, ());
SELECT course, year, udaf(earnings) FROM courseSales GROUP BY course, year GROUPING SETS(course);
SELECT course, year, udaf(earnings) FROM courseSales GROUP BY course, year GROUPING SETS(year);

-- Partial ROLLUP/CUBE/GROUPING SETS
SELECT course, year, udaf(earnings) FROM courseSales GROUP BY course, CUBE(course, year) ORDER BY course, year;
SELECT course, year, udaf(earnings) FROM courseSales GROUP BY CUBE(course, year), ROLLUP(course, year) ORDER BY course, year;
SELECT course, year, udaf(earnings) FROM courseSales GROUP BY CUBE(course, year), ROLLUP(course, year), GROUPING SETS(course, year) ORDER BY course, year;

-- GROUPING SETS with aggregate functions containing groupBy columns
SELECT course, udaf(earnings) AS sum FROM courseSales
GROUP BY course, earnings GROUPING SETS((), (course), (course, earnings)) ORDER BY course, sum;
SELECT course, udaf(earnings) AS sum, GROUPING_ID(course, earnings) FROM courseSales
GROUP BY course, earnings GROUPING SETS((), (course), (course, earnings)) ORDER BY course, sum;

-- Aliases in SELECT could be used in ROLLUP/CUBE/GROUPING SETS
SELECT a + b AS k1, b AS k2, udaf(a - b) FROM testData GROUP BY CUBE(k1, k2);
SELECT a + b AS k, b, udaf(a - b) FROM testData GROUP BY ROLLUP(k, b);
SELECT a + b, b AS k, udaf(a - b) FROM testData GROUP BY a + b, k GROUPING SETS(k);

-- GROUP BY use mixed Separate columns and CUBE/ROLLUP/Gr
SELECT a, b, udaf(1) FROM testData GROUP BY a, b, CUBE(a, b);
SELECT a, b, udaf(1) FROM testData GROUP BY a, b, ROLLUP(a, b);
SELECT a, b, udaf(1) FROM testData GROUP BY CUBE(a, b), ROLLUP(a, b);
SELECT a, b, udaf(1) FROM testData GROUP BY a, CUBE(a, b), ROLLUP(b);
SELECT a, b, udaf(1) FROM testData GROUP BY a, GROUPING SETS((a, b), (a), ());
SELECT a, b, udaf(1) FROM testData GROUP BY a, CUBE(a, b), GROUPING SETS((a, b), (a), ());
SELECT a, b, udaf(1) FROM testData GROUP BY a, CUBE(a, b), ROLLUP(a, b), GROUPING SETS((a, b), (a), ());

-- Support nested CUBE/ROLLUP/GROUPING SETS in GROUPING SETS
SELECT a, b, udaf(1) FROM testData GROUP BY a, GROUPING SETS(ROLLUP(a, b));
SELECT a, b, udaf(1) FROM testData GROUP BY a, GROUPING SETS(GROUPING SETS((a, b), (a), ()));

SELECT a, b, udaf(1) FROM testData GROUP BY a, GROUPING SETS((a, b), GROUPING SETS(ROLLUP(a, b)));
SELECT a, b, udaf(1) FROM testData GROUP BY a, GROUPING SETS((a, b, a, b), (a, b, a), (a, b));
SELECT a, b, udaf(1) FROM testData GROUP BY a, GROUPING SETS(GROUPING SETS((a, b, a, b), (a, b, a), (a, b)));

SELECT a, b, udaf(1) FROM testData GROUP BY a, GROUPING SETS(ROLLUP(a, b), CUBE(a, b));
SELECT a, b, udaf(1) FROM testData GROUP BY a, GROUPING SETS(GROUPING SETS((a, b), (a), ()), GROUPING SETS((a, b), (a), (b), ()));
SELECT a, b, udaf(1) FROM testData GROUP BY a, GROUPING SETS((a, b), (a), (), (a, b), (a), (b), ());

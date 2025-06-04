-- 1. What is the top 5 counties that has the highest and lowest proficiency rate in the Regents Exam (Geometry) in 2024?

SELECT "ENTITY_NAME", "PER_PROF"
FROM "Annual_Regents_Exams"
WHERE ("ENTITY_NAME" LIKE '%County') AND ("SUBGROUP_NAME" = 'All Students')
	AND ("SUBJECT" LIKE '%Geometry%') AND ("YEAR" = 2024) AND ("PER_PROF" NOT LIKE 's')
ORDER BY "PER_PROF" DESC
LIMIT 5;

SELECT "ENTITY_NAME", "PER_PROF"
FROM "Annual_Regents_Exams"
WHERE ("ENTITY_NAME" LIKE '%County') AND ("SUBGROUP_NAME" = 'All Students')
	AND ("SUBJECT" LIKE '%Geometry%') AND ("YEAR" = 2024) AND ("PER_PROF" NOT LIKE 's')
ORDER BY "PER_PROF"
LIMIT 5;

-- 2. How has proficiency rate in the Regents Exam (Geometry) changed from 2023 to 2024 in counties around NYC?

-- Create separate tables for 2023 and 2024
WITH table_2023 AS (
	SELECT "ENTITY_NAME", "YEAR", "PER_PROF"
	FROM "Annual_Regents_Exams"
	WHERE ("ENTITY_NAME" IN ('NYC Public Schools County', 'NEW YORK County', 'KINGS County', 'BRONX County', 'QUEENS County', 'RICHMOND County'))
		AND ("SUBJECT" LIKE '%Geometry') AND ("SUBGROUP_NAME" = 'All Students') AND ("PER_PROF" NOT LIKE 's') AND ("YEAR" = 2023)
),
table_2024 AS (
	SELECT "ENTITY_NAME", "YEAR", "PER_PROF"
	FROM "Annual_Regents_Exams"
	WHERE ("ENTITY_NAME" IN ('NYC Public Schools County', 'NEW YORK County', 'KINGS County', 'BRONX County', 'QUEENS County', 'RICHMOND County'))
		AND ("SUBJECT" LIKE '%Geometry') AND ("SUBGROUP_NAME" = 'All Students') AND ("PER_PROF" NOT LIKE 's') AND ("YEAR" = 2024)
)

-- Now, join them together
SELECT t1."ENTITY_NAME", t1."PER_PROF" AS per_prof_2023, t2."PER_PROF" AS per_prof_2024,
	t2."PER_PROF"::INTEGER - t1."PER_PROF"::INTEGER AS pct_change
FROM table_2023 t1 LEFT JOIN table_2024 t2
ON t1."ENTITY_NAME" = t2."ENTITY_NAME"
ORDER BY pct_change DESC;

-- 3. How does the proficiency rate in Common Core Geometry compare to other subfields of Common Core Mathematics in 2024?

CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM CROSSTAB($$
	SELECT "ENTITY_NAME", "SUBJECT", "PER_PROF"
	FROM "Annual_Regents_Exams"
	WHERE ("ENTITY_NAME" IN ('NYC Public Schools County', 'NEW YORK County', 'KINGS County', 'BRONX County', 'QUEENS County', 'RICHMOND County'))
		AND ("SUBJECT" IN ('Regents Common Core Algebra I', 'Regents Common Core Algebra II', 'Regents Common Core Geometry'))
		AND ("SUBGROUP_NAME" = 'All Students') AND ("PER_PROF" NOT LIKE 's') AND ("YEAR" = 2024)
$$) AS ct ("ENTITY_NAME" VARCHAR, "Regents_Common_Core_Algebra_I" VARCHAR, "Regents_Common_Core_Algebra_II" VARCHAR, "Regents_Common_Core_Geometry" VARCHAR)
ORDER BY "ENTITY_NAME";

-- Need to do crosstab because the subject names are aggregated in a shared column and I want to compare the subject proficiency rates together side by side

-- 4. How does the proficiency rate in Common Core Geometry in 2024 compare to the proficiency rate of Math Regents Exams in the cohort entering during 2019-2020? 

WITH agg_cohort AS (-- Aggregated cohort tested in Regents Math (incoming class 2019-20)
	SELECT "ENTITY_NAME", SUM("COHORT_COUNT"::INTEGER) - SUM("NUM_EXEMPT_NTEST"::INTEGER) AS agg_cohort_tested
	FROM "Total_Cohort_Regents_Exams"
	WHERE ("ENTITY_NAME" IN ('NYC Public Schools County', 'NEW YORK County', 'KINGS County', 'BRONX County', 'QUEENS County', 'RICHMOND County'))
		AND ("SUBGROUP_NAME" = 'All Students') AND ("PROF_%COHORT" NOT LIKE 's') AND ("SUBJECT" = 'MATH')
	GROUP BY "ENTITY_NAME"
),

agg_prof AS (-- Aggregated proficient students in Regents Math (incoming class 2019-20)
	SELECT "ENTITY_NAME", SUM("PROF_COUNT"::INTEGER) AS agg_prof_count
	FROM "Total_Cohort_Regents_Exams"
	WHERE ("ENTITY_NAME" IN ('NYC Public Schools County', 'NEW YORK County', 'KINGS County', 'BRONX County', 'QUEENS County', 'RICHMOND County'))
		AND ("SUBGROUP_NAME" = 'All Students') AND ("PROF_%COHORT" NOT LIKE 's') AND ("SUBJECT" = 'MATH')
	GROUP BY "ENTITY_NAME"
),

geom_2024 AS (-- Proficiency rate in Common Core Geometry (2024)
	SELECT "ENTITY_NAME", "PER_PROF"
			FROM "Annual_Regents_Exams"
			WHERE ("ENTITY_NAME" IN ('NYC Public Schools County', 'NEW YORK County', 'KINGS County', 'BRONX County', 'QUEENS County', 'RICHMOND County'))
				AND ("SUBJECT" = 'Regents Common Core Geometry') AND ("SUBGROUP_NAME" = 'All Students') AND ("PER_PROF" NOT LIKE 's') AND ("YEAR" = 2024)
)

/*
First, calculate the aggregated proficiency rate in Regents Math (incoming class 2019-20).
Then, compare them with the proficiency rate in Common Core Geometry (2024).
*/
SELECT c."ENTITY_NAME", c.agg_cohort_tested, p.agg_prof_count,
	ROUND((p.agg_prof_count::NUMERIC / c.agg_cohort_tested::NUMERIC * 100), 0) AS prof_math_incoming_2019_20,
	g."PER_PROF"::NUMERIC AS prof_geom_in_2024
FROM agg_cohort c LEFT JOIN agg_prof p ON c."ENTITY_NAME" = p."ENTITY_NAME"
LEFT JOIN geom_2024 g ON c."ENTITY_NAME" = g."ENTITY_NAME"
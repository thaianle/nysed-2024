-- 1. What is the top 5 counties that has the highest proficiency rate in the Regents Exam (Geometry) in 2024?
SELECT "ENTITY_NAME", "PER_PROF"
FROM "Annual_Regents_Exams"
WHERE ("ENTITY_NAME" LIKE '%County') AND ("SUBGROUP_NAME" = 'All Students')
	AND ("SUBJECT" LIKE '%Geometry%') AND ("YEAR" = 2024) AND ("PER_PROF" NOT LIKE 's')
ORDER BY "PER_PROF" DESC
LIMIT 5
-- Need to eliminate suppressed data

-- What about the reverse?
SELECT "ENTITY_NAME", "PER_PROF"
FROM "Annual_Regents_Exams"
WHERE ("ENTITY_NAME" LIKE '%County') AND ("SUBGROUP_NAME" = 'All Students')
	AND ("SUBJECT" LIKE '%Geometry%') AND ("YEAR" = 2024) AND ("PER_PROF" NOT LIKE 's')
ORDER BY "PER_PROF"
LIMIT 5
-- It seems like low proficiency rates in Geometry is concentrated around NYC... This might be a great starting point for the project

-- 2. How has proficiency rate in the Regents Exam (Geometry) changed from 2023 to 2024 in counties covering NYC?

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
ORDER BY pct_change DESC
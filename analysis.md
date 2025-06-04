1. What is the top 5 counties that has the highest proficiency rate in the Regents Exam (Geometry) in 2024?

```sql
SELECT "ENTITY_NAME", "PER_PROF"
FROM "Annual_Regents_Exams"
WHERE ("ENTITY_NAME" LIKE '%County') AND ("SUBGROUP_NAME" = 'All Students')
	AND ("SUBJECT" LIKE '%Geometry%') AND ("YEAR" = 2024) AND ("PER_PROF" NOT LIKE 's')
ORDER BY "PER_PROF" DESC
LIMIT 5
```

Result:
| **ENTITY_NAME**     | **PER_PROF** |
|---------------------|:------------:|
| **YATES County**    | 92           |
| **PUTNAM County**   | 83           |
| **WYOMING County**  | 82           |
| **SARATOGA County** | 82           |
| **LEWIS County**    | 81           |

What about the reverse?

```sql
SELECT "ENTITY_NAME", "PER_PROF"
FROM "Annual_Regents_Exams"
WHERE ("ENTITY_NAME" LIKE '%County') AND ("SUBGROUP_NAME" = 'All Students')
	AND ("SUBJECT" LIKE '%Geometry%') AND ("YEAR" = 2024) AND ("PER_PROF" NOT LIKE 's')
ORDER BY "PER_PROF"
LIMIT 5
```

Result:
| **ENTITY_NAME**               | **PER_PROF** |
|-------------------------------|:------------:|
| **BRONX County**              | 32           |
| **RICHMOND County**           | 41           |
| **NYC Public Schools County** | 42           |
| **KINGS County**              | 43           |
| **QUEENS County**             | 44           |

It seems like low proficiency rates in Geometry is concentrated around NYC... This might be a great starting point for the project

2. How has proficiency rate in the Regents Exam (Geometry) changed from 2023 to 2024 in counties covering NYC?

```sql
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
```

Result:
| **ENTITY_NAME**               | **per_prof_2023** | **per_prof_2024** | **pct_change** |
|-------------------------------|:-----------------:|:-----------------:|:--------------:|
| **QUEENS County**             | 38                | 44                | 6              |
| **BRONX County**              | 27                | 32                | 5              |
| **NYC Public Schools County** | 38                | 42                | 4              |
| **KINGS County**              | 40                | 43                | 3              |
| **NEW YORK County**           | 45                | 48                | 3              |
| **RICHMOND County**           | 39                | 41                | 2              |

Overall, all counties around NYC have seen an increase in the proficiency rate for Geometry in the Regents Exam, compared to the previous year.

3. Does the proficiency rate in Geometry is representative of other subjects (in 2024)?
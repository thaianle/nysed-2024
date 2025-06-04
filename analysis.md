# NYSED School Report Card Project

## Analysis File with Comments

### 1. What is the top 5 counties that has the highest and lowest proficiency rate in the Regents Exam (Geometry) in 2024?

```sql
SELECT "ENTITY_NAME", "PER_PROF"
FROM "Annual_Regents_Exams"
WHERE ("ENTITY_NAME" LIKE '%County') AND ("SUBGROUP_NAME" = 'All Students')
	AND ("SUBJECT" LIKE '%Geometry%') AND ("YEAR" = 2024) AND ("PER_PROF" NOT LIKE 's')
ORDER BY "PER_PROF" DESC
LIMIT 5;
```

Result:
| **ENTITY_NAME**     | **PER_PROF** |
|---------------------|:------------:|
| **YATES County**    | 92           |
| **PUTNAM County**   | 83           |
| **WYOMING County**  | 82           |
| **SARATOGA County** | 82           |
| **LEWIS County**    | 81           |

```sql
SELECT "ENTITY_NAME", "PER_PROF"
FROM "Annual_Regents_Exams"
WHERE ("ENTITY_NAME" LIKE '%County') AND ("SUBGROUP_NAME" = 'All Students')
	AND ("SUBJECT" LIKE '%Geometry%') AND ("YEAR" = 2024) AND ("PER_PROF" NOT LIKE 's')
ORDER BY "PER_PROF"
LIMIT 5;
```

Result:
| **ENTITY_NAME**               | **PER_PROF** |
|-------------------------------|:------------:|
| **BRONX County**              | 32           |
| **RICHMOND County**           | 41           |
| **NYC Public Schools County** | 42           |
| **KINGS County**              | 43           |
| **QUEENS County**             | 44           |

Contrary to some conventional beliefs, high proficiency rates in Geometry are concentrated in predominantly rural and suburban counties, and low proficiency rates are concentrated in the counties near New York City (NYC). This might be a great starting point for the project.

### 2. How has proficiency rate in the Regents Exam (Geometry) changed from 2023 to 2024 in counties around NYC?

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
ORDER BY pct_change DESC;
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

Compared to the previous year, all counties around NYC and NYC itself have witnessed an increase from 2 to 6 percentage points in the proficiency rate for Common Core Geometry in the NYSED Regents Exam, with Queens County and Bronx County had the greatest increase.

However, the proficiency rates in Geometry of all six counties, including NYC Public Schools, are still historically below average (50%).

### 3. How does the proficiency rate in Common Core Geometry compare to other subfields of Common Core Mathematics in 2024?

```sql
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM CROSSTAB($$
	SELECT "ENTITY_NAME", "SUBJECT", "PER_PROF"
	FROM "Annual_Regents_Exams"
	WHERE ("ENTITY_NAME" IN ('NYC Public Schools County', 'NEW YORK County', 'KINGS County', 'BRONX County', 'QUEENS County', 'RICHMOND County'))
		AND ("SUBJECT" IN ('Regents Common Core Algebra I', 'Regents Common Core Algebra II', 'Regents Common Core Geometry'))
		AND ("SUBGROUP_NAME" = 'All Students') AND ("PER_PROF" NOT LIKE 's') AND ("YEAR" = 2024)
$$) AS ct ("ENTITY_NAME" VARCHAR, "Regents_Common_Core_Algebra_I" VARCHAR, "Regents_Common_Core_Algebra_II" VARCHAR, "Regents_Common_Core_Geometry" VARCHAR)
ORDER BY "ENTITY_NAME"

-- Need to do crosstab because the subject names are aggregated in a shared column and I want to compare the subject proficiency rates together side by side
```

Result:
| **ENTITY_NAME**               | **Regents_Common_Core_Algebra_I** | **Regents_Common_Core_Algebra_II** | **Regents_Common_Core_Geometry** |
|-------------------------------|:---------------------------------:|:----------------------------------:|:--------------------------------:|
| **BRONX County**              | 30                                | 50                                 | 32                               |
| **KINGS County**              | 43                                | 54                                 | 29                               |
| **NEW YORK County**           | 67                                | 35                                 | 48                               |
| **NYC Public Schools County** | 42                                | 57                                 | 31                               |
| **QUEENS County**             | 44                                | 56                                 | 35                               |
| **RICHMOND County**           | 22                                | 68                                 | 41                               |

In all six counties around NYC, Geometry is not the subfield with the highest proficiency rate compared to other subfields of Common Core Mathematics. In fact, Geometry has the lowest proficiency rate among three subfields in Kings County, NYC Public Schools County, and Queens County.
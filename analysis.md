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

### 4. How does the proficiency rate in Common Core Geometry in 2024 compare to the proficiency rate of Math Regents Exams in the cohort entering during 2019-2020? 

**(Work in progress)**

The proficiency rate of a cohort is taken by dividing the number of students in total cohort scoring proficient by the number of students in total cohort and then multiplying it by 100. However, the provided proficiency rate overlooked the number of students who received an exempt without a valid score, likely due to the [COVID-19 pandemic](https://www.nysed.gov/sites/default/files/programs/curriculum-instruction/exemptionflyer.pdf) or [some other major life events](https://www.nysed.gov/grad-measures/news/exemptions-diploma-assessment-requirements-major-life-events). My code solved this problem, and also took the proficiency rates of the aggregated cohort entering high school in either 2019 or 2020.

```sql
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
```

Result:
| **ENTITY_NAME**               | **agg_cohort_tested** | **agg_prof_count** | **prof_math_incoming_2019_20** | **prof_geom_in_2024** |
|-------------------------------|:---------------------:|:------------------:|:------------------------------:|:---------------------:|
| **RICHMOND County**           | 7537                  | 3476               | 46                             | 41                    |
| **BRONX County**              | 21398                 | 7835               | 37                             | 32                    |
| **NYC Public Schools County** | 122517                | 58345              | 48                             | 42                    |
| **NEW YORK County**           | 25448                 | 12681              | 50                             | 48                    |
| **KINGS County**              | 34733                 | 17135              | 49                             | 43                    |
| **QUEENS County**             | 33401                 | 17218              | 52                             | 44                    |

# NYSED School Report Card Project

## Analysis File with Comments

### 1. What is the top 5 counties that has the highest and lowest proficiency rate in the Regents Exam (Geometry) in 2024?

```sql
-- Top 5 counties with highest proficiency rate
SELECT "ENTITY_NAME", "PER_PROF"
FROM "Annual_Regents_Exams"
WHERE ("ENTITY_NAME" LIKE '%County') AND ("SUBGROUP_NAME" = 'All Students')
	AND ("SUBJECT" LIKE '%Geometry%') AND ("YEAR" = 2024) AND ("PER_PROF" NOT LIKE 's')
ORDER BY "PER_PROF"::NUMERIC DESC
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
-- Top 5 counties with lowest proficiency rate
SELECT "ENTITY_NAME", "PER_PROF"
FROM "Annual_Regents_Exams"
WHERE ("ENTITY_NAME" LIKE '%County') AND ("SUBGROUP_NAME" = 'All Students')
	AND ("SUBJECT" LIKE '%Geometry%') AND ("YEAR" = 2024) AND ("PER_PROF" NOT LIKE 's')
ORDER BY "PER_PROF"::NUMERIC
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
-- Need to do crosstab because the subject names are aggregated in a shared column and I want to compare the subject proficiency rates together side by side

CREATE EXTENSION IF NOT EXISTS tablefunc; -- Enable the tablefunc extension to do crosstab

SELECT * FROM CROSSTAB($$
	SELECT "ENTITY_NAME", "SUBJECT", "PER_PROF"
	FROM "Annual_Regents_Exams"
	WHERE ("ENTITY_NAME" IN ('NYC Public Schools County', 'NEW YORK County', 'KINGS County', 'BRONX County', 'QUEENS County', 'RICHMOND County'))
		AND ("SUBJECT" IN ('Regents Common Core Algebra I', 'Regents Common Core Algebra II', 'Regents Common Core Geometry'))
		AND ("SUBGROUP_NAME" = 'All Students') AND ("PER_PROF" NOT LIKE 's') AND ("YEAR" = 2024)
$$) AS ct ("ENTITY_NAME" VARCHAR, "Regents_Common_Core_Algebra_I" VARCHAR, "Regents_Common_Core_Algebra_II" VARCHAR, "Regents_Common_Core_Geometry" VARCHAR)
ORDER BY "ENTITY_NAME";
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
LEFT JOIN geom_2024 g ON c."ENTITY_NAME" = g."ENTITY_NAME";
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

The proficiency rate in Geometry is lower than the general proficiency rate in Math for all six regions around NYC by 2-8 percentage points. These figures may suggest that Geometry might be a difficult subfield of mathematics that students in New York State typically struggle more than usual to pass.

The aggregated proficiency rates in Regents Math in all regions around NYC are near average (50%), which is slightly better than that in Regents Geometry alone, but not impressive as in many other parts of New York State.

### 5. At a school level, which schools have the highest proficiency rate in Regents Common Core Geometry exams in 2024?
(Work in progress)

There are actually 58 schools that has a 100% proficiency rate in the Regents Common Core Geometry exam in 2024 (when I changed the SELECT statement in the code block below to ```SELECT COUNT("INSTITUTION_ID")```), so I decided to print out the first 10 schools listed in the dataset.

```sql
SELECT "ENTITY_NAME", "TESTED", "PER_PROF"
FROM "Annual_Regents_Exams"
WHERE ("SUBGROUP_NAME" = 'All Students') AND ("SUBJECT" LIKE '%Geometry%') AND ("YEAR" = 2024) AND ("PER_PROF" NOT LIKE 's')
	AND ("ENTITY_CD" NOT LIKE '%0000') AND ("ENTITY_NAME" NOT LIKE '%Category%') AND ("PER_PROF"::NUMERIC = 100)
ORDER BY "ENTITY_NAME"
LIMIT 10;
```

Result:
| **ENTITY_NAME**                         | **TESTED** | **PER_PROF** |
|-----------------------------------------|:----------:|:------------:|
| **ACADIA MIDDLE SCHOOL**                | 12         | 100          |
| **ALBERT LEONARD MIDDLE SCHOOL**        | 35         | 100          |
| **ALGONQUIN MIDDLE SCHOOL**             | 13         | 100          |
| **ATTICA SENIOR HIGH SCHOOL**           | 37         | 100          |
| **BARKER ROAD MIDDLE SCHOOL**           | 9          | 100          |
| **BELLEVILLE HENDERSON CENTRAL SCHOOL** | 18         | 100          |
| **BETHLEHEM CENTRAL MIDDLE SCHOOL**     | 27         | 100          |
| **BRADFORD CENTRAL SCHOOL**             | 9          | 100          |
| **BRIARCLIFF HIGH SCHOOL**              | 82         | 100          |
| **CALKINS ROAD MIDDLE SCHOOL**          | 14         | 100          |

We can see that many of these perfect proficiency rates are actually inflated by the fact that perhaps only a few high-achieving students took the exam, especially when students have a choice between [Algebra I, Geometry, and Algebra II/ Trigonometry](https://www.schools.nyc.gov/learning/student-journey/graduation-requirements) for their high school graduation requirements. There are many middle schools in the list, which also supports my hypothesis of a selection bias because the Regents exams are originally for high school students.

Therefore, to make more valid conclusions, I decided to filter for schools with at least 100 students tested in the Regents Common Core Geometry exam. I also extracted the first two digits in the entity code (```ENTITY_CD```) to get the county code associated with each school.

```sql
SELECT "ENTITY_NAME", SUBSTRING("ENTITY_CD", 1, 2) AS county_code, "TESTED", "PER_PROF"
FROM "Annual_Regents_Exams"
WHERE ("SUBGROUP_NAME" = 'All Students') AND ("SUBJECT" LIKE '%Geometry%') AND ("YEAR" = 2024) AND ("PER_PROF" NOT LIKE 's')
	AND ("ENTITY_CD" NOT LIKE '%0000') AND ("ENTITY_NAME" NOT LIKE '%Category%') AND ("PER_PROF"::NUMERIC >= 98)
	AND ("TESTED"::NUMERIC >= 100)
ORDER BY "PER_PROF"::NUMERIC DESC;
```

Result:
| **ENTITY_NAME**                          | **county_code** | **TESTED** | **PER_PROF** |
|------------------------------------------|:---------------:|:----------:|:------------:|
| **ROBERT CUSHMAN MURPHY JR HIGH SCHOOL** | 58              | 113        | 100          |
| **STUYVESANT HIGH SCHOOL**               | 31              | 780        | 100          |
| **STATEN ISLAND TECHNICAL HS**           | 35              | 333        | 100          |
| **BROOKLYN TECHNICAL HS**                | 33              | 1440       | 99           |
| **COLUMBIA HIGH SCHOOL**                 | 49              | 180        | 99           |
| **HARRISON HIGH SCHOOL**                 | 66              | 188        | 99           |
| **YORKTOWN HIGH SCHOOL**                 | 66              | 150        | 99           |
| **NORTH SYRACUSE JUNIOR HS**             | 42              | 135        | 99           |
| **MHS AMES CAMPUS**                      | 28              | 161        | 99           |
| **MANHASSET SECONDARY SCHOOL**           | 28              | 205        | 99           |
| **HONEOYE FALLS-LIMA SENIOR HIGH SCH**   | 26              | 128        | 98           |
| **NORTH SHORE SENIOR HIGH SCHOOL**       | 28              | 165        | 98           |
| **QUEENS HS -SCIENCES-YORK COLLEGE**     | 34              | 106        | 98           |
| **GARDEN CITY HIGH SCHOOL**              | 28              | 261        | 98           |
| **IRVINGTON HIGH SCHOOL**                | 66              | 105        | 98           |
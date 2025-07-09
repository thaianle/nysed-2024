# NYSED School Report Card Project

## Part 2: Data Preparation for Machine Learning Models with PostgreSQL (ongoing)

#### Names of all schools: ```institutions```

_This table contains data from elementary, middle, and high schools. By joining tables later, we would eliminate the elementary and middle schools in the final result._

```sql
SELECT "INSTITUTION_ID", "ENTITY_CD", "ENTITY_NAME"
FROM "Institution_Grouping"
WHERE "GROUP_NAME" = 'Public School'
```

The entire result contains 4754 rows.

First 5 rows of the table:
| **INSTITUTION_ID** | **ENTITY_CD** | **ENTITY_NAME**            |
|--------------------|---------------|----------------------------|
| **800000053466**   | 130200010003  | GLENHAM SCHOOL             |
| **800000053467**   | 130200010004  | ROMBOUT MIDDLE SCHOOL      |
| **800000053468**   | 130200010005  | BEACON HIGH SCHOOL         |
| **800000053469**   | 130200010006  | SARGENT SCHOOL             |
| **800000053451**   | 130502020001  | WINGDALE ELEMENTARY SCHOOL |

#### Core and weighted performance: ```core_and_weighted```

More information:
https://www.nysed.gov/sites/default/files/programs/accountability/hs-weighted-fact-sheet.pdf

https://www.nysed.gov/sites/default/files/programs/accountability/0625_reimagine-fact-sheet_hs-core.pdf

```sql
SELECT "INSTITUTION_ID", "ENTITY_CD", "ENTITY_NAME", "WEIGHTED_COHORT", "WEIGHTED_INDEX"
FROM "ACC_HS_Core_and_Weighted_Performance"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("SUBGROUP_NAME" = 'All Students') AND ("SUBJECT" = 'Combined') AND ("WEIGHTED_COHORT"::INTEGER >= 50)
```
The entire result contains 1224 rows.

First 5 rows of the table:

| **INSTITUTION_ID** | **ENTITY_CD** | **ENTITY_NAME**                      | **WEIGHTED_COHORT** | **WEIGHTED_INDEX** |
|--------------------|---------------|--------------------------------------|--------------------:|-------------------:|
| **800000055743**   | 010100010034  | ALBANY HIGH SCHOOL                   | 1816                | 82.2               |
| **800000059776**   | 010100860907  | GREEN TECH HIGH CHARTER SCHOOL       | 127                 | 42                 |
| **800000068133**   | 010100860960  | ALBANY LEADERSHIP CS-GIRLS           | 105                 | 46.8               |
| **800000055479**   | 010201040001  | BERNE-KNOX-WESTERLO JUNIOR-SENIOR HS | 180                 | 142.3              |
| **800000055439**   | 010306060008  | BETHLEHEM CENTRAL SENIOR HIGH SCHOOL | 1038                | 198.1              |

#### Chronic absenteeism: ```chronic_absenteeism```

```sql
SELECT "INSTITUTION_ID", "ENTITY_CD", "ENTITY_NAME", "ABSENT_COUNT", "ENROLLMENT",
	"ABSENT_COUNT"::NUMERIC / "ENROLLMENT"::NUMERIC AS "ABSENT_RATE"
FROM "ACC_HS_Chronic_Absenteeism"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("SUBGROUP_NAME" = 'All Students') AND ("ABSENT_COUNT" != 's') AND ("ENROLLMENT" != 's')
	AND ("ENROLLMENT"::INTEGER >= 50)
```

The entire result contains 1293 rows.

First 5 rows of the table:

| **INSTITUTION_ID** | **ENTITY_CD** | **ENTITY_NAME**                      | **ABSENT_COUNT** | **ENROLLMENT** | **ABSENT_RATE**        |
|--------------------|---------------|--------------------------------------|-----------------:|---------------:|-----------------------:|
| **800000055743**   | 010100010034  | ALBANY HIGH SCHOOL                   | 1550             | 3046           | 0.50886408404464871963 |
| **800000059776**   | 010100860907  | GREEN TECH HIGH CHARTER SCHOOL       | 163              | 304            | 0.53618421052631578947 |
| **800000068133**   | 010100860960  | ALBANY LEADERSHIP CS-GIRLS           | 56               | 236            | 0.23728813559322033898 |
| **800000055479**   | 010201040001  | BERNE-KNOX-WESTERLO JUNIOR-SENIOR HS | 42               | 222            | 0.18918918918918918919 |
| **800000055439**   | 010306060008  | BETHLEHEM CENTRAL SENIOR HIGH SCHOOL | 155              | 1374           | 0.11280931586608442504 |

#### Graduation rate: ```graduation_rate```

```sql
SELECT "INSTITUTION_ID", "ENTITY_CD", "ENTITY_NAME", "GRAD_COUNT", "COHORT_COUNT",
	"GRAD_COUNT"::NUMERIC / "COHORT_COUNT"::NUMERIC AS "GRAD_RATE"
FROM "ACC_HS_Graduation_Rate"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("SUBGROUP_NAME" = 'All Students') AND ("COHORT" = '4-Year') AND ("GRAD_COUNT" != 's')
	AND ("COHORT_COUNT" != 's') AND ("COHORT_COUNT"::INTEGER >= 50)
```

The entire result contains 1068 rows.

First 5 rows of the table:

| **INSTITUTION_ID** | **ENTITY_CD** | **ENTITY_NAME**                      | **GRAD_COUNT** | **COHORT_COUNT** | **GRAD_RATE**          |
|--------------------|---------------|--------------------------------------|---------------:|-----------------:|-----------------------:|
| **800000055743**   | 010100010034  | ALBANY HIGH SCHOOL                   | 549            | 704              | 0.77982954545454545455 |
| **800000059776**   | 010100860907  | GREEN TECH HIGH CHARTER SCHOOL       | 49             | 54               | 0.90740740740740740741 |
| **800000068133**   | 010100860960  | ALBANY LEADERSHIP CS-GIRLS           | 50             | 55               | 0.90909090909090909091 |
| **800000055479**   | 010201040001  | BERNE-KNOX-WESTERLO JUNIOR-SENIOR HS | 47             | 53               | 0.88679245283018867925 |
| **800000055406**   | 010601060008  | COLONIE CENTRAL HIGH SCHOOL          | 359            | 402              | 0.89303482587064676617 |

#### Participation rate: ```participation_rate```

```sql
CREATE EXTENSION IF NOT EXISTS tablefunc;

/*
HS ELA and HS Math results organized only by Institution ID.
In the original table, participation rate is assembled in a long format with a "subject" column.
I used the crosstab extension in SQL to put the participation rate in ELA and Math in separate columns.
*/

WITH ela_math_scores AS (
	SELECT * FROM CROSSTAB($$
		SELECT "INSTITUTION_ID", "SUBJECT", "RATE"
		FROM "ACC_HS_Participation_Rate"
		WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
			AND ("SUBGROUP_NAME" = 'All Students') AND ("COHORT"::INTEGER >= 50)
	$$) AS ct ("INSTITUTION_ID" VARCHAR, "ELA_P_RATE" VARCHAR, "MATH_P_RATE" VARCHAR)
),

-- Create another table containing information of the entity, including the entity CD and entity name
entity_info AS (
	SELECT "INSTITUTION_ID", "ENTITY_CD", "ENTITY_NAME"
	FROM "ACC_HS_Participation_Rate"
	WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
		AND ("SUBGROUP_NAME" = 'All Students') AND ("COHORT"::INTEGER >= 50)
)

-- Now, merge the Institution ID information with entity CD and entity name
SELECT DISTINCT s."INSTITUTION_ID", e."ENTITY_CD", e."ENTITY_NAME", s."ELA_P_RATE", s."MATH_P_RATE"
-- Use the DISTINCT keyword to avoid duplicates
FROM ela_math_scores s LEFT JOIN entity_info e
ON s."INSTITUTION_ID" = e."INSTITUTION_ID"
```

The entire result contains 1036 rows.

First 5 rows of the table:

| **INSTITUTION_ID** | **ENTITY_CD** | **ENTITY_NAME**            | **ELA_P_RATE** | **MATH_P_RATE** |
|--------------------|---------------|----------------------------|---------------:|----------------:|
| **800000033912**   | 241001060003  | DANSVILLE HIGH SCHOOL      | 100            | 84.9            |
| **800000033934**   | 240801060002  | LIVONIA MIDDLE/HIGH SCHOOL | 99.3           | 64.2            |
| **800000033936**   | 241701040004  | YORK MIDDLE/HIGH SCHOOL    | 100            | 82.5            |
| **800000033940**   | 430501040001  | BLOOMFIELD HIGH SCHOOL     | 98.3           | 92.9            |
| **800000033954**   | 431101040002  | RED JACKET HIGH SCHOOL     | 100            | 96.6            |

#### Expenditures per pupil: ```expenditures_per_pupil```

_This table contains data from elementary, middle, and high schools. By joining tables later, we would eliminate the elementary and middle schools in the final result._

```sql
SELECT "INSTITUTION_ID", "ENTITY_CD", "ENTITY_NAME", "PUPIL_COUNT_TOT", "FED_STATE_LOCAL_EXP",
	"FED_STATE_LOCAL_EXP" / "PUPIL_COUNT_TOT" AS "PER_FED_STATE_LOCAL_EXP"
FROM "Expenditures_per_Pupil"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("PUPIL_COUNT_TOT" >= 50)
```

The entire result contains 4705 rows.

First 5 rows of the table:

| **INSTITUTION_ID** | **ENTITY_CD** | **ENTITY_NAME**                | **PUPIL_COUNT_TOT** | **FED_STATE_LOCAL_EXP** | **PER_FED_STATE_LOCAL_EXP** |
|--------------------|---------------|--------------------------------|--------------------:|------------------------:|----------------------------:|
| **800000055730**   | 010100010014  | MONTESSORI MAGNET SCHOOL       | 324                 | 11061662                | 34140.932098765436          |
| **800000055731**   | 010100010016  | PINE HILLS ELEMENTARY SCHOOL   | 347                 | 12070976                | 34786.67435158502           |
| **800000055732**   | 010100010018  | DELAWARE COMMUNITY SCHOOL      | 311                 | 8803017                 | 28305.520900321542          |
| **800000055733**   | 010100010019  | NEW SCOTLAND ELEMENTARY SCHOOL | 459                 | 15850733                | 34533.187363834426          |
| **800000055736**   | 010100010023  | ALBANY SCHOOL OF HUMANITIES    | 332                 | 13755312                | 41431.66265060241           |

#### Inexperienced teachers and principals: ```inexp_teachers```

_This table contains data from elementary, middle, and high schools. By joining tables later, we would eliminate the elementary and middle schools in the final result._

```sql
SELECT "INSTITUTION_ID", "ENTITY_CD", "ENTITY_NAME", "NUM_TEACH", "NUM_TEACH_INEXP", "PER_TEACH_INEXP",
	"NUM_TEACH_INEXP"::NUMERIC / "NUM_TEACH"::NUMERIC * 100 AS "PER_TEACH_INEXP_calc"
FROM "Inexperienced_Teachers_and_Principals"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("NUM_TEACH" >= 10)
```

The entire result contains 4640 rows.

First 5 rows of the table:

| **INSTITUTION_ID** | **ENTITY_CD** | **ENTITY_NAME**                | **NUM_TEACH** | **NUM_TEACH_INEXP** | **PER_TEACH_INEXP**     |
|--------------------|---------------|--------------------------------|--------------:|--------------------:|------------------------:|
| **800000055730**   | 010100010014  | MONTESSORI MAGNET SCHOOL       | 29            | 5                   | 17.24137931034482758600 |
| **800000055731**   | 010100010016  | PINE HILLS ELEMENTARY SCHOOL   | 55            | 23                  | 41.81818181818181818200 |
| **800000055732**   | 010100010018  | DELAWARE COMMUNITY SCHOOL      | 49            | 24                  | 48.97959183673469387800 |
| **800000055733**   | 010100010019  | NEW SCOTLAND ELEMENTARY SCHOOL | 61            | 20                  | 32.78688524590163934400 |
| **800000055736**   | 010100010023  | ALBANY SCHOOL OF HUMANITIES    | 40            | 10                  | 25.00000000000000000000 |

#### Teachers teaching out of certification: ```teacher_out_cert```

_This table contains data from elementary, middle, and high schools. By joining tables later, we would eliminate the elementary and middle schools in the final result._

```sql
SELECT "INSTITUTION_ID", "ENTITY_CD", "ENTITY_NAME", "NUM_TEACH_OC", "NUM_OUT_CERT",
	"NUM_OUT_CERT" / "NUM_TEACH_OC" * 100 AS "PER_OUT_CERT"
FROM "Teachers_Teaching_Out_of_Certification"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("NUM_TEACH_OC" >= 10)
```

The entire result contains 4613 rows.

First 5 rows of the table:

| **INSTITUTION_ID** | **ENTITY_CD** | **ENTITY_NAME**                | **NUM_TEACH_OC** | **NUM_OUT_CERT** | **PER_OUT_CERT**       |
|--------------------|---------------|--------------------------------|-----------------:|-----------------:|-----------------------:|
| **800000055730**   | 010100010014  | MONTESSORI MAGNET SCHOOL       | 25               | 1                | 4.00000000000000000000 |
| **800000055731**   | 010100010016  | PINE HILLS ELEMENTARY SCHOOL   | 46               | 0                | 0.00000000000000000000 |
| **800000055732**   | 010100010018  | DELAWARE COMMUNITY SCHOOL      | 41               | 1                | 2.43902439024390243900 |
| **800000055733**   | 010100010019  | NEW SCOTLAND ELEMENTARY SCHOOL | 52               | 0                | 0.00000000000000000000 |
| **800000055736**   | 010100010023  | ALBANY SCHOOL OF HUMANITIES    | 33               | 0                | 0.00000000000000000000 |

#### Joining all these tables to prepare data:
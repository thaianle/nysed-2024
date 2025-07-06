# NYSED School Report Card Project

## Part 2: Data Preparation for Machine Learning Models with PostgreSQL (ongoing)

Core and weighted performance:

More information:
https://www.nysed.gov/sites/default/files/programs/accountability/hs-weighted-fact-sheet.pdf

https://www.nysed.gov/sites/default/files/programs/accountability/0625_reimagine-fact-sheet_hs-core.pdf

```sql
SELECT "INSTITUTION_ID", "ENTITY_CD", "ENTITY_NAME", "WEIGHTED_COHORT", "WEIGHTED_INDEX"
FROM "ACC_HS_Core_and_Weighted_Performance"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("SUBGROUP_NAME" = 'All Students') AND ("SUBJECT" = 'Combined') AND ("WEIGHTED_COHORT"::INTEGER >= 100)
```

First 5 rows of the table:

| **INSTITUTION_ID** | **ENTITY_CD** | **ENTITY_NAME**                      | **WEIGHTED_COHORT** | **WEIGHTED_INDEX** |
|--------------------|---------------|--------------------------------------|--------------------:|-------------------:|
| **800000055743**   | 010100010034  | ALBANY HIGH SCHOOL                   | 1816                | 82.2               |
| **800000059776**   | 010100860907  | GREEN TECH HIGH CHARTER SCHOOL       | 127                 | 42                 |
| **800000068133**   | 010100860960  | ALBANY LEADERSHIP CS-GIRLS           | 105                 | 46.8               |
| **800000055479**   | 010201040001  | BERNE-KNOX-WESTERLO JUNIOR-SENIOR HS | 180                 | 142.3              |
| **800000055439**   | 010306060008  | BETHLEHEM CENTRAL SENIOR HIGH SCHOOL | 1038                | 198.1              |

Chronic absenteeism:

```sql
SELECT "INSTITUTION_ID", "ENTITY_CD", "ENTITY_NAME", "ABSENT_COUNT", "ENROLLMENT",
	"ABSENT_COUNT"::NUMERIC / "ENROLLMENT"::NUMERIC AS "ABSENT_RATE"
FROM "ACC_HS_Chronic_Absenteeism"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("SUBGROUP_NAME" = 'All Students') AND ("ABSENT_COUNT" != 's') AND ("ENROLLMENT" != 's')
	AND ("ENROLLMENT"::INTEGER >= 100)
```

First 5 rows of the table:

| **INSTITUTION_ID** | **ENTITY_CD** | **ENTITY_NAME**                      | **ABSENT_COUNT** | **ENROLLMENT** | **ABSENT_RATE**        |
|--------------------|---------------|--------------------------------------|-----------------:|---------------:|-----------------------:|
| **800000055743**   | 010100010034  | ALBANY HIGH SCHOOL                   | 1550             | 3046           | 0.50886408404464871963 |
| **800000059776**   | 010100860907  | GREEN TECH HIGH CHARTER SCHOOL       | 163              | 304            | 0.53618421052631578947 |
| **800000068133**   | 010100860960  | ALBANY LEADERSHIP CS-GIRLS           | 56               | 236            | 0.23728813559322033898 |
| **800000055479**   | 010201040001  | BERNE-KNOX-WESTERLO JUNIOR-SENIOR HS | 42               | 222            | 0.18918918918918918919 |
| **800000055439**   | 010306060008  | BETHLEHEM CENTRAL SENIOR HIGH SCHOOL | 155              | 1374           | 0.11280931586608442504 |

Graduation rate:
```sql
SELECT "INSTITUTION_ID", "ENTITY_CD", "ENTITY_NAME", "GRAD_COUNT", "COHORT_COUNT",
	"GRAD_COUNT"::NUMERIC / "COHORT_COUNT"::NUMERIC AS "GRAD_RATE"
FROM "ACC_HS_Graduation_Rate"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("SUBGROUP_NAME" = 'All Students') AND ("COHORT" = '4-Year') AND ("GRAD_COUNT" != 's')
	AND ("COHORT_COUNT" != 's') AND ("COHORT_COUNT"::INTEGER >= 100)
```

First 5 rows of the table:

| **INSTITUTION_ID** | **ENTITY_CD** | **ENTITY_NAME**                      | **GRAD_COUNT** | **COHORT_COUNT** | **GRAD_RATE**          |
|--------------------|---------------|--------------------------------------|---------------:|-----------------:|-----------------------:|
| **800000055743**   | 010100010034  | ALBANY HIGH SCHOOL                   | 549            | 704              | 0.77982954545454545455 |
| **800000055406**   | 010601060008  | COLONIE CENTRAL HIGH SCHOOL          | 359            | 402              | 0.89303482587064676617 |
| **800000055375**   | 010623060010  | SHAKER HIGH SCHOOL                   | 491            | 519              | 0.94605009633911368015 |
| **800000055439**   | 010306060008  | BETHLEHEM CENTRAL SENIOR HIGH SCHOOL | 333            | 349              | 0.95415472779369627507 |
| **800000055436**   | 010402060001  | RAVENA-COEYMANS-SELKIRK SR HS        | 118            | 133              | 0.88721804511278195489 |

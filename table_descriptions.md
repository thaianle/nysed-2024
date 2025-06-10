# NYSED School Report Card Project

## Condensed table and variable descriptions (Updated June 9, 2025)

Because the NYSED School Report Card database contains many tables and variables that may need some outside research or domain knowledge to understand, I have created a condensed table and variable description, which is this document, to better communicate to the potential readers of my portfolio.

For more information, please check the original README file provided in [this repository](https://github.com/thaianle/nysed-2024/blob/main/data/SRC2024ReadMe_Group4.pdf). This description only contains names of the tables and columns used in the [analysis file](https://github.com/thaianle/nysed-2024/blob/main/analysis.md).

All columns contain text data which is interpreted as VARCHAR in PostgreSQL, unless otherwise stated. There exists a foreign key relationship between columns with the same name across different tables, unless otherwise stated.

### Table 1: Annual_Regents_Exams

A table that outlines the results of the Regents Exams, which is a standardized set of examinations that high school students in New York State have to take in order to be eligible for graduation. The required set of examinations cover some subjects such as English Language Arts, mathematics, natural and social sciences. [(link)](https://www.schools.nyc.gov/learning/student-journey/graduation-requirements)

The score for each test is proportionately scaled from 0 to 100. Scores are further split into five levels: Level 5 (distinction: 85-100), Level 4 (meet expectations: 76-84), Level 3 (proficient: 65-75), Level 2 (safety net: 55-64), Level 1 (failing: below 55) are rated from Level 1 to Level 5, in which Level 5 is the highest and Level 1 is the lowest score. [(link)](https://www.nysed.gov/state-assessment/how-are-regents-examinations-scored)

- **INSTITUTION_ID** (*Primary Key*): A 12-digit unique identifier for each institution, which is unchanged over time
- **ENTITY_CD**: A 12-digit unique code for each entity (can be school, district, or county), which contains identifiers for geographical locations, school districts, and buildings; subject to geographical and administrative changes
- **ENTITY_NAME**: Name of the entity (can be school, district, or county)
- **YEAR** (*INTEGER*): Reporting year
- **SUBJECT**: Examination subject
- **SUBGROUP_NAME**: Demographic subgroup name (including race and ethnicity, socio-economic and educational backgrounds)
- **PER_PROF**: Percent of tested student scoring proficient (Level 3 and above)

### Table 2: Total_Cohort_Regents_Exams

This table also outlines the results of the Regents Exams like Table 1, but instead of aggregating data in terms of year administered, it aggregates the data in terms of student cohort or class year (for example, Class of 2023 or Class of 2024).

The cohort contains proportion of students who received an exempt from the test, likely due to the [COVID-19 pandemic](https://www.nysed.gov/sites/default/files/programs/curriculum-instruction/exemptionflyer.pdf) or [some other major life events](https://www.nysed.gov/grad-measures/news/exemptions-diploma-assessment-requirements-major-life-events).

- **INSTITUTION_ID** (*Primary Key*): A 12-digit unique identifier for each institution, which is unchanged over time
- **ENTITY_CD**: A 12-digit unique code for each entity (can be school, district, or county), which contains identifiers for geographical locations, school districts, and buildings; subject to geographical and administrative changes
- **ENTITY_NAME**: Name of the entity (can be school, district, or county)
- **SUBGROUP_NAME**: Demographic subgroup name (including race and ethnicity, socio-economic and educational backgrounds)
- **COHORT_COUNT**: Number of students in total cohort
- **PROF_COUNT**: Number of students in total cohort scoring proficient (Level 3 and above)
- **NUM_EXEMPT_NTEST**: Number of students who received an exempt without a valid score
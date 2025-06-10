# NYSED School Report Card Project

## Condensed table and variable descriptions (Updated June 9, 2025)

Because the NYSED School Report Card database contains many tables and variables . In addition, the database contains some variables and metrics that need some outside research or domain knowledge to understand. Therefore, I have created a condensed table and variable description, which is this document, to better communicate to the readers what variables are there to say.

For more information, please check the original README file provided in this repository.

All columns contain text data which is interpreted as VARCHAR in PostgreSQL, unless otherwise stated. All common column names are supposed to contain the similar types of information and data, unless otherwise stated.

### Table 1: Annual_Regents_Exams

A table that outlines the results of the Regents Exams, which is the exam that high school students in New York have to take in order to be eligible for graduation. The scores are rated from Level 1 to Level 5, in which Level 5 is the highest and Level 1 is the lowest score.

- **ENTITY_NAME**: Name of the entity (can be school, district, or county)
- **YEAR** (*Number*): Reporting year
- **SUBJECT**: Examination subject
- **SUBGROUP_NAME**: Demographic subgroup name (including race and ethnicity, socio-economic and educational backgrounds)
- **PER_PROF**: Percent of tested student scoring proficient (Level 3 and above)

### Table 2: Total_Cohort_Regents_Exams

This table also outlines the results of the Regents Exams like Table 1, but instead of aggregating data in terms of year administered, it aggregates the data in terms of student cohort or class year (for example, Class of 2023 or Class of 2024).

The cohort contains proportion of students who received an exempt from the test, likely due to the[COVID-19 pandemic](https://www.nysed.gov/sites/default/files/programs/curriculum-instruction/exemptionflyer.pdf) or [some other major life events](https://www.nysed.gov/grad-measures/news/exemptions-diploma-assessment-requirements-major-life-events).

- **ENTITY_NAME**: Name of the entity (can be school, district, or county)
- **SUBGROUP_NAME**: Demographic subgroup name (including race and ethnicity, socio-economic and educational backgrounds)
- **COHORT_COUNT**: Number of students in total cohort
- **PROF_COUNT**: Number of students in total cohort scoring proficient (Level 3 and above)
- **NUM_EXEMPT_NTEST**: Number of students who received an exempt without a valid score
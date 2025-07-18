CREATE EXTENSION IF NOT EXISTS tablefunc;

WITH institutions AS (
SELECT "INSTITUTION_ID", "ENTITY_CD", "ENTITY_NAME"
FROM "Institution_Grouping"
WHERE "GROUP_NAME" = 'Public School'
),

core_and_weighted AS (
SELECT "INSTITUTION_ID", "WEIGHTED_COHORT", "WEIGHTED_INDEX"
FROM "ACC_HS_Core_and_Weighted_Performance"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("SUBGROUP_NAME" = 'All Students') AND ("SUBJECT" = 'Combined') AND ("WEIGHTED_COHORT"::INTEGER >= 50)
),

chronic_absenteeism AS (
SELECT "INSTITUTION_ID", "ABSENT_COUNT", "ENROLLMENT",
	"ABSENT_COUNT"::NUMERIC / "ENROLLMENT"::NUMERIC AS "ABSENT_RATE"
FROM "ACC_HS_Chronic_Absenteeism"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("SUBGROUP_NAME" = 'All Students') AND ("ABSENT_COUNT" != 's') AND ("ENROLLMENT" != 's')
	AND ("ENROLLMENT"::INTEGER >= 50)
),

graduation_rate AS (
SELECT "INSTITUTION_ID", "GRAD_COUNT", "COHORT_COUNT",
	"GRAD_COUNT"::NUMERIC / "COHORT_COUNT"::NUMERIC AS "GRAD_RATE"
FROM "ACC_HS_Graduation_Rate"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("SUBGROUP_NAME" = 'All Students') AND ("COHORT" = '4-Year') AND ("GRAD_COUNT" != 's')
	AND ("COHORT_COUNT" != 's') AND ("COHORT_COUNT"::INTEGER >= 50)
),

participation_rate AS (
	SELECT * FROM CROSSTAB($$
		SELECT "INSTITUTION_ID", "SUBJECT", "RATE"
		FROM "ACC_HS_Participation_Rate"
		WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
			AND ("SUBGROUP_NAME" = 'All Students') AND ("COHORT"::INTEGER >= 50)
	$$) AS ct ("INSTITUTION_ID" VARCHAR, "ELA_P_RATE" VARCHAR, "MATH_P_RATE" VARCHAR)
),

expenditures_per_pupil AS (
SELECT "INSTITUTION_ID", "PUPIL_COUNT_TOT", "FED_STATE_LOCAL_EXP",
	"FED_STATE_LOCAL_EXP" / "PUPIL_COUNT_TOT" AS "PER_FED_STATE_LOCAL_EXP"
FROM "Expenditures_per_Pupil"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("PUPIL_COUNT_TOT" >= 50)
),

inexp_teachers AS (
SELECT "INSTITUTION_ID", "NUM_TEACH", "NUM_TEACH_INEXP", "PER_TEACH_INEXP",
	"NUM_TEACH_INEXP"::NUMERIC / "NUM_TEACH"::NUMERIC * 100 AS "PER_TEACH_INEXP_calc"
FROM "Inexperienced_Teachers_and_Principals"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("NUM_TEACH" >= 10)
),

teacher_out_cert AS (
SELECT "INSTITUTION_ID", "NUM_TEACH_OC", "NUM_OUT_CERT",
	"NUM_OUT_CERT" / "NUM_TEACH_OC" * 100 AS "PER_OUT_CERT"
FROM "Teachers_Teaching_Out_of_Certification"
WHERE (RIGHT("ENTITY_CD", 4) != '0000') AND ("ENTITY_NAME" != 'All Public Schools') AND ("YEAR" = '2024')
	AND ("NUM_TEACH_OC" >= 10)
),

accountability_status AS (
SELECT "INSTITUTION_ID", "OVERALL_STATUS"
FROM "Accountability_Status"
WHERE ("YEAR" = '2024') AND ("OVERALL_STATUS" != 'Target District')
),

need_to_resource AS (
SELECT "INSTITUTION_ID", "NEEDS_INDEX_DESCRIPTION"
FROM "BOCES_and_N_RC"
WHERE ("YEAR" = '2024') AND (RIGHT("ENTITY_CD", 4) != '0000')
)

SELECT ins."INSTITUTION_ID", ins."ENTITY_CD", ins."ENTITY_NAME",
	cw."WEIGHTED_INDEX", c_abs."ENROLLMENT", c_abs."ABSENT_COUNT",
	grad."GRAD_COUNT", grad."COHORT_COUNT", part."ELA_P_RATE", part."MATH_P_RATE",
	expd."PUPIL_COUNT_TOT", expd."FED_STATE_LOCAL_EXP",
	inet."NUM_TEACH", inet."NUM_TEACH_INEXP", ocert."NUM_TEACH_OC", ocert."NUM_OUT_CERT",
	acc."OVERALL_STATUS", nrc."NEEDS_INDEX_DESCRIPTION"

FROM institutions ins
INNER JOIN core_and_weighted cw ON ins."INSTITUTION_ID" = cw."INSTITUTION_ID"
INNER JOIN chronic_absenteeism c_abs ON ins."INSTITUTION_ID" = c_abs."INSTITUTION_ID"
INNER JOIN graduation_rate grad ON ins."INSTITUTION_ID" = grad."INSTITUTION_ID"
INNER JOIN participation_rate part ON ins."INSTITUTION_ID" = part."INSTITUTION_ID"
INNER JOIN expenditures_per_pupil expd ON ins."INSTITUTION_ID" = expd."INSTITUTION_ID"
INNER JOIN inexp_teachers inet ON ins."INSTITUTION_ID" = inet."INSTITUTION_ID"
INNER JOIN teacher_out_cert ocert ON ins."INSTITUTION_ID" = ocert."INSTITUTION_ID"
INNER JOIN accountability_status acc ON ins."INSTITUTION_ID" = acc."INSTITUTION_ID"
INNER JOIN need_to_resource nrc ON ins."INSTITUTION_ID" = nrc."INSTITUTION_ID"
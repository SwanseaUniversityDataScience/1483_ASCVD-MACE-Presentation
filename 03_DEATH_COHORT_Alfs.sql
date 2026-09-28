------------------------------------------
--
--Drop Table
CALL FNC.DROP_IF_EXISTS('SAILW1483V.PRIOR_ASCVD_DEATHS');
COMMIT;
------------------------------------------ 
--
-- Create Table
CREATE TABLE SAILW1483V.PRIOR_ASCVD_DEATHS
(
	ALF_PE				BIGINT,
	DEATH_DT			DATE,
	DEATH_CAUSE_DESC	VARCHAR(100),
	CD					VARCHAR(10),
	CAUSE_NUM			INTEGER,
	TYPE				VARCHAR(3)
) 
;
COMMIT;
------------------------------------------
--
--Insert into Table
INSERT INTO SAILW1483V.PRIOR_ASCVD_DEATHS
--
SELECT
*
FROM
(
SELECT
D.ALF_PE,
CAST(LEFT(D.DEATH_DT, 10) AS DATE) AS DEATH_DT,
DESC AS DEATH_CAUSE_DESC,
CD,
CASE 
	WHEN CD = D.DEATHCAUSE_DIAG_UNDERLYING_CD THEN 0
	WHEN CD = D.DEATHCAUSE_DIAG_1_CD THEN 1 
	WHEN CD = D.DEATHCAUSE_DIAG_2_CD THEN 2 
	ELSE NULL
END AS CAUSE_NUM,
CASE
WHEN (DESC LIKE('%cclusio%')
	OR DESC LIKE('%ebral athero%')
	OR DESC LIKE('%ebral ischaem%')	
	OR DESC LIKE('%ebral infarc%')
	OR DESC LIKE('%erebrovasc%')
	OR DESC LIKE('%aemor%')
	OR DESC LIKE('%intra%'))
THEN 'ST'
WHEN
	(DESC LIKE('%schaem%')
	OR DESC LIKE('%therosclero%')	
	OR DESC LIKE('%ardial infarc%')
	OR DESC LIKE('%ardiac septal def%')) 
THEN 'IHD'
ELSE NULL
END AS TYPE
FROM SAIL1483V.ADDE_DEATHS_20240501 D

JOIN 
(
SELECT
DIAG_CD_4 AS CD,
DIAG_DESC_4 AS DESC
FROM SAILREFRV.ICD10_DIAG_CD_4

UNION

SELECT
DIAG_CD_123 AS CD,
DIAG_DESC_123 AS DESC
FROM SAILREFRV.ICD10_DIAG_CD_123
) I
ON D.DEATHCAUSE_DIAG_UNDERLYING_CD = I.CD
OR D.DEATHCAUSE_DIAG_1_CD = I.CD
OR D.DEATHCAUSE_DIAG_2_CD = I.CD

WHERE D.DEATH_DT_VALID = 'Valid'
AND
(DESC LIKE('%schaemic%')
	OR DESC LIKE('%therosclero%')	
	OR DESC LIKE('%ardial infarc%')
	OR DESC LIKE('%ardiac septal def%')
	OR DESC LIKE('%cclusio%')
	OR DESC LIKE('%ebral ischaem%')	
	OR DESC LIKE('%ebral athero%')
	OR DESC LIKE('%ebral infarc%')
	OR DESC LIKE('%erebrovasc%')	
	OR (DESC LIKE('%aemor%') AND DESC LIKE('%intra%'))
)
	AND DESC NOT LIKE('%arach%')	
	AND DESC NOT LIKE('%ransient%') 
	AND YEAR(D.DEATH_DT) BETWEEN 2000 AND 2023
)
WHERE CAUSE_NUM IN (0,1)
;
COMMIT;
--
------------------------------------------
--
-- Select all results
SELECT 
	* 
FROM 
	SAILW1483V.PRIOR_ASCVD_DEATHS
	;
--
-- Count all results
SELECT 
	COUNT(*)
FROM 
	SAILW1483V.PRIOR_ASCVD_DEATHS;
------------------------------------------


------------------------------------------
--
--Drop Table
CALL FNC.DROP_IF_EXISTS('SAILW1483V.PRIOR_CVD_DEATH_ALF_TOP_CONSORT');
COMMIT;
------------------------------------------
--
--Create Table
CREATE TABLE SAILW1483V.PRIOR_CVD_DEATH_ALF_TOP_CONSORT
(
	ALF_PE				BIGINT,
	DEATH_DT			DATE,
	DEATH_CAUSE_DESC	VARCHAR(100),
	CD					VARCHAR(10),
	CAUSE_NUM			INTEGER,
	TYPE				VARCHAR(3)
)
;
COMMIT;
------------------------------------------
--
--Insert into Table
--
--
INSERT INTO SAILW1483V.PRIOR_CVD_DEATH_ALF_TOP_CONSORT
--
-- Checking ALFs with ASCVD diagnoses from PEDW & WLGP have a record in WDSD
--
WITH A AS
(
SELECT 
	A.*
FROM SAILW1483V.PRIOR_ASCVD_DEATHS A

JOIN SAILW1483V.PREP_ALF_WDSD WDS
ON A.ALF_PE = WDS.ALF_PE
)
 
SELECT
ALF_PE,
DEATH_DT,
DEATH_CAUSE_DESC,
CD,
CAUSE_NUM,
TYPE
FROM
(
SELECT
*,
ROW_NUMBER() OVER(PARTITION BY ALF_PE ORDER BY CAUSE_NUM) AS RANK
FROM A
)
WHERE RANK = 1 AND CD NOT IN('P523', 'H342' 'M622')
;
COMMIT;
--
------------------------------------------
--
-- Select all results
SELECT 
	* 
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_ALF_TOP_CONSORT
ORDER BY ALF_PE
FETCH FIRST 100 ROWS ONLY;
--
-- Count all results
SELECT 
	COUNT(*)
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_ALF_TOP_CONSORT
;
--
-- Count distinct alfs
SELECT 
	COUNT(DISTINCT ALF_PE)
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_ALF_TOP_CONSORT
;
------------------------------------------
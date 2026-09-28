
------------------------------------------   
--
--Drop Table
CALL FNC.DROP_IF_EXISTS('SAILW1483V.PRIOR_CVD_DEATH_ALF_OVER18');
COMMIT;
------------------------------------------
--
--Create Table
CREATE TABLE SAILW1483V.PRIOR_CVD_DEATH_ALF_OVER18
(
	ALF_PE		BIGINT
)
;
COMMIT;
------------------------------------------
--
--Insert into Table
INSERT INTO SAILW1483V.PRIOR_CVD_DEATH_ALF_OVER18
--
-- Returning ALFs who were aged >= 18 at first diagnosis of ASCVD
--
WITH ADMIS_AGE_GP AS
(
SELECT 
	C.ALF_PE,
	GP.WOB,
	C.DEATH_DT,
	CASE WHEN (GP.WOB + 18 YEARS) < C.DEATH_DT THEN 1 ELSE 0 END AS AGED_18
FROM SAILW1483V.PRIOR_CVD_DEATH_ALF_TOP_CONSORT C

JOIN (SELECT DISTINCT ALF_PE, WOB FROM SAILW1483V.EXTRACT_P4_WLGP_GP_EVENT_CLEANSED) GP
ON C.ALF_PE = GP.ALF_PE 
)

SELECT
	ALF_PE
FROM ADMIS_AGE_GP GP
WHERE 
	AGED_18 = 1
;
COMMIT;
--
------------------------------------------
--
-- Select all results
SELECT 
	* 
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_ALF_OVER18
ORDER BY ALF_PE
FETCH FIRST 100 ROWS ONLY;
--
-- Count all results
SELECT 
	COUNT(*)
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_ALF_OVER18
;
--
-- Count distinct alfs
SELECT 
	COUNT(DISTINCT ALF_PE)
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_ALF_OVER18
;
------------------------------------------

------------------------------------------
--
--Drop Table
CALL FNC.DROP_IF_EXISTS('SAILW1483V.PRIOR_CVD_DEATH_ALF_RES');
COMMIT;
------------------------------------------
--
--Create Table
CREATE TABLE SAILW1483V.PRIOR_CVD_DEATH_ALF_RES
(
	ALF_PE		BIGINT
)
;
COMMIT;
------------------------------------------
--
--Insert into Table
INSERT INTO SAILW1483V.PRIOR_CVD_DEATH_ALF_RES
--
-- Returning Prevalent ALFs who were resident in Wales at start of study period, 
-- and Incident ALFs who had been resident in Wales for > 90 days at their entry date
--
--Prevalent
WITH 
--Incident
INC_A AS
(
SELECT
A.ALF_PE,
A.DEATH_DT
FROM SAILW1483V.PRIOR_CVD_DEATH_ALF_TOP_CONSORT A

JOIN SAILW1483V.PRIOR_CVD_DEATH_ALF_OVER18 B
ON A.ALF_PE = B.ALF_PE
),

INC_B AS
(
SELECT
A.ALF_PE,
A.DEATH_DT,
W.START_DATE,
W.END_DATE,
WELSH_ADDRESS
FROM INC_A A

LEFT JOIN SAILW1483V.EXTRACT_P4_WDSD_SINGLE_CLEAN_GEO_WALES W
ON A.ALF_PE = W.ALF_PE
AND W.START_DATE <= A.DEATH_DT-90
),

INC_C AS
(
SELECT
ALF_PE,
DEATH_DT
FROM INC_B
WHERE WELSH_ADDRESS = 1
)

SELECT
DISTINCT ALF_PE
FROM INC_C
;
COMMIT;
--
------------------------------------------
--
-- Select all results
SELECT 
	* 
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_ALF_RES
ORDER BY ALF_PE
FETCH FIRST 100 ROWS ONLY;
--
-- Count all results
SELECT 
	COUNT(*)
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_ALF_RES
;
--
-- Count distinct alfs
SELECT 
	COUNT(DISTINCT ALF_PE)
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_ALF_RES
;
------------------------------------------

------------------------------------------
--
--Drop Table
CALL FNC.DROP_IF_EXISTS('SAILW1483V.PRIOR_CVD_DEATH_ALF_REG');
COMMIT;
------------------------------------------
--
--Create Table
CREATE TABLE SAILW1483V.PRIOR_CVD_DEATH_ALF_REG
(
	ALF_PE		BIGINT
)
;
COMMIT;
------------------------------------------
--
--Insert into Table
INSERT INTO SAILW1483V.PRIOR_CVD_DEATH_ALF_REG
--
-- Returning Incident ALFs who had > 90 days of SAIL-providing GP practice registration at their entry date
--
WITH
--Incident
INC_A AS
(
SELECT
A.ALF_PE,
A.DEATH_DT

FROM SAILW1483V.PRIOR_CVD_DEATH_ALF_TOP_CONSORT A

JOIN SAILW1483V.PRIOR_CVD_DEATH_ALF_RES B
ON A.ALF_PE = B.ALF_PE
),

INC_B AS
(
SELECT
A.ALF_PE,
A.DEATH_DT,
G.START_DATE,
G.END_DATE,
GP_DATA_FLAG AS SAIL_PRAC
FROM INC_A A

LEFT JOIN SAILW1483V.EXTRACT_P4_WLGP_CLEAN_GP_REG_BY_PRAC_INCLNONSAIL_MEDIAN G
ON A.ALF_PE = G.ALF_PE
AND G.START_DATE <= A.DEATH_DT-90
),

INC_C AS
(
SELECT
ALF_PE
FROM INC_B
WHERE SAIL_PRAC = 1
)

SELECT
DISTINCT ALF_PE
FROM INC_C
;
COMMIT;
--
------------------------------------------
--
-- Select all results
SELECT 
	* 
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_ALF_REG
ORDER BY ALF_PE
FETCH FIRST 100 ROWS ONLY;
--
-- Count all results
SELECT 
	COUNT(*)
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_ALF_REG
;
--
-- Count distinct alfs
SELECT 
	COUNT(DISTINCT ALF_PE)
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_ALF_REG
;
------------------------------------------

------------------------------------------   
--
--Drop Table
CALL FNC.DROP_IF_EXISTS('SAILW1483V.PRIOR_CVD_DEATH_COHORT_ALFS');
COMMIT;
------------------------------------------
--
--Create Table
CREATE TABLE SAILW1483V.PRIOR_CVD_DEATH_COHORT_ALFS
(
	ALF_PE		BIGINT,
	DEATH_DT	DATE,
	TYPE		VARCHAR(6)
)
;
COMMIT;
------------------------------------------
--
--Insert into Table
INSERT INTO SAILW1483V.PRIOR_CVD_DEATH_COHORT_ALFS
--
-- Returning final list of ALFs who made it into the study cohort after all exclusions, with their first diagnosis characteristics
--
SELECT
A.ALF_PE,
A.DEATH_DT,
A.TYPE
FROM SAILW1483V.PRIOR_CVD_DEATH_ALF_TOP_CONSORT A

JOIN SAILW1483V.PRIOR_CVD_DEATH_ALF_REG P
ON A.ALF_PE = P.ALF_PE
;
COMMIT;
--
------------------------------------------
--
-- Select all results
SELECT 
	* 
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_COHORT_ALFS
ORDER BY ALF_PE
FETCH FIRST 100 ROWS ONLY;
--
-- Count all results
SELECT 
	COUNT(*)
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_COHORT_ALFS
;
--
-- Count distinct alfs
SELECT 
	COUNT(DISTINCT ALF_PE)
FROM 
	SAILW1483V.PRIOR_CVD_DEATH_COHORT_ALFS
;


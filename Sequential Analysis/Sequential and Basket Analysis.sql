-----------------------------------change------------------------------
--1.Txn Tables (2-year period)
-----------------------------------------------------PURCHASE SEQUENCE-----------------------------------------

DROP TABLE IF EXISTS FIRST_PURCHASE;
CREATE TEMP TABLE FIRST_PURCHASE AS
SELECT *
FROM 
(
	SELECT A.*
			,DENSE_RANK () OVER (PARTITION BY A.MEMBER_NUMBER ORDER BY TXN_DATE::DATE) SEQ
	FROM TXN_2YR A INNER JOIN  HOMEOWNER_CUST B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER
) A
WHERE SEQ = 1
;

DROP TABLE IF EXISTS SECOND_PURCHASE;
CREATE TEMP TABLE SECOND_PURCHASE AS
SELECT *
FROM 
(
	SELECT A.*
			,DENSE_RANK () OVER (PARTITION BY A.MEMBER_NUMBER ORDER BY TXN_DATE::DATE) SEQ
	FROM TXN_2YR A INNER JOIN  HOMEOWNER_CUST B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER
) A
WHERE SEQ = 2
;

DROP TABLE IF EXISTS THIRD_PURCHASE;
CREATE TEMP TABLE THIRD_PURCHASE AS
SELECT *
FROM 
(
	SELECT A.* 
			,DENSE_RANK () OVER (PARTITION BY A.MEMBER_NUMBER ORDER BY TXN_DATE::DATE) SEQ
	FROM TXN_2YR A INNER JOIN  HOMEOWNER_CUST B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER
) A
WHERE SEQ = 3
;

DROP TABLE IF EXISTS FOURTH_PURCHASE;
CREATE TEMP TABLE FOURTH_PURCHASE AS
SELECT *
FROM 
(
	SELECT A.*
			,DENSE_RANK () OVER (PARTITION BY A.MEMBER_NUMBER ORDER BY TXN_DATE::DATE) SEQ
	FROM TXN_2YR A INNER JOIN  HOMEOWNER_CUST B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER
) A
WHERE SEQ = 4
;

DROP TABLE IF EXISTS FIFTH_PURCHASE;
CREATE TEMP TABLE FIFTH_PURCHASE AS
SELECT *
FROM 
(
	SELECT A.*
			,DENSE_RANK () OVER (PARTITION BY A.MEMBER_NUMBER ORDER BY TXN_DATE::DATE) SEQ
	FROM TXN_2YR A INNER JOIN  HOMEOWNER_CUST B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER
) A
WHERE SEQ = 5
;
		   
-----------------------------------------------------SEQUENTIAL: A.LOW ACTIVITY-----------------------------------------
--SELECT SUBDEPT_NAME,COUNT(DISTINCT MEMBER_NUMBER)
--FROM TXN_2YR
--GROUP BY SUBDEPT_NAME
--ORDER BY COUNT(DISTINCT MEMBER_NUMBER) DESC
--;
DROP TABLE IF EXISTS LOW_ACT_FIRST_CUST_CATE;
CREATE TEMP TABLE LOW_ACT_FIRST_CUST_CATE AS
SELECT DISTINCT A.MEMBER_NUMBER,SUBDEPT_NAME,TXN_DATE
FROM FIRST_PURCHASE A 
	 INNER JOIN HOMEOWNER_CUST B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND CUSTOMER_SEGMENT_V2 = 'HOMEOWNER LOW ACTIVITY CUSTOMERS' 
;
DROP TABLE IF EXISTS LOW_ACT_SECOND_CUST_CATE;
CREATE TEMP TABLE LOW_ACT_SECOND_CUST_CATE AS
SELECT DISTINCT A.MEMBER_NUMBER,SUBDEPT_NAME,TXN_DATE
FROM SECOND_PURCHASE A INNER JOIN HOMEOWNER_CUST B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND CUSTOMER_SEGMENT_V2 = 'HOMEOWNER LOW ACTIVITY CUSTOMERS'
;

DROP TABLE IF EXISTS LOW_ACT_LAG_DAY_FIRST_SECOND;
CREATE TEMP TABLE LOW_ACT_LAG_DAY_FIRST_SECOND AS
SELECT DISTINCT A.MEMBER_NUMBER
				,A.TXN_DATE AS PREVIOUS_TXN_DATE
				,B.TXN_DATE AS NEXT_TXN_DATE
				,DATEDIFF(DAY,A.TXN_DATE,B.TXN_DATE) AS LAG_DAY
FROM LOW_ACT_FIRST_CUST_CATE A LEFT JOIN LOW_ACT_SECOND_CUST_CATE B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER
;

DROP TABLE IF EXISTS LOW_ACT_FIRST_SECOND;
CREATE TEMP TABLE LOW_ACT_FIRST_SECOND AS
SELECT DISTINCT A.MEMBER_NUMBER,FIRST_CATE,SECOND_CATE
FROM (SELECT MEMBER_NUMBER FROM HOMEOWNER_CUST WHERE CUSTOMER_SEGMENT_V2 = 'HOMEOWNER LOW ACTIVITY CUSTOMERS' ) A
	 CROSS JOIN 
	 ( (SELECT DISTINCT SUBDEPT_NAME AS FIRST_CATE FROM TXN_2YR WHERE SUBDEPT_NAME NOT IN ('CONTRACTOR SERVICE','CARPARK','KIDS','USES STORE','FLOOR  & WALL  DECORATIVE','HBC','RIMS','SERVICE'
	 																					,'READY-MADE PRODUCT','PROFILE SYSTEM','PC TRAINING','SUBLET','MADE TO ORDER','DIY KITCHEN PROJECT'
	 																					,'SHOCK ABSORBER','WOOD & ACC','HOME ORGANIZER','BRAKE SYSTEM','SPARE PART','BATTERY','UNIFORM'
	 																					,'SPARE PART & ACCESSORIES','CONCRETE KITCHEN','TYRE','ENGINE OIL & FILTER' --CUST < 4,000
	 																					,'PREMIUM','BILL & TOP UP','SERVICE-OPERATION','HOME SERVICES','GIFT & PREMIUM','NO BAG','DELIVERY FEE','PREMIUM WITH PURCHASE','HOMEWORKS SERVICE')) B
	 	CROSS JOIN (SELECT DISTINCT SUBDEPT_NAME AS SECOND_CATE FROM TXN_2YR WHERE SUBDEPT_NAME NOT IN ('CONTRACTOR SERVICE','CARPARK','KIDS','USES STORE','FLOOR  & WALL  DECORATIVE','HBC','RIMS','SERVICE'
	 																					,'READY-MADE PRODUCT','PROFILE SYSTEM','PC TRAINING','SUBLET','MADE TO ORDER','DIY KITCHEN PROJECT'
	 																					,'SHOCK ABSORBER','WOOD & ACC','HOME ORGANIZER','BRAKE SYSTEM','SPARE PART','BATTERY','UNIFORM'
	 																					,'SPARE PART & ACCESSORIES','CONCRETE KITCHEN','TYRE','ENGINE OIL & FILTER' --CUST < 4,000
	 																					,'PREMIUM','BILL & TOP UP','SERVICE-OPERATION','HOME SERVICES','GIFT & PREMIUM','NO BAG','DELIVERY FEE','PREMIUM WITH PURCHASE','HOMEWORKS SERVICE')) C
	 ) Z
;

DROP TABLE IF EXISTS LOW_ACT_FIRST_SECOND_FLAG;
CREATE TEMP TABLE LOW_ACT_FIRST_SECOND_FLAG AS
SELECT A.*
		,CASE WHEN B.MEMBER_NUMBER IS NOT NULL THEN 1 ELSE 0 END AS FIRST_CATE_FLAG
		,CASE WHEN C.MEMBER_NUMBER IS NOT NULL THEN 1 ELSE 0 END AS SECOND_CATE_FLAG
		,LAG_DAY
FROM LOW_ACT_FIRST_SECOND A
	 LEFT JOIN LOW_ACT_FIRST_CUST_CATE B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND A.FIRST_CATE = B.SUBDEPT_NAME
	 LEFT JOIN LOW_ACT_SECOND_CUST_CATE C ON A.MEMBER_NUMBER = C.MEMBER_NUMBER AND A.SECOND_CATE = C.SUBDEPT_NAME
	 LEFT JOIN LOW_ACT_LAG_DAY_FIRST_SECOND D ON A.MEMBER_NUMBER = D.MEMBER_NUMBER
;

DELETE FROM LOW_ACT_FIRST_SECOND_FLAG
WHERE FIRST_CATE_FLAG = 0 AND SECOND_CATE_FLAG = 0;

DROP TABLE IF EXISTS LOW_ACT_FIRST_SECOND;

DROP TABLE IF EXISTS HOME_OWNER_LOW_ACT_SEQUENCE;
CREATE TEMP TABLE HOME_OWNER_LOW_ACT_SEQUENCE AS
SELECT FIRST_CATE AS PREVIOUS_CATE
		,SECOND_CATE AS NEXT_CATE
		,COUNT(DISTINCT CASE WHEN FIRST_CATE_FLAG = 1 THEN MEMBER_NUMBER END) AS PREVIOUS_CNT
		,COUNT(DISTINCT CASE WHEN SECOND_CATE_FLAG = 1 THEN MEMBER_NUMBER END) AS NEXT_CNT
		,COUNT(DISTINCT CASE WHEN FIRST_CATE_FLAG = 1 AND SECOND_CATE_FLAG = 1 THEN MEMBER_NUMBER END) AS BOTH_CNT
		,NULL :: FLOAT AS PROB_NEXT_GIVEN_PREVIOUS
		,NULL :: FLOAT AS PROB_NEXT
		,NULL :: FLOAT AS PROB_PREVIOUS
		,NULL :: FLOAT AS LIFT
		,AVG(CASE WHEN FIRST_CATE_FLAG = 1 AND SECOND_CATE_FLAG = 1 THEN LAG_DAY END) AS AVG_LAG_DAY
		,NULL :: INT AS MED_LAG_DAY
FROM LOW_ACT_FIRST_SECOND_FLAG
GROUP BY FIRST_CATE
		,SECOND_CATE
;

UPDATE HOME_OWNER_LOW_ACT_SEQUENCE
SET PROB_NEXT_GIVEN_PREVIOUS = A.PROB_NEXT_GIVEN_PREVIOUS
FROM 
(
	SELECT FIRST_CATE
			,SECOND_CATE
			,COUNT(DISTINCT CASE WHEN FIRST_CATE_FLAG = 1 AND SECOND_CATE_FLAG = 1 THEN MEMBER_NUMBER END)*1.0/COUNT(DISTINCT CASE WHEN FIRST_CATE_FLAG = 1 THEN MEMBER_NUMBER END) PROB_NEXT_GIVEN_PREVIOUS
	FROM LOW_ACT_FIRST_SECOND_FLAG  
	GROUP BY FIRST_CATE
			,SECOND_CATE
	HAVING COUNT(DISTINCT CASE WHEN FIRST_CATE_FLAG = 1 THEN MEMBER_NUMBER END) > 0
) A
WHERE HOME_OWNER_LOW_ACT_SEQUENCE.PREVIOUS_CATE = A.FIRST_CATE
	  AND HOME_OWNER_LOW_ACT_SEQUENCE.NEXT_CATE = A.SECOND_CATE
;

UPDATE HOME_OWNER_LOW_ACT_SEQUENCE
SET PROB_NEXT = NEXT_CNT*1.0/
(
	SELECT COUNT(DISTINCT MEMBER_NUMBER) AS TOTAL_CNT
	FROM LOW_ACT_FIRST_SECOND_FLAG  
	WHERE SECOND_CATE_FLAG = 1
)
;

UPDATE HOME_OWNER_LOW_ACT_SEQUENCE
SET PROB_PREVIOUS = PREVIOUS_CNT*1.0/
(
	SELECT COUNT(DISTINCT MEMBER_NUMBER) AS TOTAL_CNT
	FROM LOW_ACT_FIRST_SECOND_FLAG  
	WHERE FIRST_CATE_FLAG = 1
)
;

UPDATE HOME_OWNER_LOW_ACT_SEQUENCE
SET LIFT = PROB_NEXT_GIVEN_PREVIOUS/PROB_NEXT
;

UPDATE HOME_OWNER_LOW_ACT_SEQUENCE
SET MED_LAG_DAY = A.MED_LAG_DAY
FROM
(
	SELECT DISTINCT FIRST_CATE
					,SECOND_CATE
					,LAG_DAY
					,PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY LAG_DAY) OVER(PARTITION BY FIRST_CATE,SECOND_CATE) AS MED_LAG_DAY
	FROM LOW_ACT_FIRST_SECOND_FLAG
	WHERE FIRST_CATE_FLAG = 1 AND SECOND_CATE_FLAG = 1 
) A
WHERE HOME_OWNER_LOW_ACT_SEQUENCE.PREVIOUS_CATE = A.FIRST_CATE
		AND HOME_OWNER_LOW_ACT_SEQUENCE.NEXT_CATE = A.SECOND_CATE
;
-----------------------------------------------------SEQUENTIAL: C.REGULAR SHOPPERS-----------------------------------------

DROP TABLE IF EXISTS REG_FIRST_CUST_CATE;
CREATE TEMP TABLE REG_FIRST_CUST_CATE AS
SELECT DISTINCT A.MEMBER_NUMBER,SUBDEPT_NAME,TXN_DATE
FROM FIRST_PURCHASE A INNER JOIN HOMEOWNER_CUST B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND CUSTOMER_SEGMENT_V2 = 'HOMEOWNER REGULAR SHOPPERS'
;
DROP TABLE IF EXISTS REG_SECOND_CUST_CATE;
CREATE TEMP TABLE REG_SECOND_CUST_CATE AS
SELECT DISTINCT A.MEMBER_NUMBER,SUBDEPT_NAME,TXN_DATE
FROM SECOND_PURCHASE A INNER JOIN HOMEOWNER_CUST B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND CUSTOMER_SEGMENT_V2 = 'HOMEOWNER REGULAR SHOPPERS'
;
DROP TABLE IF EXISTS REG_THIRD_CUST_CATE;
CREATE TEMP TABLE REG_THIRD_CUST_CATE AS
SELECT DISTINCT A.MEMBER_NUMBER,SUBDEPT_NAME,TXN_DATE
FROM THIRD_PURCHASE A INNER JOIN HOMEOWNER_CUST B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND CUSTOMER_SEGMENT_V2 = 'HOMEOWNER REGULAR SHOPPERS'
;
DROP TABLE IF EXISTS REG_FOURTH_CUST_CATE;
CREATE TEMP TABLE REG_FOURTH_CUST_CATE AS
SELECT DISTINCT A.MEMBER_NUMBER,SUBDEPT_NAME,TXN_DATE
FROM FOURTH_PURCHASE A INNER JOIN HOMEOWNER_CUST B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND CUSTOMER_SEGMENT_V2 = 'HOMEOWNER REGULAR SHOPPERS'
;
DROP TABLE IF EXISTS REG_FIFTH_CUST_CATE;
CREATE TEMP TABLE REG_FIFTH_CUST_CATE AS
SELECT DISTINCT A.MEMBER_NUMBER,SUBDEPT_NAME,TXN_DATE
FROM FIFTH_PURCHASE A INNER JOIN HOMEOWNER_CUST B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND CUSTOMER_SEGMENT_V2 = 'HOMEOWNER REGULAR SHOPPERS'
;

--LAG DAY
DROP TABLE IF EXISTS REG_LAG_DAY_FIRST_SECOND;
CREATE TEMP TABLE REG_LAG_DAY_FIRST_SECOND AS
SELECT DISTINCT A.MEMBER_NUMBER
				,A.TXN_DATE AS PREVIOUS_TXN_DATE
				,B.TXN_DATE AS NEXT_TXN_DATE
				,DATEDIFF(DAY,A.TXN_DATE,B.TXN_DATE) AS LAG_DAY
FROM REG_FIRST_CUST_CATE A LEFT JOIN REG_SECOND_CUST_CATE B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER
;

DROP TABLE IF EXISTS REG_LAG_DAY_SECOND_THIRD;
CREATE TEMP TABLE REG_LAG_DAY_SECOND_THIRD AS
SELECT DISTINCT A.MEMBER_NUMBER
				,A.TXN_DATE AS PREVIOUS_TXN_DATE
				,B.TXN_DATE AS NEXT_TXN_DATE
				,DATEDIFF(DAY,A.TXN_DATE,B.TXN_DATE) AS LAG_DAY
FROM REG_SECOND_CUST_CATE A LEFT JOIN REG_THIRD_CUST_CATE B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER
;

DROP TABLE IF EXISTS REG_LAG_DAY_THIRD_FOURTH;
CREATE TEMP TABLE REG_LAG_DAY_THIRD_FOURTH AS
SELECT DISTINCT A.MEMBER_NUMBER
				,A.TXN_DATE AS PREVIOUS_TXN_DATE
				,B.TXN_DATE AS NEXT_TXN_DATE
				,DATEDIFF(DAY,A.TXN_DATE,B.TXN_DATE) AS LAG_DAY
FROM REG_THIRD_CUST_CATE A LEFT JOIN REG_FOURTH_CUST_CATE B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER
;

DROP TABLE IF EXISTS REG_LAG_DAY_FOURTH_FIFTH;
CREATE TEMP TABLE REG_LAG_DAY_FOURTH_FIFTH AS
SELECT DISTINCT A.MEMBER_NUMBER
				,A.TXN_DATE AS PREVIOUS_TXN_DATE
				,B.TXN_DATE AS NEXT_TXN_DATE
				,DATEDIFF(DAY,A.TXN_DATE,B.TXN_DATE) AS LAG_DAY
FROM REG_FOURTH_CUST_CATE A LEFT JOIN REG_FIFTH_CUST_CATE B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER
;

--FIRST SECOND
DROP TABLE IF EXISTS REG_FIRST_SECOND;
CREATE TEMP TABLE REG_FIRST_SECOND AS
SELECT DISTINCT A.MEMBER_NUMBER,FIRST_CATE,SECOND_CATE
FROM (SELECT MEMBER_NUMBER FROM HOMEOWNER_CUST WHERE CUSTOMER_SEGMENT_V2 = 'HOMEOWNER REGULAR SHOPPERS' ) A
	 CROSS JOIN 
	 ( (SELECT DISTINCT SUBDEPT_NAME AS FIRST_CATE FROM TXN_2YR WHERE SUBDEPT_NAME NOT IN ('CONTRACTOR SERVICE','CARPARK','KIDS','USES STORE','FLOOR  & WALL  DECORATIVE','HBC','RIMS','SERVICE'
	 																					,'READY-MADE PRODUCT','PROFILE SYSTEM','PC TRAINING','SUBLET','MADE TO ORDER','DIY KITCHEN PROJECT'
	 																					,'SHOCK ABSORBER','WOOD & ACC','HOME ORGANIZER','BRAKE SYSTEM','SPARE PART','BATTERY','UNIFORM'
	 																					,'SPARE PART & ACCESSORIES','CONCRETE KITCHEN','TYRE','ENGINE OIL & FILTER' --CUST < 4,000
	 																					,'PREMIUM','BILL & TOP UP','SERVICE-OPERATION','HOME SERVICES','GIFT & PREMIUM','NO BAG','DELIVERY FEE','PREMIUM WITH PURCHASE','HOMEWORKS SERVICE')) B
	 	CROSS JOIN (SELECT DISTINCT SUBDEPT_NAME AS SECOND_CATE FROM TXN_2YR WHERE SUBDEPT_NAME NOT IN ('CONTRACTOR SERVICE','CARPARK','KIDS','USES STORE','FLOOR  & WALL  DECORATIVE','HBC','RIMS','SERVICE'
	 																					,'READY-MADE PRODUCT','PROFILE SYSTEM','PC TRAINING','SUBLET','MADE TO ORDER','DIY KITCHEN PROJECT'
	 																					,'SHOCK ABSORBER','WOOD & ACC','HOME ORGANIZER','BRAKE SYSTEM','SPARE PART','BATTERY','UNIFORM'
	 																					,'SPARE PART & ACCESSORIES','CONCRETE KITCHEN','TYRE','ENGINE OIL & FILTER' --CUST < 4,000
	 																					,'PREMIUM','BILL & TOP UP','SERVICE-OPERATION','HOME SERVICES','GIFT & PREMIUM','NO BAG','DELIVERY FEE','PREMIUM WITH PURCHASE','HOMEWORKS SERVICE')) C
	 ) Z
;

DROP TABLE IF EXISTS REG_FIRST_SECOND_FLAG;
CREATE TEMP TABLE REG_FIRST_SECOND_FLAG AS
SELECT A.*
		,CASE WHEN B.MEMBER_NUMBER IS NOT NULL THEN 1 ELSE 0 END AS FIRST_CATE_FLAG
		,CASE WHEN C.MEMBER_NUMBER IS NOT NULL THEN 1 ELSE 0 END AS SECOND_CATE_FLAG
		,LAG_DAY
FROM REG_FIRST_SECOND A
	 LEFT JOIN REG_FIRST_CUST_CATE B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND A.FIRST_CATE = B.SUBDEPT_NAME
	 LEFT JOIN REG_SECOND_CUST_CATE C ON A.MEMBER_NUMBER = C.MEMBER_NUMBER AND A.SECOND_CATE = C.SUBDEPT_NAME
	 LEFT JOIN REG_LAG_DAY_FIRST_SECOND D ON A.MEMBER_NUMBER = D.MEMBER_NUMBER
;

DELETE FROM REG_FIRST_SECOND_FLAG
WHERE FIRST_CATE_FLAG = 0 AND SECOND_CATE_FLAG = 0;

SELECT COUNT(*) --71623306
FROM REG_FIRST_SECOND_FLAG;

DROP TABLE IF EXISTS REG_FIRST_SECOND;

--SECOND THIRD
DROP TABLE IF EXISTS REG_SECOND_THIRD;
CREATE TEMP TABLE REG_SECOND_THIRD AS
SELECT DISTINCT A.MEMBER_NUMBER,SECOND_CATE,THIRD_CATE
FROM (SELECT MEMBER_NUMBER FROM HOMEOWNER_CUST WHERE CUSTOMER_SEGMENT_V2 = 'HOMEOWNER REGULAR SHOPPERS' ) A
	 CROSS JOIN 
	 ( (SELECT DISTINCT SUBDEPT_NAME AS SECOND_CATE FROM TXN_2YR WHERE SUBDEPT_NAME NOT IN ('CONTRACTOR SERVICE','CARPARK','KIDS','USES STORE','FLOOR  & WALL  DECORATIVE','HBC','RIMS','SERVICE'
	 																					,'READY-MADE PRODUCT','PROFILE SYSTEM','PC TRAINING','SUBLET','MADE TO ORDER','DIY KITCHEN PROJECT'
	 																					,'SHOCK ABSORBER','WOOD & ACC','HOME ORGANIZER','BRAKE SYSTEM','SPARE PART','BATTERY','UNIFORM'
	 																					,'SPARE PART & ACCESSORIES','CONCRETE KITCHEN','TYRE','ENGINE OIL & FILTER' --CUST < 4,000
	 																					,'PREMIUM','BILL & TOP UP','SERVICE-OPERATION','HOME SERVICES','GIFT & PREMIUM','NO BAG','DELIVERY FEE','PREMIUM WITH PURCHASE','HOMEWORKS SERVICE')) B
	 	CROSS JOIN (SELECT DISTINCT SUBDEPT_NAME AS THIRD_CATE FROM TXN_2YR WHERE SUBDEPT_NAME NOT IN ('CONTRACTOR SERVICE','CARPARK','KIDS','USES STORE','FLOOR  & WALL  DECORATIVE','HBC','RIMS','SERVICE'
	 																					,'READY-MADE PRODUCT','PROFILE SYSTEM','PC TRAINING','SUBLET','MADE TO ORDER','DIY KITCHEN PROJECT'
	 																					,'SHOCK ABSORBER','WOOD & ACC','HOME ORGANIZER','BRAKE SYSTEM','SPARE PART','BATTERY','UNIFORM'
	 																					,'SPARE PART & ACCESSORIES','CONCRETE KITCHEN','TYRE','ENGINE OIL & FILTER' --CUST < 4,000
	 																					,'PREMIUM','BILL & TOP UP','SERVICE-OPERATION','HOME SERVICES','GIFT & PREMIUM','NO BAG','DELIVERY FEE','PREMIUM WITH PURCHASE','HOMEWORKS SERVICE')) C
	 ) Z
;

DROP TABLE IF EXISTS REG_SECOND_THIRD_FLAG;
CREATE TEMP TABLE REG_SECOND_THIRD_FLAG AS
SELECT A.*
		,CASE WHEN B.MEMBER_NUMBER IS NOT NULL THEN 1 ELSE 0 END AS SECOND_CATE_FLAG
		,CASE WHEN C.MEMBER_NUMBER IS NOT NULL THEN 1 ELSE 0 END AS THIRD_CATE_FLAG
		,LAG_DAY
FROM REG_SECOND_THIRD A
	 LEFT JOIN REG_SECOND_CUST_CATE B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND A.SECOND_CATE = B.SUBDEPT_NAME
	 LEFT JOIN REG_THIRD_CUST_CATE C ON A.MEMBER_NUMBER = C.MEMBER_NUMBER AND A.THIRD_CATE = C.SUBDEPT_NAME
	 LEFT JOIN REG_LAG_DAY_SECOND_THIRD D ON A.MEMBER_NUMBER = D.MEMBER_NUMBER
;

DELETE FROM REG_SECOND_THIRD_FLAG
WHERE SECOND_CATE_FLAG = 0 AND THIRD_CATE_FLAG = 0;

SELECT COUNT(*) --70829522
FROM REG_SECOND_THIRD_FLAG;

DROP TABLE IF EXISTS REG_SECOND_THIRD;

--THIRD FOURTH
DROP TABLE IF EXISTS REG_THIRD_FOURTH;
CREATE TEMP TABLE REG_THIRD_FOURTH AS
SELECT DISTINCT A.MEMBER_NUMBER,THIRD_CATE,FOURTH_CATE
FROM (SELECT MEMBER_NUMBER FROM HOMEOWNER_CUST WHERE CUSTOMER_SEGMENT_V2 = 'HOMEOWNER REGULAR SHOPPERS' ) A
	 CROSS JOIN 
	 ( (SELECT DISTINCT SUBDEPT_NAME AS THIRD_CATE FROM TXN_2YR WHERE SUBDEPT_NAME NOT IN ('CONTRACTOR SERVICE','CARPARK','KIDS','USES STORE','FLOOR  & WALL  DECORATIVE','HBC','RIMS','SERVICE'
	 																					,'READY-MADE PRODUCT','PROFILE SYSTEM','PC TRAINING','SUBLET','MADE TO ORDER','DIY KITCHEN PROJECT'
	 																					,'SHOCK ABSORBER','WOOD & ACC','HOME ORGANIZER','BRAKE SYSTEM','SPARE PART','BATTERY','UNIFORM'
	 																					,'SPARE PART & ACCESSORIES','CONCRETE KITCHEN','TYRE','ENGINE OIL & FILTER' --CUST < 4,000
	 																					,'PREMIUM','BILL & TOP UP','SERVICE-OPERATION','HOME SERVICES','GIFT & PREMIUM','NO BAG','DELIVERY FEE','PREMIUM WITH PURCHASE','HOMEWORKS SERVICE')) B
	 	CROSS JOIN (SELECT DISTINCT SUBDEPT_NAME AS FOURTH_CATE FROM TXN_2YR WHERE SUBDEPT_NAME NOT IN ('CONTRACTOR SERVICE','CARPARK','KIDS','USES STORE','FLOOR  & WALL  DECORATIVE','HBC','RIMS','SERVICE'
	 																					,'READY-MADE PRODUCT','PROFILE SYSTEM','PC TRAINING','SUBLET','MADE TO ORDER','DIY KITCHEN PROJECT'
	 																					,'SHOCK ABSORBER','WOOD & ACC','HOME ORGANIZER','BRAKE SYSTEM','SPARE PART','BATTERY','UNIFORM'
	 																					,'SPARE PART & ACCESSORIES','CONCRETE KITCHEN','TYRE','ENGINE OIL & FILTER' --CUST < 4,000
	 																					,'PREMIUM','BILL & TOP UP','SERVICE-OPERATION','HOME SERVICES','GIFT & PREMIUM','NO BAG','DELIVERY FEE','PREMIUM WITH PURCHASE','HOMEWORKS SERVICE')) C
	 ) Z
;

DROP TABLE IF EXISTS REG_THIRD_FOURTH_FLAG;
CREATE TEMP TABLE REG_THIRD_FOURTH_FLAG AS
SELECT A.*
		,CASE WHEN B.MEMBER_NUMBER IS NOT NULL THEN 1 ELSE 0 END AS THIRD_CATE_FLAG
		,CASE WHEN C.MEMBER_NUMBER IS NOT NULL THEN 1 ELSE 0 END AS FOURTH_CATE_FLAG
		,LAG_DAY
FROM REG_THIRD_FOURTH A
	 LEFT JOIN REG_THIRD_CUST_CATE B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND A.THIRD_CATE = B.SUBDEPT_NAME
	 LEFT JOIN REG_FOURTH_CUST_CATE C ON A.MEMBER_NUMBER = C.MEMBER_NUMBER AND A.FOURTH_CATE = C.SUBDEPT_NAME
	 LEFT JOIN REG_LAG_DAY_THIRD_FOURTH D ON A.MEMBER_NUMBER = D.MEMBER_NUMBER
;

DELETE FROM REG_THIRD_FOURTH_FLAG
WHERE THIRD_CATE_FLAG = 0 AND FOURTH_CATE_FLAG = 0;

DROP TABLE IF EXISTS REG_THIRD_FOURTH;

--FOURTH FIFTH
DROP TABLE IF EXISTS REG_FOURTH_FIFTH;
CREATE TEMP TABLE REG_FOURTH_FIFTH AS
SELECT DISTINCT A.MEMBER_NUMBER,FOURTH_CATE,FIFTH_CATE
FROM (SELECT MEMBER_NUMBER FROM HOMEOWNER_CUST WHERE CUSTOMER_SEGMENT_V2 = 'HOMEOWNER REGULAR SHOPPERS' ) A
	 CROSS JOIN 
	 ( (SELECT DISTINCT SUBDEPT_NAME AS FOURTH_CATE FROM TXN_2YR WHERE SUBDEPT_NAME NOT IN ('CONTRACTOR SERVICE','CARPARK','KIDS','USES STORE','FLOOR  & WALL  DECORATIVE','HBC','RIMS','SERVICE'
	 																					,'READY-MADE PRODUCT','PROFILE SYSTEM','PC TRAINING','SUBLET','MADE TO ORDER','DIY KITCHEN PROJECT'
	 																					,'SHOCK ABSORBER','WOOD & ACC','HOME ORGANIZER','BRAKE SYSTEM','SPARE PART','BATTERY','UNIFORM'
	 																					,'SPARE PART & ACCESSORIES','CONCRETE KITCHEN','TYRE','ENGINE OIL & FILTER' --CUST < 4,000
	 																					,'PREMIUM','BILL & TOP UP','SERVICE-OPERATION','HOME SERVICES','GIFT & PREMIUM','NO BAG','DELIVERY FEE','PREMIUM WITH PURCHASE','HOMEWORKS SERVICE')) B
	 	CROSS JOIN (SELECT DISTINCT SUBDEPT_NAME AS FIFTH_CATE FROM TXN_2YR WHERE SUBDEPT_NAME NOT IN ('CONTRACTOR SERVICE','CARPARK','KIDS','USES STORE','FLOOR  & WALL  DECORATIVE','HBC','RIMS','SERVICE'
	 																					,'READY-MADE PRODUCT','PROFILE SYSTEM','PC TRAINING','SUBLET','MADE TO ORDER','DIY KITCHEN PROJECT'
	 																					,'SHOCK ABSORBER','WOOD & ACC','HOME ORGANIZER','BRAKE SYSTEM','SPARE PART','BATTERY','UNIFORM'
	 																					,'SPARE PART & ACCESSORIES','CONCRETE KITCHEN','TYRE','ENGINE OIL & FILTER' --CUST < 4,000
	 																					,'PREMIUM','BILL & TOP UP','SERVICE-OPERATION','HOME SERVICES','GIFT & PREMIUM','NO BAG','DELIVERY FEE','PREMIUM WITH PURCHASE','HOMEWORKS SERVICE')) C
	 ) Z
;

DROP TABLE IF EXISTS REG_FOURTH_FIFTH_FLAG;
CREATE TEMP TABLE REG_FOURTH_FIFTH_FLAG AS
SELECT A.*
		,CASE WHEN B.MEMBER_NUMBER IS NOT NULL THEN 1 ELSE 0 END AS FOURTH_CATE_FLAG
		,CASE WHEN C.MEMBER_NUMBER IS NOT NULL THEN 1 ELSE 0 END AS FIFTH_CATE_FLAG
		,LAG_DAY
FROM REG_FOURTH_FIFTH A
	 LEFT JOIN REG_FOURTH_CUST_CATE B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND A.FOURTH_CATE = B.SUBDEPT_NAME
	 LEFT JOIN REG_FIFTH_CUST_CATE C ON A.MEMBER_NUMBER = C.MEMBER_NUMBER AND A.FIFTH_CATE = C.SUBDEPT_NAME
	 LEFT JOIN REG_LAG_DAY_FOURTH_FIFTH D ON A.MEMBER_NUMBER = D.MEMBER_NUMBER
;

DELETE FROM REG_FOURTH_FIFTH_FLAG
WHERE FOURTH_CATE_FLAG = 0 AND FIFTH_CATE_FLAG = 0;

SELECT COUNT(*) --68248712
FROM REG_FOURTH_FIFTH_FLAG;

DROP TABLE IF EXISTS REG_FOURTH_FIFTH;

--COMBINE
DROP TABLE IF EXISTS REG_PREVIOUS_NEXT_FLAG;
CREATE TEMP TABLE REG_PREVIOUS_NEXT_FLAG AS
SELECT 'FIRST-SECOND' AS BATCH
		,MEMBER_NUMBER
		,FIRST_CATE AS PREVIOUS_CATE
		,SECOND_CATE AS NEXT_CATE
		,FIRST_CATE_FLAG AS PREVIOUS_CATE_FLAG
		,SECOND_CATE_FLAG AS NEXT_CATE_FLAG
		,LAG_DAY
FROM REG_FIRST_SECOND_FLAG
UNION ALL
SELECT 'SECOND-THIRD' AS BATCH,*
FROM REG_SECOND_THIRD_FLAG
UNION ALL
SELECT 'THIRD-FOURTH' AS BATCH,*
FROM REG_THIRD_FOURTH_FLAG
UNION ALL
SELECT 'FOURTH-FIFTH' AS BATCH,*
FROM REG_FOURTH_FIFTH_FLAG
;

DROP TABLE IF EXISTS HOME_OWNER_REG_SEQUENCE;
CREATE TEMP TABLE HOME_OWNER_REG_SEQUENCE AS
SELECT PREVIOUS_CATE
		,NEXT_CATE
		,COUNT(DISTINCT CASE WHEN PREVIOUS_CATE_FLAG = 1 THEN BATCH + '-' + MEMBER_NUMBER END) AS PREVIOUS_CNT
		,COUNT(DISTINCT CASE WHEN NEXT_CATE_FLAG = 1 THEN BATCH + '-' + MEMBER_NUMBER END) AS NEXT_CNT
		,COUNT(DISTINCT CASE WHEN PREVIOUS_CATE_FLAG = 1 AND NEXT_CATE_FLAG = 1 THEN BATCH + '-' + MEMBER_NUMBER END) AS BOTH_CNT
--		,COUNT(DISTINCT CASE WHEN PREVIOUS_CATE_FLAG = 1 AND NEXT_CATE_FLAG = 1 THEN BATCH + '-' + MEMBER_NUMBER END)*1.0/COUNT(DISTINCT CASE WHEN PREVIOUS_CATE_FLAG = 1 THEN BATCH + '-' + MEMBER_NUMBER END) PROB_NEXT_GIVEN_PREVIOUS
		,NULL :: FLOAT AS PROB_NEXT_GIVEN_PREVIOUS
		,NULL :: FLOAT AS PROB_NEXT
		,NULL :: FLOAT AS PROB_PREVIOUS
		,NULL :: FLOAT AS LIFT
		,AVG(CASE WHEN PREVIOUS_CATE_FLAG = 1 AND NEXT_CATE_FLAG = 1 THEN LAG_DAY END) AS AVG_LAG_DAY
		,NULL :: INT AS MED_LAG_DAY
FROM REG_PREVIOUS_NEXT_FLAG
GROUP BY PREVIOUS_CATE
		,NEXT_CATE
;

UPDATE HOME_OWNER_REG_SEQUENCE
SET PROB_NEXT_GIVEN_PREVIOUS = A.PROB_NEXT_GIVEN_PREVIOUS
FROM 
(
	SELECT PREVIOUS_CATE
			,NEXT_CATE
			,COUNT(DISTINCT CASE WHEN PREVIOUS_CATE_FLAG = 1 AND NEXT_CATE_FLAG = 1 THEN BATCH + '-' + MEMBER_NUMBER END)*1.0/COUNT(DISTINCT CASE WHEN PREVIOUS_CATE_FLAG = 1 THEN BATCH + '-' + MEMBER_NUMBER END) PROB_NEXT_GIVEN_PREVIOUS
	FROM REG_PREVIOUS_NEXT_FLAG  
	GROUP BY PREVIOUS_CATE
			,NEXT_CATE
	HAVING COUNT(DISTINCT CASE WHEN PREVIOUS_CATE_FLAG = 1 THEN MEMBER_NUMBER END) > 0
) A
WHERE HOME_OWNER_REG_SEQUENCE.PREVIOUS_CATE = A.PREVIOUS_CATE
	  AND HOME_OWNER_REG_SEQUENCE.NEXT_CATE = A.NEXT_CATE
;

UPDATE HOME_OWNER_REG_SEQUENCE
SET PROB_NEXT = NEXT_CNT*1.0/
(
	SELECT COUNT(DISTINCT BATCH + '-' + MEMBER_NUMBER) AS TOTAL_CNT --1551470
	FROM REG_PREVIOUS_NEXT_FLAG  
	WHERE NEXT_CATE_FLAG = 1
)
;

UPDATE HOME_OWNER_REG_SEQUENCE
SET PROB_PREVIOUS = PREVIOUS_CNT*1.0/
(
	SELECT COUNT(DISTINCT BATCH + '-' + MEMBER_NUMBER) AS TOTAL_CNT --1574532
	FROM REG_PREVIOUS_NEXT_FLAG  
	WHERE PREVIOUS_CATE_FLAG = 1
)
;

UPDATE HOME_OWNER_REG_SEQUENCE
SET LIFT = PROB_NEXT_GIVEN_PREVIOUS/PROB_NEXT
;

UPDATE HOME_OWNER_REG_SEQUENCE
SET MED_LAG_DAY = A.MED_LAG_DAY
FROM
(
	SELECT DISTINCT PREVIOUS_CATE
					,NEXT_CATE
					,LAG_DAY
					,PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY LAG_DAY) OVER(PARTITION BY PREVIOUS_CATE,NEXT_CATE) AS MED_LAG_DAY
	FROM REG_PREVIOUS_NEXT_FLAG
	WHERE PREVIOUS_CATE_FLAG = 1 AND NEXT_CATE_FLAG = 1 
) A
WHERE HOME_OWNER_REG_SEQUENCE.PREVIOUS_CATE = A.PREVIOUS_CATE
	  AND HOME_OWNER_REG_SEQUENCE.NEXT_CATE = A.NEXT_CATE
;

select *
from HOME_OWNER_REG_SEQUENCE
;

--------------COMBINE SEQUENCE--------------------------
DROP TABLE IF EXISTS  U_HOME_OWNER_SEQUENCE_2019Q4;
CREATE TABLE  U_HOME_OWNER_SEQUENCE_2019Q4 AS
SELECT 'HOMEOWNER LOW ACTIVITY CUSTOMERS' AS FILTER,*
FROM HOME_OWNER_LOW_ACT_SEQUENCE
UNION ALL
SELECT 'HOMEOWNER REGULAR SHOPPERS' AS FILTER,*
FROM HOME_OWNER_REG_SEQUENCE
;

-----------------------------------------------------BASKET: C.REGULAR SHOPPERS H1-----------------------------------------

DROP TABLE IF EXISTS REG_CUST_CATE_BASKET_H1;
CREATE TEMP TABLE REG_CUST_CATE_BASKET_H1 AS
SELECT DISTINCT A.MEMBER_NUMBER,SUBDEPT_NAME
FROM TXN_2YR A INNER JOIN HOMEOWNER_CUST B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND CUSTOMER_SEGMENT_V2 = 'HOMEOWNER REGULAR SHOPPERS'
WHERE TXN_DATE:: DATE BETWEEN '2019-01-01' AND '2019-06-30' --**CHANGE
;

DROP TABLE IF EXISTS REG_BASKET_H1;
CREATE TEMP TABLE REG_BASKET_H1 AS
SELECT DISTINCT A.MEMBER_NUMBER,CATE_A,CATE_B
FROM (SELECT DISTINCT MEMBER_NUMBER FROM REG_CUST_CATE_BASKET_H1 ) A
	 CROSS JOIN 
	 ( (SELECT DISTINCT SUBDEPT_NAME AS CATE_A FROM TXN_2YR WHERE SUBDEPT_NAME NOT IN ('CONTRACTOR SERVICE','CARPARK','KIDS','USES STORE','FLOOR  & WALL  DECORATIVE','HBC','RIMS','SERVICE'
	 																					,'READY-MADE PRODUCT','PROFILE SYSTEM','PC TRAINING','SUBLET','MADE TO ORDER','DIY KITCHEN PROJECT'
	 																					,'SHOCK ABSORBER','WOOD & ACC','HOME ORGANIZER','BRAKE SYSTEM','SPARE PART','BATTERY','UNIFORM'
	 																					,'SPARE PART & ACCESSORIES','CONCRETE KITCHEN','TYRE','ENGINE OIL & FILTER' --CUST < 4,000
	 																					,'PREMIUM','BILL & TOP UP','SERVICE-OPERATION','HOME SERVICES','GIFT & PREMIUM','NO BAG','DELIVERY FEE','PREMIUM WITH PURCHASE','HOMEWORKS SERVICE')) B
	 	CROSS JOIN (SELECT DISTINCT SUBDEPT_NAME AS CATE_B FROM TXN_2YR WHERE SUBDEPT_NAME NOT IN ('CONTRACTOR SERVICE','CARPARK','KIDS','USES STORE','FLOOR  & WALL  DECORATIVE','HBC','RIMS','SERVICE'
	 																					,'READY-MADE PRODUCT','PROFILE SYSTEM','PC TRAINING','SUBLET','MADE TO ORDER','DIY KITCHEN PROJECT'
	 																					,'SHOCK ABSORBER','WOOD & ACC','HOME ORGANIZER','BRAKE SYSTEM','SPARE PART','BATTERY','UNIFORM'
	 																					,'SPARE PART & ACCESSORIES','CONCRETE KITCHEN','TYRE','ENGINE OIL & FILTER' --CUST < 4,000
	 																					,'PREMIUM','BILL & TOP UP','SERVICE-OPERATION','HOME SERVICES','GIFT & PREMIUM','NO BAG','DELIVERY FEE','PREMIUM WITH PURCHASE','HOMEWORKS SERVICE')) C
	 ) Z
;

DROP TABLE IF EXISTS REG_BASKET_H1_FLAG;
CREATE TEMP TABLE REG_BASKET_H1_FLAG AS
SELECT A.*
		,CASE WHEN B.MEMBER_NUMBER IS NOT NULL THEN 1 ELSE 0 END AS CATE_A_FLAG
		,CASE WHEN C.MEMBER_NUMBER IS NOT NULL THEN 1 ELSE 0 END AS CATE_B_FLAG
FROM REG_BASKET_H1 A
	 LEFT JOIN REG_CUST_CATE_BASKET_H1 B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND A.CATE_A = B.SUBDEPT_NAME
	 LEFT JOIN REG_CUST_CATE_BASKET_H1 C ON A.MEMBER_NUMBER = C.MEMBER_NUMBER AND A.CATE_B = C.SUBDEPT_NAME
;

DELETE FROM REG_BASKET_H1_FLAG
WHERE CATE_A_FLAG = 0 AND CATE_B_FLAG = 0;

DROP TABLE IF EXISTS REG_BASKET_H1;

DROP TABLE IF EXISTS  U_HOME_OWNER_REG_BASKET_H1_2019Q4;
CREATE TABLE  U_HOME_OWNER_REG_BASKET_H1_2019Q4 AS
SELECT CATE_A
		,CATE_B
		,COUNT(DISTINCT CASE WHEN CATE_A_FLAG = 1 THEN  MEMBER_NUMBER END) AS A_CNT
		,COUNT(DISTINCT CASE WHEN CATE_B_FLAG = 1 THEN  MEMBER_NUMBER END) AS B_CNT
		,COUNT(DISTINCT CASE WHEN CATE_A_FLAG = 1 AND CATE_B_FLAG = 1 THEN  MEMBER_NUMBER END) AS BOTH_CNT
--		,COUNT(DISTINCT CASE WHEN CATE_A_FLAG = 1 AND CATE_B_FLAG = 1 THEN  MEMBER_NUMBER END)*1.0/COUNT(DISTINCT CASE WHEN CATE_A_FLAG = 1 THEN  MEMBER_NUMBER END) PROB_B_GIVEN_A
		,NULL :: FLOAT AS PROB_B_GIVEN_A
		,NULL :: FLOAT AS PROB_B
		,NULL :: FLOAT AS PROB_A
		,NULL :: FLOAT AS LIFT
FROM REG_BASKET_H1_FLAG
GROUP BY CATE_A
		,CATE_B
;

UPDATE  U_HOME_OWNER_REG_BASKET_H1_2019Q4
SET PROB_B_GIVEN_A = A.PROB_B_GIVEN_A
FROM 
(
	SELECT CATE_A
			,CATE_B
			,COUNT(DISTINCT CASE WHEN CATE_A_FLAG = 1 AND CATE_B_FLAG = 1 THEN MEMBER_NUMBER END)*1.0/COUNT(DISTINCT CASE WHEN CATE_A_FLAG = 1 THEN MEMBER_NUMBER END) PROB_B_GIVEN_A
	FROM REG_BASKET_H1_FLAG  
	GROUP BY CATE_A
			,CATE_B
	HAVING COUNT(DISTINCT CASE WHEN CATE_A_FLAG = 1 THEN MEMBER_NUMBER END) > 0
) A
WHERE  U_HOME_OWNER_REG_BASKET_H1_2019Q4.CATE_A = A.CATE_A
	  AND  U_HOME_OWNER_REG_BASKET_H1_2019Q4.CATE_B = A.CATE_B
;

UPDATE  U_HOME_OWNER_REG_BASKET_H1_2019Q4
SET PROB_B = B_CNT*1.0/
(
	SELECT COUNT(DISTINCT MEMBER_NUMBER) AS TOTAL_CNT
	FROM REG_BASKET_H1_FLAG  
	WHERE CATE_B_FLAG = 1
)
;

UPDATE  U_HOME_OWNER_REG_BASKET_H1_2019Q4
SET PROB_A = A_CNT*1.0/
(
	SELECT COUNT(DISTINCT MEMBER_NUMBER) AS TOTAL_CNT
	FROM REG_BASKET_H1_FLAG  
	WHERE CATE_A_FLAG = 1
)
;

UPDATE  U_HOME_OWNER_REG_BASKET_H1_2019Q4
SET LIFT = PROB_B_GIVEN_A/PROB_B
;

-----------------------------------------------------BASKET: C.REGULAR SHOPPERS H2-----------------------------------------

DROP TABLE IF EXISTS REG_CUST_CATE_BASKET_H2;
CREATE TEMP TABLE REG_CUST_CATE_BASKET_H2 AS
SELECT DISTINCT A.MEMBER_NUMBER,SUBDEPT_NAME
FROM TXN_2YR A INNER JOIN HOMEOWNER_CUST B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND CUSTOMER_SEGMENT_V2 = 'HOMEOWNER REGULAR SHOPPERS'
WHERE TXN_DATE:: DATE BETWEEN '2019-07-01' AND '2019-12-31' --**CHANGE
;

DROP TABLE IF EXISTS REG_BASKET_H2;
CREATE TEMP TABLE REG_BASKET_H2 AS
SELECT DISTINCT A.MEMBER_NUMBER,CATE_A,CATE_B
FROM (SELECT DISTINCT MEMBER_NUMBER FROM REG_CUST_CATE_BASKET_H2 ) A
	 CROSS JOIN 
	 ( (SELECT DISTINCT SUBDEPT_NAME AS CATE_A FROM TXN_2YR WHERE SUBDEPT_NAME NOT IN ('CONTRACTOR SERVICE','CARPARK','KIDS','USES STORE','FLOOR  & WALL  DECORATIVE','HBC','RIMS','SERVICE'
	 																					,'READY-MADE PRODUCT','PROFILE SYSTEM','PC TRAINING','SUBLET','MADE TO ORDER','DIY KITCHEN PROJECT'
	 																					,'SHOCK ABSORBER','WOOD & ACC','HOME ORGANIZER','BRAKE SYSTEM','SPARE PART','BATTERY','UNIFORM'
	 																					,'SPARE PART & ACCESSORIES','CONCRETE KITCHEN','TYRE','ENGINE OIL & FILTER' --CUST < 4,000
	 																					,'PREMIUM','BILL & TOP UP','SERVICE-OPERATION','HOME SERVICES','GIFT & PREMIUM','NO BAG','DELIVERY FEE','PREMIUM WITH PURCHASE','HOMEWORKS SERVICE')) B
	 	CROSS JOIN (SELECT DISTINCT SUBDEPT_NAME AS CATE_B FROM TXN_2YR WHERE SUBDEPT_NAME NOT IN ('CONTRACTOR SERVICE','CARPARK','KIDS','USES STORE','FLOOR  & WALL  DECORATIVE','HBC','RIMS','SERVICE'
	 																					,'READY-MADE PRODUCT','PROFILE SYSTEM','PC TRAINING','SUBLET','MADE TO ORDER','DIY KITCHEN PROJECT'
	 																					,'SHOCK ABSORBER','WOOD & ACC','HOME ORGANIZER','BRAKE SYSTEM','SPARE PART','BATTERY','UNIFORM'
	 																					,'SPARE PART & ACCESSORIES','CONCRETE KITCHEN','TYRE','ENGINE OIL & FILTER' --CUST < 4,000
	 																					,'PREMIUM','BILL & TOP UP','SERVICE-OPERATION','HOME SERVICES','GIFT & PREMIUM','NO BAG','DELIVERY FEE','PREMIUM WITH PURCHASE','HOMEWORKS SERVICE')) C
	 ) Z
;

DROP TABLE IF EXISTS REG_BASKET_H2_FLAG;
CREATE TEMP TABLE REG_BASKET_H2_FLAG AS
SELECT A.*
		,CASE WHEN B.MEMBER_NUMBER IS NOT NULL THEN 1 ELSE 0 END AS CATE_A_FLAG
		,CASE WHEN C.MEMBER_NUMBER IS NOT NULL THEN 1 ELSE 0 END AS CATE_B_FLAG
FROM REG_BASKET_H2 A
	 LEFT JOIN REG_CUST_CATE_BASKET_H2 B ON A.MEMBER_NUMBER = B.MEMBER_NUMBER AND A.CATE_A = B.SUBDEPT_NAME
	 LEFT JOIN REG_CUST_CATE_BASKET_H2 C ON A.MEMBER_NUMBER = C.MEMBER_NUMBER AND A.CATE_B = C.SUBDEPT_NAME
;

DELETE FROM REG_BASKET_H2_FLAG
WHERE CATE_A_FLAG = 0 AND CATE_B_FLAG = 0;

DROP TABLE IF EXISTS REG_BASKET_H2;

DROP TABLE IF EXISTS  U_HOME_OWNER_REG_BASKET_H2_2019Q4;
CREATE TABLE  U_HOME_OWNER_REG_BASKET_H2_2019Q4 AS
SELECT CATE_A
		,CATE_B
		,COUNT(DISTINCT CASE WHEN CATE_A_FLAG = 1 THEN  MEMBER_NUMBER END) AS A_CNT
		,COUNT(DISTINCT CASE WHEN CATE_B_FLAG = 1 THEN  MEMBER_NUMBER END) AS B_CNT
		,COUNT(DISTINCT CASE WHEN CATE_A_FLAG = 1 AND CATE_B_FLAG = 1 THEN  MEMBER_NUMBER END) AS BOTH_CNT
--		,COUNT(DISTINCT CASE WHEN CATE_A_FLAG = 1 AND CATE_B_FLAG = 1 THEN  MEMBER_NUMBER END)*1.0/COUNT(DISTINCT CASE WHEN CATE_A_FLAG = 1 THEN  MEMBER_NUMBER END) PROB_B_GIVEN_A
		,NULL :: FLOAT AS PROB_B_GIVEN_A
		,NULL :: FLOAT AS PROB_B
		,NULL :: FLOAT AS PROB_A
		,NULL :: FLOAT AS LIFT
FROM REG_BASKET_H2_FLAG
GROUP BY CATE_A
		,CATE_B
;

UPDATE  U_HOME_OWNER_REG_BASKET_H2_2019Q4
SET PROB_B_GIVEN_A = A.PROB_B_GIVEN_A
FROM 
(
	SELECT CATE_A
			,CATE_B
			,COUNT(DISTINCT CASE WHEN CATE_A_FLAG = 1 AND CATE_B_FLAG = 1 THEN MEMBER_NUMBER END)*1.0/COUNT(DISTINCT CASE WHEN CATE_A_FLAG = 1 THEN MEMBER_NUMBER END) PROB_B_GIVEN_A
	FROM REG_BASKET_H2_FLAG  
	GROUP BY CATE_A
			,CATE_B
	HAVING COUNT(DISTINCT CASE WHEN CATE_A_FLAG = 1 THEN MEMBER_NUMBER END) > 0
) A
WHERE  U_HOME_OWNER_REG_BASKET_H2_2019Q4.CATE_A = A.CATE_A
	  AND  U_HOME_OWNER_REG_BASKET_H2_2019Q4.CATE_B = A.CATE_B
;

UPDATE  U_HOME_OWNER_REG_BASKET_H2_2019Q4
SET PROB_B = B_CNT*1.0/
(
	SELECT COUNT(DISTINCT MEMBER_NUMBER) AS TOTAL_CNT
	FROM REG_BASKET_H2_FLAG  
	WHERE CATE_B_FLAG = 1
)
;

UPDATE  U_HOME_OWNER_REG_BASKET_H2_2019Q4
SET PROB_A = A_CNT*1.0/
(
	SELECT COUNT(DISTINCT MEMBER_NUMBER) AS TOTAL_CNT
	FROM REG_BASKET_H2_FLAG  
	WHERE CATE_A_FLAG = 1
)
;

UPDATE  U_HOME_OWNER_REG_BASKET_H2_2019Q4
SET LIFT = PROB_B_GIVEN_A/PROB_B
;
---------------------------------------------------------------------------------------------------------------



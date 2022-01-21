USE [WIMS]
GO
/* Function to check hourly WHP data*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER FUNCTION [dbo].[WHPCHECK]
(		
	@date1 NVARCHAR(10) -- Persian Date
)

RETURNS TABLE 
AS
RETURN 

 
-- Get data from tblwhp 
WITH

q0 AS (
SELECT tbl0.date1, tbl0.spd, tbl0.Well_no, tbl0.well_index, ca.hour1 AS hour1, ca.pressure, 
CASE WHEN CAST(CAST(hour1 AS NVARCHAR(2)) AS REAL) <> 0 THEN 'S'+ CAST(CAST(CAST(hour1 AS NVARCHAR(2)) AS REAL) AS NVARCHAR(2))
ELSE 'S'
END AS colname
FROM [WIMS].[dbo].[tblwhp] AS tbl0
CROSS APPLY (
	VALUES
	(PARSE('00:00' AS TIME), S), (PARSE('01:00' AS TIME), S1),(PARSE('02:00' AS TIME), S2), (PARSE('03:00' AS TIME), S3),(PARSE('04:00' AS TIME), S4),(PARSE('05:00' AS TIME), S5),(PARSE('06:00' AS TIME), S6),(PARSE('07:00' AS TIME), S7),(PARSE('08:00' AS TIME), S8),
	(PARSE('09:00' AS TIME), S9),(PARSE('10:00' AS TIME), S10),(PARSE('11:00' AS TIME), S11),(PARSE('12:00' AS TIME), S12),(PARSE('13:00' AS TIME), S13),(PARSE('14:00' AS TIME), S14),
	(PARSE('15:00' AS TIME), S15),(PARSE('16:00' AS TIME), S16),(PARSE('17:00' AS TIME), S17),(PARSE('18:00' AS TIME), S18),(PARSE('19:00' AS TIME), S19),(PARSE('20:00' AS TIME), S20),
	(PARSE('21:00' AS TIME), S21),(PARSE('22:00' AS TIME), S22),(PARSE('23:00' AS TIME), S23)
	) AS ca (hour1, pressure)
	WHERE date1 = @date1
),


/***
q1 as (

Select *, (CASE WHEN SUBSTRING(recordhour, 2, len(recordhour)-1) = '' Then PARSE('00:00' AS TIME) Else PARSE(SUBSTRING(recordhour, 2, len(recordhour)-1)+':00' AS TIME) END) as hour1 from 

(SELECT  date1, spd, Well_no, S, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19, S20, S21, S22, S23
  FROM [WIMS].[dbo].[tblwhp]
  where date1 = '1400/08/15') as tbl1
  unpivot (pressure for recordhour in (S, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19, S20, S21, S22, S23)) as tbl1
) , 
***/

-- Get last data from tblaccess for each platform 
q2 AS (
SELECT tbl1.spd , tbl1.min , tbl1.max , tbl1.minval , tbl1.maxval  FROM [WIMS].[dbo].[tblaccept] AS tbl1
				LEFT JOIN [WIMS].[dbo].[tblaccept] AS tbl2
				ON tbl1.date1 < tbl2.date1 AND tbl1.spd = tbl2.spd  AND tbl2.date1<=@date1 WHERE tbl2.spd IS NULL
),

-- Get latest c-n data for each well 
q3 AS (
SELECT tbl1.date1, tbl1.spd, tbl1.well_index, tbl1.WHSP, tbl1.c, tbl3.well_name AS well_name FROM [WIMS].[dbo].[tblcnnew] as tbl1
  --left join [WIMS].[dbo].[tblcnnew] as tbl2 on tbl1.date1 < tbl2.date1 and tbl1.spd = tbl2.spd and tbl1.well_index = tbl2.well_index 
  LEFT JOIN  [WIMS].[dbo].[well_name] AS tbl3 ON tbl1.spd = tbl3.spd collate Arabic_100_CI_AI AND tbl1.well_index = tbl3.id
  INNER JOIN (SELECT max(date1) AS date1, spd, well_index FROM  [WIMS].[dbo].[tblcnnew] WHERE date1 < = @date1 GROUP BY spd, well_index) AS tbl2 ON tbl1.date1 = tbl2.date1 AND tbl1.spd = tbl2.spd AND tbl1.well_index = tbl2.well_index
 -- where tbl2.well_index is null and tbl1.date1 <= @date1
) ,

-- Get shutin data and determine any inclusive shutin period 
q4 AS
(
SELECT *, 
	LEAD(az, 1) OVER(PARTITION BY date1+spd+well_no ORDER BY az) AS azlead, 
	LAG(ta, 1) OVER(PARTITION BY date1+spd+well_no ORDER BY az) AS talag
	FROM [WIMS].[dbo].[p2_Well_child] AS tbl4
	WHERE date1 = @date1
),


q5 AS (
SELECT q0.Date1, q0.spd, q0.Well_no,q2.min, q2.max, q2.minval, q2.maxval, round(q3.c, 6) AS c, q3.WHSP,q4.az, q4.ta, q4.azlead, q4.talag,q0.pressure, q0.hour1, q0.colname  FROM q0
	LEFT JOIN q2 ON q0.spd = q2.spd collate Arabic_100_CI_AI
	LEFT JOIN q3 ON q0.spd = q3.spd collate Arabic_100_CI_AI AND q0.Well_no = q3.well_name
	LEFT JOIN q4 ON q4.spd = q0.spd AND q4.Well_no = q0.Well_no AND hour1 BETWEEN az AND ta OR (ta IS NULL AND az IS NULL)
 
),
-- Join results and perform case solution

qfinal AS (
SELECT * 
,(CASE 
WHEN (hour1 > az AND hour1 < ta AND DATEDIFF(minute, hour1, ta) >= 59) THEN 'ddd'
--WHEN (WHSP is null or c=10) THEN 'ddd'
WHEN( az = hour1 AND DATEDIFF(minute, hour1, ta) >= 59 ) THEN 'ddd'
--WHEN(azlead is null and hour1 = ta) THEN 'ddd'
WHEN(az = talag OR ta = azlead) THEN 'ddd'

WHEN( pressure = 0 ) THEN 'Less Than Minval'
WHEN (WHSP-pressure) > max THEN 'Too Much Drawdown'
WHEN ((WHSP-pressure) < min AND pressure <= WHSP) THEN 'Low DrawDown'
WHEN (pressure < minval) THEN 'Less Than Minval'
WHEN( pressure > WHSP) THEN 'Greater Than WHSIP'
WHEN pressure IS NULL THEN 'No Data Entry'  
ELSE '---' END ) AS comment 

FROM q5 

)

--select * from q0

SELECT TOP 1000000 * FROM
(
SELECT * FROM qfinal WHERE comment <> 'ddd' AND comment <> '---' 
UNION
SELECT @date1, rtrim(spdname.spd_name),NULL, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, 'No Data Entry' AS comment  
					FROM WIMS.dbo.spdname WHERE spdname.spd_name NOT IN (SELECT DISTINCT(tblwhp.spd) FROM WIMS.dbo.tblwhp WHERE date1 = @date1)) AS tbl123 ORDER BY SUBSTRING(spd,4,2) * 1, spd, len(Well_no), Well_no, hour1 
					



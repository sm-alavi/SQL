
/*
Base function for well flow rate calculation
*/

USE [WIMS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[qcalc_base]
(	
	@date1 nvarchar(10),
	@date2 nvarchar(10)
)

RETURNS TABLE 
AS
RETURN 

(
	WITH 

q1 AS (SELECT  date1, spd collate Arabic_100_CI_AI AS spd, Well_no collate Arabic_100_CI_AI AS wellno_dcs ,az, ta, h AS hour,
		CASE 
			 WHEN h = DATEPART(HOUR, az) AND  h = DATEPART(HOUR, ta) THEN DATEPART(MINUTE, ta) - DATEPART(MINUTE, az)
			 WHEN h = DATEPART(HOUR, az) THEN 60 - DATEPART(MINUTE, az)
			 WHEN h = DATEPART(HOUR, ta) THEN DATEPART(MINUTE, ta)
			 WHEN h > DATEPART(HOUR, az) AND h< DATEPART(HOUR, ta) THEN 60
			 ELSE 0 
		END  AS duration

 FROM WIMS.dbo.p2_Well_child CROSS APPLY WIMS.dbo.tblhour WHERE date1 BETWEEN  @date1 AND @date2)

,q2 AS (SELECT date1, spd, wellno_dcs, hour, CASE WHEN sum(duration) < 59 THEN sum(duration) ELSE 60 END AS duration FROM q1 GROUP BY spd, wellno_dcs,date1, hour )

,q4 AS (SELECT tbl0.date1, tbl0.spd, tbl0.Well_no AS wellno_dcs, tbl0.well_index, ca.hour1 AS hour1, CAST(SUBSTRING(CAST(ca.hour1 as VARCHAR), 1, 2) AS INT) AS txt1
			, ca.pressure
		FROM [WIMS].[dbo].[tblwhp] AS tbl0
		CROSS APPLY (
		VALUES
		(PARSE('00:00' AS TIME), S), (PARSE('01:00' AS TIME), S1),(PARSE('02:00' AS TIME), S2), (PARSE('03:00' AS TIME), S3),(PARSE('04:00' AS TIME), S4),(PARSE('05:00' AS TIME), S5),(PARSE('06:00' AS TIME), S6),(PARSE('07:00' AS TIME), S7),(PARSE('08:00' AS TIME), S8),
		(PARSE('09:00' AS TIME), S9),(PARSE('10:00' AS TIME), S10),(PARSE('11:00' AS TIME), S11),(PARSE('12:00' AS TIME), S12),(PARSE('13:00' AS TIME), S13),(PARSE('14:00' AS TIME), S14),
		(PARSE('15:00' AS TIME), S15),(PARSE('16:00' AS TIME), S16),(PARSE('17:00' AS TIME), S17),(PARSE('18:00' AS TIME), S18),(PARSE('19:00' AS TIME), S19),(PARSE('20:00' AS TIME), S20),
		(PARSE('21:00' AS TIME), S21),(PARSE('22:00' AS TIME), S22),(PARSE('23:00' AS TIME), S23)
		) AS ca (hour1, pressure) WHERE date1 BETWEEN @date1 AND @date2)

, q5 AS (SELECT q4.date1 collate Arabic_100_CI_AI AS date1 , rtrim(q4.spd) AS spd, rtrim(q4.wellno_dcs) AS wellno_dcs, q4.hour1, q2.duration AS shut_min, 60- ISNULL( q2.duration, 0) AS open_min ,q4.pressure FROM q4 LEFT JOIN q2 ON q4.spd = q2.spd AND q4.wellno_dcs = q2.wellno_dcs AND q4.txt1 = q2.hour AND q4.date1 = q2.Date1)

,q33 AS (SELECT tbl1.date1, rtrim(tbl1.spd) AS spd, rtrim(tbl1.well_no) AS wellno_fld, tbl2.well_name AS wellno_dcs, tbl1.c, tbl1.n, tbl1.WHSP, tbl1.test_date,tbl1.decline FROM WIMS.dbo.tblcnnew AS tbl1
		 LEFT JOIN WIMS.dbo.well_name AS tbl2 ON tbl1.spd collate Arabic_100_CI_AI = tbl2.spd AND tbl1.well_index = tbl2.id WHERE tbl1.date1 <= @date2 )

,q44 AS (SELECT * ,   lag(date1) OVER(PARTITION BY spd+'-'+wellno_fld ORDER BY date1 DESC) AS datelead,  lead(date1) OVER(PARTITION BY spd + wellno_fld  ORDER BY date1 DESC) AS datelag FROM q33)

,q45 AS (SELECT *, WIMS.dbo.PersianToMiladi(datelead) AS datelead_m FROM q44)

,q13 AS (SELECT q5.Date1, q5.spd, q5.wellno_dcs, q5.open_min, q5.pressure, q5.shut_min, q45.c, q45.n, q45.WHSP,q45.decline ,q45.test_date, q45.datelag, q45.datelead, q45.date1 AS dt FROM q5 LEFT JOIN q45 ON 
q5.spd collate Arabic_100_CI_AI = q45.spd AND q5.wellno_dcs collate Arabic_100_CI_AI = q45.wellno_dcs  
AND ((q5.date1 >=q45.date1 AND q5.date1 < q45.datelead AND q45.datelead IS NOT NULL) OR (q45.datelead IS NULL AND q5.date1 >= q45.date1))
) 
				
,q14 AS (SELECT *, CASE 
						WHEN c = 20 THEN (n * pressure*1.000 + decline*1.000) * 1/24.000 * (open_min / 60.000)  
						WHEN c = 30 AND pressure = 0 THEN 0
						WHEN c = 30 AND pressure > 0 THEN (n / pressure * 1.000) * decline * (1/24.000) * (open_min / 60.000)
						
						WHEN c NOT IN (10,20,30) AND shut_min = 60 THEN 0
						WHEN c NOT IN (10,20,30) THEN ( CASE 
														WHEN rtrim(spd) IN ('XXX', 'XXXX') THEN (1 - ((DATEDIFF(day, test_date, WIMS.dbo.PersianToMiladi(date1) )/30.4) * decline / 100)) * ((open_min / 60.0) * c * power((POWER(whsp*1.00 ,2) - power(pressure*1.00 , 2))*1.00000000, round(n, 7)) / 24.000) 
														ELSE (1-(decline/100.000)) * ((open_min / 60.000) * c * power((POWER(whsp*1.000 ,2) - power(pressure*1.000 , 2))*1.000000000, round(n, 7) ) / 24.00000) 
														END )    
						WHEN c = 10 THEN 0
						END AS q_gas,
						
					CASE 
						WHEN shut_min = 60 THEN NULL
						--WHEN shut_min is null THEN null 
						ELSE pressure
						END AS avg_whp, 
					CASE 
						WHEN shut_min = 60 THEN whsp
						WHEN shut_min IS NULL THEN pressure 
						ELSE pressure 
						END AS avg_whp1
						
						FROM q13 )


,q15 AS (SELECT date1, spd, wellno_dcs, round(sum(q_gas), 2) AS q_gas , sum(shut_min) AS shut_min, sum(open_min) AS open_min
		,round(avg(avg_whp), 2) AS avg_whp , round(avg(avg_whp1), 2) AS avg_whp1
		FROM q14 GROUP BY date1,spd,wellno_dcs )

SELECT * FROM q15
		
)
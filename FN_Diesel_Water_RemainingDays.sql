
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[FN_Diesel_Water_RemainingDays_Calculation]
(	
)
RETURNS TABLE 
AS
RETURN 
(

	with 

q1 as (SELECT [Date1]
      ,[spd]
      ,[freshwater_tank] + [freshwater_on] as water
	  ,isnull(LAG(freshwater_on + freshwater_tank) over(partition by spd order by date1), 0) as water_lag
      ,[Diesel_tank] + [Diesel_tote] as diesel
	  ,isnull(LAG(diesel_tank + Diesel_tote) over(partition by spd order by date1), 0) as diesel_lag
  FROM [PRCC2].[dbo].[Storage] where date1 >= '1401/01/01')

, q2_diesel as (select date1, spd, abs(diesel-diesel_lag) as diesel_diff from q1 where diesel-diesel_lag < 0 )
, q3_diesel as (select date1, spd, diesel_diff, stdev(diesel_diff) over(partition by spd) as stdev1, avg(diesel_diff) over(partition by spd) as avg1 from q2_diesel )
, q4_diesel as (select date1, spd, abs(diesel_diff) as diesel_diff from q3_diesel  where  abs(diesel_diff) < CASE WHEN ROUND((avg1/stdev1), 1) <= 1 THEN 1 ELSE ROUND((avg1/stdev1), 1) END  * abs(stdev1) 
)
, q5_diesel as (select spd, round(avg(diesel_diff), 0) as diesel_avg from q4_diesel group by spd)


, q2_water as (select date1, spd, abs(water-water_lag) as water_diff from q1  where water-water_lag < 0 )
, q3_water as (select date1, spd, water_diff, stdev(water_diff) over(partition by spd) as stdev1, avg(water_diff) over(partition by spd) as avg1 from q2_water)
, q4_water as (select date1, spd, abs(water_diff) as water_diff from q3_water  where abs(water_diff) < CASE WHEN ROUND((avg1/stdev1), 1) <=1 THEN 1 ELSE ROUND((avg1/stdev1), 1) END *  abs(stdev1)
	--where abs(water_diff) < 2 * abs(stdev1)
	)
, q5_water as (select spd, round(avg(water_diff), 0) as water_avg from q4_water group by spd)

, q6 as (select t1.spd, t1.freshwater_on + t1.freshwater_tank as water_tank, t1.Diesel_tank + t1.Diesel_tote as diesel_tank from Storage as t1
		inner join (select max(date1) as date1, spd from Storage group by spd) as t2 on t1.Date1 = t2.date1 and t1.spd = t2.spd)

, q7 as (select spd_name as platform, t2.diesel_tank, t2.water_tank, t3.diesel_avg, t4.water_avg from spdname as t1 
		inner join q6 as t2 on t1.spd_name = t2.spd
		inner join q5_diesel as t3 on t3.spd = t1.spd_name
		inner join q5_water as t4 on t4.spd = t1.spd_name
		)

select top 100000 platform, diesel_tank , diesel_avg as diesel_rate , Round(diesel_tank/diesel_avg, 0) as diesel_remain, water_tank, water_avg as water_rate, ROUND(water_tank/water_avg, 0) as water_remain from q7 order by SUBSTRING(platform, 4, 2) * 1, platform

)
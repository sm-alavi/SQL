
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FN_MonDep_DailyReport_Calculate]
(	
	@date1 nvarchar(10)
)
RETURNS TABLE 
AS
RETURN 
(
	WITH
q1 as (select t1.spd,t1.date1,  barname as mosavab from dbo.mosavab as t1 inner join (select max(date1) as date1, spd from dbo.mosavab where date1 <=@date1 group by spd ) as t2 on t1.date1 = t2.date1 and t1.spd = t2.spd)

,q2 as (select t1.*, t2.qgas, t2.cond from platforms_sub_production(@date1, @date1) as t1
		left join (select * from FN_PlatformProduction_SPD3SPD4(@date1)) as t2 
		on t1.spd = t2.spd)

,q3 as (select spd,
				CASE 
					WHEN case1 = 1 THEN (fwko1*1.000000 + fwko2*1.000000) + (cl1*1.000000+ cl2*1.000000) * 0.001217 
					WHEN Case1 = 2 THEN qgas
					WHEN case1 = 3 THEN (fwko1*1.000000 + fwko2*1.000000) + (cl1*1.000000+ cl2*1.000000) * 0.001217 
					WHEN case1 = 4 THEN (fwko1*1.000000+ fwko2*1.000000 + gas_test*1.000000) + (cl1*1.000000 + cl2*1.000000) *  0.001217 
					WHEN case1 = 5 THEN (fwko1*1.000000+ fwko2*1.000000 + gas_test*1.000000) + (cl1*1.000000 + cl2*1.000000+cond_test*1.000000) *  0.001217 
					WHEN case1 = 6 THEN (gas_production*1.000000) + (cl1*1.000000+ cl2*1.000000) * 0.001217
				END as tolid,

				CASE 
					WHEN case1 in (1,3,4,6) THEN (cl1*1.000000+ cl2*1.000000) 
					WHEN Case1 = 2 THEN cond
					WHEN case1 = 5 THEN (cl1*1.000000 + cl2*1.000000+cond_test*1.000000)
				END as mayanat

				from q2)

, q4 as (select spd, 
				CASE WHEN sazeman=N'محدودیت دریافت' then Round(Sum(meghdar), 2)  END as [paeendasti],
				CASE WHEN sazeman=N'تعمیرات اساسی' then Round(Sum(meghdar), 2) END as [overhal],
				CASE WHEN sazeman=N'تعمیرات اضطراری' then Round(Sum(meghdar), 2)  END as [ezterar],
				--CASE WHEN sazeman=N'سایر عوامل' then Round(Sum(meghdar), 2)  END as [sayer], 
				CASE WHEN sazeman not in (N'محدودیت دریافت', N'تعمیرات اساسی', N'تعمیرات اضطراری') then Round(Sum(meghdar), 5)  END as [sayer]
				from tblkahesh
 where date1 = @date1 group by spd, sazeman )


 ,q5 as (select @date1 as date1,  q3.spd, Round(isnull(q1.mosavab, 0),2) as mosavab, ROUNd(isnull(q3.tolid, 0) / 35.314, 2) as tolid, ROUND(isnull(q3.tolid/35.314 - q1.mosavab, 0), 2) as diff,
			CASE 
				WHEN q1.mosavab = 0.0 THEN 0 ELSE ROUND(isnull(q3.tolid/35.314,0) * 100.0/q1.mosavab, 2) END as randeman
				 , isnull(q3.mayanat/1000.00, 0) as mayanat, isnull(t3.ezterar, 0) as ezterar, isnull(t2.overhal, 0) as overhal, isnull(t1.paeendasti, 0) as paeendasti, isnull(t4.sayer, 0) as sayer
		  from q3 
			left join q1 on q1.spd  = q3.spd Collate Arabic_100_CI_AI
			--left join q4 on q3.spd  = q4.spd Collate Arabic_100_CI_AI
			left join (select spd, Round(Sum(meghdar), 2) as [paeendasti] from tblkahesh where sazeman=N'محدودیت دریافت' and date1 = @date1 group by spd) as t1 on t1.spd = q3.spd Collate Arabic_100_CI_AI
			left join (select spd, Round(Sum(meghdar), 2) as [overhal] from tblkahesh where sazeman=N'تعمیرات اساسی' and date1 = @date1 group by spd) as t2 on t2.spd = q3.spd Collate Arabic_100_CI_AI
			left join (select spd, Round(Sum(meghdar), 2) as [ezterar] from tblkahesh where sazeman=N'تعمیرات اضطراری' and date1 = @date1 group by spd ) as t3 on t3.spd = q3.spd Collate Arabic_100_CI_AI
			left join (select spd, Round(Sum(meghdar), 5)  as [sayer] from tblkahesh where  sazeman not in (N'محدودیت دریافت', N'تعمیرات اساسی', N'تعمیرات اضطراری') and date1 = @date1 group by spd ) as t4 on t4.spd = q3.spd Collate Arabic_100_CI_AI
			
			
			)

, q6 as (select q5.*, t1.id as idx from q5 
		left join spdname as t1 on rtrim(t1.spd_name) Collate Arabic_100_CI_AI = q5.spd )

select top 1000000000 * from q6 order by substring(spd,4,2) * 1 , spd
)
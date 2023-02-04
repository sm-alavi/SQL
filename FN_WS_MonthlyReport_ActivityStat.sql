USE [PRCC2]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_WS_MonthlyReport_ActivityStat]    Script Date: 1/4/2023 4:06:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION [dbo].[FN_WS_MonthlyReport_ActivityStat]
(	
	-- Add the parameters for the function here
	@date1 as nvarchar(10), 
	@date2 as nvarchar(10)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	with
q1 as (select  platform, wellno_dcs, wellno_fld, jobtype, dateapply from tblwelloperations
		where dateapply between @date1 and @date2
		)

,q2 as (select jobtype, platform,  count(*) as count1 from q1 group by jobtype, platform)
, q3 as (Select distinct(jobtype), (Select platform+ N'('+ cast(count1 as nvarchar(2))+ CASE WHEN count1 = 1 THEN N' well) ' ELSE N' wells) ' END  as 'data()' from q2 where q2.jobtype = t2.jobtype for xml path('')) as description from q2 as t2) 

, q6 as (select t1.platform, t1.wellno_dcs, t1.wellno_fld from tblwsdefect as t1 
		 inner join [Pars].[dbo].[tblWTSdef] as t2 on t1.def_no = t2.defno
		 where t1.status = 'Closed' and t1.importance = 'EMR' and t1.date1 between @date1 and @date2)
, q7 as (select platform, count(*) as count1 from q6 group by platform )
, q8 as (Select top 1 (Select platform+ N'(' + cast(count1 as nvarchar(10))+CASE WHEN count1 = 1 THEN N' well) ' ELSE N' wells) ' END as 'data()' from q7  for xml path('')) as description from q7 as t2)
, q9 as (select N'تعمیرات اضطراری تجهیزات سرچاهی و درون چاهی' as title,  sum(count1) as count1, description from q7 left join q8 on 1=1

group by description)

, q4 as (select jobtype,  count(*) as count1 from q1 group by jobtype)
, q5 as (select 
		CASE WHEN q4.jobtype = '010-01' THEN N'آزمایش های تفکیک گر سرچاهی' 
			WHEN q4.jobtype = '001-01' THEN N'تعمیرات دوره ای پیشگیرانه'
			WHEN q4.jobtype like '009%' and t1.reason like '(WHS)%' THEN N'آزمایش و پیمایش چاه ها'
			END as title
		 ,q4.count1, q3.description from q4
		inner join q3 on q4.jobtype = q3.jobtype
		left join tblshutinreasonchild as t1 on q4.jobtype = t1.id1)

, q10 as (select * from q5 
		union all 
		select * from q9
		where title is not null
		)

--select * from q5 where title is not null
select * from q10 where title is not null


)
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FN_WS_MonthlyReport_DeliveredWellsStatus]
(
	-- Persian date as function input variables,
	@date1 nvarchar(10),
	@date2 nvarchar(10) 
)
RETURNS 
@table1 TABLE 
(
	title nvarchar(200), 
	wells nvarchar(1000)
)
AS
BEGIN
	Declare @year  nvarchar(4) = SUBSTRING(@date1, 1,4);
    Declare @nimsal  nvarchar(10) =  CASE WHEN SUBSTRING(@date1, 6,2) * 1 <=6 then @year + '-01' ELSE @year + '-02' END;
    Declare @dateapply  nvarchar(10) = CASE WHEN SUBSTRING(@date1, 6,2) * 1 <=6 then @year + '/01/01' ELSE @year + '/07/01' END;
    Declare @dateapplysal nvarchar(10) = @year + '/01/01';

with 
qplatform as (select spd_name collate arabic_100_CI_AI as platform from spdname)
, q00 as (select platform, dateapply, wellno_dcs, wellno_fld, jobtype from tblwelloperations as t1 
		 where dateapply between @dateapplysal and @date2 and jobtype = '999-06' )
, q000 as (select platform, dateapply, wellno_dcs, wellno_fld, jobtype from tblwelloperations as t1 
		 where dateapply between @date1 and @date2 and jobtype = '999-06' )
,q1 as (
select spd, WELL,wellhandover,t2.sal
		 from pars.dbo.tblWTSplanTESTchild as t1
		 left join pars.dbo.tblWTSplanTESTparant as t2 on t1.Pid = t2.id
		 where t2.sal = @nimsal and wellhandover = 1
)

,q2 as (Select platform, (platform + '( '+ (Select ''+ wellno_fld + ',' as 'data()' from q00 where q00.platform = t2.platform for xml path('')) + ')') as wells from q00 as t2)
, q3 as (select   max(wells) as wells from q2 group by platform)
,q_delivered as (Select top 1 N'چاه هایی که تاکنون تحویل شده' as title, (Select ''+ wells + '  ' as 'data()' from q3  for xml path('')) as wells1 from q3 as t2)


,q4 as (select * from q1 where not exists (select * from q00 where q00.platform = q1.SPD and q00.wellno_fld = q1.WELL ))
,q5 as (Select spd, (spd + '( '+ (Select ''+ well + ', ' as 'data()' from q4 where q4.spd = t2.spd for xml path('')) + ')') as wells from q4 as t2)
, q6 as (select   max(wells) as wells from q5 group by spd)
,q_notdelivered as (Select top 1 N'چاه هایی که تاکنون تحویل نشده' as title, (Select ''+ wells + '  ' as 'data()' from q6  for xml path('')) as wells1 from q6 as t2)

,q22 as (Select platform, (platform + '( '+ (Select ''+ wellno_fld + ',' as 'data()' from q000 where q000.platform = t2.platform for xml path('')) + ')') as wells from q000 as t2)
, q33 as (select   max(wells) as wells from q22 group by platform)
,q_delivered_month as (Select top 1 N'چاه های تحویل شده در ماه جاری' as title, (Select ''+ wells + '  ' as 'data()' from q33  for xml path('')) as wells1 from q33 as t2)

, q7 as (select * from q_delivered_month union all select * from q_delivered union all select * from q_notdelivered)



insert @table1 
select * from q7

	RETURN 
END
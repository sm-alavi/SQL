SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_WS_WellPivotRawTable_Date]
	@date1 as nvarchar(10)
AS
BEGIN
	
	declare @query as nvarchar(max);
    declare @cols as nvarchar(max);

	SET NOCOUNT ON;

	with 

q0 as (select  well_name_field, rtrim(ltrim(spd)) as spd , id from well_name)
,q1 as (select t1.* from tblPlatformInReportStatus as t1
		 inner join (select max(date1) as date1, platform from tblPlatformInReportStatus where date1 <= @date1 group by platform) as t2
		 on t1.date1 = t2.date1 and t1.platform = t2.platform
		 where t1.isvisible = 1)
,q2 as (select q0.* from q0 inner join q1 on q0.spd = q1.platform)
,q3 as (select  well_name_field, id,
		CASE 
			WHEN spd like 'SPD19A' and well_name_field like 'B%' THEN 'SPD19B' 
			WHEN spd like 'SPD19C' and well_name_field like '2-%' THEN 'SPD19D'
			ELSE spd
		END as spd 
		from q2) 

,q4 as (select top 10000 max(spd) as spd from q3 group by spd order by substring(spd, 4, 2) * 1, spd )

,q5 as (select top 1 cols = Stuff((select ',' + '['+ spd +']'  from q4 for xml path ('') ), 1,1,'') from q4)


select @cols=cols from  q5

set @query = N' select ' + @cols + N'  from  
	( 
		select  top 10000 spdd, well_name_field, rank() over(partition by spdd order by len(well_name_field), well_name_field) as rnk from (
		select well_name_field,
		CASE 
			WHEN rtrim(spd) like ''SPD19A'' and well_name_field like ''B%'' THEN ''SPD19B'' 
			WHEN rtrim(spd) like ''SPD19C'' and well_name_field like ''2-%'' THEN ''SPD19D''
			ELSE spd
		END as spdd
		from dbo.well_name) as tt order by well_name_field
		
		
		) 
		as  x
		
		pivot 
		(
		  max(well_name_field) 
		  for spdd in (' + @cols + N' )) as p '


execute sp_executesql @query
END
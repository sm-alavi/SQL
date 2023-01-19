
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_WS_MonitoringPivotTable]
	-- Persian Date [From]
	@date1 as nvarchar(10), 
	-- Persian Date [To]
	@date2 as nvarchar(10),

	@platform as nvarchar(10) 
AS
BEGIN
	declare @query as nvarchar(MAX);
	declare @cols as nvarchar(max); 
	SET NOCOUNT ON;

    with 

q3 as (select * from dbo.FN_Monitoring_RowedData_Well(@date1, @date2, @platform) )

, q4 as (select q3.* from q3 inner join (select max(date1) as date1 from q3) as t2 on q3.Date1 = t2.date1)

,q5 as (select top 1 cols = Stuff((select ',' + '['+ col +']'  from q4 for xml path ('')), 1,1,'') from q4 )
 
select @cols=cols from  q5

set @query = N' select * from  
	( 
		select colvalue, col, date1 as [Date Persian], datem as [Date English]
		from dbo.FN_Monitoring_RowedData_Well( ''' + @date1 + ''',''' + @date2 + ''', ''' + @platform + ''' ) ) 
		as  x
		
		pivot 
		(
		  max(colvalue) 
		  for col in (' + @cols + N' )) as p '

execute sp_executesql @query

END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FN_OptimumRoute_Locations]
(
	-- Add the parameters for the function here
	--SPD1;SPD9;SPD10
	@inputstring as nvarchar(4000),
	@start as nvarchar(50), 
	@end as nvarchar(50)
)
RETURNS 
@table1 Table(
method nvarchar(50),
route1 nvarchar(4000),
distance real,
depth int
)

AS
BEGIN
declare @locations as nvarchar(4000) = CASE WHEN substring(@inputstring,len(@inputstring), 1) = ';' THEN @inputstring ELSE  @inputstring + ';' END
declare @depth as int = len(@locations) - len(replace(@locations, ';', ''));
set @depth = CASE WHEN @start = @end THEN @depth ELSE  @depth -1 END;

	with 
q0 as (select cast(rtrim(location) as nvarchar(4000)) as location, easting, northing from tblLocationRoute where @locations like '%'+location+';%')
,q00 as (select t1.location as location1, t2.location as location2, round(sqrt(Power(t2.northing-t1.northing,2) + power(t2.easting-t1.easting,2)) / 1000,2) as d from q0 as t1
		 cross apply (select * from q0 where q0.location <> t1.location) as t2)
,q1 as (

		select t1.location2, t1.location1 + '>' + t1.location2 as route1 , d, 1 as depth from q00 as t1
		where location1 = @start
		union all 
		select t2.location2, 
				q1.route1 +'>' + t2.location2 as route1, q1.d + t2.d, depth + 1 as depth
		from q1 inner join q00 as t2 on q1.location2 = t2.location1 
		where q1.route1 not like CASE WHEN t2.location2 = @start and depth+1 = @depth THEN ' ' ELSE '%'+t2.location2+'%' END 
		 )

, q2 as (select top 1 'Optimum' as method,  q1.* from q1 where depth = @depth and route1 like '%>' + @end order by d
		    union all 
		select top 10 'Input',  q1.* from q1 where route1 = replace(@locations, ';', '>') +@start)
	
	insert @table1 
	select method, route1, d, depth from q2

	RETURN 
END
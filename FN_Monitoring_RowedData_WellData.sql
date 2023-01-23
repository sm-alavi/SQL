SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[FN_Monitoring_RowedData_Well]
(	
	@date1 as nvarchar(10),
    @date2 as nvarchar(10),
    @platform as nvarchar(10) 
)
RETURNS TABLE 
AS
RETURN 
(

with 

q1 as (select top 10000000000000 *,  CASE WHEN datediff(SECOND, 0, CONVERT(time, CASE WHEN shutin ='24:00' then '23:59' else shutin end))/3600.0 >= 23.983 then 24.0 ELSE datediff(SECOND, 0, CONVERT(time, CASE WHEN shutin ='24:00' then '23:59' else shutin end))/3600.0 END  as shutinhr, dbo.PersianToMiladi(date1) as datem, rank() over(partition by spd order by well_index) as rnk from ..tblq where spd=@platform and date1 between @date1 and @date2 order by date1)

,q2 as (select top 100000000000000 q1.Date1 , q1.datem , q1.spd, q1.Well_no, q1.well_index, ca.colname,  ca.colvalue, ca.colidx from q1 cross apply (

values ('WHFP(barg)', Well_h_pres, 1), ('Shutin(hr)',shutinhr,2 ) ,('Q(MMSCFD)', Q_Well, 3), ('Choke Opening(%)', Choke_Opening, 4) , ('Annulus 7 -  10 3/4 (barg)', Annulus7, 5)
		 , ('Annulus 10 3/4 - 13 3/8 (barg)', Annulus10, 6) , ('Annulus 13 3/8 - 18 5/8 (barg)', Annulus13, 7),('WHT (C)', WHT, 8)  ) as ca (colname, colvalue, colidx) order by date1)



, q22 as (select q1.Date1,q1.datem, q1.spd, q1.Well_no, q1.well_index, ca.colname, ca.colvalue, ca.colidx  from q1 cross apply (

values ('Platform Average WHFP (barg)', Paverage, 11) ,('F.W.k 1  Gas Flow MMSCFD', fwko1, 12), ('F.W.k 1  Condensate Flow bbl/D', cl1, 13) , ('F.W.k 2  Gas Flow MMSCFD', fwko2, 14) , ('F.W.k 2  Condensate Flow bbl/D', cl2, 15) , ('Dry Gas MMSCFD', Dry_Gas, 16),('Condensate bbl/D', Condensate, 17), ('Rich Gas MMSCFD', rich_gas, 18),
		('CGR bbl/MMSCF', CGR, 19), ('Platform  Shut in hr', Platform_Shutin_hr, 20)  ,('Platform Water Production bbl/D', Water_Production, 21),('DQ', dq, 22), ('No. of Active well', Active_well_NO, 23)  ) as ca (colname, colvalue, colidx) where rnk = 1)


,q3 as (select top 10000000000000000 q2.*, t2.well_name_field as wellno_fld, 'well'+ well_name_field + '_'+colname as col from q2 left join well_name as t2 on q2.spd collate Arabic_100_CI_AI = t2.spd and q2.Well_no collate Arabic_100_CI_AI = t2.well_name order by date1, len(well_name_field), well_name_field )

,q4 as (select  q22.*, NULL as wellno_fld,  'platform'+ '_'+colname as col from q22   )

, q5 as (select * from q3 union all (select * from q4))

, q6 as (select q3.* from q3 inner join (select max(date1) as date1 from q3) as t2 on q3.Date1 = t2.date1)

,q7 as (select top 1 cols = Stuff((select ',' + col from q4 for xml path ('')), 1,1,'') from q4 )

select top 100000000000000 * from q5 order by substring(spd, 4, 2) * 1, spd, len(isnull(wellno_fld, 'ZZZZZZZZZZZZ')) ,isnull(wellno_fld, 'ZZZZZZZZZZZ'), cast(colidx as int)
)
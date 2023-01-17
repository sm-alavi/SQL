

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FN_maintenance_equipment_report]
(	
	@date1 nvarchar(10)
)

RETURNS TABLE 
AS
RETURN 
(

with
spdname1 as (select rtrim(spd_name) collate Arabic_100_CI_AI as spd_name from dbo.spdname where spd_name='SPD1')
,spdname2 as (select rtrim(spd_name) collate Arabic_100_CI_AI as spd_name from dbo.spdname where spd_name<>'SPD1')
,Utility as (select spd collate Arabic_100_CI_AI as platform, * from dbo.Utility)
,P1_utility as (select spd collate Arabic_100_CI_AI as platform, * from dbo.P1_utility)
, p1_train as (select spd collate Arabic_100_CI_AI as platform, * from dbo.p1_train)
,qfinal as (

select spd_name as Platform, 'Diesel Engine A' as [Equipment Name] , t4.G_A_Statu As Status, t4.G_A_RHrs as [Total RH], t4.G_A_R_After as [RH After Overhaul], t2.[Overhaul Date] collate Arabic_100_CI_AI as [Overhaul Date], t3.G_A_RHrs as [Last Overhaul RH]  from spdname2 as t1 
cross apply (select max(GTG_OverhalDate_A) as [Overhaul Date] from Utility where platform = t1.spd_name  and GTG_OverhalDate_A<= @date1 ) as t2
left join Utility as t3 on t1.spd_name = t3.platform  and [Overhaul Date]  = t3.Date1 collate Arabic_100_CI_AI
left join Utility as t4 on t1.spd_name = t4.platform  and t4.Date1 = @date1

union all

select spd_name as platform, 'Diesel Engine B' as [Equipment Name] , t4.G_B_Statu, t4.G_B_RHrs, t4.G_B_R_After, t2.[Overhaul Date], t3.G_B_RHrs  from spdname2 as t1 
cross apply (select max(GTG_OverhalDate_B) as [Overhaul Date] from Utility where spd = t1.spd_name and GTG_OverhalDate_B<= @date1 ) as t2
left join Utility as t3 on t1.spd_name = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join Utility as t4 on t1.spd_name = t4.platform  and t4.Date1 = @date1 

union all

select spd_name as platform, 'Air Compressor A' as [Equipment Name] , t4.Com_A_Statu, t4.Com_A_RHrs, t4.Air_A_R_After, t2.[Overhaul Date], t3.Com_A_RHrs  from spdname2 as t1 
cross apply (select max(Air_OverhalDate_A) as [Overhaul Date] from Utility where spd = t1.spd_name and Air_OverhalDate_A<= @date1 ) as t2
left join Utility as t3 on t1.spd_name = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join Utility as t4 on t1.spd_name = t4.platform  and t4.Date1 = @date1 

union all 

select spd_name as platform, 'Air Compressor B' as [Equipment Name] , t4.Com_B_Statu, t4.Com_B_RHrs, t4.Air_B_R_After, t2.[Overhaul Date], t3.Com_B_RHrs  from spdname2 as t1 
cross apply (select max(Air_OverhalDate_B) as [Overhaul Date] from Utility where spd = t1.spd_name and Air_OverhalDate_B<= @date1 ) as t2
left join Utility as t3 on t1.spd_name = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join Utility as t4 on t1.spd_name = t4.platform  and t4.Date1 = @date1 


----------------------
---------------------------------- >>>>> SPD1
----------------------

-- Utility


Union All

select spd_name as platform, 'Main Power Generator A' as [Equipment Name] , t4.A_GTG_Status, t4.A_GTG_RH, t4.GTG_M_RAFTER_A, t2.[Overhaul Date], t3.A_GTG_RH  from spdname1 as t1 
cross apply (select max(GTG_M_Date_A) as [Overhaul Date] from P1_utility where spd = t1.spd_name collate Arabic_100_CI_AI  and GTG_M_Date_A <= @date1 ) as t2 
inner join P1_utility as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
inner join P1_utility as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1 


Union All

select spd_name as platform, 'Main Power Generator B' as [Equipment Name] , t4.B_GTG_Status, t4.B_GTG_RH, t4.GTG_M_RAFTER_B, t2.[Overhaul Date], t3.B_GTG_RH  from spdname1 as t1 
cross apply (select max(GTG_M_Date_B) as [Overhaul Date] from P1_utility where spd = t1.spd_name collate Arabic_100_CI_AI  and GTG_M_Date_B <= @date1 ) as t2 
inner join P1_utility as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
inner join P1_utility as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1 

Union All

select spd_name as platform, 'Main Power Generator C' as [Equipment Name] , t4.C_GTG_Status, t4.C_GTG_RH, t4.GTG_M_RAFTER_C, t2.[Overhaul Date], t3.C_GTG_RH  from spdname1 as t1 
cross apply (select max(GTG_M_Date_C) as [Overhaul Date] from P1_utility where spd = t1.spd_name collate Arabic_100_CI_AI and GTG_M_Date_C <= @date1 ) as t2 
inner join P1_utility as t3 on t1.spd_name = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
inner join P1_utility as t4 on t1.spd_name = t4.platform  and t4.Date1 = @date1 

Union All

select spd_name as platform, 'Air Compressor A' as [Equipment Name] , t4.A_Comp_M3, t4.A_Comp_RH, t4.Air_A_R_After, t2.[Overhaul Date], t3.A_Comp_RH  from spdname1 as t1 
cross apply (select max(AC_Date_A) as [Overhaul Date] from P1_utility where spd = t1.spd_name collate Arabic_100_CI_AI  and AC_Date_A <= @date1 ) as t2 
inner join P1_utility as t3 on t1.spd_name = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
inner join P1_utility as t4 on t1.spd_name = t4.platform  and t4.Date1 = @date1 

Union All

select spd_name as platform, 'Air Compressor B' as [Equipment Name] , t4.B_Comp_M3, t4.B_Comp_RH, t4.Air_B_R_After, t2.[Overhaul Date], t3.B_Comp_RH  from spdname1 as t1 
cross apply (select max(AC_Date_B) as [Overhaul Date] from P1_utility where spd = t1.spd_name collate Arabic_100_CI_AI  and AC_Date_B <= @date1 ) as t2 
inner join P1_utility as t3 on t1.spd_name = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
inner join P1_utility as t4 on t1.spd_name = t4.platform  and t4.Date1 = @date1 

Union All

select spd_name as platform, 'Air Compressor C' as [Equipment Name] , t4.C_Comp_M3, t4.C_Comp_RH, t4.Air_C_R_After, t2.[Overhaul Date], t3.C_Comp_RH  from spdname1 as t1 
cross apply (select max(AC_Date_C) as [Overhaul Date] from P1_utility where spd = t1.spd_name collate Arabic_100_CI_AI  and AC_Date_C <= @date1 ) as t2 
inner join P1_utility as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
inner join P1_utility as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1 

Union All

select spd_name as platform, 'Engine Core A' as [Equipment Name] , '-' collate Arabic_100_CI_AI, t4.A_GTG_RH, t4.Engin_RH_AF_A, t2.[Overhaul Date], t3.Engin_RH_A  from spdname1 as t1 
cross apply (select max(ECORE_Date_A) as [Overhaul Date] from P1_utility where spd = t1.spd_name collate Arabic_100_CI_AI  and ECORE_Date_A <= @date1 ) as t2 
left join P1_utility as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join P1_utility as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1 


Union All

select spd_name as platform, 'Engine Core B' as [Equipment Name] , '-' collate Arabic_100_CI_AI, t4.B_GTG_RH, t4.Engin_RH_AF_B, t2.[Overhaul Date], t3.Engin_RH_B  from spdname1 as t1 
cross apply (select max(ECORE_Date_B) as [Overhaul Date] from P1_utility where spd = t1.spd_name collate Arabic_100_CI_AI  and ECORE_Date_B <= @date1 ) as t2 
left join P1_utility as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join P1_utility as t4 on t1.spd_name = t4.platform  and t4.Date1 = @date1 


union all

select spd_name as platform, 'Engine Core C' as [Equipment Name] , '-' collate Arabic_100_CI_AI, t4.C_GTG_RH, t4.Engin_RH_AF_C, t2.[Overhaul Date], t3.Engin_RH_C  from spdname1 as t1 
cross apply (select max(ECORE_Date_C) as [Overhaul Date] from P1_utility where spd = t1.spd_name collate Arabic_100_CI_AI  and ECORE_Date_C <= @date1 ) as t2 
left join P1_utility as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join P1_utility as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1 


union all 

select spd_name as platform, 'Sea Water Pump A' as [Equipment Name] ,CASE WHEN t4.A_Pump_M3 = 0 then 'S' ELSE 'R' END , t4.A_Pump_RH, t4.SeaWatPU_RH_AF_A, t2.[Overhaul Date], t3.A_Pump_RH  from spdname1 as t1 
cross apply (select max(SEAPUMP_Date_A) as [Overhaul Date] from P1_utility where spd = t1.spd_name collate Arabic_100_CI_AI  and SEAPUMP_Date_A <= @date1 ) as t2 
left join P1_utility as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join P1_utility as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1 

union all

select spd_name as platform, 'Sea Water Pump B' as [Equipment Name] ,CASE WHEN t4.B_Pump_M3 = 0 then 'S' ELSE 'R' END , t4.B_Pump_RH, t4.SeaWatPU_RH_AF_B, t2.[Overhaul Date], t3.B_Pump_RH  from spdname1 as t1 
cross apply (select max(SEAPUMP_Date_B) as [Overhaul Date] from P1_utility where spd = t1.spd_name collate Arabic_100_CI_AI  and SEAPUMP_Date_B <= @date1 ) as t2 
left join P1_utility as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join P1_utility as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1 

union all 

select spd_name as platform, 'Sea Water Pump C' as [Equipment Name] ,CASE WHEN t4.C_Pump_M3 = 0 then 'S' ELSE 'R' END , t4.C_Pump_RH, t4.SeaWatPU_RH_AF_C, t2.[Overhaul Date], t3.C_Pump_RH  from spdname1 as t1 
cross apply (select max(SEAPUMP_Date_C) as [Overhaul Date] from P1_utility where spd = t1.spd_name collate Arabic_100_CI_AI  and SEAPUMP_Date_C <= @date1 ) as t2 
left join P1_utility as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join P1_utility as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1 

union all 

---- Train 

select spd_name as platform, 'Glycol Circulation Pump A - Train 1' as [Equipment Name] ,t4.A_cir_Pump , t4.A_cir_Pump_RH, t4.CIR_RH_AF_A, t2.[Overhaul Date], t3.A_cir_Pump_RH  from spdname1 as t1 
cross apply (select max(CIR_DATE_A) as [Overhaul Date] from p1_train where spd = t1.spd_name collate Arabic_100_CI_AI  and CIR_DATE_A <= @date1 ) as t2 
left join p1_train as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join p1_train as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1

union all

select spd_name as platform, 'Glycol Circulation Pump A - Train 2' as [Equipment Name] ,t4.A_cir_Pump1 , t4.A_cir_Pump_RH1, t4.CIR_RH_AF_A1, t2.[Overhaul Date], t3.A_cir_Pump_RH1  from spdname1 as t1 
cross apply (select max(CIR_DATE_A1) as [Overhaul Date] from p1_train where spd = t1.spd_name collate Arabic_100_CI_AI  and CIR_DATE_A1 <= @date1 ) as t2 
left join p1_train as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join p1_train as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1

union all 

select spd_name as platform, 'Glycol Circulation Pump B - Train 1' as [Equipment Name] ,t4.B_cir_Pump , t4.B_cir_Pump_RH, t4.CIR_RH_AF_B, t2.[Overhaul Date], t3.B_cir_Pump_RH  from spdname1 as t1 
cross apply (select max(CIR_DATE_B) as [Overhaul Date] from p1_train where spd = t1.spd_name collate Arabic_100_CI_AI  and CIR_DATE_B <= @date1 ) as t2 
left join p1_train as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join p1_train as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1

union all

select spd_name as platform, 'Glycol Circulation Pump B - Train 2' as [Equipment Name] ,t4.B_cir_Pump1 , t4.B_cir_Pump_RH1, t4.CIR_RH_AF_B1, t2.[Overhaul Date], t3.B_cir_Pump_RH1  from spdname1 as t1 
cross apply (select max(CIR_DATE_B1) as [Overhaul Date] from p1_train where spd = t1.spd_name collate Arabic_100_CI_AI  and CIR_DATE_B1 <= @date1 ) as t2 
left join p1_train as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join p1_train as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1

union all

select spd_name as platform, 'Glycol Booster Pump A - Train 1' as [Equipment Name] ,t4.A_Boost_Pump , t4.A_Boost_Pump_RH, t4.BOOST_RH_AF_A, t2.[Overhaul Date], t3.A_Boost_Pump_RH  from spdname1 as t1 
cross apply (select max(BOOST_DATE_A) as [Overhaul Date] from p1_train where spd = t1.spd_name collate Arabic_100_CI_AI  and BOOST_DATE_A <= @date1 ) as t2 
left join p1_train as t3 on t1.spd_name = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join p1_train as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1

union all 

select spd_name as platform, 'Glycol Booster Pump A - Train 2' as [Equipment Name] ,t4.A_Boost_Pump1 , t4.A_Boost_Pump_RH1, t4.BOOST_RH_AF_A1, t2.[Overhaul Date], t3.A_Boost_Pump_RH1  from spdname1 as t1 
cross apply (select max(BOOST_DATE_A1) as [Overhaul Date] from p1_train where spd = t1.spd_name collate Arabic_100_CI_AI  and BOOST_DATE_A1 <= @date1 ) as t2 
left join p1_train as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join p1_train as t4 on t1.spd_name = t4.platform  and t4.Date1 = @date1

union all 

select spd_name as platform, 'Glycol Booster Pump B - Train 1' as [Equipment Name] ,t4.B_Boost_Pump , t4.B_Boost_Pump_RH, t4.BOOST_RH_AF_B, t2.[Overhaul Date], t3.B_Boost_Pump_RH  from spdname1 as t1 
cross apply (select max(BOOST_DATE_B) as [Overhaul Date] from p1_train where spd = t1.spd_name collate Arabic_100_CI_AI  and BOOST_DATE_B <= @date1 ) as t2 
left join p1_train as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join p1_train as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1

union all 

select spd_name as platform, 'Glycol Booster Pump B - Train 2' as [Equipment Name] ,t4.B_Boost_Pump1 , t4.B_Boost_Pump_RH1, t4.BOOST_RH_AF_B1, t2.[Overhaul Date], t3.B_Boost_Pump_RH1  from spdname1 as t1 
cross apply (select max(BOOST_DATE_B1) as [Overhaul Date] from p1_train where spd = t1.spd_name collate Arabic_100_CI_AI  and BOOST_DATE_B1 <= @date1 ) as t2 
left join p1_train as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join p1_train as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1

union all 

select spd_name as platform, 'Glycol Circulation Pump Gearbox A - Train 1' as [Equipment Name] ,t4.GEAR_STATUS_A , t4.GEAR_RH_A, t4.GEAR_RH_AF_A, t2.[Overhaul Date], t3.GEAR_RH_A  from spdname1 as t1 
cross apply (select max(GEAR_DATE_A) as [Overhaul Date] from p1_train where spd = t1.spd_name collate Arabic_100_CI_AI  and GEAR_DATE_A <= @date1 ) as t2 
left join p1_train as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join p1_train as t4 on t1.spd_name = t4.platform  and t4.Date1 = @date1

union all 

select spd_name as platform, 'Glycol Circulation Pump Gearbox A - Train 2' as [Equipment Name] ,t4.GEAR_STATUS_A1 , t4.GEAR_RH_A1, t4.GEAR_RH_AF_A1, t2.[Overhaul Date], t3.GEAR_RH_A1  from spdname1 as t1 
cross apply (select max(GEAR_DATE_A1) as [Overhaul Date] from p1_train where spd = t1.spd_name collate Arabic_100_CI_AI  and GEAR_DATE_A1 <= @date1 ) as t2 
left join p1_train as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join p1_train as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1

union all

select spd_name as platform, 'Glycol Circulation Pump Gearbox B - Train 1' as [Equipment Name] ,t4.GEAR_STATUS_B , t4.GEAR_RH_B, t4.GEAR_RH_AF_B, t2.[Overhaul Date], t3.GEAR_RH_B  from spdname1 as t1 
cross apply (select max(GEAR_DATE_B) as [Overhaul Date] from p1_train where spd = t1.spd_name collate Arabic_100_CI_AI  and GEAR_DATE_B <= @date1 ) as t2 
left join p1_train as t3 on t1.spd_name = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join p1_train as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1

union all 

select spd_name as platform, 'Glycol Circulation Pump Gearbox B - Train 2' as [Equipment Name] ,t4.GEAR_STATUS_B1 , t4.GEAR_RH_B1, t4.GEAR_RH_AF_B1, t2.[Overhaul Date], t3.GEAR_RH_B1  from spdname1 as t1 
cross apply (select max(GEAR_DATE_B1) as [Overhaul Date] from p1_train where spd = t1.spd_name collate Arabic_100_CI_AI  and GEAR_DATE_B1 <= @date1 ) as t2 
left join p1_train as t3 on t1.spd_name  = t3.platform  and t2.[Overhaul Date] collate Arabic_100_CI_AI = t3.Date1
left join p1_train as t4 on t1.spd_name  = t4.platform  and t4.Date1 = @date1
)


select top 1000000000 t1.*, t2.counter as Counter, t2.tag as Tag, t3.zone as Zone from qfinal  as t1
left join tblcounter as t2 on t1.Platform = t2.spd and t1.[Equipment Name] = t2.eqp
left join spdname as t3 on t1.Platform = t3.spd_name collate Arabic_100_CI_AI

order by substring(platform, 4, 2)* 1 , platform, [Equipment Name]


)

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FN_WellTest_Interpretation_Table]
(	
	@well_id as bigint
)
RETURNS TABLE 
AS
RETURN 
(
	with 
q1 as (select step_no_p as step_id, Round(AVG(t1.choke), 2) as choke,  Round(Avg(choke_feed), 2) as choke_feed, Round( AVG(t1.whfp),2) as whfp, Round( AVG(t1.whft),2) as whft
,Round( AVG(t1.choke_down_p),2) as choke_down_p,  Round(AVG(choke_down_t),2) as choke_down_t, Round(AVG(test_sep_p), 2) as test_sep_p, 
 Round(AVG(test_sep_t), 2) as test_sep_t,  Round(AVG(G_flow_A), 2) as g_flow_a,  Round(AVG(G_flow_B), 2) as g_flow_b, 

Round((Max(G_cum) - Min(G_cum)) * 24 / (datediff(hour, min(cast(date1_m as datetime) + cast(time1 as datetime)) ,  max(cast(date1_m as datetime) + cast(time1 as datetime)))),2 ) as g_cum,

Round(AVG(C_flow_A), 2) as c_flow_a, Round(AVG(C_flow_B), 2) as c_flow_b, 

Round( (Max(C_cum) - Min(C_cum)) * 24 / (datediff(hour, min(cast(date1_m as datetime) + cast(time1 as datetime)) ,  max(cast(date1_m as datetime) + cast(time1 as datetime)))), 2) as c_cum, 

Round( AVG(W_flow_A), 2) as w_flow_a, Round(AVg(W_flow_B), 2) as w_flow_b,
Round( (Max(W_cum) - Min(W_cum)) * 24 / (datediff(hour, min(cast(date1_m as datetime) + cast(time1 as datetime)) ,  max(cast(date1_m as datetime) + cast(time1 as datetime)))), 2) as w_cum,
 Count(t1.is_valid) as is_valid,
 max(wdrainnum) as wdrainnum, max(wdrainlevel) as wdrainlevel, AVG(whl_def) as whl_def, AVG(wll_def) as wll_def
from tbltestlog as t1 

where exists(select * from tblteststep as t2 where t2.ID_Step = t1.step_no_p and t2.ID_Well = @well_id) and t1.is_valid = 1

group by t1.step_no_p

)

,q2 as (select
t4.spd, t4.sal, t4.nimsal, t4.test_name, t4.test_status,t4.ID1 as test_id,
t3.well_index , t3.well_no_dcs as wellno_dcs, t3.well_no_field as wellno_fld,t3.whsip, t3.whsip_date, t3.whsip_date_M as whsip_date_m, t3.status as well_status, t3.manual_cond, t3.manual_cond_val,
t2.G_calc_type as g_calc_type, t2.C_calc_type as c_calc_type, t2.W_calc_type as w_calc_type,t2.step_no,isnull(t2.is_valid, CAST(1 as bit)) as valid,
 q1.* 
 from q1 
inner join tblteststep as t2 on q1.step_id = t2.ID_Step
inner join tbltestwells as t3 on t2.ID_Well = t3.ID1
inner join tbltestdesign as t4 on t3.ID_P = t4.ID1
)


, q3 as (select spd, 
				G_flow_A as g_flow_a_unit, G_flow_B as g_flow_b_unit, G_cum as g_cum_unit, 
				C_flow_A as c_flow_a_unit, C_flow_B as c_flow_b_unit, C_cum as c_cum_unit, 
				W_flow_A as w_flow_a_unit, W_flow_B as w_flow_b_unit, W_cum as w_cum_unit
		from tbltestunit)

, q4 as (select * from tbltestunitconversion)


, q5 as (select q3.spd
				,t1.multiplier as [c_flow_a_multiplier], t2.multiplier as [c_flow_b_multiplier], t3.multiplier as [c_cum_multiplier]
				,t4.multiplier as [g_flow_a_multiplier], t5.multiplier as [g_flow_b_multiplier], t6.multiplier as [g_cum_multiplier]
				,t7.multiplier as [w_flow_a_multiplier], t8.multiplier as [w_flow_b_multiplier], t9.multiplier as [w_cum_multiplier]
				 from q3 

		left join q4 as t1 on q3.c_flow_a_unit = t1.unit_from and t1.type1 = 'condensate'
		left join q4 as t2 on q3.c_flow_b_unit = t2.unit_from and t2.type1 = 'condensate'
		left join q4 as t3 on q3.c_cum_unit = t3.unit_from and t3.type1 = 'condensate'
		
		left join q4 as t4 on q3.g_flow_a_unit = t4.unit_from and t4.type1 = 'gas'
		left join q4 as t5 on q3.g_flow_b_unit = t5.unit_from and t5.type1 = 'gas'
		left join q4 as t6 on q3.g_cum_unit = t6.unit_from and t6.type1 = 'gas'

		left join q4 as t7 on q3.w_flow_a_unit = t7.unit_from and t7.type1 = 'water'
		left join q4 as t8 on q3.w_flow_b_unit = t8.unit_from and t8.type1 = 'water'
		left join q4 as t9 on q3.w_cum_unit = t9.unit_from and t9.type1 = 'water'
		)

, q6 as (select q2.* 
				,q5.g_flow_a_multiplier, q5.g_flow_b_multiplier, q5.g_cum_multiplier
				,q5.c_flow_a_multiplier, q5.c_flow_b_multiplier, q5.c_cum_multiplier
				,q5.w_flow_a_multiplier, q5.w_flow_b_multiplier, q5.w_cum_multiplier
				 from q2 left join q5 on q2.spd = q5.spd)

, q7 as (select spd, sal, nimsal, test_name, test_status, test_id, well_index, wellno_dcs, wellno_fld,
				whsip, whsip_date, whsip_date_m, well_status, manual_cond, manual_cond_val,
				g_calc_type, c_calc_type, w_calc_type,
				step_no,valid, step_id,choke, choke_feed, whfp, whft, choke_down_p, choke_down_t, test_sep_p, test_sep_t,
				ROUND(g_flow_a * g_flow_a_multiplier, 2) as [g_flow_a], ROUND(g_flow_b * g_flow_b_multiplier,2) as [g_flow_b], ROUND(g_cum * g_cum_multiplier, 2) as [g_cum],
				ROUNd(c_flow_a * c_flow_a_multiplier,2) as [c_flow_a], Round(c_flow_b * c_flow_b_multiplier,2) as [c_flow_b], Round(c_cum * c_cum_multiplier,2) as [c_cum], 
				ROUNd(w_flow_a * w_flow_a_multiplier,2) as [w_flow_a], ROUNd(w_flow_b * w_flow_b_multiplier,2) as [w_flow_b], ROUND(w_cum * w_cum_multiplier,2) as [w_cum], 
				is_valid, wdrainnum, wdrainlevel, whl_def, wll_def
				from q6)

select * from q7

)
/* bottom condition MAWOP calculation 
 */

USE [WIMS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[mawopbc_calc]
(	
	@date1 nvarchar(10), --Persian Date
	@gas_gradient real,
	@safety_factor real
)
RETURNS TABLE 
AS
RETURN 
(
	WITH
q0 AS (SELECT spd collate Arabic_100_CI_AI AS platform, well_name collate Arabic_100_CI_AI AS wellno_dcs FROM WIMS.dbo.well_name)
,q1 AS (SELECT * FROM PARWIMS.dbo.tblWIMSWBD WHERE wdtype = 'TUBING')
,q2 AS (SELECT Platform,wellno_dcs, collapse AS collapse, bottom_depth_tvd FROM q1 
		LEFT JOIN (SELECT IDI, weight, grade, collapse FROM PARWIMS.dbo.tblWIMStubespec) AS t2
		ON q1.IDI = t2.IDI AND q1.weight = t2.weight AND q1.grade = t2.grade)
,q3 AS (SELECT platform, wellno_dcs,annulusA_sg FROM PARWIMS.dbo.tblWIMSannfluid WHERE annulusA_fluid = 'Completion fluid')
,q4 AS (SELECT spd AS platform, Well_no AS wellno_dcs, whfp FROM WIMS.dbo.whfp_nonzero(@date1))
,q5 AS (SELECT t1.platform, t1.wellno_dcs, t2.bottom_depth_tvd, t2.collapse, t3.annulusA_sg AS annulusA_sg, t4.whfp FROM q0 AS t1
		LEFT JOIN q2 AS t2 ON t1.platform = t2.Platform AND t1.wellno_dcs = t2.wellno_dcs
		LEFT JOIN q3 AS t3 ON t1.platform = t3.platform AND t1.wellno_dcs = t3.wellno_dcs
		LEFT JOIN q4 AS t4 ON t1.platform = t4.platform AND t1.wellno_dcs = t4.wellno_dcs)
-- min(qwhpnon0.whfp + collapse * (1-isnull(cast(@safety_factor as real), 15)/100) * 0.0689 + (bottom_depth_tvd * (isnull(cast(@gas_gradient as real), 0.12)-q62.annulusA_sg*0.433) * 3.2808*0.0689)) as mawopbc 

,q6 AS (SELECT *, whfp + collapse * (1-isnull(CAST(@safety_factor AS REAL), 15)/100) * 0.0689 + (bottom_depth_tvd * (isnull(CAST(@gas_gradient AS REAL), 0.12)-annulusA_sg*0.433) * 3.2808*0.0689) AS mawopbc  
FROM q5)
,q7 AS (SELECT platform, wellno_dcs, min(mawopbc) AS mawopbc FROM q6 GROUP BY platform, wellno_dcs)

SELECT TOP 100000 * FROM q7 ORDER BY substring(platform,4,2) * 1 , platform
)

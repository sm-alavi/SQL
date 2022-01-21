
WITH

q0 AS (SELECT DISTINCT pid AS id FROM pars.dbo.tblsakhtarunit)

,q(id,idpedar) AS (
			SELECT id, id AS idpedar FROM q0
			UNION  ALL
			SELECT  tbl1.id AS id, idpedar
		 FROM pars.dbo.tblsakhtarunit AS tbl1 
		 INNER JOIN q  ON  q.id =  tbl1.pid AND q.id <> tbl1.id)

,q1 AS (SELECT * FROM q)
, q2 AS (SELECT q1.id,q1.idpedar, tbl1.des, tbl2.des AS pedar_des FROM q1 LEFT JOIN pars.dbo.tblsakhtarunit as tbl1 on tbl1.id = q1.id
		LEFT JOIN pars.dbo.tblsakhtarunit AS tbl2 ON tbl2.id = q1.idpedar)

SELECT * FROM q2 ORDER BY idpedar


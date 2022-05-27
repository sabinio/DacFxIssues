CREATE VIEW [dbo].[ViewNeedingFunction]
	AS SELECT v.a
	FROM (VALUES (dbo.ScalarFunction() )) v(a)
	
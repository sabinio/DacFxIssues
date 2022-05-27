CREATE VIEW [dbo].[ViewNeedingFunction]
	AS SELECT E.Id
	FROM dbo.EmptyTable E
	CROSS APPLY (VALUES (dbo.ScalarFunction() )) v(a)

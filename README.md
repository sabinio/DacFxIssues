# DacFxIssues

Functions not being deployed before the view that depends on them.

##Repro
* Create objects

``` sql
CREATE VIEW [dbo].[ViewNeedingFunction]
	AS SELECT v.a
	FROM (VALUES (dbo.ScalarFunction() )) v(a)
GO
CREATE FUNCTION [dbo].[ScalarFunction]()
RETURNS INT
AS
BEGIN
	RETURN 100
END

```
* Build project [FunctionViewOrderWithCrossApply.sqlproj](./FunctionViewOrderWithCrossApply/FunctionViewOrderWithCrossApply.sqlproj)
* Access the dacpac (rename as zip)
* Open the model.xml
| Note there is no reference to the scalar function in the `QueryDependencies` `Relationship` section

## Expected result
``` xml
    <Element Type="SqlView" Name="[dbo].[ViewNeedingFunction]">
			<Property Name="QueryScript">
				<Value><![CDATA[ SELECT v.a
	FROM (SELECT (dbo.ScalarFunction() )) v(a)]]></Value>
			</Property>
			<Property Name="IsAnsiNullsOn" Value="True" />
			<Relationship Name="Columns">
				<Entry>
					<Element Type="SqlComputedColumn" Name="[dbo].[ViewNeedingFunction].[a]" />
				</Entry>
			</Relationship>
			<Relationship Name="QueryDependencies">
				<Entry>
					<References Name="[dbo].[ScalarFunction]" />
				</Entry>
			</Relationship>
			<Relationship Name="Schema">
				<Entry>
					<References ExternalSource="BuiltIns" Name="[dbo]" />
				</Entry>
			</Relationship>
			<Annotation Type="SysCommentsObjectAnnotation">
				<Property Name="Length" Value="100" />
				<Property Name="StartLine" Value="1" />
				<Property Name="StartColumn" Value="1" />
				<Property Name="HeaderContents" Value="CREATE VIEW [dbo].[ViewNeedingFunction]&#xD;&#xA;&#x9;AS" />
			</Annotation>
		</Element>
```
##Actual result

``` xml
		<Element Type="SqlView" Name="[dbo].[ViewNeedingFunction]">
			<Property Name="QueryScript">
				<Value><![CDATA[ SELECT v.a
	FROM (VALUES (dbo.ScalarFunction() )) v(a)]]></Value>
			</Property>
			<Property Name="IsAnsiNullsOn" Value="True" />
			<Relationship Name="Columns">
				<Entry>
					<Element Type="SqlComputedColumn" Name="[dbo].[ViewNeedingFunction].[a]" />
				</Entry>
			</Relationship>
			<Relationship Name="Schema">
				<Entry>
					<References ExternalSource="BuiltIns" Name="[dbo]" />
				</Entry>
			</Relationship>
			<Annotation Type="SysCommentsObjectAnnotation">
				<Property Name="Length" Value="100" />
				<Property Name="StartLine" Value="1" />
				<Property Name="StartColumn" Value="1" />
				<Property Name="HeaderContents" Value="CREATE VIEW [dbo].[ViewNeedingFunction]&#xD;&#xA;&#x9;AS" />
			</Annotation>
		</Element>
```

# Workaround

1. Use SELECT rather than VALUES i.e.

``` sql
CREATE VIEW [dbo].[ViewNeedingFunction]
	AS SELECT E.Id
	FROM dbo.EmptyTable E
	CROSS APPLY (SELECT (dbo.ScalarFunction() )) v(a)
```

2. Refernce function in a non executing expression (a CASE expression that is can't be reached)

``` sql
CREATE VIEW [dbo].[ViewNeedingFunction]
	AS SELECT E.Id
	FROM dbo.EmptyTable E
	CROSS APPLY (VALUES (dbo.ScalarFunction() )) v(a)
  WHERE CASE WHEN 1=1 THEN 1 ELSE dbo.ScalarFunction() END =1
```

#Data Dictionary API for Code Generators
##Description
Lorum ipsum

##Install
- Download and Install these generators
- Generate code for the DD Core
- install resulting code
- Generate code for the DD API
- install resulting code

##Generator for DD Core
Generates CREATE SCHEMA, CREATE utility packages, and CREATE OR REPLACE initial Views.

##Generator for DD
Generates the actual DD API Package based on the views found in the selected Schema.

##Package DD_UTIL
This package contains function and cursors useful for building templates.  Specifically, the addText function for tePLSQL.
It also contains functions needed for the DDFS package.

##Package DDFS
This is a "Fail Safe" version of the DD.  It is used to create the actual DD Package.

##Package DD
This package contains a set of interfaces for all views that match the Generator's parameters.
The format of the View's names that are used to generate all of the interfaces are of the form `{schema}.{prefix}BASENAME{suffix}` where `{schema}`, `{prefix}`, and `{suffix}` are parameters from the generator.

###Interfaces
For each View found, a series of interfaces are created.
The Interfaces that are generated are
- cursor getBASENAME
- function existsBASENAME

###Parameters of Interfaces
General Parameter format for cursor and function are identical.

| Parameter Name | Default Value | Description |
| --------------:| ------------- | ----------- |
| `p_object_owner in varchar2` | Required | Exists as a required parameter if the view has the column OBJECT_OWNER |
| `p_object_name in varchar2` | Required | Exists as a required parameter if then view has the column OBJECT_NAME |
| `p_sXQuer in varchar2` | `NULL` | Always exists as an optional parameter.  NULL === all rows |
| `p_database in varchar2` | `'localhost'` | Exists as an optional parameter if the view has the column DATABASE |
|`p_edition in varchar2` | `'ORD$BASE'` | Exists as an optional parameter if the view has the column EDITION |

##sXQuery Syntax
This is a simplified XQuery syntax.  It is used to dynamically implement a WHERE clause based on a string.

XPath matches to column name of the source view. Names are Case Sensitive.
For the cursor getColumns, the XPath '/COLUMN_NAME' matches to the column ODDGEN$SYS.ODDGEN_COULMNS.COLUMN_NAME;
Since this is an XML based query, if the column in the source View is XMLType, the data in the XML document can also be used as a condition for the WHERE clause.
- place example here

example usages go here

##Customizing the DD API
###Enhancing the DD Package
To customize the DD API for your site
- CREATE OR REPLACE the view in the choosen schema
- Regenerate the code for the DD API
- install resutling code

###Example Enhancements Ideas
Possible enhancments ideas
- Modify the view to LEFT OUTER JOIN tables that represent contraints that have not been created.
- Modify the view to UNION ALL results from remote DBs.  Identifiy each remote DB in the DATABASE column.
- Modify the view to UNION ALL values in a GTT.  The GTT would contain information from a modeling program such as SQL*Developer Data Modeler.



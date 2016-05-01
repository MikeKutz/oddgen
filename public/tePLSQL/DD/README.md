Data Dictionary API for Code Generators
Lorum ipsum

Install
- Download and Install these generators
- Generate code for the DD Core
- install resulting code
- Generate code for the DD API
- install resulting code

Generator for DD Core
Generates CREATE SCHEMA, CREATE utility packages, and CREATE OR REPLACE initial Views.

Generator for DD
Generates the actual DD API Package based on the views found in the selected Schema.

Package DD_UTIL
This package contains function and cursors useful for building templates.  Specifically, the addText function for tePLSQL.
It also contains functions needed for the DDFS package.

Package DDFS
This is a "Fail Safe" version of the DD.  It is used to create the actual DD Package.

Package DD
This package contains a set of interfaces for all views that match the Generator's parameters.
The format is:
schema.prefixBASENAMEsuffix

Interfaces generated are
- cursor getBASENAME
- function existsBASENAME

Parameters
General Parameter format for cursor and function are identical
- p_object_owner in varchar2 - exists as a required parameter if view has column OBJECT_OWNER
- p_object_name in varchar2 - exists as a required parameter if view has column OBJECT_NAME
- p_sXQuer in varchar2 default NULL - always exists as an optional parameter.  NULL === all rows
- p_database in varchar2 default 'localhost' - exists as an optional parameter if view has column DATABASE
- p_edition in varchar2 default 'ORA$BASE' - exists as an optional parameter if view has column EDITION

sXQuery Syntax
This is a simplified XQuery syntax.  It is used to dynamically implement a WHERE clause based on a string.

XPath matches to column name of the source view. Names are Case Sensitive.
For the cursor getColumns, the XPath '/COLUMN_NAME' matches to the column ODDGEN$SYS.ODDGEN_COULMNS.COLUMN_NAME;
Since this is an XML based query, if the column in the source View is XMLType, the data in the XML document can also be used as a condition for the WHERE clause.
- place example here

example usages go here

On Site Enhancements of the DD API
To customize the DD API for your site
- CREATE OR REPLACE the view in the choosen schema
- Regenerate the code for the DD API
- install resutling code

Example Enhancements
- Modify the view to LEFT OUTER JOIN tables that represent contraints that have not been created.
- Modify the view to UNION ALL results from remote DBs.  Identifiy each remote DB in the DATABASE column.
- Modify the view to UNION ALL values in a GTT.  The GTT would contain information from a modeling program such as SQL*Developer Data Modeler.



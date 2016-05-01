create or replace package body TEPLSQL_DD_GENERATOR
as

   FUNCTION get_name RETURN VARCHAR2
   as
   begin
     return G_GEN_NAME;
   end;

   FUNCTION get_description RETURN VARCHAR2
   as
   begin
     return G_GEN_DESC;
   end;

   FUNCTION get_object_types RETURN t_string
   as
   begin
     return G_ALL_TYPES;
   end;

   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN t_string
   as
   begin
     if in_object_type = G_TYPE_1 then
      return t_string( '{new schema}');
     elsif in_object_type = G_TYPE_2 then
      return t_string( 'ODDGEN$SYS' );
     elsif in_object_type = G_TYPE_3 then
      return t_string( 'gen code' );
     else
      return t_string( 'bad input' );
     end if;
   end;


 procedure copyVars( p_src in teplsql.t_assoc_array, p_dst in out nocopy teplsql.t_assoc_array )
 as
   l_key varchar2(1000);
 begin
   l_key := p_src.first;
   
   while l_key is not null
   loop
     p_dst( l_key ) := p_src( l_key );
     l_key := p_src.next( l_key );
   end loop;
 end;

 procedure setVarDefaults( p_vars in out nocopy teplsql.t_assoc_array)
 as
 begin
   p_vars('default_ts') := 'USERS';
   p_vars('temp_ts')    := 'TEMP';
   p_vars('schema')     := 'ODDGEN$SYS';
   p_vars('do_ts') := '1';
   p_vars('do_schema') := '1';
   p_vars('do_packages') := '1';
   p_vars('do_views') := '1';
   p_vars('do_grants') := '1';
   p_vars('oddgen_prefix') := 'ODDGEN_';
   P_VARS('oddgen_suffix') := '';

 end;

   /**
   * Generates the result.
   * This function cannot be omitted. 
   *
   * @param in_object_type object type to process
   * @param in_object_name object_name of in_object_type to process
   * @param in_params parameters to configure the behavior of the generator
   * @returns generator output
   * @throws ORA-20501 when parameter validation fails
   */
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2,
                     in_params      IN t_param) RETURN CLOB
   as
      l_vars teplsql.t_assoc_array;
      l_clob clob;
      l_TEMPLATE_NAME VARCHAR2(200);
      l_OBJECT_NAME VARCHAR2(200) := 'TEPLSQL_DD_GENERATOR';
      l_OBJECT_TYPE VARCHAR2(200) := 'PACKAGE';
      l_SCHEMA VARCHAR2(200);
   begin
     setVarDefaults( l_vars );

     if in_object_type = G_TYPE_1
     then
      l_template_name := '/dd/make#all';
     elsif in_object_type = G_TYPE_2
     then
      l_template_name := '/dd/dd/make#spec';
     elsif in_object_type = G_TYPE_3
     then
      l_template_name := '/devtools/templates#make';
     else
      return 'INVALID TYPE selected';
     end if;
     
     l_clob := TEPLSQL.process(P_VARS => l_VARS,
                  P_TEMPLATE_NAME => l_TEMPLATE_NAME,
                  P_OBJECT_NAME => l_OBJECT_NAME,
                  P_OBJECT_TYPE => l_OBJECT_TYPE,
                  P_SCHEMA => l_SCHEMA);

     return l_clob;
   end;


 
 function getVarDefaults return teplsql.t_assoc_array
 as
   l_vars teplsql.t_assoc_array := teplsql.null_assoc_array;
 begin
   setVarDefaults( l_vars );
   return l_vars;
 end;


$if false $then
<%@ template name=/dd/make#create_inserts %>
PROMPT Creating Inserts
REM code not yet implemented
$end

/******************************************************************************\
|******************  The following is created by  *****************************|
|***************   by the template /dd/devtools/main **************************|
|**********   Actual templates are stored in TE_TEMPLATES  ********************|
\******************************************************************************/

$if false $then
<%@ template name=/dd/dd_utl/functions/add_comma#pldoc %>
/*
<p><
Adds a comma to the generated code based on input value.
</p>
<p>
This function is useful for tePLSQL generator.
</p>
<p><h2>uses case</h2>
for curr in dd.getSOMETHING loop<br>
&nbsp;@nbsp;add_comma( curr.is_last_record )<br>
end loop;
</p>

@param p_yes  Determines which text to print out.  1= true
@param p_text_for_no Use this text if the value is not 1.  Default is a comma.
@param p_text_for_yes Use this text if the values is 1.  Default is NULL.
**/
$end

$if false $then
<%@ template name=/dd/dd_utl/functions/add_comma#spec %>
function add_comma( p_yes in int, p_text_for_no in varchar2 default ',', p_text_for_yes in varchar2 default null ) return varchar2
$end

$if false $then
<%@ template name=/dd/dd_utl/functions/add_comma#body %>
as
begin
  if p_yes = 1 then return p_text_for_yes; end if;
  return p_text_for_no;
end;
$end

$if false $then
<%@ template name=/dd/make#all %>
REM Start of MAKE
<%@ include( script_intro, TEPLSQL_DD_GENERATOR ) %>

<% if ${do_ts} = 1 then %>
<%@ include( /dd/make#create_ts, TEPLSQL_DD_GENERATOR ) %>
<% end if; %>

<% if ${do_schema} = 1 then %>
<%@ include( /dd/make#create_schema, TEPLSQL_DD_GENERATOR ) %>
<% end if; %>

<% if ${do_packages} = 1 then %>
REM BEGIN PACKAGES
<%@ include( /dd/dd_utl/dd_utl#specification, TEPLSQL_DD_GENERATOR ) %>
<%@ include( /dd/dd_utl/dd_utl#body, TEPLSQL_DD_GENERATOR ) %>

<%@ include( /dd/ddfs/ddfs#spec, TEPLSQL_DD_GENERATOR ) %>
<%@ include( /dd/ddfs/ddfs#body, TEPLSQL_DD_GENERATOR ) %>
REM END PACKAGES
<% end if; %>

<% if ${do_views} = 1 then %>
<%@ include(/dd/make#create_views, TEPLSQL_DD_GENERATOR ) %>
<% end if; %>

<% if ${do_grants} = 1 then %>
<%@ include( /dd/make#create_grants, TEPLSQL_DD_GENERATOR) %>
<% end if; %>


REM End of MAKE


$end

$if false $then
<%@ template name=/dd/make#create_ts %>
PROMPT Creating Tablespace
PROMPT template incomplete

$end

$if false $then
<%@ template name=/dd/make#create_schema %>
PROMPT Creating Schema ${schema}
create user ${schema} identified by <%= chr( ascii('A') - 1 + round(dbms_random.value(1,26)))%><%= dbms_random.string('X', 10 ) %>
  default tablespace ${default_ts}
  temporary tablespace ${temp_ts}
  quota 5M on ${default_ts}
  account lock;

grant create view, create procedure to ${schema};
create role oddgen_user_role;

$end

$if false $then
<%@ template name=/dd/make#script_intro %>
PROMPT script_intro

PROMPT copyright

PROMPT Parameters Used
Schema  : ${schema}

PROMPT stats
PROMPT Created using: tePLSQL
PROMPT Created on   : <%= to_date( sysdate, 'yyyy-mon-dd hh24:MI:SS' ) %>\\n
PROMPT Created by   : <%= USER  %>\\n


$end

$if false $then
<%@ template name=/dd/make#create_grants %>
PROMPT Creating Views
grant execute on ${schema}.dd_utl to oddgen_user_role, public;
grant execute on ${schema}.ddfs to oddgen_user_role, public;
<% if ${do_views} = 1 then %>
grant select on  ${schema}.<%@ include( /dd/views/Tables#name, TEPLSQL_DD_GENERATOR ) %> to oddgen_user_role, public;
grant select on  ${schema}.<%@ include( /dd/views/Views#name, TEPLSQL_DD_GENERATOR ) %> to oddgen_user_role, public;
grant select on  ${schema}.<%@ include( /dd/views/Columns#name, TEPLSQL_DD_GENERATOR ) %> to oddgen_user_role, public;
grant select on  ${schema}.<%@ include( /dd/views/Constraints#name, TEPLSQL_DD_GENERATOR ) %> to oddgen_user_role, public;
<% end if; %>

$end

$if false $then
<%@ template name=/dd/make#create_inserts %>
REM place code to "install" templates into te_TEMPLATES here.
$end

$if false $then
<%@ template name=/dd/views/Tables#name %>
${oddgen_prefix}Tables${oddgen_suffix}
$end

$if false $then
<%@ template name=/dd/views/Columns#name %>
${oddgen_prefix}Columns${oddgen_suffix}
$end

$if false $then
<%@ template name=/dd/views/Views#name %>
${oddgen_prefix}Views${oddgen_suffix}
$end

$if false $then
<%@ template name=/dd/views/Constraints#name %>
${oddgen_prefix}Constraints${oddgen_suffix}
$end

$if false $then
<%@ template name=/dd/views/Constraints#sql %>
select
  owner as object_owner, table_name as object_name
  ,rank() over (order by owner, table_name, constraint_type desc, constraint_name) as order_by
  ,X.*
from all_constraints X
$end

$if false $then
<%@ template name=/dd/dd_utl/dd_utl#pldoc %>
/**
This package is a collection of utility functions, procedures, and cursors used by various code generation utilities.


@headcom
*/
$end

$if false $then
<%@ template name=/dd/dd/make#spec %>
create or replace
package ${schema}.dd
AUTHID CURRENT_USER
as
  <%@ include( /dd/dd/make#pldoc, TEPLSQL_DD_GENERATOR ) %>

  <%@ include( /dd/dd/cursors#main, TEPLSQL_DD_GENERATOR ) %>

end;
/

$end

$if false $then
<%@ template name=/dd/dd/make#pldoc %>
/**
<title>This is the DD API Package.</title>
<h1>Package Description</h1>
<p>This package was generated against a select set of views in the schema ${schema}</p>
<p>
All views names that fit the name format "${oddgen_prefix}ANAME${oddgen_suffix}" were used.
<br>

<p>This is the list found at the time of creation for this package.<br>
<ul><li>coming soon</li></ul><br>
</p>

<p>For each view, the following items were created:<br>
<ul><li>a parameterized named cursor -  getANAME()</li>
<li>associated arrary type for the cursor - ANAME_aa</li>
<li>nested table type for the cursor - ANAME_nt</li>
<li>(soon)an "exists" function for the cursor - existsANAME()</li>
</ul>
</p>

<h1>Parameters Format</h1>
<p>
The named cursor and the exists function use an identical set of parameters.  The parameter list is generated based on the available columns.<br>

<code>xxxxx( [p_object_owner in varchar2,] [p_object_name in varchar2,] p_sxquery in varchar2 default null [,p_database in varchar2 default 'localhost'] [,p_edition in varchar2 default 'ORA$BASE'] )</code>

<table border="1">
<tr><td>p_object_owner</td><td>required</td><td>OBJECT_OWNER</td><td>Owner of the object (eg schema)</td></tr>
<tr><td>p_object_name</td><td>required</td><td>OBJECT_NAME</td><td>Name of the object (eg table name)</td></tr>
<tr><td>p_object_name</td><td>optional</td><td><i>not applicable</it></td><td>simplified XQuery</td></tr>
<tr><td>p_database</td><td>optional</td><td>DATABASE</td><td>Database where object lives.  The view(s) must be customized.  (soon)</td></tr>
<tr><td>p_edition</td><td>optional</td><td>EDITION</td><td>The Edition in which the object exists.  The view(s) must be customized.  (soon)</td></tr>
</table>

If the stated column exists in the View, then the parameter will exist for the specification.  All interfaces will have the <i>p_sxquery</i> parameter.<br>
</p>

<h1>Simplified XQuery Syntax<h1>
<p>All cursor queries use a simplified XQuery syntax.  The function DD_UTIL.sxquery2xquery converts the string into the actual XQuery used by the Cursor.</p>
<p>
Queries are case sensitive.
</p>

<p>Because it is XML related, it will look similar to the PATH clause of XMLTable(). You access the values of a specific column using the format "/COLUMN_NAME".
</p>

<p>Columns of type XMLType cab be searched also.  This allows searching nested data.</p>
<h2>Simple Search Examples</h2>
<p>
<b>SQL</b>:  WHERE COL1 = 'something'<br>
<b>sXQuery</b>:  '/COL1 = "something"'
</p>
<p>
<b>SQL</b>: WHERE COL1 in ( 'a', 'b', 'c')<br>
<b>sXQuery</b>:  '/COL1 = ("a","b","c")'
</p>
<p><i>more examples needed</i></p>

<h2>XML Searching</h2>
Data found within columns having data type XMLType, is also searchable.  However, you need to leave out the column name of the XMLType data.<br>

<b>???</b>Find compressed tables that have a foreign key to TABLE_X<br>
<b>DD cursor</b>dd.getTables( schema_name, '/COMPRESED ="YES" and /constraints/constraint[CONSTRAINT_TYPE="F"]/R_CONSTRAINT_NAME = "TABLE_X_PK"' )<br>

<h1>Enhancing the Package</h1>
<p>To add a cursor to this package, CREATE OR REPLACE VIEW and re-create this package from the code generation engine.</p>

<p>The view expects the following columns:
<ul>
<li><b>OBJECT_OWNER</b> - this maps to the <i>p_owner</i> parameter</li>
<li><b>OBJECT_NAME</b> - this maps to the <p>p_object_name</i> parameter</li>
<li><b>ORDER_BY<b> - the output is automatically sorted by this column.  If not supplied, DBMS_RANDOM.VALUE is used !!!</li>
</ul>



@headcom
*/

$end

$if false $then
<%@ template name=/dd/dd/cursors#pldoc_cursor %>
/**
  Cursor <%@ include( /dd/dd/cursors#name_cursor, TEPLSQL_DD_GENERATOR ) %>


  This does a search on the view ${schema}.<%= t_curr.table_name %>


  @param p_owner  owner of the object
  @param p_object_name name of the object
  @param p_sxqury Simplified XQuery.  See package head for syntax
*/

$end

$if false $then
<%@ template name=/dd/dd/cursors#name_cursor %>
get<%= t_curr.table_name %>
$end

$if false $then
<%@ template name=/dd/dd/cursors#name_aa %>
get<%= t_curr.table_name %>_aa
$end

$if false $then
<%@ template name=/dd/dd/cursors#name_nt %>
get<%= t_curr.table_name %>_nt
$end

$if false $then
<%@ template name=/dd/dd/cursors#name_rcd %>
<%@ include( /dd/dd/cursors#name_cursor, TEPLSQL_DD_GENERATOR ) %>_rcd
$end

$if false $then
<%@ template name=/dd/dd/cursors#type_rcd %>
type <%@ include( /dd/dd/cursors#name_rcd, TEPLSQL_DD_GENERATOR ) %> is <%@ include( /dd/dd/cursors#name_cursor, TEPLSQL_DD_GENERATOR ) %>%ROWTYPE;


$end

$if false $then
<%@ template name=/dd/dd/cursors#type_nt %>
-- some text goes here
type <%@ include( /dd/dd/cursors#name_nt, TEPLSQL_DD_GENERATOR ) %> is table of get<%= t_curr.table_name %>%ROWTYPE;


$end

$if false $then
<%@ template name=/dd/dd/cursors#type_aa %>
type <%@ include( /dd/dd/cursors#name_aa, TEPLSQL_DD_GENERATOR ) %> is table of get<%= t_curr.table_name %>%ROWTYPE
  index by pls_integer;


$end

$if false $then
<%@ template name=/dd/dd/cursors#main %>
 
<% for t_curr in ${schema}.ddfs.GetTables( '${schema}', '/IS_VIEW = "YES"' ) loop %> 
  <%@ include( /dd/dd/cursors#pldoc_cursor, TEPLSQL_DD_GENERATOR ) %>

  cursor <%@ include( /dd/dd/cursors#name_cursor, TEPLSQL_DD_GENERATOR ) %>(
<% if ${schema}.ddfs.existsColumns( '${schema}', t_curr.table_name, '/COLUMN_NAME="OBJECT_OWNER"') then %> p_object_owner in varchar2,<% end if; %>
<% if ${schema}.ddfs.existsColumns( '${schema}', t_curr.table_name, '/COLUMN_NAME="OBJECT_NAME"') then %> p_object_name in varchar2,<% end if; %>
 p_sxquery in varchar2 default null) is 
  <%@ include( /dd/dd/cursors#single_cursor, TEPLSQL_DD_GENERATOR ) %> 

  <%@ include( /dd/dd/cursors#type_aa, TEPLSQL_DD_GENERATOR ) %>

  <%@ include( /dd/dd/cursors#type_nt, TEPLSQL_DD_GENERATOR ) %>

<% end loop; %> 

$end

$if false $then
<%@ template name=/dd/dd/cursors#single_cursor %>
with data as (
  SELECT
    <% for c_curr in ${schema}.ddfs.GetColumns(   '${schema}', t_curr.table_name ) loop %>
      <%= c_curr.column_name %>,
    <% end loop; %>
    xmlelement("row", xmlforest(
    <% for c_curr in ${schema}.ddfs.GetColumns( '${schema}', t_curr.table_name, 'not(/DATA_TYPE = ("LONG","CLOB","BLOB", "XMLTYPE"))' ) loop %>
      <%= c_curr.column_name || ${schema}.dd_utl.add_comma( c_curr.is_last_record) %>\\n
    <% end loop; %>
    )
    <% for c_curr in ${schema}.ddfs.GetColumns( '${schema}', t_curr.table_name, '/DATA_TYPE =  "XMLTYPE"' ) loop %>
      ,<%= c_curr.column_name %>
    <% end loop; %>
) xml
<% if not ${schema}.ddfs.existsColumns( '${schema}', t_curr.table_name, '/COLUMN_NAME = "ORDER_BY"' ) then %>    ,dbms_random.value() as order_by<%= chr(10) %><% end if; %>
    from ${schema}.<%= t_curr.table_name %>
)
select
    <% for c_curr in ${schema}.ddfs.GetColumns( '${schema}', t_curr.table_name ) loop %>
      <%= c_curr.column_name %>,
    <% end loop; %>
<% if not ${schema}.ddfs.existsColumns( '${schema}', t_curr.table_name, '/COLUMN_NAME = "ORDER_BY"' ) then %>    order_by,<%= chr(10) %><% end if; %>
    rank() over (order by ORDER_BY) as IS_FIRST_RECORD,
    rank() over (order by ORDER_BY DESC) as IS_LAST_RECORD
from (
    SELECT
    <% for c_curr in ${schema}.ddfs.GetColumns( '${schema}', t_curr.table_name ) loop %>
      <%= c_curr.column_name %>,
    <% end loop; %>
<% if not ${schema}.ddfs.existsColumns( '${schema}', t_curr.table_name, '/COLUMN_NAME = "ORDER_BY"' ) then %>    order_by,<%= chr(10) %><% end if; %>
    xmlquery( ${schema}.dd_utl.sxquery2xquery( p_sxquery) PASSING x.XML returning content) xml
    FROM DATA X
    WHERE 1=1
<% if ${schema}.ddfs.existsColumns(  '${schema}', t_curr.table_name, '/COLUMN_NAME="OBJECT_OWNER"') then %>
      and object_owner = p_object_owner
<% end if; %>
<% if ${schema}.ddfs.existsColumns(  '${schema}', t_curr.table_name, '/COLUMN_NAME="OBJECT_NAME"') then %>
      and object_name = p_object_name
<% end if; %>
)
where xml is not null
order by ORDER_BY;
$end

$if false $then
<%@ template name=/devtools/templates#make %>
<% for curr in (select * from te_fragments where NAME like '/dd/%' or NAME like '/devtools/%' )
loop %><%= lower( '$IF FALSE $THEN' ) %>\\n
<\\%@ template name=<%= curr.name || '#' || curr.fragment_name %> %\\>
<%= curr.fragment %>\\n
<%= lower('$END') %>\\n

<% end loop; %>

$end

$if false $then
<%@ template name=/dd/views/Tables#sql %>
 with constraint_data as (
  select owner, table_name, xmlelement( "constraints", xmlagg( xmlelement( "constraint", xmlForest(
OWNER,
CONSTRAINT_NAME,
CONSTRAINT_TYPE,
TABLE_NAME,
--SEARCH_CONDITION           LONG()        ??
R_OWNER,
R_CONSTRAINT_NAME,
DELETE_RULE,
STATUS,
DEFERRABLE,
DEFERRED,
VALIDATED,
GENERATED,
BAD,
RELY,
LAST_CHANGE,
INDEX_OWNER,
INDEX_NAME,
INVALID,
VIEW_RELATED
)) )) as CONSTRAINT_XML
from all_constraints
group by owner, table_name
)
select 
  "at".owner as object_owner,
  rank() over ( order by "at".owner, "at".table_name) as order_by,
cd.CONSTRAINT_XML,
"at"."OWNER"
,"at"."TABLE_NAME"
,"at"."TABLESPACE_NAME"
,"at"."CLUSTER_NAME"
,"at"."IOT_NAME"
,"at"."STATUS"
,"at"."PCT_FREE"
,"at"."PCT_USED"
,"at"."INI_TRANS","at"."MAX_TRANS","at"."INITIAL_EXTENT","at"."NEXT_EXTENT","at"."MIN_EXTENTS","at"."MAX_EXTENTS"
,"at"."PCT_INCREASE","at"."FREELISTS","at"."FREELIST_GROUPS"
,"at"."LOGGING","at"."BACKED_UP","at"."NUM_ROWS","at"."BLOCKS","at"."EMPTY_BLOCKS","at"."AVG_SPACE","at"."CHAIN_CNT","at"."AVG_ROW_LEN"
,"at"."AVG_SPACE_FREELIST_BLOCKS","at"."NUM_FREELIST_BLOCKS"
,"at"."DEGREE","at"."INSTANCES","at"."CACHE","at"."TABLE_LOCK"
,"at"."SAMPLE_SIZE","at"."LAST_ANALYZED","at"."PARTITIONED"
,"at"."IOT_TYPE","at"."TEMPORARY","at"."SECONDARY","at"."NESTED"
,"at"."BUFFER_POOL","at"."FLASH_CACHE","at"."CELL_FLASH_CACHE"
,"at"."ROW_MOVEMENT","at"."GLOBAL_STATS","at"."USER_STATS","at"."DURATION"
,"at"."SKIP_CORRUPT","at"."MONITORING","at"."CLUSTER_OWNER"
,"at"."DEPENDENCIES","at"."COMPRESSION","at"."COMPRESS_FOR"
,"at"."DROPPED","at"."READ_ONLY","at"."SEGMENT_CREATED","at"."RESULT_CACHE"
from all_tables "at"
  join constraint_data cd
    on ("at".owner = cd.owner and "at".table_name = cd.table_name)

$end

$if false $then
<%@ template name=/dd/views/Views#sql %>
select
  owner as object_owner
  ,rank() over (order by owner, view_name) as order_by
  ,v.*
from all_views V
$end

$if false $then
<%@ template name=/dd/make#create_views %>
PROMPT creating views
create or replace view ${schema}.<%@ include( /dd/views/Tables#name, TEPLSQL_DD_GENERATOR ) %>
as
<%@ include( /dd/views/Tables#sql, TEPLSQL_DD_GENERATOR ) %>;

create or replace view ${schema}.<%@ include( /dd/views/Views#name, TEPLSQL_DD_GENERATOR ) %>
as
<%@ include( /dd/views/Views#sql, TEPLSQL_DD_GENERATOR ) %>;

create or replace view ${schema}.<%@ include( /dd/views/Columns#name, TEPLSQL_DD_GENERATOR ) %>
as
<%@ include( /dd/views/Columns#sql, TEPLSQL_DD_GENERATOR ) %>;

create or replace view ${schema}.<%@ include( /dd/views/Constraints#name, TEPLSQL_DD_GENERATOR ) %>
as
<%@ include( /dd/views/Constraints#sql, TEPLSQL_DD_GENERATOR ) %>;


$end

$if false $then
<%@ template name=/dd/dd_utl/dd_utl#specification %>
create or replace
package ${schema}.dd_utl
as
  <%@ include( /dd/dd_utl/dd_utl#pldoc, TEPLSQL_DD_GENERATOR ) %>

  <%@ include( /dd/dd_utl/functions/sxquery2xquery#pldoc, TEPLSQL_DD_GENERATOR ) %>
  <%@ include( /dd/dd_utl/functions/sxquery2xquery#spec, TEPLSQL_DD_GENERATOR ) %>;

  <%@ include( /dd/dd_utl/functions/add_comma#pldoc, TEPLSQL_DD_GENERATOR ) %>\\n
  <%@ include( /dd/dd_utl/functions/add_comma#spec, TEPLSQL_DD_GENERATOR ) %>;
end;
<%= '/' %>\\n
$end

$if false $then
<%@ template name=/dd/dd_utl/functions/sxquery2xquery#pldoc %>
/**
  <h1>Translates a simplified XQuery into a real XQuery.</h1>
<p>
  Used to adjust a simpliefied XQuery into a legitimate XQuery.
</p>
<p>
   To Search, create a WHERE clause by prefixing the case-sensitive column name with a slash<br>
     eg  '/VIRTUAL_COLUMN="NO" and /HIDDEN_COLUMN="NO"'
</p>
<p>
The actual format uses XQuery syntax.<br>
eg '/DATA_TYPE = ('VARCHAR2", "NUMBER", "DATE")'
</p>
<p>
If the column in question is of type XMLType, you can search within the XML Data also.
</p>

@param p_sxquery Sipllified XQuery string
@return Actual XQuery string
*/
$end

$if false $then
<%@ template name=/dd/dd_utl/dd_utl#body %>
create or replace
package body ${schema}.dd_utl
as
  <%@ include( /dd/dd_utl/functions/sxquery2xquery#spec, TEPLSQL_DD_GENERATOR ) %>
  <%@ include( /dd/dd_utl/functions/sxquery2xquery#body, TEPLSQL_DD_GENERATOR ) %>

  <%@ include( /dd/dd_utl/functions/add_comma#spec, TEPLSQL_DD_GENERATOR ) %>
  <%@ include( /dd/dd_utl/functions/add_comma#body, TEPLSQL_DD_GENERATOR ) %>

end;
<%= '/' %>\\n
$end

$if false $then
<%@ template name=/dd/dd_utl/functions/sxquery2xquery#spec %>
function sxquery2xquery( p_sxquery in clob ) return clob
DETERMINISTIC
$end

$if false $then
<%@ template name=/dd/dd_utl/functions/sxquery2xquery#body %>
  as
    run_xquery clob := 'for $i in /row return $i';
    l_sxquery clob;
  begin
    if p_sxquery is not null
    then
      l_sxquery := regexp_replace( p_sxquery, '(^|[^[:alnum:]])/', '\1$i/');
      run_xquery := 'for $i in /row where ' || chr(10) || l_sxquery || chr(10) || ' return $i';
    end if;
    -- place debug stuff here
    
    return run_xquery;
  
  end;

$end

$if false $then
<%@ template name=/dd/ddfs/ddfs#body %>
create or replace
package body ${schema}.ddfs
as
  function existsColumns( p_owner in varchar2, p_table_name in varchar2, p_sxquery in varchar default null ) return boolean
  as
    l_buffer getColumns%ROWTYPE ;
    l_test    boolean;
  begin
    open getColumns( p_owner, p_table_name, p_sxquery );
      fetch getColumns into l_buffer;
      l_test := getColumns%NOTFOUND;
    close getColumns;

    if l_test or l_test is null
    then
      return false;
    end if;
    return true;
  end;

  function existsTables( p_owner in varchar2, p_sxquery in varchar2 default null ) return boolean
  as
    l_buffer  getTables%ROWTYPE;
    l_test    boolean;
  begin
    open getTables( p_owner, p_sxquery);
      fetch getTables into l_buffer;
      l_test := getTables%NOTFOUND;
    close getTables;

    if l_test or l_test is null
    then
      return false;
    end if;

    return true;
  end;
end;
<%= '/' %>
$end

$if false $then
<%@ template name=/dd/ddfs/ddfs#spec %>
create or replace
package ${schema}.ddfs
AUTHID CURRENT_USER
as
  cursor getColumns( p_owner in varchar2, p_table_name in varchar2, p_sxquery in varchar default null) is
       with data as (
            select owner, table_name, column_name, data_type, column_id, hidden_column, virtual_column  -- loop column_names
              ,xmlelement("row", xmlforest(
                    table_name, column_name, data_type, column_id, hidden_column, virtual_column -- loop column_names
                  )) xml
            from all_tab_cols
        )
      select 
          owner, table_name, column_name, data_type, column_id, hidden_column, virtual_column, -- loop column_names
    rank() over (order by column_id nulls last, owner nulls last, table_name nulls last) as IS_FIRST_RECORD,
    rank() over (order by column_id desc nulls last, owner desc nulls last, table_name desc nulls last) as IS_LAST_RECORD
      from (
          select
            owner, table_name, column_name, data_type, column_id, hidden_column, virtual_column -- loop column_names
            ,xmlquery( ${schema}.DD_UTL.sxquery2xquery( p_sxquery) PASSING x.XML returning content) xml
          from data x
          where 1=1
             and owner = p_owner
             and table_name = p_table_name -- this is the view name, other options TBD
      )
      where xml is not null
      order by column_id nulls last, owner nulls last, table_name nulls last;

  cursor GetTables( p_owner in varchar2, p_sxquery in varchar2 default null ) is      
      with data as (
        select owner, table_name, tablespace_name, is_table, is_view, table_name order_by,
          xmlelement( "row", xmlforest(
            owner, table_name, tablespace_name, is_table, is_view
          ) ) xml
        from (
          select owner, table_name, TABLESPACE_NAME, 'YES' as IS_TABLE, 'NO' as IS_VIEW from all_tables
          union all
          select owner, view_name, null, 'NO', 'YES' from all_views
        )
      )
      select
              owner, table_name, tablespace_name, is_table, is_view,
    rank() over (order by ORDER_BY) as IS_FIRST_RECORD,
    rank() over (order by ORDER_BY DESC) as IS_LAST_RECORD
        from (
          select
              owner, table_name, tablespace_name, is_table, is_view, order_by
                ,xmlquery( ${schema}.DD_UTL.sxquery2xquery( p_sxquery) PASSING x.XML returning content) xml
                from data x
                where 1=1
                   and owner = p_owner
            )
            where xml is not null
            order by order_by
      ;

  function existsColumns( p_owner in varchar2, p_table_name in varchar2, p_sxquery in varchar default null ) return boolean;
  function existsTables( p_owner in varchar2, p_sxquery in varchar2 default null ) return boolean;
end;
<%= '/' %>\\n
$end

$if false $then
<%@ template name=/dd/views/Columns#sql %>
select
  owner as object_owner, table_name as object_name
  ,rank() over (order by owner, table_name, column_id) as order_by
  ,col.*
from all_tab_cols col
$end


/******************************************************************************\
|********************  end of template dump  **********************************|
/******************************************************************************/

END;
/

CREATE OR REPLACE PACKAGE BODY ftldb_view IS
   /*
   * Copyright 2015 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
   *
   * Licensed under the Apache License, Version 2.0 (the "License");
   * you may not use this file except in compliance with the License.
   * You may obtain a copy of the License at
   *
   *     http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software
   * distributed under the License is distributed on an "AS IS" BASIS,
   * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   * See the License for the specific language governing permissions and
   * limitations under the License.
   */

-- use ${"/"} instead of plain slash (/) to ensure that IDEs such as PL/SQL Developer do not interpret it as command terminator
$IF FALSE $THEN
--%begin generate_ftl
<#assign object_type = template_args[0]/>
<#assign object_name = template_args[1]/>
<#assign view_name = template_args[2]/>
<#assign iot_name = template_args[3]/>
<#assign gen_iot = template_args[4]/>
<#assign conn = default_connection()/>
<#assign columns_query>
   SELECT column_name
     FROM dba_tab_columns
    WHERE table_name = '${object_name}'
      AND owner = USER
    ORDER BY column_id
</#assign>
<#assign columns = conn.query(columns_query)/>
<#assign pk_columns_query>
   SELECT cols.column_name
     FROM dba_constraints pk
     JOIN dba_cons_columns cols
       ON cols.constraint_name = pk.constraint_name
          AND cols.owner = pk.owner
    WHERE pk.constraint_type = 'P'
          AND pk.table_name = '${object_name}'
          AND pk.owner = USER
    ORDER BY cols.position
</#assign>
<#assign pk_columns = conn.query(pk_columns_query)/>
<#macro get_where_clause>
   <#list pk_columns as col>
      <#if col?is_first>
       WHERE ${col.COLUMN_NAME} = :OLD.${col.COLUMN_NAME}<#if col?is_last>;</#if>
      <#else>
         AND ${col.COLUMN_NAME} = :OLD.${col.COLUMN_NAME}<#if col?is_last>;</#if>
      </#if>
   </#list>
</#macro>
-- create 1:1 view for demonstration purposes
CREATE OR REPLACE VIEW ${view_name} AS
<#list columns as col>
   <#if col?is_first>
   SELECT ${col.COLUMN_NAME}<#sep>,</#sep>
   <#else>
          ${col.COLUMN_NAME}<#sep>,</#sep>
   </#if>
</#list>
     FROM ${object_name};
<#if gen_iot = "Yes">
-- create simple instead-of-trigger for demonstration purposes
CREATE OR REPLACE TRIGGER ${iot_name}
   INSTEAD OF INSERT OR UPDATE OR DELETE ON ${view_name}
BEGIN
   IF INSERTING THEN
      INSERT INTO ${object_name} (
   <#list columns as col>
         ${col.COLUMN_NAME}<#sep>,</#sep>
   </#list>
      ) VALUES (
   <#list columns as col>
         :NEW.${col.COLUMN_NAME}<#sep>,</#sep>
   </#list>
      );
   ELSIF UPDATING THEN
      UPDATE ${object_name}
   <#list columns as col>
      <#if col?is_first>
         SET ${col.COLUMN_NAME} = :NEW.${col.COLUMN_NAME}<#sep>,</#sep>
      <#else>
             ${col.COLUMN_NAME} = :NEW.${col.COLUMN_NAME}<#sep>,</#sep>
      </#if>
   </#list>
<@get_where_clause/>
   ELSIF DELETING THEN
      DELETE FROM ${object_name}
<@get_where_clause/>
   END IF;
END;
${"/"}
</#if>
--%end generate_ftl
$END

   --
   -- private types
   --
   SUBTYPE object_name_type IS VARCHAR2(30 CHAR);
   SUBTYPE string_type IS VARCHAR2(1000 CHAR);

   --
   -- private constants
   --
   c_new_line     CONSTANT string_type := chr(10);
   c_max_obj_len  CONSTANT simple_integer := 30;
   c_oddgen_error CONSTANT simple_integer := -20501;

   --
   -- get_name
   --
   FUNCTION get_name RETURN VARCHAR2 IS
   BEGIN
      RETURN '1:1 View (FTLDB)';
   END get_name;

   --
   -- get_description
   --
   FUNCTION get_description RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Generates a 1:1 view based on an existing table. Optionally generates a simple instead of trigger.';
   END get_description;

   --
   -- get_object_types
   --
   FUNCTION get_object_types RETURN vc2_array IS
   BEGIN
      RETURN NEW vc2_array('TABLES');
   END get_object_types;

   --
   -- get_object_names
   --
   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN vc2_array IS
      l_object_names vc2_array;
   BEGIN
      SELECT object_name
        BULK COLLECT
        INTO l_object_names
        FROM dba_objects
       WHERE object_type = in_object_type
         AND owner = USER
       ORDER BY object_name;
      RETURN l_object_names;
   END get_object_names;

   --
   -- get_params
   --
   FUNCTION get_params RETURN vc2_indexed_array IS
      l_params vc2_indexed_array;
   BEGIN
      l_params(c_view_suffix) := '_V';
      l_params(c_table_suffix) := '_T';
      l_params(c_iot_suffix) := '_TRG';
      l_params(c_gen_iot) := 'Yes';
      RETURN l_params;
   END get_params;

   --
   -- get_lovs
   --
   FUNCTION get_lovs RETURN vc2_array_indexed_array IS
      l_params vc2_array_indexed_array;
   BEGIN
      l_params(c_gen_iot) := NEW vc2_array('Yes', 'No');
      RETURN l_params;
   END get_lovs;

   --
   -- generate (1)
   --
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2,
                     in_params      IN vc2_indexed_array) RETURN CLOB IS
      l_args   varchar2_nt;
      l_result CLOB;
      l_params vc2_indexed_array;
      --
      FUNCTION get_base_name RETURN VARCHAR2 IS
         l_base_name object_name_type;
      BEGIN
         IF l_params(c_table_suffix) IS NOT NULL AND
            length(l_params(c_table_suffix)) > 0 AND
            substr(in_object_name,
                   length(in_object_name) - length(l_params(c_table_suffix))) =
            l_params(c_table_suffix) THEN
            l_base_name := substr(in_object_name,
                                  1,
                                  length(in_object_name) -
                                  length(l_params(c_table_suffix)));
         ELSE
            l_base_name := in_object_name;
         END IF;
         RETURN l_base_name;
      END get_base_name;
      --
      FUNCTION get_name(suffix_in IN VARCHAR2) RETURN VARCHAR2 IS
         l_name object_name_type;
      BEGIN
         l_name := get_base_name;
         IF length(l_name) + length(suffix_in) > c_max_obj_len THEN
            l_name := substr(l_name, 1, c_max_obj_len - length(suffix_in));
         END IF;
         l_name := l_name || suffix_in;
         RETURN l_name;
      END get_name;
      --
      FUNCTION get_view_name RETURN VARCHAR2 IS
      BEGIN
         RETURN get_name(l_params(c_view_suffix));
      END get_view_name;
      --
      FUNCTION get_iot_name RETURN VARCHAR2 IS
      BEGIN
         RETURN get_name(l_params(c_iot_suffix));
      END get_iot_name;
      --
      PROCEDURE check_params IS
         l_found INTEGER;
      BEGIN
         SELECT COUNT(*)
           INTO l_found
           FROM dba_tables
          WHERE table_name = in_object_name
            AND owner = USER;
         IF l_found = 0 THEN
            raise_application_error(c_oddgen_error,
                                    'Table ' || in_object_name ||
                                    ' not found.');
         END IF;
         IF get_view_name = in_object_name THEN
            raise_application_error(c_oddgen_error,
                                    'Change <' || c_view_suffix ||
                                    '>. The target view must be named differently than its base table.');
         END IF;
         IF l_params(c_gen_iot) NOT IN ('Yes', 'No') THEN
            raise_application_error(c_oddgen_error,
                                    'Invalid value <' ||
                                    l_params(c_gen_iot) ||
                                    '> for parameter <' || c_gen_iot ||
                                    '>. Valid are Yes and No.');
         END IF;
         IF l_params(c_gen_iot) = 'Yes' THEN
            IF get_iot_name = get_view_name OR
               get_iot_name = in_object_name THEN
               raise_application_error(c_oddgen_error,
                                       'Change <' || c_iot_suffix ||
                                       '>. The target instead-of-trigger must be named differently than its base view and base table.');
            END IF;
            SELECT COUNT(*)
              INTO l_found
              FROM dba_constraints
             WHERE constraint_type = 'P'
                   AND table_name = in_object_name
                   AND owner = USER;
            IF l_found = 0 THEN
               raise_application_error(c_oddgen_error,
                                       'No primary key found in table ' ||
                                       in_object_name ||
                                       '. Cannot generate instead-of-trigger.');
            END IF;
         END IF;
      END check_params;
      --
      PROCEDURE init_params IS
         i string_type;
      BEGIN
         l_params := get_params;
         IF in_params.count() > 0 THEN
            i := in_params.first();
            <<input_params>>
            WHILE (i IS NOT NULL)
            LOOP
               IF l_params.exists(i) THEN
                  l_params(i) := in_params(i);
                  i := in_params.next(i);
               ELSE
                  raise_application_error(c_oddgen_error,
                                          'Parameter <' || i ||
                                          '> is not known.');
               END IF;
            END LOOP input_params;
         END IF;
         check_params;
      END init_params;
   BEGIN
      IF in_object_type = 'TABLE' THEN
         init_params;
         l_args   := NEW varchar2_nt(in_object_type,
                                           in_object_name,
                                           get_view_name,
                                           get_iot_name,
                                           l_params(c_gen_iot));
         l_result := ftldb_api.process_to_clob(in_templ_name => lower($$PLSQL_UNIT) || '%generate_ftl',
                                               in_templ_args => l_args);
      ELSE
         raise_application_error(c_oddgen_error,
                                 '<' || in_object_type ||
                                 '> is not a supported object type. Please use TABLE.');
      END IF;
      RETURN l_result;
   END generate;

   --
   -- generate (2)
   --
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2) RETURN CLOB IS
      l_params vc2_indexed_array;
   BEGIN
      RETURN generate(in_object_type => in_object_type,
                      in_object_name => in_object_name,
                      in_params      => l_params);
   END generate;
END ftldb_view;
/
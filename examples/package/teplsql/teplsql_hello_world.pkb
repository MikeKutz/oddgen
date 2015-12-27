CREATE OR REPLACE PACKAGE BODY teplsql_hello_world IS
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

   --
   -- generate
   --
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2) RETURN CLOB IS
      l_result   CLOB;
      l_template CLOB;
      l_vars     teplsql.t_assoc_array;
   BEGIN
      -- use <%='/'%> instead of plain slash (/) to ensure that IDEs such as PL/SQL Developer do not interpret it as command terminator
      l_template := q'[
BEGIN
   sys.dbms_output.put_line('Hello ${object_type} ${object_name}!');
END;
<%='/'%>\\n
]';
      l_vars('object_type') := in_object_type;
      l_vars('object_name') := in_object_name;
      l_result := teplsql.render(p_vars => l_vars, p_template => substr(l_template, 2));
      RETURN trim(l_result); -- remove tailing space generated by tePLSQL (issue 11)
   END generate;
END teplsql_hello_world;
/
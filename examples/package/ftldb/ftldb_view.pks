CREATE OR REPLACE PACKAGE ftldb_view IS
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

   /** 
   * oddgen FTLDB example to generate a 1:1 view based on an existing table.
   *
   * @headcom
   */

   --
   -- oddgen PL/SQL data types
   --
   TYPE vc2_array IS TABLE OF VARCHAR2(1000 CHAR);
   TYPE vc2_indexed_array IS TABLE OF VARCHAR2(1000 CHAR) INDEX BY VARCHAR2(30 CHAR);
   TYPE vc2_array_indexed_array IS TABLE OF vc2_array INDEX BY VARCHAR2(30 CHAR);
   SUBTYPE param_type IS VARCHAR2(30 CHAR);

   --
   -- parameter names used also as labels in the GUI
   --
   c_view_suffix  CONSTANT param_type := 'View suffix';
   c_table_suffix CONSTANT param_type := 'Table suffix to be replaced';
   c_iot_suffix   CONSTANT param_type := 'Instead-of-trigger suffix';
   c_gen_iot      CONSTANT param_type := 'Generate instead-of-trigger';

   /**
   * Get name of the generator, used in tree view
   * If this function is not implemented, the package name will be used.
   *
   * @returns name of the generator
   */
   FUNCTION get_name RETURN VARCHAR2;

   /**
   * Get a description of the generator.
   * If this function is not implemented, the owner and the package name will be used.
   * 
   * @returns description of the generator
   */
   FUNCTION get_description RETURN VARCHAR2;

   /**
   * Get a list of supported object types.
   * If this function is not implemented, [TABLE, VIEW] will be used. 
   *
   * @returns a list of supported object types
   */
   FUNCTION get_object_types RETURN vc2_array;

   /**
   * Get a list of objects for a object type.
   * If this function is not implemented, the result of the following query will be used:
   * "SELECT object_name FROM user_objects WHERE object_type = in_object_type"
   *
   * @param in_object_type object type to filter objects
   * @returns a list of objects
   */
   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN vc2_array;

   /**
   * Get all parameters supported by the generator including default values.
   * If this function is not implemented, no parameters will be used.
   *
   * @returns parameters supported by the generator
   */
   FUNCTION get_params RETURN vc2_indexed_array;

   /**
   * Get a list of values per parameter, if such a LOV is applicable.
   * If this function is not implemented, then the parameters cannot be validated in the GUI.
   *
   * @returns parameters with their list-of-values
   */
   FUNCTION get_lovs RETURN vc2_array_indexed_array;

   /**
   * Updates the list of values per parameter.
   * This function is called after a parameter change in the GUI.
   * While this allows to amend the list-of-values based on user entry, 
   * this function call makes the GUI less responsive and disables multiple selection.
   * Do not implement this function, unless you really need it.
   *
   * @param in_params parameters to configure the behavior of the generator
   * @returns parameters with their list-of-values
   */
   --FUNCTION refresh_lovs(in_params IN vc2_indexed_array)
   --   RETURN vc2_array_indexed_array;

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
                     in_params      IN vc2_indexed_array) RETURN CLOB;

   /**
   * Alternative, simplified version of the generator, which is applicable in SQL.
   * Default values according get_params are used for in_params.
   * This function is implemented for convenience purposes only.
   *
   * @param in_object_type object type to process
   * @param in_object_name object_name of in_object_type to process
   * @returns generator output
   * @throws ORA-20501 when parameter validation fails
   */
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2) RETURN CLOB;

END ftldb_view;
/
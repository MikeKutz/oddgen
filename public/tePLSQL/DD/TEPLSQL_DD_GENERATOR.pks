create or replace package teplsql_dd_generator
as
   --
   -- oddgen PL/SQL data types
   --
   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
   SUBTYPE param_type IS VARCHAR2(30 CHAR);
   TYPE t_string IS TABLE OF string_type;
   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
   TYPE t_lov IS TABLE OF t_string INDEX BY param_type;

   --
   -- oddgen GLOBALS
   --
   G_GEN_NAME  CONSTANT string_type := '(tePLSQL) DD Generator';
   G_GEN_DESC  CONSTANT string_type := 'Create (and recreate) various portions the DD set of packages';
   G_TYPE_1    CONSTANT string_type := '1 - create Utils,etc.';
   G_TYPE_2    CONSTANT string_type := '2 - (re)Create DD Package';
   G_TYPE_3    CONSTANT string_type := '3 - create fragments';
   G_ALL_TYPES CONSTANT t_string := t_string( G_TYPE_1, G_TYPE_2, G_TYPE_3 );
   
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
   FUNCTION get_object_types RETURN t_string;

   /**
   * Get a list of objects for a object type.
   * If this function is not implemented, the result of the following query will be used:
   * "SELECT object_name FROM user_objects WHERE object_type = in_object_type"
   *
   * @param in_object_type object type to filter objects
   * @returns a list of objects
   */
   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN t_string;


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
                     in_params      IN t_param) RETURN CLOB;


 procedure copyVars( p_src in teplsql.t_assoc_array, p_dst in out nocopy teplsql.t_assoc_array );
 function  getVarDefaults return teplsql.t_assoc_array;
 procedure setVarDefaults( p_vars in out nocopy teplsql.t_assoc_array);

end;
/

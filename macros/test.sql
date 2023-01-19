{% macro get_meta_data(meta_table) %}

    {% set query %}

SELECT Source_table,Key_colmns,Target_Table,Target_Table_key_column,Output_Columns,Jointype FROM {{ meta_table }}

    {% endset %}

     {% set results_list = [] %}
    {% set data = run_query(query) %}
    {% if execute %}
    {% set results_list = data.rows %}
    {% endif %}
    {{ return(results_list) }}
    {% endmacro %}

    {% macro get_column_data(table_name,column_name) %}
SELECT {{column_name}} FROM {{ table_name }}
    {% endmacro %}


    {% macro process_meta_table_step(table_name) %}

    {%  set data =  get_meta_data(meta_table=table_name) %}

SELECT
    {% for row in data -%}
    {%  if loop.index  > 1 and row[4] is not none -%}
        , {{row[4]}}
    {% elif row[4] is not none -%}
    {{row[4]}}
    {% endif -%}
    {% endfor -%}
FROM
    {% for row in data -%}
    {% if loop.index == 1  -%}
    {{row[0]}}  {{row[5]}}  {{row[2]}}
    {% endif -%}
    {% endfor -%}  ON
    {% set ns = namespace(source_table=false)  -%}
        {%  set nst = namespace(target_table=false) -%}
        {% for row in data -%}
        {% if loop.index == 1 and row[1] is not none -%}
        {{row[0]}}.{{row[1]}} = {{row[2]}}.{{row[3]}}
        {% set ns.source_table = row[0] -%}
        {% set nst.target_table = row[2] -%}
        {% elif row[1] is not none and loop.index > 1   -%}
        AND   {{ns.source_table}}.{{row[1]}} = {{nst.target_table}}.{{row[3]}}
        {%endif-%}
        {% endfor -%}

        {% endmacro %}


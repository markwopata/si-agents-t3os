view: trovata_connections {
  sql_table_name: "ANALYTICS"."TREASURY"."TROVATA_CONNECTIONS"
    ;;

  dimension: bank_name {
    type: string
    sql: ${TABLE}."BANK_NAME" ;;
  }

  dimension: connection_type {
    type: string
    sql: ${TABLE}."CONNECTION_TYPE" ;;
  }

  dimension: risk_level {
    type: string
    html:


    {% if value == 'High' %}


    <p style="color: white; background-color: #B32F37;">{{ rendered_value }}</p>


    {% elsif value == 'Moderate' %}


    <p style="color: black; background-color: #FFD95F;">{{ rendered_value }}</p>

    {% else %}

    {{ rendered_value }}

    {% endif %};;
    sql: ${TABLE}."RISK_LEVEL" ;;
  }

  dimension: risk_level_sort {
    type: number
    sql: case when ${risk_level} = 'High' then 1 when ${risk_level} = 'Moderate' then 2 when ${risk_level} = 'Low' then 3 end ;;
  }




  dimension: status {
    type: string
    html:


    {% if value == 'Down' %}


    <p style="color: white; background-color: #B32F37;">{{ rendered_value }}</p>

     {% else %}

    {{ rendered_value }}

    {% endif %};;
    sql: ${TABLE}."STATUS" ;;
  }


}

view: collector_targets {

  derived_table: {
    sql:
    SELECT
      CUSTOMER_ID,
      COLLECTOR,
      MANAGER,
      SUM(ACTUAL_COLLECTIONS) AS ACTUAL_COLLECTIONS,
      SUM(COLLECTIONS_TARGET) AS GOAL
    FROM ANALYTICS.TREASURY.COLLECTOR_TARGETS_CHARTS
    GROUP BY
      CUSTOMER_ID,
      COLLECTOR,
      MANAGER
      ;;
  }

######### DIMENSIONS #########

  dimension: collector {
    type: string
    sql: ${TABLE}.COLLECTOR ;;
  }

  dimension: manager {
    type: string
    sql: ${TABLE}.MANAGER ;;
    link: {
      label: "Collector Detail"
      url: "https://equipmentshare.looker.com/dashboards/1847?Collector=&Manager={{ manager._filterable_value | url_encode }}"
    }
  }

  dimension: customer_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.CUSTOMER_ID ;;
  }

  ######### PRIMARY KEY #########
  dimension: key {
    type: string
    primary_key: yes
    sql:  ${collector} || '-' || ${manager} || '-' || ${customer_id};;
  }


  ######### MEASURES #########

  measure: goal {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.GOAL ;;
  }

  measure: actual_collections {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.ACTUAL_COLLECTIONS ;;
  }

  }

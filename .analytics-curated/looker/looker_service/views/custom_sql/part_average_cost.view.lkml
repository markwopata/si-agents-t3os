view: part_average_cost {
  derived_table: {
    sql:
      SELECT
         acs.current_part_id,
         acs.current_part_number,
         acs.snapshot_date,

         {% if average_type._parameter_value == 'national' %}
         case when sum(coalesce(acs.quantity,0))=0 then avg(acs.avg_cost) else sum(acs.avg_cost * coalesce(acs.quantity,0))/
            sum(coalesce(acs.quantity,0)) end avg_cost,
       sum(coalesce(acs.quantity,0)) quantity,
       null source,
       null store_id,
       null store_name,
       null market_id,
       null market_name,
       null most_recent_cost,
       null most_recent_transaction_cost,
       null _es_update_timestamp
      {% else %}
        acs.source,
        acs.store_id,
        acs.store_name,
        acs.market_id,
        acs.market_name,
        acs.most_recent_cost,
        acs.most_recent_transaction_cost,
        acs._es_update_timestamp,
        acs.avg_cost,
        acs.quantity
       {% endif %}

        FROM
          analytics.public.average_cost_snapshot acs
        where acs.snapshot_date = (select max(snapshot_date) from analytics.public.average_cost_snapshot)
      {% if average_type._parameter_value == 'national' %}
        group by acs.current_part_id, acs.current_part_number, acs.snapshot_date,
       acs.source
      {% endif %}

      ;;
  }

  parameter: average_type {
    type: unquoted
    allowed_value: {
      label: "National Average"
      value: "national"
    }

    allowed_value: {
      label: "Store Part Average"
      value: "standard"
    }
  }

  dimension: store_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.store_id ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}.store_name ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.current_part_id ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}.current_part_number ;;
  }

  dimension: average_cost {
    type: number
    value_format_name: decimal_4
    sql: ${TABLE}.avg_cost ;;
  }

  dimension: most_recent_cost {
    type: number
    value_format_name: decimal_4
    sql: ${TABLE}.most_recent_cost ;;
  }

  dimension: most_recent_transaction_cost {
    type: number
    value_format_name: decimal_4
    sql: ${TABLE}.most_recent_transaction_cost ;;
  }
}

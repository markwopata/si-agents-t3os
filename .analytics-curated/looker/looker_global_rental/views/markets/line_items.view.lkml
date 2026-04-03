view: line_items {
  derived_table: {
    sql:  select
              r.rental_id,
              ca.name as categoy,
              a.asset_class,
              m.name as branch,
              ast.name as asset_type,
              convert_timezone('{{ _user_attributes['user_timezone'] }}', li.created_date) as created_date,
              sum(coalesce(li.total, 0)) as amount
          from
              orders o
              join rentals r on o.order_id = r.order_id
              join global_line_items li on r.rental_id = li.rental_id
              join markets m on m.market_id = o.market_id
              join companies c on c.company_id = m.company_id
              left join es_warehouse.public.assets a on a.asset_id = r.asset_id
              left join es_warehouse.public.categories ca on ca.category_id = a.category_id
              left join es_warehouse.public.asset_types ast on ast.asset_type_id = a.asset_type_id
          where
            li.line_item_type_id in (1,2) AND li.domain_id = 1
      and
          m.company_id = {{ _user_attributes['company_id'] }}::numeric
      AND
      {% condition asset_type_filter %} ast.name {% endcondition %}
      AND
      {% condition category_filter %} ca.name {% endcondition %}
      AND
      {% condition branch_filter %} m.name {% endcondition %}
      AND
      {% condition asset_class_filter %} a.asset_class {% endcondition %}
      group by 1,2,3,4,5,6
      ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }

  dimension_group: created_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."CREATED_DATE" AS TIMESTAMP_NTZ);;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT";;
    value_format_name: usd_0
  }

  measure: total_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
  }

  dimension: current_year_month {
    type: yesno
    sql: date_part(month,${created_date_raw})  = date_part(month,(date_trunc('month', current_date)))
      and date_part(year,${created_date_raw})  = date_part(year,(date_trunc('year', current_date))) ;;
  }

  dimension:  date_created_last_mtd{
    type: yesno
    sql: date_part(day,${created_date_raw}) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${created_date_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
          and date_part(year,${created_date_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
  }

  measure: month_to_date_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [current_year_month: "Yes"]
  }

  measure: last_mtd_revenue {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [date_created_last_mtd: "Yes"]
  }

  filter: asset_type_filter {
  }

  filter: category_filter {
  }

  filter: branch_filter {
  }

  filter: asset_class_filter {
  }
}

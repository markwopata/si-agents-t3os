
view: region_hierarchy_discount {
  derived_table: {
    sql:
      select
          mrx.region_name as region,
          mrx.district,
          mrx.market_name as market,
          mrx.market_type,
          mrx.market_id,
          case when right(mrx.market_name, 9) = 'Hard Down' then true else false end as hard_down,
         -- mol.months_open_over_12,
          rp.online_rate,
          percent_discount,
          vmt.is_current_months_open_greater_than_twelve
      from
          analytics.public.rateachievement_points rp
          JOIN analytics.public.market_region_xwalk mrx on rp.market_id = mrx.market_id
          LEFT JOIN es_warehouse.public.equipment_classes ec on ec.equipment_class_id = rp.equipment_class_id
      left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
      group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt on vmt.market_id = rp.market_id

      where
          rp.invoice_date_created::date >= current_date - interval '29 days'
          AND (ec.name is null OR UPPER(ec.name) not like UPPER('%bucket%'))
          AND mrx.division_name = 'Equipment Rental'
          ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: hard_down {
    type: yesno
    sql: ${TABLE}."HARD_DOWN" ;;
  }

  dimension: months_open_over_12 {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
  }

  dimension: online_rate {
    type: number
    sql: ${TABLE}."ONLINE_RATE" ;;
  }

  dimension: percent_discount {
    type: number
    sql: ${TABLE}."PERCENT_DISCOUNT" ;;
  }

  measure: total_discount_percentage {
    type: number
    # sql: IFF(((${total_percent_discount}*${total_online_rate})/${total_online_rate}) is null,1,((${total_percent_discount}*${total_online_rate})/${total_online_rate})) ;;
    sql: case when sum(${online_rate}) != 0 and sum(${percent_discount}) is not null then (sum(${percent_discount}*${online_rate})/sum(${online_rate}))
    else 1 end;;
    value_format_name: percent_1
  }

  set: detail {
    fields: [
        region,
  district,
  market,
  market_type,
  percent_discount,
  online_rate
    ]
  }
}
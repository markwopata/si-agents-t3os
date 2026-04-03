view: vendor_rebate_terms {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."VENDOR_REBATE_TERMS" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: base_rebate_perc {
    type: number
    sql: ${TABLE}."BASE_REBATE_PERC" ;;
  }
  dimension: rebate_offered {
    type: yesno
    sql: ${TABLE}."REBATE_OFFERED" ;;
  }
  dimension: mapped_vendor_name {
    type: string
    sql: ${TABLE}."MAPPED_VENDOR_NAME" ;;
  }
  measure: count {
    type: count
  }
}

view: vendor_rebate_terms_score {
  derived_table: {
    sql:
with cte as (
    select tvm.vendorid
        , v.mapped_vendor_name
        , tvm.vendor_type
        , v.rebate_offered
        , v.base_rebate_perc
    from ANALYTICS.PARTS_INVENTORY.VENDOR_REBATE_TERMS v
    join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm
        on v.mapped_vendor_name = tvm.mapped_vendor_name
            and tvm.primary_vendor ilike 'yes'
)

select a.vendorid
    , a.rebate_offered
    , a.base_rebate_perc
    , avg(pa.base_rebate_perc) as peer_avg_rebate
    , greatest(coalesce(peer_avg_rebate, 0), 5) as graded_target
    , iff(a.rebate_offered = false, 0, iff((a.base_rebate_perc / graded_target) * (1/14) > (1/14), (1/14), (a.base_rebate_perc / graded_target) * (1/14))) as vendor_rebate_score
    , iff(a.rebate_offered = false, 0,iff((a.base_rebate_perc / graded_target) * (10) > (10), (10), (a.base_rebate_perc / graded_target) * (10))) as vendor_rebate_score10
from cte a
left join cte pa
    on pa.mapped_vendor_name <> a.mapped_vendor_name
        and pa.vendor_type = a.vendor_type
group by 1,2,3
;;
  }
  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }
  dimension: rebate_offered {
    type: yesno
    sql: ${TABLE}.rebate_offered ;;
  }
  dimension: base_rebate_perc {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.base_rebate_perc / 100 ;;
  }
  dimension: peer_avg_rebate {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.peer_avg_rebate / 100 ;;
  }
  dimension: graded_target {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.graded_target / 100 ;;
  }
  dimension: vendor_rebate_score {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.vendor_rebate_score, 0) ;;
  }
  dimension: vendor_rebate_score10 {
    type: number
    value_format_name: decimal_1
    sql: coalesce(${TABLE}.vendor_rebate_score10, 0) ;;
  }
}

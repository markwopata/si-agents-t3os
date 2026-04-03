view: vendor_freight_terms {
  sql_table_name: "PARTS_INVENTORY"."VENDOR_FREIGHT_TERMS" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: free_freight {
    type: yesno
    sql: ${TABLE}."FREE_FREIGHT" ;;
  }
  dimension: freight_term {
    type: number
    sql: ${TABLE}."FREIGHT_TERM" ;;
  }
  dimension: mapped_vendor_name {
    type: string
    sql: ${TABLE}."MAPPED_VENDOR_NAME" ;;
  }
  measure: count {
    type: count
  }
}

view: vendor_freight_terms_score {
  derived_table: {
    sql:
with cte as (
    select tvm.vendorid
        , v.mapped_vendor_name
        , tvm.vendor_type
        , v.free_freight
        , iff( v.free_freight = true and v.freight_term is null, 0, v.freight_term) as freight_term
    from ANALYTICS.PARTS_INVENTORY.VENDOR_FREIGHT_TERMS v
    join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm
        on v.mapped_vendor_name = tvm.mapped_vendor_name
            and tvm.primary_vendor ilike 'yes'
)

select a.vendorid
    , a.free_freight
    , a.freight_term
    , avg(pa.freight_term) as peer_avg_freight_term
    , least(coalesce(peer_avg_freight_term, 999999999999999999), 500) as graded_target
    , case
        when a.free_freight = false then 0
        when a.freight_term = 0 then (1/14)
        else iff((graded_target / a.freight_term) * (1/14) > (1/14), (1/14), (graded_target / a.freight_term) * (1/14))
        end as vendor_freight_score
    , case
        when a.free_freight = false then 0
        when a.freight_term = 0 then 10
        else iff((graded_target / a.freight_term) * 10 > 10, 10, (graded_target / a.freight_term) * 10)
        end as vendor_freight_score10
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
  dimension: free_freight_offered {
    type: yesno
    sql: ${TABLE}.free_freight ;;
  }
  dimension: freight_term {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.freight_term ;;
  }
  dimension: peer_avg_freight_term {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.peer_avg_freight_term ;;
  }
  dimension: graded_target {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.graded_target ;;
  }
  dimension: vendor_freight_score {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.vendor_freight_score, 0) ;;
  }
  dimension: vendor_freight_score10 {
    type: number
    value_format_name: decimal_1
    sql: coalesce(${TABLE}.vendor_freight_score10, 0) ;;
  }
}

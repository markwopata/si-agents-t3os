view: fleet_unavailable {
  derived_table: {
    sql:with get_past_months as (
      select date_trunc('month', dateadd(month, -row_number() over (order by null), dateadd(month, 1, current_date()))) as generateddate
    from table(generator(rowcount => 48))  -- Adjust rowcount to generate more or fewer months as needed
)

, own as (
    select aa.asset_id, vpp.start_date, coalesce(vpp.end_date, '2099-12-31') as end_date
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    join ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS vpp
        on vpp.asset_id = aa.asset_id
)

, es as (
    select aa.asset_id, scd.date_start start_date, scd.date_end end_date --all assets owned by es at the end of the year
    from ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY scd
    join ANALYTICS.PUBLIC.ES_COMPANIES esc
        on esc.company_id = scd.company_id
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on scd.asset_id = aa.asset_id
    where esc.owned = true
)

-- , test as (
    SELECT vendorid,
        vendor_name,
        vendor_type,
        d.generateddate as generateddate,
        a.asset_id,
        aa.make,
        aa.model,
        aa.oec,
        iff(scd.asset_inventory_status IN ('Soft Down','Hard Down'), aa.oec, null) as unavailable_oec,
        iff(scd.asset_inventory_status = 'Soft Down', aa.oec,null) as soft_down_oec,
        iff(scd.asset_inventory_status = 'Hard Down',aa.oec,null) as hard_down_oec,
        scd.asset_inventory_status as asset_status,
        concat(vendorid,d.generateddate, a.asset_id) as primary_key,
        -- row_number() over (partition by a.asset_id , generateddate order by vendorid) r --which ever version of the vendor it joins to first that is the one we want to keep
    from get_past_months d
    JOIN ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY_STATUS scd
        on scd.date_start <= d.generateddate
            and scd.date_end > d.generateddate
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."ASSETS" a
        on a.asset_id = scd.asset_id
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."ASSETS_AGGREGATE" aa
        ON aa.asset_id = a.asset_id
    join (
            select vendorid
                , vendor_name
                , mapped_vendor_name
                , vendor_type
                , iff(mapped_vendor_name <> 'Doosan / Bobcat', mapped_vendor_name, 'DOOSAN') as join1
                , iff(join1 = 'DOOSAN', 'BOBCAT', null) as join2
            from "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" v
            where primary_vendor ilike 'yes'and mapped_vendor_name is not null) v
        on upper(join1) = aa.make or upper(join2) = aa.make
    left join own
        on own.asset_id = aa.asset_id
            and own.start_date <= generateddate
            and own.end_date > generateddate
    left join es
        on es.asset_id = aa.asset_id
            and es.start_date <= generateddate
            and es.end_date > generateddate
    WHERE a.company_id <> 11606
        and LEFT(a.serial_number, 2) <> 'RR'
        and LEFT(a.custom_name, 2) <> 'RR'
        AND aa.oec is not null
        and coalesce(es.asset_id, own.asset_id) is not null -- ES Owned or Maintained
    -- qualify r = 1
--)
--viz tests out
-- select generateddate, vendor_name, sum(oec) o, sum(unavailable_oec) u, round((u/o) * 100, 0) as perc from test where vendor_name ilike '%SANY%' group by generateddate, vendor_name
;;
  }

  dimension: primary_key {
    type: string
    primary_key: yes
    sql:${TABLE}.primary_key ;;
    # sql: CAST(
    #       CONCAT(
    #       ${TABLE}.company_purchase_order_line_item_id,
    #       ${TABLE}.vendorid)
    #       as VARCHAR) ;;
  }

  dimension: vendorid {
    type: string
    #primary_key: yes
    sql: ${TABLE}.vendorid ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.vendor_name ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}.asset_id ;;
  }

  dimension_group: generateddate {
    type: time
    timeframes: [raw,date,time,week,month,quarter,year]
    sql: ${TABLE}.generateddate ;;
  }

  dimension:  last_30_days{
    type: yesno
    sql:  ${generateddate_date} <= current_date AND ${generateddate_date} >= (current_date - INTERVAL '30 days')
      ;;
  }

  # dimension:  po_last_30_days{
  #   type: yesno
  #   sql:  ${po_date_created} <= current_date AND ${po_date_created} >= (current_date - INTERVAL '30 days')
  #     ;;
  # }

  dimension: asset_status {
    type: string
    sql: ${TABLE}.asset_status ;;
  }

  measure: asset_count {
    type: count_distinct
    sql: ${TABLE}.asset_id ;;
  }

  measure: asset_count_down {
    type: count_distinct
    filters: [asset_status: "Soft Down, Hard Down"]
    sql: ${TABLE}.asset_id ;;
  }

  measure: asset_count_soft_down {
    type: count_distinct
    filters: [asset_status: "Soft Down"]
    sql: ${TABLE}.asset_id ;;
  }

  measure: asset_count_hard_down {
    type: count_distinct
    filters: [asset_status: "Hard Down"]
    sql: ${TABLE}.asset_id ;;
  }


  measure: oec {
    type: sum
    label: "OEC"
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${TABLE}.oec ;;
    drill_fields: [
      vendorid,
      vendor_name,
      asset_id,
      make,
      model,
      oec,
      unavailable_oec
    ]
  }

  measure: days_30_oec {
    type: sum
    filters: [last_30_days: "No"]
    value_format_name: usd
    value_format: "$#,##0"
    sql: ${TABLE}.oec ;;
  }

  # measure: days_30_asset_spend {
  #   type: sum
  #   filters: [po_last_30_days: "No"]
  #   value_format_name: usd
  #   value_format: "$#,##0"
  #   sql: ${TABLE}.oec ;;
  # }

  measure: unavailable_oec {
    type: sum
    label: "Unavailable OEC"
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${TABLE}.unavailable_oec ;;
  }
  measure: soft_down_oec {
    type: sum
    label: "Soft Down OEC"
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${TABLE}.soft_down_oec ;;
  }
  measure: hard_down_oec {
    type: sum
    label: "Hard Down OEC"
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${TABLE}.hard_down_oec ;;
  }
  measure: hard_down_percent {
    type: number
    label: "% of OEC in Hard Down"
    value_format_name: percent_1
    sql:case when ${hard_down_oec}= 0 or ${oec_comparison.oec} = 0 then 0 else ${hard_down_oec}/${oec_comparison.oec} end ;;
  }

  measure: days_30_unavailable_oec {
    type: sum
    filters: [last_30_days: "No"]
    value_format_name: usd
    value_format: "$#,##0"
    sql: ${TABLE}.unavailable_oec ;;
  }

  # measure: days_in_period {
  #   type: count_distinct
  #   sql: ${po_date_created} ;;
  # }

  # measure: avg_unavailable_oec_dollars{
  #   type:  number
  #   sql: ${unavailable_oec}/${days_in_period} ;;
  #   value_format: "$#,##0"
  # }

  # measure: avg_total_oec_dollars {
  #   type: number
  #   sql: ${oec}/${days_in_period} ;;
  #   value_format: "$#,##0"
  # }

  measure: unavailable_oec_percent_no_html {
    label: "Unavailable OEC %"
    type: number
    sql: case when ${unavailable_oec} = 0 or ${oec} = 0 then 0 else ${unavailable_oec}/${oec} end ;;
    value_format_name: percent_0
    #drill_fields: [detail*]
  }

  measure: unavailable_oec_percent_no_html_30_day {
    label: "Unavailable OEC % 30"
    type: number
    sql: case when ${days_30_unavailable_oec} = 0 or ${days_30_oec} = 0 then 0 else ${days_30_unavailable_oec}/${days_30_oec} end ;;
    value_format_name: percent_0
    #drill_fields: [detail*]
  }

  measure: unavailable_oec_percent {
    type: number
    label: "% of Fleet Unavailable"
    #need to fix this table
    #link: {label: "Unavailable OEC Trend Table"
    #  url:"https://equipmentshare.looker.com/looks/815"}
    sql: case when ${unavailable_oec} = 0 or ${oec} = 0 then 0 else ${unavailable_oec}/${oec} end ;;
    html: {{unavailable_oec_percent._rendered_value}} <br> {{asset_count._rendered_value}} Total Assets | {{asset_count_down._rendered_value}} Assets Down ({{asset_count_soft_down._rendered_value}} Soft | {{asset_count_hard_down._rendered_value}} Hard);;
    value_format_name: percent_0
    #drill_fields: [detail*]
  }

  # measure: asset_count_total {
  #   type: count
  #   #value_format_name: number
  #   value_format: "0"
  #   sql: ${TABLE}.asset_id ;;
  # }

  # set: asset_detail {
  #   fields: [ market_region_xwalk.market_name,
  #     asset_id_wo_link,
  #     serial_number,
  #     most_recent_rental.days_on_rent,
  #     assets_aggregate.category,
  #     assets_aggregate.class,
  #     assets_inventory.make,
  #     assets_inventory.model,
  #     company_id,
  #     companies.name,
  #     asset_status_key_values.value,
  #     current_inventory_status.days_in_current_status,
  #     current_inventory_status.date_start_date,
  #     asset_purchase_history_facts_final.OEC,
  #     last_wo_update.update_type,
  #     asset_location.address,
  #     asset_location.map_link]
  # }
}

view: oec_for_comparison {
  derived_table: {
    sql:
      select generateddate, vendorid, vendor_name, sum(oec) as oec
      from ${fleet_unavailable.SQL_TABLE_NAME}
      group by generateddate, vendorid, vendor_name ;;
  }

  dimension: generateddate {
    type: date_month
    sql: ${TABLE}.generateddate ;;
  }

  dimension: vendorid {
    type: string
    #primary_key: yes
    sql: ${TABLE}.vendorid ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.vendor_name ;;
  }

  dimension: primary_key {
    type: string
    primary_key: yes
    sql: concat(${vendorid}, ${generateddate}) ;;
  }

  measure: oec {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.oec ;;
  }
}

view: vendor_fleet_unavailable_score {
  derived_table: {
    sql:
with agg as (
    select vendorid
        , vendor_type
        , sum(oec) as vendor_oec
        , sum(unavailable_oec) as vendor_unavailable
    from ${fleet_unavailable.SQL_TABLE_NAME}
    where generateddate >= dateadd(month, -12, date_trunc(month, current_date))
    group by 1,2
)

select a.vendorid
    , a.vendor_type -- hidden
    , a.vendor_unavailable / a.vendor_oec as vendor_avg_unavailable_perc
    , sum(pa.vendor_oec) as peers_oec -- hidden
    , sum(pa.vendor_unavailable) as peers_unavailable -- hidden
    , peers_unavailable / peers_oec as peers_avg_unavailable_perc
    , least(coalesce(peers_avg_unavailable_perc, 1), 0.08) as target
    , iff((target / vendor_avg_unavailable_perc) * 1.25 > 1.25, 1.25, (target / vendor_avg_unavailable_perc) * 1.25) as fleet_unavailable_score
    , iff((target / vendor_avg_unavailable_perc) * 10 > 10, 10, (target / vendor_avg_unavailable_perc) * 10) as fleet_unavailable_score10
from agg a
left join agg pa
    on pa.vendorid <> a.vendorid
        and pa.vendor_type = a.vendor_type
-- where a.vendor_type = 'Aerial'
group by 1,2,3
;;
  }
  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }
  dimension: vendor_avg_unavailable_perc {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.vendor_avg_unavailable_perc ;;
  }
  dimension: peers_avg_unavailable_perc {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.peers_avg_unavailable_perc ;;
  }
  dimension: unavailable_perc_target {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.target;;
  }
  dimension: fleet_unavailable_score {
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.fleet_unavailable_score ;;
  }
  dimension: fleet_unavailable_score10 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.fleet_unavailable_score10 ;;
  }
}

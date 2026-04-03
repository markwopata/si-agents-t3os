view: oec_vendor_level {
derived_table: {
  sql:--Every Asset we've bought from a vendor at any time. We don't care if we own it now, but we care we bought it from them
with asset_status_key_values AS (
    select *
    from ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES
    where name = 'asset_inventory_status'
)

SELECT
    vendorid,
    x.company_id,
    po.vendor_id,
    sage_vendor_name as vendor_name,
    aa.asset_id as asset_id,
    po.created_at as po_date_created, -- add the PO date created col in order to filter to for the asset spend
    ai.date_created as asset_date_created, --old date col
    aa.make as make,
    aa.model as model,
    aa.oec,
    iff(askv.value IN ('Soft Down','Hard Down'), aa.oec, null) as unavailable_oec,
    askv.value as asset_status,
    concat(COMPANY_PURCHASE_ORDER_LINE_ITEM_ID,vendorid) as primary_key,
    row_number() over (partition by aa.asset_id order by vendorid) r --which ever version of the vendor it joins to first that is the one we want to keep
    FROM "ES_WAREHOUSE"."PUBLIC"."ASSETS" ai
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."ASSETS_AGGREGATE" aa
        ON aa.asset_id = ai.asset_id
    LEFT JOIN asset_status_key_values askv
        ON askv.asset_id = ai.asset_id
    --add vendor info
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."COMPANY_PURCHASE_ORDER_LINE_ITEMS" li
        ON ai.asset_id = li.asset_id
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."COMPANY_PURCHASE_ORDERS" po
        ON li.company_purchase_order_id = po.company_purchase_order_id
    LEFT JOIN "ANALYTICS"."INTACCT"."COMPANY_TO_SAGE_VENDOR_XWALK" x --When joining on company id to the vendor x walk you will get all the versions of that vendor, that is why the qualify and row_number count is there.
        ON po.vendor_id = x.company_id
    WHERE li.deleted_at IS NULL
        AND vendorid is NOT NULL
        AND aa.oec is not null
    qualify r = 1

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

  dimension_group: date_created {
    type: time
    timeframes: [raw,date,time,week,month,quarter,year]
    sql: ${TABLE}.asset_date_created ;;
  }

  dimension: po_date_created {
    type: date
    sql: ${TABLE}.po_date_created ;;
  }

  dimension: po_created_year {
    type: number
    sql: year(${TABLE}.po_date_created) ;;
  }

  dimension: po_date_is_minus_3_years {
    type: yesno
    sql: iff(${po_created_year} = year(dateadd(year, -3, current_date)), true, false) ;;
  }

  dimension: po_date_is_minus_2_years {
    type: yesno
    sql: iff(${po_created_year} = year(dateadd(year, -2, current_date)), true, false) ;;
  }

  dimension: po_date_is_last_year {
    type: yesno
    sql: iff(${po_created_year} = year(dateadd(year, -1, current_date)), true, false) ;;
  }

  dimension: po_date_is_this_year {
    type: yesno
    sql: iff(${po_created_year} = year(current_date), true, false) ;;
  }

  dimension:  last_30_days{
    type: yesno
    sql:  ${date_created_date} <= current_date AND ${date_created_date} >= (current_date - INTERVAL '30 days')
      ;;
  }

  dimension:  po_last_30_days{
    type: yesno
    sql:  ${po_date_created} <= current_date AND ${po_date_created} >= (current_date - INTERVAL '30 days')
      ;;
  }

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
    po_date_created,
    make,
    model,
    oec,
    unavailable_oec
    ]
  }

  measure: minus_3_year_spend {
    label: "Asset Spend 3 Years Ago"
    type: sum
    value_format_name: usd_0
    filters: [po_date_is_minus_3_years: "yes"]
    sql: ${TABLE}.oec  ;;
  }

  measure: minus_2_year_spend {
    label: "Asset Spend 2 Years Ago"
    type: sum
    value_format_name: usd_0
    filters: [po_date_is_minus_2_years: "yes"]
    sql: ${TABLE}.oec  ;;
  }

  measure: last_year_spend {
    label: "Asset Spend Last Year"
    type: sum
    value_format_name: usd_0
    filters: [po_date_is_last_year: "yes"]
    sql: ${TABLE}.oec  ;;
  }

  measure: ytd_spend {
    label: "Asset Spend YTD"
    type: sum
    value_format_name: usd_0
    filters: [po_date_is_this_year: "yes"]
    sql: ${TABLE}.oec  ;;
  }

  dimension: days_into_year {
    type: number
    sql: datediff(day, date_trunc(year, current_date), current_date) ;;
  }
  dimension: days_left_in_year {
    type: number
    sql: datediff(day, current_date, date_trunc(year, dateadd(year, 1, current_date))) ;;
  }
  measure: total_year_spend_projection {
    label: "Full Year Asset Spend Projection"
    type: number
    value_format_name: usd_0
    sql: ((${ytd_spend} / ${days_into_year}) * ${days_left_in_year}) + ${ytd_spend}  ;;
  }

  measure: days_30_oec {
    type: sum
    filters: [last_30_days: "No"]
    value_format_name: usd
    value_format: "$#,##0"
    sql: ${TABLE}.oec ;;
  }

  measure: days_30_asset_spend {
    type: sum
    filters: [po_last_30_days: "No"]
    value_format_name: usd
    value_format: "$#,##0"
    sql: ${TABLE}.oec ;;
  }

  measure: unavailable_oec {
    type: sum
    label: "Unavailable OEC"
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${TABLE}.unavailable_oec ;;
  }

  measure: days_30_unavailable_oec {
    type: sum
    filters: [last_30_days: "No"]
    value_format_name: usd
    value_format: "$#,##0"
    sql: ${TABLE}.unavailable_oec ;;
  }

  measure: days_in_period {
    type: count_distinct
    sql: ${po_date_created} ;;
  }

  measure: avg_unavailable_oec_dollars{
    type:  number
    sql: ${unavailable_oec}/${days_in_period} ;;
    value_format: "$#,##0"
  }

  measure: avg_total_oec_dollars {
    type: number
    sql: ${oec}/${days_in_period} ;;
    value_format: "$#,##0"
  }

  measure: unavailable_oec_percent_no_html {
    label: "Unavailable OEC %"
    type: number
    sql: case when ${unavailable_oec} = 0 or ${oec} = 0 then 0 else ${unavailable_oec}/${oec} end ;;
    value_format_name: percent_1
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
}

# view: oec_comparison {
#   derived_table: {
#     sql:
#       select vendorid
#         , sum(oec) as oec
#       from ${oec_vendor_level.SQL_TABLE_NAME}
#       group by vendorid
#       ;;
#   }

#   dimension: vendorid {
#     type: string
#     primary_key: yes
#     sql: ${TABLE}.vendorid ;;
#   }

#   dimension: oec_ {
#     type: number
#     value_format_name: usd_0
#     sql: ${TABLE}.oec ;;
#   }

#   measure: oec { #This is going to be the same number but I am making it into a measure for formatting reasons
#     type: sum
#     value_format_name: usd_0
#     sql: ${oec_} ;;
#   }
# }

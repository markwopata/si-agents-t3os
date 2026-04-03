view: warranty_invoices {
  derived_table: {
    sql: WITH parse_1 as (
    select wo.work_order_id
        , note
        , iff(note ilike 'Claim was submitted passed the allotted time frame for consideration.', '11', coalesce( --Reclass for ones created before type 11 existed
            TRIM(STRTOK(STRTOK(NOTE, ':', 2),';',1))
            , trim(left(note, 2))
        )) as Denial_Code
        , ROW_NUMBER() OVER(PARTITION BY wo.WORK_ORDER_ID ORDER BY DATE_CREATED DESC) as rank
    FROM es_warehouse.work_orders.work_order_notes wo
    where ((Note  like '"Warranty Denial Code:%'
        or Note ilike 'Warranty Denial Code:%' )
        or (note ilike '%1 - Out of Warranty;%'
        or note ilike '%2 - Parts Not Returned;%'
        or note ilike '%3 - Use of Non-OEM Parts;%'
        or note ilike '%4 - Deemed Damage or Abuse;%'
        or note ilike '%5 - Not a Warrantable Failure;%'
        or note ilike '%6 - Referred to Engine Manufacture;%'
        or note ilike '%7 - Repairs Not Authorized;%'
        or note ilike '%8 - Parts Tested Good;%'
        or note ilike '%9 - Other;%'
        or note ilike '%10 - Lack of Maintenance;%'
        or note ilike '%11 - Submission Time Expired;%'
        or note ilike '%12 - Requested Info Not Provided;%'
        or note ilike 'Claim was submitted passed the allotted time frame for consideration.'))
    order by work_order_id
)

, WO_Denial_Code as (
    select p1.WORK_ORDER_ID
        , date_trunc(year, wo.date_completed) as dates
        , DENIAL_CODE
    from parse_1 p1
    JOIN ES_WAREHOUSE.work_orders.work_orders wo
        ON p1.work_order_ID = wo.work_order_ID
    WHERE rank = 1
    order by p1.work_order_id
)

, All_Denial_Code as (
    --Old Denials using inactive fivetran job
    SELECT DISTINCT wi.WORK_ORDER_NUMBER::STRING as WORK_ORDER_ID
        , TRIM(STRTOK(wi.DENIAL_CODE,' ',1))::VARCHAR as DENIAL_CODE
        , wi._FIVETRAN_SYNCED
        , ROW_NUMBER() OVER(PARTITION BY wo.WORK_ORDER_ID ORDER BY wi._row DESC) as rank
        , _row
        , 'warranty_invoices' as flag
    FROM ANALYTICS.GS.WARRANTY_INVOICES wi
    left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        on wo.work_order_id::VARCHAR = wi.work_order_number::VARCHAR
    left join WO_DENIAL_CODE wdc
        on wdc.WORK_ORDER_ID::VARCHAR = wi.WORK_ORDER_NUMBER::VARCHAR --No dupes between tables
    WHERE wi.DENIAL_CODE is not null and wdc.work_order_id is null

    UNION

    SELECT wdi.WORK_ORDER_ID::STRING as work_order_id
       , TRIM(wdi.DENIAL_CODE)::VARCHAR as DENIAL_CODE
       , null as _FIVETRAN_SYNCED
       , 1 as rank
       , null as _row
       , 'wo_notes' as flag
    FROM WO_DENIAL_CODE wdi
    WHERE DENIAL_CODE is not null
)

-- , test as (
SELECT adc.WORK_ORDER_ID as WORK_ORDER_NUMBER
       , adc.DENIAL_CODE
       , adc._FIVETRAN_SYNCED
       , wdr.Description
       , CONCAT(adc.DENIAL_CODE, ' - ', wdr.DESCRIPTION) as DENIAL_CODE_FULL
FROM All_Denial_Code adc
LEFT JOIN ANALYTICS.PARTS_INVENTORY.WARRANTY_DENIAL_REASONS wdr
    ON adc.denial_code::VARCHAR = wdr.denial_code::VARCHAR
where rank = 1
;;
  }


  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  # dimension: claim_number {
  #   type: string
  #   sql: ${TABLE}."CLAIM_NUMBER" ;;
  # }

  # dimension: credit_memo_number {
  #   type: string
  #   sql: ${TABLE}."CREDIT_MEMO_NUMBER" ;;
  # }

  # dimension: credit_memo_received {
  #   type: yesno
  #   sql: ${credit_memo_number} is not null ;;
  # }

  # dimension: invoice_number {
  #   primary_key: yes
  #   type: string
  #   sql: ${TABLE}."INVOICE_NO" ;;
  # }

  # dimension: invoice_id {
  #   type: number
  #   value_format_name: id
  #   sql: ${TABLE}."INVOICE_ID" ;;
  # }

  dimension: work_order_number {
    primary_key: yes
    type: string
    sql: ${TABLE}."WORK_ORDER_NUMBER" ;;
  }

  dimension: formatted_work_order_number {
    type: number
    sql: try_cast(${work_order_number} as numeric) ;;
  }

  dimension: denial_code {
    type: string
    sql: ${TABLE}."DENIAL_CODE" ;;
  }

  dimension: denial_code_number {
    type: number
    sql: left(${denial_code}, 1) ;;
  }

  dimension: denial_code_full {
    type: string
    sql: ${TABLE}."DENIAL_CODE_FULL" ;;
  }

  dimension: is_denied {
    type: yesno
    sql: ${denial_code} is not null ;;
  }

  # measure: denied_count {
  #   type: count_distinct
  #   sql: ${invoice_number};;
  #   filters: [is_denied: "Yes"]
  #   drill_fields: [detail*]
  # }

  dimension: track_link_to_WO {
    label: "Link to WO"
    type: string
    sql: ${work_order_number} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_number._value }}/updates" target="_blank">Track</a></font></u> ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: work_order_id_with_link_to_work_order {
    label: "Work Order ID"
    type: string
    sql: ${work_order_number} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_number._value }}" target="_blank">{{ work_order_number._value }}</a></font></u> ;;
  }

  set: detail {
    fields: [market_region_xwalk.region_name
      , market_region_xwalk.market_name
      , invoices.created_date
      , invoices.invoice_no
      , warranty_invoice_asset_info.admin_link_to_invoice
      , invoices.date_created_date
      , companies.customer_name
      , warranty_invoice_asset_info.asset_id
      , assets_aggregate.make
      , assets_aggregate.model
      , warranty_invoice_asset_info.total_invoice_amount
      , warranty_invoice_asset_info.total_invoice_amount_denied
      , denial_code_full
      , work_order_id_with_link_to_work_order
    ]
  }
}

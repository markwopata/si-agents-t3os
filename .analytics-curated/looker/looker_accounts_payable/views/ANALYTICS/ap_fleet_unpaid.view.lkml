view: ap_fleet_unpaid {
  sql_table_name: "FLEET"."AP_FLEET_UNPAID" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: link_vendor_direct{
    type: string
    html: <font color="black " size="3"><u><a href ="https://equipmentshare.looker.com/dashboards/1605"target="_blank">Vendor Direct</a></font></u> ;;
    sql: ${TABLE}._ROW ;;
  }
  dimension: link_book_of_business{
    type: string
    html: <font color="black " size="3"><u><a href ="https://equipmentshare.looker.com/dashboards/1606"target="_blank">Book Of Business Breakout</a></font></u> ;;
    sql: ${TABLE}._ROW ;;
  }
  dimension: link_aging_report{
    type: string
    html: <font color="black " size="3"><u><a href ="https://equipmentshare.looker.com/dashboards/1607"target="_blank">Aging Report</a></font></u> ;;
    sql: ${TABLE}._ROW ;;
  }
  dimension: link_vendor_paid_history{
    type: string
    html: <font color="black " size="3"><u><a href ="https://equipmentshare.looker.com/dashboards/1608"target="_blank">Vendor Paid History</a></font></u> ;;
    sql: ${TABLE}._ROW ;;
  }
  dimension: link_es_paid_customer_non_paid{
    type: string
    html: <font color="black " size="3"><u><a href ="https://equipmentshare.looker.com/dashboards/1609"target="_blank">ES Paid Customer Non Paid</a></font></u> ;;
    sql: ${TABLE}._ROW ;;
  }
  dimension: link_vehicle_business_review{
    type: string
    html: <font color="black " size="3"><u><a href ="https://equipmentshare.looker.com/dashboards/1610"target="_blank">Vehicle Business Review</a></font></u> ;;
    sql: ${TABLE}._ROW ;;
  }
  dimension: link_sage_fleet_vendor_attributes{
    type: string
    html: <font color="black " size="3"><u><a href ="https://equipmentshare.looker.com/dashboards/1611"target="_blank">Sage Fleet Vendor Attributes</a></font></u> ;;
    sql: ${TABLE}._ROW ;;
  }
  dimension: link_payables_download{
    type: string
    html: <font color="black " size="3"><u><a href ="https://equipmentshare.looker.com/dashboards/1604"target="_blank">Payables Download</a></font></u> ;;
    sql: ${TABLE}._ROW ;;
  }
  dimension: _row {
    # primary_key: yes
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension_group: approval {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."APPROVAL_DATE" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: book_of_business {
    type: string
    sql: ${TABLE}."BOOK_OF_BUSINESS" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: core_designation {
    type: string
    sql: ${TABLE}."CORE_DESIGNATION" ;;
  }
  dimension: customer_paid {
    type: string
    sql: ${TABLE}."CUSTOMER_PAID" ;;
  }
  dimension_group: customer_paid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CUSTOMER_PAID_DATE" ;;
   }
  # dimension: date_of_workflow_update {
  #   type: date
  #   datatype: datetime
  #   sql: ${TABLE}."DATE_OF_WORKFLOW_UPDATE" ;;
  # }
  # dimension: date_of_workflow_update {
  #   type: string
  #   sql:${TABLE}."DATE_OF_WORKFLOW_UPDATE" ;;
  # }
  # dimension:  date_of_workflow_update {
  #   type: string
  #   sql: TO_VARCHAR(CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."DATE_OF_WORKFLOW_UPDATE"), 'YYYY-MM-DD HH24:MI:SS') ;;
  # }
  dimension:  date_of_workflow_update {
    type: string
    sql: TO_VARCHAR(CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."DATE_OF_WORKFLOW_UPDATE"), 'YYYY-MM-DD HH24:MI') ;;
  }
  dimension_group: date_to_be_paid {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_TO_BE_PAID" ;;
    label: "Timeframe To Be Paid"
  }
  dimension: date_to_be_paid_v2 {
    type: date
    sql: ${TABLE}."DATE_TO_BE_PAID" ;;
    label: "Date To Be Paid"
  }
  dimension: week_of_month {
    type: number
    sql: (
          FLOOR((EXTRACT(DAY FROM ${TABLE}."DATE_TO_BE_PAID") - 1) / 7) + 1
        ) ;;
    description: "Week number of the month for a given date."
  }

  # dimension: days_past_due {
  #   type: number
  #   sql: ${TABLE}."DAYS_PAST_DUE" ;;
  # }
  dimension: days_past_due_buckets {
    type: string
    sql: CASE
          WHEN ${days_until_due} <= 0 THEN 'Current'
          WHEN ${days_until_due} >= 1 AND ${days_until_due} <= 5 THEN '1-5'
          WHEN ${days_until_due} >= 6 AND ${days_until_due} <= 10 THEN '6-10'
          WHEN ${days_until_due} >= 11 AND ${days_until_due} <= 21 THEN '11-21'
          WHEN ${days_until_due} >= 22 AND ${days_until_due} <= 28 THEN '22-28'
          WHEN ${days_until_due} >= 29 AND ${days_until_due} <= 35 THEN '29-35'
          WHEN ${days_until_due} >= 36 AND ${days_until_due} <= 45 THEN '36-45'
          WHEN ${days_until_due} >= 46 AND ${days_until_due} <= 59 THEN '46-59'
          WHEN ${days_until_due} >= 60 THEN '>=60'
          ELSE 'unknown'
        END ;;

        label: "Days Past Due"
  }

  dimension: days_past_due_buckets_sort {
    type: number
    sql: CASE
          WHEN ${days_until_due} <= 0 THEN 1
          WHEN ${days_until_due} >= 1 AND ${days_until_due} <= 5 THEN 2
          WHEN ${days_until_due} >= 6 AND ${days_until_due} <= 10 THEN 3
          WHEN ${days_until_due} >= 11 AND ${days_until_due} <= 21 THEN 4
          WHEN ${days_until_due} >= 22 AND ${days_until_due} <= 28 THEN 5
          WHEN ${days_until_due} >= 29 AND ${days_until_due} <= 35 THEN 6
          WHEN ${days_until_due} >= 36 AND ${days_until_due} <= 45 THEN 7
          WHEN ${days_until_due} >= 46 AND ${days_until_due} <= 59 THEN 8
          WHEN ${days_until_due} >= 60 THEN 9
          ELSE 10
        END ;;
    label: "Sort Key"

  }


  dimension: days_until_due_buckets {
    type: string
    sql: CASE
          --WHEN ${days_until_due} <= 0 THEN 'Current'
          WHEN ${days_until_due} >= -7 AND ${days_until_due} <= -1 THEN '1-7'
          WHEN ${days_until_due} >= -14 AND ${days_until_due} <= -8 THEN '8-14'
          WHEN ${days_until_due} >= -21 AND ${days_until_due} <= -15 THEN '15-21'
          WHEN ${days_until_due} >= -28 AND ${days_until_due} <= -22 THEN '22-28'

          WHEN ${days_until_due} < -28 THEN '>28'
          WHEN ${days_until_due} >=0 THEN 'Past Due'
          ELSE 'unknown'
        END ;;

    label: "Days Until Due Bucket"
  }

  dimension: days_until_due_buckets_sort {
    type: number
    sql: CASE
          --WHEN ${days_until_due} <= 0 THEN 'Current'
          WHEN ${days_until_due} >= -7 AND ${days_until_due} <= -1 THEN 1
          WHEN ${days_until_due} >= -14 AND ${days_until_due} <= -8 THEN 2
          WHEN ${days_until_due} >= -21 AND ${days_until_due} <= -15 THEN 3
          WHEN ${days_until_due} >= -28 AND ${days_until_due} <= -22 THEN 4

          WHEN ${days_until_due} < -28 THEN 5
          WHEN ${days_until_due} >=0 THEN 6
          else 7
        END ;;
    label: " Sort Key - Days Until Due"

  }
  dimension: recon_buckets {
    type: string
    sql: CASE
          WHEN ${recon_status_w_statement_verification} ILIKE '%1-Statement Verified and Received%' THEN 'Reconciled'
          WHEN ${recon_status_w_statement_verification} ILIKE '%2%' THEN 'Reconciled'
          WHEN ${recon_status_w_statement_verification} ILIKE '%3%' THEN 'Reconciled'
          WHEN ${recon_status_w_statement_verification} ILIKE '%4%' THEN 'Reconciled'
          WHEN ${recon_status_w_statement_verification} ILIKE '%5%' THEN 'Reconciled'
          WHEN ${recon_status_w_statement_verification} ILIKE '%6%' THEN 'Reconciled'

          WHEN ${recon_status_w_statement_verification} ILIKE '%7%' THEN 'Not Reconciled'
          WHEN ${recon_status_w_statement_verification} ILIKE '%8%' THEN 'Unreconciled - Purchaser Owned'
          WHEN ${recon_status_w_statement_verification} ILIKE '%Placeholder%' THEN 'Placeholder'

          ELSE 'unknown'
        END ;;
    label: "Recon Bucket"

  }

  dimension: verified_bucket {
    type: string
    sql:  CASE
          WHEN ${recon_status_w_statement_verification} ILIKE '%1-Statement Verified and Received%' THEN 'Verified'
          WHEN ${recon_status_w_statement_verification} ILIKE '%2%' THEN 'Reconciled'
          WHEN ${recon_status_w_statement_verification} ILIKE '%3%' THEN 'Verified'
          WHEN ${recon_status_w_statement_verification} ILIKE '%4%' THEN 'Reconciled'
          WHEN ${recon_status_w_statement_verification} ILIKE '%5%' THEN 'Verified'
          WHEN ${recon_status_w_statement_verification} ILIKE '%6%' THEN 'Reconciled'

          WHEN ${recon_status_w_statement_verification} ILIKE '%7%' THEN 'Not Reconciled'
          WHEN ${recon_status_w_statement_verification} ILIKE '%8%' THEN 'Unreconciled - Purchaser Owned'
          WHEN ${recon_status_w_statement_verification} ILIKE '%Placeholder%' THEN 'Placeholder'

          ELSE 'unknown'
        END ;;

    # label: "Recon Bucket"

  }
  # dimension: days_past_due_bucket_order {
  #   type: number
  #   sql:
  #   CASE
  #     WHEN ${days_past_due} <= 30 THEN 1
  #     WHEN ${days_past_due} > 30 AND ${days_past_due} <= 60 THEN 2
  #     WHEN ${days_past_due} > 60 AND ${days_past_due} <= 90 THEN 3
  #     ELSE 4
  #   END ;;
  # }
  measure: avg_days_due {
    type: average
    sql: ${days_until_due} ;;
  }
  # dimension: days_until_due {
  #   type: number
  #   sql: ${TABLE}."DAYS_UNTIL_DUE" ;;
  # }
  dimension: days_until_due {
    type: number
    #sql: DATE_PART('day', ${due_date}::timestamp - CURRENT_TIMESTAMP()::timestamp)  ;;
    #sql: datediff(day, ${due_date} , CURRENT_TIMESTAMP())  ;;
    sql: datediff(day, ${due_date}, CURRENT_TIMESTAMP())  ;;
  }
  dimension_group: due {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DUE_DATE" ;;
  }
  dimension: factory_build_specs {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECS" ;;
  }
  dimension: financing_designation {
    type: string
    sql: ${TABLE}."FINANCING_DESIGNATION" ;;
  }
  dimension: financing_status {
    type: string
    sql: ${TABLE}."FINANCING_STATUS" ;;
  }
  dimension: ft_vendor_id {
    type: number
    sql: ${TABLE}."FT_VENDOR_ID" ;;
  }
  dimension_group: invoice {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: order_number {
    type: string
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }
  dimension: order_status {
    type: string
    sql: ${TABLE}."ORDER_STATUS" ;;
  }
#   The field is determined by the Book of Business (BoB).
# Anything that has EZ in the BoB = EZ ACH/Check
# Anything that has Pie in the BoB = PIE ACH/Check
# OEC Addition in the BoB = ACH/Check-OEC Addition
# Vechicles-Upfit in the BoB = ACH/Vehicle Upfit
# Vechicles-Chassis in the BoB = ACH/Check-Account 1309
# Then vendor Canada Towers Inc. = Wire
# Vendor CNH Industrial America LLC (Case Construction) = Portal
# Then anything remaining should be ES = ACH/Check
  dimension: preferred_payment {
    type: string
    sql:
    CASE

        when upper(${book_of_business}) ILIKE '%EZ%' then  'EZ ACH/Check'
        when upper(${book_of_business}) ILIKE '%PIE%' then 'PIE ACH/Check'
        when upper(${book_of_business}) ILIKE '%OEC ADDITION%' then 'ACH/Check-OEC Addition'
        when upper(${book_of_business}) ILIKE '%VEHICLES-UPFIT%' then 'ACH/Vehicle Upfit'
        when upper(${book_of_business}) ILIKE '%VEHICLES-CHASSIS%' then 'ACH/Check-Account 1309'
        when ${sage_vendor_id} ='V32814' then 'Wire'
        when ${sage_vendor_id} = 'V12588' then 'Portal'

      ELSE 'ACH/Check'
    END ;;

  }


  dimension: recon_status_w_statement_verification {
    type: string
    sql:
    CASE
    WHEN ${reconciliation_status} IN ('Issue with OEC', 'Issue with Description', 'PO Needs Re-Approval', 'Issue with Market/Release Date', 'Multiple Issues', 'Issue with Net Terms' )
        THEN '8 - Unreconciled Purchaser Owned'
      WHEN ${reconciliation_status} IN ('Reconciled', 'Reconciled. Aftermarket in progress', 'Second Reconciliation') THEN
        CASE
          WHEN ${order_status} = 'Received' THEN '2-Reconciled and Received'
          WHEN ${order_status} = 'Shipped' THEN '4-Reconciled and Shipped'
          ELSE '6-Reconciled and Not Shipped'
        END
      WHEN ${reconciliation_status} = 'Statement Verified' THEN
        CASE
          WHEN ${order_status} = 'Received' THEN '1-Statement Verified and Received'
          WHEN ${order_status} = 'Shipped' THEN '3-Statement Verified and Shipped'
          ELSE '5-Statement Verified and Not Shipped'
        END


        when upper(${book_of_business}) ILIKE '%PLACEHOLDER%' then 'Placeholder'

      ELSE '7-Unreconciled'
    END ;;
    label: "Recon"
  }
  dimension: pending_schedule {
    type: string
    sql: ${TABLE}."PENDING_SCHEDULE" ;;
  }
  dimension: po_approval_status {
    type: string
    sql: ${TABLE}."PO_APPROVAL_STATUS" ;;
  }
  dimension: reconciliation_status {
    type: string
    sql: ${TABLE}."RECONCILIATION_STATUS" ;;
  }
  dimension: sage_vendor_id {
    type: string
    sql: ${TABLE}."SAGE_VENDOR_ID" ;;
  }
  dimension: sent_to_ap {
    type: yesno
    sql: ${TABLE}."SENT_TO_AP" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: title_status {
    type: string
    sql: ${TABLE}."TITLE_STATUS" ;;
  }
  dimension: total_oec {
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }


  measure: sum_total_oec {
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
    # value_format: "#,##0.00"
    value_format: "#,##0"
    drill_fields: [
      _row,
      fleet_track_lines.purchase_requester,
      fleet_track_lines.note,
      asset_id,
      book_of_business,
      category,
      class,
      core_designation,
      customer_paid,
      invoice_date,
      date_to_be_paid_v2,

      days_past_due_buckets,
      days_until_due,
      due_date,
      factory_build_specs,
      financing_designation,
      financing_status,
      ft_vendor_id,
      invoice_number,
      make,
      market,
      market_id,
      model,
      order_number,
      order_status,
      recon_status_w_statement_verification,
      pending_schedule,
      po_approval_status,
      reconciliation_status,
      sage_vendor_id,
      sent_to_ap,
      serial_number,
      title_status,
      total_oec,
      vendor_name,
      year
      ]
  }
  measure: count {
    type: count
    label: "Count"
    drill_fields: [
      _row,
      fleet_track_lines.purchase_requester,
      fleet_track_lines.note,
      asset_id,
      book_of_business,
      category,
      class,
      core_designation,
      customer_paid,
invoice_date,
      date_to_be_paid_v2,

      days_past_due_buckets,
      days_until_due,
      due_date,
      factory_build_specs,
      financing_designation,
      financing_status,
      ft_vendor_id,
      invoice_number,
      make,
      market,
      market_id,
      model,
      order_number,
      order_status,
      recon_status_w_statement_verification,
      pending_schedule,
      po_approval_status,
      reconciliation_status,
      sage_vendor_id,
      sent_to_ap,
      serial_number,
      title_status,
      total_oec,
      vendor_name,
      year]
  }
}

view: ap_payments_no_filter {
  derived_table: {
    sql:


select
  row_number() over (
    order by
      aprh.recordid,
      aprd.itemid,
      apbpmt.paymentdate
  ) as pk,
  aprh.vendorid,
  case
    when aprh.vendorid in ('v27903','v12154','v12074','v32370','v12191') then 'core'
    else 'other'
  end as core_vs_other,
  aprh.prbatch,
  case
    when upper(aprh.prbatch) like '%FLEET%'   then 'no'
    when upper(aprh.prbatch) like '%OEC%'     then 'no'
    when upper(aprh.prbatch) like '%UPFIT%'   then 'no'
    when upper(aprh.prbatch) like '%VEHICLE%' then 'no'
    else 'yes'
  end as sold_assets,
  aprhpay.paymenttype      as payment_type,
  vend.name,
  vend.diversity_classification,
  vend.vendtype,
  vend.vendor_category,
  vend.reporting_category,
  vend.termname,
  apbpmt.paymentdate,
  aprhpay.state,
  aprd.accountno,
  coa.title,
  apbpmt.amount,
  aprd.itemid,
  aprd.asset_id,
  aprh.docnumber,
  aprh.recordid,
  department.departmentid,
  department.department_type,
  department.state_id,
  department.title          as department_title,
  case
    when aprd.accountno = '2014' and aprd.itemid = 'A1301' then '2014-a1301'
    when aprd.accountno = '1301'                          then '1301'
    else 'other'
  end as is_1301_or_2014_w_a1301,
  to_char(date_trunc('month', dateadd(month, -1, current_date)), 'yyyy-mm')    as prior_month_year,
  to_char(last_day(date_trunc('month', dateadd(month, -1, current_date))), 'dd') as last_day_of_prior_month,
  ceil(
    to_number(
      to_char(
        last_day(date_trunc('month', dateadd(month, -1, current_date))),
        'dd'
      )
    ) / 7
  )                                                                          as weeks_in_prior_month,
  week(current_date)                                                        as current_week_of_year,
  month(date_trunc('month', current_date) - interval '1 month')             as prior_month
from
  analytics.intacct.apbillpayment  apbpmt
  left join analytics.intacct.aprecord  aprh     on apbpmt.recordkey = aprh.recordno
                                               and aprh.recordtype in ('apbill','apadjustment')
  left join analytics.intacct.apdetail  aprd     on apbpmt.paiditemkey = aprd.recordno
                                               and aprh.recordno = aprd.recordkey
  left join analytics.intacct.vendor    vend     on aprh.vendorid = vend.vendorid
  left join analytics.intacct.glaccount coa      on aprd.accountno = coa.accountno
  left join analytics.intacct.aprecord  aprhpay  on apbpmt.paymentkey = aprhpay.recordno
  left join analytics.intacct.department department on aprd.departmentid = department.departmentid
where
  apbpmt.paymentkey    = apbpmt.parentpymt
  and aprhpay.recordtype = 'appayment'


;;
  }

  measure: count {
    type: count
    drill_fields: [account,account_name,vendor_id,vendor_name,vendor_type, vendor_category, amount, payment_date,asset_id,invoice_number,po_number,
      departmentid,department_type,state_id,department_title]
  }
  dimension:  pk {
    type: number
    primary_key: yes
    sql: ${TABLE}.pk;;
  }
  dimension:  diversity_classification {
    type: string
    sql: ${TABLE}.diversity_classification;;
  }

  dimension:  payment_type {
    type: string
    sql: ${TABLE}."PAYMENT_TYPE";;
  }
  dimension:  departmentid {
    type: string
    sql: ${TABLE}."DEPARTMENTID";;
  }
  dimension:  prbatch {
    type: string
    sql: ${TABLE}."PRBATCH";;
  }
  dimension:  department_type {
    type: string
    sql: ${TABLE}."DEPARTMENT_TYPE";;
  }
  dimension:  state_id {
    type: string
    sql: ${TABLE}."STATE_ID";;
  }
  dimension:  is_1301_or_2014_w_A1301 {
    type: string
    sql: ${TABLE}."IS_1301_OR_2014_W_A1301";;
  }
  dimension:  department_title {
    type: string
    sql: ${TABLE}."DEPARTMENT_TITLE";;
  }
  dimension: sold_assets {
    type: string
    sql: ${TABLE}."SOLD_ASSETS" ;;
  }

  dimension: core_vs_other {
    type: string
    sql: ${TABLE}."CORE_VS_OTHER" ;;
  }

dimension:  item_id {
  type: string
  sql: ${TABLE}."ITEMID";;
}
  dimension: related_parties {
    type: string
    sql: CASE WHEN ${TABLE}."VENDORID" in
        ('V28634',
'V34092',
'V28378',
'V34070',
'V32244',
'V12921',
'V32329',
'V12047',
'V34067',
'V12012',
'V30253',
'V12737',
'V12803',
'V29796',
'V11807',
'V27328',
'V11839',
'V11826',
'V27270'
        ) then 'related'


      else 'other' end;;
  }

  dimension: today_date {
    type: date
    sql: DATE(GETDATE()) ;;
  }

  dimension: weeks_in_prior_month {
    type: number
    sql: ${TABLE}."WEEKS_IN_PRIOR_MONTH";;
    }

  dimension: current_week_of_year {
    type: number
    sql: ${TABLE}."CURRENT_WEEK_OF_YEAR";;
  }
  # measure: weeks_in_prior_month2 {
  #   type: number
  #   sql: ${TABLE}."WEEKS_IN_PRIOR_MONTH";;
  # }
  dimension: vendor_id {
    type: string

    sql: ${TABLE}."VENDORID";;
  }

  dimension: vendor_name {
    type: string

    sql: ${TABLE}."NAME" ;;
  }

  dimension: vendor_type {
    type: string
    sql: ${TABLE}."VENDTYPE" ;;
  }

  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }

  dimension: reporting_category {
    type: string
    sql: ${TABLE}."REPORTING_CATEGORY" ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}."TERMNAME" ;;
  }

  dimension: payment_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."PAYMENTDATE" ;;
  }

#   dimension_group: week {
#   type: time
#   timeframes: [
#     raw,
#     week
#   ]
#   sql: ${TABLE}."PAYMENTDATE";;

# }

  dimension_group: submit_date {
    type: time
    convert_tz: no
    sql: ${TABLE}."PAYMENTDATE" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."RECORDID" ;;
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."DOCNUMBER" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: account {
    type: string

    sql: ${TABLE}."ACCOUNTNO" ;;
  }

  dimension: account_name {
    type: string

    sql: ${TABLE}."TITLE" ;;
  }

  dimension: account_v2 {
    type: string
    sql: case when ${account} = '2014' then trim(right(${item_id},4))
              when ${account} <> '2013' then ${account}
              when ${account} = '2013' then null
              else null end;;
  }


  dimension: key_2 {
    type: string
    sql: ${account} ;;
  }

dimension: submit_dt_month {
  type: date
  sql: date_trunc(month,${submit_date_date}::date)   ;;
}


  dimension: key {
    type:  string
    # primary_key: yes
    sql: iff(${item_id} is null,${account},${account}||'-'||${item_id}||'-'||${account_v2}) ;;
  }

  dimension: last_year_ytd_flag {
    type: yesno
    sql:
    CASE
      WHEN ${submit_date_date} BETWEEN DATE_TRUNC('year', CURRENT_DATE::DATE - INTERVAL '1 year')
        AND DATE_TRUNC('day', CURRENT_DATE::DATE - INTERVAL '1 year')
      THEN TRUE
      ELSE FALSE
    END ;;
  }

  dimension: is_current_week {
    type: yesno
    sql:
      CASE
        WHEN DATE_TRUNC('week', ${submit_date_date}::DATE) = DATE_TRUNC('week', CURRENT_DATE::DATE)
        THEN TRUE
        ELSE FALSE
      END ;;
  }

  dimension: is_current_week_last_year {
    type: yesno
    sql:
      CASE
        WHEN DATE_TRUNC('week', ${submit_date_date}::DATE) = DATE_TRUNC('week', CURRENT_DATE::DATE - INTERVAL '1 year')
        THEN TRUE
        ELSE FALSE
      END ;;
  }
  dimension: percent_threshold {
    label: "Percent Goal Threshold"
    type: string

    sql:
    CASE
      WHEN ${diversity_classification} in ('DVBE - Disabled Veteran Owned Business' ,'SDVBE - Service-Disabled Veteran Owned Business') THEN '5%'
      WHEN ${diversity_classification} = 'MBE - Minority Business Enterprise' THEN '5%'
      WHEN ${diversity_classification} = 'VBE - Veteran Owned Businesses' THEN '6%'
      WHEN ${diversity_classification} = 'WBE - Woman Business Enterprise'  THEN '5%'
      ELSE '0%'
    END ;;
  }

  dimension: threshold {
    label: "Goal Threshold"
    type: number
    value_format_name: usd_0
    sql:
    CASE
      WHEN ${diversity_classification} in ('DVBE - Disabled Veteran Owned Business' ,'SDVBE - Service-Disabled Veteran Owned Business') THEN 90000
      WHEN ${diversity_classification} = 'MBE - Minority Business Enterprise' THEN 90000
      WHEN ${diversity_classification} = 'VBE - Veteran Owned Businesses' THEN 108000
      WHEN ${diversity_classification} = 'WBE - Woman Business Enterprise'  THEN 90000
      ELSE 0
    END ;;
  }

  dimension: contract {
    label: "Div Contract Name"
    type: string
    sql:
    CASE
      WHEN ${diversity_classification} in ('DVBE - Disabled Veteran Owned Business' ,'SDVBE - Service-Disabled Veteran Owned Business') THEN 'SDVOSB - Service-Disabled Veteran-Owned Small Business'
      WHEN ${diversity_classification} = 'MBE - Minority Business Enterprise' THEN 'SDB - Small Disadvantaged Business'
      WHEN ${diversity_classification} = 'VBE - Veteran Owned Businesses' THEN 'VOSB - Veteran-Owned Small Business'
      WHEN ${diversity_classification} = 'WBE - Woman Business Enterprise'  THEN 'WOSB - Women-Owned Small Business'
      ELSE 'N/A'
    END ;;
  }



#dimension: vendor_status  {
  #type: string
  #sql: ytd_vendor_walk.vendor_status ;;
#}


  # measure: weeks_in_months {
  #   type: number
  #   sql: COUNT(DISTINCT DATE_TRUNC('week', ${TABLE}."PAYMENTDATE")) ;;
  #   # Replace ${date_field} with the appropriate field representing dates in your dataset
  #   # This dimension calculates the number of distinct weeks in the current month
  #   # It uses the DATE_TRUNC function to truncate dates to the week and counts the distinct weeks

  #   # sql_trigger_value: SELECT MAX(DATE_TRUNC('month', your_date_column)) FROM your_table_name ;;
  #   # # Replace your_date_column and your_table_name with the appropriate column and table names
  #   # # This SQL trigger ensures Looker reevaluates the calculation when the month changes
  # }
  # measure: weeks_in_prior_month {
  #   type: number
  #   sql: TIMESTAMP_DIFF(DATE_TRUNC('month', CURRENT_DATE), DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1' MONTH), WEEK) ;;
  #   # This measure calculates the number of weeks in the prior month
  #   # It uses TIMESTAMP_DIFF to calculate the difference in weeks between the current month and the previous month

  #   # sql_trigger_value: SELECT MAX(DATE_TRUNC('month', your_date_column)) FROM your_table_name ;;
  #   # # Replace your_date_column and your_table_name with the appropriate column and table names
  #   # # This SQL trigger ensures Looker reevaluates the calculation when the data changes
  # }

  measure: total_amount_prior_month {
    type: sum
    sql: CASE WHEN DATE_TRUNC('month', ${TABLE}."PAYMENTDATE") = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1' MONTH)
      THEN ${TABLE}."AMOUNT" ELSE NULL END ;;
  }
  # measure: amount {
  #   type: sum
  #   value_format: "#,##0.00"
  #   sql: ${TABLE}."Amount" ;;
  # }

  # measure: amount {
  #   type: number
  #   value_format: "#,##0.00"
  #   sql: ${TABLE}."AMOUNT" ;;
  # }

  # measure: amount {
  #   type: number
  #   sql: ${TABLE}."AMOUNT" ;;
  # }

 measure: amount {
    type: sum
  ##value_format: "$#,##0;($#,##0);-"
    drill_fields: [account,account_name,vendor_id,vendor_name,vendor_type,diversity_classification, vendor_category, amount, payment_date,payment_type, asset_id,invoice_number,po_number,
      departmentid,department_type,state_id,department_title]
    sql: ${TABLE}."AMOUNT"  ;;
  }


  measure: avg_spend_per_account_monthly {
    type: average
    sql: ${TABLE}."AMOUNT"
    sql_always_where: ${TABLE}."ACCOUNTNO" >= (current_date - INTERVAL '12' MONTH)
    timeframes: [month];;
}




  measure: ytd {
    label: "2026 YTD"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [spend_summary_detail*]
    filters: [submit_date_date: "this year",
      is_current_week: "no"]
  }


  measure: prior_ytd {
    label: "2025 YTD"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [spend_summary_detail*]
    filters: [last_year_ytd_flag: "yes",
      is_current_week: "no",
      is_current_week_last_year: "no",
      account: "-2515,-2508,-8106,-2425"]
  }

  measure: qtd {
    label: "QTD"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [spend_summary_detail*]
    filters: [submit_date_date: "this quarter",
      is_current_week: "no"]
  }

  measure: mtd {
    label: "MTD"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [spend_summary_detail*]
    filters: [submit_date_date: "this month",
      is_current_week: "no"]
  }

  measure: prior_mtd {
    label: "Prior Month Spend"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [spend_summary_detail*]
    filters: [submit_date_date: "last month",
      is_current_week: "no"]
  }

  measure: current_week {
    label: "Current Wk"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [spend_summary_detail*]
    filters: [submit_date_date: "this week"]
  }

  measure: prior_week {
    label: "Prior Wk"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [spend_summary_detail*]
    filters: [submit_date_date: "last week",
      is_current_week: "no"]
  }

  measure: prior_year {
    label: "Prior Yr Total"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [spend_summary_detail*]
    filters: [submit_date_date: "last year",
      account: "-2515,-2508,-8106,-2425"]
  }

  measure: run_rate_2026 {
    label: "2026 Run Rate"
    value_format_name: usd_0
    type: sum
    sql: (${TABLE}."AMOUNT"/(datediff(day,'2025-12-31',current_date)))*365 ;;
    filters: [submit_date_date: "this year",
      is_current_week: "no"]
  }

  measure: run_rate_qtr {
    label: "Q2'26 Run Rate"
    value_format_name: usd_0
    type: sum
    sql: (${TABLE}."AMOUNT"/(datediff(day,'2026-03-31',current_date)))*91 ;;
    filters: [submit_date_date: "this quarter",
      is_current_week: "no"]
  }

  measure: ytd_inactive_vendors {
    label: "Inactive Vendors"
    value_format_name: usd_0
    type: sum
    sql: -${TABLE}."AMOUNT" ;;
    drill_fields: [spend_summary_detail*]
    filters: [last_year_ytd_flag: "yes",
      is_current_week: "no",
      is_current_week_last_year: "no",
      account: "-2515,-2508,-8106,-2425",
      ytd_vendor_walk.vendor_status: "Inactive Vendor"]
  }

  measure: ytd_new_vendors {
    label: "New Vendors"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [spend_summary_detail*]
    filters: [submit_date_date: "this year",
      is_current_week: "no",
      ytd_vendor_walk.vendor_status: "New Vendor"]
  }








  set: drill_detail {
    fields: [
      pk,
      vendor_id,
      vendor_name,
      vendor_type,
      vendor_category,
      reporting_category,
      terms,
      payment_date,
      submit_date_date,
      state,
      account,
      account_name,
      amount, submit_date_time,total_amount_prior_month, today_date, weeks_in_prior_month, current_week_of_year,related_parties,item_id
    ]
  }


  set: spend_summary_detail {
    fields: [
      spend_summary_mapping.mapping_lv_1,
      spend_summary_mapping.mapping_lv_2,
      spend_summary_mapping.mapping_lv_3,
      submit_date_date,
      vendor_id,
      vendor_name,
      vendor_type,
      vendor_category,
      account,
      item_id,
      account_name,
      amount
    ]
  }

#   filter: date_filter {
#     convert_tz: no
#     type: date
#   }
 }

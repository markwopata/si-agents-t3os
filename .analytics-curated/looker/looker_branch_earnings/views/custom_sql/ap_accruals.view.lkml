view: ap_accruals {
  derived_table: {
    sql: select
       row_number() over (order by GLE.DEPARTMENT) as pk,
       GLE.DEPARTMENT                      market_id,
       GLE.ACCOUNTNO                       ,
       GLA.TITLE                           account,
       GLE.ENTRY_DATE::DATE                gl_date,
       APR.WHENDUE::DATE                   due_date,
       GLB.BATCH_TITLE                     ,
       GLE.DESCRIPTION                     description,
       split_part(GLE.DESCRIPTION, ';', 7) po_number,
       split_part(GLE.DESCRIPTION, ';', 9) bill_number,
       split_part(GLE.DESCRIPTION, ';', 3) vendor_id,
       V.NAME                              vendor_name,
       case
           when split_part(GLE.DESCRIPTION, ';', 1) = 'APAccrual'
               then 'Accrual'
           else 'Reversed'
           end                             ap_accrual_entry,
       case
           when APR.WHENPAID <= GLE.ENTRY_DATE
               then 'Paid'
           when APR.WHENPOSTED <= GLE.ENTRY_DATE
               then 'Posted'
           else 'Pending'
           end                             invoice_status,
       GLE.TR_TYPE                         ,
       (GLE.AMOUNT * -TR_TYPE)             amount,
       RU.RECORD_URL                       glbatch_url,
       ru2.record_url                      podoc_url,
       ru3.RECORD_URL                      apbill_url

      from ANALYTICS.INTACCT.GLENTRY GLE
      join ANALYTICS.INTACCT.GLBATCH GLB
      on GLE.BATCHNO = GLB.RECORDNO
      join ANALYTICS.PUBLIC.BRANCH_EARNINGS_DDS_SNAP beds
      on split_part(BEDS.PK, 'GL', 2) = GLE.RECORDNO::varchar
      join ANALYTICS.GS.PLEXI_BUCKET_MAPPING B
      on GLE.ACCOUNTNO = B.SAGE_GL
      left join ANALYTICS.INTACCT.RECORD_URL RU
      on GLB.RECORDNO = RU.RECORDNO
      and RU.INTACCT_OBJECT = 'GLBATCH'
      join ANALYTICS.INTACCT.GLACCOUNT GLA
      on GLE.ACCOUNTNO = GLA.ACCOUNTNO
      left join ANALYTICS.INTACCT.PODOCUMENT PD
      on PD.DOCNO = split_part(GLE.DESCRIPTION, ';', 7)
      and PD.DOCPARID = 'Purchase Order'
      and PD.CUSTVENDID = split_part(GLE.DESCRIPTION, ';', 3)
      left join ANALYTICS.INTACCT.RECORD_URL RU2
      on PD.RECORDNO = RU2.RECORDNO
      and RU2.INTACCT_OBJECT = 'PODOCUMENT'
      left join ANALYTICS.INTACCT.APRECORD APR
      on split_part(GLE.DESCRIPTION, ';', 9) = APR.RECORDID
      and APR.RECORDTYPE = 'apbill'
      and APR.VENDORID = split_part(GLE.DESCRIPTION, ';', 3)
      left join ANALYTICS.INTACCT.RECORD_URL RU3
      on APR.RECORDNO = RU3.RECORDNO
      and RU3.INTACCT_OBJECT = 'APBILL'
      left join ANALYTICS.INTACCT.VENDOR V
      on split_part(GLE.DESCRIPTION, ';', 3) = V.VENDORID
      where GLE.STATE = 'Posted'
      and GLE.ACCOUNTNO != '6300'
      and (GLE.BATCHTITLE ilike ('%AP Accrual%')
      or GLE.BATCHTITLE ilike ('%INITIAL LIVE ACCRUAL ENTRY%')
      or GLE.BATCHTITLE ilike ('%ADJUSTMENT FOR CONVERTED NON RECEIPTS%'))
      and gle.ENTRY_DATE >= '2021-09-30'
      and market_id not like 'R%'
      and market_id not in ('ACCTG','CORP1','CUSTSR','HUMRES','INTECH','MRKTG','NEWMRKT','SERVICE','LEGAL')
      order by po_number desc, bill_number, gl_date
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: accountno {
    label: "GL Code"
    type: string
    sql: ${TABLE}."ACCOUNTNO" ;;
  }

  dimension: account {
    label: "GL Account"
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: gl_date {
    label: "GL Date"
    type: date
    convert_tz: no
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: pk {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK" ;;
  }

  dimension_group: gl_date_entry {
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
    sql: CAST(${TABLE}."GL_DATE" AS TIMESTAMP_NTZ ;;
  }

  dimension: due_date {
    label: "Due Date"
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: vendor_id {
    label: "Vendor ID"
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: batch_title {
    type: string
    sql: ${TABLE}."BATCH_TITLE" ;;
  }

  dimension: po_number {
    label: "PO Number"
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
    #html: <u><a style="color:blue" href ="{{podoc_url._value}}"target="_blank">{{value}}</a></u> ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
    #html: <u><a style="color:blue" href ="{{apbill_url._value}}"target="_blank">{{value}}</a></u> ;;
  }

  dimension: invoice_status {
    type: string
    sql: ${TABLE}."INVOICE_STATUS" ;;
  }

  # dimension: url_sage {
  #   label: "Intacct"
  #   type: string
  #   #hidden: yes
  #   html: {% if value == null %}
  #   <font style="bold ">Pending</font>
  #   {% else %}
  #   <font color="blue "><u><a href = "{{ value }}" target="_blank">Intacct Link</a></font>
  #   {% endif %};;
  #   sql: ${TABLE}."URL_SAGE" ;;
  # }

  dimension: glbatch_url {
    label: "GLBatch URL"
    type: string
    html: {% if value == null %}
          <font style="bold ">Pending</font>
          {% else %}
          <font color="blue "><u><a href = "{{ value }}" target="_blank">Intacct GL Link</a></font>
          {% endif %};;
    sql: ${TABLE}."GLBATCH_URL" ;;
  }

  dimension: podoc_url {
    label: "PO Doc URL"
    type: string
    html: {% if value == null %}
          <font style="bold ">Pending</font>
          {% else %}
          <font color="blue "><u><a href = "{{ value }}" target="_blank">Intacct PO Link</a></font>
          {% endif %};;
    sql: ${TABLE}."PODOC_URL" ;;
  }

  dimension: apbill_url {
    label: "AP Bill URL"
    type: string
    html: {% if value == null %}
          <font style="bold ">Pending</font>
          {% else %}
          <font color="blue "><u><a href = "{{ value }}" target="_blank">Intacct AP Bill Link</a></font>
          {% endif %};;
    sql: ${TABLE}."APBILL_URL" ;;
  }

  dimension: tr_type {
    label: "Transaction Type Code"
    type: number
    sql: ${TABLE}."TR_TYPE" ;;
  }

  dimension: ap_accrual_entry {
    label: "Accrual/Reversal Code"
    type: string
    sql: ${TABLE}."AP_ACCRUAL_ENTRY" ;;

  }

  measure: amount {
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."AMOUNT" ;;
  }

  measure: curr_month_accrual {
    label: "Current Month Accrual"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."AMOUNT" ;;
    filters: [ap_accrual_entry: "Accrual"]
  }

  measure: curr_month_reversal {
    label: "Current Month Reversal"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."AMOUNT" ;;
    filters: [ap_accrual_entry: "Reversed"]
  }

  dimension: months_open {
    type: string
    sql: datediff(months, ${revmodel_market_rollout_conservative.branch_earnings_start_month_raw}, ${plexi_periods.date})+1 ;;
  }

  dimension: greater_twelve_months_open {
    label: "Markets Greater Than 12 Months Open?"
    type: yesno
    sql: ${months_open} >= 12;;
  }

  set: detail {
    fields: [
      market_id,
      accountno,
      account,
      gl_date,
      due_date,
      vendor_id,
      vendor_name,
      description,
      po_number,
      bill_number,
      invoice_status,
      tr_type,
      ap_accrual_entry,
      amount
    ]
  }

}

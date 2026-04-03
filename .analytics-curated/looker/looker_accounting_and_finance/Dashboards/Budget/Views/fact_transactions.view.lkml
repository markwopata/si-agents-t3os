view: fact_transactions {
  sql_table_name: "ANALYTICS"."CORPORATE_BUDGET"."FACT_TRANSACTIONS";;


  dimension_group: _load_timestamp {
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
    sql: ${TABLE}."_LOAD_TIMESTAMP" ;;
  }

  dimension: amount_credit {
    type: number
    sql: ${TABLE}."AMOUNT_CREDIT" ;;
  }

  dimension: amount_debit {
    type: number
    sql: ${TABLE}."AMOUNT_DEBIT" ;;
  }

  dimension: amount_net {
    type: number
    sql: ${TABLE}."AMOUNT_NET" ;;
  }

  dimension: fact_type {
    type: string
    sql: ${TABLE}."FACT_TYPE" ;;
  }

  dimension: fk_department {
    type: number
    sql: ${TABLE}."FK_DEPARTMENT" ;;
  }

  dimension: fk_expense_line {
    type: number
    sql: ${TABLE}."FK_EXPENSE_LINE" ;;
  }

  dimension: fk_budget_unit {
    type: number
    sql: ${TABLE}."FK_BUDGET_UNIT" ;;
  }

  dimension: pk_transactions {
    primary_key: yes
    type: number
    sql: ${TABLE}."PK_TRANSACTIONS" ;;
  }

  dimension: post_date {
    type: string
    sql: ${TABLE}."POST_DATE" ;;
  }

  dimension: sk_glbatch_recordno {
    type: number
    sql: ${TABLE}."SK_GLBATCH_RECORDNO" ;;
  }

  dimension: sk_glentry_recordno {
    type: number
    sql: ${TABLE}."SK_GLENTRY_RECORDNO" ;;
  }

  dimension: sk_glresolve_recordno {
    type: string
    sql: ${TABLE}."SK_GLRESOLVE_RECORDNO" ;;
  }

  dimension: trx_credit {
    type: number
    sql: ${TABLE}."TRX_CREDIT" ;;
  }

  dimension: trx_debit {
    type: number
    sql: ${TABLE}."TRX_DEBIT" ;;
  }

  dimension: trx_net {
    type: number
    sql: ${TABLE}."TRX_NET" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: originator_name {
    type: string
    sql: ${TABLE}."ORIGINATOR_NAME" ;;
  }

  dimension: approver_name {
    type: string
    sql: ${TABLE}."APPROVER_NAME" ;;
  }

  dimension: header_memo {
    type: string
    sql: ${TABLE}."HEADER_MEMO" ;;
  }

  dimension: line_memo {
    type: string
    sql: ${TABLE}."LINE_MEMO" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: ap_bill_url {
    type: string
    sql: ${TABLE}."AP_BILL_URL" ;;
    html:
    {% unless value == empty %}
    <a href="{{value}} target="_blank""><img src="https://www.concursolutions.com/favicon.ico" width="16" height="16"> Invoice</a>
    {% endunless %};;
  }

  dimension: is_published {
    description: "Flag denoting if Accounting has closed the period containing the record"
    type: yesno
    sql: ${TABLE}."IS_PUBLISHED" ;;
  }

  dimension: journal {
    type: string
    sql: ${TABLE}."JOURNAL" ;;
  }

  dimension: approved_budget {
    type: number
    value_format_name: usd
    sql: ${TABLE}."APPROVED_BUDGET" ;;
  }

  dimension: q_1_budget {
    type: number
    value_format_name: usd
    sql: ${TABLE}."Q_1_BUDGET" ;;
  }

  dimension: q_2_budget {
    type: number
    value_format_name: usd
    sql: ${TABLE}."Q_2_BUDGET" ;;
  }

  dimension: q_3_budget {
    type: number
    value_format_name: usd
    sql: ${TABLE}."Q_3_BUDGET" ;;
  }

  dimension: q_4_budget {
    type: number
    value_format_name: usd
    sql: ${TABLE}."Q_4_BUDGET" ;;
  }

  dimension: unique_id {
    type:  string
    sql: ${TABLE}."UNIQUE_ID" ;;
  }

  dimension: transaction_reference {
    type:  string
    sql: ${TABLE}."TRANSACTION_REFERENCE" ;;
  }

  dimension: sage_reference {
    type:  string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: reference {
    type:  string
    sql: CASE
          WHEN ${TABLE}."JOURNAL" = 'APA' THEN
            ${TABLE}."TRANSACTION_REFERENCE"
          WHEN ${TABLE}."BILL_NUMBER" IS NOT NULL THEN
            ${TABLE}."BILL_NUMBER"
          WHEN ${TABLE}."DOCNO" IS NOT NULL THEN
            ${TABLE}."DOCNO"
          ELSE
            NULL
        END;;
  }

  dimension: sage_url {
    type: string
    sql: ${TABLE}."SAGE_URL" ;;
    html:
    {% unless value == empty %}
    <a href="{{value}}" target="_blank"><img src="https://www.concursolutions.com/favicon.ico" width="16" height="16"> PO</a>
    {% endunless %};;
  }

  dimension: document_url {
    type: string
    sql: CASE
          WHEN ${TABLE}."AP_BILL_URL" IS NOT NULL THEN
            ${TABLE}."AP_BILL_URL"
          WHEN ${TABLE}."JOURNAL" IN ('APJ', 'APA') THEN
            ${TABLE}."SAGE_URL"
          ELSE
            NULL
        END;;
    html:
    {% unless value == empty %}
    <a href="{{value}}" target="_blank"><img src="https://www.concursolutions.com/favicon.ico" width="16" height="16"> Invoice or PO Link</a>
    {% endunless %};;
  }

  dimension: docno {
    type: string
    sql: ${TABLE}."DOCNO" ;;
  }

# - - - - - MEASURES - - - - -

  measure: count {
    type: count
    drill_fields: []
  }

  measure: total_amount_debit {
    type: sum
    value_format_name: usd
    sql: ${amount_debit} ;;
    drill_fields: [drill_to_vendor*]
    filters: [fact_type: "Actual"]
  }

  measure: total_amount_credit {
    type: sum
    value_format_name: usd
    sql: ${amount_credit} ;;
    drill_fields: [drill_to_vendor*]
    filters: [fact_type: "Actual"]
  }

  measure: total_amount_net {
    # hidden: yes
    description: "Drills to detail"
    type: sum
    value_format_name: usd
    sql: ${amount_net} ;;
    drill_fields: [transaction_detail*]
    filters: [fact_type: "Actual"]
  }

  measure: total_amount_net_string {
    description: "Same as total_amount_net but as a string so that the drill visualization uses a table."
    group_item_label: "Total Amount Net - Drill to Vendor"
    label: "Total Amount Net"
    type: string
    value_format_name: usd
    sql: ${total_amount_net} ;;
    drill_fields: [drill_to_vendor*]
  }

  measure: total_amount_net__detail {
    hidden: yes
    description: "Drills to transaction detail"
    label: "Total Amount Net"
    type: sum
    value_format_name: usd
    sql: ${amount_net} ;;
    drill_fields: [transaction_detail*]
  }

  measure: total_amount_net__detail_string {
    description: "Same as total_amount_net__detail but as a string so that the drill visualization uses a table."
    group_item_label: "Total Amount Net - Drill to Detail"
    label: "Total Amount Net"
    type: string
    value_format_name: usd
    sql: ${total_amount_net__detail} ;;
    drill_fields: [transaction_detail*]
  }

  measure: total_budget_amount {
    type: sum
    label: "Total Annual Budget Amount"
    value_format_name: usd_0
    sql: ${approved_budget} ;;
  }

  measure: total_q1_amount_net {
    type: sum
    label: "Total Quarter 1 Amount Net"
    value_format_name: usd
    sql: ${amount_net} ;;
    filters: [dim_date.quarter: "1"]
  }

  measure: total_q2_amount_net {
    type: sum
    label: "Total Quarter 2 Amount Net"
    value_format_name: usd
    sql: ${amount_net} ;;
    filters: [dim_date.quarter: "2"]
  }

  measure: total_q3_amount_net {
    type: sum
    label: "Total Quarter 3 Amount Net"
    value_format_name: usd
    sql: ${amount_net} ;;
    filters: [dim_date.quarter: "3"]
  }

  measure: total_q4_amount_net {
    type: sum
    label: "Total Quarter 4 Amount Net"
    value_format_name: usd
    sql: ${amount_net} ;;
    filters: [dim_date.quarter: "4"]
  }

measure: total_q_1_budget_amount {
    type: sum
    label: "Total Quarter 1 Budget Amount"
    value_format_name: usd_0
    sql: ${q_1_budget} ;;
  }

  measure: total_q_2_budget_amount {
    type: sum
    label: "Total Quarter 2 Budget Amount"
    value_format_name: usd_0
    sql: ${q_2_budget} ;;
  }

  measure: total_q_3_budget_amount {
    type: sum
    label: "Total Quarter 3 Budget Amount"
    value_format_name: usd_0
    sql: ${q_3_budget} ;;
  }

  measure: total_q_4_budget_amount {
    type: sum
    label: "Total Quarter 4 Budget Amount"
    value_format_name: usd_0
    sql: ${q_4_budget} ;;
  }

  measure: total_ytd_budget_amount {
    type: sum
    label: "Total YTD Budget Amount"
    value_format_name: usd_0
    sql:
      CASE
        WHEN ${dim_date.max_published_quarter} = 1 THEN
          ${q_1_budget}
        WHEN ${dim_date.max_published_quarter} = 2 THEN
          ${q_1_budget} + ${q_2_budget}
        WHEN ${dim_date.max_published_quarter} = 3 THEN
          ${q_1_budget} + ${q_2_budget} + ${q_3_budget}
        WHEN ${dim_date.max_published_quarter} = 4 THEN
          ${q_1_budget} + ${q_2_budget} + ${q_3_budget} + ${q_4_budget}
        ELSE
          0.00
      END
    ;;
  }

  measure: remaining_deficit {
    label: "Remaining/Deficit"
    type: number
    value_format_name: usd
    sql: ${total_budget_amount} - ${total_amount_net} ;;
  }

  measure: remaining_deficit_ytd {
    label: "Remaining/Deficit YTD"
    type: number
    value_format_name: usd
    sql: ${total_ytd_budget_amount} - ${total_amount_net} ;;
  }

  measure: q1_remaining_deficit {
    label: "Quarter 1 Remaining/Deficit"
    type: number
    value_format_name: usd
    sql: ${total_q_1_budget_amount} - ${total_q1_amount_net} ;;
  }

  measure: q2_remaining_deficit {
    label: "Quarter 2 Remaining/Deficit"
    type: number
    value_format_name: usd
    sql: ${total_q_2_budget_amount} - ${total_q2_amount_net} ;;
  }

  measure: q3_remaining_deficit {
    label: "Quarter 3 Remaining/Deficit"
    type: number
    value_format_name: usd
    sql: ${total_q_3_budget_amount} - ${total_q3_amount_net} ;;
  }

  measure: q4_remaining_deficit {
    label: "Quarter 4 Remaining/Deficit"
    type: number
    value_format_name: usd
    sql: ${total_q_4_budget_amount} - ${total_q4_amount_net} ;;
  }

  measure: percent_of_ytd_budget_spent {
    type: number
    label: "Percent of YTD Budget Spent"
    value_format_name: percent_0
    # all of this is to format the value in such a way to do conditional formatting on it in a tile
    # sql:
    # IFF(${total_amount_net} = 0 and ${total_budget_amount} = 0, 0, coalesce(${total_amount_net} / NULLIFZERO(${total_budget_amount}), -1))  ;;
    sql:
    CASE
    WHEN ${total_ytd_budget_amount} = 0 and ${total_amount_net} < 0 THEN 0
    WHEN ${total_ytd_budget_amount} = 0 and ${total_amount_net} > 0 THEN -1
    WHEN ${total_ytd_budget_amount} = 0 THEN 0
    ELSE ${total_amount_net} / ${total_ytd_budget_amount} END;;
    html:
    {% if total_ytd_budget_amount._value == 0 %}
    N/A - $0 Budget
    {% else %}
    {{rendered_value}}
    {% endif %}
    ;;
  }

  measure: percent_of_budget_spent {
    type: number
    label: "Percent of Budget Spent"
    value_format_name: percent_0
    # all of this is to format the value in such a way to do conditional formatting on it in a tile
    # sql:
    # IFF(${total_amount_net} = 0 and ${total_budget_amount} = 0, 0, coalesce(${total_amount_net} / NULLIFZERO(${total_budget_amount}), -1))  ;;
    sql:
    CASE
    WHEN ${total_budget_amount} = 0 and ${total_amount_net} < 0 THEN 0
    WHEN ${total_budget_amount} = 0 and ${total_amount_net} > 0 THEN -1
    WHEN ${total_budget_amount} = 0 THEN 0
    ELSE ${total_amount_net} / ${total_budget_amount} END;;
    html:
    {% if total_budget_amount._value == 0 %}
    N/A - $0 Budget
    {% else %}
    {{rendered_value}}
    {% endif %}
    ;;
  }

  # - - - - - SETS - - - - -

  set: transaction_detail {
    fields:  [
      post_date,
      unique_id,
      dim_department.sub_department_name,
      dim_department.sub_department_id,
      dim_expense_line.expense_line_name,
      dim_expense_line.gl_mapping,
      vendor_name,
      originator_name,
      line_memo,
      journal,
      reference,
      document_url,
      amount_debit,
      amount_credit]
  }

  set:  drill_to_vendor {
    fields: [
      dim_department.department_name,
      dim_department.sub_department_name,
      dim_department.sub_department_id,
      vendor_name,
      total_amount_net__detail_string
    ]
  }
}

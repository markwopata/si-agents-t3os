
view: fact_company_customer_start {
  sql_table_name: business_intelligence.gold.fact_company_customer_start  ;;


  measure: count {
    type: count

  }

  dimension: company_key {
    hidden: yes
    type: string
    sql: ${TABLE}."COMPANY_KEY" ;;
  }
  measure: new_account_count {
    group_label: "New Account Totals"
    label: "New Account Count"
    type: count_distinct
    sql: ${company_key} ;;
    description: "Total number of new accounts"
    drill_fields: [new_account_detail*]
  }

  measure: new_account_count_current_month {
    group_label: "New Account Totals"
    label: "New Account Count - Current Month"
    type: count_distinct
    sql: CASE WHEN ${new_account_date.is_current_month} THEN ${company_key} ELSE NULL END ;;
    description: "Total number of new accounts in the current month"
    drill_fields: [new_account_detail*]

  }

  measure: new_account_count_prior_month {
    group_label: "New Account Totals"
    label: "New Account Count - Prior Month"
    type: count_distinct
    sql: CASE WHEN ${new_account_date.is_prior_month} THEN ${company_key} ELSE NULL END ;;
    description: "Total number of new accounts in the prior month"
    drill_fields: [new_account_detail*]

  }

  measure: new_account_count_prior_month_to_date {
    group_label: "New Account Totals"
    label: "New Account Count - Prior Month to Date"
    type: count_distinct
    sql: CASE WHEN ${new_account_date.is_prior_month_to_date} THEN ${company_key} ELSE NULL END ;;
    description: "Total number of new accounts in the prior month to date"
    drill_fields: [new_account_detail*]

  }

  measure: total_diff_new_accounts_cm_vs_pmtd {
    group_label: "New Account Totals"
    label: "CM vs PMTD Total New Accounts"
    type: number
    sql: ${new_account_count_current_month} - ${new_account_count_prior_month_to_date} ;;
    html:
    {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% endif %};;
  }



  measure: new_account_cod_count {
    group_label: "New Account Totals"
    label: "COD New Account Count"
    type: count_distinct
    sql: CASE WHEN ${credit_application_type} = 'COD'THEN ${company_key} ELSE NULL END ;;
    description: "Total number of COD new accounts"
    drill_fields: [new_account_detail*]

  }

  measure: new_account_cod_count_filter {
    group_label: "New Account Totals"
    label: "COD New Accounts"
    type: count_distinct
    sql: ${company_key};;
    description: "Total number of COD new accounts"
    filters: [credit_application_type: "COD"]
    drill_fields: [new_account_detail*]
  }

  measure: new_account_cod_count_current_month {
    group_label: "New Account Totals"
    label: "COD New Account Count - Current Month"
    type: count_distinct
    sql: CASE WHEN ${new_account_date.is_current_month} and ${credit_application_type} = 'COD' THEN ${company_key} ELSE NULL END ;;
    description: "Total number of COD new accounts in the current month"
    drill_fields: [new_account_detail*]

  }

  measure: new_account_cod_count_prior_month {
    group_label: "New Account Totals"
    label: "COD New Account Count - Prior Month"
    type: count_distinct
    sql: CASE WHEN ${new_account_date.is_prior_month} and ${credit_application_type} = 'COD' THEN ${company_key} ELSE NULL END ;;
    description: "Total number of COD new accounts in the prior month"
    drill_fields: [new_account_detail*]

  }

  measure: new_account_cod_count_prior_month_to_date {
    group_label: "New Account Totals"
    label: "COD New Account Count - Prior Month to Date"
    type: count_distinct
    sql: CASE WHEN ${new_account_date.is_prior_month_to_date} and ${credit_application_type} = 'COD' THEN ${company_key} ELSE NULL END ;;
    description: "Total number of COD new accounts in the prior month to date"
    drill_fields: [new_account_detail*]

  }



  measure: new_account_credit_count {
    group_label: "New Account Totals"
    label: "Credit New Account Count"
    type: count_distinct
    sql: CASE WHEN ${credit_application_type} = 'Credit' THEN ${company_key} ELSE NULL END ;;
    description: "Total number of Credit new accounts"
    drill_fields: [new_account_detail*]
  }

  measure: new_account_credit_count_filter {
    group_label: "New Account Totals"
    label: "Credit New Accounts"
    type: count_distinct
    sql: ${company_key} ;;
    description: "Total number of Credit new accounts"
    filters: [credit_application_type: "Credit"]
    drill_fields: [new_account_detail*]
  }


  measure: new_account_credit_count_current_month {
    group_label: "New Account Totals"
    label: "Credit New Account Count - Current Month"
    type: count_distinct
    sql: CASE WHEN ${new_account_date.is_current_month} and ${credit_application_type} = 'Credit' THEN ${company_key} ELSE NULL END ;;
    description: "Total number of credit new accounts in the current month"
    drill_fields: [new_account_detail*]

  }

  measure: new_account_credit_count_prior_month {
    group_label: "New Account Totals"
    label: "Credit New Account Count - Prior Month"
    type: count_distinct
    sql: CASE WHEN ${new_account_date.is_prior_month} and ${credit_application_type} = 'Credit' THEN ${company_key} ELSE NULL END ;;
    description: "Total number of credit new accounts in the prior month"
    drill_fields: [new_account_detail*]

  }

  measure: new_account_credit_count_prior_month_to_date {
    group_label: "New Account Totals"
    label: "Credit New Account Count - Prior Month to Date"
    type: count_distinct
    sql: CASE WHEN ${new_account_date.is_prior_month_to_date} and ${credit_application_type} = 'Credit' THEN ${company_key} ELSE NULL END ;;
    description: "Total number of credit new accounts in the prior month to date"
    drill_fields: [new_account_detail*]

  }

  dimension: salesperson_user_key {
    hidden: yes
    type: string
    sql: ${TABLE}."SALESPERSON_USER_KEY" ;;
  }

  dimension: salesperson_key {
    hidden: yes
    type: string
    sql: ${TABLE}."SALESPERSON_KEY" ;;
  }

  dimension: first_account_date_ct_key {
    hidden: yes
    type: string
    sql: ${TABLE}."FIRST_ACCOUNT_DATE_CT_KEY" ;;
  }

  dimension: credit_application_type {
    type: string
    sql: ${TABLE}."CREDIT_APPLICATION_TYPE" ;;
  }

  dimension: new_account_source {
    type: string
    sql: ${TABLE}."FIRST_ACCOUNT_SOURCE" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: is_locked {
    type: yesno
    sql: ${TABLE}."IS_LOCKED" ;;
  }

  dimension_group: _created_recordtimestamp {
    type: time
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
  }

  dimension_group: _updated_recordtimestamp {
    type: time
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
  }

  set: new_account_detail {
    fields: [
      dim_companies_bi.company_and_id_with_na_icon_and_link_int_credit_app,
      new_account_date.date_formatted,
      dim_salesperson_enhanced_historical.rep_home_perm_enh,
      credit_application_type,
      new_account_source,
      notes,
      dim_companies_bi.company_lifetime_rental_status_formatted
    ]
  }


}

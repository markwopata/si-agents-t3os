view: commission_overrides {
  sql_table_name: "RATE_ACHIEVEMENT"."COMMISSION_OVERRIDES_LOOKER" ;;

  dimension: parent_company {
    type: string
    sql: ${TABLE}.parent_company ;; }

  dimension: company_id {
    type: number
    value_format: "0"
    sql: ${TABLE}.COMPANY_ID ;; }

  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;; }

  dimension: national_account {
    type: yesno
    sql: ${TABLE}.national_account_flag ;; }

  dimension: max_rebate_percent {
    type: number
    value_format: "0.00%"
    sql: ${TABLE}.max_rebate_percent ;; }

  dimension: rebate_percent_achieved {
    type: number
    value_format: "0.00%"
    sql: ${TABLE}.rebate_percent_achieved ;; }

  dimension: invoice_id {
    type: number
    value_format: "0"
    sql: ${TABLE}.INVOICE_ID ;; }

  dimension: line_item_id {
    type: number
    primary_key: yes
    value_format: "0"
    sql: ${TABLE}.LINE_ITEM_ID ;; }

  dimension: rental_id {
    type: number
    value_format: "0"
    sql: ${TABLE}.RENTAL_ID ;; }

  dimension: equipment_class_id {
    type: number
    value_format: "0"
    sql: ${TABLE}.EQUIPMENT_CLASS_ID ;; }


  dimension: equipment_class_name {
    type: string
    sql: ${TABLE}.EQUIPMENT_CLASS_NAME ;; }

  # dimension: branch_id {
  #   type: number
  #   value_format: "0"
  #   sql: ${TABLE}.BRANCH_ID ;; }

  dimension: amount {
    type: number
    value_format: "$#,##0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}.AMOUNT ;; }

  dimension: deal_floor {
    type: number
    value_format: "$#,##0"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}.deal_floor ;; }

  dimension: floor_rate {
    type: number
    value_format: "$#,##0"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}.floor_rate ;; }

  dimension: gross_profit_margin {
    type: number
    value_format: "$#,##0"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}.gross_profit_margin ;; }

  dimension: gross_profit_margin_pct {
    type: number
    value_format: "#,##0.00%"         # Dollars with 2 decimals ($123.00)
    sql: ROUND(${TABLE}.gross_profit_margin / ${TABLE}.AMOUNT );; }

  dimension: billing_type {
    type: string
    sql: ${TABLE}.billing_type ;; }

  dimension: deal_rate_created_by {
    type: string
    sql: ${TABLE}.deal_rate_created_by ;; }

  dimension: salesperson_id {
    type: string
    sql: ${TABLE}."SALESPERSON_ID" ;; }

  dimension: salesperson_email_address {
    type: string
    sql: ${TABLE}."SALESPERSON_EMAIL_ADDRESS" ;; }

  dimension: salesperson_name {
    type: string
    sql: ${TABLE}."SALESPERSON_NAME" ;; }

  dimension: cycle_length {
    type: number
    sql: ${TABLE}.cycle_length ;; }

  dimension: company_rate_current {
    type: yesno
    sql: ${TABLE}.company_rate_current ;; }

  dimension: location_rate_current {
    type: yesno
    sql: ${TABLE}.location_rate_current ;; }

  dimension: effective_four_week_rate {
    type: number
    value_format: "$#,##0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}.effective_four_week_rate ;; }

  dimension: company_rate {
    type: number
    value_format: "$#,##0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}.company_rate ;; }

  dimension: location_rate {
    type: number
    value_format: "$#,##0.00"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}.location_rate ;; }

  dimension: current_deal_rate_per_month {
    type: number
    value_format: "$#,##0"         # Dollars ($123)
    sql: ${TABLE}.current_deal_rate_per_month ;; }

  dimension_group: deal_rate_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.deal_rate_created_date ;; }

  dimension_group: billing_approved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.billing_approved_date ;; }

  dimension_group: company_effective_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.company_effective_start_date ;; }

  dimension_group: location_effective_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.location_effective_start ;; }

  dimension_group: company_rate_achievement_expiration_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.company_rate_achievement_expiration ;; }

  dimension_group: location_rate_achievement_expiration_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.location_rate_achievement_expiration ;; }

  dimension_group: company_original_expiration_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.company_original_expiration ;; }

  dimension_group: location_original_expiration_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.location_original_expiration_date ;; }

  # dimension: company_contract_length_in_years {
  #   type: number
  #   value_format: "#,##0.00"
  #   sql: ${TABLE}.company_contract_length_in_years ;; }

  dimension: company_or_location_contract_length_in_years {
    type: number
    value_format: "#,##0.00"
    sql: CASE
    WHEN ${location_rate_agreement_greater_1_yr} = TRUE THEN location_contract_length_in_years
    WHEN ${company_rate_agreement_greater_1_yr} = TRUE THEN company_contract_length_in_years
      ELSE null
      END ;; }

  dimension: active_deal_rate_override {
    type: yesno
    sql: ${TABLE}.active_deal_rate_override ;; }

  dimension: invoice_below_floor {
    type: yesno
    sql: ${TABLE}.invoice_below_floor ;; }

  dimension: company_commission_exception {
    type: yesno
    sql: ${TABLE}.company_commission_exception ;; }

  dimension: commission_override_request {
    type: yesno
    sql: ${TABLE}.commission_override_request ;; }

  dimension: company_rate_agreement_greater_1_yr {
    type: yesno
    # drill_fields: [detail*, admin_link_to_invoice,date_created_date,invoices_rebates.paid_date,Days_from_date_paid_to_billing_approved_date]
    sql: ${TABLE}.company_rate_agreement_greater_1_yr ;; }

  dimension: location_rate_agreement_greater_1_yr {
    type: yesno
    sql: ${TABLE}.location_rate_agreement_greater_1_yr ;; }

  dimension: company_or_location_rate_agreement_greater_1_yr {
    type: yesno
    sql: CASE
    WHEN ${company_rate_agreement_greater_1_yr} = TRUE OR ${location_rate_agreement_greater_1_yr} = TRUE THEN TRUE
      ELSE FALSE
      END ;; }

  dimension: current_deal_rate_with_high_time_ute {
    type: yesno
    sql: ${TABLE}.current_deal_rate_with_high_time_ute ;; }


  dimension: has_at_least_one_override {
    type: yesno
    sql: ${TABLE}.has_at_least_one_override ;; }

  dimension: high_ute_class {
    type: yesno
    sql: ${TABLE}.high_ute_class ;; }


  dimension: district {
    type: string
    sql: ${TABLE}.district ;; }

  dimension: region_name {
    type: string
    sql: ${TABLE}.region_name ;; }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;; }

  dimension: market {
    type: string
    sql: ${TABLE}.market_name ;; }

  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;; }

  dimension: project_id {
    type: number
    value_format: "0"
    sql: ${TABLE}.project_id ;; }

  dimension: project_name {
    type: string
    sql: ${TABLE}.project_name ;; }

  measure: total_gross_profit_margin {
    type: sum
    value_format: "$#,##0"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}.gross_profit_margin  ;; }

  measure: last_three_months_district_time_ute {
    type: average
    value_format: "#,##0.00%"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}.last_three_months_district_time_ute  ;; }



  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${TABLE}."DISTRICT" in ({{ _user_attributes['district'] }}) OR ${TABLE}."REGION_NAME" in ({{ _user_attributes['region'] }}) OR ${TABLE}."MARKET_ID" in ({{ _user_attributes['market_id'] }}) ;;
  }

  dimension: achieved_rate_as_pct_of_floor{
    type: number
    sql: ${TABLE}.achieved_rate_as_pct_of_floor ;;
    value_format: "0.00%"
  }

  dimension: current_company_commission_exception{
    type: yesno
    sql: ${TABLE}.current_company_commission_exception ;;
  }


  parameter: pivot_field {
    type: string
    default_value: "Region"
    allowed_value: {
      label: "District"
      value: "District"
    }
    allowed_value: {
      label: "Region"
      value: "Region"
    }
    allowed_value: {
      label: "Market"
      value: "Market"
    }
    allowed_value: {
      label: "Company"
      value: "Company"
    }
    allowed_value: {
      label: "Project"
      value: "Project"
    }
    allowed_value: {
      label: "Salesperson"
      value: "Salesperson"
    }
    allowed_value: {
      label: "Equipment Class"
      value: "Equipment Class"
    }
    allowed_value: {
      label: "Billing Year"
      value: "Billing Year"
    }
  }

  dimension: pivot_field_selection {
    type: string
    sql:
    CASE
      WHEN {% parameter pivot_field %} = 'District' THEN ${TABLE}.district
      WHEN {% parameter pivot_field %} = 'Region' THEN ${TABLE}.region_name
            WHEN {% parameter pivot_field %} = 'Market' THEN ${TABLE}.market_name
      WHEN {% parameter pivot_field %} = 'Company' THEN ${TABLE}.company_name
      WHEN {% parameter pivot_field %} = 'Project' THEN ${TABLE}.project_name
      WHEN {% parameter pivot_field %} = 'Salesperson' THEN ${TABLE}.salesperson_name
      WHEN {% parameter pivot_field %} = 'Equipment Class' THEN ${TABLE}.equipment_class_name
      WHEN {% parameter pivot_field %} = 'Billing Year' THEN CAST(YEAR(${TABLE}.billing_approved_date) as string)
    END ;;
  }


  # measure: rental_revenue_sum {
  #   type:  sum
  #   value_format_name: usd
  #   value_format: "$#,##0"
  #   sql:  ${TABLE}."AMOUNT" ;;
  #   # link: {
  #   #   label: "Additional Details"
  #   #   url: "{{ drill_fields_invoice._link}}"
  #   # }
  # }



  measure: total_gross_profit_margin_pct {
    type: number
    sql: CASE
          WHEN ${total_amount} != 0 THEN ${total_gross_profit_margin} / ${total_amount}
          ELSE 0
        END ;;
    value_format: "#,##0.00%" # Formats the result as a percentage
  }






  measure: revenue_below_floor_with_overrides {
    type: sum
    value_format: "$#,##0"
    filters: [invoice_below_floor: "TRUE", has_at_least_one_override: "TRUE"]
    drill_fields: [company_name,project_name,salesperson_name,region_name, district, market, rental_id, invoice_id, equipment_classes.name, billing_approved_date, amount, total_gross_profit_margin, total_gross_profit_margin_pct, last_three_months_district_time_ute, deal_floor, floor_rate, revenue_with_active_deal_rates, revenue_with_active_deal_rates_and_high_time_ute, revenue_with_commission_overrides, revenue_with_company_commission_exception, revenue_with_company_or_location_rate_agreement_greater_1_yr ]
    sql: CASE WHEN ${invoice_below_floor} = true AND ${has_at_least_one_override} = true THEN ${amount} ELSE 0 END ;;
  }

  measure: revenue_below_floor {
    type: sum
    value_format: "$#,##0"
    sql: CASE WHEN ${invoice_below_floor} = true THEN ${amount} ELSE 0 END ;;
  }

  measure: percent_of_revenue_below_floor_with_overrides {
    type: number
    sql: CASE
          WHEN ${revenue_below_floor} != 0 THEN ${revenue_below_floor_with_overrides} / ${revenue_below_floor}
          ELSE 0
        END ;;
    value_format: "0.00%"
  }

  measure: avg_achieved_rate_as_pct_of_floor {
    type: average
    sql: ${achieved_rate_as_pct_of_floor};;
    value_format: "0.00%"
  }

#   measure:  drill_fields_invoice {
#     hidden:  yes
#     type:  sum
#     sql:  0;;
#     drill_fields:
#     [contract_scoring_invoice_level.parent_company_name, contract_scoring_invoice_level.company_name, contract_scoring_invoice_level.equipment_class_name, contract_scoring_invoice_level.line_item_id,contract_scoring_invoice_level.invoice_date, contract_scoring_invoice_level.shift_type_id, contract_scoring_invoice_level.monthly_service_costs,contract_scoring_invoice_level.monthly_amort, contract_scoring_invoice_level.commission_amount, contract_scoring_invoice_level.rebate_amount, contract_scoring_invoice_level.breakeven_rate, contract_scoring_invoice_level.rental_revenue, contract_scoring_invoice_level.gross_profit_margin, contract_scoring_invoice_level.gross_profit_margin_pct]
# #contract_scoring_invoice_level.invoice_number,
#   }




  measure: gross_profit_margin_sum{
    type:  sum
    value_format_name: usd
    value_format: "$#,##0"
    sql:  ${TABLE}."GROSS_PROFIT_MARGIN" ;;
    # link: {
    #   label: "Additional Details"
    #   url: "{{ drill_fields_invoice._link}}"
    # }
  }

  # measure: total_gross_profit_margin_pct {
  #   type: number
  #   value_format: "#,##0.00%"         # Dollars with 2 decimals ($123.00)
  #   sql: ${TABLE}.gross_profit_margin / ${TABLE}.amount  ;; }

  # measure: gross_profit_margin_pct_sum {
  #   type: number
  #   sql: CASE
  #         WHEN ${rental_revenue_sum} != 0 THEN ${gross_profit_margin_sum} / ${rental_revenue_sum}
  #         ELSE 0
  #       END ;;
  #   value_format: "0.00%" # Formats the result as a percentage
  # }


  measure: total_amount {
    type: sum
    value_format: "$#,##0"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}.AMOUNT  ;; }


  measure: revenue_with_active_deal_rates_and_high_time_ute {
    type: sum
    value_format: "$#,##0"         # Dollars with 2 decimals ($123.00)
    filters: [active_deal_rate_override: "TRUE", high_ute_class: "TRUE"]
    drill_fields: [company_name,project_name,salesperson_name,region_name, district, market, rental_id, invoice_id, equipment_classes.name, billing_approved_date, amount, total_gross_profit_margin, total_gross_profit_margin_pct, last_three_months_district_time_ute, deal_floor, floor_rate, revenue_with_active_deal_rates, revenue_with_active_deal_rates_and_high_time_ute, revenue_with_commission_overrides, revenue_with_company_commission_exception, revenue_with_company_or_location_rate_agreement_greater_1_yr ]
    sql: CASE WHEN ${TABLE}.active_deal_rate_override = true and ${TABLE}.high_ute_class = true THEN ${TABLE}.AMOUNT else 0 end ;; }



  measure: revenue_with_active_deal_rates {
    type: sum
    value_format: "$#,##0"         # Dollars with 2 decimals ($123.00)
    filters: [active_deal_rate_override: "TRUE"]
    drill_fields: [company_name,project_name,salesperson_name,region_name, district, market, rental_id, invoice_id, equipment_classes.name, billing_approved_date, amount, total_gross_profit_margin, total_gross_profit_margin_pct, last_three_months_district_time_ute, deal_floor, floor_rate, revenue_with_active_deal_rates, revenue_with_active_deal_rates_and_high_time_ute, revenue_with_commission_overrides, revenue_with_company_commission_exception, revenue_with_company_or_location_rate_agreement_greater_1_yr ]
    sql: CASE WHEN ${TABLE}.active_deal_rate_override = true THEN ${TABLE}.AMOUNT else 0 end ;; }

  measure: revenue_with_commission_overrides {
    type: sum
    value_format: "$#,##0"         # Dollars with 2 decimals ($123.00)
    filters: [commission_override_request: "TRUE"]
    drill_fields: [company_name,project_name,salesperson_name, region_name, district, market, rental_id, invoice_id, equipment_classes.name, billing_approved_date, amount, total_gross_profit_margin, total_gross_profit_margin_pct, last_three_months_district_time_ute, deal_floor, floor_rate, revenue_with_active_deal_rates, revenue_with_active_deal_rates_and_high_time_ute, revenue_with_commission_overrides, revenue_with_company_commission_exception, revenue_with_company_or_location_rate_agreement_greater_1_yr ]
    sql: CASE WHEN ${TABLE}.commission_override_request = true THEN ${TABLE}.AMOUNT else 0 end ;; }

  measure: revenue_with_company_commission_exception {
    type: sum
    value_format: "$#,##0"         # Dollars with 2 decimals ($123.00)
    filters: [company_commission_exception: "TRUE"]
    drill_fields: [company_name,project_name,salesperson_name, region_name, district, market, rental_id, invoice_id, equipment_classes.name, billing_approved_date, amount, total_gross_profit_margin, total_gross_profit_margin_pct, last_three_months_district_time_ute, deal_floor, floor_rate, revenue_with_active_deal_rates, revenue_with_active_deal_rates_and_high_time_ute, revenue_with_commission_overrides, revenue_with_company_commission_exception, revenue_with_company_or_location_rate_agreement_greater_1_yr ]
    sql: CASE WHEN ${TABLE}.company_commission_exception = true THEN ${TABLE}.AMOUNT else 0 end ;; }

  measure: revenue_with_company_or_location_rate_agreement_greater_1_yr {
    type: sum
    value_format: "$#,##0"         # Dollars with 2 decimals ($123.00)
    filters: [company_or_location_rate_agreement_greater_1_yr: "TRUE"]
    drill_fields: [company_name,project_name,salesperson_name, region_name, district, market, rental_id, invoice_id, equipment_classes.name, billing_approved_date, amount, total_gross_profit_margin, total_gross_profit_margin_pct, last_three_months_district_time_ute, deal_floor, floor_rate, revenue_with_active_deal_rates, revenue_with_active_deal_rates_and_high_time_ute, revenue_with_commission_overrides, revenue_with_company_commission_exception, revenue_with_company_or_location_rate_agreement_greater_1_yr ]
    sql: CASE
         WHEN ${company_rate_agreement_greater_1_yr} = TRUE OR ${location_rate_agreement_greater_1_yr} = TRUE THEN ${TABLE}.AMOUNT else 0 end ;; }

  # measure: revenue_with_location_rate_agreement_greater_1_yr{
  #   type: sum
  #   value_format: "$#,##0"         # Dollars with 2 decimals ($123.00)
  #   filters: [location_rate_agreement_greater_1_yr: "TRUE"]
  #   drill_fields: [company_name,project_name,salesperson_name,region_name, district, market,  rental_id, invoice_id, equipment_classes.name, billing_approved_date, amount, total_gross_profit_margin, total_gross_profit_margin_pct, last_three_months_district_time_ute, deal_floor, floor_rate, revenue_with_active_deal_rates, revenue_with_active_deal_rates_and_high_time_ute, revenue_with_commission_overrides, revenue_with_company_commission_exception, revenue_with_company_rate_agreement_greater_1_yr, revenue_with_location_rate_agreement_greater_1_yr ]
  #   sql: CASE WHEN ${TABLE}.location_rate_agreement_greater_1_yr = true THEN ${TABLE}.AMOUNT else 0 end ;; }

  measure: revenue_with_at_least_one_override{
    type: sum
    value_format: "$#,##0"         # Dollars with 2 decimals ($123.00)
    filters: [has_at_least_one_override: "TRUE"]
    drill_fields: [company_name,project_name,salesperson_name, region_name, district, market, rental_id, invoice_id, equipment_classes.name, billing_approved_date, amount, total_gross_profit_margin, total_gross_profit_margin_pct, last_three_months_district_time_ute, deal_floor, floor_rate, revenue_with_active_deal_rates, revenue_with_active_deal_rates_and_high_time_ute, revenue_with_commission_overrides, revenue_with_company_commission_exception, revenue_with_company_or_location_rate_agreement_greater_1_yr ]
    sql: CASE WHEN ${TABLE}.has_at_least_one_override = true THEN ${TABLE}.AMOUNT else 0 end ;; }

}

view: collections_actuals {
  sql_table_name: "ANALYTICS"."TREASURY"."COLLECTIONS_ACTUALS_PAYMENTS" ;;

  ################## PRIMARY KEY ##################
  dimension: key {
    type: string
    primary_key: yes
    sql: ${TABLE}."MONTH_" || '-'|| ${TABLE}."INVOICE_NO" || '-' || ${TABLE}."CUSTOMER_ID"||'-'||${TABLE}."PAYMENT_AMOUNT" ;;
  }

  dimension: target_key {
    type: string
    sql: ${TABLE}."TARGET_KEY" ;;
  }

  dimension: payment_date {
    type: date
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }

  ################## DIMENSIONS ##################
  dimension: month_ {
    type: date
    sql: ${TABLE}."MONTH_" ;;
  }

  dimension: invoice_no {
    type: string
    html:<font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}" target="_blank">{{value}}</a></font></u>;;
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: payment_quarter {
    type: string
    sql: ${TABLE}."PAYMENT_QUARTER" ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: branch_id {
    type: string
    value_format_name: id
    sql: iff(${TABLE}."BRANCH_ID" is null,'77777',${TABLE}."BRANCH_ID") ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: salesperson_user_id {
    type: number
    value_format_name: id
    sql: iff(${TABLE}."SALESPERSON_USER_ID" is null,'999999',${TABLE}."SALESPERSON_USER_ID") ;;
  }

  dimension: salesperson_name {
    type: string
    sql: iff(${TABLE}."SALESPERSON_NAME" is null,'No salesperson on invoice',${TABLE}."SALESPERSON_NAME") ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: combined_customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type:  string
    sql:  ${TABLE}."CUSTOMER_NAME" ;;
  }

  #dimension: customer_id_2 {
  #  type: string
  #  sql: IFF(${TABLE}."CUSTOMER_ID_2" IS NULL,'999999',${TABLE}."CUSTOMER_ID_2") ;;
  #}

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }



  ################## MEASURES ##################

  measure: collections {
    type: sum
    value_format_name: usd_0
    drill_fields: [collection_details*]
    sql: coalesce(${TABLE}."PAYMENT_AMOUNT",0) ;;
  }

  measure: collections_dd {
    label: "Collections"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
  }

  measure: run_rate_collections {
    label: "Run Rate Collections"
    type: number
    sql: (${collections} / datediff(day, '2025-06-30',current_date)) * 92 ;;
    value_format_name: usd_0
  }

  measure: amount_to_be_collected_run_rate {
    label: "Amount to be Collected"
    type: number
    sql: iff(${collector_individual_targets.collections_target} - ${run_rate_collections}<=0,0,${collector_individual_targets.collections_target} - ${run_rate_collections}) ;;
    value_format_name: usd_0
  }

  ############## DRILL FIELDS ##############
  set: collection_details {
    fields: [invoice_no,salesperson_user_id,salesperson_name,month_,due_date,branch_id,branch_name,customer_id,customer_name,collector_individual_targets.manager,collector_individual_targets.collector,collections]
  }

  }

view: vendor_coi_audit {

  derived_table: {
    sql:
    SELECT V.VENDORID                   AS VENDOR_ID,
       V.NAME                           AS VENDOR_NAME,
       V.REQUIRES_COI                   AS REQUIRES_COI,
       V.COI_URL                        AS COI_URL,
       V.VENDTYPE                       AS VENDOR_TYPE,
       V.VENDOR_CATEGORY                AS VENDOR_CATEGORY,
       V.EARLIEST_COI_EXPIRATION_DATE   AS COI_EXPIRATION_DATE,
       V.STATUS                         AS VENDOR_STATUS,
       V.PARENT_VENDOR                  AS PARENT_VENDOR,
       V.NEW_VENDOR_CATEGORY            AS NEW_VENDOR_CATEGORY,
       V.VENDOR_SUB_CATEGORY            AS VENDOR_SUB_CATEGORY
    FROM ANALYTICS.INTACCT.VENDOR V;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
    primary_key: yes
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: requires_coi {
    type: string
    sql: ${TABLE}."REQUIRES_COI" ;;
  }

  dimension: coi_url {
    type: string
    sql: ${TABLE}."COI_URL" ;;
  }

  dimension: vendor_type {
    type: string
    sql: ${TABLE}."VENDOR_TYPE" ;;
  }

  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }

  dimension: earliest_coi_expiration {
    type:  date
    sql: ${TABLE}."COI_EXPIRATION_DATE" ;;
  }

  dimension: vendor_status {
    type:  string
    sql: ${TABLE}."VENDOR_STATUS" ;;
  }

  dimension: parent_vendor {
    type:  string
    sql: ${TABLE}."PARENT_VENDOR" ;;
  }

  dimension_group: when_posted {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}."WHENPOSTED" ;;
  }

  dimension: new_vendor_category {
    type: string
    sql: ${TABLE}."NEW_VENDOR_CATEGORY" ;;
  }

  dimension: vendor_subcategory {
    type: string
    sql: ${TABLE}."VENDOR_SUB_CATEGORY" ;;
  }

  ##################################################################################
# COI Required by Vendor Status
  measure: count_vendors_coi_required {
    type: count
    filters: [requires_coi: "true", vendor_status: "active, inactive, null"]
    description: "Count of vendors who require a COI"
  }

  measure: count_active_vendors_coi_required {
    type: count
    filters: [requires_coi: "true", vendor_status: "active"]
    description: "Count of Active vendors who require a COI"
  }

  measure: count_inactive_vendors_coi_required {
    type: count
    filters: [requires_coi: "true", vendor_status: "inactive"]
    description: "Count of Inactive vendors who require a COI"
  }

  ##################################################################################

  ##################################################################################
# COI Expirations by Vendor Status

  measure: total_vendors_with_expired_coi {
    type: count
    filters: [earliest_coi_expiration: "before today"]
    description: "Total vendors with expiring COIs"
  }

  measure: active_vendors_with_expired_coi {
    type: count
    filters: [vendor_status: "active", earliest_coi_expiration: "before today"]
    description: "Active vendors with expiring COIs"
  }

  measure: inactive_vendors_with_expired_coi {
    type: count
    filters: [vendor_status: "inactive", earliest_coi_expiration: "before today"]
    description: "Inactive vendors with expiring COIs"
  }


  measure: count_coi_expiring_this_month {
    type: count
    filters: [requires_coi: "true", earliest_coi_expiration: "this month"]
    description: "Count of COI-required vendors with COI expiring in the current month"
  }

  measure: count_active_vendors_coi_expiring_this_month {
    type: count
    filters: [requires_coi: "true", earliest_coi_expiration: "this month", vendor_status: "active"]
    description: "Count of Active COI-required vendors with COI expiring in the current month"
  }

  measure: count_inactive_vendors_coi_expiring_this_month {
    type: count
    filters: [requires_coi: "true", earliest_coi_expiration: "this month", vendor_status: "inactive"]
    description: "Count of Active COI-required vendors with COI expiring in the current month"
  }




  measure: count_coi_expiring_next_month{
    type: count
    filters: [requires_coi: "true", earliest_coi_expiration: "next month"]
    description: "Count of COI-required vendors with COI expiring the next month"
  }

  measure: count_active_vendors_coi_expiring_next_month {
    type: count
    filters: [requires_coi: "true", earliest_coi_expiration: "next month", vendor_status: "active"]
    description: "Count of Active COI-required vendors with COI expiring next month"
  }

  measure: count_inactive_vendors_coi_expiring_next_month {
    type: count
    filters: [requires_coi: "true", earliest_coi_expiration: "next month", vendor_status: "inactive"]
    description: "Count of Active COI-required vendors with COI expiring next month"
  }



  measure: count_coi_expiring_this_year{
    type: count
    filters: [requires_coi: "true", earliest_coi_expiration: "this year"]
    description: "Count of COI-required vendors with COI expiring in the current year"
  }

  measure: count_active_vendors_coi_expiring_this_year{
    type: count
    filters: [requires_coi: "true", earliest_coi_expiration: "this year", vendor_status: "active"]
    description: "Count of Active COI-required vendors with COI expiring in the current year"
  }

  measure: count_inactive_vendors_coi_expiring_this_year{
    type: count
    filters: [requires_coi: "true", earliest_coi_expiration: "this year", vendor_status: "inactive"]
    description: "Count of Active COI-required vendors with COI expiring in the current year"
  }

  ##################################################################################

  measure: count_vendors_coi_required_null_url {
    type: count
    filters: [requires_coi: "true", coi_url: "null"]
    description: "Count of COI-required vendors with a null COI_URL"
  }

  measure: count_active_vendors_coi_required_null_url {
    type: count
    filters: [requires_coi: "true", coi_url: "null", vendor_status: "active"]
    description: "Count of active COI-required vendors with a null COI_URL"
  }

  measure: count_inactive_vendors_coi_required_null_url {
    type: count
    filters: [requires_coi: "true", coi_url: "null", vendor_status: "inactive"]
    description: "Count of inactive COI-required vendors with a null COI_URL"
  }




  measure: percent_vendors_coi_required_missing_coi_url {
    type: number
    sql: (${count_vendors_coi_required_null_url} / NULLIF(${count_vendors_coi_required}, 0)) ;;
    value_format: "0.00%"
    description: "Percentage of COI-required vendors missing COI_URL"
  }

  measure: percent_active_vendors_coi_required_missing_coi_url {
    type: number
    sql: (${count_active_vendors_coi_required_null_url} / NULLIF(${count_active_vendors_coi_required}, 0)) ;;
    value_format: "0.00%"
    description: "Percentage of COI-required vendors missing COI_URL"
  }
  measure: percent_inactive_vendors_coi_required_missing_coi_url {
    type: number
    sql: (${count_inactive_vendors_coi_required_null_url} / NULLIF(${count_inactive_vendors_coi_required}, 0)) ;;
    value_format: "0.00%"
    description: "Percentage of COI-required vendors missing COI_URL"
  }



# Vendor Counts and COI Requirements

  measure: total_vendors {
    type: count
    description: "Total number of vendors"
  }

  measure: active_vendors {
    type: count
    filters: [vendor_status: "active"]
    description: "Count of active vendors"
  }

  measure: inactive_vendors {
    type: count
    filters: [vendor_status: "inactive"]
    description: "Count of inactive vendors"
  }

  }

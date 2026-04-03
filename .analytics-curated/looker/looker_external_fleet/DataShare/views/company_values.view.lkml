# view: company_values {
#     derived_table: {
#       sql: select * from business_intelligence.triage.stg_t3__company_values ;;
#     }

view: company_values {
    sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__COMPANY_VALUES"
      ;;

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: order_id {
      type: number
      sql: ${TABLE}."ORDER_ID" ;;
    }

    dimension: rental_company_id {
      type: number
      sql: ${TABLE}."RENTAL_COMPANY_ID" ;;
    }

    dimension: owner_company_id {
      type: number
      sql: ${TABLE}."OWNER_COMPANY_ID" ;;
    }

    dimension: rental_parent_company_id {
      type: number
      sql: ${TABLE}."RENTAL_PARENT_COMPANY_ID" ;;
    }

    dimension: rental_parent_company_name {
      type: string
      sql: ${TABLE}."RENTAL_PARENT_COMPANY_NAME" ;;
    }

    dimension: owner_parent_company_id {
      type: number
      sql: ${TABLE}."OWNER_PARENT_COMPANY_ID" ;;
    }

    dimension: owner_parent_company_name {
      type: string
      sql: ${TABLE}."OWNER_PARENT_COMPANY_NAME" ;;
    }

    dimension: rental_id {
      type: number
      sql: ${TABLE}."RENTAL_ID" ;;
    }

    dimension: asset_id {
      type: number
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension_group: start_date {
      type: time
      sql: ${TABLE}."START_DATE" ;;
    }

    dimension_group: end_date {
      type: time
      sql: ${TABLE}."END_DATE" ;;
    }

    dimension: sub_renter_id {
      type: number
      sql: ${TABLE}."SUB_RENTER_ID" ;;
    }

    dimension: sub_renter_company_id {
      type: number
      sql: ${TABLE}."SUB_RENTER_COMPANY_ID" ;;
    }

    dimension: sub_renting_company {
      type: string
      sql: ${TABLE}."SUB_RENTING_COMPANY" ;;
    }

    dimension: sub_renting_contact {
      type: string
      sql: ${TABLE}."SUB_RENTING_CONTACT" ;;
    }

    dimension: job_id {
      type: number
      sql: ${TABLE}."JOB_ID" ;;
    }

    dimension: job_name {
      type: string
      sql: ${TABLE}."JOB_NAME" ;;
    }

    dimension: phase_job_id {
      type: number
      sql: ${TABLE}."PHASE_JOB_ID" ;;
    }

    dimension: phase_job_name {
      type: string
      sql: ${TABLE}."PHASE_JOB_NAME" ;;
    }

    dimension_group: data_refresh_timestamp {
      type: time
      sql: ${TABLE}."DATA_REFRESH_TIMESTAMP" ;;
    }

    set: detail {
      fields: [
        order_id,
        rental_company_id,
        owner_company_id,
        rental_parent_company_id,
        rental_parent_company_name,
        owner_parent_company_id,
        owner_parent_company_name,
        rental_id,
        asset_id,
        start_date_time,
        end_date_time,
        sub_renter_id,
        sub_renter_company_id,
        sub_renting_company,
        sub_renting_contact,
        job_id,
        job_name,
        phase_job_id,
        phase_job_name,
        data_refresh_timestamp_time
      ]
    }
  }

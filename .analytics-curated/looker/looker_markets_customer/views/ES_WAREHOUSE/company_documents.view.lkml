view: company_documents {
  # swapping to a derived table to pull in all fields + the last doc information to allow filtering for company docs that are renewed
  derived_table: {
    sql: with company_docs as (
            select
            company_id,
            company_document_type_id,
            created_by_user_id,
            date_created,
            voided,
            valid_from,
            valid_until,
            notes,
            original_file_name,
            file_name,
            file_path,
            extended_data,
            company_document_id,
            _es_update_timestamp
            from ES_WAREHOUSE.PUBLIC.COMPANY_DOCUMENTS)
, AL_HAPD_docs as (
            select
            trim(COMPANY_ACCT_) as COMPANY_ID
            , 123456 as COMPANY_DOCUMENT_TYPE_ID
            , NULL as CREATED_BY_USER_ID
            , _FIVETRAN_SYNCED as DATE_CREATED
            , False as VOIDED
            , POLICY_START_DATE as VALID_FROM
            , POLICY_EXPIRATION as VALID_UNTIL
            , NULL as NOTES
            , NULL as ORIGINAL_FILE_NAME
            , NULL as FILE_NAME
            , NULL as FILE_PATH
            , NULL as EXTENDED_DATA
            , dense_rank() OVER (ORDER BY COMPANY_ID) as COMPANY_DOCUMENT_ID
            , _FIVETRAN_SYNCED as _ES_UPDATE_TIMESTAMP
            from
ANALYTICS.AL_HAPD.AL_HAPD_GOOGLE_SHEET)
, all_docs as (
select * from AL_HAPD_docs
UNION
select * from company_docs
)
select *,
                case when VOIDED = false
                  then last_value (COMPANY_DOCUMENT_ID) over (PARTITION BY company_Id, company_document_type_id order by valid_until, DATE_CREATED)
                  else null end as last_valid_company_doc_id
                , case
                when company_document_type_id in (3, 123456) then 'N/A'
                when company_document_type_id = 1 and valid_until < CURRENT_DATE then 'YES'
                else 'No' end as should_charge_rpp
        from all_docs
        where voided = false
        ;;
  }
  #sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANY_DOCUMENTS"  ;;
  drill_fields: [company_document_id]

  dimension: company_document_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_DOCUMENT_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: company_document_type_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."COMPANY_DOCUMENT_TYPE_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: should_charge_rpp_sql {
    label: "Should Charge RPP?"
    type: string
    sql: ${TABLE}."SHOULD_CHARGE_RPP" ;;
  }

  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: extended_data {
    type: string
    sql: ${TABLE}."EXTENDED_DATA" ;;
  }

  dimension: file_name {
    type: string
    sql: ${TABLE}."FILE_NAME" ;;
  }

  dimension: file_path {
    type: string
    sql: ${TABLE}."FILE_PATH" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: original_file_name {
    type: string
    sql: ${TABLE}."ORIGINAL_FILE_NAME" ;;
  }

  dimension_group: valid_from {
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
    sql: CAST(${TABLE}."VALID_FROM" AS TIMESTAMP_NTZ) ;;
  }

dimension: valid_until_days {
  type: number
  hidden: no
  sql: DATEDIFF(DAY, getdate(), CAST(${TABLE}."VALID_UNTIL" AS TIMESTAMP_NTZ));;
}

  dimension_group: valid_until {
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
    sql: CAST(${TABLE}."VALID_UNTIL" AS TIMESTAMP_NTZ) ;;
  }

  dimension: voided {
    type: yesno
    sql: ${TABLE}."VOIDED" ;;
  }

  dimension: date_before_today {
    type: yesno
    sql: ${valid_until_date} < current_date() ;;
  }

  dimension: expiring_next_90_days {
    type: yesno
    sql: ${valid_until_date} between current_date() and current_date() + interval '90 day' ;;
  }

  dimension: last_valid_company_doc_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."LAST_VALID_COMPANY_DOC_ID" ;;
  }

  dimension: is_last {
    type: yesno
    sql: ${last_valid_company_doc_id} = ${company_document_id} ;;
  }

  measure: count {
    type: count
    drill_fields: [company_document_id, file_name, original_file_name, company_document_types.company_document_type_id, company_document_types.name]
  }
}

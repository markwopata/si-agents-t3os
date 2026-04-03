view: capitalcustommeterreadingreport {
  derived_table: {
    sql:
      select a.asset_id,
          '900' as company_code,
          a.custom_name as equipment_code,
          1 as meter_number,
          'ES Track' as batch_id,
          convert_timezone('America/Chicago', ast.last_checkin_timestamp) as transaction_date,
          case when a.asset_type_id = 1 then floor(ast.hours)
                   when a.asset_type_id = 2 then floor(ast.odometer)
                   else null end as meter_reading,
          '' as meter_change,
          case when ast.street is null then '' else concat(ast.street, ', ', ast.city, ', ', st.abbreviation, ' ', ast.zip_code) end as meter_remarks,
          '' as notes,
          initcap(aty.name) as asset_type
      from assets a join table(assetlist(27961)) L on L.asset_id = a.asset_id
          join asset_statuses ast on ast.asset_id = a.asset_id
          left join asset_tracker_assignments ata on ata.asset_id = a.asset_id
          left join asset_types aty on aty.asset_type_id = a.asset_type_id
          left join states st on st.state_id = ast.state_id
      where
          (a.asset_type_id = 1 and ast.hours is not null
              or a.asset_type_id = 2 and ast.odometer is not null)
          and ata.date_installed is not null and ata.date_uninstalled is null
      order by a.custom_name
    ;;
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: company_code {
    type: string
    sql: ${TABLE}."COMPANY_CODE" ;;
  }

  dimension: equipment_code {
    type: string
    sql: ${TABLE}."EQUIPMENT_CODE" ;;
  }

  dimension: meter_number {
    type: number
    sql: ${TABLE}."METER_NUMBER" ;;
  }

  dimension: batch_id {
    type: string
    sql: ${TABLE}."BATCH_ID" ;;
  }

  dimension: transaction_date {
    type:  date
    sql: ${TABLE}."TRANSACTION_DATE" ;;
    html: {{ rendered_value | date: "%m/%d/%Y"  }};;
  }

  dimension: meter_reading {
    type: number
    sql: ${TABLE}."METER_READING" ;;
  }

  dimension: meter_change {
    type: string
    sql: ${TABLE}."METER_CHANGE" ;;
  }

  dimension: meter_remarks {
    type: string
    sql: ${TABLE}."METER_REMARKS" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }



}

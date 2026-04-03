view: equipment_classes {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_CLASSES"
    ;;
  drill_fields: [equipment_class_id]

  dimension: equipment_class_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
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

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: company_division_id {
    type: number
    sql: ${TABLE}."COMPANY_DIVISION_ID" ;;
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

  dimension_group: date_updated {
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: primary_photo_id {
    type: number
    sql: ${TABLE}."PRIMARY_PHOTO_ID" ;;
  }

  dimension: rentable {
    type: yesno
    sql: ${TABLE}."RENTABLE" ;;
  }

  dimension: weekly_minimum {
    type: yesno
    sql: ${TABLE}."WEEKLY_MINIMUM" ;;
  }

  measure: count {
    type: count
    drill_fields: [equipment_class_id, name]
  }

  dimension: equipment_category{
    type: string
    sql:
      CASE
        WHEN ${name} like '%Aerial Lift%' THEN 'Aerial Lift'
        WHEN ${name} like '%Articulating Boom Lift%' THEN 'Articulating Boom Lift'
        WHEN ${name} like '%Forklift%' THEN 'Forklift'
        WHEN ${name} like '%Forklift & Material Handling%' THEN 'Forklift & Material Handling'
        WHEN ${name} like '%Lighting%' THEN 'Lighting'
        WHEN ${name} like '%Material Handling%' THEN 'Material Handling'
        WHEN ${name} like '%Scissor Lift%' THEN 'Scissor Lift'
        WHEN ${name} like '%Telehandler%' THEN 'Telehandler'
        WHEN ${name} like '%Telescopic Boom Lift%' THEN 'Telescopic Boom Lift'
        WHEN ${name} like '%Towable Lift%' THEN 'Towable Lift'
        WHEN ${name} like '%Vertical Mast Lift%' THEN 'Vertical Mast Lift'
        WHEN ${name} like '%AG Tractor%' THEN 'AG Tractor'
        WHEN ${name} like '%Attachment%' THEN 'Attachment'
        WHEN ${name} like '%Backhoe%' THEN 'Backhoe'
        WHEN ${name} like '%Buggie & Bucket%' THEN 'Buggie & Bucket'
        WHEN ${name} like '%Compaction%' THEN 'Compaction'
        WHEN ${name} like '%Cutting & Coring%' THEN 'Cutting & Coring'
        WHEN ${name} like '%Excavator%' THEN 'Excavator'
        WHEN ${name} like '%Heavy Equipment%' THEN 'Heavy Equipment'
        WHEN ${name} like '%Loader%' THEN 'Loader'
        WHEN ${name} like '%Plate Compactor%' THEN 'Plate Compactor'
        WHEN ${name} like '%Roller%' THEN 'Roller'
        WHEN ${name} like '%Skid Steer%' THEN 'Skid Steer'
        WHEN ${name} like '%Surface Preparation%' THEN 'Surface Preparation'
        WHEN ${name} like '%Sweeper & Broom Equipment%' THEN 'Sweeper & Broom Equipment'
        WHEN ${name} like '%Tractor%' THEN 'Tractor'
        WHEN ${name} like '%Trencher%' THEN 'Trencher'
        WHEN ${name} like '%Generator%' THEN 'Generator'
      ELSE 'General'
      END ;;
  }

dimension: business_segment_id {
  type: number
  sql: ${TABLE}. "BUSINESS_SEGMENT_ID" ;;
}
}

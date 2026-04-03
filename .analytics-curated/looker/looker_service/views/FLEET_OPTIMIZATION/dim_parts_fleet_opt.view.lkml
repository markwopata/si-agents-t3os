view: dim_parts_fleet_opt {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_PARTS_FLEET_OPT" ;;

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: part_archived {
    type: yesno
    sql: ${TABLE}."PART_ARCHIVED" ;;
  }
  dimension: part_category_id {
    type: number
    sql: ${TABLE}."PART_CATEGORY_ID" ;;
  }
  dimension: part_category_name {
    type: string
    sql: ${TABLE}."PART_CATEGORY_NAME" ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: part_internal_use {
    type: yesno
    sql: ${TABLE}."PART_INTERNAL_USE" ;;
  }
  dimension: part_is_global {
    type: yesno
    sql: ${TABLE}."PART_IS_GLOBAL" ;;
  }
  dimension: part_key {
    type: string
    sql: ${TABLE}."PART_KEY" ;;
  }
  dimension: part_level {
    type: number
    sql: ${TABLE}."PART_LEVEL" ;;
  }
  dimension: part_manufacturer_number {
    type: string
    sql: ${TABLE}."PART_MANUFACTURER_NUMBER" ;;
  }
  dimension: part_master_key {
    type: string
    sql: ${TABLE}."PART_MASTER_KEY" ;;
  }
  dimension: part_msrp {
    type: number
    sql: ${TABLE}."PART_MSRP" ;;
  }
  dimension: part_name {
    type: string
    sql: ${TABLE}."PART_NAME" ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: part_provider_id {
    type: number
    sql: ${TABLE}."PART_PROVIDER_ID" ;;
  }
  dimension: part_provider_name {
    type: string
    sql: ${TABLE}."PART_PROVIDER_NAME" ;;
  }
  dimension: si_67_part_provider_name {
    hidden: yes
    type: string
    sql: iff(${TABLE}."PART_PROVIDER_NAME" = 'BULK - BUCKET MINI TRACK LOADER', 'BULK - BUCKET MINI-TRACK-LOADER', ${TABLE}."PART_PROVIDER_NAME")  ;;
  }
  dimension_group: part_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."PART_RECORDTIMESTAMP" ;;
  }
  dimension: part_reporting_category {
    type: string
    sql: ${TABLE}."PART_REPORTING_CATEGORY" ;;
  }
  dimension: part_search {
    type: string
    sql: ${TABLE}."PART_SEARCH" ;;
  }
  dimension: part_sku_field {
    type: string
    sql: ${TABLE}."PART_SKU_FIELD" ;;
  }
  dimension: part_source {
    type: string
    sql: ${TABLE}."PART_SOURCE" ;;
  }
  dimension: part_type_description {
    type: string
    sql: ${TABLE}."PART_TYPE_DESCRIPTION" ;;
  }
  dimension: part_type_id {
    type: number
    sql: ${TABLE}."PART_TYPE_ID" ;;
  }
  dimension: part_verified_for_company {
    type: yesno
    sql: ${TABLE}."PART_VERIFIED_FOR_COMPANY" ;;
  }
  dimension: part_verified_globally {
    type: yesno
    sql: ${TABLE}."PART_VERIFIED_GLOBALLY" ;;
  }
  measure: count {
    type: count
    drill_fields: [part_provider_name, part_category_name, part_name]
  }
}
view: dim_parts_fleet_opt_attributes {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_PARTS_FLEET_OPT" ;;
  #creating as separate view to avoid tying views together for FC stockable adjusted filter that relies on multiple joins in explore
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;}

  dimension: fc_stockable {
    type: yesno
    sql: iff(${fulfillment_parts_attributes.fc_stockable} is null, true, ${fulfillment_parts_attributes.fc_stockable}) ;;
    hidden: yes #just using this field to accomodate nulls for the adjusted filter, hiding since it would be confusing to users HL 12.5.25
  }

  dimension: fc_stockable_adjusted {
    type: yesno
    sql:
    CASE
      WHEN
        (
          (${part_categorization_structure.category} = 'Attachments & Implements' AND ${part_categorization_structure.subcategory} = 'Buckets' AND ${part_categorization_structure.part_containers} = '')
          OR (${part_categorization_structure.category} = 'Attachments & Implements' AND ${part_categorization_structure.subcategory} = 'Hammers & Breakers' AND ${part_categorization_structure.part_containers} = '')
          OR (${part_categorization_structure.category} = 'Electrical & Lighting' AND ${part_categorization_structure.subcategory} = 'Batteries' AND ${part_categorization_structure.part_containers} = 'Other Batteries')
          OR (${part_categorization_structure.category} = 'Maintenance' AND ${part_categorization_structure.subcategory} = 'Battery Maintenance' AND ${part_categorization_structure.part_containers} = '')
          OR (${part_categorization_structure.category} = 'Safety & Compliance' AND ${part_categorization_structure.subcategory} = 'Fire Suppression Systems' AND ${part_categorization_structure.part_containers} IN ('Fire Extinguishers', 'Automatic Fire Suppression'))
          OR (${part_categorization_structure.category} = 'Electrical & Lighting' AND ${part_categorization_structure.subcategory} = 'Batteries' AND ${part_categorization_structure.part_containers} = '')
          OR (${part_categorization_structure.category} = 'Maintenance' AND ${part_categorization_structure.subcategory} = 'Fluids & Lubricants' AND ${part_categorization_structure.part_containers} IN ('Hydraulic Lubricants', 'Transmission Lubricants', 'DEF', 'Fuel', 'Coolants', 'Differential Lubricants'))
          OR (${part_categorization_structure.category} = 'Pneumatics & Air Systems' AND ${part_categorization_structure.subcategory} = 'Air Tanks' AND ${part_categorization_structure.part_containers} IN ('Standard Air Tanks', 'High-Pressure Air Tanks'))
          OR (${part_categorization_structure.category} = 'Undercarriage' AND ${part_categorization_structure.subcategory} = 'Tracks' AND ${part_categorization_structure.part_containers} = 'Rubber Tracks')
          OR (${part_categorization_structure.category} = 'Undercarriage' AND ${part_categorization_structure.subcategory} = 'Wear Parts' AND ${part_categorization_structure.part_containers} = 'Cleats')
          OR (${part_categorization_structure.category} = 'Frames & Chassis' AND ${part_categorization_structure.subcategory} = 'Frames' AND ${part_categorization_structure.part_containers} = 'Fork Carriages')
          OR (${part_categorization_structure.category} = 'Frames & Chassis' AND ${part_categorization_structure.subcategory} = 'Counterweights' AND ${part_categorization_structure.part_containers} = 'Rear Counterweights')
          OR (${part_categorization_structure.category} = 'Materials' AND ${part_categorization_structure.subcategory} = 'Concrete Accessories' AND ${part_categorization_structure.part_containers} = 'Rebar Chairs')
          OR (${part_categorization_structure.category} = 'Materials' AND ${part_categorization_structure.subcategory} = 'Concrete Reinforcement' AND ${part_categorization_structure.part_containers} = 'Dowels')
          OR (${part_categorization_structure.category} = 'Attachments & Implements' AND ${part_categorization_structure.subcategory} = 'Buckets' AND ${part_categorization_structure.part_containers} IN ('Excavator Buckets', 'Loader Buckets'))
          OR (${part_categorization_structure.category} = 'Cabin & Operator Controls' AND ${part_categorization_structure.subcategory} = 'Cabin Safety Systems' AND ${part_categorization_structure.part_containers} = 'Rollover Protection (ROPS)')
          OR (${part_categorization_structure.category} = 'Electrical & Lighting' AND ${part_categorization_structure.subcategory} = 'Batteries' AND ${part_categorization_structure.part_containers} IN ('Starter Batteries', 'Deep Cycle Batteries'))
          OR (${part_categorization_structure.category} = 'Security Systems' AND ${part_categorization_structure.subcategory} = 'Access Control' AND ${part_categorization_structure.part_containers} = 'Trackers')
          OR (${part_categorization_structure.subcategory} IN ('Concrete Formwork','Beverages'))
        )
      THEN FALSE
      ELSE ${fc_stockable}
    END ;;
  }
}

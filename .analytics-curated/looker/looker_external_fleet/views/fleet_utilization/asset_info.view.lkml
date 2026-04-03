view: asset_info {
  derived_table: {
    sql:
    select
    case when {{ _user_attributes['company_id'] }}::numeric = ai.company_id then 'Owned'
    else 'Rented'
    end as ownership
    , ai.ASSET_ID
    , ai.COMPANY_ID
    , ASSET
    , CUSTOM_NAME
    , ASSET_CLASS
    , CATEGORY
    , BRANCH
    , MAKE
    , MODEL
    , SERIAL_NUMBER_VIN
    , SERIAL_NUMBER
    , VIN
    , ASSET_TYPE
    , TRACKER_GROUPING
    , TRACKER_DEVICE_SERIAL
    , TRACKER_TRACKER_ID
    , ESDB_TRACKER_ID
    , DRIVER_NAME
    , CONTACT_IN_72_HOURS
    , license_plate_number
    , license_plate_state
    , ai.archived_status
    , DATA_REFRESH_TIMESTAMP
    from
    BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_INFO ai
    left join es_warehouse.public.organization_asset_xref oax on ai.asset_id = oax.asset_id
    left join es_warehouse.public.organizations o on oax.organization_id = o.organization_id

          where
          ai.company_id = {{ _user_attributes['company_id'] }}
          or o.company_id = {{ _user_attributes['company_id'] }}


          AND {% condition custom_name_filter %} ai.custom_name {% endcondition %}
          AND {% condition asset_class_filter %} ai.asset_class {% endcondition %}
          AND {% condition groups_filter %} o.name {% endcondition %}
          AND {% condition ownership_filter %} ownership {% endcondition %}
          AND {% condition category_filter %} ai.category {% endcondition %}
          AND {% condition branch_filter %} ai.branch {% endcondition %}
          AND {% condition make_filter %} ai.make {% endcondition %}
          AND {% condition model_filter %} ai.model {% endcondition %}
          AND {% condition asset_type_filter %} ai.asset_type {% endcondition %}
          AND {% condition tracker_grouping_filter %} ai.tracker_grouping {% endcondition %}
          AND {% condition license_plate_filter %} ai.license_plate_number {% endcondition %}
          AND {% condition archived_status_filter %} ai.archived_status {% endcondition %}


      UNION

      select
          case when {{ _user_attributes['company_id'] }}::numeric = ai.company_id then 'Owned'
          else 'Rented'
          end as ownership
          , ai.ASSET_ID
          , ai.COMPANY_ID
          , ai.ASSET
          , ai.CUSTOM_NAME
          , ai.ASSET_CLASS
          , ai.CATEGORY
          , ai.BRANCH
          , ai.MAKE
          , ai.MODEL
          , ai.SERIAL_NUMBER_VIN
          , ai.SERIAL_NUMBER
          , ai.VIN
          , ai.ASSET_TYPE
          , ai.TRACKER_GROUPING
          , ai.TRACKER_DEVICE_SERIAL
          , ai.TRACKER_TRACKER_ID
          , ai.ESDB_TRACKER_ID
          , ai.DRIVER_NAME
          , ai.CONTACT_IN_72_HOURS
          , license_plate_number
          , license_plate_state
          , ai.archived_status
          , ai.DATA_REFRESH_TIMESTAMP
          from
          BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_INFO AI
          join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__BY_DAY_UTILIZATION bdu on BDU.ASSET_ID = AI.ASSET_ID AND BDU.rental_company_id = {{ _user_attributes['company_id'] }}::numeric
          where
          bdu.date >= {% date_start date_filter %}::date
          AND bdu.date <= {% date_end date_filter %}::date
          AND {% condition custom_name_filter %} ai.custom_name {% endcondition %}
          AND {% condition asset_class_filter %} ai.asset_class {% endcondition %}
          AND {% condition groups_filter %} o.name {% endcondition %}
          AND {% condition ownership_filter %} ownership {% endcondition %}
          AND {% condition category_filter %} ai.category {% endcondition %}
          AND {% condition branch_filter %} ai.branch {% endcondition %}
          AND {% condition make_filter %} ai.make {% endcondition %}
          AND {% condition model_filter %} ai.model {% endcondition %}
          AND {% condition asset_type_filter %} ai.asset_type {% endcondition %}
          AND {% condition tracker_grouping_filter %} ai.tracker_grouping {% endcondition %}
          AND {% condition license_plate_filter %} ai.license_plate_number {% endcondition %}
          AND {% condition archived_status_filter %} ai.archived_status {% endcondition %}
          ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: ${asset_id} ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: ownership {
    type: string
    sql: ${TABLE}."OWNERSHIP" ;;
  }

  dimension: ownership_info {
    type: string
    sql: ${TABLE}."OWNERSHIP_INFO" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: archived_status {
    type: string
    sql: ${TABLE}."ARCHIVED_STATUS" ;;
  }

  # dimension: group_name {
  #   type: string
  #   sql: ${TABLE}."GROUP_NAME" ;;
  # }

  dimension: asset_class {
    label: "Class"
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: serial_number_vin {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_VIN" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: tracker_grouping {
    type: string
    sql: ${TABLE}."TRACKER_GROUPING" ;;
  }

  dimension: driver_name {
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }

  dimension: license_plate_number {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_NUMBER" ;;
  }

  dimension: license_plate_state {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_STATE" ;;
  }

  filter: custom_name_filter {
  }

  filter: groups_filter {
  }

  filter: ownership_filter {
  }

  filter: asset_class_filter {
  }

  filter: branch_filter {
  }

  filter: category_filter {
  }

  filter: asset_type_filter {
  }

  filter: tracker_grouping_filter {
  }

  filter: license_plate_filter {
  }

  filter: make_filter {
  }

  filter: model_filter {
  }

  filter: sub_renting_company_filter {
  }

  filter: sub_renting_contact_filter {
  }

  filter: archived_status_filter {
  }

  filter: date_filter {
    type: date_time
  }

  parameter: show_assets_no_contact_over_72_hrs {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }
}

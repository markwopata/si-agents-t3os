view: fleet_value_actions {
  derived_table: {
    sql: with value_actions as (
    select 'bulk create asset click upload button' as value_action, *
    from heap_main_production.heap.fleet_value_actions_bulk_create_asset_click_upload_button
    union
    select 'create alert rule form click save' as value_action, *
    from heap_main_production.heap.fleet_value_actions_create_alert_rule_form_click_save
    union
    select 'create asset click save asset button' as value_action, *
    from heap_main_production.heap.fleet_value_actions_create_asset_click_save_asset_button
    union
    select 'create geofence page modal click save button' as value_action, *
    from heap_main_production.heap.fleet_value_actions_create_geofence_page_modal_click_save_button
    union
    select 'edit alert rule form click save button' as value_action, *
    from heap_main_production.heap.fleet_value_actions_edit_alert_rule_form_click_save_button
    union
    select 'edit asset tab click save asset button' as value_action, *
    from heap_main_production.heap.fleet_value_actions_edit_asset_tab_click_save_asset_button
    union
    select 'fleet map click apply filters button' as value_action, *
    from heap_main_production.heap.fleet_value_actions_fleet_map_click_apply_filters_button
    union
    select 'fleet map click search assets field' as value_action,
           USER_ID,
           EVENT_ID,
           SESSION_ID,
           TIME,
           TYPE,
           LIBRARY,
           PLATFORM,
           DEVICE_TYPE,
           COUNTRY,
           REGION,
           CITY,
           IP,
           REFERRER,
           LANDING_PAGE,
           LANDING_PAGE_QUERY,
           LANDING_PAGE_HASH,
           BROWSER,
           SEARCH_KEYWORD,
           UTM_SOURCE,
           UTM_CAMPAIGN,
           UTM_MEDIUM,
           UTM_TERM,
           UTM_CONTENT,
           DOMAIN,
           QUERY,
           PATH,
           HASH,
           TITLE,
           HREF,
           TARGET_TEXT,
           HEAP_DEVICE_ID,
           HEAP_PREVIOUS_PAGE,
           SCREEN_DIMENSIONS
    from heap_main_production.heap.FLEET_VALUE_ACTIONS_FLEET_MAP_CLICK_SEARCH_ASSETS_FIELD
    union
    select 'fleet map off rent modal click off rent button' as value_action, *
    from heap_main_production.heap.FLEET_VALUE_ACTIONS_FLEET_MAP_OFF_RENT_MODAL_CLICK_OFF_RENT_BUTTON
    union
    select 'fleet map owned asset location modal click share location button' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_FLEET_MAP_OWNED_ASSET_LOCATION_MODAL_CLICK_SHARE_LOCATION_BUTTON
    union
    select 'fleet map rented asset location modal click share location button' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_FLEET_MAP_RENTED_ASSET_LOCATION_MODAL_CLICK_SHARE_LOCATION_BUTTON
    union
    select 'fleet map service modal click request button' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_FLEET_MAP_SERVICE_MODAL_CLICK_REQUEST_BUTTON
    union
    select 'invoice edit po modal click save button' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_INVOICE_EDIT_PO_MODAL_CLICK_SAVE_BUTTON
    union
    select 'map create geofence modal click save geofence button' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_MAP_CREATE_GEOFENCE_MODAL_CLICK_SAVE_GEOFENCE_BUTTON
    union
    select 'owned asset access tab click add button' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_OWNED_ASSET_ACCESS_TAB_CLICK_ADD_BUTTON
    union
    select 'owned asset history tab view page' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_OWNED_ASSET_HISTORY_TAB_VIEW_PAGE
    union
    select 'rental asset access tab click add button' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_RENTAL_ASSET_ACCESS_TAB_CLICK_ADD_BUTTON
    union
    select 'rental details tab click view rental agreement link' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_RENTAL_DETAILS_TAB_CLICK_VIEW_RENTAL_AGREEMENT_LINK
    union
    select 'rental details tab off rent modal click off rent button' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_RENTAL_DETAILS_TAB_OFF_RENT_MODAL_CLICK_OFF_RENT_BUTTON
    union
    select 'rental details tab service request click request button' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_RENTAL_DETAILS_TAB_SERVICE_REQUEST_CLICK_REQUEST_BUTTON
    union
    select 'rental history tab view page' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_RENTAL_HISTORY_TAB_VIEW_PAGE
    union
    select 'rental table click rent now button' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_RENTAL_TABLE_CLICK_RENT_NOW_BUTTON
    union
    select 'rental table edit purchase order modal click save button' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_RENTAL_TABLE_EDIT_PURCHASE_ORDER_MODAL_CLICK_SAVE_BUTTON
    union
    select 'rental table off rent modal click off rent button' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_RENTAL_TABLE_OFF_RENT_MODAL_CLICK_OFF_RENT_BUTTON
    union
    select 'rental table request service modal click request button' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_RENTAL_TABLE_REQUEST_SERVICE_MODAL_CLICK_REQUEST_BUTTON
    union
    select 'xirgo camera modal click start live stream button' as value_action, *
    from HEAP_MAIN_PRODUCTION.HEAP.FLEET_VALUE_ACTIONS_XIRGO_CAMERA_MODAL_CLICK_START_LIVE_STREAM_BUTTON)

select
       VALUE_ACTION,
       USER_ID,
       EVENT_ID,
       SESSION_ID,
       TIME,
       TYPE,
       LIBRARY,
       PLATFORM,
       DEVICE_TYPE,
       COUNTRY,
       REGION,
       CITY,
       IP,
       REFERRER,
       LANDING_PAGE,
       LANDING_PAGE_QUERY,
       LANDING_PAGE_HASH,
       BROWSER,
       SEARCH_KEYWORD,
       UTM_SOURCE,
       UTM_CAMPAIGN,
       UTM_MEDIUM,
       UTM_TERM,
       UTM_CONTENT,
       DOMAIN,
       QUERY,
       PATH,
       HASH,
       TITLE,
       HREF,
       TARGET_TEXT,
       HEAP_DEVICE_ID,
       HEAP_PREVIOUS_PAGE,
       SCREEN_DIMENSIONS


from value_actions va ;;
  }

  dimension: value_action {
    type: string
    sql: ${TABLE}."VALUE_ACTION" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: event_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
  }

  dimension: session_id {
    type: number
    sql: ${TABLE}."SESSION_ID" ;;
  }

  dimension_group: time {
    type: time
    timeframes: [date, time, week, month, quarter]
    sql: CONVERT_TIMEZONE('America/Chicago', ${TABLE}."TIME") ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: library {
    type: string
    sql: ${TABLE}."LIBRARY" ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: device_type {
    type: string
    sql: ${TABLE}."DEVICE_TYPE" ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: ip {
    type: string
    sql: ${TABLE}."IP" ;;
  }

  dimension: referrer {
    type: string
    sql: ${TABLE}."REFERRER" ;;
  }

  dimension: landing_page {
    type: string
    sql: ${TABLE}."LANDING_PAGE" ;;
  }

  dimension: landing_page_query {
    type: string
    sql: ${TABLE}."LANDING_PAGE_QUERY" ;;
  }

  dimension: landing_page_hash {
    type: string
    sql: ${TABLE}."LANDING_PAGE_HASH" ;;
  }

  dimension: browser {
    type: string
    sql: ${TABLE}."BROWSER" ;;
  }

  dimension: search_keyword {
    type: string
    sql: ${TABLE}."SEARCH_KEYWORD" ;;
  }

  dimension: utm_source {
    type: string
    sql: ${TABLE}."UTM_SOURCE" ;;
  }

  dimension: utm_campaign {
    type: string
    sql: ${TABLE}."UTM_CAMPAIGN" ;;
  }

  dimension: utm_medium {
    type: string
    sql: ${TABLE}."UTM_MEDIUM" ;;
  }

  dimension: utm_term {
    type: string
    sql: ${TABLE}."UTM_TERM" ;;
  }

  dimension: utm_content {
    type: string
    sql: ${TABLE}."UTM_CONTENT" ;;
  }

  dimension: domain {
    type: string
    sql: ${TABLE}."DOMAIN" ;;
  }

  dimension: query {
    type: string
    sql: ${TABLE}."QUERY" ;;
  }

  dimension: path {
    type: string
    sql: ${TABLE}."PATH" ;;
  }

  dimension: hash {
    type: string
    sql: ${TABLE}."HASH" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension: href {
    type: string
    sql: ${TABLE}."HREF" ;;
  }

  dimension: target_text {
    type: string
    sql: ${TABLE}."TARGET_TEXT" ;;
  }

  dimension: heap_device_id {
    type: string
    sql: ${TABLE}."HEAP_DEVICE_ID" ;;
  }

  dimension: heap_previous_page {
    type: string
    sql: ${TABLE}."HEAP_PREVIOUS_PAGE" ;;
  }

  dimension: screen_dimensions {
    type: string
    sql: ${TABLE}."SCREEN_DIMENSIONS" ;;
  }

  # - - - - - MEASURES - - - - -

  measure: count {
    type: count
  }

  # - - - - - SETS - - - - -

  set: event_detail {
    fields: [
      value_action,

    ]
  }
  }

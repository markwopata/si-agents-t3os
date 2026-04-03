view: rental_requests {
    derived_table: {
      sql: select *
              from
              RENTAL_ORDER_REQUEST.PUBLIC.RENTAL_REQUESTS ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension_group: _es_update_timestamp {
      type: time
      sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
    }

    dimension_group: _es_load_timestamp {
      type: time
      sql: ${TABLE}."_ES_LOAD_TIMESTAMP" ;;
    }

    dimension: id {
      type: string
      sql: ${TABLE}."ID" ;;
    }

    dimension: shift_plan_name {
      type: string
      sql: ${TABLE}."SHIFT_PLAN_NAME" ;;
    }

    dimension: dropoff_fee {
      type: number
      sql: ${TABLE}."DROPOFF_FEE" ;;
    }

    dimension: delivery_instructions {
      type: string
      sql: ${TABLE}."DELIVERY_INSTRUCTIONS" ;;
    }

    dimension: shift_plan_description {
      type: string
      sql: ${TABLE}."SHIFT_PLAN_DESCRIPTION" ;;
    }

    dimension: status {
      type: string
      sql: ${TABLE}."STATUS" ;;
    }

    dimension: longitude {
      type: string
      sql: ${TABLE}."LONGITUDE" ;;
    }

    dimension: type {
      type: string
      sql: ${TABLE}."TYPE" ;;
    }

    dimension_group: deleted_at {
      type: time
      sql: ${TABLE}."DELETED_AT" ;;
    }

    dimension: receiver_contact_phone {
      type: string
      sql: ${TABLE}."RECEIVER_CONTACT_PHONE" ;;
    }

    dimension: receiver_option {
      type: string
      sql: ${TABLE}."RECEIVER_OPTION" ;;
    }

    dimension: equipment_charges {
      type: number
      sql: ${TABLE}."EQUIPMENT_CHARGES" ;;
    }

    dimension: branch_id {
      type: string
      sql: ${TABLE}."BRANCH_ID" ;;
    }

    dimension: user_id {
      type: string
      sql: ${TABLE}."USER_ID" ;;
    }

    dimension: state {
      type: string
      sql: ${TABLE}."STATE" ;;
    }

    dimension: rental_subtotal {
      type: number
      sql: ${TABLE}."RENTAL_SUBTOTAL" ;;
    }

    dimension: guest_user_request {
      type: yesno
      sql: ${TABLE}."GUEST_USER_REQUEST" ;;
    }

    dimension: state_name {
      type: string
      sql: ${TABLE}."STATE_NAME" ;;
    }

    dimension: delivery_fee {
      type: number
      sql: ${TABLE}."DELIVERY_FEE" ;;
    }

    dimension: jobsite_address_id {
      type: string
      sql: ${TABLE}."JOBSITE_ADDRESS_ID" ;;
    }

    dimension: rpp_cost {
      type: number
      sql: ${TABLE}."RPP_COST" ;;
    }

    dimension: get_directions_link {
      type: string
      sql: ${TABLE}."GET_DIRECTIONS_LINK" ;;
    }

    dimension: shift_id {
      type: string
      sql: ${TABLE}."SHIFT_ID" ;;
    }

    dimension: rental_protection_plan {
      type: string
      sql: ${TABLE}."RENTAL_PROTECTION_PLAN" ;;
    }

    dimension: dropoff_option {
      type: string
      sql: ${TABLE}."DROPOFF_OPTION" ;;
    }

    dimension: timezone {
      type: string
      sql: ${TABLE}."TIMEZONE" ;;
    }

    dimension: city {
      type: string
      sql: ${TABLE}."CITY" ;;
    }

    dimension: taxes {
      type: number
      sql: ${TABLE}."TAXES" ;;
    }

    dimension: shift_plan_multiplier {
      type: number
      sql: ${TABLE}."SHIFT_PLAN_MULTIPLIER" ;;
    }

    dimension: latitude {
      type: string
      sql: ${TABLE}."LATITUDE" ;;
    }

    dimension: order_total {
      type: number
      sql: ${TABLE}."ORDER_TOTAL" ;;
    }

    dimension: receiver_contact_name {
      type: string
      sql: ${TABLE}."RECEIVER_CONTACT_NAME" ;;
    }

    dimension_group: created_at {
      type: time
      sql: ${TABLE}."CREATED_AT" ;;
    }

    dimension: delivery_option {
      type: string
      sql: ${TABLE}."DELIVERY_OPTION" ;;
    }

    dimension_group: updated_at {
      type: time
      sql: ${TABLE}."UPDATED_AT" ;;
    }

    dimension: location {
      type: location
      sql_latitude: ${TABLE}."LATITUDE" ;;
      sql_longitude: ${TABLE}."LONGITUDE" ;;
    }
    set: detail {
      fields: [
        _es_update_timestamp_time,
        _es_load_timestamp_time,
        id,
        shift_plan_name,
        dropoff_fee,
        delivery_instructions,
        shift_plan_description,
        status,
        longitude,
        type,
        deleted_at_time,
        receiver_contact_phone,
        receiver_option,
        equipment_charges,
        branch_id,
        user_id,
        state,
        rental_subtotal,
        guest_user_request,
        state_name,
        delivery_fee,
        jobsite_address_id,
        rpp_cost,
        get_directions_link,
        shift_id,
        rental_protection_plan,
        dropoff_option,
        timezone,
        city,
        taxes,
        shift_plan_multiplier,
        latitude,
        order_total,
        receiver_contact_name,
        created_at_time,
        delivery_option,
        updated_at_time,
        location
      ]
    }
  }

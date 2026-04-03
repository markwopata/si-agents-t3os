# Commented out due to zero usage on 2026-03-26 — orphaned view, parent model has 0 explores
# view: v_deliveries {
#   derived_table: {
#     sql:
#
# SELECT del.delivery_id
#      , types.name             AS delivery_type
#      , status.name            AS delivery_status
#      , facil.name             AS facilitator_type
#      , del.asset_id
#      , del.rental_id
#      , del.order_id
#      , del.date_created
#      , del.scheduled_date
#      , del.completed_date
#      , del.run_name
#      , del.note
#      , origin.company_id      AS origin_company_id
#      , destination.company_id AS destination_company_id
#   FROM es_warehouse.public.deliveries del
#        JOIN es_warehouse.public.delivery_types types
#             ON del.delivery_type_id = types.delivery_type_id
#        JOIN es_warehouse.public.delivery_statuses status
#             ON del.delivery_status_id = status.delivery_status_id
#        JOIN es_warehouse.public.delivery_facilitator_types facil
#             ON del.facilitator_type_id = facil.delivery_facilitator_type_id
#        LEFT JOIN es_warehouse.public.locations origin
#                  ON del.origin_location_id = origin.location_id
#        LEFT JOIN es_warehouse.public.locations destination
#                  ON del.location_id = destination.location_id
#
#     ;;
#   }
#
#   dimension: delivery_id {
#     primary_key: yes
#     sql: ${TABLE}."DELIVERY_ID" ;;
#   }
#
#   dimension: delivery_type {
#     type: string
#     sql: ${TABLE}."DELIVERY_TYPE" ;;
#   }
#
#   dimension: delivery_status {
#     type: string
#     sql: ${TABLE}."DELIVERY_STATUS" ;;
#   }
#
#   dimension: facilitator_type {
#     type: string
#     sql: ${TABLE}."FACILITATOR_TYPE" ;;
#   }
#
#   dimension: asset_id {
#     type: number
#     sql: ${TABLE}."ASSET_ID" ;;
#   }
#
#   dimension: rental_id {
#     type: number
#     sql: ${TABLE}."RENTAL_ID" ;;
#   }
#
#   dimension: order_id {
#     type: number
#     sql: ${TABLE}."ORDER_ID" ;;
#   }
#
#   dimension_group: created {
#     type: time
#     timeframes: [raw, date, week, month]
#     sql: ${TABLE}."DATE_CREATED" ;;
#   }
#
#   dimension_group: scheduled {
#     type: time
#     timeframes: [raw, date, week, month]
#     sql: ${TABLE}."SCHEDULED_DATE" ;;
#   }
#
#   dimension_group: completed {
#     type: time
#     timeframes: [raw, date, week, month]
#     sql: ${TABLE}."COMPLETED_DATE" ;;
#   }
#
#   dimension: run_name {
#     type: string
#     sql: ${TABLE}."RUN_NAME" ;;
#   }
#
#   dimension: note {
#     type: string
#     sql: ${TABLE}."NOTE" ;;
#   }
#
#   dimension: origin_company_id {
#     type: number
#     sql: ${TABLE}."ORIGIN_COMPANY_ID" ;;
#   }
#
#   dimension: destination_company_id {
#     type: number
#     sql: ${TABLE}."DESTINATION_COMPANY_ID" ;;
#   }
#
#   # - - - - - MEASURES - - - - -
#
#   measure: count {
#     type: count
#     drill_fields: [delivery_type, delivery_status, facilitator_type, asset_id, rental_id, completed_date]
#   }
#
#   measure: perc_of_total {
#     type: percent_of_total
#     sql: ${count} ;;
#   }
#
# }

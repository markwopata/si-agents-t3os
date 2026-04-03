connection: "reportingc_warehouse"

include: "/views/*.view.lkml"
  explore:  notification_delivery_logs {
    sql_always_where: ${users.company_id} = {{ _user_attributes['company_id'] }}::numeric
        AND (${notification_delivery_logs.tracking_incident_id} is not null OR ${notification_delivery_logs.tracking_diagnostic_codes_id} is not null);;
    group_label: "Fleet"
    label: "Asset Alert Notifications"
    case_sensitive: no
    persist_for: "10 minutes"

 #   ${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))

    join: tracking_diagnostic_codes {
      type: left_outer
      relationship: many_to_one
      sql_on: ${notification_delivery_logs.tracking_diagnostic_codes_id} = ${tracking_diagnostic_codes.tracking_diagnostic_codes_id} ;;
    }

    join: tracking_obd_dtc_codes {
      type: left_outer
      relationship: many_to_one
      sql_on: ${tracking_diagnostic_codes.tracking_obd_dtc_code_id} = ${tracking_obd_dtc_codes.tracking_obd_dtc_code_id} ;;
    }

    join: tracking_incidents {
      type: left_outer
      relationship: many_to_one
      sql_on: ${notification_delivery_logs.tracking_incident_id} = ${tracking_incidents.tracking_incident_id} ;;
    }

    join: notification_types {
      type: left_outer
      relationship: one_to_many
      sql_on: ${notification_types.notification_type_id} = ${notification_delivery_logs.notification_type_id} ;;
    }

    join: asset_alert_rules {
      type: left_outer
      relationship: one_to_many
      sql_on: ${asset_alert_rules.asset_alert_rule_id} = ${notification_delivery_logs.asset_alert_rule_id} ;;
    }

    join: assets {
      type: left_outer
      relationship: many_to_one
      sql_on:${tracking_diagnostic_codes.asset_id} = ${assets.asset_id} OR  ${tracking_incidents.asset_id} = ${assets.asset_id} ;;
    }

    join: users {
      type: left_outer
      relationship: many_to_one
      sql_on: ${notification_delivery_logs.user_id} = ${users.user_id} ;;
    }

    join: asset_types {
      type: left_outer
      relationship: many_to_one
      sql_on: ${asset_types.asset_type_id} = ${assets.asset_type_id} ;;
    }

    join: categories {
      type: left_outer
      relationship: many_to_one
      sql_on: ${categories.category_id} = ${assets.category_id} ;;
    }


    }

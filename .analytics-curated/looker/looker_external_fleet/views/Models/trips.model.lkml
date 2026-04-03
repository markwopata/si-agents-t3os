connection: "reportingc_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: assets {
  sql_always_where: ${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
      OR
      ${asset_id} in (select asset_id from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start trip_log_details.date_filter %}), convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end trip_log_details.date_filter %}), '{{ _user_attributes['user_timezone'] }}')))
      ;;
      # ${asset_id} in (select asset_id from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', current_date::timestamp_ntz), convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',  current_date::timestamp_ntz), '{{ _user_attributes['user_timezone'] }}')))
    group_label: "Trips"
    label: "Trip Detail and Log"
    case_sensitive: no
    persist_for: "30 minutes"

    join: asset_types {
      type: left_outer
      relationship: many_to_one
      sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
    }

    join: organization_asset_xref {
      type: left_outer
      relationship: many_to_one
      sql_on: ${assets.asset_id} = ${organization_asset_xref.asset_id} ;;
    }

    join: organizations {
      type: left_outer
      relationship: one_to_many
      sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
    }

    join: categories {
      type: left_outer
      relationship: many_to_one
      sql_on: ${categories.category_id} = ${assets.category_id} ;;
    }

    join: markets {
      type: left_outer
      relationship: many_to_one
      sql_on: ${markets.market_id} = ${assets.inventory_branch_id} ;;
    }

    join: trip_log_details {
      type: left_outer
      relationship: many_to_one
      sql_on: ${trip_log_details.asset_id} = ${assets.asset_id} ;;
    }

    join: trip_detail_history {
      type: left_outer
      relationship: many_to_one
      sql_on: ${trip_detail_history.asset_id} = ${assets.asset_id} ;;
    }
  }

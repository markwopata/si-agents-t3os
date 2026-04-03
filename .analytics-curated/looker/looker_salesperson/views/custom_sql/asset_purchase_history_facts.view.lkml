view: asset_purchase_history_initial {
  derived_table: {
    sql:
    SELECT asset_id
    , max(purchase_history_id) as latest_purchase_id
    , min(purchase_history_id) as original_purchase_id
    , max(coalesce(oec,purchase_price)) as highest_purchase_price
    , min(coalesce(oec,purchase_price)) as lowest_purchase_price
    FROM ES_WAREHOUSE.PUBLIC.asset_purchase_history
    GROUP BY 1
    ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: latest_purchase_id {
    type: number
    sql: ${TABLE}.latest_purchase_id ;;
  }

  dimension: original_purchase_id {
    type: number
    sql: ${TABLE}.original_purchase_id ;;
  }

  dimension: highest_purchase_price {
    type: number
    sql: ${TABLE}.highest_purchase_price ;;
  }

  dimension: lowest_purchase_price {
    type: number
    sql: ${TABLE}.lowest_purchase_price ;;
  }

}

view: asset_purchase_history_facts_intermediary {
  derived_table: {
    sql:
    SELECT asset_purchase_history_initial.asset_id
    , asset_purchase_history_initial.latest_purchase_id
    , asset_purchase_history_initial.original_purchase_id
    , asset_purchase_history_initial.highest_purchase_price
    , asset_purchase_history_initial.lowest_purchase_price
    , coalesce(asset_purchase_history.oec,asset_purchase_history.purchase_price) as original_purchase_price
    FROM ${asset_purchase_history_initial.SQL_TABLE_NAME} LEFT JOIN ES_WAREHOUSE.PUBLIC.asset_purchase_history ON asset_purchase_history_initial.original_purchase_id = asset_purchase_history.purchase_history_id
    ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: latest_purchase_id {
    type: number
    sql: ${TABLE}.latest_purchase_id ;;
  }

  dimension: original_purchase_id {
    type: number
    sql: ${TABLE}.original_purchase_id ;;
  }

  dimension: highest_purchase_price {
    type: number
    sql: ${TABLE}.highest_purchase_price ;;
  }

  dimension: lowest_purchase_price {
    type: number
    sql: ${TABLE}.lowest_purchase_price ;;
  }

  dimension: original_purchase_price {
    type: number
    sql: ${TABLE}.original_purchase_price ;;
  }

  measure: sum_purchase_price {
    type: sum
    sql: ${TABLE}.highest_purchase_price;;
  }

}

view: asset_purchase_history_facts_final {
  derived_table: {
    # datagroup_trigger: 6AM_update
    sql:
    SELECT asset_purchase_history_facts_intermediary.asset_id
    , asset_purchase_history_facts_intermediary.latest_purchase_id
    , asset_purchase_history_facts_intermediary.original_purchase_id
    , asset_purchase_history_facts_intermediary.highest_purchase_price
    , asset_purchase_history_facts_intermediary.lowest_purchase_price
    , asset_purchase_history_facts_intermediary.original_purchase_price
    , coalesce(asset_purchase_history.oec,asset_purchase_history.purchase_price) as latest_purchase_price
    ,current_date() as last_updated
    FROM ${asset_purchase_history_facts_intermediary.SQL_TABLE_NAME} LEFT JOIN ES_WAREHOUSE.PUBLIC.asset_purchase_history ON asset_purchase_history_facts_intermediary.latest_purchase_id = asset_purchase_history.purchase_history_id
    ;;
  }

  dimension: asset_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: latest_purchase_id {
    hidden: no
    type: number
    sql: ${TABLE}.latest_purchase_id ;;
  }

  dimension: original_purchase_id {
    hidden: yes
    type: number
    sql: ${TABLE}.original_purchase_id ;;
  }

  dimension: highest_purchase_price {
    type: number
    sql: ${TABLE}.highest_purchase_price ;;
    value_format_name: usd
  }

  dimension: lowest_purchase_price {
    type: number
    sql: ${TABLE}.lowest_purchase_price ;;
    value_format_name: usd
  }

  dimension: original_purchase_price {
    type: number
    sql: ${TABLE}.original_purchase_price ;;
    value_format_name: usd
  }

  dimension: latest_purchase_price {
    type: number
    sql: ${TABLE}.latest_purchase_price ;;
    value_format_name: usd
  }

  dimension: historic_price_change {
    group_label: "Price Metrics"
    description: "difference in price from original to current price"
    type: number
    sql: ${latest_purchase_price} - ${original_purchase_price} ;;
    value_format_name: usd
  }

  dimension: peak_price_change {
    group_label: "Price Metrics"
    description: "difference in price from highest to current price"
    type: number
    sql: ${highest_purchase_price} - ${latest_purchase_price} ;;
    value_format_name: usd
  }

  measure: OEC {
    label: "OEC"
    description: "sum of the latest purchase price"
    type: sum
    sql: ${latest_purchase_price} ;;
    value_format: "$#,##0"
    drill_fields: [assets.asset_id,equipment_assignments.start_date,assets.make_and_model,assets.name, OEC]
  }

  measure: average_historic_price_change {
    description: "sum of difference in price from original to current price"
    type: average
    sql: ${historic_price_change} ;;
    value_format_name: usd
  }

  measure: average_peak_price_change {
    description: "average of difference in price from highest to current price"
    type: average
    sql: ${peak_price_change} ;;
    value_format_name: usd
  }

  measure: unavailable_oec {
    description: "Total Amount of OEC that falls in an inventory status of pending return, make ready, needs inspection, soft down, hard down"
    type: sum
    sql: CASE WHEN ${asset_status_key_values.value} IN ('Pending Return','Make Ready','Needs Inspection', 'Soft Down','Hard Down') then ${latest_purchase_price} ELSE null END ;;
  }

#   measure: unavailable_oec_service {
#     description: "Total Amount of OEC that falls in an inventory status of make ready, needs inspection, soft down, hard down"
#     type: sum
#     sql: CASE WHEN ${asset_status_key_values.value} IN ('Make Ready','Needs Inspection', 'Soft Down','Hard Down') then ${latest_purchase_price} ELSE null END ;;

# #     filters: {
# #       field: markets.is_public_rsp
# #       value: "yes"
# #     }
# #
# #     filters: {
# #       field: markets.company_id
# #       value: "1854"
# #     }

#     filters: [
#       markets.company_id: "1854",
#       markets.is_public_rsp: "yes"
#     ]

#     # filters: {
#     #   field: assets.deleted
#     #   value: "no"
#     # }

#     # filters: {
#     #   field: assets.available_for_rent
#     #   value: "yes"
#     # }

#     # filters: {
#     #   field: assets.asset_type_id
#     #   value: "1"
#     # }

#   }

  measure: on_rent_oec {
    description: "Total Amount of On Rent OEC"
    type: sum
    # sql: CASE WHEN coalesce(${asset_statuses.asset_inventory_status},${asset_statuses.asset_rental_status}) IN ('On Rent') then ${latest_purchase_price} ELSE 0 END ;;
    sql: CASE WHEN ${asset_status_key_values.value} IN ('On Rent') then ${latest_purchase_price} ELSE 0 END ;;
  }

  measure:  on_rent_oec_perc{
    description: "%age of on rent assets"
    type: number
    #filters: [OEC: "> 0"]
    sql: CASE WHEN ${asset_purchase_history_facts_final.OEC} >0 THEN 100.0 * (${asset_purchase_history_facts_final.on_rent_oec} / ${asset_purchase_history_facts_final.OEC}) ELSE 0 END ;;
    value_format: "0.0\%"
  }

  measure:  unavailable_oec_perc{
    description: "%age of unavailable assets"
    type: number
    sql: (${asset_purchase_history_facts_final.unavailable_oec} / ${asset_purchase_history_facts_final.OEC}) * 100;;
    value_format: "0.0\%"
  }

  # measure:  unavailable_oec_percent_service{
  #   description: "%age of unavailable assets"
  #   type: number
  #   sql: (${asset_purchase_history_facts_final.unavailable_oec_service} / ${asset_purchase_history_facts_final.OEC});;
  # }

  # measure:  unavailable_oec_percent_service_as_percentage{
  #   description: "%age of unavailable assets"
  #   type: number
  #   value_format: "0.0\%"
  #   sql: (${asset_purchase_history_facts_final.unavailable_oec_service} / ${asset_purchase_history_facts_final.OEC}) * 100;;
  # }

  measure: unavailable_percent {
    #Place number of statuses out of the asset statuses table in view if it errors out on not including assets status in from clause
    description: "% of unavailable OEC - Place number of statuses out of the asset statuses table in view if it errors out on not including assets status in from clause"
    type: number
    sql: ${unavailable_oec} / (CASE WHEN ${OEC} = 0 THEN 1 ELSE ${OEC} END) ;;
  }

  measure: unavailable_oec_percent_market_drill {
    #Place number of statuses out of the asset statuses table in view if it errors out on not including assets status in from clause
    description: "% of unavailable OEC - Place number of statuses out of the asset statuses table in view if it errors out on not including assets status in from clause"
    type: number
    sql: (${unavailable_oec} / (CASE WHEN ${OEC} = 0 THEN 1 ELSE ${OEC} END))*100 ;;
    drill_fields: [market_region_xwalk.market_name, unavailable_oec_perc, asset_status_key_values.number_of_statuses]
    value_format: "##.0\%"
  }

  dimension: goal_text {
    type: string
    sql: 'Goal:' ;;
  }

#This measure is created as pseudo values to correct the range in Unavailable Assets % by OEC Gauge visaulization.
  measure:  unavailable_oec_new {
    sql:
      case
        When ${asset_purchase_history_facts_final.unavailable_oec_perc} = 0
        THEN '0'

        When ${asset_purchase_history_facts_final.unavailable_oec_perc} >= 0.01 AND ${asset_purchase_history_facts_final.unavailable_oec_perc} <= 1.60
        THEN '1'

        When ${asset_purchase_history_facts_final.unavailable_oec_perc} >= 1.61 AND ${asset_purchase_history_facts_final.unavailable_oec_perc} <= 4
        THEN '3'

        When ${asset_purchase_history_facts_final.unavailable_oec_perc} >= 4.01 AND ${asset_purchase_history_facts_final.unavailable_oec_perc} <= 5.50
        THEN '6'

        When ${asset_purchase_history_facts_final.unavailable_oec_perc} >= 5.51 AND ${asset_purchase_history_facts_final.unavailable_oec_perc} <= 7.20
        THEN '8'

        When ${asset_purchase_history_facts_final.unavailable_oec_perc} >= 8.01 AND ${asset_purchase_history_facts_final.unavailable_oec_perc} <= 8.57
        THEN '11'

        When ${asset_purchase_history_facts_final.unavailable_oec_perc} >= 8.58 AND ${asset_purchase_history_facts_final.unavailable_oec_perc} <= 8.95
        THEN '13'

        When ${asset_purchase_history_facts_final.unavailable_oec_perc} >= 8.96 AND ${asset_purchase_history_facts_final.unavailable_oec_perc} <= 9.33
        THEN '15'

       When ${asset_purchase_history_facts_final.unavailable_oec_perc} >= 9.34 AND ${asset_purchase_history_facts_final.unavailable_oec_perc} <= 9.71
        THEN '17'

        When ${asset_purchase_history_facts_final.unavailable_oec_perc} >= 9.72 AND ${asset_purchase_history_facts_final.unavailable_oec_perc} <= 10
        THEN '19'

        When${asset_purchase_history_facts_final.unavailable_oec_perc} >= 10.01 AND ${asset_purchase_history_facts_final.unavailable_oec_perc} <= 12.99
        THEN '21'

        When${asset_purchase_history_facts_final.unavailable_oec_perc} >= 13 AND ${asset_purchase_history_facts_final.unavailable_oec_perc} <= 14.99
        THEN '22'

        When ${asset_purchase_history_facts_final.unavailable_oec_perc} >= 15 AND ${asset_purchase_history_facts_final.unavailable_oec_perc} <= 17.99
        THEN '24'

         When ${asset_purchase_history_facts_final.unavailable_oec_perc} >= 18 AND ${asset_purchase_history_facts_final.unavailable_oec_perc} <= 21.99
        THEN '26'

         When ${asset_purchase_history_facts_final.unavailable_oec_perc} >= 22 AND ${asset_purchase_history_facts_final.unavailable_oec_perc} <= 24.99
        THEN '28'

         When ${asset_purchase_history_facts_final.unavailable_oec_perc} >= 25
        THEN '30'

        end;;
  }

  # measure:  unavailable_oec_for_service {
  #   sql:
  #     case WHEN ${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage} = null THEN '1'


  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 0 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 1.60
  #       THEN '1'

  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 1.61 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 4
  #       THEN '3'

  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 4.01 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 5.50
  #       THEN '6'

  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 5.51 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 6.99
  #       THEN '8'

  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 7.00 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 8.09
  #       THEN '10'

  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 8.1 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 8.57
  #       THEN '11'

  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 8.58 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 8.95
  #       THEN '13'

  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 8.96 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 9.33
  #       THEN '15'

  #     When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 9.34 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 9.71
  #       THEN '18'

  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 9.72 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 10
  #       THEN '20'

  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 10.01 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 12.99
  #       THEN '21'

  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 13 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 14.99
  #       THEN '22'

  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 15 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 17.99
  #       THEN '24'

  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 18 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 21.99
  #       THEN '26'

  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 22 AND ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) <= 24.99
  #       THEN '28'

  #       When ROUND(${asset_purchase_history_facts_final.unavailable_oec_percent_service_as_percentage},2) >= 25
  #       THEN '30'

  #       end;;
  # }
}

view: collector_targets_charts {
  sql_table_name: "ANALYTICS"."TREASURY"."COLLECTOR_TARGETS_CHARTS" ;;

##### DIMENSIONS #####

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

  dimension: customer_id {
    value_format_name: id
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: manager {
    type: string
    suggest_persist_for: "1 minute"
    sql: ${TABLE}."MANAGER" ;;
  }

  dimension: quarter {
    type: string
    sql: '2026-Q1' ;;
  }

  dimension: collector_email_address {
    type: string
    sql: ${TABLE}."COLLECTOR_EMAIL_ADDRESS" ;;
  }

  dimension: is_collector {
    type: yesno
    sql: (LOWER(${collector_email_address}) = LOWER('{{ _user_attributes['email'] }}')) OR
         (LOWER('{{ _user_attributes['email'] }}') in (
        'lewis.hornsby@equipmentshare.com',
        'ashley.dominguez@equipmentshare.com',
        'tiffany.brown@equipmentshare.com',
        'greg.stegeman@equipmentshare.com',
        'cassondra.simon@equipmentshare.com',
        'rhiannon.mitchell@equipmentshare.com',
        'paul.logue@equipmentshare.com',
        'mark.wopata@equipmentshare.com',
        'jabbok@equipmentshare.com',
        'regina.stuart@equipmentshare.com',
        'erica.parsons@equipmentshare.com'
        )) ;;
  }


  ##### MEASURES #####

  measure: actual_collections {
    value_format_name: usd_0
    type: sum
    drill_fields: [target_details*]
    sql: ${TABLE}."ACTUAL_COLLECTIONS" ;;
  }

  measure: collections_target {
    value_format_name: usd_0
    type: sum
    drill_fields: [target_details*]
    sql: ${TABLE}."COLLECTIONS_TARGET" ;;
  }

  measure: amount_to_be_collected {
    type: number
    drill_fields: [target_details*]
    sql: ${collections_target} - ${actual_collections} ;;
    value_format_name: usd_0
  }

  measure: run_rate_collections {
    label: "Run Rate Collections"
    type: number
    drill_fields: [target_details*]
    sql: (${actual_collections} / datediff(day, '2025-12-31', current_date)) * 90 ;;
    value_format_name: usd_0
  }

  measure: amount_to_be_collected_run_rate {
    label: "Amount to be Collected Run Rate"
    type: number
    drill_fields: [target_details*]
    sql: iff(${collections_target} - ${run_rate_collections}<=0,0,${collections_target} - ${run_rate_collections}) ;;
    value_format_name: usd_0
  }

  ##### DRILL FIELDS #####

  set: target_details {
    fields: [customer_id,collector,manager,actual_collections,collections_target,amount_to_be_collected]
  }

}


view: branch_cash_collection_goals {
  derived_table: {
    sql: with branch_target as (
      select
          region_district,
          branch_id,
          branch_name,
          collections_target
      from
        analytics.treasury.collection_targets_branch_district
      )
      , branch_collected as (
      select
          branch_id,
          branch_name,
          region_district,
          sum(payment_amount) as collected_amount
      from
          analytics.treasury.collections_actuals_payments
      group by
          branch_id,
          branch_name,
          region_district
      )
      select
      mrx.region_name,
      bt.region_district,
      bt.branch_id,
      bt.branch_name,
      bt.collections_target,
      coalesce(bc.collected_amount,0) as collected_amount,
      case
      when coalesce(bc.collected_amount,0) = 0 then bt.collections_target
      when bt.collections_target is null or bt.collections_target = 0 then 0
      when bc.collected_amount >= bt.collections_target then 0
      else bt.collections_target - bc.collected_amount end as amount_to_be_collected
      from
      branch_target bt
      left join branch_collected bc on bt.branch_id = bc.branch_id
      left join analytics.public.market_region_xwalk mrx on mrx.market_id = bt.branch_id
      where
      (
      'developer' = {{ _user_attributes['department'] }}
      OR 'god view' = {{ _user_attributes['department'] }}
      OR 'managers' = {{ _user_attributes['department'] }}
      OR 'collectors' = {{ _user_attributes['department'] }}
      )
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    label: "Branch"
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: collections_target {
    type: number
    sql: ${TABLE}."COLLECTIONS_TARGET" ;;
  }

  dimension: collected_amount {
    type: number
    sql: ${TABLE}."COLLECTED_AMOUNT" ;;
  }

  dimension: amount_to_be_collected {
    type: number
    sql: ${TABLE}."AMOUNT_TO_BE_COLLECTED" ;;
  }

  measure: total_collected_amount {
    label: "Total Collected"
    type: sum
    sql: ${collected_amount} ;;
    value_format_name: usd_0
    drill_fields: [total_collected_drill*]
  }

  measure: total_to_be_collected_amount {
    label: "Amount to be Collected"
    type: sum
    sql: ${amount_to_be_collected} ;;
    value_format_name: usd_0
    drill_fields: [total_collected_drill*]
  }

  set: total_collected_drill {
    fields: [
      region_district,
      branch_name,
      branch_cash_collection_goals_drill.company_name,
      branch_cash_collection_goals_drill.invoice_no,
      branch_cash_collection_goals_drill.total_collected
    ]
  }

  # branch_id,
  # branch_name,
  # region_name,
  # district,
  # region_district,
  # salesperson_user_id,
  # invoice_no,
  # payment_amount,
  # company_name

  set: detail {
    fields: [
        region_district,
  branch_id,
  branch_name,
  collections_target,
  collected_amount,
  amount_to_be_collected
    ]
  }
}

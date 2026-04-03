
view: salesrep_cash_collection_goal {
  derived_table: {
    sql: with rep_target as (
    select
    salesperson_user_id,
    collections_target
    from
    analytics.treasury.collection_targets_salesperson
    )
    , rep_collected as (
    select
    salesperson_user_id,
    salesperson_name,
    sum(payment_amount) as collected_amount
    from
    analytics.treasury.collections_actuals_payments
    group by
    salesperson_user_id,
    salesperson_name
    )
    select
    rt.salesperson_user_id,
    concat(u.first_name,' ',u.last_name) as rep_name,
    concat(u.first_name,' ',u.last_name,' - ',u.user_id) as full_name_with_id,
    rt.collections_target,
    coalesce(rc.collected_amount,0) as collected_amount,
    case
    when coalesce(rc.collected_amount,0) = 0 then rt.collections_target
    when rt.collections_target is null or rt.collections_target = 0 then 0
    when rc.collected_amount >= rt.collections_target then 0
    else rt.collections_target - rc.collected_amount end as amount_to_be_collected
    from
    rep_target rt
    left join rep_collected rc on rt.salesperson_user_id = rc.salesperson_user_id
    left join es_warehouse.public.users u on u.user_id = rt.salesperson_user_id
    where
    (
    ('salesperson' = {{ _user_attributes['department'] }} AND u.deleted = 'No' AND u.email_address ILIKE '{{ _user_attributes['email'] }}')
    )
    OR
    (
    ('salesperson' != {{ _user_attributes['department'] }}
    AND
    ('developer' = {{ _user_attributes['department'] }}
    OR 'god view' = {{ _user_attributes['department'] }}
    OR 'managers' = {{ _user_attributes['department'] }}
    OR 'collectors' = {{ _user_attributes['department'] }})
    )
    )
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: rep_name {
    label: "Salesperson"
    type: string
    sql: ${TABLE}."REP_NAME" ;;
  }

  dimension: full_name_with_id {
    type: string
    sql: ${TABLE}."FULL_NAME_WITH_ID" ;;
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
      rep_name,
      salesrep_cash_collection_goal_drill.company_name,
      salesrep_cash_collection_goal_drill.invoice_no,
      salesrep_cash_collection_goal_drill.total_collected
    ]
  }

  set: detail {
    fields: [
        salesperson_user_id,
  rep_name,
  full_name_with_id,
  collections_target,
  collected_amount,
  amount_to_be_collected
    ]
  }
}

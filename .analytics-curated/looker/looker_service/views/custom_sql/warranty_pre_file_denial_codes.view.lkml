view: warranty_pre_file_denial_codes {
  derived_table: {
    sql:
select won.work_order_id
    , u.user_id
    , concat(u.first_name,' ', u.last_name) as full_name
    , pfdc.name as denial_code
    , won.date_created
    , lead(won.date_created) over (partition by won.work_order_id order by won.date_created asc) as last_update_check
from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_NOTES won
join ANALYTICS.WARRANTIES.PRE_FILE_DENIAL_CODES pfdc
    on pfdc.letter_code = left(won.note, 1)
join ES_WAREHOUSE.PUBLIC.USERS u
    on u.user_id = won.creator_user_id
where (note ilike 'A - Incorrect Billing Type;%'
    or note ilike 'B - Maintenance;%'
    or note ilike 'C - Normal Wear/Tear;%'
    or note ilike 'D - Failure is not covered by Active Warranty;%'
    or note ilike 'E - Non-OEM Parts Used;%'
    or note ilike 'F - Customer Damage;%'
    or note ilike 'G - Dealer Only Repair;%'
    or note ilike 'H - Outside Repair Not Authorized;%'
    or note ilike 'I - Timeframe to File Expired;%'
    or note ilike 'J - Repair not performed to OEM Standard;%'
    or note ilike 'K - Out of Warranty;%'
    or note ilike 'L - Requested Info Not Provided;%')
    and archived_date is null
qualify last_update_check is null ;;
  }

dimension: work_order_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.work_order_id ;;
}

dimension: user_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.user_id ;;
}

dimension: admin {
  type: string
  sql: ${TABLE}.full_name ;;
}

dimension: denial_code {
  type: string
  sql: ${TABLE}.denial_code ;;
}

dimension_group: created {
  type: time
  timeframes: [
    raw,
    time,
    date,
    week,
    month,
    quarter,
    year
  ]
  sql: CAST(${TABLE}.date_created AS TIMESTAMP_NTZ) ;;
}

measure: count {
  type: count
  drill_fields: [
    work_orders.work_order_id_with_link_to_work_order
    , work_orders.description
    , denial_code
    , created_date
    , work_orders.asset_id
    , assets_aggregate.make
    , assets_aggregate.model
  ]
}
}

view: distribution_center_transactions {
  derived_table: {
    sql:
      with dc_to_dc as ( -- Gives DC->DC transactions that need to be filtered out
    select distinct TRANSACTION_ID
    from analytics.intacct_models.part_inventory_transactions
    where (to_id in ('9814','432') and from_id in ('9814','432'))
      and TRANSACTION_TYPE_ID = 6
),
     first_inbound as ( -- gives min date a part was transferred from a branch to the DC
         select part_id,
                min(date_completed) as first_received_at
         from analytics.intacct_models.part_inventory_transactions
         where transaction_type = 'Store to Store'
           and to_id in ('9814', '432')
           and date_completed is not null
           and TRANSACTION_ID not in (select TRANSACTION_ID from dc_to_dc)  -- filtering out DC -> DC transactions
           and MARKET_NAME = 'Distribution Center'
         group by 1)
-- all completed transactions going too or from the DC
         select pit.transaction_id,
                pit.TRANSACTION_ITEM_ID,
                m.MARKET_ID as to_from_market_id,
                m.MARKET_NAME as to_from_market_name,
                pit.part_id,
                pit.PART_NUMBER,
                pit.DESCRIPTION,
                p.PART_PROVIDER_NAME,
                p.PART_CATEGORY_NAME,
                pit.ROOT_PART_ID,
                pit.ROOT_PART_DESCRIPTION,
                pit.date_completed,
                pit.transaction_type,
                pit.transaction_type_id,
                pit.MANUAL_ADJUSTMENT_REASON,
                pit.from_id,
                pit.to_id,
                abs(pit.quantity) as quantity,
                pit.cost,
                pit.weighted_average_cost,
                case
                    when pit.to_id in ('9814', '432')
                        then 'Inbound'
                    else 'Outbound' end as DC_Direction,         -- entering or leaving DC flag
                case
                    when pit.date_completed >= fi.first_received_at
                        then TRUE
                    else FALSE end     as is_post_first_receipt, -- transaction occurred before or after first time that part was sent from branch to the DC
                case
                    when fi.first_received_at is not null
                        then TRUE
                    else FALSE end as part_transferred_to_dc
         from analytics.intacct_models.part_inventory_transactions pit
                  left join first_inbound fi
                            on pit.part_id = fi.part_id
                  left join FLEET_OPTIMIZATION.GOLD.DIM_PARTS_FLEET_OPT p on pit.PART_ID = p.PART_ID
                  LEFT JOIN platform.gold.DIM_INVENTORY_LOCATIONS il
                            ON (
                                   CASE
                                       WHEN pit.TO_ID   IN ('9814','432') THEN pit.FROM_ID   -- inbound to DC, market is the from side
                                       WHEN pit.FROM_ID IN ('9814','432') THEN pit.TO_ID     -- outbound from DC, market is the to side
                                       ELSE NULL
                                       END
                                   ) = il.inventory_location_id
                  left join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m on il.INVENTORY_LOCATION_MARKET_ID = m.MARKET_ID
         where (pit.to_id in ('9814', '432') or pit.from_id in ('9814', '432'))    -- filtering to transactions going to or from DC
           and DATE_CANCELLED is null                                              -- filtering out cancelled transactions
           and TRANSACTION_TYPE_ID not in ('5', '14', '19', '20') -- filtering out unneeded transaction types
           and TRANSACTION_ID not in (select TRANSACTION_ID from dc_to_dc) -- filtering out DC -> DC transactions
           and TRANSACTION_STATUS = 'Completed'
           and pit.MARKET_NAME = 'Distribution Center'
          ;;
  }

  dimension: transaction_id {
    type: string
    sql: ${TABLE}.TRANSACTION_ID ;;
  }

  dimension: to_from_market_id {
    type: string
    sql:${TABLE}.to_from_market_id ;;
  }

  dimension:  to_from_market_name{
    type: string
    sql: ${TABLE}.to_from_market_name ;;
  }

  dimension: part_id {
    type: string
    sql: ${TABLE}.PART_ID ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}.PART_NUMBER ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.DESCRIPTION ;;
  }

  dimension: part_provider_name {
    type: string
    sql: ${TABLE}.part_provider_name ;;
  }

  dimension: part_category_name {
    type: string
    sql: ${TABLE}.part_category_name ;;
  }

  dimension: root_part_id {
    type: string
    sql: ${TABLE}.ROOT_PART_ID ;;
  }

  dimension: root_part_description {
    type: string
    sql: ${TABLE}.ROOT_PART_DESCRIPTION ;;
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}.TRANSACTION_TYPE ;;
  }

  dimension: transaction_type_id {
    type: number
    sql: ${TABLE}.TRANSACTION_TYPE_ID ;;
  }

  dimension: manual_adjustment_reason {
    type: string
    sql: ${TABLE}.MANUAL_ADJUSTMENT_REASON ;;
  }

  dimension: from_id {
    type: string
    sql: ${TABLE}.FROM_ID ;;
  }

  dimension: to_id {
    type: string
    sql: ${TABLE}.TO_ID ;;
  }

  dimension_group: date_completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.DATE_COMPLETED ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.QUANTITY ;;
  }

  dimension: cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.COST ;;
  }

  dimension: weighted_average_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.WEIGHTED_AVERAGE_COST ;;
  }

  dimension: dc_direction {
    type: string
    sql: ${TABLE}.dc_direction ;;
  }

  measure: transaction_count {
    type: count
    drill_fields: [transaction_id, part_id, part_number, date_completed_date, transaction_type]
  }

  measure: total_quantity {
    type: sum
    sql: ${quantity} ;;
  }

  measure: total_cost {
    type: sum
    value_format_name: usd
    sql: ${cost} ;;
  }

  measure: total_weighted_average_cost {
    type: sum
    value_format_name: usd
    sql: ${weighted_average_cost} ;;
  }

  dimension: is_post_first_receipt {
    type: yesno
    sql: ${TABLE}.IS_POST_FIRST_RECEIPT ;;
  }

  dimension: part_transferred_to_dc {
    type: yesno
    sql: ${TABLE}.part_transferred_to_dc ;;
  }

  measure: inbound_units {
    type: sum
    sql: ${quantity} ;;
    filters: [dc_direction: "Inbound"]
    value_format_name: decimal_0
  }

  measure: outbound_units {
    type: sum
    sql: ${quantity} ;;
    filters: [dc_direction: "Outbound"]
    value_format_name: decimal_0
  }

  measure: inbound_dollars {
    type: sum
    sql: ${cost} ;;
    filters: [dc_direction: "Inbound"]
    value_format_name: usd
  }

  measure: outbound_dollars {
    type: sum
    sql: ${cost} ;;
    filters: [dc_direction: "Outbound"]
    value_format_name: usd
  }
}

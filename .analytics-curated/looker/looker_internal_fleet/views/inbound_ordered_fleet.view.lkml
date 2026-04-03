

view: inbound_ordered_fleet {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: select
              mar.market_id,
              mar.name,
              mak.equipment_make_id,
              mak.name,
              mod.name,
              mod.equipment_model_id,
              sum(case when cpoli.ORDER_STATUS ilike 'ordered' then 1 else 0 end) as ordered_count,
              sum(case when cpoli.ORDER_STATUS ilike 'shipped' then 1 else 0 end) as shipped_count,
              sum(case when cpoli.ORDER_STATUS ilike 'okay to ship' then 1 else 0 end) as okay_to_ship_count

              from COMPANY_PURCHASE_ORDER_LINE_ITEMS cpoli

            left join assets a
                on cpoli.ASSET_ID = a.ASSET_ID

            join EQUIPMENT_MODELS mod
                on cpoli.EQUIPMENT_MODEL_ID = mod.EQUIPMENT_MODEL_ID

            join EQUIPMENT_MAKES mak
                on mod.EQUIPMENT_MAKE_ID = mak.EQUIPMENT_MAKE_ID

            left join MARKETS mar
                on cpoli.MARKET_ID = mar.MARKET_ID

            group by mar.market_id, mak.equipment_make_id, mod.equipment_model_id, mar.name, mak.name, mod.name

            order by mar.name, mak.name, mod.name
      ;;
  }

  # Define your dimensions and measures here, like this:
  dimension: market_id {
    type: number
    sql: ${TABLE}.market_id ;;
  }

  dimension: equipment_make_id {
    type: number
    sql: ${TABLE}.equipment_make_id ;;
  }

  dimension: equipment_model_id {
    type: number
    sql: ${TABLE}.equipment_model_id ;;
  }

  dimension: ordered_count {
    type:  number
    sql: ${TABLE}.ordered_count ;;
  }

  dimension: shipped_count {
    type:  number
    sql: ${TABLE}.shipped_count ;;
  }

  dimension: okay_to_ship_count {
    type:  number
    sql: ${TABLE}.okay_to_ship_count ;;
  }
}

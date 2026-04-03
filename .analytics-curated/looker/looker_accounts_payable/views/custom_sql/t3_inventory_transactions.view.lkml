view: t3_inventory_transactions {
  derived_table: {
    sql: with prep_store_part_cost as (select STORE_PART_ID
                                   , STORE_PART_COST_ID
                                   , COST
                                   , DATE_ARCHIVED
                                   , DATE_CREATED
                                   , coalesce(lag(DATE_ARCHIVED::timestamp_ntz)
                                                  over (partition by STORE_PART_ID order by date_archived, STORE_PART_COST_ID),
                                              0::timestamp_ntz)::timestamp_ntz                           as date_start
                                   , coalesce(DATE_ARCHIVED::timestamp_ntz, '2099-12-31'::timestamp_ntz) as date_end
                              from ES_WAREHOUSE.INVENTORY.STORE_PART_COSTS
                              order by STORE_PART_ID, STORE_PART_COST_ID),
     transactions_combined as (
-- Negative transactions (reducing inventory)
         select sp.store_id,
                s.name                                store_name,
                coalesce(s.parent_id, s.store_id)     parent_store_id,
                m.market_id,
                m.name                                market_name,
                tt.transaction_type_id,
                tt.name                               transaction_type,
                -ti.QUANTITY_RECEIVED                 quantity,
                spc.cost,
                -ti.quantity_received * spc.cost      amount,
                sp.store_part_id,
                p1.part_id,
                p1.part_number,
                pt.description,
                t.from_id,
                t.to_id,
                ti.COST_PER_ITEM, -- Choosing to not trust this cost at this time
                u.username                            created_by,
                t.transaction_id,
                ti.transaction_item_id,
                t.date_completed,
                date_trunc('month', t.date_completed) month_,
                case
                    when t.TRANSACTION_TYPE_ID = 7
                        then 'https://app.estrack.com/#/service/work-orders/' || TO_ID::STRING
                    end                               url_track,
                'negatives'                           src
         from es_warehouse.inventory.transactions t
                  join ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
                       on t.TRANSACTION_ID = ti.TRANSACTION_ID
                  join es_warehouse.INVENTORY.TRANSACTION_TYPES tt
                       on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
                  join ES_WAREHOUSE.INVENTORY.PARTS p1
                       on ti.PART_ID = p1.PART_ID
                  left join ES_WAREHOUSE.INVENTORY.PARTS p2
                            on p1.duplicate_of_id = p2.PART_ID
                  join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
                       on pt.PART_TYPE_ID = coalesce(p2.PART_TYPE_ID, p1.PART_TYPE_ID)
                  join es_warehouse.inventory.stores s
                       on t.from_id = s.STORE_ID
                  left join es_warehouse.INVENTORY.stores ps -- Parent store
                            on s.PARENT_ID = ps.STORE_ID
                  join es_warehouse.public.markets m
                       on coalesce(s.branch_id, ps.branch_id) = m.market_id
                  join ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
                       on s.store_id = sp.STORE_ID
                           and sp.PART_ID = coalesce(p2.part_id, p1.part_id)
                  join prep_store_part_cost spc
                       on sp.STORE_PART_ID = spc.STORE_PART_ID
                           and t.DATE_CREATED >= spc.date_start
                           and t.DATE_CREATED < spc.date_end
                  join es_warehouse.public.users u
                       on ti.created_by = u.user_id
         union all

      -- Positive transactions (Increasing inventory)
      select sp.store_id,
      s.name                                store_name,
      coalesce(s.parent_id, s.store_id)     parent_store_id,
      m.market_id,
      m.name                                market_name,
      tt.transaction_type_id,
      tt.name                               transaction_type,
      ti.QUANTITY_RECEIVED                  quantity,
      spc.cost,
      ti.quantity_received * spc.cost       amount,
      sp.store_part_id,
      p1.part_id,
      p1.part_number,
      pt.description,
      t.from_id,
      t.to_id,
      ti.COST_PER_ITEM, -- Choosing to not trust this cost at this time
      u.username                            created_by,
      t.transaction_id,
      ti.transaction_item_id,
      t.date_completed,
      date_trunc('month', t.date_completed) month_,
      case
      when t.TRANSACTION_TYPE_ID = 9
      then 'https://app.estrack.com/#/service/work-orders/' || from_id::STRING
      end                               url_track,
      'positives'                           src
      from es_warehouse.inventory.transactions t
      join ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
      on t.TRANSACTION_ID = ti.TRANSACTION_ID
      join es_warehouse.INVENTORY.TRANSACTION_TYPES tt
      on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
      join ES_WAREHOUSE.INVENTORY.PARTS p1
      on ti.PART_ID = p1.PART_ID
      left join ES_WAREHOUSE.INVENTORY.PARTS p2
      on p1.duplicate_of_id = p2.PART_ID
      join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
      on pt.PART_TYPE_ID = coalesce(p2.PART_TYPE_ID, p1.PART_TYPE_ID)
      join es_warehouse.inventory.stores s
      on t.to_id = s.STORE_ID
      left join es_warehouse.INVENTORY.stores ps -- Parent store
      on s.PARENT_ID = ps.STORE_ID
      join es_warehouse.public.markets m
      on coalesce(s.branch_id, ps.branch_id) = m.market_id
      join ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
      on s.store_id = sp.STORE_ID
      and sp.PART_ID = coalesce(p2.part_id, p1.part_id)
      join prep_store_part_cost spc
      on sp.STORE_PART_ID = spc.STORE_PART_ID
      and t.DATE_CREATED >= spc.date_start
      and t.DATE_CREATED < spc.date_end
      join es_warehouse.public.users u
      on ti.created_by = u.user_id)
      select *
      from transactions_combined tc
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: store_id {
    type: number
    sql: ${TABLE}."STORE_ID" ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}."STORE_NAME" ;;
  }

  dimension: parent_store_id {
    type: number
    sql: ${TABLE}."PARENT_STORE_ID" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: transaction_type_id {
    type: number
    sql: ${TABLE}."TRANSACTION_TYPE_ID" ;;
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}."TRANSACTION_TYPE" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}."COST" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: store_part_id {
    type: number
    sql: ${TABLE}."STORE_PART_ID" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: from_id {
    type: number
    sql: ${TABLE}."FROM_ID" ;;
  }

  dimension: to_id {
    type: number
    sql: ${TABLE}."TO_ID" ;;
  }

  dimension: cost_per_item {
    type: number
    sql: ${TABLE}."COST_PER_ITEM" ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: transaction_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ID" ;;
  }

  dimension: transaction_item_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ITEM_ID" ;;
  }

  dimension_group: date_completed {
    type: time
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  dimension_group: month_ {
    type: time
    sql: ${TABLE}."MONTH_" ;;
  }

  dimension: url_track {
    type: string
    sql: ${TABLE}."URL_TRACK" ;;
  }

  dimension: src {
    type: string
    sql: ${TABLE}."SRC" ;;
  }

  set: detail {
    fields: [
      store_id,
      store_name,
      parent_store_id,
      market_id,
      market_name,
      transaction_type_id,
      transaction_type,
      quantity,
      cost,
      amount,
      store_part_id,
      part_id,
      part_number,
      description,
      from_id,
      to_id,
      cost_per_item,
      created_by,
      transaction_id,
      transaction_item_id,
      date_completed_time,
      month__time,
      url_track,
      src
    ]
  }
}

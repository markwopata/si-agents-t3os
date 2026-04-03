view: parts_consumption {
#UNDER CONSTRUCTION
  derived_table:{
    sql: with parts_per_WO_pre AS (
          SELECT IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID) AS id
               , IFF(TRANSACTION_TYPE_ID = 7, t.FROM_ID, t.TO_ID) AS store_id
               , ti.PART_ID                                       AS part_id
               , p.PART_NUMBER                                    as part_number
               , p.NAME                                           as name
               , p.SEARCH                                         as search
               , t.transaction_type_id                            AS transaction_type_id
               , IFF(TRANSACTION_TYPE_ID = 7, ti.quantity_received, -ti.quantity_received)    AS qty
               , 'work order'                                     as cogs_type
          FROM ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
                   LEFT JOIN ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
                             ON t.TRANSACTION_ID = ti.TRANSACTION_ID
                   join ES_WAREHOUSE.INVENTORY.PARTS p
                             on ti.PART_ID = p.PART_ID
          WHERE t.TRANSACTION_TYPE_ID IN (7, 9)
          and t.DATE_CANCELLED is null
          )

, parts_per_WO as (
    select ppwp.*, wo.DATE_COMPLETED as final_date
    from parts_per_WO_pre ppwp
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    on ppwp.id = wo.WORK_ORDER_ID
    where wo.ARCHIVED_DATE is null
    and wo.DATE_COMPLETED is not null
    and wo.ASSET_ID is not null
)

, parts_per_invoice_pre as (
          SELECT IFF(TRANSACTION_TYPE_ID in (3, 13), t.TO_ID, t.FROM_ID) AS id
               , IFF(TRANSACTION_TYPE_ID in (3, 13), t.FROM_ID, t.TO_ID) AS store_id
               , ti.PART_ID                                              AS part_id
               , p.PART_NUMBER                                           as part_number
               , p.NAME                                                  as name
               , p.SEARCH                                                as search
               , t.transaction_type_id                                   AS transaction_type_id
               , IFF(TRANSACTION_TYPE_ID in (3, 13), ti.quantity_received, -ti.quantity_received)     AS qty
               , 'invoice'                                               as cogs_type
          FROM ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
                   LEFT JOIN ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
                             ON t.TRANSACTION_ID = ti.TRANSACTION_ID
                   join ES_WAREHOUSE.INVENTORY.PARTS p
                             on ti.PART_ID = p.PART_ID
          WHERE TRANSACTION_TYPE_ID IN (3, 13, 4)
          and t.DATE_CANCELLED is null
          -- 3  = Store to Retail Sale
          -- 13 = Store to Rental Retail Sale
          -- 4  = Retail Sale to Store
)

, parts_per_invoice as (
    select ppip.*, inv.BILLING_APPROVED_DATE as final_date
    from parts_per_invoice_pre ppip
    join ES_WAREHOUSE.PUBLIC.INVOICES inv
    on ppip.id = inv.INVOICE_ID
    where inv.BILLING_APPROVED_DATE is not null
)

, merge as (
select * from parts_per_WO
union all
select * from parts_per_invoice
)

select m.cogs_type
     , m.id
     , m.store_id
     , m.part_id
     , m.part_number
     , sum(m.qty) as quantity
     , m.final_date
     , snap.AVG_COST
     , snap.SNAPSHOT_DATE
     , sum(m.qty) * snap.AVG_COST as total_cost
from merge m
join ANALYTICS.PUBLIC.AVERAGE_COST_SNAPSHOT snap
on m.part_id = snap.CURRENT_PART_ID
       and m.store_id = snap.STORE_ID
       and last_day(m.final_date, 'month') = snap.SNAPSHOT_DATE
group by m.cogs_type, m.id, m.store_id, m.part_id, m.part_number, m.final_date
       , snap.AVG_COST, snap.SNAPSHOT_DATE
having sum(qty) > 0
order by final_date desc;;
}

dimension: key_field {
  primary_key: yes
  type: string
  sql: concat(cast(${TABLE}."COGS_TYPE" as string)
              ,' '
              ,cast(${TABLE}."ID" as string)
              ,' '
              ,cast(${TABLE}."PART_ID" as string)
              ,' '
              ,cast(${TABLE}."STORE_ID" as string)
             )  ;;
}

dimension: consumption_type {
  type: string
  sql: ${TABLE}."COGS_TYPE" ;;
}

dimension: id {
  type: number
  sql: ${TABLE}."ID" ;;
}

dimension: store_id {
  type: number
  sql: ${TABLE}."STORE_ID" ;;
}

dimension: part_id {
  type: number
  sql: ${TABLE}."PART_ID" ;;
}

dimension: quantity {
  type: number
  sql: ${TABLE}."QUANTITY" ;;
}

dimension: average_cost {
  type: number
  value_format_name: usd
  sql: ${TABLE}."AVG_COST" ;;
}

dimension: cost_consumed {
  type: number
  value_format_name: usd
  sql: coalesce(${TABLE}."TOTAL_COST",0) ;;
  }

dimension_group: consumption_date {
  type: time
  timeframes: [raw, date, week, month, quarter, year]
  convert_tz: no
  datatype: date
  sql: ${TABLE}."FINAL_DATE" ;;
}

  dimension_group: snap_match_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SNAPSHOT_DATE" ;;
  }

measure: total_consumed {
  type: sum
  value_format_name: usd
  sql: ${cost_consumed} ;;
}


}

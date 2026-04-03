view: transactions {
  derived_table: {
    sql: select date_completed, date_created, transaction_id, part_id, store_id, created_by, quantity_received, quantity_sent, cost_per_item, total_cost,
       sum(case when quantity_received >= 1 then quantity_received
                when quantity_sent >= 1 then - quantity_sent
                else 0
           end) over
           (partition by part_id, store_id order by date_completed asc) as total_in_stock,
           from_uuid_id, transaction_type_id, transaction_status_id
from(
select t.date_completed, t.date_created, ti.transaction_id, t.created_by, ti.part_id, t.to_id as store_id,
       case
            when to_id in (3917,3918,3920,3921) and date_cancelled is null then ti.quantity_received
            else 0
       end as quantity_received,
       0 as quantity_sent,
       ti.cost_per_item,
         IFF(TRANSACTION_TYPE_ID = 9, COST_PER_ITEM * -1, COST_PER_ITEM) * QUANTITY_RECEIVED as total_cost,
       t.from_uuid_id, t.transaction_type_id, transaction_status_id
        from ES_WAREHOUSE.INVENTORY.transaction_items ti
        inner join es_warehouse.inventory.transactions t
        on ti.transaction_id = t.transaction_id
where to_id in (3917,3918,3920,3921) and date_cancelled is null
union all
select t.date_completed, t.date_created, ti.transaction_id, t.created_by, ti.part_id, t.from_id as store_id,
       0 as quantity_received,
       case
         when from_id in (3917,3918,3920,3921) and date_cancelled is null then ti.quantity_received
         else 0
       end as quantity_sent,
       ti.cost_per_item,
         IFF(TRANSACTION_TYPE_ID = 9, COST_PER_ITEM * -1, COST_PER_ITEM) * QUANTITY_RECEIVED as total_cost,
       t.from_uuid_id, t.transaction_type_id, transaction_status_id
        from ES_WAREHOUSE.INVENTORY.transaction_items ti
        inner join es_warehouse.inventory.transactions t
        on ti.transaction_id = t.transaction_id
where from_id in (3917,3918,3920,3921) and date_cancelled is null
) transactions
group by date_completed, date_created, store_id, part_id, transaction_id, created_by, quantity_received, quantity_sent, cost_per_item, total_cost, from_uuid_id, transaction_type_id, transaction_status_id
order by date_completed, store_id, part_id, transaction_id asc
      ;;
  }

  dimension_group: date_completed {
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
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  dimension_group: date_created {
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
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  dimension: transaction_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ID" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: store_id {
    type: number
    sql: ${TABLE}."STORE_ID" ;;
  }

  dimension: quantity_received {
    type: number
    sql: ${TABLE}."QUANTITY_RECEIVED" ;;
  }

  dimension: quantity_sent {
    type: number
    sql: ${TABLE}."QUANTITY_SENT" ;;
  }

  dimension: total_in_stock {
    type: number
    sql: ${TABLE}."TOTAL_IN_STOCK" ;;
  }

  dimension: quantity_in_stock {
    type: number
    sql: case when ${total_in_stock} < 0 then 0
          else ${total_in_stock}
          end;;
  }

  dimension: created_by {
    type: number
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: cost_per_item {
    type: number
    value_format_name: usd
    sql: ${TABLE}."COST_PER_ITEM" ;;
  }

  dimension: total_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}."TOTAL_COST" ;;
  }

  dimension: transaction_type_id {
    type: number
    sql: ${TABLE}."TRANSACTION_TYPE_ID" ;;
  }

  dimension: from_uuid_id {
    type: string
    sql: ${TABLE}."FROM_UUID_ID" ;;
  }

  dimension: transaction_status_id {
    type: number
    sql: ${TABLE}."TRANSACTION_STATUS_ID" ;;
  }

  dimension: link {
    type: string
    sql:
    CASE
    WHEN ${transaction_type_id} = 21 THEN ${from_uuid_id} -- From PO
    WHEN ${transaction_type_id} = 7 then ${store_id}::string -- Store to WO
    WHEN ${transaction_type_id} = 9 then ${store_id}::string -- WO to store
    WHEN ${transaction_type_id} = 3 then ${store_id}::string -- Store to Retail Sale
    ELSE NULL END;;
    html:
    {% if transaction_type_id._value == 21 %}
    <font color="blue "><u><a href="https://costcapture.estrack.com/purchase-orders/{{ rendered_value }}/detail" target="_blank">Purchase Order</a></font></u>
    {% elsif transaction_type_id._value == 7 %}
    <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{rendered_value}}/updates" target="_blank">To Work Order</a></font></u>
    {% elsif transaction_type_id._value == 9 %}
    <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ rendered_value }}/updates" target="_blank">From Work Order</a></font></u>
    {% elsif transaction_type_id._value == 3 %}
    <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ rendered_value }}" target="_blank">To Retail Sale</a></font></u>
    {% else %}

      {% endif %}
      ;;
  }

  measure: total_part_cost {
    type: sum
    sql: ${total_cost} ;;
    value_format_name: usd
    drill_fields: [transaction_detail*]
  }

  set: transaction_detail {
    fields: [
      stores.name,
      part_types.description,
      parts.part_number,
      transaction.quantity_received,
      transaction.quantity_sent,
      transaction.total_cost,
      transaction.date_completed
    ]
  }

}

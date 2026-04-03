view: rpo_equipment_sales {
  derived_table: {
    sql: select
    vli.asset_id,
    i.company_id                as company_id,
    i.billing_approved_date::date as sales_date,
    vli.line_item_type_id,
    vli.line_item_type,
    vli.amount,
    i.salesperson_user_id,
    concat(u.first_name, ' ', u.last_name) sales_person_full_name,
    case when (vli.asset_id in (select afs.asset_id
          from analytics.public.asset_financing_snapshots afs
          where afs.category = 'Contractor Owned OEC' and date = LAST_DAY(DATEADD(MONTH, -1, CURRENT_DATE)))
          or i.company_id in (6954, 55524, 73584, 111143)) then 'Y' else 'N' end as OWN_SALE_FLAG,
    case
        when vli.LINE_ITEM_TYPE_ID in (8,43) then 'RPO Rental Revenue'
        when vli.LINE_ITEM_TYPE_ID in (50) then 'RPO Equipment Sale'
        else null
    end as revenue_type
from analytics.public.v_line_items vli
left join es_warehouse.public.invoices i
    on vli.invoice_id = i.invoice_id
left join es_warehouse.public.users u
    on u.user_id = i.salesperson_user_id
left join es_warehouse.public.companies c
    on c.company_id = i.company_id
where revenue_type is not null
    and (vli.line_item_type_id in (43, 50) or c.name ilike '%(RPO)')
;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: sales_date {
    type: date
    sql: ${TABLE}."SALES_DATE" ;;
  }

  dimension_group: sales_grouped{
    type: time
    sql: ${TABLE}."SALES_DATE" ;;
  }


  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: line_item_type {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: sales_person_full_name {
    type: string
    sql: ${TABLE}."SALES_PERSON_FULL_NAME" ;;
  }

  dimension: own_sale_flag {
    type: string
    sql: ${TABLE}."OWN_SALE_FLAG" ;;
  }

  dimension: revenue_type {
    type: string
    sql: ${TABLE}."REVENUE_TYPE" ;;
  }

  measure: total_sales {
    type:  sum
    sql: ${amount};;
    value_format_name: usd_0
  }

  measure: avg_sales_price {
    type: average
    sql: ${amount} ;;
    value_format_name: usd_0
  }

  set: detail {
    fields: [
      asset_id,
      company_id,
      sales_date,
      line_item_type_id,
      line_item_type,
      amount,
      salesperson_user_id,
      sales_person_full_name,
      own_sale_flag
    ]
  }
}

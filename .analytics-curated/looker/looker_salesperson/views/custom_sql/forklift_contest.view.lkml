view: forklift_contest {
  derived_table: {
    sql:
with rentals as (select r.RENTAL_ID,
                        r.ASSET_ID,
                        ec.NAME                                                                    as equipment_class,
                        r.DATE_CREATED::date                                                       as rental_date_created,
                        r.START_DATE::date                                                         as rental_date_start,
                        r.END_DATE::date                                                           as rental_date_end,
                        greatest(datediff(days, case when rental_date_start > current_date
                                          then current_date else rental_date_start end,
                                    case
                                    when r.END_DATE > '2023-05-31' then (case
                                                                            when current_date < '2023-05-31'
                                                                                then current_date
                                                                                    else '2023-05-31' end)
                                    when r.END_DATE > current_date then current_date
                                    else r.END_DATE::date end), 1)                                as days_on_rent,
                        i.BILLED_AMOUNT,
                        i.COMPANY_ID,
                        c.NAME                                                                     as company_name,
                        os.USER_ID                                                                 as salesperson_user_id,
                        concat(u.FIRST_NAME, ' ', u.LAST_NAME)                                     as salesperson
                 from ES_WAREHOUSE.PUBLIC.RENTALS r
                          join ES_WAREHOUSE.PUBLIC.ORDERS o on r.ORDER_ID = o.ORDER_ID
                          join ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS os on o.ORDER_ID = os.ORDER_ID
                          join ES_WAREHOUSE.PUBLIC.USERS u on os.USER_ID = u.USER_ID
                          join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on r.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
                          left join (select RENTAL_ID, INVOICE_ID
                                     from ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
                                     join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
                                     on li.ASSET_ID = aa.ASSET_ID
                                     where LINE_ITEM_TYPE_ID in (6, 8, 108, 109)
                                     and aa.EQUIPMENT_CLASS_ID in (9103, 7873, 3528, 5013, 7233, 20, 3128, 3132, 3381))
                                    li on r.RENTAL_ID = li.RENTAL_ID
                          left join (select INVOICE_ID, COMPANY_ID, BILLED_AMOUNT
                                     from ES_WAREHOUSE.PUBLIC.INVOICES
                                          -- only count the billing cycles that began in May
                                     where START_DATE < '2023-06-01') i on li.INVOICE_ID = i.INVOICE_ID
                          left join ES_WAREHOUSE.PUBLIC.COMPANIES c on i.COMPANY_ID = c.COMPANY_ID
                 where r.START_DATE between '2023-05-01' and '2023-05-31'
                   and r.EQUIPMENT_CLASS_ID in (9103, 7873, 3528, 5013, 7233, 20, 3128, 3132, 3381)
                 order by 1),
     asset_customer as (select *,
                               row_number() over (partition by COMPANY_ID, ASSET_ID,
                              salesperson order by rental_date_created asc)           as first_rental,
                               count(*) over ( partition by COMPANY_ID, ASSET_ID,
                              salesperson )                                           as num_rows
                        from (select distinct RENTAL_ID, COMPANY_ID, ASSET_ID, salesperson, rental_date_created
                              from rentals
                              order by RENTAL_ID))
select r.*
from rentals r
         join asset_customer ac on r.RENTAL_ID = ac.RENTAL_ID
where first_rental = 1
order by RENTAL_ID
    ;;
  }

  dimension: rental_id {
    primary_key: yes
    value_format: "0"
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: asset_id {
    type: number
    value_format: "0"
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: invoice_id {
    type: number
    value_format: "0"
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: rental_date_created {
    type: date
    sql: ${TABLE}."RENTAL_DATE_CREATED" ;;
  }

  dimension: rental_date_start {
    type: date
    sql: ${TABLE}."RENTAL_DATE_START" ;;
  }

  dimension: rental_date_end {
    type: date
    sql: ${TABLE}."RENTAL_DATE_END" ;;
  }

  dimension: days_on_rent {
    type: number
    sql: ${TABLE}."DAYS_ON_RENT" ;;
  }

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  dimension: company_id {
    type: number
    value_format: "0"
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }


  measure: total_days_on_rent {
    type: sum
    sql: ${days_on_rent} ;;
    drill_fields: [salesperson, rental_id, asset_id, equipment_class, company_name, rental_date_created,
      rental_date_start, rental_date_end, days_on_rent]
  }

  measure: revenue {
    type: sum
    sql: ${billed_amount} ;;
    drill_fields: [salesperson, rental_id, asset_id, equipment_class, company_name, rental_date_created,
                    rental_date_start, rental_date_end, days_on_rent]
  }

  measure: new_rentals_count {
    type: count_distinct
    sql: ${rental_id} ;;
    drill_fields: [salesperson, rental_id, asset_id, equipment_class, company_name, rental_date_created,
                    rental_date_start, rental_date_end, days_on_rent]
  }

}

view: collector_actual_payments {
  derived_table: {
    sql:
WITH INVOICE_EXCLUDE_CTE AS (
SELECT DISTINCT INVOICE_NO
FROM ANALYTICS.PUBLIC.V_LINE_ITEMS
WHERE LINE_ITEM_TYPE_ID  IN (1, 3, 4, 14, 22, 23, 24, 27, 30, 31, 32, 33, 34, 35, 37, 38, 50, 74, 75,
     76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 107, 110, 111, 113, 116, 120)
)
SELECT LAST_DAY(I.BILLING_APPROVED_DATE::DATE) AS MONTH_,i.invoice_no, i.due_date::date as due_date,
       i.ship_from:branch_id as branch_id,x.market_name as branch_name,x.region_district,
       i.salesperson_user_id as salesperson_user_id,
      u.last_name || ', '|| u.first_name as salesperson_name,p.payment_date,i.company_id as customer_id,
      c.name as customer_name,
      cit.collector,
       SUM(pa.amount) AS payment_amount
  FROM es_warehouse.public.payment_applications pa
       join es_warehouse.public.payments p on pa.payment_id = p.payment_id
       left join es_warehouse.public.invoices as i on i.invoice_id = pa.invoice_id
       join analytics.public.market_region_xwalk as x on i.ship_from:branch_id::varchar = x.market_id::varchar
       left join es_warehouse.public.companies as c on i.company_id = c.company_id
       left join es_warehouse.public.users as u on i.salesperson_user_id = u.user_id
       left join analytics.treasury.collector_individual_targets as cit on i.ship_from:branch_id::varchar = cit.branch_id::varchar
 WHERE p.payment_date >= '2023-10-01'
   AND p.payment_date < '2024-01-01'
   AND pa.reversed_date IS NULL
   and i.company_id not in (select company_id from analytics.public.es_companies)
and I.COMPANY_ID NOT IN (6954,20598,55524)
AND I.BILLING_APPROVED_DATE > '2017-01-01'
AND I.BILLING_APPROVED_DATE IS NOT NULL
AND I.INVOICE_ID <> 724307
AND I.INVOICE_NO NOT IN (SELECT INVOICE_NO FROM INVOICE_EXCLUDE_CTE)
group by LAST_DAY(I.BILLING_APPROVED_DATE::DATE),i.invoice_no, i.due_date::date,
         i.ship_from:branch_id ,x.market_name, x.region_district,
         i.salesperson_user_id,
         u.last_name || ', '|| u.first_name,p.payment_date,i.company_id,c.name,cit.collector
            ;;
  }

  ################## DIMENSIONS ##################

  dimension: invoice_no {
    type: string
    sql: ${TABLE}.INVOICE_NO  ;;
  }

  dimension: branch_id {
    type: string
    value_format_name: id
    sql: ${TABLE}.BRANCH_ID  ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}.BRANCH_NAME  ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}.REGION_DISTRICT  ;;
  }

  dimension: payment_date {
    type: date
    sql: ${TABLE}.PAYMENT_DATE::DATE  ;;
  }

  dimension: customer_id {
    type: string
    value_format_name: id
    sql: ${TABLE}.CUSTOMER_ID  ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}.CUSTOMER_NAME  ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}.COLLECTOR  ;;
  }


  ################## PRIMARY KEY ##################
  dimension: key {
    type: string
    primary_key: yes
    sql: ${TABLE}."MONTH_" || '-'|| ${TABLE}."INVOICE_NO" || '-' || ${TABLE}."CUSTOMER_ID" ;;
  }

  ################## MEASURES ##################

  measure: payment_amount {
    label: "Collections"
    type: sum
    value_format_name: usd_0
    drill_fields: [drill_details*]
    sql: ${TABLE}.PAYMENT_AMOUNT ;;
  }

  ################## DRILL DETAIL ##################

  set: drill_details {
    fields: [invoice_no,branch_id,branch_name,region_district,payment_date,customer_id,customer_name,collector,payment_amount]
  }


  }

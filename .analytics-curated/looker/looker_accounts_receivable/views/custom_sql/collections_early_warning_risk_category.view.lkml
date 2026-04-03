view: collections_early_warning_risk_category {
  derived_table: {
    sql:
with customers_total_ar as(
select c.company_id,
       sum(case when i.owed_amount is not null and i.owed_amount > 0.0 then i.owed_amount ELSE i.billed_amount end) as amount
 FROM ES_WAREHOUSE.public.orders o
 LEFT JOIN ES_WAREHOUSE.public.invoices i ON o.order_id = i.order_id
 LEFT JOIN ES_WAREHOUSE.public.users u ON o.user_id = u.user_id
 LEFT JOIN ES_WAREHOUSE.public.companies c ON u.company_id = c.company_id
 where paid = false
  and billing_approved = true
 group by c.company_id)

, outstanding_amount as(
select company_id
     , sum(owed_amount) as owed_amount_60_days
 from es_warehouse.public.invoices
 where due_date_outstanding in(61,91,121)
 group by all)

, dso as(
select company_id
     , (sum(coalesce(owed_amount,0))/nullifzero(sum(billed_amount)))*180 as dso
 from es_warehouse.public.invoices
 where billing_approved = true
 group by all)

, last_payment_date as(
select i.company_id
     , max(pa.date) as last_payment_date
 from es_warehouse.public.payment_applications pa
 left join es_warehouse.public.invoices i on pa.invoice_id = i.invoice_id
 group by all)

, max_invoice_rental as(
select max(rental_id) as rental_id,
       max(invoice_id) as invoice_id
 from ANALYTICS.PUBLIC.v_line_items
 where line_item_type_id in (6,8,108,109)
 group by rental_id, invoice_id)

, open_rentals as(
select i.company_id
     , count(distinct r.rental_id) as count_of_open_rentals
 from es_warehouse.public.rentals r
 join max_invoice_rental mir on r.rental_id = mir.rental_id
 left join es_warehouse.public.invoices i on mir.invoice_id = i.invoice_id
 where r.rental_status_id = 5
 group by all)

select c.name as company_name
     , c.company_id
     , (cta.amount - c.credit_limit) as amount_over_credit_limit
     , coalesce(cta.amount,0) as total_ar_amount
     , lpd.last_payment_date::date as last_payment_date
     , dso.dso
     , c.do_not_rent
     , coalesce(opr.count_of_open_rentals,0) as count_of_open_rentals
     , coalesce(om.owed_amount_60_days,0) as owed_amount_60_days
 from es_warehouse.public.companies c
 left join customers_total_ar cta on c.company_id = cta.company_id
 left join last_payment_date lpd on c.company_id = lpd.company_id
 left join dso dso on c.company_id = dso.company_id
 left join open_rentals opr on c.company_id = opr.company_id
 left join outstanding_amount om on c.company_id = om.company_id
 where cta.amount <> 0;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: company_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: amount_over_credit_limit {
    type: number
    sql: ${TABLE}."AMOUNT_OVER_CREDIT_LIMIT" ;;
  }

  dimension: total_ar_amount {
    type: number
    sql: ${TABLE}."TOTAL_AR_AMOUNT" ;;
  }

  dimension: last_payment_date {
    type: date
    sql: ${TABLE}."LAST_PAYMENT_DATE" ;;
  }

  dimension: dso {
    type: number
    sql: ${TABLE}."DSO" ;;
  }

  dimension: do_not_rent {
    type: yesno
    sql: ${TABLE}."DO_NOT_RENT" ;;
  }

  dimension: count_of_open_rentals {
    type: number
    sql: ${TABLE}."COUNT_OF_OPEN_RENTALS" ;;
  }

  dimension: owed_amount_60_days {
    type: number
    sql: ${TABLE}."OWED_AMOUNT_60_DAYS" ;;
  }

  dimension: risk_category {
   type: string
    sql: case
          when datediff(day,${last_payment_date},current_timestamp()) > 30
           and ${amount_over_credit_limit} > 10000
           and ${dso} > 60
           and ${owed_amount_60_days} <> 0
            then 'High Risk'
          when datediff(day,${last_payment_date},current_timestamp()) > 30
           and ${amount_over_credit_limit} > 10000
           and ${dso} >= 15 and ${dso} <= 60
           and ${owed_amount_60_days} <> 0
            then 'Medium Risk'
          when ${total_ar_amount} > 1000
           and ${amount_over_credit_limit} > 2500
           and ${owed_amount_60_days} = 0
           and ${do_not_rent} = 'Yes'
           and ${count_of_open_rentals} = 0
           and ${dso} >= 15
            then 'Low Risk'
          else 'Not Categorized'
         end;;
  }

}

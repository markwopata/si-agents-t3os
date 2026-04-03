view: customers_without_assigned_collector {
  derived_table: {
    sql:
       select c.company_id, c.name as company_name,sum(i.owed_amount) as balance
from es_warehouse.public.companies as c
left join ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS as cca on c.company_id = cca.company_id
left join es_warehouse.public.invoices as i on c.company_id = i.company_id
where cca.company_id is null
and i.company_id not in (select company_id from analytics.public.es_companies)
and i.billing_approved_date is not null
group by all
having balance >=  5000
;;
  }


  dimension: customer_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: customer_name {
    type: number
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ customers_without_assigned_collector.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."COMPANY_NAME" ;;
  }


  dimension: balance {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."BALANCE" ;;
  }
  }

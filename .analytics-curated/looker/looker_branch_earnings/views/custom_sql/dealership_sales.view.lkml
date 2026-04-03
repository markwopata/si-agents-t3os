view: dealership_sales {
  derived_table: {
    sql:
      select
r.gl_date::date as gl_date,
r.market_name,
coalesce(a.make, 'Unknown / no asset make') as vehicle_company,
round(sum(case when r.line_item_type_name = 'New Dealership Equipment Sales' then r.amount else 0 end), 2) as equipment_sales_revenue,
round(sum(case when r.line_item_type_name = 'New Dealership Attachment Sale' then r.amount else 0 end), 2) as attachment_sales_revenue,
round(sum(r.amount), 2) as total_revenue
from analytics.intacct_models.int_revenue as r
left join analytics.assets.int_assets as a
on r.asset_id = a.asset_id
where not coalesce(r.is_intercompany, false)
and r.line_item_type_name in (
'New Dealership Equipment Sales',
'New Dealership Attachment Sale')
group by 1, 2, 3
order by gl_date desc, market_name, total_revenue desc


      ;;
  }

  dimension: gl_date {
    label: "GL Date"
    type: date
    sql: ${TABLE}."GL_DATE" ;;
  }


  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: vehicle_company {
    label: "Vehicle Company"
    type: string
    sql: ${TABLE}."VEHICLE_COMPANY" ;;
  }
  measure: equipment_sales_revenue {
    label: "Equipment Sales Revenue"
    type: sum
    sql: ${TABLE}."EQUIPMENT_SALES_REVENUE" ;;
  }

  measure: attachment_sales_revenue {
    label: "Attachment Sales Revenue"
    type: sum
    sql: ${TABLE}."ATTACHMENT_SALES_REVENUE" ;;
  }

  measure: total_revenue {
    label: "Total Revenue"
    type: sum
    sql: ${TABLE}."TOTAL_REVENUE" ;;
  }

  }

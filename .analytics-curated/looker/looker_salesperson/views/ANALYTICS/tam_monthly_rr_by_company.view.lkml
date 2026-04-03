view: tam_monthly_rr_by_company {
  derived_table: {
    sql: SELECT
             u.user_id AS tam_user_id,
             YEAR(li.GL_BILLING_APPROVED_DATE) as year,
             MONTH(li.GL_BILLING_APPROVED_DATE) as month,
             c.name as company_name,
             CONCAT(c.name, ' - ', i.company_id) as company_w_id,
             SUM(li.amount) AS monthly_rental_revenue_by_company
         FROM es_warehouse.public.users u
                  left join es_warehouse.public.invoices i on u.user_id = i.salesperson_user_id
                  left join analytics.public.v_line_items li on li.invoice_id = i.invoice_id
                  left join es_warehouse.public.orders o on i.order_id = o.order_id
                  left join es_warehouse.public.order_salespersons os on o.order_id = os.order_id
                  left join ES_WAREHOUSE.PUBLIC.COMPANIES c on c.company_id = i.company_id
         WHERE i.company_id not in (1854,1855,8151,155)
           AND li.line_item_type_id in (6,8,108,109)
           AND os.salesperson_type_id = 1
           AND date_trunc('MONTH', li.GL_BILLING_APPROVED_DATE) >= date_trunc('YEAR', CURRENT_DATE() - INTERVAL '2 YEAR')
         GROUP BY
             u.user_id,
             YEAR(li.GL_BILLING_APPROVED_DATE),
             MONTH(li.GL_BILLING_APPROVED_DATE),
             CONCAT(c.name, ' - ', i.company_id),
            c.name
             ;;
}

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: month {
    type: number
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: tam_user_id {
    type: number
    sql: ${TABLE}."TAM_USER_ID" ;;
  }

  dimension: pk {
    type: string
    primary_key: yes
    sql:  CONCAT(${tam_user_id},'-',${year},'-',${month},'-',${company});;
  }

  dimension: fk_sgr {
    type: string
    sql: CONCAT(${tam_user_id},'-',${year},'-',${month});;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY_W_ID" ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name_only._filterable_value | url_encode }}&Company%20ID="
    }
  }

  dimension: company_name_only {
    type: string
    sql: TRIM(${TABLE}."COMPANY_NAME") ;;
  }

  dimension: monthly_rental_revenue_by_company {
    type: number
    sql: ${TABLE}."MONTHLY_RENTAL_REVENUE_BY_COMPANY" ;;
  }

  dimension: month_year {
    type: date
    sql: DATEFROMPARTS(${year}, ${month}, 1);;
    html: {{rendered_value | date: "%b %Y"}} ;;
  }

  measure: rental_revenue_by_company {
    type: sum
    value_format_name: usd_0
    sql: ${monthly_rental_revenue_by_company} ;;
  }

  measure: rental_revenue_by_company_month_drilldown {
    type: string
    sql: 'second layer drilldown data must be downloaded separately' ;;
    drill_fields: [month_detail*]
    html: <a href="#drillmenu" target="_self"><img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a>;;
  }

  set: detail {
    fields: [
      tam_user_id,
      year,
      month,
      company,
      monthly_rental_revenue_by_company
    ]
  }

  set: month_detail {
    fields: [
      month_year,
      sales_goals_rental_historic.territory_account_manager,
      company,
      rental_revenue_by_company
    ]
  }

}

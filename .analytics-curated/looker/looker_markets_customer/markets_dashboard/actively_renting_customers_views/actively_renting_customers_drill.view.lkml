
view: actively_renting_customers_drill {
  derived_table: {
    sql:  select
--              coalesce(case when position(' ',coalesce(cd.NICKNAME,cd.FIRST_NAME)) = 0 then concat(coalesce(cd.NICKNAME,cd.FIRST_NAME), ' ', cd.LAST_NAME)
--              else concat(coalesce(cd.NICKNAME,concat(cd.FIRST_NAME, ' ',cd.LAST_NAME))) end, concat(u.first_name,' ',u.last_name)) as salesperson,
             c.name as customer,
             c.company_id as customer_id,
             o.market_id,
             count(distinct r.rental_id) as count_of_current_rentals
      from ES_WAREHOUSE.PUBLIC.ORDERS o
            left join ES_WAREHOUSE.PUBLIC.RENTALS r on o.order_id = r.order_id
            left join ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS os on o.order_id = os.order_id
            left join ES_WAREHOUSE.PUBLIC.USERS AS salesperson_user on os.user_id = salesperson_user.user_id
            left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd on salesperson_user.email_address = cd.work_email
            left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw on o.market_id = xw.market_id
            left join ES_WAREHOUSE.PUBLIC.USERS u on o.user_id = u.user_id
            left join ES_WAREHOUSE.PUBLIC.COMPANIES c on u.company_id = c.company_id
      where r.rental_status_id = 5
            and xw.market_name is not null
            and os.salesperson_type_id = 1
      group by
               customer,
               customer_id,
               o.market_id ;;
  }

  measure: count {
    type: count
  }

  dimension: primary_key {
    type: string
    sql: concat(${customer},${customer_id},${market_id}) ;;
    primary_key: yes
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER" ;;
    html: <font color="0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{rendered_value}}&Company+ID="target="_blank">{{rendered_value}}</a></font>
    <td>
    <span style="color: #8C8C8C;"> ID: {{customer_id._value}} </span>
    </td>;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: count_of_current_rentals {
    type: number
    sql: ${TABLE}."COUNT_OF_CURRENT_RENTALS" ;;
  }

  # dimension: count_of_total_rentals {
  #   type: number
  #   sql: ${TABLE}."COUNT_OF_TOTAL_RENTALS" ;;
  # }

  measure: total_count_of_current_rentals {
    label: "Current Rentals"
    type: sum
    sql: ${count_of_current_rentals} ;;
  }

  # measure: total_count_of_rentals {
  #   type: sum
  #   sql: ${count_of_total_rentals} ;;
  # }

}

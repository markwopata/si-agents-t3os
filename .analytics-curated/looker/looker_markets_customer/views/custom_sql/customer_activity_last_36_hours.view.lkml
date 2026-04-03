view: customer_activity_last_36_hours {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    sql: WITH
   invoices_info
AS
   (
   SELECT  u.COMPANY_ID
               , c.NAME
               , COALESCE(ais.primary_salesperson_id, os.user_id, o.salesperson_user_id) AS final_salesperson_user_id
               , u2.first_name
               , u2.last_name
                , cd.employee_title
               , SUM(li.amount) AS total_spend
               , MAX(i.start_date) AS latest_invoice_date
               , RANK() OVER (PARTITION BY u.company_id ORDER BY cd.employee_title IN ('Territory Account Manager',
                                     'New Equipment Territory Sales Representative',
                                     'Territory Sales Manager',
                                     'Retail Equipment Sales Representative',
                                     'Territory Manager',
                                     'Territory Retail Sales Representative',
                                     'Rental Territory Manager',
                                     'District Sales Manager',
                                     'Business Partnership Manager',
                                     'Market Consultant Manager',
                                     'General Manager',
                                     'Sales Manager',
                                     'District Manager',
                                     'Rental Coordinator',
                                     'Store Associate: Sales',
                                     'Strategic Account Manager',
                                     'Industrial Strategic Account Manager',
                                     'Retail Account Manager') DESC
               , MAX(i.start_date) DESC) AS rank_number

       FROM    ES_WAREHOUSE.PUBLIC.orders o
                   LEFT OUTER JOIN ES_WAREHOUSE.PUBLIC.invoices i
                       ON o.order_id = i.order_id
                   LEFT OUTER JOIN ANALYTICS.PUBLIC.v_line_items li
                       ON i.invoice_id = li.invoice_id
                   LEFT OUTER JOIN es_warehouse.public.approved_invoice_salespersons ais
                       ON i.invoice_id = ais.invoice_id
                   INNER JOIN ES_WAREHOUSE.PUBLIC.order_salespersons os
                       ON o.order_id = os.order_id
                   INNER JOIN ES_WAREHOUSE.PUBLIC.users u
                       ON o.user_id = u.user_id
                   INNER JOIN ES_WAREHOUSE.PUBLIC.companies c
                       ON u.company_id = c.company_id
                   INNER JOIN ES_WAREHOUSE.PUBLIC.users u2
                       ON COALESCE(ais.primary_salesperson_id, os.user_id, o.salesperson_user_id) = u2.user_id
                   LEFT JOIN analytics.payroll.company_directory cd ON lower(cd.work_email) = lower(u2.email_address)

       WHERE   i.invoice_date > DATEADD(MONTH, -12, CURRENT_DATE())
               AND u.company_id IS NOT NULL
               AND os.salesperson_type_id = 1
               AND COALESCE(ais.primary_salesperson_id, os.user_id, o.salesperson_user_id) IS NOT NULL

       GROUP BY    u.company_id
                   , c.name
                   , final_salesperson_user_id
                   , u.company_id
                   , u2.first_name
                   , u2.last_name
                   , cd.employee_title

       HAVING  SUM(li.amount) > 0

       QUALIFY rank_number = 1
   )

   , assetlist
AS
   (
       SELECT  r.RENTAL_ID
               , r.ORDER_ID
               , a.ASSET_ID
               , COALESCE(a.RENTAL_BRANCH_ID, a.INVENTORY_BRANCH_ID) AS MARKET_ID
               , CONCAT(a.MAKE, ' ', a.MODEL) as MAKEANDMODEL
               , CONVERT_TIMEZONE('America/Chicago', r.START_DATE) as RENTAL_DATE
               , CASE
                   WHEN CONVERT_TIMEZONE('America/Chicago', sais.DATE_START) BETWEEN DATEADD(HOUR, -36, CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP()))
                               AND CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())
                           AND sais.DATE_START::DATE >= DATEADD(HOUR, -24, r.START_DATE)::DATE
                           AND sais.DATE_START::DATE <= DATEADD(HOUR, 24, r.START_DATE)::DATE
                           AND sais.current_flag = 1 THEN
                       'On Rent'
                   WHEN CONVERT_TIMEZONE('America/Chicago', sais.DATE_END) BETWEEN DATEADD(HOUR, -36, CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP()))
                               AND CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())
                           AND sais.DATE_END::DATE >= DATEADD(HOUR, -24, r.END_DATE)::DATE
                           AND sais.DATE_END::DATE <= DATEADD(HOUR, 24, r.END_DATE)::DATE
                           AND sais.DATE_END IS NOT NULL THEN
                       'Off Rent'
                   ELSE
                       'Unrecognized Status'
               END as STATUS

       FROM    ES_WAREHOUSE.PUBLIC.ASSETS a
                   INNER JOIN ES_WAREHOUSE.PUBLIC.RENTALS r
                       ON a.ASSET_ID = r.ASSET_ID
                           AND a.ASSET_TYPE_ID = 1
                   INNER JOIN ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY_STATUS sais
                       ON a.ASSET_ID = sais.ASSET_ID
                           AND sais.ASSET_INVENTORY_STATUS = 'On Rent'

       WHERE       (
                       CONVERT_TIMEZONE('America/Chicago', sais.DATE_START) BETWEEN DATEADD(HOUR, -36, CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP()))
                           AND CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())
                       AND sais.DATE_START::DATE >= DATEADD(HOUR, -24, r.START_DATE)::DATE
                       AND sais.DATE_START::DATE <= DATEADD(HOUR, 24, r.START_DATE)::DATE
                       AND sais.CURRENT_FLAG = 1
                   )
               OR
                   (
                       CONVERT_TIMEZONE('America/Chicago', sais.DATE_END) BETWEEN DATEADD(HOUR, -36, CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP()))
                           AND CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())
                       AND sais.DATE_END::DATE >= DATEADD(HOUR, -24, r.END_DATE)::DATE
                       AND sais.DATE_END::DATE <= DATEADD(HOUR, 24, r.END_DATE)::DATE
                       AND sais.DATE_END IS NOT NULL
                   )

       UNION

       SELECT  r.RENTAL_ID
               , r.ORDER_ID
               , a.ASSET_ID
               , COALESCE(a.RENTAL_BRANCH_ID, a.INVENTORY_BRANCH_ID) AS MARKET_ID
               , CONCAT(a.MAKE, ' ', a.MODEL) as MAKEANDMODEL
               , CONVERT_TIMEZONE('America/Chicago', r.START_DATE) as RENTAL_DATE
               , 'Total On Rent' as STATUS

       FROM    ES_WAREHOUSE.PUBLIC.ASSETS a
                   INNER JOIN ES_WAREHOUSE.PUBLIC.RENTALS r
                       ON a.ASSET_ID = r.ASSET_ID
                           AND a.ASSET_TYPE_ID = 1
                           AND r.RENTAL_STATUS_ID = 5
                   INNER JOIN ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY_STATUS sais
                       ON a.ASSET_ID = sais.ASSET_ID
                           AND sais.CURRENT_FLAG = 1
   )

SELECT  a.RENTAL_ID
       , a.ASSET_ID
       , a.MAKEANDMODEL
       , c.COMPANY_ID
       , c.NAME as company_name
       , CONCAT(ii.FIRST_NAME,' ', ii.LAST_NAME, ' - ', ii.final_salesperson_user_id) AS MAIN_SALESPERSON
       , m.MARKET_ID
       , m.NAME AS MARKET_NAME
       , a.RENTAL_DATE
       , a.STATUS
       , concat(si.name, ' - ', COALESCE(si.home_market_dated, concat('District ',si.district_dated), si.region_name_dated)) as sp_name_location

FROM    assetlist a
           LEFT OUTER JOIN ES_WAREHOUSE.PUBLIC.orders o
               ON a.ORDER_ID = o.ORDER_ID
           LEFT OUTER JOIN ES_WAREHOUSE.PUBLIC.users u
               ON o.USER_ID = u.USER_ID
           LEFT OUTER JOIN ES_WAREHOUSE.PUBLIC.companies c
               ON u.COMPANY_ID = c.COMPANY_ID
           LEFT OUTER JOIN invoices_info ii
               ON c.COMPANY_ID = ii.COMPANY_ID
           LEFT OUTER JOIN ES_WAREHOUSE.PUBLIC.markets m
               ON a.MARKET_ID = m.MARKET_ID
          LEFT OUTER JOIN analytics.bi_ops.salesperson_info si ON si.user_id = ii.final_salesperson_user_id AND record_ineffective_date IS NULL

 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: makeandmodel {
    type: string
    sql: ${TABLE}."MAKEANDMODEL" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name._filterable_value | url_encode }}&Company%20ID="
    }
  }

  dimension: company_name_formatted {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{filterable_value | url_encode}}&Company+ID="target="_blank"> {{rendered_value}}  ➔ </a></font>
    <td>
    <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
    </td>;;
  }

  dimension: sp_name_location {
    type: string
    sql: ${TABLE}."SP_NAME_LOCATION" ;;
  }

  dimension: main_salesperson {
    type: string
    sql: ${TABLE}."MAIN_SALESPERSON" ;;


  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension_group: rental_date {
    type: time
    sql: ${TABLE}."RENTAL_DATE" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  measure: off_rent_count {
    type: sum
    sql: CASE WHEN ${status} = 'Off Rent' THEN 1 END ;;
    drill_fields: [detail*]
  }

  measure: on_rent_count {
    type: sum
    sql: CASE WHEN ${status} = 'On Rent' THEN 1 END ;;
    drill_fields: [detail*]
  }

  measure: total_on_rent_count {
    type: sum
    sql: CASE WHEN ${status} = 'Total On Rent' THEN 1 END ;;
    drill_fields: [detail*]
  }

  measure: net_change {
    type: number
    sql: ${on_rent_count} - ${off_rent_count} ;;
  }

  measure: net_change_formatted {
    type: number
    sql: ${net_change} ;;
    html: {% if net_change._value > 0 %}
      <span style="color: darkgreen;"> {{net_change._rendered_value }} </span>

    {% elsif net_change._value < 0 %}
      <span style="color: #b02a3e;"> {{net_change._rendered_value }} </span>

    {% else %}
    <span style="color: black;"> {{net_change._rendered_value }} </span>

    {% endif %};;
  }

  set: detail {
    fields: [
      rental_id,
      asset_id,
      makeandmodel,
      company_id,
      company_name,
      main_salesperson,
      market_id,
      market_name,
      rental_date_time,
      status
    ]
  }
}

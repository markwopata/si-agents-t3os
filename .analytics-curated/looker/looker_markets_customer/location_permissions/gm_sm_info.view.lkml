
view: gm_sm_info {
  derived_table: {
    sql: SELECT
            cd.market_id,
            MAX(CASE WHEN cd.employee_title = 'General Manager'
            THEN cd.first_name || ' ' || cd.last_name
            ELSE NULL END) AS general_manager,
            MAX(CASE WHEN cd.employee_title = 'General Manager'
            THEN work_phone
            ELSE NULL END) AS general_manager_phone,
            MAX(CASE WHEN cd.employee_title = 'General Manager'
            THEN work_email
            ELSE NULL END) AS general_manager_email,

            MAX(CASE WHEN cd.employee_title = 'Service Manager'
            THEN cd.first_name || ' ' || cd.last_name
            ELSE NULL END) AS service_manager,
            MAX(CASE WHEN cd.employee_title = 'Service Manager'
            THEN work_phone
            ELSE NULL END) AS service_manager_phone,
            MAX(CASE WHEN cd.employee_title = 'Service Manager'
            THEN work_email
            ELSE NULL END) AS service_manager_email,
            FROM analytics.payroll.company_directory cd
            WHERE employee_status = 'Active'
            GROUP BY cd.market_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: general_manager {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER" ;;
    html: <font color="#000000">
          {{rendered_value}} </a>
          <br />
          <font style="color: #000000; text-align: right;">Phone: </font>
          <font style="color: #8C8C8C; text-align: right;">{{general_manager_phone._rendered_value }} </font>
            <br />
          <font style="color: #000000; text-align: right;">Email: </font>
          <font style="color: #8C8C8C; text-align: right;">{{general_manager_email._rendered_value }} </font>
          ;;
  }

  dimension: general_manager_phone {
    type: string
    # sql: ${TABLE}."GENERAL_MANAGER_PHONE" ;;
    sql: CONCAT(
          SUBSTR(${TABLE}."GENERAL_MANAGER_PHONE", 1, 3), '-',
          SUBSTR(${TABLE}."GENERAL_MANAGER_PHONE", 4, 3), '-',
          SUBSTR(${TABLE}."GENERAL_MANAGER_PHONE", 7, 4)
          ) ;;
  }

  dimension: general_manager_email {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_EMAIL" ;;
  }

  dimension: service_manager {
    type: string
    sql: ${TABLE}."SERVICE_MANAGER" ;;
    html: <font color="#000000">
          {{rendered_value}} </a>
          <br />
          <font style="color: #000000; text-align: right;">Phone: </font>
          <font style="color: #8C8C8C; text-align: right;">{{service_manager_phone._rendered_value }} </font>
           <br />
          <font style="color: #000000; text-align: right;">Email: </font>
          <font style="color: #8C8C8C; text-align: right;">{{service_manager_email._rendered_value }} </font>
          ;;
  }
  dimension: service_manager_phone {
    type: string
    # sql: ${TABLE}."SERVICE_MANAGER_PHONE" ;;
    sql: CONCAT(
          SUBSTR(${TABLE}."SERVICE_MANAGER_PHONE", 1, 3), '-',
          SUBSTR(${TABLE}."SERVICE_MANAGER_PHONE", 4, 3), '-',
          SUBSTR(${TABLE}."SERVICE_MANAGER_PHONE", 7, 4)
          ) ;;
  }

  dimension: service_manager_email {
    type: string
    sql: ${TABLE}."SERVICE_MANAGER_EMAIL" ;;
  }

  set: detail {
    fields: [
        market_id,
  general_manager,
  general_manager_phone,
  general_manager_email,
  service_manager,
  service_manager_phone,
  service_manager_email
    ]
  }
}

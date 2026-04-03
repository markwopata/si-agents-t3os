view: time_tracking_wo_vs_unallocated {
  derived_table: {
    sql: SELECT
    row_number() over (order by te.work_order_id) as pk,
    U.EMPLOYEE_ID::VARCHAR                                      AS EMPLOYEE_ID,
       CD.EMPLOYEE_TITLE,
       upper(COALESCE(CD.NICKNAME, CD.FIRST_NAME || ' ' || CD.LAST_NAME)) AS EMPLOYEE_NAME,
       TE.START_DATE,
       TE.END_DATE,
       WOT.NAME                                                    AS WORK_ORDER_TYPE,
       CD.MARKET_ID,
       X.MARKET_NAME,
       X.REGION_DISTRICT,
       TE.WORK_ORDER_ID,
       SUM(TE.REGULAR_HOURS + TE.OVERTIME_HOURS)                   AS TOTAL_HOURS,
       IFF(TE.WORK_ORDER_ID IS NULL, 0, TOTAL_HOURS)               AS ASSIGNED_HOURS,
       IFF(TE.WORK_ORDER_ID IS NULL, TOTAL_HOURS, 0)               AS UNASSIGNED_HOURS
FROM ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRIES AS TE
         INNER JOIN ES_WAREHOUSE.PUBLIC.USERS AS U
          ON TE.USER_ID = U.USER_ID
         INNER JOIN ANALYTICS.PAYROLL.COMPANY_DIRECTORY AS CD
          ON U.EMPLOYEE_ID::VARCHAR = CD.EMPLOYEE_ID::VARCHAR
         INNER JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK AS X
          ON CD.MARKET_ID = X.MARKET_ID
         LEFT JOIN ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS AS WO
          ON TE.WORK_ORDER_ID = WO.WORK_ORDER_ID
         LEFT JOIN ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_TYPES AS WOT
          ON WO.WORK_ORDER_TYPE_ID = WOT.WORK_ORDER_TYPE_ID
WHERE TE.START_DATE >= '2022-01-01'
  AND TE.EVENT_TYPE_ID = 1
  AND TE.APPROVAL_STATUS = 'Approved'
  AND CD.EMPLOYEE_TITLE ILIKE ANY ('%technician%', '%mechanic%')
  and CD.EMPLOYEE_TITLE NOT ILIKE '%yard technician%' -- Mark W says don't include yard techs
GROUP BY U.EMPLOYEE_ID::VARCHAR, CD.EMPLOYEE_TITLE, upper(COALESCE(CD.NICKNAME, CD.FIRST_NAME || ' ' || CD.LAST_NAME)),
         TE.START_DATE, TE.END_DATE, WOT.NAME, CD.MARKET_ID, X.MARKET_NAME, X.REGION_DISTRICT, TE.WORK_ORDER_ID
       ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

 dimension: start_date {
   type:date
  sql: ${TABLE}."START_DATE" ;;
 }

  dimension_group: start_date_group {
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: end_date {
    type: date
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: employee_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: work_order_type {
    type: string
    sql: ${TABLE}."WORK_ORDER_TYPE" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
    # primary_key: yes
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_name_link {
    type: string
    html:
    <font color="blue "><u><a href = "@{db_unassigned_tech_hours_detail}?Period={{ _filters["plexi_periods.display"] | url_encode }}&Market+Name={{ time_tracking_wo_vs_unallocated.market_name._filterable_value | url_encode }}&Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&District={{ _filters['market_region_xwalk.region_district'] | url_encode }}&Market+Type={{ _filters['market_region_xwalk.market_type'] | url_encode }}&Markets+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}" target="_blank">{{ market_name_link._value }}</a></font></u>;;
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;  }

  dimension: work_order_id {
    type: string
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  measure: total_hours {
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."TOTAL_HOURS" ;;
  }

  measure: assigned_hours {
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."ASSIGNED_HOURS" ;;
  }

  measure: unassigned_hours {
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."UNASSIGNED_HOURS" ;;
    drill_fields: [employee_name, employee_title, unassigned_hours, assigned_hours, total_hours]
  }

  measure: percent_unassigned {
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: ${unassigned_hours}/nullifzero(${total_hours}) ;;
    drill_fields: [market_name,unassigned_hours]
  }

  measure: percent_assigned {
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: ${assigned_hours}/nullifzero(${total_hours}) ;;

  }



  measure: percent_assigned_combined {
    type: string
    sql: ${percent_assigned} || ' '|| ${assigned_hours} ;;
  }

  measure: work_order_count {
    type: sum
    #value_format: "#,##0.00;(#,##0.00);-"
    sql: case when ${work_order_id} is null then 0 else 1 end ;;
  }

  dimension: work_order_id_t3 {
    type: string
    html:<font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}/time" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: unassigned_tech_hours_link_button {
    type: string
    sql: 'Unassigned Tech Hours Detail' ;;
    html: <a style="color:rgb(26, 115, 232)" href="@{db_time_tracking_wo_vs_unallocated_detail}?Period={{ _filters['plexi_periods.display'] | url_encode }}&toggle=det" target="_blank">{{value}}</a> ;;
  }

  dimension: pk {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK" ;;
  }


  }

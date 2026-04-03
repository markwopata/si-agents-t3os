view: costcapture_po_to_corporate {
  derived_table: {
    sql: Select po.PURCHASE_ORDER_NUMBER,
       m.market_id,
       m.NAME,
       concat(u.first_name, ' ', u.last_name) as CREATOR,
       u.username,
       cd.WORK_EMAIL,
       (TO_CHAR(TO_DATE(CONVERT_TIMEZONE('UTC', 'America/Chicago', CAST(po.DATE_CREATED AS TIMESTAMP_NTZ))),
                'YYYY-MM-DD HH24:MI:SS'))     AS "WHENCREATED"

FROM PROCUREMENT.PUBLIC.PURCHASE_ORDERS po
         left join ES_WAREHOUSE.PUBLIC.MARKETS m on po.DELIVER_TO_ID = m.market_id
         left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = po.created_by_id
         left join "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY" cd on cd.work_email = u.username
         left join ANALYTICS.INTACCT.DEPARTMENT d ON m.MARKET_ID::VARCHAR = d.DEPARTMENTID::VARCHAR
where po.company_id = 1854
  AND (po.DELIVER_TO_ID IN ('13481', '66785')
    OR d.DEPARTMENT_TYPE IN ('Forge & Build','D365'))
  and po.DATE_CREATED >= DATEADD(HOUR, -24, CURRENT_TIMESTAMP())
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: purchase_order_number {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: creator {
    type: string
    sql: ${TABLE}."CREATOR" ;;
  }

  dimension: username {
    type: string
    sql: ${TABLE}."USERNAME" ;;
  }

  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  dimension: whencreated {
    type: string
    sql: ${TABLE}."WHENCREATED" ;;
  }

  set: detail {
    fields: [
      purchase_order_number,
      market_id,
      market_name,
      creator,
      username,
      work_email,
      whencreated
    ]
  }
}

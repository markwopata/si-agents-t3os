view: unclaimed_property {
  derived_table: {
    sql: SELECT co.COMPANY_ID,
       co.NAME AS COMPANY_NAME,
       CASE
           WHEN l.ZIP_CODE IS NULL THEN CONCAT(l.CITY, ', ', s.ABBREVIATION)
           WHEN l.STREET_2 IS NULL THEN CONCAT(l.STREET_1, ', ', l.CITY, ', ', s.ABBREVIATION, ' ', l.ZIP_CODE)
           ELSE CONCAT(l.STREET_1, ' ', l.STREET_2, ', ', l.CITY, ', ', s.ABBREVIATION, ' ', l.ZIP_CODE) END AS ADDRESS
FROM ES_WAREHOUSE.PUBLIC.COMPANIES co
LEFT JOIN ES_WAREHOUSE.PUBLIC.LOCATIONS l ON co.BILLING_LOCATION_ID = l.LOCATION_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.STATES s ON l.STATE_ID = s.STATE_ID ;;
  }

  dimension: company_id {
    type: string
    primary_key: yes
    label: "Company ID"
    sql: ${TABLE}."COMPANY_ID" ;;
    html: <a href="{{ company_url._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;
  }

  dimension: company_url {
    type: string
    sql: CONCAT('https://admin.equipmentshare.com/#/home/companies/',${TABLE}."COMPANY_ID") ;;
  }

  dimension: company_name {
    type: string
    label: "Company Name"
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: company_address {
    type: string
    label: "Company Address"
    sql: ${TABLE}."ADDRESS" ;;
  }
}

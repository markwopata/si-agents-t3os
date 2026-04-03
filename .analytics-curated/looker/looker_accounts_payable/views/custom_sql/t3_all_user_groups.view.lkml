view: t3_all_user_groups {
  derived_table: {
    sql: SELECT g.NAME                                                                                  AS GROUP_NAME,
       g.DATE_ARCHIVED                                                                         AS GROUP_ARCHIVED_DATE,
       ro.NAME                                                                                 AS ROLE_NAME,
       ro.DATE_ARCHIVED                                                                        AS ROLE_DATE_ARCHIVED,
       ro.SPENDING_LIMIT                                                                       AS ROLE_SPENDING_LIMIT,
       CASE
           WHEN t.RESOURCE_TYPE_ID = 1 THEN 'EquipmentShare'
           WHEN t.RESOURCE_TYPE_ID = 2 THEN CONCAT('Company: ', c.COMPANY_ID, ' - ', c.NAME)
           WHEN t.RESOURCE_TYPE_ID = 3 THEN CONCAT('Region: ', re.REGION_ID, ' - ', re.NAME)
           WHEN t.RESOURCE_TYPE_ID = 4 THEN CONCAT('Store: ', r.OBJECT_ID, ' - ', l.NAME)
           WHEN t.RESOURCE_TYPE_ID = 5 THEN CONCAT('Branch: ', r.OBJECT_ID, ' - ', m.NAME) END AS RESOURCE,
       u.EMPLOYEE_ID,
       CONCAT(u.FIRST_NAME, ' ', u.LAST_NAME)                                                  AS USER_NAME,
       u.EMAIL_ADDRESS,
       cd.EMPLOYEE_TITLE,
       cd.DATE_TERMINATED,
       cd.MARKET_ID,
       cd.DEFAULT_COST_CENTERS_FULL_PATH
FROM ES_WAREHOUSE.INVENTORY.RESOURCE_POLICIES rp
         LEFT JOIN ES_WAREHOUSE.INVENTORY.RESOURCES r ON rp.RESOURCE_ID = r.RESOURCE_ID
         LEFT JOIN ES_WAREHOUSE.INVENTORY.RESOURCE_TYPES t ON r.RESOURCE_TYPE_ID = t.RESOURCE_TYPE_ID
         LEFT JOIN ES_WAREHOUSE.INVENTORY.GROUPS g ON rp.GROUP_ID = g.GROUP_ID
         LEFT JOIN ES_WAREHOUSE.INVENTORY.ROLES ro ON rp.ROLE_ID = ro.ROLE_ID
         LEFT JOIN ES_WAREHOUSE.INVENTORY.USER_GROUPS ug ON ug.GROUP_ID = rp.GROUP_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS u ON ug.USER_ID = u.USER_ID
         LEFT JOIN ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd ON u.EMPLOYEE_ID = CAST(cd.EMPLOYEE_ID AS VARCHAR)
-- STORES - RESOURCE TYPE = 4
         LEFT JOIN ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS l ON r.OBJECT_ID = l.INVENTORY_LOCATION_ID
    AND r.RESOURCE_TYPE_ID = 4
-- BRANCHES - RESOURCE TYPE = 5
         LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS m ON r.OBJECT_ID = m.MARKET_ID AND r.RESOURCE_TYPE_ID = 5
-- COMPANIES - RESOURCE TYPE = 2
         LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES c ON r.OBJECT_ID = c.COMPANY_ID AND r.RESOURCE_TYPE_ID = 2
-- REGIONS - RESOURCE TYPE = 3
         LEFT JOIN ES_WAREHOUSE.INVENTORY.REGIONS re ON r.OBJECT_ID = re.REGION_ID AND r.RESOURCE_TYPE_ID = 3
WHERE r.COMPANY_ID = 1854
ORDER BY g.NAME ;;
  }

  dimension: group_name {
    label: "Group Name"
    type: string
    sql: ${TABLE}."GROUP_NAME" ;;
  }

  dimension: group_archived_date {
    label: "Group Archived Date"
    type: date_time
    sql: ${TABLE}."GROUP_ARCHIVED_DATE" ;;
  }

  dimension: role_name {
    label: "Role Name"
    type: string
    sql: ${TABLE}."ROLE_NAME" ;;
  }

  dimension: role_archived_date {
    label: "Role Archived Date"
    type: date_time
    sql: ${TABLE}."ROLE_DATE_ARCHIVED" ;;
  }

  dimension: role_spending_limit {
    label: "Spending Limit"
    type: number
    sql: ${TABLE}."ROLE_SPENDING_LIMIT" ;;
  }

  dimension: resource {
    label: "Resource"
    type: string
    sql: ${TABLE}."RESOURCE" ;;
  }

  dimension: employee_id {
    label: "Employee ID"
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: user_name {
    label: "User Name"
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: email {
    label: "Email"
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: employee_title {
    label: "Employee Title"
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: date_terminated {
    label: "Date Terminated"
    type: date
    sql: ${TABLE}."DATE_TERMINATED" ;;
  }

  dimension: department_id {
    label: "Department ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: cost_center {
    label: "Department - Full Path"
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }

  measure: role_count {
    type: count_distinct
    label: "Role Count"
    sql: CONCAT(${role_name},${resource}) ;;
    drill_fields: [details*]
  }

  measure: user_count {
    type: count_distinct
    label: "User Count"
    sql: ${user_name} ;;
    drill_fields: [user_details*]
  }

  measure: is_active_group {
    type: yesno
    sql: IFF(${group_archived_date} IS NULL, true, false) ;;
  }

  measure: is_active_role {
    type: yesno
    sql: IFF(${role_archived_date} IS NULL, true, false) ;;
  }

  measure: is_terminated {
    type: yesno
    sql: IFF(${date_terminated} IS NULL, false, true) ;;
  }

  set: details {
    fields: [
      group_name,
      role_name,
      role_spending_limit,
      resource
    ]}

  set: user_details {
    fields: [
      employee_id,
      user_name,
      email,
      employee_title,
      date_terminated,
      department_id,
      cost_center
    ]
  }
}

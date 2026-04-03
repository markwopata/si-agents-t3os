view: po_approval_limits_by_user {

    derived_table: {
      sql:
/*
 This query creates a live report of the previously static report 'Corporate Sage users - DOA Levels'.
 Its purpose is to view the Approval Limits of all Sage Intacct users within the company and to provide
 the ability to view by a variety of factors like their number of reports, title, cost center, and more.
 */
WITH dept AS (
    SELECT INTACCT_USER_LOGIN,
           LISTAGG(DISTINCT
                   CASE
                       WHEN ur.RESTRICTION_TYPE = 'DEPARTMENT'
                           THEN CONCAT(ur.RESTRICTION_VALUE, ' - ', d.TITLE)
                       ELSE '' END, ',') AS LOCATION
    FROM ANALYTICS.INTACCT.USER_RESTRICTIONS ur
    LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT d ON ur.RESTRICTION_VALUE = d.DEPARTMENTID
    WHERE RESTRICTION_TYPE = 'DEPARTMENT'
    GROUP BY INTACCT_USER_LOGIN
),

entity AS (
    SELECT INTACCT_USER_LOGIN,
           LISTAGG(DISTINCT
                   CASE WHEN ur.RESTRICTION_TYPE = 'LOCATION' THEN ur.RESTRICTION_VALUE ELSE '' END, ',') AS ENTITY
    FROM ANALYTICS.INTACCT.USER_RESTRICTIONS ur
    WHERE RESTRICTION_TYPE = 'LOCATION'
    GROUP BY INTACCT_USER_LOGIN
),

po_access AS (
    SELECT DISTINCT r.RECORDNO AS ROLE_ID,
                    r.NAME     AS ROLE_NAME
    FROM ANALYTICS.INTACCT.ROLES r
    LEFT JOIN ANALYTICS.INTACCT.ROLEPOLICYASSIGNMENT rpa ON r.RECORDNO = rpa.ROLEKEY
    WHERE rpa.MODULE = 'po'
),

po_app AS (
    SELECT DISTINCT r.RECORDNO        AS ROLE_ID,
                    r.NAME            AS ROLE_NAME,
                    CASE
                        WHEN rpa.RIGHTS LIKE '%Level6%' THEN 'No Limit'
                        WHEN rpa.RIGHTS LIKE '%Level5%' THEN 'Up to $75k'
                        WHEN rpa.RIGHTS LIKE '%Level4%' THEN 'Up to $50k'
                        WHEN rpa.RIGHTS LIKE '%Level3%' THEN 'Up to $25k'
                        WHEN rpa.RIGHTS LIKE '%Level2%' THEN 'Up to $10k'
                        WHEN rpa.RIGHTS LIKE '%Level1%' THEN 'Up to $5k'
                        ELSE NULL END AS PO_APPROVAL_LIMIT
    FROM ANALYTICS.INTACCT.ROLES r
    LEFT JOIN ANALYTICS.INTACCT.ROLEPOLICYASSIGNMENT rpa ON r.RECORDNO = rpa.ROLEKEY
    WHERE rpa.MODULE = 'po'
      AND rpa.POLICYNAME = 'Purchasing Approval Levels'
),

num_reports AS (
        SELECT
        DIRECT_MANAGER_EMPLOYEE_ID,
        COUNT(*) AS Report_Count
        FROM ANALYTICS.PAYROLL.COMPANY_DIRECTORY
        WHERE EMPLOYEE_STATUS NOT IN ('Never Started', 'Terminated', 'Inactive', 'Not In Payroll', 'Not in Payroll')
        GROUP BY DIRECT_MANAGER_EMPLOYEE_ID
),
ranked_roles AS (
    SELECT
        CD.EMPLOYEE_ID                                          AS "Employee ID",
        CD.FIRST_NAME                                           AS "First Name",
        CD.LAST_NAME                                            AS "Last Name",
        CD.WORK_EMAIL                                           AS "Email",
        CD.EMPLOYEE_TITLE                                       AS "Title",
        CD.LOCATION                                             AS "Location",
        -- Split the 'DEFAULT_COST_CENTERS_FULL_PATH' by '/'
        SPLIT_PART(CD.DEFAULT_COST_CENTERS_FULL_PATH, '/', 1)   AS "Cost Center Level 1",
        SPLIT_PART(CD.DEFAULT_COST_CENTERS_FULL_PATH, '/', 2)   AS "Cost Center Level 2",
        SPLIT_PART(CD.DEFAULT_COST_CENTERS_FULL_PATH, '/', 3)   AS "Cost Center Level 3",
        SPLIT_PART(CD.DEFAULT_COST_CENTERS_FULL_PATH, '/', 4)   AS "Cost Center Level 4",
        SPLIT_PART(CD.DEFAULT_COST_CENTERS_FULL_PATH, '/', 5)   AS "Cost Center Level 5",
        CD.MARKET_ID                                            AS "Market",
        u.ADMIN                                                 AS ADMIN_ACCESS,
        u.USERTYPE                                              AS USER_TYPE,
        u.STATUS                                                AS USER_STATUS,
        ug.NAME                                                 AS USER_GROUP_NAME,
        ug.DESCR                                                AS USER_GROUP_DESCRIPTION,
        rl.NAME                                                 AS ROLE_NAME,
        rl.DESCRIPTION                                          AS ROLE_DESCRIPTION,
        cd.EMPLOYEE_TITLE                                       AS EMPLOYEE_TITLE,
        dept.LOCATION                                           AS LOCATION_RESTRICTIONS,
        entity.ENTITY                                           AS ENTITY_RESTRICTIONS,
        po_access.ROLE_ID,
        po_app.PO_APPROVAL_LIMIT,
        num_reports.Report_Count,
        CASE
            WHEN PO_APPROVAL_LIMIT = 'No Limit' THEN 1
            WHEN PO_APPROVAL_LIMIT = 'Up to $75k' THEN 2
            WHEN PO_APPROVAL_LIMIT = 'Up to $50k' THEN 3
            WHEN PO_APPROVAL_LIMIT = 'Up to $25k' THEN 4
            WHEN PO_APPROVAL_LIMIT = 'Up to $10k' THEN 5
            WHEN PO_APPROVAL_LIMIT = 'Up to $5k' THEN 6
            ELSE 9
        END AS Role_Hierarchy,
        ROW_NUMBER() OVER (PARTITION BY cd.WORK_EMAIL ORDER BY Role_Hierarchy ASC) AS ROLE_RANK
    FROM ANALYTICS.INTACCT.USERINFO u
    LEFT JOIN ANALYTICS.INTACCT.MEMBERUSERGROUP mug ON u.RECORDNO = mug.USERKEY
    LEFT JOIN ANALYTICS.INTACCT.USERGROUP ug ON mug.USERGROUPKEY = ug.RECORDNO
    LEFT JOIN ANALYTICS.INTACCT.ROLEASSIGNMENT ra ON ug.RECORDNO = ra.USER_GROUP_KEY AND ra.TYPE = 'G'
    LEFT JOIN ANALYTICS.INTACCT.ROLES rl ON ra.ROLEKEY = rl.RECORDNO
    LEFT JOIN ANALYTICS.INTACCT.CONTACT c ON u.CONTACTKEY = c.RECORDNO
    LEFT JOIN ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd ON lower(cd.WORK_EMAIL) = LOWER(c.EMAIL1)
    LEFT JOIN po_access ON rl.RECORDNO = po_access.ROLE_ID
    LEFT JOIN po_app ON rl.RECORDNO = po_app.ROLE_ID
    LEFT JOIN dept ON u.LOGINID = dept.INTACCT_USER_LOGIN
    LEFT JOIN entity ON u.LOGINID = entity.INTACCT_USER_LOGIN
    LEFT JOIN num_reports ON cd.EMPLOYEE_ID = num_reports.DIRECT_MANAGER_EMPLOYEE_ID
    WHERE u.STATUS = 'active'
      AND po_app.PO_APPROVAL_LIMIT IS NOT NULL
      AND cd.EMPLOYEE_ID IS NOT NULL
)

SELECT *
FROM ranked_roles
WHERE ROLE_RANK = 1
ORDER BY "Employee ID";;

    }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."Employee ID" ;;
    primary_key: yes
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."First Name" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."Last Name" ;;
  }

  dimension: work_email {
    type: string
    sql: ${TABLE}."Email" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."Title" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."Location" ;;
  }

  dimension: cost_center_level_1 {
    type: string
    sql: ${TABLE}."Cost Center Level 1" ;;
  }

  dimension: cost_center_level_2 {
    type: string
    sql: ${TABLE}."Cost Center Level 2" ;;
  }

  dimension: cost_center_level_3 {
    type: string
    sql: ${TABLE}."Cost Center Level 3" ;;
  }
  dimension: cost_center_level_4 {
    type: string
    sql: ${TABLE}."Cost Center Level 4" ;;
  }

  dimension: cost_center_level_5 {
    type: string
    sql: ${TABLE}."Cost Center Level 5" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."Market" ;;
  }
  dimension: admin {
    type: string
    sql: ${TABLE}."ADMIN_ACCESS" ;;
  }

  dimension: user_type {
    type: string
    sql: ${TABLE}."USER_TYPE" ;;
  }

  dimension: user_status {
    type: string
    sql: ${TABLE}."USER_STATUS" ;;
  }

  dimension: user_group_name {
    type: string
    sql: ${TABLE}."USER_GROUP_NAME" ;;
  }

  dimension: user_group_description {
    type: string
    sql: ${TABLE}."USER_GROUP_DESCRIPTION" ;;
  }

  dimension: role_name {
    type: string
    sql: ${TABLE}."ROLE_NAME" ;;
  }

  dimension: role_description {
    type: string
    sql: ${TABLE}."ROLE_DESCRIPTION" ;;
  }

  dimension: location_restrictions {
    type: string
    sql: ${TABLE}."LOCATION_RESTRICTIONS" ;;
  }

  dimension: entity_restrictions {
    type: string
    sql: ${TABLE}."ENTITY_RESTRICTIONS" ;;
  }

  dimension: role_id {
    type: string
    sql: ${TABLE}."ROLE_ID" ;;
  }

  dimension: po_approval_limit {
    type: string
    sql: ${TABLE}."PO_APPROVAL_LIMIT" ;;
  }

  dimension: report_count {
    type: number
    sql: ${TABLE}."REPORT_COUNT" ;;
  }

  dimension: role_hierarchy {
    type: number
    sql: ${TABLE}."ROLE_HIERARCHY" ;;
  }

  dimension: role_rank {
    type: number
    sql: ${TABLE}."ROLE_RANK" ;;
  }

  set: detail {
    fields: [
      employee_id,
      first_name,
      last_name,
      employee_title,
      location,
      cost_center_level_1,
      cost_center_level_2,
      cost_center_level_5,
      admin,
      user_type,
      user_group_name,
      role_name,
      role_id,
      po_approval_limit,
      report_count
    ]
  }
}

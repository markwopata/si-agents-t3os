view: sage_permissions {
  derived_table: {
    sql: WITH purchasing_level_per_user AS (
    SELECT
        USR.LOGINID AS USER_LOGIN,
        TO_NUMBER(REGEXP_SUBSTR(RPA.RIGHTS, '\\d+$')) AS LEVEL_NUMBER,
        ROW_NUMBER() OVER (
            PARTITION BY USR.LOGINID
            ORDER BY
                CASE WHEN RPA.POLICYNAME = 'Purchasing Approval Levels' THEN 1 ELSE 2 END
        ) AS RN
    FROM ANALYTICS.INTACCT.USERINFO USR
    LEFT JOIN ANALYTICS.INTACCT.MEMBERUSERGROUP MUG ON USR.RECORDNO = MUG.USERKEY
    LEFT JOIN ANALYTICS.INTACCT.USERGROUP UG ON MUG.USERGROUPKEY = UG.RECORDNO
    LEFT JOIN ANALYTICS.INTACCT.ROLEASSIGNMENT RA ON UG.RECORDNO = RA.USER_GROUP_KEY
    LEFT JOIN ANALYTICS.INTACCT.ROLES R ON RA.ROLEKEY = R.RECORDNO
    LEFT JOIN ANALYTICS.INTACCT.ROLEPOLICYASSIGNMENT RPA ON R.RECORDNO = RPA.ROLEKEY
    WHERE RPA.POLICYNAME = 'Purchasing Approval Levels'
),
po_view_access_per_user AS (
  SELECT
    USR.LOGINID AS USER_LOGIN,
    MAX(CASE
      WHEN RPA.POLICYNAME ILIKE '%Purchasing Transactions%'
       AND RPA.RIGHTS ILIKE '%read%' THEN 'Yes'
      ELSE 'No'
    END) AS PO_VIEW_ACCESS
  FROM ANALYTICS.INTACCT.USERINFO USR
  LEFT JOIN ANALYTICS.INTACCT.MEMBERUSERGROUP MUG ON USR.RECORDNO = MUG.USERKEY
  LEFT JOIN ANALYTICS.INTACCT.USERGROUP UG ON MUG.USERGROUPKEY = UG.RECORDNO
  LEFT JOIN ANALYTICS.INTACCT.ROLEASSIGNMENT RA ON UG.RECORDNO = RA.USER_GROUP_KEY
  LEFT JOIN ANALYTICS.INTACCT.ROLES R ON RA.ROLEKEY = R.RECORDNO
  LEFT JOIN ANALYTICS.INTACCT.ROLEPOLICYASSIGNMENT RPA ON R.RECORDNO = RPA.ROLEKEY
  GROUP BY USR.LOGINID
)
SELECT
USR.DESCRIPTION                                                       AS USER_NAME,
USR.LOGINID                                                           AS USER_LOGIN,
USR.USERTYPE                                                          AS USER_TYPE,
CASE
   WHEN USR.ADMIN = 'Full' THEN 'Full'
   WHEN USR.ADMIN = 'true' THEN 'Limited'
   WHEN USR.ADMIN = 'false' THEN 'Off'
   ELSE NULL
END                                                                   AS ADMIN_PRIVLEDGES,
USR.STATUS                                                            AS USER_STATUS,
CD.DIRECT_MANAGER_NAME                                                AS MANAGER_NAME,
CD.EMPLOYEE_TITLE                                                     AS WORKDAY_TITLE,
CASE
  WHEN SPLIT_PART(CD.DEFAULT_COST_CENTERS_FULL_PATH, '/', -1) = 'Administrative'
    THEN SPLIT_PART(CD.DEFAULT_COST_CENTERS_FULL_PATH, '/', -2)
  ELSE SPLIT_PART(CD.DEFAULT_COST_CENTERS_FULL_PATH, '/', -1)
END                                                                   AS COST_CENTER_NAME,
COALESCE(
  GREATEST(CAST(DATE_REHIRED AS DATE), CAST(DATE_HIRED AS DATE)),
  CAST(DATE_REHIRED AS DATE),
  CAST(DATE_HIRED AS DATE)
)                                                                     AS EFFECTIVE_HIRE_DATE,
CAST(
  CASE
    WHEN DATE_TERMINATED > COALESCE(
      GREATEST(CAST(DATE_REHIRED AS DATE), CAST(DATE_HIRED AS DATE)),
      CAST(DATE_REHIRED AS DATE),
      CAST(DATE_HIRED AS DATE)
    ) THEN DATE_TERMINATED
    ELSE NULL
  END
AS DATE)                                                              AS FINAL_DATE_TERMINATED,
PV.PO_VIEW_ACCESS                                                     AS PO_VIEW_ACCESS,
CASE
    WHEN MAX(PLU.LEVEL_NUMBER) = 1 THEN 'Up to $5k'
    WHEN MAX(PLU.LEVEL_NUMBER) = 2 THEN 'Up to $10k'
    WHEN MAX(PLU.LEVEL_NUMBER) = 3 THEN 'Up to $25k'
    WHEN MAX(PLU.LEVEL_NUMBER) = 4 THEN 'Up to $50k'
    WHEN MAX(PLU.LEVEL_NUMBER) = 5 THEN 'Up to $75k'
    WHEN MAX(PLU.LEVEL_NUMBER) = 6 THEN 'No Limit'
    ELSE '$0'
END                                                                    AS PO_APPROVAL_LIMIT,
ENTITY.RESTRICTION_VALUE                                               AS ENTITY_RESTRICTIONS,
    CONCAT(DEP.RESTRICTION_VALUE, ' - ', D.TITLE)                      AS DEPARTMENT_RESTRICTIONS,
UG.NAME                                                                AS USER_GROUP,
R.NAME                                                                 AS ROLE_NAME,
R.DESCRIPTION                                                          AS ROLE_DESCRIPTION,
RPA.MODULE                                                             AS ROLE_MODULE,
RPA.POLICYNAME                                                         AS "RPA.POLICYNAME",
RPA.RIGHTS                                                             AS "RPA.RIGHTS"
FROM
          ANALYTICS.INTACCT.USERINFO             USR
LEFT JOIN ANALYTICS.INTACCT.MEMBERUSERGROUP      MUG    ON USR.RECORDNO          = MUG.USERKEY
LEFT JOIN ANALYTICS.INTACCT.USERGROUP            UG     ON MUG.USERGROUPKEY      = UG.RECORDNO
LEFT JOIN ANALYTICS.INTACCT.ROLEASSIGNMENT       RA     ON UG.RECORDNO           = RA.USER_GROUP_KEY
LEFT JOIN ANALYTICS.INTACCT.ROLES                R      ON RA.ROLEKEY            = R.RECORDNO
LEFT JOIN ANALYTICS.INTACCT.ROLEPOLICYASSIGNMENT RPA    ON R.RECORDNO            = RPA.ROLEKEY
LEFT JOIN ANALYTICS.INTACCT.CONTACT              C      ON USR.CONTACTKEY        = C.RECORDNO
LEFT JOIN ANALYTICS.INTACCT.USER_RESTRICTIONS    ENTITY ON USR.LOGINID           = ENTITY.INTACCT_USER_LOGIN AND ENTITY.RESTRICTION_TYPE = 'LOCATION'
LEFT JOIN ANALYTICS.INTACCT.USER_RESTRICTIONS    DEP    ON USR.LOGINID           = DEP.INTACCT_USER_LOGIN    AND DEP.RESTRICTION_TYPE = 'DEPARTMENT'
LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT           D      ON DEP.RESTRICTION_VALUE = D.DEPARTMENTID
LEFT JOIN (SELECT *,ROW_NUMBER() OVER (PARTITION BY WORK_EMAIL ORDER BY POSITION_EFFECTIVE_DATE DESC NULLS LAST) AS RN
    FROM ANALYTICS.PAYROLL.COMPANY_DIRECTORY QUALIFY RN = 1)
                                                  CD ON LOWER(C.EMAIL1)       = LOWER(CD.WORK_EMAIL)
LEFT JOIN purchasing_level_per_user PLU ON USR.LOGINID = PLU.USER_LOGIN AND PLU.RN = 1
LEFT JOIN po_view_access_per_user PV ON USR.LOGINID = PV.USER_LOGIN
GROUP BY
    USER_NAME,
    USR.LOGINID,
    USER_TYPE,
    ADMIN_PRIVLEDGES,
    USER_STATUS,
    MANAGER_NAME,
    WORKDAY_TITLE,
    COST_CENTER_NAME,
    EFFECTIVE_HIRE_DATE,
    FINAL_DATE_TERMINATED,
    PO_VIEW_ACCESS,
    ENTITY_RESTRICTIONS,
    DEPARTMENT_RESTRICTIONS,
    USER_GROUP,
    ROLE_NAME,
    ROLE_DESCRIPTION,
    ROLE_MODULE,
    "RPA.POLICYNAME",
    "RPA.RIGHTS"
ORDER BY USR.DESCRIPTION
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}.USER_NAME ;;
  }

  dimension: user_login {
    type: string
    sql: ${TABLE}.USER_LOGIN ;;
  }

  dimension: user_type {
    type: string
    sql: ${TABLE}.USER_TYPE ;;
  }

  dimension: admin_privledges {
    type: string
    sql: ${TABLE}.ADMIN_PRIVLEDGES ;;
  }

  dimension: user_status {
    type: string
    sql: ${TABLE}.USER_STATUS ;;
  }

  dimension: manager_name {
    type: string
    sql: ${TABLE}.MANAGER_NAME ;;
  }

  dimension: workday_title {
    type: string
    sql: ${TABLE}.WORKDAY_TITLE ;;
  }

  dimension: cost_center_name {
    type: string
    sql: ${TABLE}.COST_CENTER_NAME ;;
  }

  dimension: effective_hire_date {
    type: date
    sql: ${TABLE}.EFFECTIVE_HIRE_DATE ;;
  }

  dimension: final_date_terminated {
    type: date
    sql: ${TABLE}.FINAL_DATE_TERMINATED ;;
  }

  dimension: po_view_access {
    type: string
    sql: ${TABLE}.PO_VIEW_ACCESS ;;
  }

  dimension: po_approval_limit {
    type: string
    sql: ${TABLE}.PO_APPROVAL_LIMIT ;;
  }

  dimension: entity_restrictions {
    type: string
    sql: ${TABLE}.ENTITY_RESTRICTIONS ;;
  }

  dimension: department_restrictions {
    type: string
    sql: ${TABLE}.DEPARTMENT_RESTRICTIONS ;;
  }

  dimension: user_group {
    type: string
    sql: ${TABLE}.USER_GROUP ;;
  }

  dimension: role_name {
    type: string
    sql: ${TABLE}.ROLE_NAME ;;
  }

  dimension: role_description {
    type: string
    sql: ${TABLE}.ROLE_DESCRIPTION ;;
  }

  dimension: role_module {
    type: string
    sql: ${TABLE}.ROLE_MODULE ;;
  }

  dimension: rpa_policyname {
    type: string
    sql: ${TABLE}."RPA.POLICYNAME" ;;
  }

  dimension: rpa_rights {
    type: string
    sql: ${TABLE}."RPA.RIGHTS" ;;
  }

  set: detail {
    fields: [
      user_name,
      user_login,
      user_type,
      admin_privledges,
      user_status,
      manager_name,
      workday_title,
      cost_center_name,
      effective_hire_date,
      final_date_terminated,
      po_view_access,
      po_approval_limit,
      entity_restrictions,
      department_restrictions,
      user_group,
      role_name,
      role_description,
      role_module,
      rpa_policyname,
      rpa_rights
    ]
  }
}

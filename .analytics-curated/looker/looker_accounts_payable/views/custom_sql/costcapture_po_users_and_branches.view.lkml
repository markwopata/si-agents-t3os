view: costcapture_po_users_and_branches {
  derived_table: {
    sql: SELECT DISTINCT
          T3_PERMS.NAME               AS USER_NAME,
          T3_PERMS.USER_ID            AS USER_ID,
          T3_PERMS.LOGIN              AS USER_LOGIN,
          T3_PERMS.RESOURCE_OBJECT_ID AS BRANCH
      FROM
          (SELECT
               USER.USER_ID                                                             AS USER_ID,
               CONCAT(COALESCE(USER.FIRST_NAME, ''), ' ', COALESCE(USER.LAST_NAME, '')) AS NAME,
               USER.USERNAME                                                            AS LOGIN,
               USER.EMAIL_ADDRESS                                                       AS EMAIL,
               USER.BRANCH_ID                                                           AS BRANCH_T3,
               BERP.INTACCT_DEPARTMENT_ID                                               AS BRANCH_INTACCT,
               UG.USER_GROUP_ID                                                         AS USER_GROUP_ID,
               UG.GROUP_ID                                                              AS GROUP_ID,
               GR.NAME                                                                  AS GROUP_NAME,
               RESPL.RESOURCE_POLICY_ID                                                 AS RESOURCE_POLICY_ID,
               RESPL.RESOURCE_ID                                                        AS RESOURCE_ID,
               RESPL.ROLE_ID                                                            AS ROLE_ID,
               ROLE.NAME                                                                AS ROLE_NAME,
               RP.ROLE_PERMISSION_ID                                                    AS ROLE_PERMISSION_ID,
               RP.PERMISSION_ID                                                         AS PERM_ID,
               PERM.NAME                                                                AS PERM_NAME,
               PERM.FRIENDLY_NAME                                                       AS PERM_FRIENDLY_NAME,
               PERM.RESOURCE_TYPE_ID                                                    AS RESOURCE_TYPE_ID,
               RT.NAME                                                                  AS RESOURCE_TYPE_NAME,
               RES.PARENT_ID                                                            AS RESOURCE_PARENT_ID,
               RES.OBJECT_ID                                                            AS RESOURCE_OBJECT_ID
           FROM
               ES_WAREHOUSE.PUBLIC.USERS USER
                   LEFT JOIN ES_WAREHOUSE.PUBLIC.BRANCH_ERP_REFS BERP ON USER.BRANCH_ID = BERP.BRANCH_ID
                   LEFT JOIN ES_WAREHOUSE.INVENTORY.USER_GROUPS UG ON USER.USER_ID = UG.USER_ID
                   LEFT JOIN ES_WAREHOUSE.INVENTORY.GROUPS GR ON UG.GROUP_ID = GR.GROUP_ID AND GR.DATE_ARCHIVED IS NULL
                   LEFT JOIN ES_WAREHOUSE.INVENTORY.RESOURCE_POLICIES RESPL ON UG.GROUP_ID = RESPL.GROUP_ID
                   LEFT JOIN ES_WAREHOUSE.INVENTORY.ROLES ROLE
                             ON RESPL.ROLE_ID = ROLE.ROLE_ID AND ROLE.COMPANY_ID = '1854' AND ROLE.DATE_ARCHIVED IS NULL
                   LEFT JOIN ES_WAREHOUSE.INVENTORY.ROLE_PERMISSIONS RP ON ROLE.ROLE_ID = RP.ROLE_ID
                   LEFT JOIN ES_WAREHOUSE.INVENTORY.PERMISSIONS PERM ON RP.PERMISSION_ID = PERM.PERMISSION_ID
                   LEFT JOIN ES_WAREHOUSE.INVENTORY.RESOURCE_TYPES RT
                             ON PERM.RESOURCE_TYPE_ID = RT.RESOURCE_TYPE_ID
                   LEFT JOIN ES_WAREHOUSE.INVENTORY.RESOURCES RES
                             ON RESPL.RESOURCE_ID = RES.RESOURCE_ID AND RES.COMPANY_ID = '1854'
           WHERE
                 USER.COMPANY_ID = '1854'
             AND USER.DELETED = FALSE) T3_PERMS
      WHERE
          T3_PERMS.PERM_ID IN (66)
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_login {
    type: string
    sql: ${TABLE}."USER_LOGIN" ;;
  }

  dimension: branch {
    type: number
    sql: ${TABLE}."BRANCH" ;;
  }

  set: detail {
    fields: [user_name, user_id, user_login, branch]
  }
}

view: cost_capture_permissions {
  derived_table: {
    sql: WITH cost_capture_user_permissions AS (select
          ug.user_id,
          concat(u.first_name,' ',u.last_name) as user_name,
          g.name as group_name,
          gp.name as permissions,
          ukg.EMPLOYEE_NUMBER as employee_id,
          ukg.EMPLOYEE_TITLE as title,
          cd.DEFAULT_COST_CENTERS_FULL_PATH as full_cost_center
      from
          ES_WAREHOUSE.inventory.user_groups ug
          join ES_WAREHOUSE.PUBLIC.users u on u.user_id = ug.user_id
          left join ES_WAREHOUSE.inventory.groups g on g.group_id = ug.group_id
          left join "ANALYTICS"."DOCEBO"."UKG_EMPLOYEES" AS ukg on ukg.EMPLOYEE_EMAIL = u.USERNAME
          left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY AS cd on cd.WORK_EMAIL = u.USERNAME
          left join (
                      with parent_resources as (
                      SELECT
                          parent_resource.object_id        AS object_id,
                          parent_resource.resource_id      AS resource_id,
                          parent_resource.resource_type_id AS resource_type_id,
                          parent_policy.group_id           AS group_id,
                          parent_policy.role_id            AS role_id
                      FROM
                          ES_WAREHOUSE.inventory.resource_policies  AS parent_policy
                              JOIN ES_WAREHOUSE.inventory.resources AS parent_resource
                                   ON parent_policy.resource_id = parent_resource.resource_id
                              JOIN ES_WAREHOUSE.inventory.groups ON inventory.groups.group_id = parent_policy.group_id
                                  AND inventory.groups.date_archived IS NULL
                              JOIN ES_WAREHOUSE.inventory.roles
                                   ON inventory.roles.role_id = parent_policy.role_id AND inventory.roles.date_archived IS NULL
                              JOIN ES_WAREHOUSE.inventory.user_groups ON inventory.user_groups.group_id = parent_policy.group_id
                      WHERE
                          parent_resource.company_id = 1854
                      )
                      , child_resources as (
                      SELECT
                                      child_resource.object_id        AS child_resource_object_id,
                                      child_resource.resource_id      AS child_resource_resource_id,
                                      child_resource.resource_type_id AS child_resource_resource_type_id,
                                      parent_resources.group_id          AS policy_grants_group_id,
                                      parent_resources.role_id           AS policy_grants_role_id
                                  FROM
                                      ES_WAREHOUSE.inventory.resources AS child_resource
                                          JOIN parent_resources ON child_resource.parent_id = parent_resources.resource_id
                      )
                      , policy_grants as (
                      select * from parent_resources
                      UNION
                      select * from child_resources
                      )
                      , group_permissions as (
                      SELECT
                          inventory.permissions.permission_id AS permission_id,
                          inventory.permissions.name,
                          policy_grants.object_id             AS object_id,
                          policy_grants.resource_type_id,
                          policy_grants.group_id
                      FROM
                          policy_grants
                              JOIN ES_WAREHOUSE.inventory.role_permissions ON inventory.role_permissions.role_id = policy_grants.role_id
                              JOIN ES_WAREHOUSE.inventory.permissions ON inventory.permissions.permission_id = inventory.role_permissions.permission_id
                      WHERE
                          policy_grants.resource_type_id = inventory.permissions.resource_type_id
                      QUALIFY ROW_NUMBER() OVER (PARTITION BY inventory.permissions.permission_id,policy_grants.group_id ORDER BY inventory.permissions.permission_id) = 1
                      )
                      select
                          group_id,
                          listagg(name,', ') as name
                      from
                          group_permissions
                      group by
                          group_id

      ) gp on gp.group_id = g.group_id
      where
      g.date_archived IS NULL
      and g.company_id = 1854
      and u.company_id = 1854
      and u.deleted = FALSE
      order by ug.user_id
      )
      SELECT
      cost_capture_user_permissions."EMPLOYEE_ID"  AS  "cost_capture_user_permissions.employee_id",
      cost_capture_user_permissions."USER_NAME"  AS "cost_capture_user_permissions.user_name",
      cost_capture_user_permissions."GROUP_NAME"  AS "cost_capture_user_permissions.group_name",
      cost_capture_user_permissions."TITLE"  AS  "cost_capture_user_permissions.title",
      cost_capture_user_permissions."FULL_COST_CENTER"  AS  "cost_capture_user_permissions.full_cost_center",
      cost_capture_user_permissions."PERMISSIONS"  AS "cost_capture_user_permissions.permissions"


      FROM cost_capture_user_permissions
      GROUP BY
      1,
      2,
      3,
      4,
      5,
      6
      ORDER BY
      1
      FETCH NEXT 5000 ROWS ONLY
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: cost_capture_user_permissions_employee_id {
    type: string
    sql: ${TABLE}."cost_capture_user_permissions.employee_id" ;;
  }

  dimension: cost_capture_user_permissions_user_name {
    type: string
    sql: ${TABLE}."cost_capture_user_permissions.user_name" ;;
  }

  dimension: cost_capture_user_permissions_group_name {
    type: string
    sql: ${TABLE}."cost_capture_user_permissions.group_name" ;;
  }

  dimension: cost_capture_user_permissions_title {
    type: string
    sql: ${TABLE}."cost_capture_user_permissions.title" ;;
  }

  dimension: cost_capture_user_permissions_full_cost_center {
    type: string
    sql: ${TABLE}."cost_capture_user_permissions.full_cost_center" ;;
  }

  dimension: cost_capture_user_permissions_permissions {
    type: string
    sql: ${TABLE}."cost_capture_user_permissions.permissions" ;;
  }

  set: detail {
    fields: [
      cost_capture_user_permissions_employee_id,
      cost_capture_user_permissions_user_name,
      cost_capture_user_permissions_group_name,
      cost_capture_user_permissions_title,
      cost_capture_user_permissions_full_cost_center,
      cost_capture_user_permissions_permissions
    ]
  }
}

#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: costcapture_user_info_2 {
  derived_table: {
    sql: select
                      ug.user_id,
                      u.email_address,
                      concat(u.first_name,' ',u.last_name) as user_name,
                      g.name as group_name,
                      IFNULL(objlup.name,'Global')as "OBJECT_NAME",
                      cd.EMPLOYEE_TITLE as title,
                      cd.DEFAULT_COST_CENTERS_FULL_PATH as full_cost_center,
                      gp.name as permissions,
                      concat(r.RESOURCE_TYPE_ID,'-',r.object_id) as "RESOURCE_TYPE_OBJECT"

                  from
                      ES_WAREHOUSE.inventory.user_groups ug
                      join ES_WAREHOUSE.PUBLIC.users u on u.user_id = ug.user_id
                      left join ES_WAREHOUSE.INVENTORY.groups g on g.group_id = ug.group_id
                      left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY AS cd on cd.WORK_EMAIL = u.USERNAME
                      LEFT JOIN "ES_WAREHOUSE"."INVENTORY"."RESOURCE_POLICIES" rp ON rp.GROUP_ID = g.GROUP_ID
                      LEFT JOIN "ES_WAREHOUSE"."INVENTORY"."RESOURCES" r ON r.RESOURCE_ID = rp.RESOURCE_ID
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

                  LEFT JOIN (
                      SELECT
                          CONCAT('5','-',MARKET_ID) AS RTO,
                          NAME
                      FROM "ES_WAREHOUSE"."PUBLIC"."MARKETS"
                      WHERE COMPANY_ID = 1854

                          UNION

                      SELECT
                          CONCAT('4','-',STORE_ID),
                          NAME
                      FROM "ES_WAREHOUSE"."INVENTORY"."STORES"
                      WHERE COMPANY_ID = 1854

                          UNION

                      SELECT
                          CONCAT('2','-',COMPANY_ID),
                          NAME
                      FROM "ES_WAREHOUSE"."PUBLIC"."COMPANIES"
                      WHERE COMPANY_ID = 1854) AS objlup ON objlup.RTO = "RESOURCE_TYPE_OBJECT"


      where
                      g.date_archived IS NULL
                      and g.company_id = 1854
                      and u.company_id = 1854
                      and u.deleted = FALSE
                      and u.email_address not like '%suspended%'

                  order by ug.user_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_email {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: group_name {
    type: string
    sql: ${TABLE}."GROUP_NAME" ;;
  }

  dimension: object_name {
    type: string
    sql: ${TABLE}."OBJECT_NAME" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension: full_cost_center {
    type: string
    sql: ${TABLE}."FULL_COST_CENTER" ;;
  }

  dimension: permissions {
    type: string
    sql: ${TABLE}."PERMISSIONS" ;;
  }

  dimension: resource_type_object {
    type: string
    sql: ${TABLE}."RESOURCE_TYPE_OBJECT" ;;
  }

  set: detail {
    fields: [
        user_id,
  user_name,
  group_name,
  object_name,
  title,
  full_cost_center,
  permissions,
  resource_type_object
    ]
  }
}

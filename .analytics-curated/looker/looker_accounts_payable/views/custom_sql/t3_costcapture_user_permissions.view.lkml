view: t3_costcapture_user_permissions {
    derived_table: {
      sql: select
          ug.user_id,
          concat(u.first_name,' ',u.last_name) as user_name,
          cd.employee_title,
          g.name as group_name,
          g.spending_limit as spending_limit,
          gp.name as permissions
      from
          ES_WAREHOUSE.inventory.user_groups ug
          join ES_WAREHOUSE.PUBLIC.users u on u.user_id = ug.user_id
          left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
                ON (
                    -- Match on ID after stripping 'CW'
                    REPLACE(u.EMPLOYEE_ID, 'CW', '') = CAST(cd.EMPLOYEE_ID AS VARCHAR)
                )
                OR (
                    -- Fallback: Match on email if the EMPLOYEE_ID match fails
                    (u.EMPLOYEE_ID IS NULL OR u.EMPLOYEE_ID = '')
                    AND LOWER(u.EMAIL_ADDRESS) = LOWER(cd.WORK_EMAIL)
                )
          left join ES_WAREHOUSE.inventory.groups g on g.group_id = ug.group_id
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
        ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: user_id {
      type: number
      sql: ${TABLE}."USER_ID" ;;
    }

    dimension: user_name {
      type: string
      sql: ${TABLE}."USER_NAME" ;;
    }

    dimension: employee_title {
      type: string
      sql: ${TABLE}."EMPLOYEE_TITLE" ;;
    }

    dimension: group_name {
      type: string
      sql: ${TABLE}."GROUP_NAME" ;;
    }

  dimension: spending_limit {
    type: number
    sql: ${TABLE}."SPENDING_LIMIT" ;;
  }

    dimension: permissions {
      type: string
      sql: ${TABLE}."PERMISSIONS" ;;
    }

    set: detail {
      fields: [user_id, user_name, group_name, permissions]
    }
  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: t3_costcapture_user_permissions {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }

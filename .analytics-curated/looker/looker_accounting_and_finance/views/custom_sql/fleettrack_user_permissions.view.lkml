view: fleettrack_user_permissions {
  derived_table: {
    sql:
      WITH ul_dedup AS (
          SELECT *
          FROM ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_USER_LIMITS
          QUALIFY ROW_NUMBER() OVER (
              PARTITION BY user_id
              ORDER BY _ES_UPDATE_TIMESTAMP DESC NULLS LAST,
                       COMPANY_PURCHASE_ORDER_USER_LIMIT_ID DESC
          ) = 1
      ),
      parsed_cost_center AS (
          SELECT
              employee_id,
              default_cost_centers_full_path,
              SPLIT(default_cost_centers_full_path, '/') AS cost_centers
          FROM ANALYTICS.PAYROLL.COMPANY_DIRECTORY
      )

      SELECT
      CONCAT(cd.first_name, ' ', cd.last_name, ' - ', cd.employee_id) AS name_employee_id,
      u.email_address,
      cc.cost_centers[ARRAY_SIZE(cc.cost_centers) - 2]::STRING AS department,
      cc.cost_centers[ARRAY_SIZE(cc.cost_centers) - 1]::STRING AS sub_department,
      cd.employee_title,
      CASE
      WHEN u.can_read_asset_financial_records
      AND u.can_create_asset_financial_records THEN 'Read_Create'
      WHEN u.can_read_asset_financial_records
      AND NOT u.can_create_asset_financial_records THEN 'Read'
      ELSE 'None'
      END AS permission,
      CASE
      WHEN ul.approval_limit = -1 THEN 'Unlimited'
      WHEN ul.approval_limit IS NULL THEN '0'
      ELSE TO_VARCHAR(ul.approval_limit)
      END AS approval_level,
      ul.can_change_reconciliation_status,
      ul.can_edit_line_asset_id_assignments,
      ul.can_edit_line_after_schedule_assignment,
      ul.can_edit_pending_schedule,
      ul.can_change_out_of_reconciliation,
      ul.can_edit_read_only_line,
      ul.can_change_out_of_financial_schedule
      FROM ul_dedup ul
      LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS u
      ON ul.user_id = u.user_id
      LEFT JOIN ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
      ON TO_VARCHAR(u.employee_id) = TO_VARCHAR(cd.employee_id)
      LEFT JOIN parsed_cost_center cc
      ON cd.employee_id = cc.employee_id
      WHERE cd.employee_status NOT ILIKE '%Terminated%'
      ;;
  }

  # Dimensions
  dimension: name_employee_id {
    type: string
    sql: ${TABLE}.name_employee_id ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}.email_address ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: sub_department {
    type: string
    sql: ${TABLE}.sub_department ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}.employee_title ;;
  }

  dimension: permission {
    type: string
    sql: ${TABLE}.permission ;;
  }

  dimension: approval_level {
    type: string
    sql: ${TABLE}.approval_level ;;
  }

  # Flag dimensions (booleans)
  dimension: can_change_reconciliation_status {
    type: yesno
    sql: ${TABLE}.can_change_reconciliation_status ;;
  }

  dimension: can_edit_line_asset_id_assignments {
    type: yesno
    sql: ${TABLE}.can_edit_line_asset_id_assignments ;;
  }

  dimension: can_edit_line_after_schedule_assignment {
    type: yesno
    sql: ${TABLE}.can_edit_line_after_schedule_assignment ;;
  }

  dimension: can_edit_pending_schedule {
    type: yesno
    sql: ${TABLE}.can_edit_pending_schedule ;;
  }

  dimension: can_change_out_of_reconciliation {
    type: yesno
    sql: ${TABLE}.can_change_out_of_reconciliation ;;
  }

  dimension: can_edit_read_only_line {
    type: yesno
    sql: ${TABLE}.can_edit_read_only_line ;;
  }

  dimension: can_change_out_of_financial_schedule {
    type: yesno
    sql: ${TABLE}.can_change_out_of_financial_schedule ;;
  }

  # Measures
  measure: row_count {
    type: count
  }

  measure: user_count {
    type: count_distinct
    sql: ${email_address} ;;
  }
}

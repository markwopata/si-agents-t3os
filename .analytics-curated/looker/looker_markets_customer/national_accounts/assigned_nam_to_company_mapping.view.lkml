
view: assigned_nam_to_company_mapping {
  derived_table: {
    sql: WITH na_company_list AS (
        SELECT
            bcp.company_id,
            c.name AS company_name,
            COALESCE(
              CASE
                WHEN POSITION(' ', COALESCE(cd.nickname, cd.first_name)) = 0
                  THEN CONCAT(COALESCE(cd.nickname, cd.first_name), ' ', cd.last_name)
                ELSE CONCAT(COALESCE(cd.nickname, CONCAT(cd.first_name, ' ', cd.last_name)))
              END,
              'Unassigned'
            ) AS assigned_nam
        FROM es_warehouse.public.billing_company_preferences bcp
        JOIN es_warehouse.public.companies c
          ON bcp.company_id = c.company_id
        LEFT JOIN analytics.commission.nam_company_assignments nca
          ON nca.company_id = c.company_id
        LEFT JOIN es_warehouse.public.users u
          ON u.user_id = nca.nam_user_id
        LEFT JOIN analytics.payroll.company_directory cd
          ON LOWER(u.EMAIL_ADDRESS) = LOWER(cd.WORK_EMAIL)
        WHERE bcp.PREFS:national_account = TRUE
          AND (
            CURRENT_TIMESTAMP() BETWEEN nca.effective_start_date AND nca.effective_end_date
            OR (nca.effective_start_date IS NULL AND nca.effective_end_date IS NULL)
          )
      ),
      parent_map AS (
        SELECT
          company_id,
          parent_company_id,
          parent_company_name
        FROM analytics.bi_ops.v_parent_company_relationships
      )
      SELECT
        ncl.company_id,
        ncl.company_name,
        /* If child is Unassigned, use parent's assigned_nam (if that isn't Unassigned). Otherwise keep child's. */
        COALESCE(
          CASE WHEN UPPER(ncl.assigned_nam) = 'UNASSIGNED' THEN NULL ELSE ncl.assigned_nam END,
          CASE WHEN UPPER(parent_ncl.assigned_nam) = 'UNASSIGNED' THEN NULL ELSE parent_ncl.assigned_nam END,
          'Unassigned'
        ) AS assigned_nam,
        pm.parent_company_id,
        pm.parent_company_name AS parent_company
      FROM na_company_list ncl
      LEFT JOIN parent_map pm
        ON ncl.company_id = pm.company_id
      LEFT JOIN na_company_list parent_ncl
        ON pm.parent_company_id = parent_ncl.company_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: assigned_nam {
    type: string
    sql: ${TABLE}."ASSIGNED_NAM" ;;
  }

  dimension: parent_company_id {
    type: number
    sql: ${TABLE}."PARENT_COMPANY_ID" ;;
  }

  dimension: parent_company {
    type: string
    sql: ${TABLE}."PARENT_COMPANY" ;;
  }

  set: detail {
    fields: [
        company_id,
	company_name,
	assigned_nam,
	parent_company_id,
	parent_company
    ]
  }
}

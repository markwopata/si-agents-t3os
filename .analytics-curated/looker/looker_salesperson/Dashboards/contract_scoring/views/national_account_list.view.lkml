view: national_account_list {

  derived_table: {
    sql:
      WITH national_accounts AS (
                  SELECT company_id
                  FROM es_warehouse.public.BILLING_COMPANY_PREFERENCES
                  WHERE PREFS:national_account = TRUE
              )

        , parent_company_relationships AS (
        SELECT company_id, parent_company_id
        FROM analytics.bi_ops.parent_company_relationships
        QUALIFY ROW_NUMBER() OVER(PARTITION BY company_id ORDER BY record_created_timestamp desc) = 1
        )

        , commission_assignments AS (
        SELECT *,
        CASE WHEN effective_end_date <> '2099-12-31 23:59:59.999'::timestamp_ntz
        THEN 1 ELSE 0 END as upcoming_assignment_change
        FROM analytics.commission.nam_company_assignments
        WHERE current_timestamp() BETWEEN effective_start_date AND effective_end_date
        )

        , account_info AS (
        SELECT *
        FROM analytics.bi_ops.national_account_info
        QUALIFY ROW_NUMBER() OVER(PARTITION BY company_id ORDER BY record_creation_date desc) = 1
        ),
        user_map AS (
        SELECT u.user_id, u.email_address,
        CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
        THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
        ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END as name
        FROM es_warehouse.public.users u
        JOIN analytics.payroll.company_directory cd ON lower(u.email_address) = lower(cd.work_email)
        )

        , na_companies AS (
        SELECT na.company_id as company_id,
        c.name                          as company,
        --                                  ai.region,
        --                                  ca.director_user_id,
        COALESCE(ud.name, 'Unassigned') as sales_director,
        --                                  ca.nam_user_id,
        --                                  ai.coordinator_user_id,
        --                                  nt.name                                   as net_term,
        --                                  CONCAT('https://admin.equipmentshare.com/#/home/companies/',
        --                                         ca.company_id::varchar)            as admin_link,
        --                                  pcr.parent_company_id,
                                         COALESCE(pc.name,c.name)                                as parent_company_name_na,
        COALESCE(cg.CUSTOMER_GROUP_NAME,c.name)           as parent_company_name_rebates
        --                                  ai.notes,
        --                                  bcp.PREFS:general_services_administration as GSA_flag,
        --                                  bcp.PREFS:managed_billing                 as managed_billing_flag,
        --                                  ca.upcoming_assignment_change,
        --                                  COALESCE(ai.account_folder_url, '')       as account_folder_url
        FROM national_accounts na
        JOIN es_warehouse.public.companies c ON na.company_id = c.company_id
        LEFT JOIN commission_assignments ca ON ca.company_id = na.company_id
        LEFT JOIN account_info ai ON na.company_id = ai.company_id
        LEFT JOIN parent_company_relationships pcr ON na.company_id = pcr.company_id
        LEFT JOIN es_warehouse.public.companies pc ON pc.company_id = pcr.parent_company_id
        LEFT JOIN es_warehouse.public.net_terms nt ON c.net_terms_id = nt.net_terms_id
        LEFT JOIN es_warehouse.public.billing_company_preferences bcp
        ON na.company_id = bcp.company_id
        LEFT JOIN user_map ud ON ca.director_user_id = ud.user_id
        left join ANALYTICS.GS.AR_BB_CUSTOMER_GROUPING cg
        on try_cast(cg.CUSTOMER_ID as number) = c.COMPANY_ID)


SELECT DISTINCT parent_company_name_na from na_companies
      ;;
  }

  # Define your dimensions and measures here, like this:
  dimension: parent_company_name {
    type: string
    primary_key: yes
    sql: ${TABLE}.parent_company_name_na ;;
  }
}

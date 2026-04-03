
view: tiering_practice {
  derived_table: {
    sql:   WITH SALESPERSONS AS (
            SELECT user_id,
                employee_id,
                name as sp_name,
                email_address,
                employee_status_present,
                salesperson_jurisdiction_dated as sp_jurisdiction_dated,
                region_name_dated as sp_region_dated,
                district_dated  as sp_district_dated,
                home_market_id_dated  as sp_market_id_dated,
                home_market_dated as sp_market_dated,
                record_effective_date,
                record_ineffective_date,
                employee_title_dated,
                direct_manager_user_id_present,
                first_date_as_tam,
                CASE WHEN DATEADD(month, '6', first_date_as_TAM) > TO_DATE(CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP()))
                    THEN 'Under 6 Months' ELSE 'Older than 6 Months' END AS new_sp_flag_current
            FROM analytics.bi_ops.salesperson_info --WHERE record_ineffective_date IS NULL and employee_title_dated = 'National Account Manager' and employee_status_present ilike 'act%'
            )

    , national_accounts AS (
    SELECT cp.company_id
        ,coalesce(CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0 THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
                    ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END, 'Ronny Robinson') as nam_name
        , coalesce(nca.nam_user_id, 60029) as nam_user_id
        , cd.work_email as nam_email
        , cd.employee_status as nam_employee_status
        , cd.employee_title as nam_title

      FROM es_warehouse.public.billing_company_preferences cp
      join es_warehouse.public.companies c ON c.company_id = cp.company_id
      LEFT JOIN analytics.commission.nam_company_assignments nca ON c.company_id = nca.company_id AND current_timestamp() BETWEEN effective_start_date AND effective_end_date
      LEFT JOIN es_warehouse.public.users u ON u.user_id = coalesce(nca.nam_user_id, 60029) --Giving all unaffiliated accounts to Ronny Robinson
      LEFT JOIN  analytics.payroll.company_directory cd ON lower(u.email_address) = lower(cd.work_email)
      WHERE PREFS:national_account = TRUE

    )

    , rental_rev_by_company_rep_rental_id_li AS ( --row for each line item/ rentalid/company/ sales rep
        SELECT
            CONVERT_TIMEZONE('America/Chicago', li.date_updated) as approved_date,
            --CONCAT('Q', QUARTER(CONVERT_TIMEZONE('America/Chicago', li.date_updated)), ' - ', YEAR(CONVERT_TIMEZONE('America/Chicago', li.date_updated))) as quarter_rental,
            DATE_TRUNC(quarter, li.date_updated)::DATE as q_date,
            li.rental_id,
            c.company_id as rental_company_id,
            c.name as rental_company,
            account.first_order,
            account.first_rental,
            li.amount,
            COALESCE(na.nam_user_id, sp.user_id) as primary_sp_user_id,
            COALESCE(na.nam_email, sp.email_address) as sp_email,
            COALESCE(na.nam_name, sp.sp_name) as sp_name,
            CASE WHEN na.company_id IS NULL THEN sp.employee_title_dated ELSE NULL END as employee_title_dated,
            CASE WHEN na.company_id IS NULL THEN sp.sp_district_dated ELSE NULL END as sp_district_dated,
            CASE WHEN na.company_id IS NULL THEN sp.sp_market_id_dated ELSE NULL END as sp_market_id_dated,
            CASE WHEN na.company_id IS NULL THEN sp.sp_market_dated ELSE NULL END as sp_market_dated,
            CASE WHEN na.company_id IS NULL THEN current_home.sp_current_home_id END as current_sp_home_id,
            CASE WHEN na.company_id IS NULL THEN current_home.sp_current_home END as current_sp_home,
            current_home.direct_manager_user_id_present,
            dn.name as direct_manager_name_present,
            COALESCE(nam_employee_status, current_home.current_status) as current_status, -- bring in the name_employee_status so you get the employee status of Mr Ronny
            COALESCE(na.nam_title, current_home.employee_title_dated) as current_title,  -- bring in title from nam cd so that we have Ronny's title too
            CASE WHEN na.company_id IS NULL THEN current_home.first_date_as_TAM ELSE null end as first_date_as_TAM,
            CASE WHEN na.company_id IS NULL THEN current_home.new_sp_flag_current ELSE null end as new_sp_flag_current,
            CASE WHEN na.company_id IS NULL THEN FALSE ELSE TRUE END as national_account_flag

        FROM SALESPERSONS sp
         JOIN analytics.intacct_models.stg_es_warehouse_public__approved_invoice_salespersons ais ON ais.salesperson_id = sp.user_id
         JOIN es_warehouse.public.invoices  i ON i.invoice_id = ais.invoice_id
         JOIN es_warehouse.public.orders o ON i.order_id = o.order_id
         JOIN (SELECT * FROM es_warehouse.public.line_items WHERE line_item_type_id IN (6,8,108,109)) li ON li.invoice_id = ais.invoice_id
         --Customer/Company Info
         LEFT JOIN es_warehouse.public.users AS customer ON (o.user_id) = (customer.user_id)
         LEFT JOIN es_warehouse.public.companies c ON (c.company_id) = (customer.company_id)
         LEFT JOIN es_warehouse.public.markets m ON o.MARKET_ID = m.MARKET_ID
         LEFT JOIN analytics.public.MARKET_REGION_XWALK mrx ON o.MARKET_ID = mrx.MARKET_ID
         -- Only looking at Credit Accounts
         JOIN (SELECT * from analytics.bi_ops.new_account_by_type_log WHERE app_type = 'Credit') account ON account.company_id = c.company_id
          --National Account Info
         LEFT JOIN national_accounts na ON na.company_id = c.company_id
        --Current Info for SP (NAM if applicable)
         LEFT JOIN (SELECT user_id, sp_market_id_dated AS sp_current_home_id, sp_market_dated AS sp_current_home , direct_manager_user_id_present, employee_title_dated, employee_status_present AS current_status, first_date_as_TAM, new_sp_flag_current
            FROM SALESPERSONS si
            QUALIFY row_number() OVER (partitiON by user_id order by record_effective_date DESC) = 1) current_home ON current_home.user_id = COALESCE(na.nam_user_id, sp.user_id)
        --Direct Manager Name
         LEFT JOIN (SELECT u.user_id,
            CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0 THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
                    ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END as name
            FROM es_warehouse.public.users u
            JOIN analytics.payroll.company_directory cd ON lower(TRIM(cd.work_email)) = lower(TRIM(u.email_address))
            WHERE u.user_id IN (SELECT DISTINCT direct_manager_user_id_present FROM SALESPERSONS)) dn ON dn.user_id = current_home.direct_manager_user_id_present

        WHERE i.company_id not in (1854,1855,8151,155,420)
            AND ais.salesperson_type_id = 1 --Primary Salesreps Only
           -- AND quarter_rental = 'Q4 - 2024' -- Quarter of Choice
            AND q_date = DATEADD('quarter', '-1', DATE_TRUNC('quarter', current_date))::DATE
            AND li.rental_id IS NOT NULL -- no null rental ids
            --AND date_trunc('MONTH', approved_date) >= dateadd(month, '-7', date_trunc('MONTH', CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())))
            AND ( COALESCE(na.nam_user_id, sp.user_id) = 60029 OR ((TO_DATE(approved_date) BETWEEN sp.RECORD_EFFECTIVE_DATE AND dateadd(day, -1, sp.RECORD_INEFFECTIVE_DATE))
                OR (TO_DATE(approved_date) >= sp.RECORD_EFFECTIVE_DATE AND sp.RECORD_INEFFECTIVE_DATE IS NULL)) )
                --Take Correct Record in SI for dated salesrep market data unless we are talking about Ronny.. this should work should NAMs b/c they are included in SP
            AND c.company_id NOT IN (SELECT DISTINCT cp.company_id FROM es_warehouse.public.billing_company_preferences cp join es_warehouse.public.companies c ON c.company_id = cp.company_id WHERE PREFS:legal_audit = TRUE OR c.do_not_rent = TRUE)
            -- Take Out Legal/DNR Companies


        )

        ,  num_ids_amount_per_company_rep as ( -- row for each sales rep/company combo and their totals during the quarter
        SELECT
            q_date, rental_company_id, rental_company, primary_sp_user_id, sp_name, current_title, current_status, national_account_flag, first_order, first_rental,
            COUNT(distinct rental_id) as rental_id_count,
            SUM(amount) as total_rental_rev
        FROM rental_rev_by_company_rep_rental_id_li
        GROUP BY q_date, rental_company_id, rental_company, primary_sp_user_id, sp_name, current_title, current_status, national_account_flag, first_order, first_rental
        ORDER BY rental_company_id desc , rental_id_count DESC
        )


        , including_quarterly_totals AS ( -- row for each sales rep/company combo . the pairs totals and the company's overall totals
        SELECT *
        , SUM(rental_id_count) OVER (PARTITION BY rental_company_id, rental_company ORDER BY rental_company_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS quarterly_rental_id_count
        , SUM(total_rental_rev) OVER (PARTITION BY rental_company_id, rental_company ORDER BY rental_company_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS total_quarterly_rev
        , ROW_NUMBER() OVER(PARTITION BY rental_company_id
                        ORDER BY
                            CASE WHEN current_status NOT IN ('Active') THEN 2 ELSE 1 END,
                            CASE WHEN current_title NOT IN ('Territory Account Manager', 'Strategic Account Manager', 'Rental Territory Manager', 'National Account Manager') THEN 2 ELSE 1 END,
                            CASE WHEN national_account_flag = FALSE AND current_title NOT IN ('Territory Account Manager', 'Strategic Account Manager', 'Rental Territory Manager') THEN 2 ELSE 1 END,
                            rental_id_count DESC,
                            total_rental_rev DESC) as sales_rep_rank
        , CASE WHEN first_order >= DATEADD(day, '45', q_date) THEN TRUE ELSE FALSE END as brand_new_flag
        FROM num_ids_amount_per_company_rep

        )

        , top_rep_each_company AS (
        SELECT *, DIV0NULL(total_rental_rev, total_quarterly_rev) as rev_prct, DIV0NULL(rental_id_count, quarterly_rental_id_count) as id_prct
        , PERCENT_RANK() OVER (ORDER BY total_quarterly_rev DESC) AS prct_rank
        , CASE
              WHEN prct_rank <= 0.05 THEN 'Tier 1'  -- Top 5%
                WHEN prct_rank <= 0.15 THEN 'Tier 2'  -- Next 10%
                WHEN prct_rank <= 0.35 THEN 'Tier 3'  --Next 20%
                --WHEN prct_rank <= 0.55 THEN 'Tier 4'  --Next 20%
                ELSE 'Tier 4'  -- Remaining 65%
                END AS tier
        FROM including_quarterly_totals
        WHERE (quarterly_rental_id_count > 1 )
            AND (brand_new_flag = FALSE OR (brand_new_flag = TRUE AND total_quarterly_rev > 8000))
            AND total_quarterly_rev > 8000
            AND sales_rep_rank = 1

        ORDER BY rental_company_id
        )


        , tier_stats AS (
            SELECT
                tier,
                COUNT(*) AS company_count,
                SUM(total_quarterly_rev) AS total_revenue
            FROM top_rep_each_company
            GROUP BY tier
        )
        , budget_allocation AS (
            SELECT
                tier,
                company_count as company_count_in_tier,
                total_revenue,
                CASE
                    WHEN tier = 'Tier 1' THEN 0.245 * {{budget_total._parameter_value}} -- 35% of budget to Tier 1
                    WHEN tier = 'Tier 2' THEN 0.25 * {{budget_total._parameter_value}} -- 30% of budget to Tier 2
                    WHEN tier = 'Tier 3' THEN 0.185 * {{budget_total._parameter_value}} -- 15% of budget to Tier 3
                   -- WHEN tier = 'Tier 4' THEN 0.135 * 160000 -- 10% of budget to Tier 4
                    ELSE 0.32 * {{budget_total._parameter_value}}                      -- 10% of budget to Tier 5
                END AS tier_budget
                , div0null(tier_budget, company_count_in_tier) as per_company
            FROM tier_stats
        )

            SELECT
                trec.q_date,
                trec.rental_company_id,
                trec.rental_company,
                trec.sp_name,
                trec.primary_sp_user_id,
                trec.current_title,
                trec.current_status,
                trec.national_account_flag,
                trec.first_order,
                trec.rental_id_count,
                trec.total_rental_rev as rental_rev_by_rep,
                trec.quarterly_rental_id_count,
                trec.total_quarterly_rev,
                trec.tier,
                b.tier_budget,
                b.company_count_in_tier,
                -- Per-customer share of the tier budget
                per_company AS budget_for_company
            FROM top_rep_each_company trec
            JOIN budget_allocation b ON trec.tier = b.tier
            ORDER BY trec.tier, total_quarterly_rev ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }


  dimension: pk {
    type: string
    primary_key: yes
    sql:  concat( ${TABLE}."RENTAL_COMPANY_ID" ,  ${TABLE}."SP_NAME",  ${TABLE}."PRIMARY_SP_USER_ID", ${TABLE}."RENTAL_REV_BY_REP")  ;;
  }

  parameter: budget_total {
    type: number
    default_value: "160000"
    description: "Enter the budget total"
  }

  dimension: rental_company_id {
    type: string
    sql: ${TABLE}."RENTAL_COMPANY_ID" ;;
  }

  dimension_group: q_date {
    type: time
    sql: ${TABLE}."Q_DATE" ;;
  }

  dimension: quarter_name {
    type: string
    sql:concat(${q_date_quarter_of_year}, ' - ', ${q_date_year}) ;;
  }


  measure: company_distinct_count {
    type: count_distinct
    sql: ${rental_company_id} ;;
  }

  dimension: rental_company {
    type: string
    sql: ${TABLE}."RENTAL_COMPANY" ;;
  }

  dimension: total_budget {
    type: number
    sql: ;;
  }

  dimension: sp_name {
    type: string
    sql: ${TABLE}."SP_NAME" ;;
  }

  dimension: current_title {
    type: string
    sql: ${TABLE}."CURRENT_TITLE" ;;
  }

  dimension: current_title_formatted {
    type: string
    sql: ${current_title} ;;
    html: {% if  rendered_value == 'Territory Account Manager' or rendered_value == 'National Account Manager' or rendered_value == 'Rental Territory Manager' or rendered_value == 'Strategic Account Manager' %}
    {{rendered_value}}
    {% else %}
    <font color="#C49102">
    {{rendered_value}}

    {% endif %}

    ;;
  }

  dimension: current_status {
    type: string
    sql: ${TABLE}."CURRENT_STATUS" ;;
  }


  dimension: sp_name_format {
    type: string
    sql: ${sp_name} ;;
    html: {% if  current_status._rendered_value == 'Active' %}
    {{rendered_value}}
    {% else %}
    <font color="#DA344D">
    {{rendered_value}} - {{current_status._rendered_value}}

    {% endif %}

  ;;
  }

  dimension: primary_sp_user_id {
    type: string
    sql: ${TABLE}."PRIMARY_SP_USER_ID" ;;
  }



  dimension: national_account_flag {
    type: yesno
    sql: ${TABLE}."NATIONAL_ACCOUNT_FLAG" ;;
  }

  dimension: first_order_by_company {
    type: date
    sql: ${TABLE}."FIRST_ORDER" ;;
  }

  dimension: rental_id_count {
    type: number
    sql: ${TABLE}."RENTAL_ID_COUNT" ;;
  }

  dimension: rental_rev_by_rep {
    type: number
    sql: ${TABLE}."RENTAL_REV_BY_REP" ;;
  }

  dimension: total_quarterly_rev {
    type:number
    sql: ${TABLE}."TOTAL_QUARTERLY_REV" ;;
    value_format_name: usd_0
  }

  dimension: quarterly_rental_id_count {
    type: number
    sql: ${TABLE}."QUARTERLY_RENTAL_ID_COUNT" ;;
  }

  dimension: tier {
    type: string
    sql: ${TABLE}."TIER" ;;
  }

  dimension: tier_budget {
    type: number
    sql: ${TABLE}."TIER_BUDGET" ;;
    value_format_name: usd_0
  }

  dimension: company_count_in_tier {
    type: number
    sql:  ${TABLE}."COMPANY_COUNT_IN_TIER" ;;
  }

  dimension: budget_for_company {
    type: number
    sql:  ${TABLE}."BUDGET_FOR_COMPANY" ;;
    value_format_name: usd_0
  }

 measure: total_budget_per_rep {
    type: sum
    sql:  ${budget_for_company} ;;
    value_format_name: usd_0
    drill_fields: [co_count_description*]

  }

  set: co_count_description {
    fields: [rental_company_id, rental_company, national_account_flag, first_order_by_company, tier, budget_for_company]
  }



  set: detail {
    fields: [
        rental_company_id,
  rental_company,
  national_account_flag
    ]
  }
}

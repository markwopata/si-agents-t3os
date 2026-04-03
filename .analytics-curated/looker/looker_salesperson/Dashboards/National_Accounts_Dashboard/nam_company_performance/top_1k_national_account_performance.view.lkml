
view: top_1k_national_account_performance {
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
      ),
      parent_nam_mapping as (
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
        ON pm.parent_company_id = parent_ncl.company_id
      )
      ,

          /* Month calendar: current month back 12, rolled from v_dim_dates_bi */
          month_calendar AS (
            WITH months AS (
              SELECT DISTINCT
                DATE_TRUNC(month, d.date)::DATE AS month_year
              FROM business_intelligence.gold.v_dim_dates_bi d
              WHERE d.date >= DATEADD(month, -12, DATE_TRUNC(month, CURRENT_DATE))
                AND d.date <  DATEADD(month,  1, DATE_TRUNC(month, CURRENT_DATE))
            ),
            flags AS (
              SELECT
                DATE_TRUNC(month, d.date)::DATE AS month_year,
                BOOLOR_AGG(d.is_prior_month)   AS any_is_prior_month,
                BOOLOR_AGG(d.is_current_month) AS any_is_current_month
              FROM business_intelligence.gold.v_dim_dates_bi d
              WHERE d.date >= DATEADD(month, -12, DATE_TRUNC(month, CURRENT_DATE))
                AND d.date <  DATEADD(month,  1, DATE_TRUNC(month, CURRENT_DATE))
              GROUP BY 1
            )
            SELECT
              m.month_year,
              f.any_is_prior_month   AS is_prior_month,
              f.any_is_current_month AS is_current_month,
              m.month_year = DATEADD(month, -2, DATE_TRUNC('month', CURRENT_DATE))::DATE AS last_day_two_months_ago,
              m.month_year = DATEADD(month, -3, DATE_TRUNC('month', CURRENT_DATE))::DATE AS last_day_three_months_ago,
              (m.month_year >= DATEADD(month, -12, DATE_TRUNC('month', CURRENT_DATE))
               AND m.month_year <  DATE_TRUNC('month', CURRENT_DATE)) AS ttm_flag
            FROM months m
            LEFT JOIN flags f USING (month_year)
          ),

          /* All company × month combinations */
          company_months AS (
            SELECT
              pnm.company_id,
              pnm.company_name,
              mc.month_year,
              mc.is_prior_month,
              mc.is_current_month,
              mc.last_day_two_months_ago,
              mc.last_day_three_months_ago,
              mc.ttm_flag
            FROM parent_nam_mapping pnm
            CROSS JOIN month_calendar mc
          ),
          /* Detailed line items (kept as in your original with minor formatting) */
          na_line_item_level AS (
            SELECT
              li.LINE_ITEM_ID,
              r.RENTAL_ID,
              li.AMOUNT,
              li.ASSET_ID,
              r.EQUIPMENT_CLASS_ID,
              ec.NAME AS EQUIPMENT_CLASS,
              i.INVOICE_ID,
              i.SHIP_FROM:branch_id AS MARKET_ID,
              i.SALESPERSON_USER_ID,
              CONCAT(TRIM(u.FIRST_NAME), ' ', TRIM(u.LAST_NAME)) AS SALESPERSON,
              i.BILLING_APPROVED_DATE,
              i.COMPANY_ID,
              pnm.COMPANY_NAME,
              pnm.assigned_nam,
              CASE WHEN r.PRICE_PER_WEEK IS NULL AND r.PRICE_PER_MONTH IS NULL AND r.PRICE_PER_DAY IS NOT NULL THEN TRUE ELSE FALSE END AS DAILY_BILLING_FLAG,
              CASE
                WHEN li.EXTENDED_DATA:rental:price_per_four_weeks::NUMBER IS NOT NULL THEN 'four_week'
                WHEN li.EXTENDED_DATA:rental:price_per_month::NUMBER      IS NOT NULL THEN 'monthly'
                ELSE NULL
              END AS BILLING_TYPE,
              DATEDIFF(day, i.START_DATE, i.END_DATE) AS cycle_length,
              CASE
                WHEN daily_billing_flag = TRUE THEN (o.PRICE_PER_MONTH / 28) * cycle_length
                WHEN BILLING_TYPE = 'four_week'
                  OR (BILLING_TYPE = 'monthly' AND o.DATE_CREATED < '2024-01-01') THEN
                     li.EXTENDED_DATA:rental:cheapest_period_hour_count  * o.PRICE_PER_HOUR +
                     li.EXTENDED_DATA:rental:cheapest_period_day_count   * o.PRICE_PER_DAY +
                     li.EXTENDED_DATA:rental:cheapest_period_week_count  * o.PRICE_PER_WEEK +
                     COALESCE(li.EXTENDED_DATA:rental:cheapest_period_four_week_count,
                              li.EXTENDED_DATA:rental:cheapest_period_month_count) * o.PRICE_PER_MONTH
                WHEN BILLING_TYPE = 'monthly' THEN
                     IFF(cycle_length > 28, (o.PRICE_PER_MONTH / 28) * cycle_length,
                       li.EXTENDED_DATA:rental:cheapest_period_hour_count   * o.PRICE_PER_HOUR +
                       li.EXTENDED_DATA:rental:cheapest_period_day_count    * o.PRICE_PER_DAY +
                       li.EXTENDED_DATA:rental:cheapest_period_week_count   * o.PRICE_PER_WEEK +
                       li.EXTENDED_DATA:rental:cheapest_period_month_count  * o.PRICE_PER_MONTH)
              END AS ONLINE_RATE,
              CASE WHEN ONLINE_RATE IS NOT NULL AND ONLINE_RATE > 0
                THEN (1 - (li.AMOUNT / ONLINE_RATE))::NUMERIC(20,2)
                ELSE NULL
              END AS PERCENT_DISCOUNT
            FROM ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
            JOIN ES_WAREHOUSE.PUBLIC.INVOICES i ON li.INVOICE_ID = i.INVOICE_ID
            LEFT JOIN ES_WAREHOUSE.PUBLIC.RENTALS r ON r.RENTAL_ID = li.RENTAL_ID
            LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec ON r.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
            LEFT JOIN ES_WAREHOUSE.PUBLIC.ORDERS ord ON ord.ORDER_ID = r.ORDER_ID
            LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS m ON m.MARKET_ID = ord.MARKET_ID
            LEFT JOIN ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr ON m.MARKET_ID = rr.MARKET_ID
            LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS u ON i.SALESPERSON_USER_ID = u.USER_ID
            JOIN parent_nam_mapping pnm ON i.COMPANY_ID = pnm.COMPANY_ID
            LEFT JOIN ANALYTICS.RATE_ACHIEVEMENT.GRACE_PERIOD_RATES grp ON li.LINE_ITEM_ID = grp.LINE_ITEM_ID
            LEFT JOIN ANALYTICS.RATE_ACHIEVEMENT.DISCOUNT_RATES dr
              ON dr.DISTRICT = rr.DISTRICT
             AND dr.EQUIPMENT_CLASS_ID = r.EQUIPMENT_CLASS_ID
             AND dr.DATE_CREATED <= ord.DATE_CREATED
             AND (ord.DATE_CREATED <= dr.DATE_VOIDED OR dr.DATE_VOIDED IS NULL)
            LEFT JOIN (SELECT * FROM ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES WHERE RATE_TYPE_ID = 1) o
              ON r.EQUIPMENT_CLASS_ID = o.EQUIPMENT_CLASS_ID
             AND i.SHIP_FROM:branch_id = o.BRANCH_ID
             AND i.BILLING_APPROVED_DATE >= o.DATE_CREATED
             AND i.BILLING_APPROVED_DATE < COALESCE(o.DATE_VOIDED, '2099-12-31 23:59:59.999'::TIMESTAMP_NTZ)
             AND (o.DATE_VOIDED IS NOT NULL OR o.ACTIVE)
            --LEFT JOIN na_company_list na ON na.company_id = c.company_id
            WHERE li.LINE_ITEM_TYPE_ID = 8
              AND m.COMPANY_ID = 1854
              AND i.BILLING_APPROVED_DATE >= DATEADD(DAY, -30, CURRENT_DATE())
          ),
          /* Company-level discount sums only when ONLINE_RATE > 0 */
          company_discount_percentage AS (
            SELECT
              COMPANY_ID,
              COMPANY_NAME,
              SUM(CASE WHEN ONLINE_RATE > 0 THEN ONLINE_RATE ELSE 0 END) AS COMPANY_ONLINE_RATE,
              SUM(CASE WHEN ONLINE_RATE > 0 THEN AMOUNT      ELSE 0 END) AS COMPANY_AMOUNT
            FROM na_line_item_level
            GROUP BY 1,2
          ),

          /* NAM-level discount sums, grouped by effective NAM (parent fallback) */
          nam_discount_percentage AS (
            SELECT
              assigned_nam AS NAM,
              SUM(CASE WHEN ONLINE_RATE > 0 THEN ONLINE_RATE ELSE 0 END) AS NAM_ONLINE_RATE,
              SUM(CASE WHEN ONLINE_RATE > 0 THEN AMOUNT      ELSE 0 END) AS NAM_AMOUNT
            FROM na_line_item_level
            GROUP BY 1
          ),

          /* Rental revenue by company × month (unchanged rules) */
          rental_rev AS (
            SELECT
              DATE_TRUNC(month, icl.gl_date)::DATE AS month_year,
              icl.company_id,
              SUM(icl.amount) AS rental_revenue
            FROM analytics.intacct_models.int_admin_invoice_and_credit_line_detail icl
            JOIN parent_nam_mapping pna ON icl.company_id = pna.company_id
            WHERE icl.is_rental_revenue
              AND DATE_TRUNC(month, icl.gl_date)::DATE >= DATEADD(month, -12, DATE_TRUNC(month, CURRENT_DATE))
              AND DATE_TRUNC(month, icl.gl_date)::DATE <  DATEADD(month,  1, DATE_TRUNC(month, CURRENT_DATE))
            GROUP BY 1,2
          ),

          /* OEC units on rent: last day-of-month (or today) then roll up */
          oec_units_on_rent AS (
            SELECT
              DATE_TRUNC(month, arc.date)::DATE AS month_year,
              arc.company_id,
              SUM(oec)         AS oec_on_rent,
              COUNT(rental_id) AS assets_on_rent
            FROM business_intelligence.triage.stg_bi__daily_actively_renting_customers arc
            JOIN business_intelligence.gold.v_dim_dates_bi d  ON d.date = arc.date
            JOIN parent_nam_mapping pna ON pna.company_id = arc.company_id
            WHERE DATE_TRUNC(month, arc.date)::DATE >= DATEADD(month, -12, DATE_TRUNC(month, CURRENT_DATE))
              AND DATE_TRUNC(month, arc.date)::DATE <  DATEADD(month,  1, DATE_TRUNC(month, CURRENT_DATE))
              AND ( d.is_last_day_of_month
                      OR d.date = (
                   SELECT MAX(date)::date
                   FROM business_intelligence.triage.stg_bi__daily_actively_renting_customers
                    )
                )
            GROUP BY 1,2
          )

          SELECT
            cm.month_year,
            cm.company_id,
            cm.company_name,
            pnm.assigned_nam AS assigned_nam,
            COALESCE(pcr.parent_company_name, cm.company_name) AS parent_company_name,
            cm.is_prior_month,
            cm.is_current_month,
            cm.last_day_two_months_ago,
            cm.last_day_three_months_ago,
            cm.ttm_flag,
            COALESCE(oec.oec_on_rent, 0)    AS oec_on_rent,
            COALESCE(oec.assets_on_rent, 0) AS assets_on_rent,
            COALESCE(rr.rental_revenue, 0)  AS rental_revenue,
            cdp.company_online_rate,
            cdp.company_amount,
            ndp.nam_online_rate,
            ndp.nam_amount
          FROM company_months cm
          LEFT JOIN oec_units_on_rent oec
            ON oec.company_id = cm.company_id AND oec.month_year = cm.month_year
          LEFT JOIN rental_rev rr
            ON rr.company_id  = cm.company_id AND rr.month_year  = cm.month_year
          LEFT JOIN analytics.bi_ops.v_parent_company_relationships pcr
            ON pcr.company_id = cm.company_id
          LEFT JOIN parent_nam_mapping pnm
            ON pnm.company_id = cm.company_id
          -- LEFT JOIN effective_nam en
          --   ON en.company_id = cm.company_id
          LEFT JOIN company_discount_percentage cdp
            ON cdp.company_id = cm.company_id
          LEFT JOIN nam_discount_percentage ndp
            ON ndp.nam = pnm.assigned_nam ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: month_year {
    type: date
    sql: ${TABLE}."MONTH_YEAR" ;;
  }

  dimension: month_year_formatted {
    label: "Month"
    type: date
    sql: ${month_year};;
    html:{{ rendered_value | date: "%b %Y"  }};;
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
    label: "National Account Manager"
    type: string
    sql: ${TABLE}."ASSIGNED_NAM" ;;
  }

  dimension: parent_company_name {
    group_label: "Parent Company"
    label: "Company Name"
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME" ;;
  }

  dimension: parent_company_name_drill {
    group_label: "Parent Company for Drill"
    label: "Parent Company"
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME" ;;
  }

  dimension: is_prior_month {
    type: yesno
    sql: ${TABLE}."IS_PRIOR_MONTH" ;;
  }

  dimension: is_current_month {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTH" ;;
  }

  dimension: last_day_two_months_ago {
    type: yesno
    sql: ${TABLE}."LAST_DAY_TWO_MONTHS_AGO" ;;
  }

  dimension: last_day_three_months_ago {
    type: yesno
    sql: ${TABLE}."LAST_DAY_THREE_MONTHS_AGO" ;;
  }

  dimension: ttm_flag {
    type: yesno
    sql: ${TABLE}."TTM_FLAG" ;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  dimension: assets_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }

  dimension: company_online_rate {
    type: number
    sql: ${TABLE}."COMPANY_ONLINE_RATE" ;;
  }

  dimension: company_amount {
    type: number
    sql: ${TABLE}."COMPANY_AMOUNT" ;;
  }

  dimension: nam_online_rate {
    type: number
    sql: ${TABLE}."NAM_ONLINE_RATE" ;;
  }

  dimension: nam_amount {
    type: number
    sql: ${TABLE}."NAM_AMOUNT" ;;
  }

  measure: last_30_days_company_discount_percentage {
    label: "Last 30 Days Company Discount %"
    type: number
    sql: IFF(SUM(COMPANY_ONLINE_RATE) > 0,
      (SUM(COMPANY_ONLINE_RATE - IFF(COMPANY_ONLINE_RATE > 0,COMPANY_AMOUNT,0)) / SUM(COMPANY_ONLINE_RATE))::NUMERIC(20,4),
      NULL)  ;;
    value_format_name: percent_1
  }

  measure: last_30_days_nam_discount_percentage {
    label: "Last 30 Days National Account Manager Discount %"
    type: number
    sql: IFF(SUM(NAM_ONLINE_RATE) > 0,
      (SUM(NAM_ONLINE_RATE - IFF(NAM_ONLINE_RATE > 0,NAM_AMOUNT,0)) / SUM(NAM_ONLINE_RATE))::NUMERIC(20,4),
      NULL)  ;;
    value_format_name: percent_1
  }

  measure: total_rental_revenue {
    type: sum
    sql: ${rental_revenue} ;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: current_month_total_rental_revenue {
    group_label: "Current Month Metrics"
    type: sum
    sql: ${rental_revenue} ;;
    filters: [is_current_month: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: prior_month_total_rental_revenue {
    group_label: "Prior Month Metrics"
    type: sum
    sql: ${rental_revenue} ;;
    filters: [is_prior_month: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: two_months_ago_total_rental_revenue {
    group_label: "Two Months Ago Metrics"
    type: sum
    sql: ${rental_revenue} ;;
    filters: [last_day_two_months_ago: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: three_months_ago_total_rental_revenue {
    group_label: "Three Months Ago Metrics"
    type: sum
    sql: ${rental_revenue} ;;
    filters: [last_day_three_months_ago: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: ttm_total_rental_revenue {
    group_label: "TTM Metrics"
    label: "Trailing Twelve Months Rental Revenue"
    type: sum
    sql: ${rental_revenue} ;;
    filters: [ttm_flag: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: total_assets_on_rent {
    type: sum
    sql: ${assets_on_rent} ;;
    drill_fields: [detail*]
  }

  measure: current_month_total_assets_on_rent {
    group_label: "Current Month Metrics"
    type: sum
    sql: ${assets_on_rent} ;;
    filters: [is_current_month: "Yes"]
    drill_fields: [detail*]
  }

  measure: prior_month_total_assets_on_rent {
    group_label: "Prior Month Metrics"
    type: sum
    sql: ${assets_on_rent} ;;
    filters: [is_prior_month: "Yes"]
    drill_fields: [detail*]
  }

  measure: two_months_ago_total_assets_on_rent {
    group_label: "Two Months Ago Metrics"
    type: sum
    sql: ${assets_on_rent} ;;
    filters: [last_day_two_months_ago: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: three_months_ago_total_assets_on_rent {
    group_label: "Three Months Ago Metrics"
    type: sum
    sql: ${assets_on_rent} ;;
    filters: [last_day_three_months_ago: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: ttm_total_assets_on_rent {
    group_label: "TTM Metrics"
    label: "Trailing Twelve Months Assets On Rent"
    type: sum
    sql: ${assets_on_rent} ;;
    filters: [ttm_flag: "Yes"]
    drill_fields: [detail*]
  }

  measure: total_oec_on_rent {
    label: "Total OEC On Rent"
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: current_month_total_oec_on_rent {
    group_label: "Current Month Metrics"
    label: "Current Month Total OEC On Rent"
    type: sum
    sql: ${oec_on_rent} ;;
    filters: [is_current_month: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: prior_month_total_oec_on_rent {
    group_label: "Prior Month Metrics"
    label: "Prior Month Total OEC On Rent"
    type: sum
    sql: ${oec_on_rent} ;;
    filters: [is_prior_month: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: two_months_ago_total_oec_on_rent {
    group_label: "Two Months Ago Metrics"
    type: sum
    sql: ${oec_on_rent} ;;
    filters: [last_day_two_months_ago: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: three_months_ago_total_oec_on_rent {
    group_label: "Three Months Ago Metrics"
    type: sum
    sql: ${oec_on_rent} ;;
    filters: [last_day_three_months_ago: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: ttm_total_oec_on_rent {
    group_label: "TTM Metrics"
    label: "Trailing Twelve Months OEC On Rent"
    type: sum
    sql: ${oec_on_rent} ;;
    filters: [ttm_flag: "Yes"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: total_na_companies {
    label: "Total National Account Assigned Companies"
    type: count_distinct
    sql: ${parent_company_name} ;;
    drill_fields: [detail*]
  }

  measure: rental_revenue_per_na {
    group_label: "TTM Metrics"
    label: "Trailing Twelve Months Rental Rev Per National Account"
    type: number
    sql: DIV0NULL(${ttm_total_rental_revenue}, ${total_na_companies}) ;;
    # sql: ${ttm_total_rental_revenue}/${total_gc_companies} ;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: monthly_rental_revenue_per_gc {
    group_label: "Metrics"
    label: "Rental Rev Per National Account"
    type: number
    sql: DIV0NULL(${total_rental_revenue}, ${total_na_companies}) ;;
    # sql: ${total_rental_revenue}/${total_gc_companies} ;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: current_vs_prior_month_assets_on_rent {
    group_label: "Metrics"
    label: "Month over Month Assets On Rent Change"
    type: number
    sql: ${current_month_total_assets_on_rent} - ${prior_month_total_assets_on_rent} ;;
    drill_fields: [detail*]
  }

  measure: current_vs_prior_month_rental_revnue {
    group_label: "Metrics"
    label: "Month over Month Rental Revenue Change"
    type: number
    sql: ${current_month_total_rental_revenue} - ${prior_month_total_rental_revenue} ;;
  }

  measure: pct_change_vs_prior {
    type: number
    sql: ((${prior_month_total_rental_revenue} - ${two_months_ago_total_rental_revenue}) / NULLIF(${two_months_ago_total_rental_revenue},0)) ;;
    value_format_name: percent_2
  }

  measure: pct_change_vs_2mo {
    type: number
    sql: ((${two_months_ago_total_rental_revenue} - ${three_months_ago_total_rental_revenue}) / NULLIF(${three_months_ago_total_rental_revenue},0)) ;;
    value_format_name: percent_2
  }

  measure: revenue_trend {
    type: string
    sql:
    CASE
      WHEN ((${pct_change_vs_prior} > 0.10 AND ${pct_change_vs_2mo} > 0.10)) THEN 'Growing'
      WHEN ((${pct_change_vs_prior} < -0.10 AND ${pct_change_vs_2mo} < -0.10)) THEN 'Declining'
      ELSE 'Stable'
    END ;;
  }

  measure: revenue_trend_with_icons {
    type: string
    sql:
    CASE
      WHEN ((${pct_change_vs_prior} > 0.10 AND ${pct_change_vs_2mo} > 0.10)) THEN 'Growing'
      WHEN ((${pct_change_vs_prior} < -0.10 AND ${pct_change_vs_2mo} < -0.10)) THEN 'Declining'
      ELSE 'Stable'
    END ;;
    html: {% if value == 'Growing' %}
      <span style="color:#16a34a;font-weight:600;">▲ {{ rendered_value }}</span>
    {% elsif value == 'Declining' %}
      <span style="color:#dc2626;font-weight:600;">▼{{ rendered_value }}</span>
    {% else %}
      <span style="color:#6b7280;font-weight:600;">⇆ {{ rendered_value }}</span>
    {% endif %} ;;
  }


  measure: revenue_prior_month {
    type: sum
    sql: ${TABLE}.prior_month_total_rental_revenue ;;
  }

  measure: revenue_two_months_ago {
    type: sum
    sql: ${TABLE}.two_months_ago_total_rental_revenue ;;
  }

  measure: revenue_three_months_ago {
    type: sum
    sql: ${TABLE}.three_months_ago_total_rental_revenue ;;
  }

  dimension: pct_change_vs_prior_num {
    type: number
    value_format_name: percent_2
    sql: ((${TABLE}.prior_month_total_rental_revenue - ${TABLE}.two_months_ago_total_rental_revenue)
      / NULLIF(${TABLE}.two_months_ago_total_rental_revenue, 0)) ;;
  }

  dimension: pct_change_vs_2mo_num {
    type: number
    value_format_name: percent_2
    sql: ((${TABLE}.two_months_ago_total_rental_revenue - ${TABLE}.three_months_ago_total_rental_revenue)
      / NULLIF(${TABLE}.three_months_ago_total_rental_revenue, 0)) ;;
  }

  dimension: parent_company_name_with_nam {
    group_label: "Parent Company With NAM"
    label: "Company Name"
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME" ;;
    html:
    <font color="#0063f3">
    <a href="https://equipmentshare.looker.com/dashboards/1556?Company=&Parent+Company={{filterable_value | url_encode}}&Single-Line+Charts+Time+Frame=%5E-365" target="_blank">
    {{rendered_value}} ➔
    </a>
    </font>
    <br />
    <font style="color: #8C8C8C; text-align: right;">NAM: </font> {{assigned_nam._rendered_value}}  ;;
  }

  dimension: parent_company_name_with_link {
    group_label: "Parent Company With Link"
    label: "Company Name"
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME" ;;
    html:
    <font color="#0063f3">
    <a href="https://equipmentshare.looker.com/dashboards/1556?Company=&Parent+Company={{filterable_value | url_encode}}&Single-Line+Charts+Time+Frame=%5E-365" target="_blank">
    {{rendered_value}} ➔
    </a>
    </font> ;;
  }

  set: detail {
    fields: [
      month_year,
      parent_company_name_drill,
      company_name,
      assigned_nam,
      total_rental_revenue,
      total_oec_on_rent,
      total_assets_on_rent
    ]
  }
}

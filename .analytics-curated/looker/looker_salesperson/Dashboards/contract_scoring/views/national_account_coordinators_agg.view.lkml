view: national_account_coordinators_agg {
  derived_table: {
    sql:
WITH parent_company_relationships AS (
  SELECT company_id, parent_company_id
  FROM analytics.bi_ops.parent_company_relationships
  QUALIFY ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY record_created_timestamp DESC) = 1
),

user_map AS (
  SELECT
    u.user_id,
    u.email_address,
    CASE
      WHEN POSITION(' ', COALESCE(cd.nickname, cd.first_name)) = 0
        THEN CONCAT(COALESCE(cd.nickname, cd.first_name), ' ', cd.last_name)
      ELSE CONCAT(COALESCE(cd.nickname, CONCAT(cd.first_name, ' ', cd.last_name)))
    END AS name
  FROM es_warehouse.public.users u
  JOIN analytics.payroll.company_directory cd
    ON LOWER(u.email_address) = LOWER(cd.work_email)
),

/* 1) Start from your scoring table and resolve company_id exactly like your original */
scoring_with_company AS (
  SELECT
    f.*,
    c.company_id,
    p.parent_company_id
  FROM analytics.rate_achievement.contract_scoring_quarterly_agg f
  LEFT JOIN es_warehouse.public.companies c
    ON c.name = f.parent_company_name
  LEFT JOIN parent_company_relationships p
    ON p.company_id = c.company_id
),

/* 2) Compute invoice-grain payout inputs */
quarterly_payout_inputs AS (
  SELECT
    company_id,
    parent_company_id,
    DATE_TRUNC('QUARTER', invoice_date::date) AS quarter_start,

    gross_profit_margin_sum,
    gross_profit_margin_pct_sum,
    ancillary_pct_of_revenue,

    CASE
      WHEN gross_profit_margin_pct_sum >= .55 THEN 0.0015
      WHEN gross_profit_margin_pct_sum BETWEEN 0.525 AND 0.55 THEN 0.0013
      WHEN gross_profit_margin_pct_sum BETWEEN 0.5 AND 0.525 THEN 0.0012
      WHEN gross_profit_margin_pct_sum BETWEEN 0.475 AND 0.5 THEN 0.0009
      WHEN gross_profit_margin_pct_sum BETWEEN 0.45 AND 0.475 THEN 0.0007
      WHEN gross_profit_margin_pct_sum BETWEEN 0.425 AND 0.45 THEN 0.0004
      WHEN gross_profit_margin_pct_sum BETWEEN 0.4 AND 0.425 THEN 0.0003
      WHEN gross_profit_margin_pct_sum >= 0.375 AND gross_profit_margin_pct_sum < 0.4 THEN 0.0002
      WHEN gross_profit_margin_pct_sum < 0.375 THEN 0.0001
      ELSE 0.0001
    END AS payout_pct,

    CASE
      WHEN ancillary_pct_of_revenue >= 0.3 THEN 1.25
      WHEN ancillary_pct_of_revenue BETWEEN 0.25 AND 0.3 THEN 1.2
      WHEN ancillary_pct_of_revenue BETWEEN 0.2 AND 0.25 THEN 1.15
      WHEN ancillary_pct_of_revenue BETWEEN 0.175 AND 0.2 THEN 1.1
      WHEN ancillary_pct_of_revenue BETWEEN 0.15 AND 0.175 THEN 1.05
      WHEN ancillary_pct_of_revenue BETWEEN 0.125 AND 0.15 THEN 1
      WHEN ancillary_pct_of_revenue BETWEEN 0.1 AND 0.125 THEN 0.975
      WHEN ancillary_pct_of_revenue BETWEEN 0.09 AND 0.1 THEN 0.95
      WHEN ancillary_pct_of_revenue BETWEEN 0.08 AND 0.09 THEN 0.925
      WHEN ancillary_pct_of_revenue >= 0.07 AND ancillary_pct_of_revenue < 0.08 THEN 0.9
      WHEN ancillary_pct_of_revenue < 0.07 THEN 0.85
      ELSE 1
    END AS ancillary_multiplier
  FROM scoring_with_company
  WHERE company_id IS NOT NULL
),

/* 3) Quarter total payout per company_id */
quarter_payout AS (
  SELECT
    company_id,
    parent_company_id,
    quarter_start,
    gross_profit_margin_sum * payout_pct * ancillary_multiplier AS quarter_total_payout
  FROM quarterly_payout_inputs

),

/* 4) Explode quarter into 3 month-starts, allocate one third */
quarter_months AS (
  SELECT
    qp.company_id,
    qp.parent_company_id,
    qp.quarter_start,
    DATEADD(month, m.month_offset, qp.quarter_start) AS month_start,
    qp.quarter_total_payout / 3.0 AS monthly_third_payout
  FROM quarter_payout qp
  JOIN (
    SELECT 0 AS month_offset
    UNION ALL SELECT 1
    UNION ALL SELECT 2
  ) m
),

/* 5) For each month slice, find NAC assignment effective for that month (JOIN ON company_id like your original) */
month_assignments AS (
  SELECT
    qm.*,
    a.coordinator_user_id AS nac1_id,
    a.nac_2_user_id       AS nac2_id,
    a.nac_3_user_id       AS nac3_id
  FROM quarter_months qm
  LEFT JOIN analytics.rate_achievement.national_account_info_snapshot a
    ON a.company_id = qm.company_id
   AND a.snapshot_month = qm.month_start

),

/* 6) Resolve names and compute payouts per slice using your original split rules */
month_payout_calc AS (
  SELECT
    ma.month_start AS invoice_date,
    ma.monthly_third_payout AS total_payout,

    u1.name AS nac1,
    u2.name AS nac2,
    u3.name AS nac3,

    REGEXP_REPLACE(cd_nac1.direct_manager_name, '\\s*\\(\\d+\\)$', '') AS nam,

    CASE WHEN u1.name IS NOT NULL AND u2.name IS NULL AND u3.name IS NULL THEN 0.8 * ma.monthly_third_payout
         WHEN u1.name IS NOT NULL AND u2.name IS NOT NULL AND u3.name IS NULL THEN 0.5 * ma.monthly_third_payout
         WHEN u1.name IS NOT NULL AND u2.name IS NOT NULL AND u3.name IS NOT NULL THEN 0.4 * ma.monthly_third_payout
         ELSE NULL END AS nac1_payout,

    CASE WHEN u2.name IS NOT NULL THEN 0.3 * ma.monthly_third_payout ELSE NULL END AS nac2_payout,
    CASE WHEN u3.name IS NOT NULL THEN 0.1 * ma.monthly_third_payout ELSE NULL END AS nac3_payout,
    CASE WHEN cd_nac1.direct_manager_name IS NOT NULL THEN 0.2 * ma.monthly_third_payout ELSE NULL END AS nam_payout
  FROM month_assignments ma
  LEFT JOIN user_map u1 ON u1.user_id = ma.nac1_id
  LEFT JOIN user_map u2 ON u2.user_id = ma.nac2_id
  LEFT JOIN user_map u3 ON u3.user_id = ma.nac3_id
  LEFT JOIN analytics.payroll.company_directory cd_nac1
    ON LOWER(cd_nac1.work_email) = LOWER(u1.email_address)
),

/* 7) Person-level rows */
payouts AS (
  SELECT nac1 AS name, invoice_date, nac1_payout AS payout FROM month_payout_calc
  UNION ALL
  SELECT nac2 AS name, invoice_date, nac2_payout FROM month_payout_calc
  UNION ALL
  SELECT nac3 AS name, invoice_date, nac3_payout FROM month_payout_calc
  UNION ALL
  SELECT nam  AS name, invoice_date, nam_payout  FROM month_payout_calc
)

SELECT *
FROM payouts
WHERE name IS NOT NULL;;








    }


dimension: name {

  type: string
  sql: ${TABLE}."NAME" ;;


}


  dimension_group: invoice_date {
    type: time
    timeframes: [
      quarter,
      year
    ]
    sql: CAST(${TABLE}.INVOICE_DATE AS TIMESTAMP_NTZ) ;;
  }



measure: payout {

  type: sum
  sql: ${TABLE}."PAYOUT" ;;
  value_format_name: usd





}






    }

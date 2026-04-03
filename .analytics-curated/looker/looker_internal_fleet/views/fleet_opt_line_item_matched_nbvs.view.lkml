view: fleet_opt_line_item_matched_nbvs {
    derived_table: {
      sql: WITH base_data AS (
         SELECT
              li.line_item_id,
              li.line_item_type_id,
              lit.name AS line_item_type_name,
              li.invoice_id,
              i.invoice_no,
              li.asset_id,
              cli.credit_note_line_item_id,
              cn.memo AS credit_memo,
              m.name AS sale_branch,
              d.name AS sale_district,
              r.name AS sale_region,
              i.billing_approved_date AS gl_billing_approved_date,
              cli.date_created AS gl_billing_approved_date_for_credit,
              li.amount AS line_item_amount,
              cli.credit_amount AS credit_amount,
              li.amount + COALESCE(-ABS(cli.credit_amount), 0) AS actual_sales_amount_with_credits,
              CASE
                WHEN cli.credit_note_line_item_id IS NOT NULL THEN TRUE
                ELSE FALSE
              END AS line_item_has_credit,
              CASE
                WHEN (li.amount + COALESCE(-ABS(cli.credit_amount), 0)) = 0
                  AND (cli.credit_amount IS NOT NULL AND cli.credit_amount <> 0)
                THEN TRUE
                ELSE FALSE
              END AS line_item_fully_credited,
              CASE
                WHEN (li.amount + COALESCE(-ABS(cli.credit_amount), 0)) = 0
                  AND (cli.credit_amount IS NOT NULL AND cli.credit_amount <> 0)
                  AND DATE_TRUNC(month, i.billing_approved_date) = DATE_TRUNC(month, cli.date_created)
                THEN TRUE
                ELSE FALSE
              END AS line_item_fully_credited_in_same_month,
              CASE
                WHEN (li.amount + COALESCE(-ABS(cli.credit_amount), 0)) = 0
                  AND cn.memo ILIKE '%swap%'
                THEN TRUE
                ELSE FALSE
              END AS asset_most_likely_swapped,
              i.salesperson_user_id,
              CONCAT(u.first_name, ' ', u.last_name) AS sales_person_full_name,
              sm.name AS salesperson_branch_name,
              sd.name AS salesperson_district_name,
              sr.name AS salesperson_region_name
          FROM es_warehouse.public.line_items li
          LEFT JOIN es_warehouse.public.line_item_types lit ON li.line_item_type_id = lit.line_item_type_id
          LEFT JOIN es_warehouse.public.credit_note_line_items cli ON li.line_item_id = cli.line_item_id
          LEFT JOIN es_warehouse.public.credit_notes cn ON cli.credit_note_id = cn.credit_note_id
          LEFT JOIN es_warehouse.public.invoices i ON li.invoice_id = i.invoice_id
          LEFT JOIN fleet_optimization.gold.dim_assets_fleet_opt dafo ON li.asset_id = dafo.asset_id
          LEFT JOIN es_warehouse.public.users u ON u.user_id = i.salesperson_user_id
          LEFT JOIN es_warehouse.public.markets sm ON u.branch_id = sm.market_id
          LEFT JOIN es_warehouse.public.districts sd ON sm.district_id = sd.district_id
          LEFT JOIN es_warehouse.public.regions sr ON sd.region_id = sr.region_id
          LEFT JOIN es_warehouse.public.markets m ON li.branch_id = m.market_id
          LEFT JOIN es_warehouse.public.districts d ON m.district_id = d.district_id
          LEFT JOIN es_warehouse.public.regions r ON d.region_id = r.region_id
          WHERE li.line_item_type_id IN (
            81, 50, 111, 123, 24, 80, 110, 120, 125, 118, 126, 127
          )
          ),
          nbv_prior_to_billing AS (
          SELECT
              bd.line_item_id,
              bd.asset_id,
              bd.gl_billing_approved_date,
              nbv.total_estimated_nbv AS nbv,
              nbv.nbv_as_of_date
          FROM base_data bd
          LEFT JOIN fleet_optimization.gold.dim_agg_asset_nbv_by_month nbv
              ON bd.asset_id = nbv.asset_id
             AND LAST_DAY(DATEADD(month, -1, gl_billing_approved_date)) = nbv.nbv_as_of_date
          WHERE credit_note_line_item_id IS NULL
          ),
           nbv_on_sale_month AS (
          SELECT
              bd.line_item_id,
              bd.asset_id,
              bd.gl_billing_approved_date,
              nbv.total_estimated_nbv AS nbv,
              nbv.nbv_as_of_date
          FROM base_data bd
          LEFT JOIN fleet_optimization.gold.dim_agg_asset_nbv_by_month nbv
              ON bd.asset_id = nbv.asset_id
             AND LAST_DAY(bd.gl_billing_approved_date) = nbv.nbv_as_of_date
          WHERE credit_note_line_item_id IS NULL
      ),
      asset_snapshot_financing_previous AS (
          SELECT bd.line_item_id,
          bd.asset_id,
          afs.nbv,
          TO_DATE(afs.snapshot_date) AS snapshot_date,
          bd.gl_billing_approved_date,
          ROW_NUMBER() OVER (
          PARTITION BY afs.asset_id
          ORDER BY ABS(DATEDIFF(day, snapshot_date, bd.gl_billing_approved_date))
          ) AS closest_date_within_month_rank
          FROM base_data bd
          LEFT JOIN analytics.public.asset_financing_snapshots afs
          ON bd.asset_id = afs.asset_id
          AND LAST_DAY(DATEADD(month, -1, gl_billing_approved_date)) = LAST_DAY(afs.snapshot_date)
          WHERE credit_note_line_item_id IS NULL
          QUALIFY ROW_NUMBER() OVER (
          PARTITION BY afs.asset_id
          ORDER BY ABS(DATEDIFF(day, snapshot_date, bd.gl_billing_approved_date))
          ) = 1
      ),
      asset_snapshot_financing_current AS (
          SELECT bd.line_item_id,
          bd.asset_id,
          afs.nbv,
          TO_DATE(afs.snapshot_date) AS snapshot_date,
          bd.gl_billing_approved_date,
          ROW_NUMBER() OVER (
          PARTITION BY afs.asset_id
          ORDER BY ABS(DATEDIFF(day, snapshot_date, bd.gl_billing_approved_date))
          ) AS closest_date_within_month_rank
          FROM base_data bd
          LEFT JOIN analytics.public.asset_financing_snapshots afs
          ON bd.asset_id = afs.asset_id
          AND LAST_DAY(bd.gl_billing_approved_date) = LAST_DAY(afs.snapshot_date)
          WHERE credit_note_line_item_id IS NULL
          QUALIFY ROW_NUMBER() OVER (
          PARTITION BY afs.asset_id
          ORDER BY ABS(DATEDIFF(day, snapshot_date, bd.gl_billing_approved_date))
          ) = 1
      ),
      estimated_valuation_proxy AS (
          SELECT
              bd.line_item_id,
              bd.asset_id,
              bd.gl_billing_approved_date,
              fev.estimated_valuation_number
          FROM base_data bd
          LEFT JOIN fleet_optimization.gold.dim_assets_fleet_opt dafo
              ON bd.asset_id = dafo.asset_id
          LEFT JOIN fleet_optimization.gold.fact_estimated_valuation fev
              ON dafo.asset_key = fev.asset_key
             AND DATEADD(MONTH, -1, LAST_DAY(bd.gl_billing_approved_date)) = fev.date_month_end
          WHERE credit_note_line_item_id IS NULL
      ),
      rouse_estimation_proxy AS (
          SELECT
              bd.line_item_id,
              bd.asset_id,
              bd.gl_billing_approved_date,
              aere.net_book_value
          FROM base_data bd
          LEFT JOIN data_science.fleet_opt.all_equipment_rouse_estimates aere
              ON bd.asset_id = aere.asset_id
             AND DATEADD(MONTH, -1, LAST_DAY(bd.gl_billing_approved_date)) = LAST_DAY(TO_DATE(aere.date_created))
          WHERE credit_note_line_item_id IS NULL
      ),
      final_table AS (
          SELECT
              bd.*,
              nbv_prior.nbv AS actual_nbv_prior_to_gl_billing_approved,
              nbv_on_sale.nbv AS actual_nbv_in_month_of_gl_billing_approved,
              asfp.nbv AS afs_nbv_lagged,
              asfc.nbv AS afs_nbv_on_sale,
              estimated_valuation_proxy.estimated_valuation_number AS fo_nbv_proxy,
              rouse_estimation_proxy.net_book_value AS aere_nbv_proxy,
              CASE WHEN bd.line_item_fully_credited = TRUE THEN NULL
              ELSE
                  COALESCE(
                    NULLIF(nbv_prior.nbv,0),
                    NULLIF(afs_nbv_lagged,0),
                    NULLIF(rouse_estimation_proxy.net_book_value,0),
                    NULLIF(nbv_on_sale.nbv,0),
                    NULLIF(afs_nbv_on_sale,0),
                    NULLIF(estimated_valuation_proxy.estimated_valuation_number,0)
                  )
              END AS sale_nbv_estimate,
              CASE WHEN bd.actual_sales_amount_with_credits <= 0 OR bd.actual_sales_amount_with_credits IS NULL OR sale_nbv_estimate <= 0 OR sale_nbv_estimate IS NULL THEN NULL
                ELSE (bd.actual_sales_amount_with_credits - sale_nbv_estimate)
              END AS sale_earnings,
              CASE WHEN bd.actual_sales_amount_with_credits <= 0 OR bd.actual_sales_amount_with_credits IS NULL OR sale_nbv_estimate <= 0 OR sale_nbv_estimate IS NULL THEN NULL
                ELSE (bd.actual_sales_amount_with_credits - sale_nbv_estimate) / bd.actual_sales_amount_with_credits
              END AS sale_margin_pct
          FROM base_data bd
          LEFT JOIN nbv_prior_to_billing nbv_prior
            ON bd.asset_id = nbv_prior.asset_id AND bd.line_item_id = nbv_prior.line_item_id
          LEFT JOIN nbv_on_sale_month nbv_on_sale
            ON bd.asset_id = nbv_on_sale.asset_id AND bd.line_item_id = nbv_on_sale.line_item_id
          LEFT JOIN estimated_valuation_proxy
            ON bd.asset_id = estimated_valuation_proxy.asset_id AND bd.line_item_id = estimated_valuation_proxy.line_item_id
          LEFT JOIN rouse_estimation_proxy
            ON bd.asset_id = rouse_estimation_proxy.asset_id AND bd.line_item_id = rouse_estimation_proxy.line_item_id
          LEFT JOIN asset_snapshot_financing_previous asfp
            ON bd.asset_id = asfp.asset_id AND bd.line_item_id = asfp.line_item_id
          LEFT JOIN asset_snapshot_financing_current asfc
            ON bd.asset_id = asfc.asset_id AND bd.line_item_id = asfc.line_item_id
      )
      SELECT * FROM final_table
      ;;
      }

  # ---- Primary key ----
  dimension: line_item_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.line_item_id ;;
  }

  # ---- Core keys / ids ----
  dimension: invoice_id {
    type: number
    sql: ${TABLE}.invoice_id ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}.invoice_no ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}.line_item_type_id ;;
  }

  dimension: line_item_type_name {
    type: string
    sql: ${TABLE}.line_item_type_name ;;
  }

  dimension: credit_note_line_item_id {
    type: number
    sql: ${TABLE}.credit_note_line_item_id ;;
    hidden: yes
  }

  # ---- Dates ----
  dimension_group: gl_billing_approved_date {
    type: time
    timeframes: [date, week, month, quarter, year, raw]
    sql: ${TABLE}.gl_billing_approved_date ;;
  }

  dimension_group: gl_billing_approved_date_for_credit {
    type: time
    timeframes: [date, week, month, quarter, year, raw]
    sql: ${TABLE}.gl_billing_approved_date_for_credit ;;
    hidden: yes
  }

  # ---- Locations (sale) ----
  dimension: sale_branch {
    type: string
    sql: ${TABLE}.sale_branch ;;
  }

  dimension: sale_district {
    type: string
    sql: ${TABLE}.sale_district ;;
  }

  dimension: sale_region {
    type: string
    sql: ${TABLE}.sale_region ;;
  }

  # ---- Locations (salesperson) ----
  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}.salesperson_user_id ;;
  }

  dimension: sales_person_full_name {
    type: string
    sql: ${TABLE}.sales_person_full_name ;;
  }

  dimension: salesperson_branch_name {
    type: string
    sql: ${TABLE}.salesperson_branch_name ;;
  }

  dimension: salesperson_district_name {
    type: string
    sql: ${TABLE}.salesperson_district_name ;;
  }

  dimension: salesperson_region_name {
    type: string
    sql: ${TABLE}.salesperson_region_name ;;
  }

  # ---- Credit / flags ----
  dimension: credit_memo {
    type: string
    sql: ${TABLE}.credit_memo ;;
  }

  dimension: line_item_has_credit {
    type: yesno
    sql: ${TABLE}.line_item_has_credit ;;
  }

  dimension: line_item_fully_credited {
    type: yesno
    sql: ${TABLE}.line_item_fully_credited ;;
  }

  dimension: line_item_fully_credited_in_same_month {
    type: yesno
    sql: ${TABLE}.line_item_fully_credited_in_same_month ;;
  }

  dimension: asset_most_likely_swapped {
    type: yesno
    sql: ${TABLE}.asset_most_likely_swapped ;;
  }

  # ---- Dollar amounts (row-level) ----
  dimension: line_item_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}.line_item_amount ;;
  }

  dimension: credit_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}.credit_amount ;;
  }

  dimension: actual_sales_amount_with_credits {
    type: number
    value_format_name: usd
    sql: ${TABLE}.actual_sales_amount_with_credits ;;
  }

  dimension: actual_nbv_prior_to_gl_billing_approved {
    type: number
    value_format_name: usd
    sql: ${TABLE}.actual_nbv_prior_to_gl_billing_approved ;;
  }

  dimension: actual_nbv_in_month_of_gl_billing_approved {
    type: number
    value_format_name: usd
    sql: ${TABLE}.actual_nbv_in_month_of_gl_billing_approved ;;
  }

  dimension: afs_nbv_lagged {
    type: number
    value_format_name: usd
    sql: ${TABLE}.afs_nbv_lagged ;;
  }

  dimension: afs_nbv_on_sale {
    type: number
    value_format_name: usd
    sql: ${TABLE}.afs_nbv_on_sale ;;
  }

  dimension: fo_nbv_proxy {
    type: number
    value_format_name: usd
    sql: ${TABLE}.fo_nbv_proxy ;;
  }

  dimension: aere_nbv_proxy {
    type: number
    value_format_name: usd
    sql: ${TABLE}.aere_nbv_proxy ;;
  }

  dimension: sale_nbv_estimate {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.sale_nbv_estimate ;;
  }

  dimension: sale_earnings {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.sale_earnings ;;
  }

  dimension: sale_margin_pct {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.sale_margin_pct ;;
  }

  # ---- Basic measures ----
  measure: count {
    type: count
    drill_fields: [line_item_id, invoice_no, asset_id]
  }

  measure: distinct_assets {
    type: count_distinct
    sql: ${asset_id} ;;
  }

  measure: distinct_invoices {
    type: count_distinct
    sql: ${invoice_id} ;;
  }

  measure: total_line_item_amount {
    type: sum
    value_format_name: usd_0
    sql: ${line_item_amount} ;;
  }

  measure: total_credit_amount {
    type: sum
    value_format_name: usd_0
    sql: ${credit_amount} ;;
  }

  measure: total_actual_sales_with_credits {
    type: sum
    value_format_name: usd_0
    sql: ${actual_sales_amount_with_credits} ;;
  }

  measure: total_sale_nbv_estimate {
    type: sum
    value_format_name: usd_0
    sql: ${sale_nbv_estimate} ;;
  }

  # ---- Some useful ratios / margins ----
  measure: avg_sale_nbv_estimate {
    type: average
    value_format_name: usd_0
    sql: ${sale_nbv_estimate} ;;
  }

  measure: avg_actual_sales_with_credits {
    type: average
    value_format_name: usd_0
    sql: ${actual_sales_amount_with_credits} ;;
  }

  # Margin = sales - NBV, aggregated correctly
  measure: average_sale_earnings {
    type: number
    value_format_name: usd_0
    sql: ${sale_earnings} ;;
  }

  measure: average_sale_margin_pct {
    type: average
    value_format_name: percent_2
    sql: ${sale_margin_pct};;
  }

  # Share of fully credited items
  measure: pct_line_items_fully_credited {
    type: number
    value_format_name: percent_2
    sql: AVG(CASE WHEN ${line_item_fully_credited} THEN 1.0 ELSE 0.0 END) ;;
  }
}

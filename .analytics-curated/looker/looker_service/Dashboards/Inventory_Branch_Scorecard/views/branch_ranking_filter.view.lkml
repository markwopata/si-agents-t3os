# Bin Locations:      Low     0.5
# Deadstock:          High    2
# Manual Adjustments: High    2
# Min / Max:          Low     0.5
# Parts Needed:       High    2
# Purchase Orders:    High    2
# Warranty Denials:   Medium  1

view: branch_ranking_filter {
  derived_table: {
    sql:
      WITH combined_data AS (
        select
          d.market_id,
          -- Calculating the total score
          COALESCE((AVG(LEAST(COALESCE(bla.score,0),{% parameter bin_locations_aggregate.weight %})) +
                    AVG(LEAST(COALESCE(dsa.score,0),{% parameter deadstock_aggregate.weight %})) +
                    AVG(LEAST(COALESCE(maa.score,0),{% parameter manual_adjustment_aggregate.weight %})) +
                    AVG(LEAST(COALESCE(mmu.score,0),{% parameter min_max_use_aggregate.weight %})) +
                    AVG(LEAST(COALESCE(woa.score,0),{% parameter parts_needed_wo_aggregate.weight %})) +
                    AVG(LEAST(COALESCE(poa.score,0),{% parameter purchase_order_aggregate.weight %})) +
                    AVG(LEAST(COALESCE(wda.score,0),{% parameter warranty_denials_aggregate.weight %}))
          ),0)                                                                                              as total_score_avg_last_3_months,
        from ${market_region_xwalk_and_dates.SQL_TABLE_NAME}                                                as d
          -- LEFT JOIN each aggregate table based on market_id & month
          LEFT JOIN ${bin_locations_aggregate.SQL_TABLE_NAME}                                               as bla
            on d.market_id = bla.branch_id and d.month = bla.month
          LEFT JOIN ${deadstock_aggregate.SQL_TABLE_NAME}                                                   as dsa
            ON d.market_id = dsa.market_id and d.month = dsa.month
          LEFT JOIN ${manual_adjustment_aggregate.SQL_TABLE_NAME}                                           as maa
            ON d.market_id = maa.market_id and d.month = maa.month
          LEFT JOIN ${min_max_use_aggregate.SQL_TABLE_NAME}                                                 as mmu
            on d.market_id = mmu.branch_id and d.month = mmu.month
          LEFT JOIN ${parts_needed_wo_aggregate.SQL_TABLE_NAME}                                             as woa
            on d.market_id = woa.branch_id and d.month = woa.month
          LEFT JOIN ${purchase_order_aggregate.SQL_TABLE_NAME}                                              as poa
            on d.market_id = poa.branch_id and d.month = poa.month
          LEFT JOIN ${warranty_denials_aggregate.SQL_TABLE_NAME}                                            as wda
            on d.market_id = wda.branch_id and d.month = wda.month
        where d.month >= DATEADD('month', -3, DATE_TRUNC('month', CURRENT_DATE()))
          and d.month < DATE_TRUNC('month', CURRENT_DATE())
        group by 1
        )
        select
              market_id,
              total_score_avg_last_3_months,
              -- Ranking logic
              RANK() OVER (ORDER BY total_score_avg_last_3_months DESC)                                     as desc_rank,
              RANK() OVER (ORDER BY total_score_avg_last_3_months ASC)                                      as asc_rank
        from combined_data
        ;;
  }
  # Dimensions
  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
  }
  dimension: branch_ranking {
    type: string
    sql: CASE
           WHEN ${TABLE}.desc_rank <= 10 THEN 'Top 10'
           WHEN ${TABLE}.asc_rank <= 10 THEN 'Bottom 10'
           ELSE null
         END ;;
  }
  dimension: total_score_avg_last_3_months {
    type: number
    value_format: "0.00"
    sql: ${TABLE}."TOTAL_SCORE_AVG_LAST_3_MONTHS" ;;
  }
}

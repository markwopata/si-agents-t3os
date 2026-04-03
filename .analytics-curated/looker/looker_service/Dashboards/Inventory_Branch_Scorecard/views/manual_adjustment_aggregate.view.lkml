view: manual_adjustment_aggregate {

  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql:
        with wo_tags_aggregate as (
            SELECT wo.work_order_id,
                   wo.work_order_status_id,
                   LISTAGG(t.name, ', ') AS tags,
                   COUNT(*)              AS total_tags
            FROM es_warehouse.work_orders.work_orders wo
            INNER JOIN es_warehouse.work_orders.work_order_company_tags as ct
                ON ct.work_order_id = wo.work_order_id
            INNER JOIN es_warehouse.work_orders.company_tags            as t
                ON t.company_tag_id = ct.company_tag_id
            INNER JOIN es_warehouse.public.assets                       as a
                ON wo.asset_id = a.asset_id
            INNER JOIN es_warehouse.public.markets                      as m
                ON a.service_branch_id = m.market_id
            WHERE m.company_id = 1854 --only assets that we service
              AND wo.archived_date IS NULL
            GROUP BY wo.work_order_id, wo.work_order_status_id
        )
        , outgoing_count as (
            select pit.MARKET_ID,
                   date_trunc(month,pit.date_completed)::date           as month,
                   count(*)                                             as transactions
            from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS   as pit
            left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS              as wo
                on pit.WORK_ORDER_ID = wo.WORK_ORDER_ID
            left join wo_tags_aggregate                                 as wot
                on wo.WORK_ORDER_ID = wot.WORK_ORDER_ID
            where date_trunc(month, pit.DATE_COMPLETED) >= dateadd(month,-18,current_date) and
              ((TRANSACTION_TYPE_ID in (7) and wot.tags ilike any ('%Inventory%','%Cycle Count%','%Adjustment%') and wo.WORK_ORDER_STATUS_ID in (3,4)) or
               (TRANSACTION_TYPE_ID in (18) and MANUAL_ADJUSTMENT_REASON_ID in (4,10)))
            group by 1,2
            order by 1,2
        )
        , incoming_count as (
            select pit.MARKET_ID,
                   date_trunc(month,pit.date_completed)::date           as month,
                   count(*)                                             as transactions
            from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS   as pit
            left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS              as wo
                on pit.WORK_ORDER_ID = wo.WORK_ORDER_ID
            where date_trunc(month, pit.DATE_COMPLETED) >= dateadd(month,-18,current_date) and
              (TRANSACTION_TYPE_ID in (17) and MANUAL_ADJUSTMENT_REASON_ID in (1,10))
            group by 1,2
            order by 1,2
        )
        , total_transactions_count as (
            select pit.MARKET_ID,
                   date_trunc(month,pit.date_completed)::date           as month,
                   count(*)                                             as transactions
            from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS   as pit
            left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS              as wo
                on pit.WORK_ORDER_ID = wo.WORK_ORDER_ID
            where date_trunc(month, pit.DATE_COMPLETED) >= dateadd(month,-18,current_date)
            group by 1,2
            order by 1,2
        )
        select ttc.MARKET_ID,
               ttc.month,
               ttc.transactions                                         as total_transactions,
               otc.transactions                                         as outgoing_transactions,
               itc.transactions                                         as incoming_transactions,
               zeroifnull(outgoing_transactions) + zeroifnull(incoming_transactions)      as total_manual_adjustments,
               round(total_manual_adjustments / nullifzero(total_transactions),4)         as ratio,
        --        since the total_manual_adjustments is such a small number compared to the overall number of
        --        transactions, we set a goal then score based on the branches performance when compared to the goal
        --        for this metric, the goal is set at 1.2%.  Branches get points as long as they're under the goal.
               round(1 - ratio / .012,4)                                 as perc_to_goal,
               round(perc_to_goal * {% parameter weight %},2)           as score
        from total_transactions_count                                   as ttc
        left join outgoing_count                                        as otc
            on ttc.MARKET_ID = otc.MARKET_ID and
               ttc.month = otc.month
        left join incoming_count                                        as itc
            on ttc.MARKET_ID = itc.MARKET_ID and
               ttc.month = itc.month
        order by 1,2 desc;;
  }
  label: "Manual Adjustments"
    dimension: pkey {
      type: string
      hidden: yes
      primary_key: yes
      sql: CONCAT(${month}, ${market_id});;
    }
    dimension: market_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."MARKET_ID" ;;
    }
    dimension: month {
      type: date
      sql: ${TABLE}."MONTH" ;;
    }
    dimension: total_transactions {
      type: number
      sql: ${TABLE}."TOTAL_TRANSACTIONS" ;;
    }
    dimension: total_manual_adjustments {
      type: number
      sql: ${TABLE}."TOTAL_MANUAL_ADJUSTMENTS" ;;
    }
    dimension: ratio {
      type: number
      value_format_name: percent_2
      sql: COALESCE(GREATEST(${TABLE}."RATIO",0),1) ;;
    }
    parameter: weight {
      hidden: yes
      default_value: "2"
    }
    dimension: score {
      type: number
      value_format: "0.00"
      sql: COALESCE(GREATEST(${TABLE}."SCORE",0),{% parameter weight %}) ;;
    }
    measure: ratio_avg_last_1_month {
      type: average
      value_format_name: percent_2
      sql: case when ${inventory_branch_scorecard.is_last_1_month} then ${ratio} else null end;;
    }
    measure: ratio_avg_last_3_months {
      type: average
      value_format_name: percent_2
      sql: case when ${inventory_branch_scorecard.is_last_3_months} then ${ratio} else null end;;
    }
    measure: ratio_avg_last_6_months {
      type: average
      value_format_name: percent_2
      sql: case when ${inventory_branch_scorecard.is_last_6_months} then ${ratio} else null end;;
    }
    measure: ratio_avg_last_12_months {
      type: average
      value_format_name: percent_2
      sql: case when ${inventory_branch_scorecard.is_last_12_months} then ${ratio} else null end;;
    }
    measure: score_avg_last_1_month {
      type: average
      value_format: "0.00"
      html: {{score_avg_last_1_month._rendered_value}} / {{ratio_avg_last_1_month._rendered_value}} ;;
      sql:  case when ${inventory_branch_scorecard.is_last_1_month} then ${score} else null end;;
    }
    measure: score_avg_last_3_months {
      type: average
      value_format: "0.00"
      html: {{score_avg_last_3_months._rendered_value}} / {{ratio_avg_last_3_months._rendered_value}} ;;
      sql:  case when ${inventory_branch_scorecard.is_last_3_months} then ${score} else null end;;
    }
    measure: score_avg_last_6_months {
      type: average
      value_format: "0.00"
      html: {{score_avg_last_6_months._rendered_value}} / {{ratio_avg_last_6_months._rendered_value}} ;;
      sql:  case when ${inventory_branch_scorecard.is_last_6_months} then ${score} else null end;;
    }
    measure: score_avg_last_12_months {
      type: average
      value_format: "0.00"
      html: {{score_avg_last_12_months._rendered_value}} / {{ratio_avg_last_12_months._rendered_value}} ;;
      sql:  case when ${inventory_branch_scorecard.is_last_12_months} then ${score} else null end;;
    }



}

view: abs_assets {
  derived_table: {
    sql:
    with period as (
       SELECT
        dd.dt_key,
        dd.dt_date                AS period_date,
        DATE_TRUNC('month', dd.dt_date)  AS period_start_date,
        dd.dt_period             AS period_name
      FROM platform.gold.dim_dates dd
      WHERE dd.dt_date >= '2021-01-01'
        AND dd.dt_date <= CURRENT_DATE
        AND (
          dd.dt_date = LAST_DAY(dd.dt_date)
          OR dd.dt_date = CURRENT_DATE
        )
        and {% condition period_name %} dd.period_name {% endcondition %}
      ORDER BY dd.dt_date DESC
    ),
    revenues as (
        select
            ild.asset_id,
            round(sum(amount), 2) as amount
        from analytics.intacct_models.int_admin_invoice_and_credit_line_detail as ild
        cross join period
        where ild.gl_date::date >= date_trunc(month, period.period_date::date)
            and ild.gl_date::date <= period.period_date
            and ild.line_item_type_id in (6, 8, 108, 109)
        group by ild.asset_id
    ),

    first_program_date as (
        select
            ipp.asset_id,
            date_trunc(month, min(ipp.date_start)) as first_payout_program_date
        from analytics.assets.int_payout_programs as ipp
        group by all
    ),

    ala2 as (
        select
            ala.admin_asset_id,
            round(sum(ala.nbv_estimated_book_value), 2) as nbv
        from analytics.assets.asset4000_las_assets as ala
        cross join period
        where ala.report_date::date = period.period_date
        group by all
    )

    select
        ia.asset_id,
        year(ia.first_rental_date)::text as first_rental_year,
        ia.first_rental_date::date as first_rental_date,
        round(coalesce(iaph.oec, ia.oec), 2) as oec,
        ia.make,
        ia.model,
        ia.year as model_year,
        ia.purchase_date::date as purchase_date,
        m.state as asset_state,
        m.market_id,
        m.market_name,
        ia.equipment_class as class,
        ia.category,
        r.amount as rental_revenue,
        ala2.nbv as nbv_raw,
        -- audit fields
        sac.company_id as asset_company_id,
        ia.purchase_date::date as purchase_date_,
        ia.first_rental_date::date as first_rental_date_,
        ipp.payout_program_id is not null as is_payout_program,
        fpd.first_payout_program_date,
        greatest(0, case
            when is_payout_program
                then datediff(months, date_trunc(
                        month,
                        least(
                            coalesce(ia.first_rental_date, '2099-12-31'::date),
                            fpd.first_payout_program_date
                        )
                    ), date_trunc(month, period.period_date)) + 1
            when ala2.nbv is null and ia.rental_branch_id is null
                then datediff(months, date_trunc(month, ia.first_rental_date), date_trunc(month, period.period_date)) + 1
        end)
            as months_to_depreciate, -- Has to be greater than equal to 0
        round(greatest(0, coalesce(iaph.oec, ia.oec) * (1 - months_to_depreciate * .0115)), 2) as nbv_estimated,
        coalesce(nbv_estimated, nbv_raw) as nbv,
        period.period_date

    -- iah.flv,
    --        iah.olv,
    --        iah.fmv,
    --        iah.revenue
    from analytics.vm_dbt.int_assets as ia
        cross join period
        left join analytics.intacct_models.stg_es_warehouse_scd__scd_asset_rsp as sar
            on ia.asset_id = sar.asset_id
                and period.period_date::date + 1 - interval '1 nanosecond' between sar.date_start and sar.date_end
        left join analytics.intacct_models.stg_es_warehouse_scd__scd_asset_inventory as sai
            on ia.asset_id = sai.asset_id
                and period.period_date::date + 1 - interval '1 nanosecond' between sai.date_start and sai.date_end
        left join analytics.intacct_models.stg_es_warehouse_scd__scd_asset_company as sac
            on ia.asset_id = sac.asset_id
                and period.period_date::date + 1 - interval '1 nanosecond' between sac.date_start and sac.date_end
        left join analytics.assets.int_payout_programs as ipp
            on ia.asset_id = ipp.asset_id
                and period.period_date::date + 1 - interval '1 nanosecond' between ipp.date_start and ipp.date_end
        left join analytics.vm_dbt.int_markets as m
            on coalesce(sar.rental_branch_id, sai.inventory_branch_id) = m.market_id
        left join ala2
            on ia.asset_id = ala2.admin_asset_id
        left join revenues as r
            on ia.asset_id = r.asset_id
        left join first_program_date as fpd
            on ia.asset_id = fpd.asset_id
        left join analytics.assets.int_asset_purchase_history as iaph
            on ia.asset_id = iaph.asset_id
                and period.period_date::date + 1 - interval '1 nanosecond' between iaph.date_start and iaph.date_end
    where 1 = 1
      ;;
  }

  filter: period_name {
    type: string
    suggest_explore: period_list_for_abs_assets
    suggest_dimension: period_list_for_abs_assets.period_name
  }

# Dimensions
  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: first_rental_year {
    type: string
    sql: ${TABLE}.first_rental_year ;;
  }

  dimension: first_rental_date {
    type: date
    sql: ${TABLE}.first_rental_date ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}.oec ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: model_year {
    type: number
    sql: ${TABLE}.model_year ;;
  }

  dimension: purchase_date {
    type: date
    sql: ${TABLE}.purchase_date ;;
  }

  dimension: asset_state {
    type: string
    sql: ${TABLE}.asset_state ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}.class ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}.rental_revenue ;;
  }

  dimension: nbv_raw {
    type: number
    sql: ${TABLE}.nbv_raw ;;
  }

  dimension: asset_company_id {
    type: number
    sql: ${TABLE}.asset_company_id ;;
  }

  dimension: purchase_date_ {
    type: date
    sql: ${TABLE}.purchase_date_ ;;
  }

  dimension: first_rental_date_ {
    type: date
    sql: ${TABLE}.first_rental_date_ ;;
  }

  dimension: is_payout_program {
    type: yesno
    sql: ${TABLE}.is_payout_program ;;
  }

  dimension: first_payout_program_date {
    type: date
    sql: ${TABLE}.first_payout_program_date ;;
  }

  dimension: months_to_depreciate {
    type: number
    sql: ${TABLE}.months_to_depreciate ;;
  }

  dimension: nbv_estimated {
    type: number
    sql: ${TABLE}.nbv_estimated ;;
  }

  dimension: nbv {
    type: number
    sql: ${TABLE}.nbv ;;
  }

  dimension: period_date {
    type: date
    sql: ${TABLE}.period_date ;;

  }


# Measures
  measure: total_assets {
    type: count_distinct
    sql: ${asset_id} ;;
  }

  measure: total_rental_revenue_apr25 {
    type: sum
    sql: ${TABLE}.rental_revenue_apr25 ;;
  }

  measure: total_nbv_raw {
    type: sum
    sql: ${TABLE}.nbv_raw ;;
  }

  measure: total_nbv_estimated {
    type: sum
    sql: ${TABLE}.nbv_estimated ;;
  }

}

view: asset_utilization_rolling_weekly24 {
  derived_table: {
    sql:
  WITH day_series AS (
  select distinct date_trunc('week', series::date) as week_date
      from table(es_warehouse.public.generate_series(
                                dateadd(week, -24, current_date)::timestamp_tz,
                                dateadd(day, 1, current_date)::timestamp_tz,
                                'week'))
  )
  , all_asset_in_inventory_with_status as (
  -- Assets in inventory and status at the start of the time period
      select
        ds.week_date,
        a.asset_id, --sai.date_start, sai.date_end,
        aa.asset_type,
        coalesce(ec.name, 'No Asset Class') as asset_class,
        last_value(ais.asset_inventory_status) over (partition by ds.week_date, a.asset_id order by ais.date_end) as asset_inventory_status, --ais.date_start, ais.date_end,
        m.market_id,
        m.name,
        a.company_id as asset_owner_id,
        coalesce(aa.oec,a.purchase_price,0) as oec
      from es_warehouse.public.assets_aggregate aa
            join ES_WAREHOUSE.SCD.scd_asset_inventory sai on aa.asset_id = sai.asset_id
            join ES_WAREHOUSE.PUBLIC.assets a on sai.asset_id = a.asset_id
            left join ES_WAREHOUSE.SCD.scd_asset_inventory_status ais on aa.asset_id = ais.asset_id
            left join ES_WAREHOUSE.PUBLIC.equipment_classes ec on a.equipment_class_id = ec.equipment_class_id
            join ES_WAREHOUSE.PUBLIC.markets m on coalesce(a.rental_branch_id, a.inventory_branch_id) = m.market_id
            join day_series ds
                        on ds.week_date >= (convert_timezone('Pacific/Auckland', sai.date_start))
                               AND ds.week_date < coalesce((convert_timezone('Pacific/Auckland', sai.date_end)), '2099-12-31')
                            AND ds.week_date >= (convert_timezone('Pacific/Auckland', ais.date_start))
                               AND ds.week_date <= coalesce((convert_timezone('Pacific/Auckland', ais.date_end)), '2099-12-31')
      where m.company_id = 6302
        -- removed deleted assets prior to the time period based on the SDC asset inventory table
        and ES_WAREHOUSE.PUBLIC.overlaps(sai.date_start, sai.date_end, convert_timezone('Pacific/Auckland','UTC', current_timestamp)::date - interval '24 weeks', convert_timezone('Pacific/Auckland','UTC', current_timestamp)::date + interval '59 mins')
        and ES_WAREHOUSE.PUBLIC.overlaps(ais.date_start::date, ais.date_end::date, convert_timezone('Pacific/Auckland','UTC', current_timestamp)::date - interval '24 weeks', convert_timezone('Pacific/Auckland','UTC', current_timestamp)::date + interval '59 mins')
     )
    , tot_rental_revenue_by_day as (
    --Calculate rental revenue by invoice data
      select distinct
        ds.week_date,
       -- use asset_id on line_item if available; otherwise use asset_id on initial rental
        coalesce(li.payload:rental.asset_id, r.asset_id) as asset_id,
        m.market_id,
        sum(li.sub_total) as rental_rev
      from ES_WAREHOUSE.PUBLIC.orders o
        join ES_WAREHOUSE.PUBLIC.rentals r on o.order_id = r.order_id
        join ES_WAREHOUSE_NZ.PUBLIC.invoices i on o.order_id = i.order_external_id
        join ES_WAREHOUSE_NZ.PUBLIC.line_items li on i.id = li.invoice_id
        join ES_WAREHOUSE.PUBLIC.markets m on o.market_id = m.market_id
        join day_series ds
                      on (convert_timezone('Pacific/Auckland', i.issue_date)) >= ds.week_date
                            and (convert_timezone('Pacific/Auckland', i.issue_date)) < ds.week_date + interval '8 days'
      where m.company_id = 6302
        and li.charge_id = 1
        and i.issue_date::date >= convert_timezone('Pacific/Auckland','UTC', current_timestamp)::date - interval '24 weeks' and i.issue_date::date < convert_timezone('Pacific/Auckland','UTC', current_timestamp)::date + interval '1 day'
        and i.deleted_date is NULL
        and li.deleted_date is NULL
      group by ds.week_date, coalesce(li.payload:rental.asset_id, r.asset_id), m.market_id
      )
--      , joinA as(
      -- join non-summarized data together; do calculations in Looker
      select
        inv.week_date,
        inv.asset_id,
        initcap(inv.asset_type) as asset_type,
        inv.asset_class,
        inv.market_id as branch_id,
        inv.name as branch,
        inv.asset_owner_id,
        inv.asset_inventory_status,
        inv.oec,
        coalesce(r.rental_rev,0) as rental_rev
      from all_asset_in_inventory_with_status inv
        left join tot_rental_revenue_by_day r on inv.week_date = r.week_date and inv.asset_id = r.asset_id and inv.market_id = r.market_id
    ;;
  }
  dimension: compound_primary_key {
    primary_key: yes
    type: string
    sql: concat(${week_date}, ${asset_id}) ;;
  }

  dimension: week_date {
    label: "Week"
    type: date_week
    sql: ${TABLE}."WEEK_DATE" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format_name: id
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: rental_rev {
    type: number
    sql: ${TABLE}."RENTAL_REV" ;;
  }

  measure: tot_asset_oec {
    label: "OEC"
    type: sum
    sql: ${oec};;
    value_format: "0.0,,\" M\""
    drill_fields: [branch, asset_id, asset_class, oec]
  }

  measure: assets_considered_on_rent {
    type: count
    filters: [asset_inventory_status: "On Rent"]
  }

  measure: total_asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [branch, asset_id, asset_class, oec]
  }

  measure: count_utilization {
    type: number
    sql: ${assets_considered_on_rent} / case when ${total_asset_count} = 0 then NULL else ${total_asset_count} end ;;
    value_format_name: percent_1
    drill_fields: [week_date, asset_class_customer_branch.branch, asset_id, asset_inventory_status, total_asset_count]
  }

  measure: tot_rental_rev_for_oec_assets {
    label: "Daily Rental Revenue"
    type: sum
    sql: CASE WHEN ${oec} = 0 then NULL ELSE ${rental_rev} END ;;
    value_format_name: usd_0
  }

  measure: financial_utilization {
    type: number
    sql:  ${tot_rental_rev_for_oec_assets} * 365 / 7 / CASE WHEN ${tot_asset_oec} = 0 THEN NULL ELSE ${tot_asset_oec} END ;;
    value_format_name: percent_1
    drill_fields: [week_date,
      asset_class_customer_branch.branch,
      asset_id,
      asset_class_customer_branch.make,
      asset_class_customer_branch.model,
      asset_inventory_status,
      tot_rental_rev_for_oec_assets,
      tot_asset_oec,
      financial_utilization]
  }

  }

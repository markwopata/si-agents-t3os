view: asset_utilization_rolling180 {
  derived_table: {
    sql:
        WITH day_series AS (
        select distinct date_trunc('day', series::date) as day_date
        from table(es_warehouse.public.generate_series(
                                dateadd(day, -180, current_date)::timestamp_tz,
                                dateadd(day, 1, current_date)::timestamp_tz,
                                'day'))
        )
        , all_asset_in_inventory_with_status as (
        -- Assets in inventory and status at the start of the time period
            select
              ds.day_date,
              a.asset_id, aa.asset_type, --sai.date_start, sai.date_end,
              coalesce(ec.name, 'No Asset Class') as asset_class,
              last_value(ais.asset_inventory_status) over (partition by ds.day_date, a.asset_id order by ais.date_end) as asset_inventory_status, --ais.date_start, ais.date_end,
              m.market_id,
              m.name,
              coalesce(aa.oec,a.purchase_price,0) as oec
            from es_warehouse.public.assets_aggregate aa
                  join ES_WAREHOUSE.SCD.scd_asset_inventory sai on aa.asset_id = sai.asset_id
                  join ES_WAREHOUSE.PUBLIC.assets a on sai.asset_id = a.asset_id
                  left join ES_WAREHOUSE.SCD.scd_asset_inventory_status ais on aa.asset_id = ais.asset_id
                  left join ES_WAREHOUSE.PUBLIC.equipment_classes ec on a.equipment_class_id = ec.equipment_class_id
                  join ES_WAREHOUSE.PUBLIC.markets m on coalesce(a.rental_branch_id, a.inventory_branch_id) = m.market_id
                  join ES_WAREHOUSE.PUBLIC.companies c on a.company_id = c.company_id
                  join day_series ds
                              on ds.day_date >= (convert_timezone('{{ _user_attributes['user_timezone'] }}', sai.date_start))
                                     AND ds.day_date <= coalesce((convert_timezone('{{ _user_attributes['user_timezone'] }}', sai.date_end)), '2099-12-31')
                                  AND ds.day_date >= (convert_timezone('{{ _user_attributes['user_timezone'] }}', ais.date_start))
                                     AND ds.day_date <= coalesce((convert_timezone('{{ _user_attributes['user_timezone'] }}', ais.date_end)), '2099-12-31')
            where m.company_id = {{ _user_attributes['company_id'] }}
              -- removed deleted assets prior to the time period based on the SDC asset inventory table
              and ES_WAREHOUSE.PUBLIC.overlaps(sai.date_start, sai.date_end, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date - interval '180 days', convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date + interval '59 mins')
              and ES_WAREHOUSE.PUBLIC.overlaps(ais.date_start::date, ais.date_end::date, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date - interval '180 days', convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date + interval '59 mins')
           )
          , rental_revenue_by_day as (
          --Calculate rental revenue by invoice data
            select distinct ds.day_date,
              convert_timezone('{{ _user_attributes['user_timezone'] }}', i.issue_date) as issue_date,
             -- use asset_id on line_item if available; otherwise use asset_id on initial rental
              coalesce(li.payload:rental.asset_id, r.asset_id) as asset_id,
              m.market_id,
              li.sub_total
            from ES_WAREHOUSE.PUBLIC.orders o
              join ES_WAREHOUSE.PUBLIC.rentals r on o.order_id = r.order_id
              join ES_WAREHOUSE_NZ.PUBLIC.invoices i on o.order_id = i.order_external_id
              join ES_WAREHOUSE_NZ.PUBLIC.line_items li on i.id = li.invoice_id
              join ES_WAREHOUSE.PUBLIC.markets m on o.market_id = m.market_id
              join day_series ds
                          on ds.day_date >= (convert_timezone('{{ _user_attributes['user_timezone'] }}', i.issue_date))
                                                 AND ds.day_date < coalesce((convert_timezone('{{ _user_attributes['user_timezone'] }}', dateadd(day, 1, i.issue_date))), '2099-12-31')
            where m.company_id = {{ _user_attributes['company_id'] }}
              and li.charge_id = 1
              and i.issue_date::date >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date - interval '180 days' and i.issue_date::date < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date + interval '1 day'
              and i.deleted_date is NULL
              and li.deleted_date is NULL
            )
            , tot_rental_revenue_by_day as (
             select day_date,
              asset_id,
              market_id,
              sum(sub_total) as rental_rev
             from rental_revenue_by_day rr
            group by day_date, asset_id, market_id
            )
            -- join non-summarized data together; do calculations in Looker
            select
              inv.day_date,
              inv.asset_id,
              initcap(inv.asset_type) as asset_type,
              inv.asset_class,
              inv.market_id as branch_id,
              inv.name as branch,
              inv.asset_inventory_status,
              inv.oec,
              coalesce(r.rental_rev,0) as rental_rev
            from all_asset_in_inventory_with_status inv
              left join tot_rental_revenue_by_day r on inv.day_date = r.day_date and inv.market_id = r.market_id and inv.asset_id = r.asset_id
          ;;
  }

  dimension: compound_primary_key {
    primary_key: yes
    type: string
    sql: concat(${day_date}, ${asset_id}) ;;
  }

  dimension: day_date {
    label: "Date"
    type: date
    sql: ${TABLE}."DAY_DATE" ;;
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
    drill_fields: [asset_class, oec, branch, asset_id, ]
  }

  measure: total_asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [asset_class, asset_inventory_status, oec, branch, asset_id]
  }

  measure: count_utilization {
    type: number
    sql: ${assets_considered_on_rent} / case when ${total_asset_count} = 0 then NULL else ${total_asset_count} end ;;
    value_format_name: percent_1
    drill_fields: [day_date, asset_class, asset_inventory_status, total_asset_count, branch, asset_id]
  }

  measure: tot_rental_rev_for_oec_assets {
    label: "Daily Rental Revenue"
    type: sum
    sql: CASE WHEN ${oec} = 0 then NULL ELSE ${rental_rev} END ;;
    value_format_name: usd_0
  }

  measure: financial_utilization {
    type: number
    sql:  ${tot_rental_rev_for_oec_assets} * 365 / CASE WHEN ${tot_asset_oec} = 0 THEN NULL ELSE ${tot_asset_oec} END ;;
    value_format_name: percent_1
    drill_fields: [day_date,
                  asset_class,
                  asset_class_customer_branch.make,
                  asset_class_customer_branch.model,
                  asset_inventory_status,
                  tot_rental_rev_for_oec_assets,
                  tot_asset_oec,
                  financial_utilization,
                  branch,
                  asset_id,]
  }

}
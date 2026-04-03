view: asset_utilization_180d {
derived_table: {
  sql:
       WITH day_series AS (
        select distinct date_trunc('day', series::date) as day_date
        from table(es_warehouse.public.generate_series(
                                dateadd(day, -179, convert_timezone('{{ _user_attributes['user_timezone'] }}', current_date))::timestamp_tz,
                                (convert_timezone('{{ _user_attributes['user_timezone'] }}', current_date))::timestamp_tz,
                                'day'))
      )
      , all_asset_in_inventory_with_status_by_day as (
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
            and ES_WAREHOUSE.PUBLIC.overlaps(sai.date_start, sai.date_end, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date - interval '179 days', convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date + interval '59 mins')
            and ES_WAREHOUSE.PUBLIC.overlaps(ais.date_start::date, ais.date_end::date, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date - interval '179 days', convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date + interval '59 mins')
    --and a.asset_id = 16078
        )
        , flag_on_rent_status as (
        select asset_id, asset_type, asset_class, market_id, name, oec, asset_inventory_status,
            case when asset_inventory_status = 'On Rent' then 1 else 0 end as on_rent
        from all_asset_in_inventory_with_status_by_day
        )
       , days_asset_on_rent as (
        select asset_id, asset_type, asset_class, market_id, name, oec, sum(on_rent) as days_asset_on_rent
        from flag_on_rent_status
        group by asset_id, asset_type, asset_class, market_id, name, oec
        )
        --Calculate rental revenue by invoice data
        , inv_rev_180d as (
        select distinct
         -- use asset_id on line_item if available; otherwise use asset_id on initial rental
          coalesce(li.payload:rental.asset_id, r.asset_id) as asset_id,
          m.market_id,
          li.sub_total
        from ES_WAREHOUSE.PUBLIC.orders o
          join ES_WAREHOUSE.PUBLIC.rentals r on o.order_id = r.order_id
          join ES_WAREHOUSE_NZ.PUBLIC.invoices i on o.order_id = i.order_external_id
          join ES_WAREHOUSE_NZ.PUBLIC.line_items li on i.id = li.invoice_id
          join ES_WAREHOUSE.PUBLIC.markets m on o.market_id = m.market_id
        where m.company_id = {{ _user_attributes['company_id'] }}
          and li.charge_id = 1
          and i.issue_date::date >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date - interval '179 days'
          and i.issue_date::date < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date
          and i.deleted_date is NULL
          and li.deleted_date is NULL
        )
        , tot_rev_180d as (
         select
          asset_id,
          market_id,
          sum(sub_total) as rental_rev
         from inv_rev_180d
        group by asset_id, market_id
        )
          -- join non-summarized data together; do calculations in Looker
          select
            inv.asset_id,
            initcap(inv.asset_type) as asset_type,
            inv.asset_class,
            inv.market_id as branch_id,
            inv.name as branch,
            inv.days_asset_on_rent,
            inv.oec,
            coalesce(r.rental_rev,0) as billed_rental_rev
          from days_asset_on_rent inv
            left join tot_rev_180d r on inv.market_id = r.market_id and inv.asset_id = r.asset_id
  ;;

  }
  dimension: asset_id {
    primary_key: yes
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

  dimension: asset_owner_id {
    type: number
    sql: ${TABLE}."ASSET_OWNER_ID" ;;
    value_format_name: id
  }

  dimension: days_asset_on_rent {
    type: number
    sql: ${TABLE}."DAYS_ASSET_ON_RENT" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: billed_rental_rev {
    label: "Billed Rental Revenue (180 Days)"
    type: number
    sql: ${TABLE}."BILLED_RENTAL_REV" ;;
  }



  measure: tot_asset_oec {
    label: "Total OEC"
    type: sum
    sql: ${oec};;
    value_format_name: usd_0
    drill_fields: [asset_class, oec, asset_id, branch]
  }

  measure: total_asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [asset_class, oec, asset_id, branch]
  }

  measure: count_utilization {
    label: "Unit Utilization (180 Days)"
    type: number
    sql: sum(${days_asset_on_rent}) / (${total_asset_count} * 180) ;;
    value_format_name: percent_1
    drill_fields: [asset_class, days_asset_on_rent, oec, asset_id, branch]
  }

  measure: tot_rental_rev_for_oec_assets {
    label: "Billed Rental Revenue (180 Days)"
    type: sum
    sql: CASE WHEN ${oec} = 0 then NULL ELSE ${billed_rental_rev} END ;;
    value_format_name: usd_0
  }

  measure: est_yearly_rental_rev_for_oec_assets {
    label: "Annualized Rental Revenue (Rolling 180 Days)"
    type: number
    sql: ${tot_rental_rev_for_oec_assets} * 365 / 180 ;;
    value_format_name: usd_0
  }

  measure: financial_utilization {
    label: "Financial Utilization (180 Days)"
    type: number
    sql:  ${tot_rental_rev_for_oec_assets} * 365 / 180 / CASE WHEN ${tot_asset_oec} = 0 THEN NULL ELSE ${tot_asset_oec} END ;;
    value_format_name: percent_1
    drill_fields:[asset_class,
                  asset_class_customer_branch.make,
                  asset_class_customer_branch.model,
                  tot_asset_oec,
                  tot_rental_rev_for_oec_assets,
                  est_yearly_rental_rev_for_oec_assets,
                  financial_utilization,
                  days_asset_on_rent,
                  branch,
                  asset_id]
  }

}
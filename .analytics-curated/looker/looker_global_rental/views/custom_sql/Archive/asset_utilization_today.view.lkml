view: asset_utilization_today {
  derived_table: {
    sql:
        with oec_today as (
      -- Assets in inventory and status at the start of the time period
      select distinct
        a.asset_id,
        aa.asset_type,
        coalesce(ec.name, 'No Asset Class') as asset_class,
        last_value(ais.asset_inventory_status) over (partition by a.asset_id order by ais.date_end) as asset_inventory_status_today, --ais.date_start, ais.date_end,
        m.market_id,
        m.name,
        a.company_id as asset_owner_id,
        coalesce(aa.oec,a.purchase_price,0) as oec_today
      from es_warehouse.public.assets_aggregate aa
            join ES_WAREHOUSE.SCD.scd_asset_inventory sai on aa.asset_id = sai.asset_id
            join ES_WAREHOUSE.PUBLIC.assets a on sai.asset_id = a.asset_id
            left join ES_WAREHOUSE.SCD.scd_asset_inventory_status ais on aa.asset_id = ais.asset_id
            left join ES_WAREHOUSE.PUBLIC.equipment_classes ec on a.equipment_class_id = ec.equipment_class_id
            join ES_WAREHOUSE.PUBLIC.markets m on coalesce(a.rental_branch_id, a.inventory_branch_id) = m.market_id
      where m.company_id = {{ _user_attributes['company_id'] }}
        -- removed deleted assets prior to the time period based on the SDC asset inventory table
       and ES_WAREHOUSE.PUBLIC.overlaps(sai.date_start, sai.date_end, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date + interval '23 hours' + interval '59 mins')
        -- queries correct asset_inventory_status based on dates
        and ES_WAREHOUSE.PUBLIC.overlaps(ais.date_start::date, ais.date_end::date, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date + interval '23 hours' + interval '59 mins')
      )
      --Calculate rental revenue by invoice data
      , inv_rev_today as (
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
        and i.issue_date::date >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date and i.issue_date::date < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date + interval '1 day'
        and i.deleted_date is NULL
        and li.deleted_date is NULL
      )
      , rev_today as (
       select
        asset_id,
        market_id,
        sum(sub_total) as rental_rev_today
       from inv_rev_today
      group by asset_id, market_id
      )
      -- join non-summarized data together; do calculations in Looker
      select
        o.asset_id,
        initcap(o.asset_type) as asset_type,
        o.asset_class,
        o.market_id as branch_id,
        o.name as branch,
        o.asset_owner_id,
        o.asset_inventory_status_today,
        o.oec_today,
        coalesce(r.rental_rev_today,0) as rental_rev_today
      from oec_today o
        left join rev_today r on o.market_id = r.market_id and o.asset_id = r.asset_id
        order by asset_id
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

    dimension: asset_inventory_status_today {
      type: string
      sql: ${TABLE}."ASSET_INVENTORY_STATUS_TODAY" ;;
    }

    dimension: oec_today {
      type: number
      sql: ${TABLE}."OEC_TODAY" ;;
    }

    dimension: rental_rev_today {
      type: number
      sql: ${TABLE}."RENTAL_REV_TODAY" ;;
    }



    measure: tot_asset_oec_today {
      label: "OEC (Today)"
      type: sum
      sql: ${oec_today};;
      value_format_name: usd_0
      drill_fields: [asset_class, oec_today, asset_id, branch]
    }

    measure: percent_tot_oec_today {
      type: percent_of_total
      sql: ${tot_asset_oec_today} ;;
      drill_fields: [asset_class, oec_today, asset_id, branch]
      value_format_name: decimal_1
    }

    measure: assets_considered_on_rent {
      type: count
      filters: [asset_inventory_status_today: "On Rent"]
    }

    measure: total_asset_count {
      type: count_distinct
      sql: ${asset_id} ;;
      drill_fields: [asset_class, oec_today, asset_id, branch]
    }

    measure: count_utilization {
      label: "Count Utilization (Today)"
      type: number
      sql: ${assets_considered_on_rent} / case when ${total_asset_count} = 0 then NULL else ${total_asset_count} end ;;
      value_format_name: percent_1
      drill_fields: [asset_class, asset_inventory_status_today, asset_id, branch]
    }

    measure: tot_rental_rev_for_oec_assets_today {
      label: "Rental Revenue (Today)"
      type: sum
      sql: CASE WHEN ${oec_today} = 0 then NULL ELSE ${rental_rev_today} END ;;
      value_format_name: usd_0
    }

    measure: est_yearly_rental_rev_for_oec_assets_today {
      label: "Annualized Rental Revenue"
      type: number
      sql: ${tot_rental_rev_for_oec_assets_today} * 365 ;;
      value_format_name: usd_0
    }

    measure: financial_utilization_today {
      label: "Financial Utilization (Today)"
      type: number
      sql:  ${tot_rental_rev_for_oec_assets_today} * 365 / CASE WHEN ${tot_asset_oec_today} = 0 THEN NULL ELSE ${tot_asset_oec_today} END ;;
      value_format_name: percent_1
      drill_fields: [asset_class,
                     asset_class_customer_branch.make,
                     asset_class_customer_branch.model,
                     tot_asset_oec_today,
                     tot_rental_rev_for_oec_assets_today,
                     est_yearly_rental_rev_for_oec_assets_today,
                     financial_utilization_today,
                     asset_inventory_status_today,
                     asset_id,
                     branch]
    }

  }
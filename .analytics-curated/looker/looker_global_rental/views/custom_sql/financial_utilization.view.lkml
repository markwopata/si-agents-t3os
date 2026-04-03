view: financial_utilization {
  derived_table: {
    sql:
     with asset_info as (
        select
            aa.asset_id,
            c.name as asset_owner,
            a.category_id,
            aa.category,
            a.equipment_class_id,
            a.asset_class,
            aa.make,
            aa.model,
            coalesce(aa.oec, a.purchase_price) as oec
        from
            es_warehouse.public.assets_aggregate aa
            left join es_warehouse.public.assets a on a.asset_id = aa.asset_id
            left join es_warehouse.public.companies c on a.company_id = c.company_id
            join ES_WAREHOUSE.PUBLIC.markets m on coalesce(a.rental_branch_id, a.inventory_branch_id) = m.market_id
        where
            m.company_id = {{ _user_attributes['company_id'] }}
        --    and a.asset_type_id = 1
            and a.asset_class is not null
            and coalesce(aa.oec, a.purchase_price) is not null
            and coalesce(aa.oec, a.purchase_price) <> 0
            and a.available_for_rent = true
    )
    ,asset_rev as (
        select
            li.payload:rental.asset_id as asset_id,
            sum(li.sub_total) as rental_rev
        from ES_WAREHOUSE.PUBLIC.orders o
            join ES_WAREHOUSE_NZ.PUBLIC.invoices i on o.order_id = i.order_external_id
            join ES_WAREHOUSE_NZ.PUBLIC.line_items li on i.id = li.invoice_id
            join ES_WAREHOUSE.PUBLIC.markets m on o.market_id = m.market_id
        where m.company_id = {{ _user_attributes['company_id'] }}
            and li.charge_id = 1
            and i.issue_date::date >= current_date - interval '31 days'
            and i.deleted_date is NULL
            and li.deleted_date is NULL
        group by
            1
    )
    select
        ai.asset_id,
        ai.category,
        ai.category_id,
        ai.asset_class as class,
        ai.asset_owner,
        ai.equipment_class_id,
        ai.make,
        ai.model,
        ai.oec,
        coalesce(ar.rental_rev,0) as rental_rev
    from
        asset_info ai
        left join asset_rev ar on ai.asset_id = ar.asset_id
        ;;
  }


    dimension: asset_id {
      primary_key: yes
      type: number
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension: category {
      type: string
      sql: ${TABLE}."CATEGORY" ;;
    }

    dimension: category_id {
      type: number
      sql: ${TABLE}."CATEGORY_ID" ;;
    }

    dimension: class {
      type: string
      sql: ${TABLE}."CLASS" ;;
    }

  dimension: asset_owner {
    type: string
    sql: ${TABLE}."ASSET_OWNER" ;;
  }


    dimension: equipment_class_id {
      type: number
      sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    }

    dimension: make {
      type: string
      sql: ${TABLE}."MAKE" ;;
    }

    dimension: market_id {
      type: number
      sql: ${TABLE}."MARKET_ID" ;;
    }

    dimension: model {
      type: string
      sql: ${TABLE}."MODEL" ;;
    }

    dimension: oec {
      type: number
      sql: ${TABLE}."OEC" ;;
    }

    dimension: rental_rev {
      type: number
      sql: ${TABLE}."RENTAL_REV" ;;
    }

    measure: rental_revenue {
      type: sum
      sql: ${rental_rev} ;;
    }

    measure: ttl_oec {
      type: sum
      sql: ${oec} ;;
    }

    measure: fin_util {
      type: number
      label: "Financial Utilization"
      value_format: "0.0%"
      sql: ${rental_revenue} * 365 / 31 / case when ${ttl_oec} = 0 then null else ${ttl_oec} end ;;
    }

    measure: count {
      type: count
      drill_fields: []
    }
  }

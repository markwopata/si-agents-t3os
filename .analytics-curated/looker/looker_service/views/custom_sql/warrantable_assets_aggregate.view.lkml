view: warrantable_assets_aggregate {
    derived_table: {
      sql:
       SELECT aa.*
        FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT da
          on da.asset_id = aa.asset_id
        join FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT dc
          on dc.company_key = da.asset_company_key
        left join ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS vpp
          on vpp.asset_id = aa.asset_id
            and vpp.end_date is null
        where vpp.asset_id is not null or (dc.company_is_equipmentshare_company and dc.company_is_reporting_company)
            ;;
    }

    dimension: asset_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."ASSET_ID" ;;
      primary_key: yes
    }

    dimension: asset_type {
      type: string
      sql: ${TABLE}."ASSET_TYPE" ;;
    }

    dimension: asset_type_id {
      type: number
      sql: ${TABLE}."ASSET_TYPE_ID" ;;
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

    dimension: missing_class {
      type: yesno
      sql: iff(${TABLE}."CLASS" is null, true, false) ;;
    }

    dimension: company_id {
      type: number
      sql: ${TABLE}."COMPANY_ID" ;;
    }

    dimension: custom_name {
      type: string
      sql: ${TABLE}."CUSTOM_NAME" ;;
    }

    dimension_group: date_created {
      type: time
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}."DATE_CREATED" ;;
    }

    dimension: equipment_class_id {
      type: number
      sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    }

    dimension_group: first_rental {
      type: time
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: CAST(${TABLE}."FIRST_RENTAL" AS TIMESTAMP_NTZ) ;;
    }

    dimension: inventory_branch_id {
      type: number
      sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
    }

    dimension: make {
      type: string
      sql: ${TABLE}."MAKE" ;;
    }

    dimension: equipment_make_id {
      type: number
      sql: ${TABLE}.equipment_make_id ;;
    }

    dimension: model {
      type: string
      sql: ${TABLE}."MODEL" ;;
    }

    dimension: make_model {
      type: string
      sql: CONCAT(${make}, ' ', ${model}) ;;
    }

    dimension: oec {
      type: number
      value_format_name: usd_0
      sql: ${TABLE}."OEC" ;;
    }

    dimension: missing_oec {
      type: yesno
      sql: iff(${TABLE}."OEC" is null, true, false) ;;
    }

    dimension: owner {
      type: string
      sql: ${TABLE}."OWNER" ;;
    }

    dimension_group: purchase {
      type: time
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: CAST(${TABLE}."PURCHASE_DATE" AS TIMESTAMP_NTZ) ;;
    }

    dimension: rental_branch_id {
      type: number
      sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
    }

    dimension: serial_number {
      type: string
      sql: ${TABLE}."SERIAL_NUMBER" ;;
    }

    dimension: vin {
      type: string
      sql: ${TABLE}."VIN" ;;
    }

    dimension: year {
      type: number
      value_format_name: id
      sql: ${TABLE}."YEAR" ;;
    }

    measure: count {
      type: count
      drill_fields: [
          asset_id
          , make
          , model
          , year
          , class
          , category
          ]
    }

    dimension: es_or_own {
      type: string
      sql: case
            when ${company_id} in (select company_id from FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT where company_is_equipmentshare_company and company_is_reporting_company) then 'ES Company'
            when ${company_id} in (
                select distinct aa.company_id
                from ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS vpp
                join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
                  on aa.asset_id = vpp.asset_id
                where vpp.end_date is not null) then 'OWN Company'
        Else 'External'
        End;;
  }

  }

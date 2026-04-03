view: asset_financial_history_tab {
  derived_table: {
    sql:
        select aa.asset_id,
            serial_number,
            financial_schedule_id as schedule_id,
            financed_amount,
            aph.finance_status,
            aa.oec as purchase_price,
            initcap(asset_type) as asset_type,
            aa.rental_branch_id,
            aa.inventory_branch_id,
            c.name as asset_owner,
            aph.purchase_history_id,
            aa.asset_class,
            aa.make,
            aa.model
        from ES_WAREHOUSE.PUBLIC.assets_aggregate aa
            left join ES_WAREHOUSE.PUBLIC.asset_purchase_history aph on aa.asset_id = aph.asset_id
            join ES_WAREHOUSE.PUBLIC.markets m on coalesce(aa.rental_branch_id, aa.inventory_branch_id) = m.market_id
            left join ES_WAREHOUSE.PUBLIC.companies c on aa.company_id = c.company_id
        where m.company_id = {{ _user_attributes['company_id'] }}
        ;;
  }

  dimension: asset_id {
    label: "Asset ID"
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID";;
    value_format_name: id
    html: <font color="blue"><u><a href="https://app.estrack.com/#/home/company-admin/finances/asset/{{ asset_id._filterable_value }}/detail/{{ purchase_history_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE";;
  }

  dimension: asset_owner {
    type: string
    sql: ${TABLE}."ASSET_OWNER";;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID";;
    value_format_name: id
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID";;
    value_format_name: id
  }

  dimension: schedule_id {
    type: number
    sql: ${TABLE}."SCHEDULE_ID";;
    value_format_name: id
  }

  dimension: serial_number {
    label: "Serial #"
    type: string
    sql: ${TABLE}."SERIAL_NUMBER";;
  }

  dimension: financed_amount {
    type: string
    sql: ${TABLE}."FINANCED_AMOUNT";;
  }

  dimension: finance_status {
    label: "Status"
    type: string
    sql: ${TABLE}."FINANCE_STATUS";;
  }

  dimension: purchase_price {
    type: number
    sql: ${TABLE}."PURCHASE_PRICE";;
    value_format_name: usd
  }

  dimension: purchase_history_id {
    type: number
    sql: ${TABLE}."PURCHASE_HISTORY_ID";;
    value_format_name: id
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS";;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE";;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL";;
  }

  dimension: make_model {
    label: "Make-Model"
    type: string
    sql: concat_ws('-', ${make}, ${model});;
  }

  }

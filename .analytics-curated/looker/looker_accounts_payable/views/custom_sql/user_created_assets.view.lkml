view: user_created_assets {
  derived_table: {
    sql: select
            convert_timezone('America/Chicago', ca.date_created) as added_date,
            parameters:asset_args.company_id::number as company_id,
            coalesce(ca.user_id, parameters:asset_args.user_id::number) as user_id,
            parameters:asset_id::number as asset_id,
            u.email_address,
            concat(u.first_name, '', u.last_name) as user_name,
            coalesce(a.OEC,aph.OEC) as oec,
            cpo.INVOICE_NUMBER,
            a.CUSTOM_NAME,
            c.NAME as owner_name
    from ES_WAREHOUSE.PUBLIC.command_audit ca
         left join es_warehouse.public.users u ON u.user_id = ca.user_id
         left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE a ON a.ASSET_ID = parameters:asset_id::number
         left join ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS cpo ON cpo.ASSET_ID = parameters:asset_id::number
         left join ES_WAREHOUSE.PUBLIC.COMPANIES c ON c.COMPANY_ID = a.COMPANY_ID
         left join ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY aph ON parameters:asset_id::number = aph.asset_id
    where convert_timezone('America/Chicago', ca.date_created) >= dateadd('year', -3, current_date)
          AND command = 'CreateAsset'
          AND ca.parameters:asset_args.company_id::number = 1854
      ;;
}
  dimension_group: added_date {
    type: time
    sql: ${TABLE}."ADDED_DATE" ;;
    html: {{ rendered_value | date: "%B %d, %Y" }};;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: asset_id {
    label: "Asset ID With T3 Link"
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER";;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: owner_name {
    type: string
    sql: ${TABLE}."OWNER_NAME" ;;
  }

}

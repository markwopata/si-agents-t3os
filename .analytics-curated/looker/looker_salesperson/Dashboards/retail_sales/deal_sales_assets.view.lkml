view: deal_sales_assets {
  derived_table: {
    sql:
     select
                 li.asset_id as asset_id,
                 aa.make as make,
                 aa.model as model,
                 i.company_id                as company_id,
                 li.line_item_type_id as line_item_type_id,
                 vli.line_item_type as line_item_type,
                 case
                    when aa.make ilike '%wacker%' and aa.model ilike any ('SW%','ST%') then 1
                    when aa.make ilike '%sany%'
                        and (aa.model ilike '%SY135%'
                              or aa.model ilike '%SY155%'
                              or aa.model ilike '%SY215%'
                              or aa.model ilike '%SY225%'
                              or aa.model ilike '%SY235%'
                              or aa.model ilike '%SY265%'
                              or aa.model ilike '%SY365%'
                              or aa.model ilike '%SY500%')
                    then 1
                    else 0
                    end as include_flag,
                 li.amount as sale_amount,
                 vli.gl_billing_approved_date as sales_date,
                 i.salesperson_user_id,
                 concat(u.first_name, ' ', u.last_name) sales_person_full_name,
                 case when (li.asset_id in (select afs.asset_id
                          from analytics.public.asset_financing_snapshots afs
                          where category = 'Contractor Owned OEC' and date = LAST_DAY(DATEADD(MONTH, -1, CURRENT_DATE)))
                          or i.company_id in (6954, 55524, 73584, 111143)) then 'Y' else 'N' end as OWN_SALE_FLAG,

      from es_warehouse.public.line_items li

      left join analytics.public.v_line_items vli
        on li.line_item_id = vli.line_item_id

      left join es_warehouse.public.invoices i
         on vli.invoice_id = i.invoice_id

      left join es_warehouse.public.users u
         on u.user_id = i.salesperson_user_id

      left join es_warehouse.public.assets_aggregate aa
         on li.asset_id = aa.asset_id

      where i.salesperson_user_id > 0
      and li.line_item_type_id = 81
      and include_flag = 1
    ;; }


  dimension: asset_id {
    type:  number
    primary_key: yes
    hidden:  no
    description: "Selected assets incentivized for used fleet sales. Contains Sany and Wacker Neuson models"
    sql:  ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: OEM {
    type:  string
    description: "Corresponds to es_warehouse.public.assets MAKE field. Original equipment manufacturer of asset"
    sql:  ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    description: "Corresponds to es_warehouse.public.assets Model field."
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: sales_date {
    type: date
    sql: ${TABLE}."SALES_DATE" ;;
  }

  dimension_group: sales_grouped{
    type: time
    sql: ${TABLE}."SALES_DATE" ;;
  }


  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
    value_format_name: id
  }

  dimension: line_item_type {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE" ;;
  }

  dimension: sale_amount {
    type: number
    sql: ${TABLE}."SALE_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
    value_format_name: id
  }

  dimension: sales_person_full_name {
    type: string
    sql: ${TABLE}."SALES_PERSON_FULL_NAME" ;;
  }

  dimension: own_sale_flag {
    type: string
    description: "flag stemming from analytics.public.asset_financing_snapshots: aggregates OWN-program sales based on category or company_id"
    sql: ${TABLE}."OWN_SALE_FLAG" ;;
  }

  dimension: subsidy {
    type: number
    sql: case when ${OEM} ilike '%wacker%' and ${model} ilike any ('SW%','ST%') then 10000
                when (${OEM} ilike '%SANY%' and ${model} ilike 'SY135%') then 11500
                when (${OEM} ilike '%SANY%' and ${model} ilike 'SY155%') then 11500
                when (${OEM} ilike '%SANY%' and ${model} ilike 'SY215%') then 17000
                when (${OEM} ilike '%SANY%' and ${model} ilike 'SY225%') then 17000
                when (${OEM} ilike '%SANY%' and ${model} ilike 'SY235%') then 17000
                when (${OEM} ilike '%SANY%' and ${model} ilike 'SY265%') then 23000
                when (${OEM} ilike '%SANY%' and ${model} ilike 'SY365%') then 28000
                when (${OEM} ilike '%SANY%' and ${model} ilike 'SY500%') then 35000
                else 0
           end;;
    value_format_name: usd
  }

  measure: total_sales {
    type:  sum
    sql: ${sale_amount};;
    value_format_name: usd_0
  }

  measure: avg_sales_price {
    type: average
    sql: ${sale_amount} ;;
    value_format_name: usd_0
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      asset_id,
      OEM,
      model,
      company_id,
      sales_date,
      line_item_type_id,
      line_item_type,
      sale_amount,
      salesperson_user_id,
      sales_person_full_name,
      own_sale_flag
    ]
  }



}

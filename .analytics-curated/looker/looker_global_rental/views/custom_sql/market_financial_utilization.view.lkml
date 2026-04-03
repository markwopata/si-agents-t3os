view: market_financial_utilization {
  derived_table: {
    sql: with oec_cte as (
      select
        a.asset_id, aa.asset_type,
        m.market_id,
        m.name,
        sum(coalesce(aa.oec,a.purchase_price)) as oec
      from es_warehouse.public.assets_aggregate aa
            left join es_warehouse.public.assets a on a.asset_id = aa.asset_id
            join ES_WAREHOUSE.PUBLIC.markets m on coalesce(a.rental_branch_id, a.inventory_branch_id) = m.market_id
      where m.company_id = '{{ _user_attributes['company_id'] }}'::numeric
        and a.deleted = false
        and a.available_for_rent = true
      group by
        a.asset_id,
        aa.asset_type,
        m.market_id,
        m.name
      ),
      --Calculate last 31 days rental revenue by market based on invoice date
      rev_cte as (
      select
        li.payload:rental.asset_id as asset_id,
        m.market_id,
        --x.region,
        --x.region_name,
        --x.district,
        sum(li.sub_total) as rental_rev
      from ES_WAREHOUSE.PUBLIC.orders o
        join ES_WAREHOUSE_NZ.PUBLIC.invoices i on o.order_id = i.order_external_id
        join ES_WAREHOUSE_NZ.PUBLIC.line_items li on i.id = li.invoice_id
        join ES_WAREHOUSE.PUBLIC.markets m on o.market_id = m.market_id
      --left join market_region_xwalk x on o.market_id = x.market_id
      where m.company_id = {{ _user_attributes['company_id'] }}
        and li.charge_id = 1
        and i.issue_date::date >= current_date - interval '31 days'
        and i.deleted_date is NULL
        and li.deleted_date is NULL
      group by
        li.payload:rental.asset_id,
        m.market_id
        )
     select o.market_id as marketid,
        r.market_id,
        o.asset_id, initcap(o.asset_type) as asset_type,
        o.name,
        o.oec,
        case when r.rental_rev is null then 0 else r.rental_rev end as rental_rev,
        case when r.rental_rev is null then 0 else r.rental_rev * 365 / 31 /o.oec end as fin_util,
        current_timestamp() as last_updated
      from oec_cte o
        join rev_cte r on o.market_id = r.market_id and o.asset_id = r.asset_id
      where o.oec is not null
      order by fin_util desc
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: compound_primary_key {
    primary_key: yes
    type: string
    sql: CONCAT(${TABLE}."MARKETID", ${TABLE}."ASSET_ID") ;;
  }

  dimension: marketid {
    type: number
    sql: ${TABLE}."MARKETID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: rental_rev {
    type: number
    sql: ${TABLE}."RENTAL_REV" ;;
  }

  dimension: fin_util {
    type: number
    sql: ${TABLE}."FIN_UTIL" ;;
  }

  # dimension: region {
  #   type: number
  #   sql: ${TABLE}."REGION" ;;
  # }

  # dimension: region_name {
  #   type: string
  #   sql: ${TABLE}."REGION_NAME" ;;
  # }

  # dimension: district {
  #   type: number
  #   sql: ${TABLE}."DISTRICT" ;;
  # }

  dimension_group: last_updated {
    type: time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}', ${TABLE}."LAST_UPDATED") ;;
  }

  measure: rental_revenue {
    type: sum
    sql: ${rental_rev} ;;
    value_format: "$#,##0"
  }

  measure: summarized_oec {
    type: sum
    sql: ${oec} ;;
    value_format: "$#,##0"
  }

  measure: financial_utilization {
    type: number
    sql: CASE WHEN ${rental_revenue} is null OR ${rental_revenue} = 0 THEN 0 ELSE ${rental_revenue}*365/31/${oec} END ;;
    # sql: ${fin_util} ;;
    value_format_name: percent_1
    drill_fields: [market_name,financial_utilization]
  }

  dimension: market_name {
    type: string
    sql: ${name} ;;
  }

  parameter: drop_down_selection {
    type: string
    allowed_value: { value: "Region"}
    allowed_value: { value: "District"}
    allowed_value: { value: "Market"}
  }

  # dimension: dynamic_location {
  #   label_from_parameter: drop_down_selection
  #   sql:
  #   {% if drop_down_selection._parameter_value == "'Region'" %}
  #     ${region_name}
  #   {% elsif drop_down_selection._parameter_value == "'District'" %}
  #     ${district}
  #   {% elsif drop_down_selection._parameter_value == "'Market'" %}
  #     ${market_name}
  #   {% else %}
  #     NULL
  #   {% endif %} ;;
  # }

  set: detail {
    fields: [
      marketid,
      name,
      oec,
      rental_rev,
      fin_util
    ]
  }
}
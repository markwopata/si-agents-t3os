view: market_financial_utilization {
  derived_table: {
    # datagroup_trigger: 6AM_update
    sql: with oec_cte as (
      select
        m.market_id,
        x.region,
        x.region_name,
        x.district,
        m.name,
        sum(coalesce(p.oec,p.purchase_price)) as oec
      from ES_WAREHOUSE.PUBLIC.assets a
      join ES_WAREHOUSE.PUBLIC.asset_purchase_history p
        on a.asset_id = p.asset_id
      join ES_WAREHOUSE.PUBLIC.markets m
        on a.rental_branch_id = m.market_id
      left join market_region_xwalk x
        on m.market_id = x.market_id
      where p.purchase_history_id in (select max(purchase_history_id) from ES_WAREHOUSE.PUBLIC.asset_purchase_history group by asset_id)
      and m.is_public_rsp = true
      and a.asset_type_id = 1
      and a.deleted = false
      and a.available_for_rent = true
      group by
        m.market_id,
        m.name,
        x.region,
        x.region_name,
        x.district
      ),
      --Calculate last 31 days rental revenue by market based on invoice date
      rev_cte as (
      select
        o.market_id,
        x.region,
        x.region_name,
        x.district,
        sum(li.amount) as rental_rev
      from ES_WAREHOUSE.PUBLIC.orders o
      join ES_WAREHOUSE.PUBLIC.invoices i on o.order_id = i.order_id
      join ANALYTICS.PUBLIC.v_line_items li on i.invoice_id = li.invoice_id
      left join market_region_xwalk x
        on o.market_id = x.market_id
      where li.line_item_type_id in (6, 8,108,109)
      and i.billing_approved = true
      and (convert_timezone('America/Chicago',i.invoice_date))::date >= (convert_timezone('America/Chicago',current_timestamp)::date - interval '31 days')
      group by
        o.market_id,
        x.region,
        x.region_name,
        x.district)
      select coalesce(o.market_id, r.market_id) as marketid, o.name, o.oec,
      case when
        r.rental_rev is null
        then 0
        else r.rental_rev
        end as rental_rev,
      case when
        r.rental_rev is null
        then 0
        when o.oec is null or o.oec = 0 then 0
        else r.rental_rev * 365 / 31 /o.oec
        end as fin_util,
       o.region, o.region_name, o.district, current_timestamp() as last_updated
      from oec_cte o
      full outer join rev_cte r
        on o.market_id = r.market_id
      --order by fin_util desc
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: marketid {
    primary_key: yes
    type: number
    sql: ${TABLE}."MARKETID" ;;
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

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: number
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension_group: last_updated {
    type: time
    sql: ${TABLE}."LAST_UPDATED" ;;
  }

  measure: Rental_Revenue {
    type: sum
    sql: ${rental_rev} ;;
    value_format: "$#,##0"
  }

  measure: OEC {
    type: sum
    sql: ${oec} ;;
    value_format: "$#,##0"
  }

  measure: Financial_Utilization {
    type: number
    sql: CASE WHEN ${Rental_Revenue} is null OR ${Rental_Revenue} = 0 THEN 0 ELSE ${Rental_Revenue}*365/31/NULLIF(${OEC},0) END ;;
    # sql: ${fin_util} ;;
    value_format: "0.0%"
    drill_fields: [market_name,Financial_Utilization]
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

  dimension: dynamic_location {
    label_from_parameter: drop_down_selection
    sql:
    {% if drop_down_selection._parameter_value == "'Region'" %}
      ${region_name}
    {% elsif drop_down_selection._parameter_value == "'District'" %}
      ${district}
    {% elsif drop_down_selection._parameter_value == "'Market'" %}
      ${market_name}
    {% else %}
      NULL
    {% endif %} ;;
  }

  set: detail {
    fields: [
      marketid,
      name,
      oec,
      rental_rev,
      fin_util,
      region,
      region_name,
      district
    ]
  }
}

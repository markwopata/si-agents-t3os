view: preferred_nonpreferred_vendor_comparison {
  label: "Vendor Type Spend"
  derived_table: {
    sql:
      select po.requesting_branch_id as market_id,
             po.purchase_order_number,
             v.vendorid as vendor_id,
             v.name as vendor_name,
             DATE_TRUNC('month', po.date_created)::DATE as month,
             COALESCE(vm.preferred, 'No') as preferred_vendor,
             SUM(poli.price_per_unit*poli.quantity) as vendor_spend
      from procurement.public.purchase_orders po
      join procurement.public.purchase_order_line_items poli on po.purchase_order_id = poli.purchase_order_id
      join ES_WAREHOUSE.INVENTORY.PARTS p on poli.item_id = p.item_id
      left join (select
                      v.name,
                      evs.entity_id,
                      v.vendorid
                 from ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS evs
                 left join analytics.intacct.vendor v
                      on evs.EXTERNAL_ERP_VENDOR_REF = v.vendorid
                 ) v on po.vendor_id = v.entity_id
      left join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING vm on v.vendorid = vm.vendorid
      where po.company_id = 1854
        and po.date_archived is null
        and poli.date_archived is null
        and amount_approved > 0
      group by 1,2,3,4,5,6
      order by market_id, vendor_spend desc
    ;;
  }


  # Dimensions
  dimension_group: spend {
    type: time
    timeframes: [date, week, month, month_name, quarter, year]
    datatype: date
    sql: ${TABLE}.month ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.market_id ;;
  }

  dimension: purchase_order_number {
    primary_key: yes
    type: string
    sql: ${TABLE}.purchase_order_number ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.vendor_id ;;
  }

  # Yes/No version for filtering and nicer UX
  dimension: is_preferred_vendor {
    type: yesno
    sql: ${TABLE}.preferred_vendor = 'Yes' ;;
  }

  dimension: vendor_status {
    type: string
    sql: case when ${is_preferred_vendor} = 'Yes' then 'Preferred' else 'Non-Preferred' end ;;
  }

  # Record counts
  measure: record_count {
    type: count
    # drill_fields: [purchase_order_number, vendor_id, market_id, month]
  }

  # Purchase Order counts
  measure: purchase_order_count {
    type: count_distinct
    sql: ${purchase_order_number} ;;
  }

  measure: total_vendor_spend {
    label: "Total Spend"
    type: sum
    value_format_name: usd
    sql: ${TABLE}.vendor_spend ;;
    drill_fields: [market_detail*]
  }

  measure: preferred_vendor_spend {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.vendor_spend ;;
    filters: [is_preferred_vendor: "yes"]
  }
  measure: non_preferred_vendor_spend {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.vendor_spend ;;
    filters: [is_preferred_vendor: "no"]
  }
  measure: preferred_vendor_spend_perc {
    label: "Preferred Spend Percentage of Total Spend"
    type: number
    value_format_name: percent_2
    html: {{total_vendor_spend._rendered_value}} Total |
          {{preferred_vendor_spend._rendered_value}} / {{preferred_vendor_spend_perc._rendered_value}} Preffered Vendor |
          {{non_preferred_vendor_spend._rendered_value}} / {{non_preferred_vendor_spend_perc.rendered_value}} Non-Preffered Vendor;;
    sql: ${preferred_vendor_spend} / ${total_vendor_spend} ;;
    drill_fields: [region_detail*]
  }
  measure: non_preferred_vendor_spend_perc {
    label: "Non-Preferred Spend Percentage of Total Spend"
    type: number
    value_format_name: percent_2
    html: {{total_vendor_spend._rendered_value}} Total |
          {{preferred_vendor_spend._rendered_value}} / {{preferred_vendor_spend_perc._rendered_value}} Preffered Vendor |
          {{non_preferred_vendor_spend._rendered_value}} / {{non_preferred_vendor_spend_perc.rendered_value}} Non-Preffered Vendor;;
    sql: ${non_preferred_vendor_spend} / ${total_vendor_spend} ;;
    # drill_fields: [market_region_xwalk.market_name, non_preferred_vendor_spend, total_vendor_spend]
    drill_fields: [region_detail*]
  }

dimension: vendor_name {
  sql: coalesce(top_vendor_mapping.mapped_vendor_name, top_vendor_mapping.vendor_name) ;;
}

dimension: po_vendor_name {
  label: "Vendor Name"
  type: string
  sql: ${TABLE}.vendor_name ;;
}

dimension: test {
  link: {url:"https://equipmentshare.looker.com/explore/service_parts/preferred_nonpreferred_vendor_comparison?qid=D21aZwpoSwgoruiBSVCVBO"}
}
  set: market_detail {
    fields: [
             market_region_xwalk.market_name,
             purchase_orders.purchase_order_id_with_link,
             purchase_orders.date_created,
             po_vendor_name,
             total_vendor_spend,
             purchase_orders.notes,
             is_preferred_vendor,
            ]
  }
  set: region_detail {
    fields: [
             market_region_xwalk.region_name,
             total_vendor_spend,
             vendor_status
            ]
  }
}

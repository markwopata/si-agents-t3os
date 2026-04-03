view: asset_info {
  derived_table: {
    sql: select a.asset_id
     , a.market_id
     , a.company_id
     , a.asset_class
     , a.asset_type_id
     , ast.name as asset_type
     , cat.name as category
     , case
        when r.asset_id is not null then 'Yes'
        else 'No'
       end as on_rent
     , m.name as branch
from assets a
left join asset_types ast on ast.asset_type_id = a.asset_type_id
left join categories cat on cat.category_id = a.category_id
left join rentals r on r.asset_id = a.asset_id and rental_status_id = 5
left join markets m on m.market_id = a.inventory_branch_id
where a.deleted = FALSE
AND a.company_id = {{ _user_attributes['company_id'] }}
      AND
      {% condition asset_type_filter %} ast.name {% endcondition %}
      AND
      {% condition category_filter %} cat.name {% endcondition %}
      AND
      {% condition branch_filter %} m.name {% endcondition %}
      AND
      {% condition asset_class_filter %} a.asset_class {% endcondition %}
 ;;
  }

  dimension: asset_id {
    # primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: market_id {
    # primary_key: yes
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: on_rent {
    type: string
    sql: ${TABLE}."ON_RENT" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  set: detail {
    fields: [
      asset_class,
      asset_type,
      category,
      on_rent,
      branch
    ]
  }

  dimension: link_to_utilization_report {
    group_label: "Link to T3 Report"
    label: "View Report"
    type: string
    sql: 'View Report Link' ;;
    html: <font color="#0063f3"><a href="https://staging-looker-analytics.estrack.com/dashboards/267?Asset+Type=Equipment&Category=&Asset=&Branch=&Asset+Class=" target="_blank">
      Click here to view the full Utilization Report</a></font>;;
  }

  measure: number_of_assets {
    type: count
    drill_fields: [detail*]
  }

  measure: on_rent_assets {
    type: count
    filters: [on_rent: "Yes"]
  }

  measure: market_utilization {
    type: number
    sql: ${on_rent_assets} / ${number_of_assets} * 100 ;;
  }

  filter: asset_type_filter {
  }

  filter: category_filter {
  }

  filter: branch_filter {
  }

  filter: asset_class_filter {
  }

}

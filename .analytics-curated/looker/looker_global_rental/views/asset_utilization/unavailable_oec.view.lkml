view: unavailable_oec {
  derived_table: {
    sql:
      with unavailable_oec_own as (
      select
          sum(case when askv.value in ('Pending Return','Make Ready','Needs Inspection', 'Soft Down','Hard Down') then aa.oec ELSE null END) as unavailable,
          sum(aa.oec) as unavailable_oec
      from
          --table(assetlist(101457::numeric)) alo
          table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
          join assets_aggregate aa on alo.asset_id = aa.asset_id
          join asset_status_key_values askv on askv.asset_id = alo.asset_id and name = 'asset_inventory_status'
          join assets a on a.asset_id = alo.asset_id
          left join asset_types ast on ast.asset_type_id = a.asset_type_id
          left join categories cat on cat.category_id = a.category_id
          left join markets m on m.market_id = a.inventory_branch_id
      where
        {% condition custom_name_filter %} a.custom_name {% endcondition %}
        AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
        AND {% condition category_filter %} cat.name {% endcondition %}
        AND {% condition branch_filter %} m.name {% endcondition %}
        AND {% condition asset_type_filter %} ast.name {% endcondition %}
      )
      ,unavailable_rental as (
      select
          sum(case when askv.value in ('Pending Return','Make Ready','Needs Inspection', 'Soft Down','Hard Down') then aa.oec ELSE null END) as unavailable,
          sum(aa.oec) as unavailable_oec
      from
          assets a
          join assets_aggregate aa on a.asset_id = aa.asset_id
          join asset_status_key_values askv on askv.asset_id = a.asset_id and askv.name = 'asset_inventory_status'
          left join asset_types ast on ast.asset_type_id = a.asset_type_id
          left join categories cat on cat.category_id = a.category_id
          join markets m on m.market_id = a.rental_branch_id
      where
        {% condition custom_name_filter %} a.custom_name {% endcondition %}
        AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
        AND {% condition category_filter %} cat.name {% endcondition %}
        AND {% condition branch_filter %} m.name {% endcondition %}
        AND {% condition asset_type_filter %} ast.name {% endcondition %}
        AND a.asset_id not in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
        AND a.deleted = FALSE
        AND m.company_id = {{ _user_attributes['company_id'] }}
      )
      select
        sum(uoo.unavailable + ur.unavailable)/
        sum(uoo.unavailable_oec + ur.unavailable_oec) as unavailable_oec
      from
        unavailable_oec_own uoo
        left join unavailable_rental ur on 1=1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: unavailable_oec {
    type: number
    sql: ${TABLE}."UNAVAILABLE_OEC" ;;
  }

  set: detail {
    fields: [unavailable_oec]
  }

  dimension: goal_text {
    type: string
    sql: 'Goal:' ;;
  }

  filter: custom_name_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.asset
  }

  filter: asset_class_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.asset_class
  }

  filter: branch_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.branch
  }

  filter: category_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.category
  }

  filter: asset_type_filter {
    # suggest_explore: asset_utilization_by_day
    # suggest_dimension: asset_utilization_by_day.asset_type
  }

  measure: total_unavilable_oec {
    type: sum
    sql: ${unavailable_oec}*100 ;;
    html: {{rendered_value}}% ;;
    value_format: "0.0\%"
  }
}

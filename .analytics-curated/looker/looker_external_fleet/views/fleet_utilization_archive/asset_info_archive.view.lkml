view: asset_info_archive {
  derived_table: {
    sql:
    with asset_info_pre as (select distinct
          alo.asset_id,
          'Owned' as ownership,
          a.custom_name as asset,
          --o.name as group_name,
          --org.group_name,
          a.asset_class,
          cat.name as category,
          case when m.company_id = {{ _user_attributes['company_id'] }}::numeric then m.name
          else '' end as branch,
          a.make,
          a.model,
          coalesce(a.serial_number,a.vin) as serial_number_vin,
          concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type,
          tm.tracker_grouping,
          a.driver_name
      from
          table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
          join assets a on alo.asset_id = a.asset_id
          left join asset_types ast on ast.asset_type_id = a.asset_type_id
          --listagg
          left join organization_asset_xref oax on alo.asset_id = oax.asset_id
          left join organizations o on oax.organization_id = o.organization_id
          left join categories cat on cat.category_id = a.category_id
          left join markets m on m.market_id = a.inventory_branch_id
          join es_warehouse.public.trackers_mapping tm on tm.asset_id = a.asset_id
          left join (select asset_id, value as last_location_timestamp from asset_status_key_values where name = 'last_location_timestamp') lc on lc.asset_id = alo.asset_id
      where
          {% condition custom_name_filter %} a.custom_name {% endcondition %}
          AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
          --AND {% condition groups_filter %} org.group_name {% endcondition %}
          AND {% condition groups_filter %} o.name {% endcondition %}
          AND {% condition ownership_filter %} ('Owned') {% endcondition %}
          AND {% condition category_filter %} cat.name {% endcondition %}
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND {% condition asset_type_filter %} ast.name {% endcondition %}
          AND {% condition tracker_grouping_filter %} tm.tracker_grouping {% endcondition %}
          AND tm.asset_id is not null
          AND
            {% if show_assets_no_contact_over_72_hrs._parameter_value == "'Yes'" %}
            1=1
            {% elsif show_assets_no_contact_over_72_hrs._parameter_value == "'No'" %}
            datediff(hours,lc.last_location_timestamp,current_timestamp) <= 72
            {% else %}
            1 = 1
            {% endif %}
      union
      select distinct
          alr.asset_id,
          'Rented' as ownership,
          a.custom_name as asset,
          --o.name as group_name,
          --org.group_name,
          a.asset_class,
          cat.name as category,
          case when m.company_id = {{ _user_attributes['company_id'] }}::numeric then m.name
          else '' end as branch,
          a.make,
          a.model,
          coalesce(a.serial_number,a.vin) as serial_number_vin,
          concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type,
          tm.tracker_grouping,
          a.driver_name
      from
          table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
          convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}),
          convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}),
          '{{ _user_attributes['user_timezone'] }}')) alr
          join assets a on alr.asset_id = a.asset_id
          left join asset_types ast on ast.asset_type_id = a.asset_type_id
          --listagg
          left join organization_asset_xref oax on alr.asset_id = oax.asset_id
          left join organizations o on oax.organization_id = o.organization_id
          left join categories cat on cat.category_id = a.category_id
          left join markets m on m.market_id = a.inventory_branch_id
          join es_warehouse.public.trackers_mapping tm on tm.asset_id = a.asset_id
          left join (select asset_id, value as last_location_timestamp from asset_status_key_values where name = 'last_location_timestamp') lc on lc.asset_id = alr.asset_id
      where
          {% condition custom_name_filter %} a.custom_name {% endcondition %}
          AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
          --AND {% condition groups_filter %} org.group_name {% endcondition %}
          AND {% condition groups_filter %} o.name {% endcondition %}
          AND {% condition ownership_filter %} ('Rented') {% endcondition %}
          AND {% condition category_filter %} cat.name {% endcondition %}
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND {% condition asset_type_filter %} ast.name {% endcondition %}
          AND {% condition tracker_grouping_filter %} tm.tracker_grouping {% endcondition %}
          AND tm.asset_id is not null
          AND
            {% if show_assets_no_contact_over_72_hrs._parameter_value == "'Yes'" %}
            (lc.last_location_timestamp is null or datediff(hours,lc.last_location_timestamp,current_timestamp) >= 72)
            {% elsif show_assets_no_contact_over_72_hrs._parameter_value == "'No'" %}
            datediff(hours,lc.last_location_timestamp,current_timestamp) <= 72
            {% else %}
            1 = 1
            {% endif %}
          AND a.company_id <> {{ _user_attributes['company_id'] }}
          )
          select * from asset_info_pre
          ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: ${asset_id} ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: ownership {
    type: string
    sql: ${TABLE}."OWNERSHIP" ;;
  }

  dimension: ownership_info {
    type: string
    sql: ${TABLE}."OWNERSHIP_INFO" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  # dimension: group_name {
  #   type: string
  #   sql: ${TABLE}."GROUP_NAME" ;;
  # }

  dimension: asset_class {
    label: "Class"
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: serial_number_vin {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_VIN" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: tracker_grouping {
    type: string
    sql: ${TABLE}."tracker_grouping" ;;
  }

  dimension: driver_name {
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }

  filter: custom_name_filter {
  }

  filter: groups_filter {
  }

  filter: ownership_filter {
  }

  filter: asset_class_filter {
  }

  filter: branch_filter {
  }

  filter: category_filter {
  }

  filter: asset_type_filter {
  }

  filter: tracker_grouping_filter {
  }

  filter: date_filter {
    type: date_time
  }

  parameter: show_assets_no_contact_over_72_hrs {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }
}

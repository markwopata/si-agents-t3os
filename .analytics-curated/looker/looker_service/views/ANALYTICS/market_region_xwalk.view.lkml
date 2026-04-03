view: market_region_xwalk {
  sql_table_name: "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK"
    ;;

  dimension: market_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format: "0"
  }
  dimension: market_filtered_yn {
    type: string
    sql:  {% if market_name._is_filtered %}
          'Market Selected'
          {% else %}
           'No'
          {% endif %} ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: area_code {
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: district_text {
    type: string
    sql: ${TABLE}."DISTRICT" ::text ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ::text ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: dealership_y_n {
    type: yesno
    sql: ${TABLE}."IS_DEALERSHIP" ;;
  }

  dimension: fulfillment_center_branch { ## branch using fc as of 10/2/2024
    type: yesno
    sql: iff(${market_id} in (100084,123279,121364,118741,118304,118928,119548,117658,116480,
    116676,115005,111298,113822,110132,107531,111615,113364,109003,99181,105670,104585,106045,
    104651,105742,104466,103038,103114,103045,102440,100031,49771,96278,84007,40686,40692,95857,
    90850,87996,78646,15963,20553,13576,85154,63125,44501,11007,80549,3,40685,24081,24080,61102,
    18703,7672,7670,45106,40698,16835,73712,40524,36764,15965,83551,80605,80607,6,8606,10525,61106,
    1,7329,74090,2,17140,10313,61872,11812,8135,55507,15969,15984,13575,8,43290,77191,36769,8631,
    17138,15977,23627,13574,4,18702,25923,33165,92194,92193,123054),true,false) ;;
  }

  dimension: fc_market_yn { #trying to switch to the live GS since marcia's team is still adding markets
    type: yesno
    sql: iff(${market_name} in(select distinct location from ANALYTICS.PARTS_INVENTORY.FULFILLMENT_CENTER_MARKETS),true,false) ;;
  }

  dimension: market_type_desc {
    type: string
    sql: case when ${market_type} = 'Pum' then 'Pump & Power'
              when ${market_type} = 'ITL' then 'Industrial'
              when ${market_type} = 'OPS' then 'Rental Yard'
              else ${market_type} --updated this from 'Other' since the types are changing
              END;;
  }

  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${market_region_xwalk.district} in ({{ _user_attributes['district'] }}) OR ${market_region_xwalk.region_name} in ({{ _user_attributes['region'] }}) OR ${market_region_xwalk.market_id} in ({{ _user_attributes['market_id'] }}) ;;
  }
  parameter: drop_down_selection {
    type: string
    allowed_value: {value: "Company"}
    allowed_value: {value: "Region"}
    allowed_value: {value: "District"}
    allowed_value: {value: "Market"}
  }

  dimension: dynamic_location {
    description: "Allows user to pick between Company, Region, District, and Market Axis."
    label_from_parameter: drop_down_selection
    sql:
    {% if drop_down_selection._parameter_value == "'Region'" %}
      ${region_name}
    {% elsif drop_down_selection._parameter_value == "'District'" %}
      ${district}
    {% elsif drop_down_selection._parameter_value == "'Market'" %}
      ${market_name}
    {% else %}
      null
    {% endif %} ;;
  }

##  This is here since technician level metrics should have the dynamic_location on that view as well... but this allows market level visuals
##  to continue to use the same drop down filter selection on dashboards without breaking them.
  parameter: drop_down_selection_with_tech {
    type: string
    # allowed_value: {value: "Company"}
    allowed_value: {value: "Region"}
    allowed_value: {value: "District"}
    allowed_value: {value: "Market"}
    allowed_value: {value: "Technician"}
  }
  dimension: dynamic_location_with_tech {
    description: "Allows user to pick between Company, Region, District, and Market Axis."
    label_from_parameter: drop_down_selection_with_tech
    sql:
    {% if drop_down_selection_with_tech._parameter_value == "'Region'" %}
      ${region_name}
    {% elsif drop_down_selection_with_tech._parameter_value == "'District'" %}
      ${district}
    {% elsif drop_down_selection_with_tech._parameter_value == "'Market'" %}
      ${market_name}
    {% elsif drop_down_selection_with_tech._parameter_value == "'Technician'" %}
      ${market_name}
    {% else %}
      NULL
    {% endif %} ;;
  }
  dimension: selected_hierarchy_dimension {
    description: "Changes axis based on user's applied filters."
    type: string
    link: {label:"Service Dashboard"
      url:"https://equipmentshare.looker.com/dashboards/49?Market=&Region=&District=&Market+Type="}
    sql:   {% if drop_down_selection._parameter_value == "'Region'" %}
      ${region_name}
    {% elsif drop_down_selection._parameter_value == "'District'" %}
      ${district}
    {% elsif drop_down_selection._parameter_value == "'Market'" %}
      ${market_name}
      {% elsif market_name._in_query %}
           ${market_name}
         {% elsif district._in_query %}
           ${market_name}
         {% elsif region_name._in_query %}
           ${district}
         {% else %}
           ${region_name}
         {% endif %};;
  }

  measure: count {
    type: count
    drill_fields: [market_name]
  }

  dimension: pilot_study_market {
    type: yesno
    sql: iff(${market_id} in (3, 15966, 74090, 10313, 11812, 8631), TRUE, FALSE) ;;
  }

  dimension: market_name_and_id {
    type: string
    sql: concat(${market_id},' - ',${market_name}) ;;
  }
}

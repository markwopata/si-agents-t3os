
view: markets_on_rent_asset_locations {
  derived_table: {
    sql:
with main_info as (
select distinct concat(salesperson_admin_name.FIRST_NAME, ' ', salesperson_admin_name.LAST_NAME, ' - ', salesperson_admin_name.USER_ID) as sales_rep,
       c.NAME as company,
       c.COMPANY_ID,
       r.ASSET_ID,
       r.RENTAL_ID,
       xw.REGION_NAME as region,--as asset_current_region,
       xw.DISTRICT, --as asset_current_district,
       ao.MARKET_ID, --as asset_current_rental_branch_id,
       xw.MARKET_NAME as market, --as asset_current_rental_branch_name,
       xw.MARKET_TYPE
from ES_WAREHOUSE.PUBLIC.ORDERS o
    JOIN ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS os on o.ORDER_ID = os.ORDER_ID
    JOIN ES_WAREHOUSE.PUBLIC.USERS AS salesperson_admin_name on salesperson_admin_name.USER_ID = os.USER_ID
    JOIN ES_WAREHOUSE.PUBLIC.RENTALS r on os.ORDER_ID = r.ORDER_ID
    JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_ASSIGNMENTS ea on r.RENTAL_ID = ea.RENTAL_ID
    JOIN ES_WAREHOUSE.PUBLIC.USERS AS customer_user on o.USER_ID = customer_user.USER_ID
    JOIN ES_WAREHOUSE.PUBLIC.COMPANIES c on customer_user.COMPANY_ID = c.COMPANY_ID
    JOIN ANALYTICS.BI_OPS.ASSET_OWNERSHIP ao on r.ASSET_ID = ao.ASSET_ID
    JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw on xw.MARKET_ID = ao.MARKET_ID
where r.RENTAL_STATUS_ID = 5
      AND os.SALESPERSON_TYPE_ID = 1
      AND current_date BETWEEN ea.start_date AND coalesce(ea.end_date,'2999-12-31')
      AND {% condition market_name_filter_mapping %} xw.MARKET_NAME {% endcondition %}
),

asset_tracker_location as (
select mi.asset_id,
       mi.market_id,
       st_y(to_geography(value)) as lat,
       st_x(to_geography(value)) as lon
from main_info mi
     JOIN ES_WAREHOUSE.PUBLIC.asset_status_key_values askv on askv.asset_id = mi.asset_id
     JOIN ES_WAREHOUSE.PUBLIC.assets a on mi.ASSET_ID = a.ASSET_ID
where   askv.name in ('location')
        AND a.TRACKER_ID is not null
        AND askv.UPDATED >= dateadd(hour,-72,current_date) --- removing anything with a last updated timestamp of more than 3 days ago.
),

asset_tracker_address_values AS (
select atl.ASSET_ID,
       askv2.NAME,
       askv2.VALUE
from asset_tracker_location atl
join ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES askv2 on atl.ASSET_ID = askv2.ASSET_ID -- inner join because it'll remove assets that have a timestamp in the location name greater than 72 hrs ago
where NAME IN ('street', 'city', 'state_id', 'zip_code')
),

asset_tracker_address_pivot as (
select *
from
    asset_tracker_address_values
PIVOT (
    MAX(VALUE)
    FOR NAME IN ('street', 'city', 'state_id', 'zip_code')
)
),

asset_tracker_final_address as (
select ASSET_ID,
       concat("'street'", ' ', "'city'", ', ', s.NAME, ' ', "'zip_code'") as full_address
from asset_tracker_address_pivot atap
     left join ES_WAREHOUSE.PUBLIC.STATES s on atap."'state_id'" = s.STATE_ID
),

asset_delivery_location as (
select mi.ASSET_ID,
       l.LATITUDE,
       l.LONGITUDE,
       concat(l.STREET_1, ' ', l.CITY, ', ', s.NAME, ' ', l.ZIP_CODE) as full_address,
       d.RENTAL_ID,
       d.COMPLETED_DATE
from main_info mi
left join ES_WAREHOUSE.PUBLIC.DELIVERIES d on mi.ASSET_ID = d.ASSET_ID and mi.RENTAL_ID = d.RENTAL_ID
left join ES_WAREHOUSE.PUBLIC.LOCATIONS l on d.LOCATION_ID = l.LOCATION_ID
left join ES_WAREHOUSE.PUBLIC.STATES s on l.STATE_ID = s.STATE_ID
where d.COMPLETED_DATE is not null
      AND d.ASSET_ID is not null
      AND d.COMPLETED_DATE >= dateadd(hour,-72,current_date)
)

select mi.*,
       coalesce(atl.lat,adl.LATITUDE) as lat,
       coalesce(atl.lon,adl.LONGITUDE) as lon,
       coalesce(atfa.full_address,adl.full_address,concat(coalesce(atl.lat,adl.LATITUDE),', ',coalesce(atl.lon,adl.LONGITUDE))) as full_address
from main_info mi
left join asset_tracker_location atl on mi.ASSET_ID = atl.ASSET_ID
left join asset_tracker_final_address atfa on mi.ASSET_ID = atfa.ASSET_ID
left join asset_delivery_location adl on mi.ASSET_ID = adl.ASSET_ID
where coalesce(atl.lat,adl.LATITUDE) is not null;;
  }

  measure: count {
    type: count
    drill_fields: [company_formatted, sales_rep_formatted, rental_id, asset_id, asset_address]
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: asset_address {
    label: "Asset's Last Known Address"
    type: string
    sql: ${TABLE}."FULL_ADDRESS" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
    primary_key: yes
  }

  dimension: lat {
    type: number
    sql: ${TABLE}."LAT" ;;
  }

  dimension: lon {
    type: number
    sql: ${TABLE}."LON" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company {
    label: "Customer"
    type: string
    sql: ${TABLE}."COMPANY" ;;
    html: {{rendered_value}}
          <br> ‎ </br>;;
  }

  dimension: company_formatted {
    description: "This format is being used for drill down purposes only"
    label: "Customer"
    type: string
    sql: ${TABLE}."COMPANY" ;;
    html: <font color="0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{filterable_value}}&Company+ID="target="_blank">{{rendered_value}}</a></font>
          <td>
          <span style="color: #8C8C8C;"> ID: {{customer_id._value}} </span>
          </td>;;
  }

  dimension: sales_rep {
    label: "Salesperson"
    type: string
    sql: ${TABLE}."SALES_REP" ;;
    html: {{rendered_value}}
          <br> ‎ </br>;;
  }

  dimension: sales_rep_formatted {
    description: "This format is being used for drill down purposes only"
    label: "Salesperson"
    type: string
    sql: ${TABLE}."SALES_REP" ;;
    html: <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/5?Sales+Rep={{rendered_value}}"target="_blank">{{rendered_value}}</a></font>;;
  }

  dimension: current_rental_location {
    label: "Rental Location"
    type: location
    sql_latitude:${lat} ;;
    sql_longitude:${lon} ;;
  }

  measure: actively_renting_customers {
    type: count_distinct
    sql: ${company} ;;
  }

  measure: count_of_assets {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [company,asset_id,sales_rep]
  }

  filter: market_name_filter_mapping {
    type: string
  }

  set: detail {
    fields: [
        region,
  district,
  market,
  market_type,
  asset_id,
  lat,
  lon
    ]
  }
}

view: underperforming_assets {

    derived_table: {
      sql:
      SELECT
       aa.ASSET_ID,
       COALESCE(aa.MAKE, '(unknown)') as MAKE,
       COALESCE(aa.MODEL, '(unknown)') as MODEL,
       aa.CUSTOM_NAME,
       aa.CATEGORY_ID,
       COALESCE(aa.CATEGORY, '(unknown)') as CATEGORY,
       COALESCE(pc.PARENT_CATEGORY,'(unknown)') as PARENT_CATEGORY,
       aa.EQUIPMENT_CLASS_ID,
       COALESCE(aa.CLASS, '(unknown)') as CLASS,
       COALESCE(aa.OEC, 0) as OEC,
       aa.RENTAL_BRANCH_ID,
       xw.REGION_NAME,
       xw.DISTRICT,
       xw.MARKET_NAME,
       xw.MARKET_TYPE,
       ea.MOST_RECENT_RENTAL::date as MOST_RECENT_RENTAL

      FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
      JOIN ES_WAREHOUSE.PUBLIC.ASSETS a
          ON aa.ASSET_ID = a.ASSET_ID
      LEFT JOIN (SELECT ASSET_ID,
                        max(coalesce(END_DATE, current_date)) as MOST_RECENT_RENTAL
                        FROM ES_WAREHOUSE.PUBLIC.EQUIPMENT_ASSIGNMENTS
                        GROUP BY ASSET_ID) ea
          ON ea.ASSET_ID = aa.ASSET_ID
      LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
          ON aa.RENTAL_BRANCH_ID = xw.MARKET_ID
      LEFT JOIN ANALYTICS.PUBLIC.PARENT_CATEGORY pc
          ON pc.EQUIPMENT_CLASS_ID = aa.EQUIPMENT_CLASS_ID
      JOIN ANALYTICS.BI_OPS.ASSET_OWNERSHIP ao
          on aa.ASSET_ID = ao.ASSET_ID

      WHERE (most_recent_rental < dateadd(day, -90, current_date) OR most_recent_rental is null)
      AND datediff(day, coalesce(aa.PURCHASE_DATE, a.DATE_CREATED), current_date) > 90
      AND aa.RENTAL_BRANCH_ID is not null
      AND ao.OWNERSHIP in ('ES', 'OWN')
      AND a.DELETED = 'false'
      AND {% condition region_filter_mapping %} xw.REGION_NAME {% endcondition %}
      AND {% condition district_filter_mapping %} xw.REGION_NAME {% endcondition %}
      AND {% condition market_filter_mapping %} xw.MARKET_NAME {% endcondition %}
      AND {% condition market_type_filter_mapping %} xw.MARKET_TYPE {% endcondition %};;
    }

    dimension: asset_id {
      primary_key: yes
      type: number
      sql: ${TABLE}."ASSET_ID" ;;
      value_format_name: id
      html: <font color="blue "><u><a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{ asset_id._value }}" target="_blank">{{ asset_id._value }}</a></font></u>;;
    }

    dimension: make {
      type: string
      sql: ${TABLE}."MAKE" ;;
    }

    dimension: model {
      type: string
      sql: ${TABLE}."MODEL" ;;
    }

    dimension: custom_name {
      type: string
      sql: ${TABLE}."CUSTOM_NAME" ;;
    }

    dimension: category_id {
      type: number
      sql: ${TABLE}."CATEGORY_ID" ;;
      value_format_name: id
    }

    dimension: category {
      type: string
      sql: ${TABLE}."CATEGORY" ;;
    }

    dimension: parent_category {
      type: string
      sql: ${TABLE}."PARENT_CATEGORY" ;;
    }

    dimension: equipment_class_id {
      type: number
      sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
      value_format_name: id
    }

    dimension: class {
      type: string
      sql: ${TABLE}."CLASS" ;;
    }

    dimension: oec {
      label: "OEC"
      type: number
      sql: ${TABLE}."OEC" ;;
    }

    dimension: rental_branch_id {
      type: number
      sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
      value_format_name: id
    }

    dimension: region {
      type: string
      sql: ${TABLE}."REGION_NAME" ;;
    }

    dimension: district {
      type: string
      sql: ${TABLE}."DISTRICT" ;;
    }

    dimension: market {
      type: string
      sql: ${TABLE}."MARKET_NAME" ;;
    }

    dimension: market_type {
      type: string
      sql: ${TABLE}."MARKET_TYPE" ;;
    }

    dimension: most_recent_rental {
      type: date
      sql: ${TABLE}."MOST_RECENT_RENTAL" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    measure: days_since_rental {
      type: number
      sql: DATEDIFF('days', ${most_recent_rental}, CURRENT_DATE());;
    }

    measure: count {
      type: count
    }

    filter: region_filter_mapping {
      type: string
    }

    filter: district_filter_mapping {
      type: string
    }

    filter: market_filter_mapping {
      type: string
    }

    filter: market_type_filter_mapping {
      type: string
    }
}

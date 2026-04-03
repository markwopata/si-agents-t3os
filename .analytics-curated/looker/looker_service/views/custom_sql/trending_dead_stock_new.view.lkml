view: trending_dead_stock_new {
  derived_table: {
    sql:
      WITH get_past_days AS (
        SELECT last_day(dateadd(month, -row_number() OVER (ORDER BY NULL), dateadd(day, 1, current_date)), 'month') AS generated_date
        FROM TABLE(generator(rowcount => 12))
      ), deadstock_monthly_snapshots AS (
        SELECT *
        FROM ANALYTICS.PARTS_INVENTORY.DEADSTOCK_SNAPSHOT ds
        JOIN get_past_days gd
          ON ds.SNAP_DATE = gd.generated_date
      ), enriched_snapshots AS (
        SELECT
            ds.SNAP_DATE,
            ds.PART_ID,
            p.PART_NUMBER,
            p.SEARCH AS DESCRIPTION,
            p.PROVIDER_ID,
            pr.NAME AS PROVIDER,
            ds.BIN_LOCATION,
            ds.SUB_PART_NUMBERS,
            ds.SUB_PART_IDS,
            ds.INVENTORY_LOCATION_ID,
            ds.LOCATION_NAME AS STORE_NAME,
            ds.MARKET_ID AS THE_MARKET_ID,
            ds.MARKET_NAME AS THE_MARKET_NAME,
            ds.DISTRICT_NAME AS THE_DISTRICT_NAME,
            ds.REGION_NAME AS THE_REGION_NAME,
            ds.OG_LAST_CONSUMED,
            ds.OVERALL_LAST_CONSUMED,
            ds.INV_HEALTH,
            ds.TOTAL_IN_INVENTORY,
            ds.AVG_COST,
            ds.INV_DOLLARS,
            ds.DEAD_STOCK,
            IFF(ds.INV_HEALTH = 'Dead', ds.DEAD_STOCK, 0) AS DEAD_DOLLARS
        FROM deadstock_monthly_snapshots ds

        JOIN ES_WAREHOUSE.INVENTORY.PARTS p ON ds.PART_ID = p.PART_ID
        LEFT JOIN ES_WAREHOUSE.INVENTORY.PROVIDERS pr ON p.PROVIDER_ID = pr.PROVIDER_ID
        LEFT JOIN ANALYTICS.PARTS_INVENTORY.TELEMATICS_PART_IDS tpi ON tpi.PART_ID = ds.PART_ID

        WHERE ds.TOTAL_IN_INVENTORY <> 0
          AND ds.LOCATION_NAME NOT ILIKE '%tele%'
          AND tpi.PART_ID IS NULL
          AND p.PROVIDER_ID NOT IN (SELECT api.PROVIDER_ID
                                    FROM ANALYTICS.PARTS_INVENTORY.ATTACHMENT_PROVIDER_IDS api)
      ), dead_stock_by_store_part AS (
        SELECT
            SNAP_DATE,
            INVENTORY_LOCATION_ID,
            STORE_NAME,
            THE_MARKET_ID,
            THE_MARKET_NAME,
            THE_DISTRICT_NAME,
            THE_REGION_NAME,
            PART_ID,
            PART_NUMBER,
            DESCRIPTION,
            PROVIDER_ID,
            SUM(DEAD_DOLLARS) AS DEAD_DOLLARS,
            SUM(INV_DOLLARS) AS INVENTORY_DOLLARS
        FROM enriched_snapshots
        WHERE INVENTORY_LOCATION_ID IN (SELECT il.INVENTORY_LOCATION_ID
                                        FROM ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
                                        JOIN ES_WAREHOUSE.PUBLIC.MARKETS m ON il.BRANCH_ID = m.MARKET_ID
                                        WHERE il.COMPANY_ID = 1854
                                          AND il.DATE_ARCHIVED IS NULL
                                          AND m.ACTIVE = TRUE)
        GROUP BY
            SNAP_DATE,
            INVENTORY_LOCATION_ID,
            STORE_NAME,
            THE_MARKET_ID,
            THE_MARKET_NAME,
            THE_DISTRICT_NAME,
            THE_REGION_NAME,
            PART_ID,
            PART_NUMBER,
            DESCRIPTION,
            PROVIDER_ID
      )
      SELECT
          SNAP_DATE,
          PROVIDER_ID,
          PART_ID,
          INVENTORY_LOCATION_ID,
          STORE_NAME,
          THE_MARKET_ID,
          THE_MARKET_NAME,
          THE_DISTRICT_NAME,
          THE_REGION_NAME,
          SUM(DEAD_DOLLARS) AS TOTAL_INVENTORY_DEAD_DOLLARS,
          SUM(INVENTORY_DOLLARS) AS TOTAL_INVENTORY_VALUE,
          TOTAL_INVENTORY_DEAD_DOLLARS / TOTAL_INVENTORY_VALUE AS DEAD_RATIO
      FROM dead_stock_by_store_part
      GROUP BY
          SNAP_DATE,
          PROVIDER_ID,
          PART_ID,
          INVENTORY_LOCATION_ID,
          STORE_NAME,
          THE_MARKET_ID,
          THE_MARKET_NAME,
          THE_DISTRICT_NAME,
          THE_REGION_NAME
      ORDER BY SNAP_DATE DESC;
      } ;;

      # (Keep all original dimensions and measures unchanged here...)
      # Use your existing LookML dimension and measure definitions below this line
    }

    dimension: snap_date {
      type: date_month
      sql: ${TABLE}."SNAP_DATE" ;;
    }

    dimension_group: snap_date_complete {
      type: time
      timeframes: [raw, date, week, month, month_name, quarter, year]
      convert_tz: no
      datatype: date
      sql: ${TABLE}."SNAP_DATE" ;;
    }

    dimension: provider_id {
      type: number
      value_format_name: id
      sql: ${TABLE}.provider_id ;;
    }

    dimension: part_id {
      type: number
      value_format_name: id
      sql: ${TABLE}.part_id ;;
    }

    dimension: inventory_location_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."INVENTORY_LOCATION_ID" ;;
    }

    dimension: store_name {
      type: string
      sql: ${TABLE}."STORE_NAME" ;;
    }

    dimension: market_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."THE_MARKET_ID" ;;
    }

    dimension: market_name {
      type: string
      sql: ${TABLE}."THE_MARKET_NAME" ;;
    }

    dimension: district_name {
      type: string
      sql: ${TABLE}."THE_DISTRICT_NAME" ;;
    }

    dimension: region_name {
      type: string
      sql: ${TABLE}."THE_REGION_NAME" ;;
    }

    dimension: dead_dollars {
      type: number
      value_format_name: usd_0
      sql: ${TABLE}."TOTAL_INVENTORY_DEAD_DOLLARS" ;;
    }

    measure: total_dead_dollars {
      type: sum
      value_format_name: usd_0
      sql: ${dead_dollars} ;;
    }

    dimension: inventory_value {
      type: number
      value_format_name: usd_0
      sql: ${TABLE}."TOTAL_INVENTORY_VALUE" ;;
    }

    dimension: dead_stock_ratio {
      type: number
      value_format_name: percent_1
      sql: ${TABLE}."DEAD_RATIO" ;;
    }
    measure: total_dead_stock_ratio_html {
      type: number
      html: {{total_dead_stock_ratio_html._rendered_value}} | {{total_dead_dollars._rendered_value}} of {{total_inventory_value._rendered_value}};;
      value_format_name: percent_1
      sql: ${total_dead_dollars}/${total_inventory_value} ;;
      drill_fields: [dead_stock_detail*]
    }
    measure: total_inventory_value {
      type: sum
      value_format_name: usd_0
      sql: ${inventory_value} ;;
      drill_fields: [dead_stock_detail*]
    }

    set: dead_stock_detail {
      fields: [
        market_region_xwalk.market_id,
        market_region_xwalk.market_name,
        inventory_value,
        total_dead_dollars,
        total_dead_stock_ratio
      ]
    }

    measure: total_dead_stock_ratio {
      type: number
      value_format_name: percent_0
      sql: ${total_dead_dollars} / ${total_inventory_value} ;;
    }

    dimension: selected_hierarchy_dimension {
      type: string
      # link: {label:"El ChuPARTcabra Dashboard"
      #   url:"https://equipmentshare.looker.com/dashboards/937?Market+Name=&District+Name=&Region+Name="}
      sql: {% if market_name._in_query %}
           ${store_name}
         {% elsif district_name._in_query %}
           ${market_name}
         {% elsif region_name._in_query %}
           ${district_name}
         {% else %}
           ${region_name}
         {% endif %};;
    }
    parameter: dead_stock_definition {
      type: string
      default_value: "180"
      allowed_value: {
        label: "3 Months"
        value: "90"
      }
      allowed_value: {
        label: "6 Months"
        value: "180"
      }
      allowed_value: {
        label: "9 Months"
        value: "270"
      }
      allowed_value: {
        label: "12 Months"
        value: "365"
      }
    }
  }

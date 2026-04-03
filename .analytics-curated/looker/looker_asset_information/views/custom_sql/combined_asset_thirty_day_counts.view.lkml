view: combined_asset_thirty_day_counts {
  derived_table: {
    sql: WITH parent_categories AS (select
        parent_category_id,
        name as parent_category_name,
        category_id,
        company_division_id
      from
        ES_WAREHOUSE.PUBLIC.categories c
      where
        -- active = true
        -- Commented out where active = true per Ryan Bernhard request Help Looker 02/24/25
        parent_category_id is null
 ),
        sub_categories AS (
          SELECT
            parent_category_id,
            name AS sub_category_name,
            category_id,
            company_division_id
          FROM ES_WAREHOUSE.PUBLIC.categories c
          WHERE parent_category_id IS NOT NULL
        ),
        mapped_classes AS (
  SELECT
    asset_id,
    asset_equipment_class_name
  FROM fleet_optimization.gold.dim_assets_fleet_opt
  WHERE asset_equipment_subcategory_name = 'Utility Vehicles'
)
        , asset_counts_cte AS (
      SELECT
      parent_categories.parent_category_name AS parent_category_name,
      sub_categories.sub_category_name        AS sub_category_name,
      COALESCE(mapped_classes.asset_equipment_class_name, equipment_classes."NAME") AS equipment_class_name,
      market_region_xwalk.REGION_NAME,
      market_region_xwalk.district,
      market_region_xwalk.MARKET_NAME,

      COUNT(DISTINCT assets_inventory."ASSET_ID") AS total_asset_count,



      COUNT(DISTINCT
      CASE
      WHEN COALESCE(scd_asset_inventory_status."ASSET_INVENTORY_STATUS", 'Unassigned')
      IN ('On Rent', 'On RPO')
      THEN CONCAT(scd_asset_inventory_status."ASSET_ID", scd_asset_inventory_status."CURRENT_FLAG")
      ELSE NULL
      END
      ) AS on_rent_asset_count,

      COUNT(DISTINCT
      CASE
      WHEN COALESCE(scd_asset_inventory_status."ASSET_INVENTORY_STATUS", 'Unassigned')
      IN ('Ready To Rent')
      THEN CONCAT(scd_asset_inventory_status."ASSET_ID", scd_asset_inventory_status."CURRENT_FLAG")
      ELSE NULL
      END
      ) AS ready_to_rent_asset_count,
      COUNT(DISTINCT
      CASE
      WHEN COALESCE(scd_asset_inventory_status."ASSET_INVENTORY_STATUS", 'Unassigned')
      IN ('Assigned')
      THEN CONCAT(scd_asset_inventory_status."ASSET_ID", scd_asset_inventory_status."CURRENT_FLAG")
      ELSE NULL
      END
      ) AS assigned_asset_count,
    COUNT(DISTINCT
      CASE
      WHEN COALESCE(scd_asset_inventory_status."ASSET_INVENTORY_STATUS", 'Unassigned')
      IN ('Pre-Delivered')
      THEN CONCAT(scd_asset_inventory_status."ASSET_ID", scd_asset_inventory_status."CURRENT_FLAG")
      ELSE NULL
      END
      ) AS predelivered_asset_count

      FROM "ES_WAREHOUSE"."PUBLIC"."ASSETS" AS assets_inventory

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" AS markets
      ON COALESCE(assets_inventory."RENTAL_BRANCH_ID", assets_inventory."INVENTORY_BRANCH_ID") = markets."MARKET_ID"

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."RENTALS" AS rentals
      ON assets_inventory."ASSET_ID" = rentals."ASSET_ID"

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_MODELS" AS equipment_models
      ON equipment_models."EQUIPMENT_MODEL_ID" = assets_inventory."EQUIPMENT_MODEL_ID"

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_CLASSES_MODELS_XREF" AS equipment_classes_models_xref
      ON equipment_models."EQUIPMENT_MODEL_ID" = equipment_classes_models_xref."EQUIPMENT_MODEL_ID"

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_CLASSES" AS equipment_classes
      ON equipment_classes_models_xref."EQUIPMENT_CLASS_ID" = equipment_classes."EQUIPMENT_CLASS_ID"

      LEFT JOIN sub_categories
      ON equipment_classes."CATEGORY_ID" = sub_categories."CATEGORY_ID"

      LEFT JOIN parent_categories ON (sub_categories."PARENT_CATEGORY_ID") = (parent_categories."CATEGORY_ID") AND (sub_categories."CATEGORY_ID") = (equipment_classes."CATEGORY_ID")


      LEFT JOIN "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK" AS market_region_xwalk
      ON markets."MARKET_ID" = market_region_xwalk."MARKET_ID"

      LEFT JOIN "ES_WAREHOUSE"."SCD"."SCD_ASSET_INVENTORY_STATUS" AS scd_asset_inventory_status
      ON scd_asset_inventory_status."ASSET_ID" = assets_inventory."ASSET_ID"

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" AS rental_market
      ON rental_market."MARKET_ID" = assets_inventory."RENTAL_BRANCH_ID"

      LEFT JOIN mapped_classes
  ON assets_inventory.asset_id = mapped_classes."ASSET_ID"

      WHERE
      assets_inventory."ASSET_TYPE_ID" = 1
      AND (
      NOT (assets_inventory."DELETED")
      OR assets_inventory."DELETED" IS NULL
      )
      AND (
      NOT (
      assets_inventory."COMPANY_ID" = 11606
      OR LEFT(assets_inventory."CUSTOM_NAME", 2) = 'RR'
      OR LEFT(assets_inventory."SERIAL_NUMBER", 2) = 'RR'
      )
      OR (
      (
      assets_inventory."COMPANY_ID" = 11606
      OR LEFT(assets_inventory."CUSTOM_NAME", 2) = 'RR'
      OR LEFT(assets_inventory."SERIAL_NUMBER", 2) = 'RR'
      ) IS NULL
      )
      )
      AND markets."COMPANY_ID" = 1854
      AND markets."IS_PUBLIC_RSP"
      AND scd_asset_inventory_status."CURRENT_FLAG" = 1
      AND rental_market."COMPANY_ID" = 1854
      AND (
      (
      assets_inventory."COMPANY_ID" <> 11606
      AND LEFT(assets_inventory."SERIAL_NUMBER", 2) <> 'RR'
      AND LEFT(assets_inventory."CUSTOM_NAME", 2) <> 'RR'
      )
      OR assets_inventory."SERIAL_NUMBER" IS NULL
      )
      AND COALESCE(scd_asset_inventory_status."ASSET_INVENTORY_STATUS", 'Unassigned') IS NOT NULL

      GROUP BY
      parent_categories.parent_category_name,
      sub_categories.sub_category_name,
      COALESCE(mapped_classes.asset_equipment_class_name, equipment_classes."NAME"),
      market_region_xwalk.REGION_NAME,
      market_region_xwalk.district,
      market_region_xwalk.MARKET_NAME
      )
      , thirty_days_from_now_count_cte AS (
      SELECT
      parent_categories.parent_category_name AS parent_category_name,
      sub_categories.sub_category_name        AS sub_category_name,
      COALESCE(mapped_classes.asset_equipment_class_name, equipment_classes."NAME") AS equipment_class_name,
      market_region_xwalk.REGION_NAME,
      market_region_xwalk.district,
      market_region_xwalk.MARKET_NAME,

      COUNT(DISTINCT assets."ASSET_ID") AS upcoming_30_day_asset_count,
      COUNT(DISTINCT rentals."RENTAL_ID") AS upcoming_30_day_rental_count,
      COUNT(
        DISTINCT
        CASE
            WHEN assets.asset_id IS NULL
            THEN rentals."RENTAL_ID"
        END
) AS no_assigned_asset_upcoming_30_day_rental_count,
COUNT(
        DISTINCT
        CASE
            WHEN assets.asset_id IS NOT NULL
            THEN rentals."RENTAL_ID"
        END
) AS assigned_asset_upcoming_30_day_rental_count


      FROM "ES_WAREHOUSE"."PUBLIC"."ORDERS" AS orders
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."ORDER_SALESPERSONS" AS order_salespersons
      ON orders."ORDER_ID" = order_salespersons."ORDER_ID"
      INNER JOIN "ES_WAREHOUSE"."PUBLIC"."RENTALS" AS rentals
      ON rentals."ORDER_ID" = orders."ORDER_ID"
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_ASSIGNMENTS" AS equipment_assignments
      ON equipment_assignments."RENTAL_ID" = rentals."RENTAL_ID"
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_CLASSES" AS equipment_classes
      ON rentals."EQUIPMENT_CLASS_ID" = equipment_classes."EQUIPMENT_CLASS_ID"
            LEFT JOIN sub_categories
      ON equipment_classes."CATEGORY_ID" = sub_categories."CATEGORY_ID"

      LEFT JOIN parent_categories ON (sub_categories."PARENT_CATEGORY_ID") = (parent_categories."CATEGORY_ID") AND (sub_categories."CATEGORY_ID") = (equipment_classes."CATEGORY_ID")
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."ASSETS" AS assets
      ON assets."ASSET_ID" = equipment_assignments."ASSET_ID"
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."DELIVERIES" AS deliveries
      ON deliveries."RENTAL_ID" = rentals."RENTAL_ID"
      INNER JOIN "ES_WAREHOUSE"."PUBLIC"."LOCATIONS" AS locations
      ON deliveries."LOCATION_ID" = locations."LOCATION_ID"
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."STATES" AS states
      ON states."STATE_ID" = locations."STATE_ID"
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" AS users
      ON COALESCE(order_salespersons."USER_ID", orders."SALESPERSON_USER_ID") = users."USER_ID"
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" AS markets
      ON markets."MARKET_ID" = orders."MARKET_ID"
      LEFT JOIN "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK" AS market_region_xwalk
      ON market_region_xwalk."MARKET_ID" = markets."MARKET_ID"
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" AS customer
      ON orders."USER_ID" = customer."USER_ID"
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."COMPANIES" AS companies
      ON customer."COMPANY_ID" = companies."COMPANY_ID"
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."PURCHASE_ORDERS" AS purchase_orders
      ON orders."PURCHASE_ORDER_ID" = purchase_orders."PURCHASE_ORDER_ID"
      LEFT JOIN "PUBLIC"."RENTAL_STATUSES" AS rental_statuses
      ON rentals."RENTAL_STATUS_ID" = rental_statuses."RENTAL_STATUS_ID"
      LEFT JOIN ES_WAREHOUSE.PUBLIC.categories categories
      ON equipment_classes."CATEGORY_ID" = categories."CATEGORY_ID"
      LEFT JOIN mapped_classes ON assets.asset_id = mapped_classes.asset_id


      WHERE
      rentals."START_DATE" >= DATEADD(day, 1, CURRENT_DATE)
      AND rentals."START_DATE" <  DATEADD(day, 30, DATEADD(day, 1, CURRENT_DATE))

      AND ( (locations."COMPANY_ID") <> 1854 OR locations."COMPANY_ID" IS NULL )
      AND (
      UPPER(rental_statuses."NAME") = UPPER('Pending')
      OR UPPER(rental_statuses."NAME") = UPPER('Draft')
      )
      AND (
      (
      (SUBSTR(TRIM(assets."SERIAL_NUMBER"), 1, 3) != 'RR-'
      AND SUBSTR(TRIM(assets."SERIAL_NUMBER"), 1, 2) != 'RR')
      OR assets."SERIAL_NUMBER" IS NULL
      )
      AND (
      (
      'collectors' = 'developer'
      OR (
      'salesperson' = 'developer'
      AND users."DELETED" = 'No'
      )
      )
      OR (
      market_region_xwalk."DISTRICT" IN ( '0' )
      OR market_region_xwalk."REGION_NAME" IN (
      'Midwest','Southeast','Pacific','Mountain West',
      'Southwest','Northeast','Industrial'
      )
      OR market_region_xwalk."MARKET_ID"::text IN ( '0' )
      )
      )
      )
      GROUP BY
      parent_categories.parent_category_name,
      sub_categories.sub_category_name,
      COALESCE(mapped_classes.asset_equipment_class_name, equipment_classes."NAME"),
      market_region_xwalk.REGION_NAME,
      market_region_xwalk.district,
      market_region_xwalk.MARKET_NAME
      ),

      base AS (
      SELECT
      /*— Subcategory & Class labels —*/
      CASE
      WHEN COALESCE(asset_counts.parent_category_name, thirty_days.parent_category_name) IS NULL
      THEN 'na'
      ELSE COALESCE(asset_counts.parent_category_name, thirty_days.parent_category_name)
      END AS parent_category,
      CASE
      WHEN COALESCE(asset_counts.sub_category_name, thirty_days.sub_category_name) IS NULL
      THEN 'na'
      ELSE COALESCE(asset_counts.sub_category_name, thirty_days.sub_category_name)
      END AS subcategory,

      CASE
      WHEN COALESCE(asset_counts.equipment_class_name, thirty_days.equipment_class_name) IS NULL
      THEN 'na'
      ELSE COALESCE(asset_counts.equipment_class_name, thirty_days.equipment_class_name)
      END AS class,

      CASE
      WHEN COALESCE(asset_counts.REGION_NAME, thirty_days.REGION_NAME) IS NULL
      THEN 'na'
      ELSE COALESCE(asset_counts.REGION_NAME, thirty_days.REGION_NAME)
      END AS region_name,

      CASE
      WHEN COALESCE(asset_counts.district, thirty_days.district) IS NULL
      THEN 'na'
      ELSE COALESCE(asset_counts.district, thirty_days.district)
      END AS district,

      CASE
      WHEN COALESCE(asset_counts.MARKET_NAME, thirty_days.MARKET_NAME) IS NULL
      THEN 'na'
      ELSE COALESCE(asset_counts.MARKET_NAME, thirty_days.MARKET_NAME)
      END AS market_name,

      /*— Raw counts (may be NULL if no “asset_counts” row for that combo) —*/
      asset_counts.on_rent_asset_count    AS on_rent_asset_count,
      asset_counts.ready_to_rent_asset_count AS ready_to_rent_asset_count,
      asset_counts.assigned_asset_count AS assigned_asset_count,
      asset_counts.predelivered_asset_count AS predelivered_asset_count,

      asset_counts.total_asset_count      AS total_asset_count,
      thirty_days.upcoming_30_day_asset_count,
      thirty_days.upcoming_30_day_rental_count,
      thirty_days.no_assigned_asset_upcoming_30_day_rental_count,
      thirty_days.assigned_asset_upcoming_30_day_rental_count,

      /*— Rename existing unit_utilization → market_class_unit_utilization —*/
      CASE
      WHEN asset_counts.total_asset_count = 0 THEN NULL
      ELSE asset_counts.on_rent_asset_count::FLOAT
      / asset_counts.total_asset_count
      END AS market_class_unit_utilization,

      CASE
          WHEN asset_counts.total_asset_count = 0 THEN NULL
          ELSE (
            asset_counts.on_rent_asset_count
            + asset_counts.assigned_asset_count
            + asset_counts.predelivered_asset_count
          )::FLOAT
            / asset_counts.total_asset_count
    END AS market_class_on_rent_assigned_predelivered_unit_utilization


      FROM asset_counts_cte AS asset_counts
      FULL OUTER JOIN thirty_days_from_now_count_cte AS thirty_days
      ON asset_counts.parent_category_name      = thirty_days.parent_category_name
      AND asset_counts.sub_category_name      = thirty_days.sub_category_name
      AND asset_counts.equipment_class_name   = thirty_days.equipment_class_name
      AND asset_counts.REGION_NAME            = thirty_days.REGION_NAME
      AND asset_counts.district               = thirty_days.district
      AND asset_counts.MARKET_NAME            = thirty_days.MARKET_NAME
      )

      SELECT
      parent_category,
      subcategory,
      class,
      region_name,
      district,
      market_name,
      on_rent_asset_count,
      ready_to_rent_asset_count,
      assigned_asset_count,
      predelivered_asset_count,
      total_asset_count,
      SUM(total_asset_count) OVER () AS summed_total_asset_count,
      upcoming_30_day_asset_count,
      upcoming_30_day_rental_count,
      no_assigned_asset_upcoming_30_day_rental_count,
      assigned_asset_upcoming_30_day_rental_count,
      market_class_unit_utilization,
      market_class_on_rent_assigned_predelivered_unit_utilization,

      /*— DISTRICT + CLASS level utilization —*/
      CASE
      WHEN SUM(COALESCE(total_asset_count,0))
      OVER (PARTITION BY parent_category, subcategory, class, district) = 0
      THEN NULL
      ELSE
      SUM(COALESCE(on_rent_asset_count,0))
      OVER (PARTITION BY parent_category, subcategory, class, district)::FLOAT
      /
      SUM(COALESCE(total_asset_count,0))
      OVER (PARTITION BY parent_category, subcategory, class, district)
      END
      AS district_class_unit_utilization,

        CASE
          WHEN
            SUM(
              COALESCE(total_asset_count, 0)
            ) OVER (PARTITION BY parent_category, subcategory, class, district)
            = 0
          THEN NULL
          ELSE
            (
              SUM(
                COALESCE(on_rent_asset_count,       0)
              + COALESCE(assigned_asset_count,      0)
              + COALESCE(predelivered_asset_count,  0)
              ) OVER (PARTITION BY parent_category, subcategory, class, district)
            )::FLOAT
            /
            SUM(
              COALESCE(total_asset_count, 0)
            ) OVER (PARTITION BY parent_category, subcategory, class, district)
        END AS district_class_on_rent_assigned_predelivered_unit_utilization,


      /*— REGION + CLASS level utilization —*/
      CASE
      WHEN SUM(COALESCE(total_asset_count,0))
      OVER (PARTITION BY parent_category, subcategory, class, region_name) = 0
      THEN NULL
      ELSE
      SUM(COALESCE(on_rent_asset_count,0))
      OVER (PARTITION BY parent_category, subcategory, class, region_name)::FLOAT
      /
      SUM(COALESCE(total_asset_count,0))
      OVER (PARTITION BY parent_category, subcategory, class, region_name)
      END
      AS region_class_unit_utilization,

      CASE
          WHEN
            SUM(
              COALESCE(total_asset_count, 0)
            ) OVER (PARTITION BY parent_category, subcategory, class, region_name)
            = 0
          THEN NULL
          ELSE
            (
              SUM(
                COALESCE(on_rent_asset_count,       0)
              + COALESCE(assigned_asset_count,      0)
              + COALESCE(predelivered_asset_count,  0)
              ) OVER (PARTITION BY parent_category, subcategory, class, region_name)
            )::FLOAT
            /
            SUM(
              COALESCE(total_asset_count, 0)
            ) OVER (PARTITION BY parent_category, subcategory, class, region_name)
        END AS region_class_on_rent_assigned_predelivered_unit_utilization,

      /*— OVERALL + CLASS level utilization —*/
      CASE
      WHEN SUM(COALESCE(total_asset_count,0))
      OVER (PARTITION BY parent_category, subcategory, class) = 0
      THEN NULL
      ELSE
      SUM(COALESCE(on_rent_asset_count,0))
      OVER (PARTITION BY parent_category, subcategory, class)::FLOAT
      /
      SUM(COALESCE(total_asset_count,0))
      OVER (PARTITION BY parent_category, subcategory, class)
      END
      AS overall_class_unit_utilization,
      CASE
          WHEN
            SUM(
              COALESCE(total_asset_count, 0)
            ) OVER (PARTITION BY parent_category, subcategory, class)
            = 0
          THEN NULL
          ELSE
            (
              SUM(
                COALESCE(on_rent_asset_count,       0)
              + COALESCE(assigned_asset_count,      0)
              + COALESCE(predelivered_asset_count,  0)
              ) OVER (PARTITION BY parent_category, subcategory, class)
            )::FLOAT
            /
            SUM(
              COALESCE(total_asset_count, 0)
            ) OVER (PARTITION BY parent_category, subcategory, class)
        END AS overall_class_on_rent_assigned_predelivered_unit_utilization,

      FROM base

      ;;
  }

  # Grouping keys:


  dimension: parent_category {
    type: string
    sql: ${TABLE}.parent_category ;;
  }


  dimension: subcategory {
    type: string
    sql: ${TABLE}.subcategory ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}.class ;;
  }

  dimension: class_clean {
    label: "Class (clean)"
    type: string
    sql:
    REGEXP_REPLACE(${TABLE}.class, '[,\'"]', '')
  ;;
  }


  dimension: region_name {
    type: string
    sql: ${TABLE}.region_name ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: composite_pk {
    type: string
    sql:
    CONCAT(
      ${parent_category}, '⎪',
      ${subcategory},   '⎪',
      ${class},'⎪',
      ${region_name},         '⎪',
      ${district},            '⎪',
      ${market_name}
    ) ;;
    primary_key: yes
    hidden: yes
    description: "Synthetic PK combining all grouping fields"
  }

  # Measures (counts/ratios):
  measure: on_rent_asset_count {
    type: sum
    sql: ${TABLE}.on_rent_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: ready_to_rent_asset_count {
    type: sum
    sql: ${TABLE}.ready_to_rent_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: unit_count {
    type: sum
    sql: ${TABLE}.total_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: summed_total_asset_count {
    type: average
    sql: ${TABLE}.summed_total_asset_count ;;
    value_format_name: "decimal_0"
  }


  measure: upcoming_30_day_asset_count {
    description: "Number of unique assets being rented out in the next 30 days. (The same asset can appear multiple times if it’s rented more than once.)"
    type: sum
    sql: ${TABLE}.upcoming_30_day_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: 30_day_reservations {
    description: "Number of distinct rentals taking place in the next 30 days."
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.region_name,
      thirty_day_reservations_detail.district,
      thirty_day_reservations_detail.market_name,
      thirty_day_reservations_detail.rental_start_date,
      thirty_day_reservations_detail.rental_end_date,
      thirty_day_reservations_detail.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_detail.class,
      thirty_day_reservations_detail.make_and_model,
      thirty_day_reservations_detail.jobsite_link,
      thirty_day_reservations_detail.location_nickname,
      thirty_day_reservations_detail.purchase_order_name,
      thirty_day_reservations_detail.formatted_price_per_day,
      thirty_day_reservations_detail.formatted_price_per_week,
      thirty_day_reservations_detail.formatted_price_per_month,
      thirty_day_reservations_detail.delivery_contact_name,
      thirty_day_reservations_detail.delivery_contact_phone_number,
      thirty_day_reservations_detail.delivery_charge,
      thirty_day_reservations_detail.job_description,
      thirty_day_reservations_detail.rental_status_name,
      thirty_day_reservations_detail.salespeople_full_names_with_id
    ]
  }

  measure: no_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with no assigned asset."
    type: sum
    sql: ${TABLE}.no_assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    drill_fields: [
      thirty_day_reservations_no_asset_id.rental_id,
      thirty_day_reservations_no_asset_id.asset_id,
      thirty_day_reservations_no_asset_id.region_name,
      thirty_day_reservations_no_asset_id.district,
      thirty_day_reservations_no_asset_id.market_name,
      thirty_day_reservations_no_asset_id.rental_start_date,
      thirty_day_reservations_no_asset_id.rental_end_date,
      thirty_day_reservations_no_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_no_asset_id.class,
      thirty_day_reservations_no_asset_id.make_and_model,
      thirty_day_reservations_no_asset_id.jobsite_link,
      thirty_day_reservations_no_asset_id.location_nickname,
      thirty_day_reservations_no_asset_id.purchase_order_name,
      thirty_day_reservations_no_asset_id.formatted_price_per_day,
      thirty_day_reservations_no_asset_id.formatted_price_per_week,
      thirty_day_reservations_no_asset_id.formatted_price_per_month,
      thirty_day_reservations_no_asset_id.delivery_contact_name,
      thirty_day_reservations_no_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_no_asset_id.delivery_charge,
      thirty_day_reservations_no_asset_id.job_description,
      thirty_day_reservations_no_asset_id.rental_status_name,
      thirty_day_reservations_no_asset_id.salespeople_full_names_with_id
    ]
  }

  measure: assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with an assigned asset."
    type: sum
    sql: ${TABLE}.assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    drill_fields: [
      thirty_day_reservations_asset_id.rental_id,
      thirty_day_reservations_asset_id.asset_id,
      thirty_day_reservations_asset_id.region_name,
      thirty_day_reservations_asset_id.district,
      thirty_day_reservations_asset_id.market_name,
      thirty_day_reservations_asset_id.rental_start_date,
      thirty_day_reservations_asset_id.rental_end_date,
      thirty_day_reservations_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_asset_id.class,
      thirty_day_reservations_asset_id.make_and_model,
      thirty_day_reservations_asset_id.jobsite_link,
      thirty_day_reservations_asset_id.location_nickname,
      thirty_day_reservations_asset_id.purchase_order_name,
      thirty_day_reservations_asset_id.formatted_price_per_day,
      thirty_day_reservations_asset_id.formatted_price_per_week,
      thirty_day_reservations_asset_id.formatted_price_per_month,
      thirty_day_reservations_asset_id.delivery_contact_name,
      thirty_day_reservations_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_asset_id.delivery_charge,
      thirty_day_reservations_asset_id.job_description,
      thirty_day_reservations_asset_id.rental_status_name,
      thirty_day_reservations_asset_id.salespeople_full_names_with_id
    ]
  }

  measure: market_class_on_rent_unit_utilization {
    type: average
    sql:  ${TABLE}.market_class_unit_utilization
      ;;
    value_format_name: "percent_2"
  }

  measure: market_class_on_rent_assigned_predelivered_unit_utilization {
    type: average
    sql:  ${TABLE}.market_class_on_rent_assigned_predelivered_unit_utilization
      ;;
    value_format_name: "percent_2"
  }

  measure: district_class_on_rent_unit_utilization {
    type: average
    sql:  ${TABLE}.district_class_unit_utilization
      ;;
    value_format_name: "percent_2"
  }

  measure: district_class_on_rent_assigned_predelivered_unit_utilization {
    type: average
    sql:  ${TABLE}.market_class_on_rent_assigned_predelivered_unit_utilization
      ;;
    value_format_name: "percent_2"
  }


  measure: region_class_on_rent_unit_utilization {
    type: average
    sql:  ${TABLE}.region_class_unit_utilization
      ;;
    value_format_name: "percent_2"
  }

  measure: region_class_on_rent_assigned_predelivered_unit_utilization {
    type: average
    sql:  ${TABLE}.region_class_on_rent_assigned_predelivered_unit_utilization
      ;;
    value_format_name: "percent_2"
  }

  measure: overall_class_on_rent_unit_utilization {
    type: average
    sql:  ${TABLE}.overall_class_unit_utilization
      ;;
    value_format_name: "percent_2"
  }

  measure: overall_class_on_rent_assigned_predelivered_unit_utilization {
    type: average
    sql:  ${TABLE}.overall_class_on_rent_assigned_predelivered_unit_utilization
      ;;
    value_format_name: "percent_2"
  }

  measure: industrial_unit_count {
    type: sum
    sql: ${TABLE}.total_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Industrial" ]
  }
  measure: industrial_on_rent_asset_count {
    type: sum
    sql: ${TABLE}.on_rent_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Industrial" ]
  }

  measure: industrial_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Industrial" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.region_name,
      thirty_day_reservations_detail.district,
      thirty_day_reservations_detail.market_name,
      thirty_day_reservations_detail.rental_start_date,
      thirty_day_reservations_detail.rental_end_date,
      thirty_day_reservations_detail.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_detail.class,
      thirty_day_reservations_detail.make_and_model,
      thirty_day_reservations_detail.jobsite_link,
      thirty_day_reservations_detail.location_nickname,
      thirty_day_reservations_detail.purchase_order_name,
      thirty_day_reservations_detail.formatted_price_per_day,
      thirty_day_reservations_detail.formatted_price_per_week,
      thirty_day_reservations_detail.formatted_price_per_month,
      thirty_day_reservations_detail.delivery_contact_name,
      thirty_day_reservations_detail.delivery_contact_phone_number,
      thirty_day_reservations_detail.delivery_charge,
      thirty_day_reservations_detail.job_description,
      thirty_day_reservations_detail.rental_status_name,
      thirty_day_reservations_detail.salespeople_full_names_with_id
    ]
  }

  measure: industrial_no_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with no assigned asset."
    type: sum
    sql: ${TABLE}.no_assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Industrial" ]
    drill_fields: [
      thirty_day_reservations_no_asset_id.rental_id,
      thirty_day_reservations_no_asset_id.asset_id,
      thirty_day_reservations_no_asset_id.region_name,
      thirty_day_reservations_no_asset_id.district,
      thirty_day_reservations_no_asset_id.market_name,
      thirty_day_reservations_no_asset_id.rental_start_date,
      thirty_day_reservations_no_asset_id.rental_end_date,
      thirty_day_reservations_no_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_no_asset_id.class,
      thirty_day_reservations_no_asset_id.make_and_model,
      thirty_day_reservations_no_asset_id.jobsite_link,
      thirty_day_reservations_no_asset_id.location_nickname,
      thirty_day_reservations_no_asset_id.purchase_order_name,
      thirty_day_reservations_no_asset_id.formatted_price_per_day,
      thirty_day_reservations_no_asset_id.formatted_price_per_week,
      thirty_day_reservations_no_asset_id.formatted_price_per_month,
      thirty_day_reservations_no_asset_id.delivery_contact_name,
      thirty_day_reservations_no_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_no_asset_id.delivery_charge,
      thirty_day_reservations_no_asset_id.job_description,
      thirty_day_reservations_no_asset_id.rental_status_name,
      thirty_day_reservations_no_asset_id.salespeople_full_names_with_id
    ]
  }

  measure: industrial_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with an assigned asset."
    type: sum
    sql: ${TABLE}.assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Industrial" ]
    drill_fields: [
      thirty_day_reservations_asset_id.rental_id,
      thirty_day_reservations_asset_id.asset_id,
      thirty_day_reservations_asset_id.region_name,
      thirty_day_reservations_asset_id.district,
      thirty_day_reservations_asset_id.market_name,
      thirty_day_reservations_asset_id.rental_start_date,
      thirty_day_reservations_asset_id.rental_end_date,
      thirty_day_reservations_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_asset_id.class,
      thirty_day_reservations_asset_id.make_and_model,
      thirty_day_reservations_asset_id.jobsite_link,
      thirty_day_reservations_asset_id.location_nickname,
      thirty_day_reservations_asset_id.purchase_order_name,
      thirty_day_reservations_asset_id.formatted_price_per_day,
      thirty_day_reservations_asset_id.formatted_price_per_week,
      thirty_day_reservations_asset_id.formatted_price_per_month,
      thirty_day_reservations_asset_id.delivery_contact_name,
      thirty_day_reservations_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_asset_id.delivery_charge,
      thirty_day_reservations_asset_id.job_description,
      thirty_day_reservations_asset_id.rental_status_name,
      thirty_day_reservations_asset_id.salespeople_full_names_with_id
    ]
  }


  measure: industrial_on_rent_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "Industrial" ]
  }

  measure: industrial_on_rent_assigned_predelivered_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_on_rent_assigned_predelivered_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "Industrial" ]
  }

  measure: midwest_unit_count {
    type: sum
    sql: ${TABLE}.total_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Midwest" ]
  }
  measure: midwest_on_rent_asset_count {
    type: sum
    sql: ${TABLE}.on_rent_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Midwest" ]
  }

  measure: midwest_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Midwest" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.region_name,
      thirty_day_reservations_detail.district,
      thirty_day_reservations_detail.market_name,
      thirty_day_reservations_detail.rental_start_date,
      thirty_day_reservations_detail.rental_end_date,
      thirty_day_reservations_detail.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_detail.class,
      thirty_day_reservations_detail.make_and_model,
      thirty_day_reservations_detail.jobsite_link,
      thirty_day_reservations_detail.location_nickname,
      thirty_day_reservations_detail.purchase_order_name,
      thirty_day_reservations_detail.formatted_price_per_day,
      thirty_day_reservations_detail.formatted_price_per_week,
      thirty_day_reservations_detail.formatted_price_per_month,
      thirty_day_reservations_detail.delivery_contact_name,
      thirty_day_reservations_detail.delivery_contact_phone_number,
      thirty_day_reservations_detail.delivery_charge,
      thirty_day_reservations_detail.job_description,
      thirty_day_reservations_detail.rental_status_name,
      thirty_day_reservations_detail.salespeople_full_names_with_id
    ]
  }

  measure: midwest_no_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with no assigned asset."
    type: sum
    sql: ${TABLE}.no_assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Midwest" ]
    drill_fields: [
      thirty_day_reservations_no_asset_id.rental_id,
      thirty_day_reservations_no_asset_id.asset_id,
      thirty_day_reservations_no_asset_id.region_name,
      thirty_day_reservations_no_asset_id.district,
      thirty_day_reservations_no_asset_id.market_name,
      thirty_day_reservations_no_asset_id.rental_start_date,
      thirty_day_reservations_no_asset_id.rental_end_date,
      thirty_day_reservations_no_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_no_asset_id.class,
      thirty_day_reservations_no_asset_id.make_and_model,
      thirty_day_reservations_no_asset_id.jobsite_link,
      thirty_day_reservations_no_asset_id.location_nickname,
      thirty_day_reservations_no_asset_id.purchase_order_name,
      thirty_day_reservations_no_asset_id.formatted_price_per_day,
      thirty_day_reservations_no_asset_id.formatted_price_per_week,
      thirty_day_reservations_no_asset_id.formatted_price_per_month,
      thirty_day_reservations_no_asset_id.delivery_contact_name,
      thirty_day_reservations_no_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_no_asset_id.delivery_charge,
      thirty_day_reservations_no_asset_id.job_description,
      thirty_day_reservations_no_asset_id.rental_status_name,
      thirty_day_reservations_no_asset_id.salespeople_full_names_with_id
    ]
  }

  measure: midwest_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with an assigned asset."
    type: sum
    sql: ${TABLE}.assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Midwest" ]
    drill_fields: [
      thirty_day_reservations_asset_id.rental_id,
      thirty_day_reservations_asset_id.asset_id,
      thirty_day_reservations_asset_id.region_name,
      thirty_day_reservations_asset_id.district,
      thirty_day_reservations_asset_id.market_name,
      thirty_day_reservations_asset_id.rental_start_date,
      thirty_day_reservations_asset_id.rental_end_date,
      thirty_day_reservations_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_asset_id.class,
      thirty_day_reservations_asset_id.make_and_model,
      thirty_day_reservations_asset_id.jobsite_link,
      thirty_day_reservations_asset_id.location_nickname,
      thirty_day_reservations_asset_id.purchase_order_name,
      thirty_day_reservations_asset_id.formatted_price_per_day,
      thirty_day_reservations_asset_id.formatted_price_per_week,
      thirty_day_reservations_asset_id.formatted_price_per_month,
      thirty_day_reservations_asset_id.delivery_contact_name,
      thirty_day_reservations_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_asset_id.delivery_charge,
      thirty_day_reservations_asset_id.job_description,
      thirty_day_reservations_asset_id.rental_status_name,
      thirty_day_reservations_asset_id.salespeople_full_names_with_id
    ]
  }


  measure: midwest_on_rent_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "Midwest" ]
  }

  measure: midwest_on_rent_assigned_predelivered_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_on_rent_assigned_predelivered_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "Midwest" ]
  }

  measure: mountain_west_unit_count {
    type: sum
    sql: ${TABLE}.total_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Mountain West" ]
  }

  measure: mountain_west_on_rent_asset_count {
    type: sum
    sql: ${TABLE}.on_rent_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Mountain West" ]
  }

  measure: mountain_west_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Mountain West" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.region_name,
      thirty_day_reservations_detail.district,
      thirty_day_reservations_detail.market_name,
      thirty_day_reservations_detail.rental_start_date,
      thirty_day_reservations_detail.rental_end_date,
      thirty_day_reservations_detail.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_detail.class,
      thirty_day_reservations_detail.make_and_model,
      thirty_day_reservations_detail.jobsite_link,
      thirty_day_reservations_detail.location_nickname,
      thirty_day_reservations_detail.purchase_order_name,
      thirty_day_reservations_detail.formatted_price_per_day,
      thirty_day_reservations_detail.formatted_price_per_week,
      thirty_day_reservations_detail.formatted_price_per_month,
      thirty_day_reservations_detail.delivery_contact_name,
      thirty_day_reservations_detail.delivery_contact_phone_number,
      thirty_day_reservations_detail.delivery_charge,
      thirty_day_reservations_detail.job_description,
      thirty_day_reservations_detail.rental_status_name,
      thirty_day_reservations_detail.salespeople_full_names_with_id
    ]
  }

  measure: mountain_west_no_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with no assigned asset."
    type: sum
    sql: ${TABLE}.no_assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Mountain West" ]
    drill_fields: [
      thirty_day_reservations_no_asset_id.rental_id,
      thirty_day_reservations_no_asset_id.asset_id,
      thirty_day_reservations_no_asset_id.region_name,
      thirty_day_reservations_no_asset_id.district,
      thirty_day_reservations_no_asset_id.market_name,
      thirty_day_reservations_no_asset_id.rental_start_date,
      thirty_day_reservations_no_asset_id.rental_end_date,
      thirty_day_reservations_no_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_no_asset_id.class,
      thirty_day_reservations_no_asset_id.make_and_model,
      thirty_day_reservations_no_asset_id.jobsite_link,
      thirty_day_reservations_no_asset_id.location_nickname,
      thirty_day_reservations_no_asset_id.purchase_order_name,
      thirty_day_reservations_no_asset_id.formatted_price_per_day,
      thirty_day_reservations_no_asset_id.formatted_price_per_week,
      thirty_day_reservations_no_asset_id.formatted_price_per_month,
      thirty_day_reservations_no_asset_id.delivery_contact_name,
      thirty_day_reservations_no_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_no_asset_id.delivery_charge,
      thirty_day_reservations_no_asset_id.job_description,
      thirty_day_reservations_no_asset_id.rental_status_name,
      thirty_day_reservations_no_asset_id.salespeople_full_names_with_id
    ]
  }

  measure: mountain_west_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with an assigned asset."
    type: sum
    sql: ${TABLE}.assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Mountain West" ]
    drill_fields: [
      thirty_day_reservations_asset_id.rental_id,
      thirty_day_reservations_asset_id.asset_id,
      thirty_day_reservations_asset_id.region_name,
      thirty_day_reservations_asset_id.district,
      thirty_day_reservations_asset_id.market_name,
      thirty_day_reservations_asset_id.rental_start_date,
      thirty_day_reservations_asset_id.rental_end_date,
      thirty_day_reservations_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_asset_id.class,
      thirty_day_reservations_asset_id.make_and_model,
      thirty_day_reservations_asset_id.jobsite_link,
      thirty_day_reservations_asset_id.location_nickname,
      thirty_day_reservations_asset_id.purchase_order_name,
      thirty_day_reservations_asset_id.formatted_price_per_day,
      thirty_day_reservations_asset_id.formatted_price_per_week,
      thirty_day_reservations_asset_id.formatted_price_per_month,
      thirty_day_reservations_asset_id.delivery_contact_name,
      thirty_day_reservations_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_asset_id.delivery_charge,
      thirty_day_reservations_asset_id.job_description,
      thirty_day_reservations_asset_id.rental_status_name,
      thirty_day_reservations_asset_id.salespeople_full_names_with_id
    ]
  }

  measure: mountain_west_on_rent_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "Mountain West" ]
  }

  measure: mountain_west_on_rent_assigned_predelivered_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_on_rent_assigned_predelivered_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "Mountain West" ]
  }

  measure: northeast_unit_count {
    type: sum
    sql: ${TABLE}.total_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Northeast" ]
  }
  measure: northeast_on_rent_asset_count {
    type: sum
    sql: ${TABLE}.on_rent_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Northeast" ]
  }

  measure: northeast_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Northeast" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.region_name,
      thirty_day_reservations_detail.district,
      thirty_day_reservations_detail.market_name,
      thirty_day_reservations_detail.rental_start_date,
      thirty_day_reservations_detail.rental_end_date,
      thirty_day_reservations_detail.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_detail.class,
      thirty_day_reservations_detail.make_and_model,
      thirty_day_reservations_detail.jobsite_link,
      thirty_day_reservations_detail.location_nickname,
      thirty_day_reservations_detail.purchase_order_name,
      thirty_day_reservations_detail.formatted_price_per_day,
      thirty_day_reservations_detail.formatted_price_per_week,
      thirty_day_reservations_detail.formatted_price_per_month,
      thirty_day_reservations_detail.delivery_contact_name,
      thirty_day_reservations_detail.delivery_contact_phone_number,
      thirty_day_reservations_detail.delivery_charge,
      thirty_day_reservations_detail.job_description,
      thirty_day_reservations_detail.rental_status_name,
      thirty_day_reservations_detail.salespeople_full_names_with_id
    ]
  }

  measure: northeast_no_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with no assigned asset."
    type: sum
    sql: ${TABLE}.no_assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Northeast" ]
    drill_fields: [
      thirty_day_reservations_no_asset_id.rental_id,
      thirty_day_reservations_no_asset_id.asset_id,
      thirty_day_reservations_no_asset_id.region_name,
      thirty_day_reservations_no_asset_id.district,
      thirty_day_reservations_no_asset_id.market_name,
      thirty_day_reservations_no_asset_id.rental_start_date,
      thirty_day_reservations_no_asset_id.rental_end_date,
      thirty_day_reservations_no_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_no_asset_id.class,
      thirty_day_reservations_no_asset_id.make_and_model,
      thirty_day_reservations_no_asset_id.jobsite_link,
      thirty_day_reservations_no_asset_id.location_nickname,
      thirty_day_reservations_no_asset_id.purchase_order_name,
      thirty_day_reservations_no_asset_id.formatted_price_per_day,
      thirty_day_reservations_no_asset_id.formatted_price_per_week,
      thirty_day_reservations_no_asset_id.formatted_price_per_month,
      thirty_day_reservations_no_asset_id.delivery_contact_name,
      thirty_day_reservations_no_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_no_asset_id.delivery_charge,
      thirty_day_reservations_no_asset_id.job_description,
      thirty_day_reservations_no_asset_id.rental_status_name,
      thirty_day_reservations_no_asset_id.salespeople_full_names_with_id
    ]
  }

  measure: northeast_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with an assigned asset."
    type: sum
    sql: ${TABLE}.assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Northeast" ]
    drill_fields: [
      thirty_day_reservations_asset_id.rental_id,
      thirty_day_reservations_asset_id.asset_id,
      thirty_day_reservations_asset_id.region_name,
      thirty_day_reservations_asset_id.district,
      thirty_day_reservations_asset_id.market_name,
      thirty_day_reservations_asset_id.rental_start_date,
      thirty_day_reservations_asset_id.rental_end_date,
      thirty_day_reservations_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_asset_id.class,
      thirty_day_reservations_asset_id.make_and_model,
      thirty_day_reservations_asset_id.jobsite_link,
      thirty_day_reservations_asset_id.location_nickname,
      thirty_day_reservations_asset_id.purchase_order_name,
      thirty_day_reservations_asset_id.formatted_price_per_day,
      thirty_day_reservations_asset_id.formatted_price_per_week,
      thirty_day_reservations_asset_id.formatted_price_per_month,
      thirty_day_reservations_asset_id.delivery_contact_name,
      thirty_day_reservations_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_asset_id.delivery_charge,
      thirty_day_reservations_asset_id.job_description,
      thirty_day_reservations_asset_id.rental_status_name,
      thirty_day_reservations_asset_id.salespeople_full_names_with_id
    ]
  }

  measure: northeast_on_rent_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "Northeast" ]
  }

  measure: northeast_on_rent_assigned_predelivered_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_on_rent_assigned_predelivered_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "Northeast" ]
  }

  measure: pacific_unit_count {
    type: sum
    sql: ${TABLE}.total_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Pacific" ]
  }
  measure: pacific_on_rent_asset_count {
    type: sum
    sql: ${TABLE}.on_rent_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Pacific" ]
  }

  measure: pacific_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Pacific" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.region_name,
      thirty_day_reservations_detail.district,
      thirty_day_reservations_detail.market_name,
      thirty_day_reservations_detail.rental_start_date,
      thirty_day_reservations_detail.rental_end_date,
      thirty_day_reservations_detail.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_detail.class,
      thirty_day_reservations_detail.make_and_model,
      thirty_day_reservations_detail.jobsite_link,
      thirty_day_reservations_detail.location_nickname,
      thirty_day_reservations_detail.purchase_order_name,
      thirty_day_reservations_detail.formatted_price_per_day,
      thirty_day_reservations_detail.formatted_price_per_week,
      thirty_day_reservations_detail.formatted_price_per_month,
      thirty_day_reservations_detail.delivery_contact_name,
      thirty_day_reservations_detail.delivery_contact_phone_number,
      thirty_day_reservations_detail.delivery_charge,
      thirty_day_reservations_detail.job_description,
      thirty_day_reservations_detail.rental_status_name,
      thirty_day_reservations_detail.salespeople_full_names_with_id
    ]
  }

  measure: pacific_no_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with no assigned asset."
    type: sum
    sql: ${TABLE}.no_assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Pacific" ]
    drill_fields: [
      thirty_day_reservations_no_asset_id.rental_id,
      thirty_day_reservations_no_asset_id.asset_id,
      thirty_day_reservations_no_asset_id.region_name,
      thirty_day_reservations_no_asset_id.district,
      thirty_day_reservations_no_asset_id.market_name,
      thirty_day_reservations_no_asset_id.rental_start_date,
      thirty_day_reservations_no_asset_id.rental_end_date,
      thirty_day_reservations_no_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_no_asset_id.class,
      thirty_day_reservations_no_asset_id.make_and_model,
      thirty_day_reservations_no_asset_id.jobsite_link,
      thirty_day_reservations_no_asset_id.location_nickname,
      thirty_day_reservations_no_asset_id.purchase_order_name,
      thirty_day_reservations_no_asset_id.formatted_price_per_day,
      thirty_day_reservations_no_asset_id.formatted_price_per_week,
      thirty_day_reservations_no_asset_id.formatted_price_per_month,
      thirty_day_reservations_no_asset_id.delivery_contact_name,
      thirty_day_reservations_no_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_no_asset_id.delivery_charge,
      thirty_day_reservations_no_asset_id.job_description,
      thirty_day_reservations_no_asset_id.rental_status_name,
      thirty_day_reservations_no_asset_id.salespeople_full_names_with_id
    ]
  }

  measure: pacific_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with an assigned asset."
    type: sum
    sql: ${TABLE}.assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Pacific" ]
    drill_fields: [
      thirty_day_reservations_asset_id.rental_id,
      thirty_day_reservations_asset_id.asset_id,
      thirty_day_reservations_asset_id.region_name,
      thirty_day_reservations_asset_id.district,
      thirty_day_reservations_asset_id.market_name,
      thirty_day_reservations_asset_id.rental_start_date,
      thirty_day_reservations_asset_id.rental_end_date,
      thirty_day_reservations_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_asset_id.class,
      thirty_day_reservations_asset_id.make_and_model,
      thirty_day_reservations_asset_id.jobsite_link,
      thirty_day_reservations_asset_id.location_nickname,
      thirty_day_reservations_asset_id.purchase_order_name,
      thirty_day_reservations_asset_id.formatted_price_per_day,
      thirty_day_reservations_asset_id.formatted_price_per_week,
      thirty_day_reservations_asset_id.formatted_price_per_month,
      thirty_day_reservations_asset_id.delivery_contact_name,
      thirty_day_reservations_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_asset_id.delivery_charge,
      thirty_day_reservations_asset_id.job_description,
      thirty_day_reservations_asset_id.rental_status_name,
      thirty_day_reservations_asset_id.salespeople_full_names_with_id
    ]
  }


  measure: pacific_on_rent_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "Pacific" ]
  }

  measure: pacific_on_rent_assigned_predelivered_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_on_rent_assigned_predelivered_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "Pacific" ]
  }

  measure: southeast_unit_count {
    type: sum
    sql: ${TABLE}.total_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Southeast" ]
  }
  measure: southeast_on_rent_asset_count {
    type: sum
    sql: ${TABLE}.on_rent_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Southeast" ]
  }

  measure: southeast_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Southeast" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.region_name,
      thirty_day_reservations_detail.district,
      thirty_day_reservations_detail.market_name,
      thirty_day_reservations_detail.rental_start_date,
      thirty_day_reservations_detail.rental_end_date,
      thirty_day_reservations_detail.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_detail.class,
      thirty_day_reservations_detail.make_and_model,
      thirty_day_reservations_detail.jobsite_link,
      thirty_day_reservations_detail.location_nickname,
      thirty_day_reservations_detail.purchase_order_name,
      thirty_day_reservations_detail.formatted_price_per_day,
      thirty_day_reservations_detail.formatted_price_per_week,
      thirty_day_reservations_detail.formatted_price_per_month,
      thirty_day_reservations_detail.delivery_contact_name,
      thirty_day_reservations_detail.delivery_contact_phone_number,
      thirty_day_reservations_detail.delivery_charge,
      thirty_day_reservations_detail.job_description,
      thirty_day_reservations_detail.rental_status_name,
      thirty_day_reservations_detail.salespeople_full_names_with_id
    ]
  }

  measure: southeast_no_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with no assigned asset."
    type: sum
    sql: ${TABLE}.no_assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Southeast" ]
    drill_fields: [
      thirty_day_reservations_no_asset_id.rental_id,
      thirty_day_reservations_no_asset_id.asset_id,
      thirty_day_reservations_no_asset_id.region_name,
      thirty_day_reservations_no_asset_id.district,
      thirty_day_reservations_no_asset_id.market_name,
      thirty_day_reservations_no_asset_id.rental_start_date,
      thirty_day_reservations_no_asset_id.rental_end_date,
      thirty_day_reservations_no_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_no_asset_id.class,
      thirty_day_reservations_no_asset_id.make_and_model,
      thirty_day_reservations_no_asset_id.jobsite_link,
      thirty_day_reservations_no_asset_id.location_nickname,
      thirty_day_reservations_no_asset_id.purchase_order_name,
      thirty_day_reservations_no_asset_id.formatted_price_per_day,
      thirty_day_reservations_no_asset_id.formatted_price_per_week,
      thirty_day_reservations_no_asset_id.formatted_price_per_month,
      thirty_day_reservations_no_asset_id.delivery_contact_name,
      thirty_day_reservations_no_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_no_asset_id.delivery_charge,
      thirty_day_reservations_no_asset_id.job_description,
      thirty_day_reservations_no_asset_id.rental_status_name,
      thirty_day_reservations_no_asset_id.salespeople_full_names_with_id
    ]
  }

  measure: southeast_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with an assigned asset."
    type: sum
    sql: ${TABLE}.assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Southeast" ]
    drill_fields: [
      thirty_day_reservations_asset_id.rental_id,
      thirty_day_reservations_asset_id.asset_id,
      thirty_day_reservations_asset_id.region_name,
      thirty_day_reservations_asset_id.district,
      thirty_day_reservations_asset_id.market_name,
      thirty_day_reservations_asset_id.rental_start_date,
      thirty_day_reservations_asset_id.rental_end_date,
      thirty_day_reservations_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_asset_id.class,
      thirty_day_reservations_asset_id.make_and_model,
      thirty_day_reservations_asset_id.jobsite_link,
      thirty_day_reservations_asset_id.location_nickname,
      thirty_day_reservations_asset_id.purchase_order_name,
      thirty_day_reservations_asset_id.formatted_price_per_day,
      thirty_day_reservations_asset_id.formatted_price_per_week,
      thirty_day_reservations_asset_id.formatted_price_per_month,
      thirty_day_reservations_asset_id.delivery_contact_name,
      thirty_day_reservations_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_asset_id.delivery_charge,
      thirty_day_reservations_asset_id.job_description,
      thirty_day_reservations_asset_id.rental_status_name,
      thirty_day_reservations_asset_id.salespeople_full_names_with_id
    ]
  }

  measure: southeast_on_rent_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "Southeast" ]
  }

  measure: southeast_on_rent_assigned_predelivered_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_on_rent_assigned_predelivered_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "Southeast" ]
  }

  measure: southwest_unit_count {
    type: sum
    sql: ${TABLE}.total_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Southwest" ]
  }
  measure: southwest_on_rent_asset_count {
    type: sum
    sql: ${TABLE}.on_rent_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Southwest" ]
  }
  measure: southwest_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Southwest" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.region_name,
      thirty_day_reservations_detail.district,
      thirty_day_reservations_detail.market_name,
      thirty_day_reservations_detail.rental_start_date,
      thirty_day_reservations_detail.rental_end_date,
      thirty_day_reservations_detail.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_detail.class,
      thirty_day_reservations_detail.make_and_model,
      thirty_day_reservations_detail.jobsite_link,
      thirty_day_reservations_detail.location_nickname,
      thirty_day_reservations_detail.purchase_order_name,
      thirty_day_reservations_detail.formatted_price_per_day,
      thirty_day_reservations_detail.formatted_price_per_week,
      thirty_day_reservations_detail.formatted_price_per_month,
      thirty_day_reservations_detail.delivery_contact_name,
      thirty_day_reservations_detail.delivery_contact_phone_number,
      thirty_day_reservations_detail.delivery_charge,
      thirty_day_reservations_detail.job_description,
      thirty_day_reservations_detail.rental_status_name,
      thirty_day_reservations_detail.salespeople_full_names_with_id
    ]
  }

  measure: southwest_no_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with no assigned asset."
    type: sum
    sql: ${TABLE}.no_assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Southwest" ]
    drill_fields: [
      thirty_day_reservations_no_asset_id.rental_id,
      thirty_day_reservations_no_asset_id.asset_id,
      thirty_day_reservations_no_asset_id.region_name,
      thirty_day_reservations_no_asset_id.district,
      thirty_day_reservations_no_asset_id.market_name,
      thirty_day_reservations_no_asset_id.rental_start_date,
      thirty_day_reservations_no_asset_id.rental_end_date,
      thirty_day_reservations_no_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_no_asset_id.class,
      thirty_day_reservations_no_asset_id.make_and_model,
      thirty_day_reservations_no_asset_id.jobsite_link,
      thirty_day_reservations_no_asset_id.location_nickname,
      thirty_day_reservations_no_asset_id.purchase_order_name,
      thirty_day_reservations_no_asset_id.formatted_price_per_day,
      thirty_day_reservations_no_asset_id.formatted_price_per_week,
      thirty_day_reservations_no_asset_id.formatted_price_per_month,
      thirty_day_reservations_no_asset_id.delivery_contact_name,
      thirty_day_reservations_no_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_no_asset_id.delivery_charge,
      thirty_day_reservations_no_asset_id.job_description,
      thirty_day_reservations_no_asset_id.rental_status_name,
      thirty_day_reservations_no_asset_id.salespeople_full_names_with_id
    ]
  }

  measure: southwest_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with an assigned asset."
    type: sum
    sql: ${TABLE}.assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Southwest" ]
    drill_fields: [
      thirty_day_reservations_asset_id.rental_id,
      thirty_day_reservations_asset_id.asset_id,
      thirty_day_reservations_asset_id.region_name,
      thirty_day_reservations_asset_id.district,
      thirty_day_reservations_asset_id.market_name,
      thirty_day_reservations_asset_id.rental_start_date,
      thirty_day_reservations_asset_id.rental_end_date,
      thirty_day_reservations_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_asset_id.class,
      thirty_day_reservations_asset_id.make_and_model,
      thirty_day_reservations_asset_id.jobsite_link,
      thirty_day_reservations_asset_id.location_nickname,
      thirty_day_reservations_asset_id.purchase_order_name,
      thirty_day_reservations_asset_id.formatted_price_per_day,
      thirty_day_reservations_asset_id.formatted_price_per_week,
      thirty_day_reservations_asset_id.formatted_price_per_month,
      thirty_day_reservations_asset_id.delivery_contact_name,
      thirty_day_reservations_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_asset_id.delivery_charge,
      thirty_day_reservations_asset_id.job_description,
      thirty_day_reservations_asset_id.rental_status_name,
      thirty_day_reservations_asset_id.salespeople_full_names_with_id
    ]
  }

  measure: southwest_on_rent_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "Southwest" ]
  }

  measure: southwest_on_rent_assigned_predelivered_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_on_rent_assigned_predelivered_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "Southwest" ]
  }

  measure: na_unit_count {
    type: sum
    sql: ${TABLE}.total_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "na" ]
  }
  measure: na_on_rent_asset_count {
    type: sum
    sql: ${TABLE}.on_rent_asset_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "na" ]
  }

  measure: na_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "na" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.region_name,
      thirty_day_reservations_detail.district,
      thirty_day_reservations_detail.market_name,
      thirty_day_reservations_detail.rental_start_date,
      thirty_day_reservations_detail.rental_end_date,
      thirty_day_reservations_detail.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_detail.class,
      thirty_day_reservations_detail.make_and_model,
      thirty_day_reservations_detail.jobsite_link,
      thirty_day_reservations_detail.location_nickname,
      thirty_day_reservations_detail.purchase_order_name,
      thirty_day_reservations_detail.formatted_price_per_day,
      thirty_day_reservations_detail.formatted_price_per_week,
      thirty_day_reservations_detail.formatted_price_per_month,
      thirty_day_reservations_detail.delivery_contact_name,
      thirty_day_reservations_detail.delivery_contact_phone_number,
      thirty_day_reservations_detail.delivery_charge,
      thirty_day_reservations_detail.job_description,
      thirty_day_reservations_detail.rental_status_name,
      thirty_day_reservations_detail.salespeople_full_names_with_id
    ]
  }

  measure: na_no_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with no assigned asset."
    type: sum
    sql: ${TABLE}.no_assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "na" ]
    drill_fields: [
      thirty_day_reservations_no_asset_id.rental_id,
      thirty_day_reservations_no_asset_id.asset_id,
      thirty_day_reservations_no_asset_id.region_name,
      thirty_day_reservations_no_asset_id.district,
      thirty_day_reservations_no_asset_id.market_name,
      thirty_day_reservations_no_asset_id.rental_start_date,
      thirty_day_reservations_no_asset_id.rental_end_date,
      thirty_day_reservations_no_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_no_asset_id.class,
      thirty_day_reservations_no_asset_id.make_and_model,
      thirty_day_reservations_no_asset_id.jobsite_link,
      thirty_day_reservations_no_asset_id.location_nickname,
      thirty_day_reservations_no_asset_id.purchase_order_name,
      thirty_day_reservations_no_asset_id.formatted_price_per_day,
      thirty_day_reservations_no_asset_id.formatted_price_per_week,
      thirty_day_reservations_no_asset_id.formatted_price_per_month,
      thirty_day_reservations_no_asset_id.delivery_contact_name,
      thirty_day_reservations_no_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_no_asset_id.delivery_charge,
      thirty_day_reservations_no_asset_id.job_description,
      thirty_day_reservations_no_asset_id.rental_status_name,
      thirty_day_reservations_no_asset_id.salespeople_full_names_with_id
    ]
  }

  measure: na_assigned_asset_upcoming_30_day_rental_count {
    description: "Number of distinct rentals in the next 30 days with an assigned asset."
    type: sum
    sql: ${TABLE}.assigned_asset_upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "na" ]
    drill_fields: [
      thirty_day_reservations_asset_id.rental_id,
      thirty_day_reservations_asset_id.asset_id,
      thirty_day_reservations_asset_id.region_name,
      thirty_day_reservations_asset_id.district,
      thirty_day_reservations_asset_id.market_name,
      thirty_day_reservations_asset_id.rental_start_date,
      thirty_day_reservations_asset_id.rental_end_date,
      thirty_day_reservations_asset_id.company_name,
      thirty_day_reservations_detail.parent_category,
      thirty_day_reservations_detail.subcategory,
      thirty_day_reservations_asset_id.class,
      thirty_day_reservations_asset_id.make_and_model,
      thirty_day_reservations_asset_id.jobsite_link,
      thirty_day_reservations_asset_id.location_nickname,
      thirty_day_reservations_asset_id.purchase_order_name,
      thirty_day_reservations_asset_id.formatted_price_per_day,
      thirty_day_reservations_asset_id.formatted_price_per_week,
      thirty_day_reservations_asset_id.formatted_price_per_month,
      thirty_day_reservations_asset_id.delivery_contact_name,
      thirty_day_reservations_asset_id.delivery_contact_phone_number,
      thirty_day_reservations_asset_id.delivery_charge,
      thirty_day_reservations_asset_id.job_description,
      thirty_day_reservations_asset_id.rental_status_name,
      thirty_day_reservations_asset_id.salespeople_full_names_with_id
    ]
  }


  measure: na_on_rent_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "na" ]
  }

  measure: na_on_rent_assigned_predelivered_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_on_rent_assigned_predelivered_unit_utilization ;;
    value_format_name: "percent_2"
    filters: [ region_name: "na" ]
  }

}

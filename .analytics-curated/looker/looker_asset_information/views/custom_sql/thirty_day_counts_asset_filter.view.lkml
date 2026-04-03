view: thirty_day_counts_asset_filter  {
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
        )
        SELECT

  CASE
      WHEN parent_categories.parent_category_name IS NULL
      THEN 'na'
      ELSE parent_categories.parent_category_name
      END AS parent_category,
  CASE
      WHEN sub_categories.sub_category_name  IS NULL
      THEN 'na'
      ELSE sub_categories.sub_category_name
      END AS subcategory,
  CASE
      WHEN equipment_classes."NAME" IS NULL
      THEN 'na'
      ELSE equipment_classes."NAME"
      END AS class,
    CASE
      WHEN  market_region_xwalk.REGION_NAME  IS NULL
      THEN 'na'
      ELSE  market_region_xwalk.REGION_NAME
      END AS region_name,
    CASE
      WHEN  market_region_xwalk.district    IS NULL
      THEN 'na'
      ELSE  market_region_xwalk.district
      END AS district,
    CASE
      WHEN  market_region_xwalk.MARKET_NAME       IS NULL
      THEN 'na'
      ELSE  market_region_xwalk.MARKET_NAME
      END AS market_name,



  rentals."RENTAL_ID"                      AS rental_id,
  equipment_assignments."ASSET_ID"         AS asset_id,

  CASE
    WHEN rentals."ASSET_ID" IS NOT NULL THEN 'Yes'
    ELSE 'No'
  END                                      AS has_asset_assigned,

  rentals."START_DATE"                     AS start_date
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

      ;;
  }


  dimension: parent_category { type: string sql: ${TABLE}.parent_category ;; }
  dimension: subcategory    { type: string sql: ${TABLE}.subcategory    ;; }
  dimension: class                { type: string sql: ${TABLE}.class ;; }
  dimension: region_name          { type: string sql: ${TABLE}.region_name          ;; }
  dimension: district             { type: string sql: ${TABLE}.district             ;; }
  dimension: market_name          { type: string sql: ${TABLE}.market_name          ;; }

  dimension: class_clean {
    label: "Class (clean)"
    type: string
    sql:
    REGEXP_REPLACE(${TABLE}.class, '[,\'"]', '')
  ;;
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}.rental_id ;;
    hidden: yes
  }
  dimension: start_date {
    type: date
    sql: ${TABLE}.start_date ;;
  }
  dimension: has_asset_assigned {
    type: string
    sql: ${TABLE}.has_asset_assigned ;;
  }


  measure: 30_day_reservations {
    type: count_distinct
    sql: ${rental_id} ;;
    value_format_name: "decimal_0"
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.has_asset_assigned,
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

  measure: industrial_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Industrial" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.has_asset_assigned,
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



  measure: midwest_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Midwest" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.has_asset_assigned,
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
      thirty_day_reservations_detail.has_asset_assigned,
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



  measure: northeast_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Northeast" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.has_asset_assigned,
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


  measure: pacific_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Pacific" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.has_asset_assigned,
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



  measure: southeast_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Southeast" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.has_asset_assigned,
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

  measure: southwest_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "Southwest" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.has_asset_assigned,
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


  measure: na_30_day_reservations {
    type: sum
    sql: ${TABLE}.upcoming_30_day_rental_count ;;
    value_format_name: "decimal_0"
    filters: [ region_name: "na" ]
    drill_fields: [
      thirty_day_reservations_detail.rental_id,
      thirty_day_reservations_detail.asset_id,
      thirty_day_reservations_detail.has_asset_assigned,
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



}

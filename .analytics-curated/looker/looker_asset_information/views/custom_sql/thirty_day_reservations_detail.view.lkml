#
# /views/ES_WAREHOUSE/thirty_day_reservations_detail.view.lkml
#
view: thirty_day_reservations_detail {
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
,active_branch_rental_rates_pivot AS (
           WITH columns AS (
             SELECT
               branch_id,
               equipment_class_id,
               rate_type_id,
               SUM(price_per_hour)  AS pivotcol1,
               SUM(price_per_day)   AS pivotcol2,
               SUM(price_per_week)  AS pivotcol3,
               SUM(price_per_month) AS pivotcol4
             FROM es_warehouse.public.branch_rental_rates
             WHERE active = 'Y'
             GROUP BY branch_id, equipment_class_id, rate_type_id
           ),
           agg_columns AS (
             SELECT
               branch_id,
               equipment_class_id,
               OBJECT_AGG(rate_type_id, pivotcol1) AS hour_price,
               OBJECT_AGG(rate_type_id, pivotcol2) AS day_price,
               OBJECT_AGG(rate_type_id, pivotcol3) AS week_price,
               OBJECT_AGG(rate_type_id, pivotcol4) AS month_price
             FROM columns
             GROUP BY branch_id, equipment_class_id
           )
           SELECT
             ac.branch_id                       AS branch_id,
             ac.equipment_class_id              AS equipment_class_id,
             ec.name                            AS class,
             ac.hour_price:"1"::integer         AS online_hour_rate,
             ac.day_price:"1"::integer          AS online_day_rate,
             ac.week_price:"1"::integer         AS online_week_rate,
             ac.month_price:"1"::integer        AS online_month_rate,
             ac.hour_price:"2"::integer         AS benchmark_hour_rate,
             ac.day_price:"2"::integer          AS benchmark_day_rate,
             ac.week_price:"2"::integer         AS benchmark_week_rate,
             ac.month_price:"2"::integer        AS benchmark_month_rate,
             ac.hour_price:"3"::integer         AS floor_hour_rate,
             ac.day_price:"3"::integer          AS floor_day_rate,
             ac.week_price:"3"::integer         AS floor_week_rate,
             ac.month_price:"3"::integer        AS floor_month_rate,
             ac.month_price:"3"::integer / 28    AS calc_floor_daily_rate,
             ac.month_price:"1"::integer / 28    AS calc_online_daily_rate
           FROM agg_columns ac
           LEFT JOIN es_warehouse.public.equipment_classes ec
             ON ac.equipment_class_id = ec.equipment_class_id
         )
         SELECT DISTINCT
           rentals."RENTAL_ID"                               AS rental_id,
           assets."ASSET_ID"                                 AS asset_id,
          CASE
            WHEN assets."ASSET_ID" IS NOT NULL THEN 'Yes'
          ELSE 'No'
           END                                      AS has_asset_assigned,
          CASE
            WHEN market_region_xwalk."REGION_NAME" IS NULL
            THEN 'na'
            ELSE market_region_xwalk."REGION_NAME"
          END AS region_name,

          CASE
            WHEN market_region_xwalk."DISTRICT" IS NULL
            THEN 'na'
            ELSE market_region_xwalk."DISTRICT"
          END AS district,

          CASE
            WHEN market_region_xwalk."MARKET_NAME" IS NULL
            THEN 'na'
            ELSE market_region_xwalk."MARKET_NAME"
          END AS market_name,
           TO_CHAR(TO_DATE(rentals."START_DATE"), 'YYYY-MM-DD')   AS rental_start_date,
           TO_CHAR(TO_DATE(rentals."END_DATE"), 'YYYY-MM-DD')   AS rental_end_date,
           REPLACE(TRIM(companies."NAME"), CHAR(9), '')       AS company_name,

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
              WHEN mapped_classes.asset_equipment_class_name IS NOT NULL
                THEN mapped_classes.asset_equipment_class_name
              WHEN equipment_classes."NAME" IS NULL
                THEN 'na'
              ELSE equipment_classes."NAME"
            END AS class,
           CONCAT(assets."MAKE", ' ', assets."MODEL", ' (', assets."YEAR", ')') AS make_and_model,

CASE
    WHEN rentals."RENTAL_ID" = 2837509 THEN
      '286 W 300 N, Anderson, IN 46012'
    WHEN rentals."RENTAL_ID" = 2842606 THEN
      '28 Weems Street, Brownsville, TX 78521'
    ELSE
      CONCAT(
        locations."STREET_1", ', ',
        locations."CITY", ', ',
        states."ABBREVIATION", ' ',
        locations."ZIP_CODE"
      )
  END AS jobsite_link,

CASE
    WHEN rentals."RENTAL_ID" = 2837509 THEN
      'E & B PAVING, LLC'
    WHEN rentals."RENTAL_ID" = 2793937 THEN
      'SpaceX'
    ELSE
      locations."NICKNAME"
  END AS location_nickname,
  purchase_orders."NAME"                             AS purchase_order_name,

      CASE
      WHEN (CASE
      WHEN rentals."PRICE_PER_WEEK" IS NULL
      AND rentals."PRICE_PER_MONTH" IS NULL
      THEN 10
      ELSE rentals."RENTAL_TYPE_ID"
      END) = 10
      AND rentals."PRICE_PER_DAY" < active_branch_rental_rates_pivot.calc_floor_daily_rate
      THEN 'Below Floor'
      WHEN (CASE
      WHEN rentals."PRICE_PER_WEEK" IS NULL
      AND rentals."PRICE_PER_MONTH" IS NULL
      THEN 10
      ELSE rentals."RENTAL_TYPE_ID"
      END) = 10
      AND rentals."PRICE_PER_DAY" >= active_branch_rental_rates_pivot.calc_online_daily_rate
      THEN 'Above Online'
      WHEN (CASE
      WHEN rentals."PRICE_PER_WEEK" IS NULL
      AND rentals."PRICE_PER_MONTH" IS NULL
      THEN 10
      ELSE rentals."RENTAL_TYPE_ID"
      END) = 10
      AND rentals."PRICE_PER_DAY" >= active_branch_rental_rates_pivot.calc_floor_daily_rate
      AND rentals."PRICE_PER_DAY" < active_branch_rental_rates_pivot.calc_online_daily_rate
      THEN 'Above Floor/Below Online'
      WHEN rentals."PRICE_PER_DAY" < active_branch_rental_rates_pivot.floor_day_rate
      THEN 'Below Floor'
      WHEN rentals."PRICE_PER_DAY" >= active_branch_rental_rates_pivot.floor_day_rate
      AND rentals."PRICE_PER_DAY" < active_branch_rental_rates_pivot.online_day_rate
      THEN 'Above Floor/Below Online'
      WHEN rentals."PRICE_PER_DAY" >= active_branch_rental_rates_pivot.online_day_rate
      THEN 'Above Online'
      ELSE 'Above Floor/Below Online'
      END                                                AS day_rate_achievement,

      rentals."PRICE_PER_DAY"                              AS formatted_price_per_day,

      CASE
      WHEN rentals."PRICE_PER_WEEK" < active_branch_rental_rates_pivot.floor_week_rate
      THEN 'Below Floor'
      WHEN rentals."PRICE_PER_WEEK" >= active_branch_rental_rates_pivot.floor_week_rate
      AND rentals."PRICE_PER_WEEK" < active_branch_rental_rates_pivot.online_week_rate
      THEN 'Above Floor/Below Online'
      WHEN rentals."PRICE_PER_WEEK" >= active_branch_rental_rates_pivot.online_week_rate
      THEN 'Above Online'
      ELSE 'Above Floor/Below Online'
      END                                                AS week_rate_achievement,

      rentals."PRICE_PER_WEEK"                             AS formatted_price_per_week,

      CASE
      WHEN rentals."PRICE_PER_MONTH" < active_branch_rental_rates_pivot.floor_month_rate
      THEN 'Below Floor'
      WHEN rentals."PRICE_PER_MONTH" >= active_branch_rental_rates_pivot.floor_month_rate
      AND rentals."PRICE_PER_MONTH" < active_branch_rental_rates_pivot.online_month_rate
      THEN 'Above Floor/Below Online'
      WHEN rentals."PRICE_PER_MONTH" >= active_branch_rental_rates_pivot.online_month_rate
      THEN 'Above Online'
      ELSE 'Above Floor/Below Online'
      END                                                AS month_rate_achievement,

      rentals."PRICE_PER_MONTH"                            AS formatted_price_per_month,

      deliveries."CONTACT_NAME"                            AS delivery_contact_name,
      deliveries."CONTACT_PHONE_NUMBER"                    AS delivery_contact_phone_number,
      deliveries."CHARGE"                                  AS delivery_charge,

      rentals."JOB_DESCRIPTION"                            AS job_description,
      rental_statuses."NAME"                               AS rental_status_name,

        LISTAGG(
    CONCAT(
      CASE
        WHEN users."FIRST_NAME" IS NULL
          THEN 'No Salesperson Assigned'
        ELSE TRIM(users."FIRST_NAME") || ' ' || TRIM(users."LAST_NAME")
      END,
      ' - ',
      users."USER_ID"
    ),
    ', '
  )
  WITHIN GROUP (ORDER BY users."USER_ID") AS salespeople_full_names_with_id


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
      LEFT JOIN active_branch_rental_rates_pivot
      ON orders."MARKET_ID" = active_branch_rental_rates_pivot.branch_id
      AND rentals."EQUIPMENT_CLASS_ID" = active_branch_rental_rates_pivot.equipment_class_id
      LEFT JOIN mapped_classes
  ON assets."ASSET_ID" = mapped_classes.asset_id

      WHERE
      rentals."START_DATE" >= DATEADD(day, 1, CURRENT_DATE)
      AND rentals."RENTAL_ID" IS NOT NULL
      AND rentals."START_DATE" <= DATEADD(day, 30, CURRENT_DATE)
      AND (locations."COMPANY_ID" <> 1854 OR locations."COMPANY_ID" IS NULL)
      AND (
      UPPER(rental_statuses."NAME") = UPPER('Pending')
      OR UPPER(rental_statuses."NAME") = UPPER('Draft')
      )
      AND (
      (
      SUBSTR(TRIM(assets."SERIAL_NUMBER"), 1, 3) != 'RR-'
      AND SUBSTR(TRIM(assets."SERIAL_NUMBER"), 1, 2) != 'RR'
      )
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
          market_region_xwalk."DISTRICT" IN (
            '0'
          )
          OR market_region_xwalk."REGION_NAME" IN (
            'Midwest','Southeast','Pacific','Mountain West',
            'Southwest','Northeast','Industrial'
          )
          OR market_region_xwalk."MARKET_ID"::text IN (
            '0'
          )
        )
      )
--AND rentals."RENTAL_ID"IN ('2793937', '2774273')
      GROUP BY
      rentals."RENTAL_ID",
      assets."ASSET_ID",
      CASE
        WHEN assets."ASSET_ID" IS NOT NULL
            THEN 'Yes'
            ELSE 'No'
      END,
      market_region_xwalk."REGION_NAME",
      market_region_xwalk."DISTRICT",
      market_region_xwalk."MARKET_NAME",
      TO_CHAR(TO_DATE(rentals."START_DATE"), 'YYYY-MM-DD'),
      TO_CHAR(TO_DATE(rentals."END_DATE"), 'YYYY-MM-DD'),
      companies."NAME",
       CASE
              WHEN mapped_classes.asset_equipment_class_name IS NOT NULL
                THEN mapped_classes.asset_equipment_class_name
              WHEN equipment_classes."NAME" IS NULL
                THEN 'na'
              ELSE equipment_classes."NAME"
            END,
      parent_categories.parent_category_name,
      subcategory,

      CONCAT(assets."MAKE", ' ', assets."MODEL", ' (', assets."YEAR", ')'),
      CONCAT(locations."STREET_1", ', ', locations."CITY", ', ', states."ABBREVIATION", ' ', locations."ZIP_CODE"),
      locations."NICKNAME",
      purchase_orders."NAME",
      CASE
      WHEN (CASE
      WHEN rentals."PRICE_PER_WEEK" IS NULL
      AND rentals."PRICE_PER_MONTH" IS NULL
      THEN 10
      ELSE rentals."RENTAL_TYPE_ID"
      END) = 10
      AND rentals."PRICE_PER_DAY" < active_branch_rental_rates_pivot.calc_floor_daily_rate
      THEN 'Below Floor'
      WHEN (CASE
      WHEN rentals."PRICE_PER_WEEK" IS NULL
      AND rentals."PRICE_PER_MONTH" IS NULL
      THEN 10
      ELSE rentals."RENTAL_TYPE_ID"
      END) = 10
      AND rentals."PRICE_PER_DAY" >= active_branch_rental_rates_pivot.calc_online_daily_rate
      THEN 'Above Online'
      WHEN (CASE
      WHEN rentals."PRICE_PER_WEEK" IS NULL
      AND rentals."PRICE_PER_MONTH" IS NULL
      THEN 10
      ELSE rentals."RENTAL_TYPE_ID"
      END) = 10
      AND rentals."PRICE_PER_DAY" >= active_branch_rental_rates_pivot.calc_floor_daily_rate
      AND rentals."PRICE_PER_DAY" < active_branch_rental_rates_pivot.calc_online_daily_rate
      THEN 'Above Floor/Below Online'
      WHEN rentals."PRICE_PER_DAY" < active_branch_rental_rates_pivot.floor_day_rate
      THEN 'Below Floor'
      WHEN rentals."PRICE_PER_DAY" >= active_branch_rental_rates_pivot.floor_day_rate
      AND rentals."PRICE_PER_DAY" < active_branch_rental_rates_pivot.online_day_rate
      THEN 'Above Floor/Below Online'
      WHEN rentals."PRICE_PER_DAY" >= active_branch_rental_rates_pivot.online_day_rate
      THEN 'Above Online'
      ELSE 'Above Floor/Below Online'
      END,
      rentals."PRICE_PER_DAY",
      CASE
      WHEN rentals."PRICE_PER_WEEK" < active_branch_rental_rates_pivot.floor_week_rate
      THEN 'Below Floor'
      WHEN rentals."PRICE_PER_WEEK" >= active_branch_rental_rates_pivot.floor_week_rate
      AND rentals."PRICE_PER_WEEK" < active_branch_rental_rates_pivot.online_week_rate
      THEN 'Above Floor/Below Online'
      WHEN rentals."PRICE_PER_WEEK" >= active_branch_rental_rates_pivot.online_week_rate
      THEN 'Above Online'
      ELSE 'Above Floor/Below Online'
      END,
      rentals."PRICE_PER_WEEK",
      CASE
      WHEN rentals."PRICE_PER_MONTH" < active_branch_rental_rates_pivot.floor_month_rate
      THEN 'Below Floor'
      WHEN rentals."PRICE_PER_MONTH" >= active_branch_rental_rates_pivot.floor_month_rate
      AND rentals."PRICE_PER_MONTH" < active_branch_rental_rates_pivot.online_month_rate
      THEN 'Above Floor/Below Online'
      WHEN rentals."PRICE_PER_MONTH" >= active_branch_rental_rates_pivot.online_month_rate
      THEN 'Above Online'
      ELSE 'Above Floor/Below Online'
      END,
      rentals."PRICE_PER_MONTH",
      deliveries."CONTACT_NAME",
      deliveries."CONTACT_PHONE_NUMBER",
      deliveries."CHARGE",
      rentals."JOB_DESCRIPTION",
      rental_statuses."NAME"
      ORDER BY rentals."RENTAL_ID" ASC
    ;;
  }


  dimension: rental_id {
    type: number
    sql: ${TABLE}.rental_id ;;
    primary_key:  yes
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: has_asset_assigned {
    type: string
    sql: ${TABLE}.has_asset_assigned;;
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

  dimension: rental_start_date {
    type: date
    sql: ${TABLE}.rental_start_date ;;
  }

  dimension: rental_end_date {
    type: date
    sql: ${TABLE}.rental_end_date ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
  }

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

  dimension: make_and_model {
    type: string
    sql: ${TABLE}.make_and_model ;;
  }

  dimension: jobsite_link {
    type: string
    sql: ${TABLE}.jobsite_link ;;
  }

  dimension: location_nickname {
    type: string
    sql: ${TABLE}.location_nickname ;;
  }

  dimension: purchase_order_name {
    type: string
    sql: ${TABLE}.purchase_order_name ;;
  }

  dimension: day_rate_achievement {
    type: string
    sql: ${TABLE}.day_rate_achievement ;;
  }

  # measure: formatted_price_per_day {
  #   type: sum
  #   sql: ${TABLE}.formatted_price_per_day ;;
  #   value_format_name: "usd"
  # }

  dimension: formatted_price_per_day {
    group_label: "Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.formatted_price_per_day ;;
     html: |
      {% if day_rate_achievement == "Below Floor" %}
        <div style="color:white;
          background-color:rgba(168,8,8,1);
          text-align:center;">
        {{ rendered_value }}
        </div>
      {% else %}
        {{ rendered_value }}
      {% endif %}
    ;;
  }

  dimension: week_rate_achievement {
    type: string
    sql: ${TABLE}.week_rate_achievement ;;
  }

  # measure: formatted_price_per_week {
  #   type: sum
  #   sql: ${TABLE}.formatted_price_per_week ;;
  #   value_format_name: "usd"
  # }

  dimension: formatted_price_per_week {
    group_label: "Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.formatted_price_per_week ;;
    html: |
      {% if week_rate_achievement == "Below Floor" %}
        <div style="color:white;
          background-color:rgba(168,8,8,1);
          text-align:center;">
        {{ rendered_value }}
      </div>
      {% else %}
        {{ rendered_value }}
      {% endif %}
    ;;
  }


  dimension: month_rate_achievement {
    type: string
    sql: ${TABLE}.month_rate_achievement ;;
  }

  dimension: formatted_price_per_month {
    group_label: "Rate Achievement"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.formatted_price_per_month ;;
    html: |
      {% if month_rate_achievement == "Below Floor" %}
        <div style="color:white;
          background-color:rgba(168,8,8,1);
          text-align:center;">
          {{ rendered_value }}
        </div>
      {% else %}
        {{ rendered_value }}
      {% endif %}
    ;;
  }

  # measure: formatted_price_per_month {
  #   type: sum
  #   sql: ${TABLE}.formatted_price_per_month ;;
  #   value_format_name: "usd"
  # }

  dimension: delivery_contact_name {
    type: string
    sql: ${TABLE}.delivery_contact_name ;;
  }

  dimension: delivery_contact_phone_number {
    type: string
    sql: ${TABLE}.delivery_contact_phone_number ;;
  }

  dimension: delivery_charge {
    type: number
    sql: ${TABLE}.delivery_charge ;;
    value_format_name: "usd"
  }

  dimension: job_description {
    type: string
    sql: ${TABLE}.job_description ;;
  }

  dimension: rental_status_name {
    type: string
    sql: ${TABLE}.rental_status_name ;;
  }

  dimension: salespeople_full_names_with_id {
    type: string
    sql: ${TABLE}.salespeople_full_names_with_id ;;
  }
}

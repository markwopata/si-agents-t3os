#
#   grouped_oec.view.lkml
#
view: grouped_counts_utilizations {
  derived_table: {
    sql:
WITH
  --------------------------------------------
  -- 1) Build a simple lookup of each sub‐category
  --------------------------------------------
  sub_categories AS (
    SELECT
      parent_category_id,
      name               AS sub_category_name,   -- unquoted, lower‐case
      category_id,
      company_division_id
    FROM ES_WAREHOUSE.PUBLIC.categories c
    WHERE c.parent_category_id IS NOT NULL
  ),

  --------------------------------------------
  -- 2) Compute on‐rent rates per market/class
  --------------------------------------------
  market_class_on_rent_rates AS (
    WITH on_rent AS (
      SELECT
        rental_id,
        asset_id,
        price_per_day,
        price_per_week,
        price_per_month,
        price_per_hour
      FROM ES_WAREHOUSE.PUBLIC.RENTALS r
      WHERE
        r.rental_status_id = 5
        AND r.deleted         = FALSE
    )
    SELECT
      p.market_id,
      p.equipment_class_id,
      p.equipment_class,
      COUNT(p.asset_id)                  AS asset_count,
      SUM(r.price_per_month)             AS total_price_per_month,
      ROW_NUMBER() OVER (
        ORDER BY p.market_id,
                 p.equipment_class_id,
                 p.equipment_class
      )                                   AS row_number
    FROM on_rent r
    INNER JOIN analytics.public.rateachievement_points p
      ON r.rental_id = p.rental_id
     AND r.asset_id   = p.asset_id
    GROUP BY
      p.market_id,
      p.equipment_class_id,
      p.equipment_class
  ),

  --------------------------------------------
  -- 3) Group everything together by category / class / market
  --------------------------------------------
  grouped_oec AS (
    SELECT
      CASE WHEN
        asset_physical."PARENT_CATEGORY_NAME" IS NULL
            THEN 'na'
            ELSE asset_physical."PARENT_CATEGORY_NAME"
            END
        AS parent_category_name,
        CASE WHEN
        sub_categories.sub_category_name IS NULL
            THEN 'na'
            ELSE sub_categories.sub_category_name
            END
        AS sub_category_name,
        CASE WHEN
        equipment_classes."NAME"  IS NULL
            THEN 'na'
            ELSE equipment_classes."NAME"
            END
        AS equipment_classes_name,
        CASE WHEN
        market_region_xwalk."REGION_NAME" IS NULL
            THEN 'na'
            ELSE market_region_xwalk."REGION_NAME"
            END
        AS region_name,
        CASE WHEN
        market_region_xwalk."DISTRICT"    IS NULL
            THEN 'na'
            ELSE market_region_xwalk."DISTRICT"
            END
        AS district,
        CASE WHEN
        market_region_xwalk."MARKET_NAME"     IS NULL
            THEN 'na'
            ELSE market_region_xwalk."MARKET_NAME"
            END
        AS market_name,

      ----------------------------------------------------------------
      --   1) Total number of distinct assets in this grouping
      ----------------------------------------------------------------
      COUNT(DISTINCT assets_inventory."ASSET_ID")   AS total_asset_count,

      ----------------------------------------------------------------
      --   2) On Rent OR On RPO distinct count (intermediate)
      ----------------------------------------------------------------
      COUNT(
        DISTINCT CASE
          WHEN COALESCE(
                 scd_asset_inventory_status."ASSET_INVENTORY_STATUS",
                 'Unassigned'
               ) IN ('On Rent','On RPO')
          THEN CONCAT(
                 scd_asset_inventory_status."ASSET_ID",
                 scd_asset_inventory_status."CURRENT_FLAG"
               )
          ELSE NULL
        END
      )                                             AS count_of_on_rent_assets,

      ----------------------------------------------------------------
      --   3) On Rent Asset Count
      ----------------------------------------------------------------
      COUNT(
        DISTINCT CASE
          WHEN scd_asset_inventory_status."ASSET_INVENTORY_STATUS" = 'On Rent'
          THEN CONCAT(
                 scd_asset_inventory_status."ASSET_ID",
                 scd_asset_inventory_status."CURRENT_FLAG"
               )
          ELSE NULL
        END
      )                                             AS on_rent_asset_count,

      ----------------------------------------------------------------
      --   4) Assigned Asset Count
      ----------------------------------------------------------------
      COUNT(
        DISTINCT CASE
          WHEN scd_asset_inventory_status."ASSET_INVENTORY_STATUS" = 'Assigned'
          THEN CONCAT(
                 scd_asset_inventory_status."ASSET_ID",
                 scd_asset_inventory_status."CURRENT_FLAG"
               )
          ELSE NULL
        END
      )                                             AS assigned_asset_count,

      ----------------------------------------------------------------
      --   5) Unassigned Asset Count
      ----------------------------------------------------------------
      COUNT(
        DISTINCT CASE
          WHEN COALESCE(
                 scd_asset_inventory_status."ASSET_INVENTORY_STATUS",
                 'Unassigned'
               ) NOT IN (
                 'On Rent','Assigned','Ready To Rent','Needs Inspection',
                 'Pending Return','Soft Down','Hard Down','Make Ready','Pre-Delivered'
               )
          THEN CONCAT(
                 scd_asset_inventory_status."ASSET_ID",
                 scd_asset_inventory_status."CURRENT_FLAG"
               )
          ELSE NULL
        END
      )                                             AS unassigned_asset_count,

      ----------------------------------------------------------------
      --   6) Ready to Rent Asset Count
      ----------------------------------------------------------------
      COUNT(
        DISTINCT CASE
          WHEN scd_asset_inventory_status."ASSET_INVENTORY_STATUS" = 'Ready To Rent'
          THEN CONCAT(
                 scd_asset_inventory_status."ASSET_ID",
                 scd_asset_inventory_status."CURRENT_FLAG"
               )
          ELSE NULL
        END
      )                                             AS ready_to_rent_asset_count,

      ----------------------------------------------------------------
      --   7) Needs Inspection Asset Count
      ----------------------------------------------------------------
      COUNT(
        DISTINCT CASE
          WHEN scd_asset_inventory_status."ASSET_INVENTORY_STATUS" = 'Needs Inspection'
          THEN CONCAT(
                 scd_asset_inventory_status."ASSET_ID",
                 scd_asset_inventory_status."CURRENT_FLAG"
               )
          ELSE NULL
        END
      )                                             AS needs_inspection_asset_count,

      ----------------------------------------------------------------
      --   8) Pending Return Asset Count
      ----------------------------------------------------------------
      COUNT(
        DISTINCT CASE
          WHEN scd_asset_inventory_status."ASSET_INVENTORY_STATUS" = 'Pending Return'
          THEN CONCAT(
                 scd_asset_inventory_status."ASSET_ID",
                 scd_asset_inventory_status."CURRENT_FLAG"
               )
          ELSE NULL
        END
      )                                             AS pending_return_asset_count,

      ----------------------------------------------------------------
      --   9) Soft Down Asset Count
      ----------------------------------------------------------------
      COUNT(
        DISTINCT CASE
          WHEN scd_asset_inventory_status."ASSET_INVENTORY_STATUS" = 'Soft Down'
          THEN CONCAT(
                 scd_asset_inventory_status."ASSET_ID",
                 scd_asset_inventory_status."CURRENT_FLAG"
               )
          ELSE NULL
        END
      )                                             AS soft_down_asset_count,

      ----------------------------------------------------------------
      --  10) Hard Down Asset Count
      ----------------------------------------------------------------
      COUNT(
        DISTINCT CASE
          WHEN scd_asset_inventory_status."ASSET_INVENTORY_STATUS" = 'Hard Down'
          THEN CONCAT(
                 scd_asset_inventory_status."ASSET_ID",
                 scd_asset_inventory_status."CURRENT_FLAG"
               )
          ELSE NULL
        END
      )                                             AS hard_down_asset_count,

      ----------------------------------------------------------------
      --  11) Make Ready Asset Count
      ----------------------------------------------------------------
      COUNT(
        DISTINCT CASE
          WHEN scd_asset_inventory_status."ASSET_INVENTORY_STATUS" = 'Make Ready'
          THEN CONCAT(
                 scd_asset_inventory_status."ASSET_ID",
                 scd_asset_inventory_status."CURRENT_FLAG"
               )
          ELSE NULL
        END
      )                                             AS make_ready_asset_count,

      ----------------------------------------------------------------
      --  12) Pre‐Delivered Asset Count
      ----------------------------------------------------------------
      COUNT(
        DISTINCT CASE
          WHEN scd_asset_inventory_status."ASSET_INVENTORY_STATUS" = 'Pre-Delivered'
          THEN CONCAT(
                 scd_asset_inventory_status."ASSET_ID",
                 scd_asset_inventory_status."CURRENT_FLAG"
               )
          ELSE NULL
        END
      )                                             AS pre_delivered_asset_count,

      ----------------------------------------------------------------
      --  13) On RPO Asset Count
      ----------------------------------------------------------------
      COUNT(
        DISTINCT CASE
          WHEN UPPER(
                 COALESCE(
                   scd_asset_inventory_status."ASSET_INVENTORY_STATUS",
                   'Unassigned'
                 )
               ) = 'ON RPO'
          THEN CONCAT(
                 scd_asset_inventory_status."ASSET_ID",
                 scd_asset_inventory_status."CURRENT_FLAG"
               )
          ELSE NULL
        END
      )                                             AS count_of_on_rpo_assets,

      ----------------------------------------------------------------
      --  14) total_oec: “distinct-sum-hack” to avoid double counting
      ----------------------------------------------------------------
      COALESCE(
        CAST(
          (
            SUM(
              DISTINCT (
                CAST(
                  FLOOR(
                    COALESCE(assets_aggregate."OEC", 0) * 1000000
                  ) AS DECIMAL(38,0)
                )
                + (
                  TO_NUMBER(
                    MD5(assets_aggregate."ASSET_ID"),
                    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                  ) % 1.0e27
                )::NUMERIC(38,0)
              )
            )
            - SUM(
              DISTINCT (
                TO_NUMBER(
                  MD5(assets_aggregate."ASSET_ID"),
                  'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                ) % 1.0e27
              )::NUMERIC(38,0)
            )
          ) AS DOUBLE PRECISION
        ) / 1000000.0
      , 0)                                             AS total_oec,

      ----------------------------------------------------------------
      --  15) fin_util: same distinct-sum hack
      ----------------------------------------------------------------
      COALESCE(
        CAST(
          (
            SUM(
              DISTINCT (
                CAST(
                  FLOOR(
                    COALESCE(financial_utilization."RENTAL_REV", 0) * 1000000
                  ) AS DECIMAL(38,0)
                )
                + (
                  TO_NUMBER(
                    MD5(
                      CONCAT(
                        financial_utilization."ASSET_ID",
                        ' ',
                        financial_utilization."MARKET_ID"
                      )
                    ),
                    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                  ) % 1.0e27
                )::NUMERIC(38,0)
              )
            )
            - SUM(
              DISTINCT (
                TO_NUMBER(
                  MD5(
                    CONCAT(
                      financial_utilization."ASSET_ID",
                      ' ',
                      financial_utilization."MARKET_ID"
                    )
                  ),
                  'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                ) % 1.0e27
              )::NUMERIC(38,0)
            )
          ) AS DOUBLE PRECISION
        ) / 1000000.0
      , 0)
      * 365.0 / 31.0
      / NULLIF(
        COALESCE(
          CAST(
            (
              SUM(
                DISTINCT (
                  CAST(
                    FLOOR(
                      COALESCE(financial_utilization."OEC", 0) * 1000000
                    ) AS DECIMAL(38,0)
                  )
                  + (
                    TO_NUMBER(
                      MD5(
                        CONCAT(
                          financial_utilization."ASSET_ID",
                          ' ',
                          financial_utilization."MARKET_ID"
                        )
                      ),
                      'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                    ) % 1.0e27
                  )::NUMERIC(38,0)
                )
              )
              - SUM(
                DISTINCT (
                  TO_NUMBER(
                    MD5(
                      CONCAT(
                        financial_utilization."ASSET_ID",
                        ' ',
                        financial_utilization."MARKET_ID"
                      )
                    ),
                    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                  ) % 1.0e27
                )::NUMERIC(38,0)
              )
            ) AS DOUBLE PRECISION
          ) / 1000000.0
        , 0)
      , 0)
      AS fin_util,

      ----------------------------------------------------------------
      -- 16) Average Monthly Rate for Open Contracts
      ----------------------------------------------------------------
      COALESCE(
        CAST(
          (
            SUM(
              DISTINCT (
                CAST(
                  FLOOR(
                    COALESCE(
                      market_class_on_rent_rates."TOTAL_PRICE_PER_MONTH",
                      0
                    )
                    / market_class_on_rent_rates."ASSET_COUNT"
                    * 1000000
                  ) AS DECIMAL(38,0)
                )
                + (
                  TO_NUMBER(
                    MD5(
                      market_class_on_rent_rates."ROW_NUMBER"
                    ),
                    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                  ) % 1.0e27
                )::NUMERIC(38,0)
              )
            )
            - SUM(
              DISTINCT (
                TO_NUMBER(
                  MD5(
                    market_class_on_rent_rates."ROW_NUMBER"
                  ),
                  'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                ) % 1.0e27
              )::NUMERIC(38,0)
            )
          ) AS DOUBLE PRECISION
        ) / 1000000.0
      , 0)
      /
      NULLIF(
        COUNT(
          DISTINCT CASE
            WHEN market_class_on_rent_rates."TOTAL_PRICE_PER_MONTH"
                 / market_class_on_rent_rates."ASSET_COUNT" IS NOT NULL
            THEN market_class_on_rent_rates."ROW_NUMBER"
            ELSE NULL
          END
        )
      , 0)
      AS avg_price_per_month

    FROM ES_WAREHOUSE.PUBLIC.ASSETS AS assets_inventory

      LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS AS assets
        ON assets_inventory."ASSET_ID" = assets."ASSET_ID"

      INNER JOIN ANALYTICS.ASSET_DETAILS.ASSETS_INCLUDING_PURCHASING AS asset_physical
        ON assets."ASSET_ID" = asset_physical."ASSET_ID"

      LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS markets
        ON COALESCE(
             assets_inventory."RENTAL_BRANCH_ID",
             assets_inventory."INVENTORY_BRANCH_ID"
           ) = markets."MARKET_ID"

      LEFT JOIN ANALYTICS.PUBLIC.FINANCIAL_UTILIZATION AS financial_utilization
        ON financial_utilization."ASSET_ID" = assets."ASSET_ID"
       AND assets_inventory."RENTAL_BRANCH_ID" = financial_utilization."RENTAL_BRANCH_ID"

      LEFT JOIN (
        SELECT
          w.ASSET_ID,
          w.COMPANY_ID,
          w.CUSTOM_NAME,
          w.OWNER,
          w.EQUIPMENT_MAKE_ID,
          w.MAKE,
          w.EQUIPMENT_MODEL_ID,
          w.MODEL,
          w.EQUIPMENT_CLASS_ID,
          w.CLASS,
          w.CATEGORY_ID,
          w.CATEGORY,
          w.YEAR,
          w.SERIAL_NUMBER,
          w.VIN,
          w.ASSET_TYPE_ID,
          w.ASSET_TYPE,
          w.OEC,
          w.DATE_CREATED,
          w.PURCHASE_DATE,
          w.RENTAL_BRANCH_ID,
          w.INVENTORY_BRANCH_ID,
          w.FIRST_RENTAL,
          w.ASSET_CLASS,
          w.SERVICE_BRANCH_ID,
          w.BUSINESS_SEGMENT_ID,
          w.BUSINESS_SEGMENT_NAME,

          CASE
            WHEN d.ASSET_FIRST_RENTAL_START_DATE > DATE '2015-01-01'
            THEN DATEDIFF(
                   'MONTH',
                   d.ASSET_FIRST_RENTAL_START_DATE,
                   CURRENT_DATE
                 )
            ELSE NULL
          END AS asset_age_month

        FROM es_warehouse.public.assets_aggregate w
        LEFT JOIN platform.gold.dim_assets d
          ON w.ASSET_ID = d.ASSET_ID
      ) AS assets_aggregate
        ON assets_inventory."ASSET_ID" = assets_aggregate."ASSET_ID"

      LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_MODELS AS equipment_models
        ON equipment_models."EQUIPMENT_MODEL_ID" = assets_inventory."EQUIPMENT_MODEL_ID"

      LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES_MODELS_XREF AS equipment_classes_models_xref
        ON equipment_models."EQUIPMENT_MODEL_ID" = equipment_classes_models_xref."EQUIPMENT_MODEL_ID"

      LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES AS equipment_classes
        ON equipment_classes_models_xref."EQUIPMENT_CLASS_ID" =
           equipment_classes."EQUIPMENT_CLASS_ID"

      LEFT JOIN sub_categories
        ON equipment_classes."CATEGORY_ID" = sub_categories."CATEGORY_ID"

      LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK AS market_region_xwalk
        ON markets."MARKET_ID" = market_region_xwalk."MARKET_ID"

      LEFT JOIN ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY_STATUS AS scd_asset_inventory_status
        ON scd_asset_inventory_status."ASSET_ID" = assets_inventory."ASSET_ID"

      LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS rental_market
        ON rental_market."MARKET_ID" = assets_inventory."RENTAL_BRANCH_ID"

      LEFT JOIN market_class_on_rent_rates
        ON market_region_xwalk."MARKET_ID"           = market_class_on_rent_rates.market_id
       AND assets_inventory.equipment_class_id       = market_class_on_rent_rates.equipment_class_id

    WHERE
      assets_inventory."ASSET_TYPE_ID" = 1
      AND (
        NOT assets_inventory."DELETED"
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
      AND COALESCE(
            scd_asset_inventory_status."ASSET_INVENTORY_STATUS",
            'Unassigned'
          ) IS NOT NULL

    GROUP BY
      asset_physical."PARENT_CATEGORY_NAME",
      sub_categories.sub_category_name,
      equipment_classes."NAME",
      market_region_xwalk."REGION_NAME",
      market_region_xwalk."DISTRICT",
      market_region_xwalk."MARKET_NAME"
  )

-- Final Pull from grouped_oec, with all original measures
-- plus 4 levels of “percent_of_total_oec” and 4 levels of “unit_utilization” and “assigned+pre-delivered”
SELECT
  parent_category_name            AS category,
  sub_category_name               AS subcategory,
  equipment_classes_name          AS class,
  region_name,
  district,
  market_name,

  ----------------------------------------------------------------
  -- Total Assets
  ----------------------------------------------------------------
  total_asset_count,

  total_oec,

  SUM(total_oec) OVER () AS summed_total_oec,

ROUND(
  CASE
    WHEN summed_total_oec = 0 THEN NULL
    ELSE total_oec::numeric / summed_total_oec * 100
  END
, 6) AS percent_of_total_oec,
  ----------------------------------------------------------------
  -- Financial Utilization
  ----------------------------------------------------------------
  fin_util                                          AS financial_utilization,

  ----------------------------------------------------------------
  -- Average Monthly Rate for Open Contracts
  ----------------------------------------------------------------
  avg_price_per_month                               AS average_monthly_rate_for_open_contracts,

  ----------------------------------------------------------------
  -- Status‐based counts
  ----------------------------------------------------------------
  on_rent_asset_count,
  assigned_asset_count,
  unassigned_asset_count,
  ready_to_rent_asset_count,
  needs_inspection_asset_count,
  pending_return_asset_count,
  soft_down_asset_count,
  hard_down_asset_count,
  make_ready_asset_count,
  pre_delivered_asset_count,

  ----------------------------------------------------------------
  -- On RPO Asset Count
  ----------------------------------------------------------------
  count_of_on_rpo_assets,

  ----------------------------------------------------------------
  -- 9) MARKET + CLASS assigned+pre‐delivered utilization
  --    = (on_rent + assigned + pre_delivered) ÷ total_asset_count
  ----------------------------------------------------------------
   CASE
    WHEN total_asset_count = 0 THEN NULL
    ELSE (
      on_rent_asset_count
    )::DOUBLE PRECISION / total_asset_count
  END                                               AS market_class_unit_utilization,

  CASE
    WHEN total_asset_count = 0 THEN NULL
    ELSE (
      on_rent_asset_count
      + assigned_asset_count
      + pre_delivered_asset_count
    )::DOUBLE PRECISION / total_asset_count
  END                                               AS market_class_unit_utilization_assigned_predelivered,

  ----------------------------------------------------------------
  -- 10) DISTRICT + CLASS assigned+pre‐delivered utilization
  ----------------------------------------------------------------
   CASE
    WHEN SUM(COALESCE(total_asset_count,0))
         OVER (PARTITION BY sub_category_name, equipment_classes_name, district) = 0
    THEN NULL
    ELSE
      SUM(
        COALESCE(on_rent_asset_count,0)
      ) OVER (PARTITION BY sub_category_name, equipment_classes_name, district)::DOUBLE PRECISION
      /
      SUM(COALESCE(total_asset_count,0))
      OVER (PARTITION BY sub_category_name, equipment_classes_name, district)
  END                                               AS district_class_unit_utilization,

  CASE
    WHEN SUM(COALESCE(total_asset_count,0))
         OVER (PARTITION BY sub_category_name, equipment_classes_name, district) = 0
    THEN NULL
    ELSE
      SUM(
        COALESCE(on_rent_asset_count,0)
        + COALESCE(assigned_asset_count,0)
        + COALESCE(pre_delivered_asset_count,0)
      ) OVER (PARTITION BY sub_category_name, equipment_classes_name, district)::DOUBLE PRECISION
      /
      SUM(COALESCE(total_asset_count,0))
      OVER (PARTITION BY sub_category_name, equipment_classes_name, district)
  END                                               AS district_class_unit_utilization_assigned_predelivered,

  ----------------------------------------------------------------
  -- 11) REGION + CLASS assigned+pre‐delivered utilization
  ----------------------------------------------------------------
    CASE
    WHEN SUM(COALESCE(total_asset_count,0))
         OVER (PARTITION BY sub_category_name, equipment_classes_name, region_name) = 0
    THEN NULL
    ELSE
      SUM(
        COALESCE(on_rent_asset_count,0)
      ) OVER (PARTITION BY sub_category_name, equipment_classes_name, region_name)::DOUBLE PRECISION
      /
      SUM(COALESCE(total_asset_count,0))
      OVER (PARTITION BY sub_category_name, equipment_classes_name, region_name)
  END                                               AS region_class_unit_utilization,

  CASE
    WHEN SUM(COALESCE(total_asset_count,0))
         OVER (PARTITION BY sub_category_name, equipment_classes_name, region_name) = 0
    THEN NULL
    ELSE
      SUM(
        COALESCE(on_rent_asset_count,0)
        + COALESCE(assigned_asset_count,0)
        + COALESCE(pre_delivered_asset_count,0)
      ) OVER (PARTITION BY sub_category_name, equipment_classes_name, region_name)::DOUBLE PRECISION
      /
      SUM(COALESCE(total_asset_count,0))
      OVER (PARTITION BY sub_category_name, equipment_classes_name, region_name)
  END                                               AS region_class_unit_utilization_assigned_predelivered,

  ----------------------------------------------------------------
  -- 12) OVERALL + CLASS assigned+pre‐delivered utilization
  ----------------------------------------------------------------
    CASE
    WHEN SUM(COALESCE(total_asset_count,0))
         OVER (PARTITION BY sub_category_name, equipment_classes_name) = 0
    THEN NULL
    ELSE
      SUM(
        COALESCE(on_rent_asset_count,0)
      ) OVER (PARTITION BY sub_category_name, equipment_classes_name)::DOUBLE PRECISION
      /
      SUM(COALESCE(total_asset_count,0))
      OVER (PARTITION BY sub_category_name, equipment_classes_name)
  END                                               AS overall_class_unit_utilization,

  CASE
    WHEN SUM(COALESCE(total_asset_count,0))
         OVER (PARTITION BY sub_category_name, equipment_classes_name) = 0
    THEN NULL
    ELSE
      SUM(
        COALESCE(on_rent_asset_count,0)
        + COALESCE(assigned_asset_count,0)
        + COALESCE(pre_delivered_asset_count,0)
      ) OVER (PARTITION BY sub_category_name, equipment_classes_name)::DOUBLE PRECISION
      /
      SUM(COALESCE(total_asset_count,0))
      OVER (PARTITION BY sub_category_name, equipment_classes_name)
  END                                               AS overall_class_unit_utilization_assigned_predelivered

FROM grouped_oec
ORDER BY total_asset_count DESC
;;
  }

  dimension: row_id {
    type: string
    sql:
    CONCAT(
      ${subcategory}, '-',
      ${class},       '-',
      ${region_name}, '-',
      ${district},    '-',
      ${market_name}
    ) ;;
    primary_key: yes
    hidden: yes
  }


  # Dimensions (grouping keys)
  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: subcategory {
    type: string
    sql: ${TABLE}.subcategory ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}.class ;;
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

  # Measures (all the aggregated metrics)
  measure: total_asset_count {
    type: sum
    sql: ${TABLE}.total_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: count_of_on_rent_assets {
    type: sum
    sql: ${TABLE}.count_of_on_rent_assets ;;
    value_format_name: "decimal_0"
  }

  measure: on_rent_asset_count {
    type: sum
    sql: ${TABLE}.on_rent_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: assigned_asset_count {
    type: sum
    sql: ${TABLE}.assigned_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: unassigned_asset_count {
    type: sum
    sql: ${TABLE}.unassigned_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: ready_to_rent_asset_count {
    type: sum
    sql: ${TABLE}.ready_to_rent_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: needs_inspection_asset_count {
    type: sum
    sql: ${TABLE}.needs_inspection_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: pending_return_asset_count {
    type: sum
    sql: ${TABLE}.pending_return_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: soft_down_asset_count {
    type: sum
    sql: ${TABLE}.soft_down_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: hard_down_asset_count {
    type: sum
    sql: ${TABLE}.hard_down_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: make_ready_asset_count {
    type: sum
    sql: ${TABLE}.make_ready_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: pre_delivered_asset_count {
    type: sum
    sql: ${TABLE}.pre_delivered_asset_count ;;
    value_format_name: "decimal_0"
  }

  measure: count_of_on_rpo_assets {
    type: sum
    sql: ${TABLE}.count_of_on_rpo_assets ;;
    value_format_name: "decimal_0"
  }

  measure: total_oec {
    type: sum
    sql: ${TABLE}.total_oec ;;
    value_format_name: "usd"
  }

  measure: summed_total_oec {
    type: average
    sql: ${TABLE}.summed_total_oec ;;
    value_format_name: "usd"
  }

  measure: percent_of_total_oec {
    type: sum
    sql: ${TABLE}.percent_of_total_oec ;;
    value_format: "#.######################################################################################################################################################"
    description: "Does not quite get to 100 (number not %) due to Looker truncating values after 6 decimal spaces, effectively rounding down numbers. Do the calculation manually for better precision"
    }

  measure: financial_utilization {
    type: average
    sql: ${TABLE}.financial_utilization ;;
    value_format_name: "percent_2"
  }

  measure: market_class_unit_utilization {
    type: average
    sql: ${TABLE}.market_class_unit_utilization ;;
    value_format_name: "percent_2"
  }

  measure: district_class_unit_utilization {
    type: average
    sql: ${TABLE}.district_class_unit_utilization ;;
    value_format_name: "percent_2"
  }

  measure: region_class_unit_utilization {
    type: average
    sql: ${TABLE}.region_class_unit_utilization ;;
    value_format_name: "percent_2"
  }

  measure: overall_class_unit_utilization {
    type: average
    sql: ${TABLE}.overall_class_unit_utilization ;;
    value_format_name: "percent_2"
  }

  measure: market_class_unit_utilization_assigned_predelivered {
    type: average
    sql: ${TABLE}.market_class_unit_utilization_assigned_predelivered ;;
    value_format_name: "percent_2"
  }

  measure: district_class_unit_utilization_assigned_predelivered {
    type: average
    sql: ${TABLE}.district_class_unit_utilization_assigned_predelivered ;;
    value_format_name: "percent_2"
  }

  measure: region_class_unit_utilization_assigned_predelivered {
    type: average
    sql: ${TABLE}.region_class_unit_utilization_assigned_predelivered ;;
    value_format_name: "percent_2"
  }

  measure: overall_class_unit_utilization_assigned_predelivered {
    type: average
    sql: ${TABLE}.overall_class_unit_utilization_assigned_predelivered ;;
    value_format_name: "percent_2"
  }

  measure: average_monthly_rate_for_open_contracts {
    type: average
    sql: ${TABLE}.average_monthly_rate_for_open_contracts ;;
    value_format_name: "usd"
  }
}

view: aztec_inventory {
  derived_table: {
    sql: WITH T3_PROVIDERS AS (
          -- Pull active OEM list
          SELECT UPPER(TRIM(NAME)) AS NAME, PROVIDER_ID
          FROM INVENTORY.INVENTORY.PROVIDERS
          WHERE company_id = 1854
            AND DATE_ARCHIVED IS NULL
      ),
      T3_PARTS AS (
          -- Pull active Parts list
          SELECT UPPER(TRIM(PART_PROVIDER_NAME)) AS PART_PROVIDER_NAME,
                 UPPER(TRIM(PART_NUMBER)) AS PART_NUMBER,
                 PART_NAME
          FROM PLATFORM.GOLD.DIM_PARTS
          WHERE PART_INTERNAL_USE = TRUE
            AND PART_ARCHIVED = FALSE
      ),
      CONSOLIDATED_TABS AS (
        select manufacturer,
        part_number,
        description,
        count,
        bin,
        'League City' as tab,
        from analytics.financial_systems.aztec_league_city_gsheet
      union all
        select manufacturer,
        part_number,
        description,
        count,
        bin,
        'Port Arthur' as tab,
        from analytics.financial_systems.aztec_port_arthur_gsheet
      union all
        select manufacturer,
        part_number,
        description,
        count,
        bin,
        'Corpus Christi' as tab,
        from analytics.financial_systems.aztec_corpus_christi_gsheet
      union all
        select manufacturer,
        part_number,
        description,
        count,
        bin,
        'Midland' as tab,
        from analytics.financial_systems.aztec_midland_gsheet
      ),
      UPLOADED_DATA AS (
          -- Clean and map the single uploaded sheet
          -- Assuming your staging table is called STG_BAILEY_INVENTORY_REPORT
          SELECT
              CASE UPPER(TRIM(i.manufacturer))
                  WHEN 'WINTERS' THEN 'WINTERS INSTRUMENTS' -- doesn't exist in our sheet
                  WHEN 'DIXON' THEN 'DIXON VALVE' -- doesn't exist in our sheet
                  WHEN 'MCMASTER-CARR' THEN 'MCMASTER-CARR SUPPLY' -- exists in our sheet as 'MCMASTER-CARR'
                  WHEN 'NORBAR' THEN 'NORBAR TORQUE TOOLS' -- exists in our sheet as 'norbar torque tools'
                  WHEN 'A & A HYDRAULIC' THEN 'A & A HYDRAULIC REPAIR CO'
                  WHEN 'ANGLE REPAIR & CALIBRATION' THEN 'ANGLE REPAIR & CALIBRATION SERVICE, INC.'
                  WHEN 'EREPLACEMENTPARTS.COM' THEN 'EREPLACEMENTPARTS.COM INC.'
                  WHEN 'TUNGSTEN' THEN 'TUNGSTEN CAPITAL PARTNERS'
                  WHEN 'HYDRATIGHT' THEN 'HYDRATIGHT OPERATIONS, INC.'
                  WHEN 'INDUSTRIAL AIR TOOL' THEN 'INDUSTRIAL AIR TOOL, L.P., L.L.P.'
                  WHEN 'INTEGRATED SUPPLY NETWORK, LLC' THEN 'INTEGRATED SUPPLY NETWORK, INC (ISN)'
                  WHEN 'POWER TOOL SERVICE CO., INC.' THEN 'POWER TOOL SERVICE'
                  WHEN 'PLARAD' THEN 'PLARAD BOLTING TECHNOLOGY, LLC'
                  WHEN 'SNAP ON' THEN 'SNAP-ON INCORPORATED DBA FASTORQ'
                  WHEN 'SNAP-ON INDUSTRIAL BRANDS' THEN 'SNAP-ON INCORPORATED DBA FASTORQ'
                  WHEN 'CEJN' THEN 'CEJN AB'
                  ELSE UPPER(TRIM(i.manufacturer))
              END AS CLEAN_MFG,
              i.description,
              i.count,
              UPPER(TRIM(i.part_number)) AS CLEAN_PART_NUMBER,
              tab
          FROM CONSOLIDATED_TABS i
      ),
      MISSING_MFR_LIST AS (
          -- Find distinct manufacturers from the uploaded sheet that are missing in T3
          SELECT DISTINCT u.CLEAN_MFG
          FROM UPLOADED_DATA u
          LEFT JOIN T3_PROVIDERS p ON u.CLEAN_MFG = p.NAME
          -- Only flag it as a missing MFR if the vendor name isn't blank to begin with
          WHERE p.NAME IS NULL
            AND u.CLEAN_MFG IS NOT NULL
            AND u.CLEAN_MFG != ''
      ),
      CATEGORIZED_PARTS AS (
          -- Evaluate every uploaded part and assign it to its respective bucket
          SELECT
              u.CLEAN_MFG AS MFG,
              u.CLEAN_PART_NUMBER AS PART_NUMBER,
              u.description,
              u.count,
              t3.PART_NAME AS T3_PART_NAME,
              CASE
                  -- 1. Missing Manufacturer
                  WHEN u.CLEAN_MFG IS NULL OR u.CLEAN_MFG = '' THEN 'PART_NUMBER_MISSING_MFG'

      -- 2. Missing Part Number
      WHEN u.CLEAN_PART_NUMBER IS NULL OR u.CLEAN_PART_NUMBER = '' THEN 'MISSING_PART_NUMBER'

      -- 3. Manufacturer not in T3
      WHEN mml.CLEAN_MFG IS NOT NULL THEN 'PART_MFR_NOT_IN_T3'

      -- 4. Part not in T3 (Left Join failed)
      WHEN t3.PART_NUMBER IS NULL THEN 'PARTS_NOT_IN_T3'

      -- 5. Successful Match
      ELSE 'MATCHED_PARTS'
      END AS EXCEL_TAB_DESTINATION,
      tab

      FROM UPLOADED_DATA u
      -- LEFT JOIN STORES s
      -- ON u.warehousecode = s.warehousecode
      -- Join to check if the MFG is in our "missing" list
      LEFT JOIN MISSING_MFR_LIST mml
      ON u.CLEAN_MFG = mml.CLEAN_MFG
      -- Join to check if the Part exists in T3
      LEFT JOIN T3_PARTS t3
      ON u.CLEAN_MFG = t3.PART_PROVIDER_NAME
      AND u.CLEAN_PART_NUMBER = t3.PART_NUMBER
      )
      -- Output the final dataset
      SELECT *
      FROM CATEGORIZED_PARTS
      ORDER BY EXCEL_TAB_DESTINATION, MFG, PART_NUMBER;;
  }

  # Define your dimensions and measures here, like this:
  dimension: mfg {
    label: "Manufacturer"
    type: string
    sql: ${TABLE}.mfg ;;
  }

  dimension: part_number {
    label: "Part Number"
    type: string
    sql: ${TABLE}.part_number ;;
  }

  dimension: description {
    label: "Description"
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: count {
    label: "Count"
    type: number
    sql: ${TABLE}.count ;;
  }

  dimension: t3_part_name {
    label: "T3 Part Name"
    type: string
    sql: ${TABLE}.T3_PART_NAME ;;
  }

  dimension: category {
    label: "Category"
    type: string
    sql: ${TABLE}.EXCEL_TAB_DESTINATION ;;
  }

  dimension: tab {
    label: "Sheet tab"
    type: string
    sql: ${TABLE}.tab ;;
  }
}

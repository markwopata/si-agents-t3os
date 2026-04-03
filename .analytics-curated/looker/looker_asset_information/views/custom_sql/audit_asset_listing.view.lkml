view: audit_asset_listing {
    derived_table: {
        # SQL comes from tory_asset_listing.sql which is the abl_flash_oec code + fti report fields
        sql:   WITH rouse_a_additional_fields AS ( -- ls_lk from rouse A code
      SELECT aa.asset_id,
             aa.category_id,
             aa.category,
             GREATEST(DATEDIFF(MONTH, COALESCE(aa.purchase_date, aa.date_created),
                               CONVERT_TIMEZONE('UTC', 'America/Chicago',
                                                (({% date_start as_of_date_filter %}::DATE)::STRING || ' 23:59:59.999')::TIMESTAMP_NTZ)),
                      0)                                                                                         AS age,
             sais.asset_inventory_status,
             CASE WHEN ea.asset_id IS NULL THEN FALSE ELSE TRUE END                                              AS ever_rented,
             CASE
                 WHEN category_id IN (149, 514, 115, 660, 664, 662, 659, 518, 98, 661) THEN TRUE
                 ELSE FALSE END                                                                                  AS vehicle,
             CASE
                 WHEN ever_rented = FALSE AND vehicle = TRUE THEN FALSE
                 WHEN (sais.asset_inventory_status IS NULL OR sais.asset_inventory_status <> 'On Rent') AND
                      vehicle = TRUE THEN FALSE
                 ELSE TRUE END                                                                                   AS intended_for_rental,
             sar.intended_for_rental                                                                             AS fti_intended_rental_fleet
        FROM es_warehouse.public.assets_aggregate aa --                       join LS_STAGE.ROUSE_A_ASSETS RAA
--                            on AA.ASSET_ID = RAA.ASSET_ID
                 LEFT JOIN es_warehouse.scd.scd_asset_inventory_status sais
                           ON aa.asset_id = sais.asset_id AND CONVERT_TIMEZONE('UTC', 'America/Chicago',
                                                                               (({% date_start as_of_date_filter %}::DATE)::STRING || ' 23:59:59.999')::TIMESTAMP_NTZ) BETWEEN date_start AND date_end
                 LEFT JOIN (SELECT asset_id,
                                   MIN(start_date) AS first_rental
                              FROM es_warehouse.public.equipment_assignments
                             GROUP BY asset_id) ea
                           ON aa.asset_id = ea.asset_id
                 LEFT JOIN (SELECT DISTINCT asset_id,
                                            TRUE AS intended_for_rental
                              FROM es_warehouse.scd.scd_asset_rsp
                             WHERE date_start <= (({% date_start as_of_date_filter %}::DATE)::STRING || ' 23:59:59.999')::TIMESTAMP_NTZ
                               AND rental_branch_id IS NOT NULL
--                                  GROUP BY asset_id
--                                      qualify row_number() over (partition by asset_id order by date_start DESC) = 1
        ) sar
                           ON aa.asset_id = sar.asset_id
--     select ASSET_ID,
--            CATEGORY_ID,
--            CATEGORY,
--            AGE,
--            ASSET_INVENTORY_STATUS,
--            COALESCE(FTI_INTENDED_RENTAL_FLEET, INTENDED_FOR_RENTAL) AS intended_for_rental,
--            FTI_INTENDED_RENTAL_FLEET                                as fti_intended_for_rental
--     from ROUSE_A_ADDITIONAL_FIELDS
--
  )
SELECT aa.oec,
       sac.company_id,
       aa.asset_id,
       aa.make,
       aa.model,
       aa.asset_type,
       aa.first_rental,
       aa.year,
       ham.market_id,
       CASE
           WHEN vpp.payout_program_type_id IS NOT NULL OR sac.company_id = 6954
               THEN 'Y' -- Force all EZ Equipment to Contractor Owned (Sometimes may be a lag)
           ELSE 'N' END                                                                        contractor_owned_flag,
       CASE
           WHEN aa.asset_type IN ('vehicle', 'trailer') THEN 'rolling stock'
           ELSE 'equipment' -- Bucket everything else into equipment
           END                                                                                 asset_type_adj,
       CASE
           WHEN sched.sage_account_number = '8200' THEN 'pit-Operating'
           WHEN sched.lender = 'Non-Debt' THEN 'Non-Debt' -- prevent Non-Debt from showing as loan/cap lease
           WHEN LENGTH(sched.sage_account_number) > 1 AND LOWER(sched.sage_account_number) <> 'not needed'
               THEN 'Loan or Capital Lease' END                                                sage_operating_type,
       sched.financing_facility_type,
       sched.lender,
       sched.financial_schedule_id,
       sched.phoenix_id,
       sched.commencement_date,
       sched.sage_account_number,
       aphl.finance_status,
       CASE WHEN sac.company_id IN (1854, 1855, 8151, 61036) THEN 'owned' ELSE 'non-owned' END owned_status,
       aa.purchase_date,
       aa.date_created,
       aa.oec - LEAST(aa.oec * CASE
                                   WHEN aa.asset_type_id IN (2, 3)
                                       THEN .9 / (7 * 12) -- vehicle salvage = 10%, equip = 20%
                                   ELSE .8 / (10 * 12) END * GREATEST(0, -- Prevent negative months diff
       /*months*/ COALESCE(DATEDIFF(MONTH, CASE
                                               WHEN aa.asset_type_id = 1 THEN aa.first_rental
                                               ELSE COALESCE(aa.purchase_date, aa.date_created) END, dates.date) + 0.5,
                           0)),
                    /*Salvage Value*/aa.oec * CASE WHEN aa.asset_type_id IN (2, 3) THEN .9 ELSE .8 END) *
                CASE WHEN aa.first_rental IS NULL AND aa.asset_type_id = 1 THEN 0 ELSE 1 END   nbv,
       dates.date,
       CASE
           WHEN contractor_owned_flag = 'Y' THEN 'Contractor Owned OEC'
           WHEN owned_status <> 'owned' THEN 'Non ES-Owned'
           WHEN sage_operating_type = 'pit-Operating' AND owned_status = 'owned' THEN 'Operating Lease OEC'
           WHEN sage_operating_type = 'pit-Operating' THEN 'Other Operating Lease'
           WHEN sched.financial_schedule_id IN (1539, 1612)
               THEN 'other' -- hard exclude these, they claim to be Sold and paid off, should not have company_id 1854 OR an error FS_ID
           WHEN asset_type_adj = 'equipment' AND
                (aphl_status = 'cash owned' OR sage_operating_type = 'Loan or Capital Lease') THEN 'Owned Rental OEC'
           WHEN asset_type_adj = 'rolling stock' AND
                (aphl_status = 'cash owned' OR sage_operating_type = 'Loan or Capital Lease')
               THEN 'Owned Rolling Stock OEC'
           ELSE 'other' END                                                                    report_category,
       CURRENT_TIMESTAMP()                                                                     snapshot_date,
       aphl.aphl_status,
       aa.category,
       aa.serial_number,
       aa.vin,
       COALESCE(raaf.asset_inventory_status, 'Other')                                          status,
       a.description,
       copli.order_status,
       mtf.rental_branch_id,
       mtf.inventory_branch_id
  FROM es_warehouse.public.assets_aggregate aa
           JOIN (SELECT CONVERT_TIMEZONE('UTC', 'America/Chicago', {% date_start as_of_date_filter %})::DATE DATE) AS dates
           JOIN es_warehouse.public.assets a
                ON aa.asset_id = a.asset_id
           LEFT JOIN rouse_a_additional_fields raaf
                     ON aa.asset_id = raaf.asset_id
           JOIN es_warehouse.scd.scd_asset_company sac -- Historical company_id
                ON aa.asset_id = sac.asset_id AND
                   dates.date || ' 23:59:59.999' BETWEEN sac.date_start AND COALESCE(sac.date_end, '2099-12-31')
           LEFT JOIN (SELECT asset_id,
                             MIN(start_date)
                                 OVER (PARTITION BY asset_id, COALESCE(end_date, '2099-12-31'::TIMESTAMPTZ) ORDER BY asset_id, COALESCE(end_date, '2099-12-31'::TIMESTAMPTZ) DESC)          start_date,
                             MAX(COALESCE(end_date, '2099-12-31'::TIMESTAMPTZ))
                                 OVER (PARTITION BY asset_id, COALESCE(end_date, '2099-12-31'::TIMESTAMPTZ) ORDER BY asset_id, COALESCE(end_date, '2099-12-31'::TIMESTAMPTZ) DESC)          end_date,
                             payout_program_type_id,
                             ROW_NUMBER() OVER (PARTITION BY asset_id, COALESCE(end_date, '2099-12-31'::TIMESTAMPTZ) ORDER BY asset_id, COALESCE(end_date, '2099-12-31'::TIMESTAMPTZ) DESC) rn
                        FROM es_warehouse.public.v_payout_programs) vpp -- Contractor Owned Program
                     ON aa.asset_id = vpp.asset_id AND
                        dates.date || ' 23:59:59.999' BETWEEN vpp.start_date AND COALESCE(vpp.end_date, '2099-12-31') AND
                        vpp.rn = 1
           LEFT JOIN (SELECT asset_id, market_id from analytics.public.historical_asset_market
                                       qualify row_number() over (partition by ASSET_ID order by DATE DESC) = 1) ham -- Use to get market_id
                     ON aa.asset_id = ham.asset_id --AND ham.date = dates.date
           LEFT JOIN (SELECT DISTINCT COALESCE(aphl.asset_id, aph.asset_id)                                                                    asset_id,
                                      txdt.financing_facility_type,
                                      pit.sage_account_number,
                                      pit.lender,
                                      txdt.commencement_date,
                                      pit.phoenix_id,
                                      pit.financial_schedule_id,
                                      ROW_NUMBER() OVER (PARTITION BY COALESCE(aphl.asset_id, aph.asset_id) ORDER BY aphl.date_generated DESC) rn
                        FROM es_warehouse.public.asset_purchase_history aph
                                 LEFT JOIN es_warehouse.public.asset_purchase_history_logs aphl
                                           ON aph.purchase_history_id = aphl.purchase_history_id AND
                                              aphl.date_generated < {% date_start as_of_date_filter %}::DATE + 1 -- My Date
                            AND aphl.DATE_GENERATED >= '2020-08-01' JOIN analytics.debt.PHOENIX_ID_TYPES pit
                          ON coalesce(aphl.financial_schedule_id, aph.FINANCIAL_SCHEDULE_ID) = pit.FINANCIAL_SCHEDULE_ID LEFT JOIN analytics.debt.TV6_XML_DEBT_TABLE_CURRENT txdt ON pit.PHOENIX_ID = txdt.PHOENIX_ID
                       WHERE (txdt.current_version = 'Yes'
                         AND txdt.gaap_non_gaap = 'Non-GAAP'
                         AND txdt.COMMENCEMENT_DATE
                           < {% date_start as_of_date_filter %}::DATE + 1)
                          OR txdt.PHOENIX_ID IS NULL --allow the left join to return nulls in txdt
  ) sched
                     ON aa.asset_id = sched.asset_id AND (sched.commencement_date <= dates.date OR
                                                          sched.commencement_date IS NULL) -- allow non-debt schedules so we can use that as filter
                         AND sched.rn = 1
           LEFT JOIN (SELECT asset_id,
                             finance_status,
                             CASE
                                 WHEN (LOWER(finance_status) LIKE '%cash%' OR
                                       LOWER(finance_status) LIKE '%completed%' OR
                                       financial_schedule_id IN (2399, 2769)) -- Schedule for paid in cash
                                     AND LOWER(finance_status) NOT LIKE '%cash deposit%' -- Cash deposit is used as an
                                 -- interim status between net terms and paid in cash. Implies cash paid out for an
                                 -- asset that will be on an operating lease
                                     THEN 'cash owned'
                                 ELSE '' END aphl_status
                        FROM es_warehouse.public.asset_purchase_history_logs aphl
                       WHERE aphl.date_generated >= '2020-08-01'                           -- Data before August is not good
                         AND aphl.date_generated < {% date_start as_of_date_filter %}::DATE + 1 -- My Date
                         AND (aphl.finance_status IS NOT NULL
                         AND aphl.FINANCE_STATUS <> '')
                     QUALIFY row_number() OVER (PARTITION BY asset_id ORDER BY date_generated DESC) = 1 -- Rank and select last entry before our end date (last
  ) aphl
                     ON aphl.asset_id = aa.asset_id
           LEFT JOIN (SELECT DISTINCT asset_id,
                                      order_status
                        FROM es_warehouse.public.company_purchase_order_line_items
                       WHERE asset_id IS NOT NULL) copli
                     ON aa.asset_id = copli.asset_id
           LEFT JOIN (SELECT asset_id,
                             inventory_branch_id, --- This is to flag to tell if the market being used in inventory or rental branch. Kinzie Leach wanted this KC 6/10/24
                             rental_branch_id
                      FROM es_warehouse.public.assets ) mtf
                      ON aa.asset_id = mtf.asset_id

      ;;
  }



  filter: as_of_date_filter {
    type: date_time
    convert_tz: yes
  }

  dimension: as_of_date {
      label: "As of Date"
      type: date
      sql: ${TABLE}.DATE ;;
  }

  dimension: asset_id {
      type: number
      value_format: "0"
      sql: ${TABLE}.ASSET_ID ;;
  }

  dimension: make {
      type: string
      sql: ${TABLE}.MAKE ;;
  }

  dimension: model {
      type: string
      sql: ${TABLE}.MODEL ;;
  }

  dimension: market_id {
      type: number
      value_format: "0"
      sql: ${TABLE}.MARKET_ID ;;
  }

  dimension: inventory_branch_id {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: rental_branch_id {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: market_from{
    type: string
    sql: CASE WHEN ${rental_branch_id} is null then 'Fleet' else 'ES Admin' end;;
  }

  dimension: company_id {
      type: number
      value_format: "0"
      sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: oec {
      type: number
      label: "OEC"
      value_format: "#,##0.00;(#,##0.00);-"
      sql: ${TABLE}.OEC ;;
  }

  dimension: asset_type {
      type: string
      sql: ${TABLE}.asset_type ;;
  }

  dimension: first_rental {
      type: date_time
      sql: ${TABLE}.first_rental ;;
  }

  dimension: year {
      type: string
      sql: ${TABLE}.year ;;
  }

  dimension: contractor_owned_flag {
      type: string
      sql: ${TABLE}.contractor_owned_flag ;;
  }

  dimension: asset_type_adj {
      type: string
      sql: ${TABLE}.asset_type_adj ;;
  }

  dimension: sage_operating_type {
      type: string
      sql: ${TABLE}.sage_operating_type ;;
  }

  dimension: financing_facility_type {
      type: string
      sql: ${TABLE}.FINANCING_FACILITY_TYPE ;;
  }

  dimension: lender {
      type: string
      sql: ${TABLE}.lender ;;
  }

  dimension: financial_schedule_id {
      type: number
      value_format: "0"
      sql: ${TABLE}.financial_schedule_id ;;
  }

  dimension: phoenix_id {
      type: number
      value_format: "0"
      sql: ${TABLE}.phoenix_id ;;
  }

  dimension: commencement_date {
      type: date_time
      sql: ${TABLE}.commencement_date ;;
  }

  dimension: sage_account_number {
      type: string
      sql: ${TABLE}.sage_account_number ;;
  }

  dimension: finance_status {
      type: string
      sql: ${TABLE}.finance_status ;;
  }

  dimension: owned_status {
      type: string
      sql: ${TABLE}.owned_status ;;
  }

  dimension: purchase_date {
      type: date_time
      sql: ${TABLE}.purchase_date ;;
  }

  dimension: date_created {
      type: date_time
      sql: ${TABLE}.date_created ;;
  }

  dimension: nbv {
      type: number
      label: "NBV"
      value_format: "#,##0.00;(#,##0.00);-"
      sql: ${TABLE}.nbv ;;
  }

  dimension: report_category {
      type: string
      sql: ${TABLE}.report_category ;;
  }

  dimension: category {
      type: string
      sql: ${TABLE}.category ;;
  }

  dimension: serial_number {
      type: string
      sql: ${TABLE}.serial_number ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}.VIN ;;
  }

  dimension: status {
      type: string
      sql: ${TABLE}.status ;;
  }

  dimension: aphl_status {
      type: string
      sql: ${TABLE}.aphl_status ;;
  }

  dimension: description {
      type: string
      sql: ${TABLE}.description ;;
  }

  # Fleet track order status
  dimension: order_status {
    type: string
    sql: ${TABLE}."ORDER_STATUS" ;;
  }

}

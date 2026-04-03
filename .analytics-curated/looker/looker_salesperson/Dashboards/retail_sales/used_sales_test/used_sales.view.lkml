view: recent_sales {
  derived_table:{
    sql: --new query for used sales
WITH sales_data AS (  -- (original CTE)
  SELECT
    li.asset_id,
    i.company_id,
    li.line_item_type_id,
    vli.line_item_type,
    CASE
      WHEN li.line_item_type_id = 81 THEN 'used'
      WHEN li.line_item_type_id = 24 THEN 'new'
      WHEN li.line_item_type_id = 80 THEN 'new dealership'
      ELSE 'other'
    END AS equipment_sale_type,
    li.amount                           AS sale_amount,
    i.salesperson_user_id,
    vli.gl_billing_approved_date        AS sales_date,
    CONCAT(u.first_name, ' ', u.last_name) AS sales_person_full_name,
    CASE WHEN (
      li.asset_id IN (
        SELECT afs.asset_id
        FROM analytics.public.asset_financing_snapshots afs
        WHERE category = 'Contractor Owned OEC'
          AND date = LAST_DAY(DATEADD(MONTH, -1, CURRENT_DATE))
      )
      OR i.company_id IN (6954, 55524, 73584, 111143, 109626)
    ) THEN 'Y' ELSE 'N' END AS OWN_SALE_FLAG,
    CASE WHEN dafo.asset_oem_deal_flag = TRUE THEN 'Y' ELSE 'N' END AS asset_oem_deal_flag,
    CASE
      WHEN aa.make ILIKE '%wacker%' THEN 'Y'
      WHEN aa.make ILIKE '%sany%' AND (
        aa.model ILIKE '%SY135%' OR aa.model ILIKE '%SY155%' OR
        aa.model ILIKE '%SY215%' OR aa.model ILIKE '%SY225%' OR
        aa.model ILIKE '%SY235%' OR aa.model ILIKE '%SY265%' OR
        aa.model ILIKE '%SY365%' OR aa.model ILIKE '%SY500%'
      ) THEN 'Y'
      ELSE 'N'
    END AS subsidy_deal_flag,
    li.branch_id,
    m.name AS branch_name,
    sm.name AS salesperson_branch_name,
    d.district_id,
    d.name AS district_name,
    r.region_id,
    CONCAT(r.region_id, '-', d.district_id) AS region_district_id,
    r.name AS region_name,
    cnli.amount AS credit_amount,
    aa.make,
    aa.model,
    aa.oec
  FROM es_warehouse.public.line_items li
  LEFT JOIN fleet_optimization.gold.dim_assets_fleet_opt dafo
    ON li.asset_id = dafo.asset_id
  LEFT JOIN analytics.public.v_line_items vli
    ON li.line_item_id = vli.line_item_id
  LEFT JOIN es_warehouse.public.invoices i
    ON vli.invoice_id = i.invoice_id
  LEFT JOIN es_warehouse.public.users u
    ON u.user_id = i.salesperson_user_id
  LEFT JOIN es_warehouse.public.markets sm
    ON u.branch_id = sm.market_id
  LEFT JOIN es_warehouse.public.markets m
    ON vli.branch_id = m.market_id
  LEFT JOIN es_warehouse.public.districts d
    ON m.district_id = d.district_id
  LEFT JOIN es_warehouse.public.credit_note_line_items cnli
    ON vli.line_item_id = cnli.line_item_id
  LEFT JOIN es_warehouse.public.regions r
    ON d.region_id = r.region_id
  LEFT JOIN es_warehouse.public.assets_aggregate aa
    ON li.asset_id = aa.asset_id
  WHERE vli.line_item_type_id IN (81, 24, 80)
    AND i.salesperson_user_id IS NOT NULL      -- fix: don't use the full-name alias in WHERE
),

-- 1) Rouse valuation NBV just prior to sale; convert 0 to NULL
valuation_nbv AS (
  SELECT
    sd.asset_id,
    sd.sales_date,
    NULLIF(aere.net_book_value, 0) AS valuation_nbv,
    aere.date_created              AS valuation_nbv_date
  FROM sales_data sd
  LEFT JOIN data_science.fleet_opt.all_equipment_rouse_estimates aere
    ON aere.asset_id = sd.asset_id
   AND aere.date_created < sd.sales_date
  QUALIFY ROW_NUMBER()
    OVER (PARTITION BY sd.asset_id, sd.sales_date
          ORDER BY aere.date_created DESC) = 1
),

-- 2) Financing snapshot NBV just prior to (or on) sale; keep zeros as-is
old_nbv AS (
  SELECT
    sd.asset_id,
    sd.sales_date,
    afs.nbv        AS old_nbv,
    afs.date       AS old_nbv_date
  FROM sales_data sd
  LEFT JOIN analytics.public.asset_financing_snapshots afs
    ON afs.asset_id = sd.asset_id
   AND afs.date <= sd.sales_date
  QUALIFY ROW_NUMBER()
    OVER (PARTITION BY sd.asset_id, sd.sales_date
          ORDER BY afs.date DESC) = 1
)

-- 3) Final select with COALESCE
SELECT
  sd.*,
  v.valuation_nbv,
  v.valuation_nbv_date,
  o.old_nbv,
  o.old_nbv_date,
  COALESCE(v.valuation_nbv, o.old_nbv) AS nbv_prior_to_sale,
  IFF(v.valuation_nbv IS NOT NULL, v.valuation_nbv_date, o.old_nbv_date) AS nbv_date
FROM sales_data sd
LEFT JOIN valuation_nbv v
  ON v.asset_id = sd.asset_id AND v.sales_date = sd.sales_date
LEFT JOIN old_nbv o
  ON o.asset_id = sd.asset_id AND o.sales_date = sd.sales_date
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
    value_format_name: usd
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name:id
  }

  dimension: sales_date {
    type: date
    sql: ${TABLE}."SALES_DATE" ;;
  }

  dimension_group: sales_grouped  {
    type: time
    sql: ${TABLE}."SALES_DATE" ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
    value_format_name: id
  }

  dimension: line_item_type {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE" ;;
  }

  dimension: equipment_sale_type {
    type: string
    sql: ${TABLE}."EQUIPMENT_SALE_TYPE" ;;
  }

  dimension: credit_note_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
    value_format_name: id
  }

  dimension: sale_amount {
    type: number
    sql: ${TABLE}."SALE_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: net_book_value {
    type: number
    sql: ${TABLE}."NBV_PRIOR_TO_SALE" ;;
    value_format_name: usd
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
    value_format_name: id
  }

  dimension: gl_billing_approved_date {
    type: date
    sql: ${TABLE}."GL_BILLING_APPROVED_DATE" ;;
  }

  dimension: sales_person_full_name {
    type: string
    sql: ${TABLE}."SALES_PERSON_FULL_NAME" ;;
  }

  dimension: own_sale_flag {
    type: string
    sql: ${TABLE}."OWN_SALE_FLAG" ;;
  }

  dimension: oem_deal_flag {
    type: string
    sql: ${TABLE}."ASSET_OEM_DEAL_FLAG" ;;
  }

  dimension: subsidy_deal_flag {
    type: string
    sql: ${TABLE}."SUBSIDY_DEAL_FLAG" ;;
  }

  dimension: region_district_id {
    type: string
    sql: ${TABLE}."REGION_DISTRICT_ID" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format_name: id
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
    label: "Sale-Credited Branch"
  }

  dimension: salesperson_branch_name {
    type: string
    sql: ${TABLE}."SALESPERSON_BRANCH_NAME" ;;
  }

  dimension: district_id {
    type: number
    sql: ${TABLE}."DISTRICT_ID" ;;
    value_format_name: id
  }

  dimension: district_name {
    type: string
    sql: ${TABLE}."DISTRICT_NAME" ;;
  }

  dimension: region_id {
    type: number
    sql: ${TABLE}."REGION_ID" ;;
    value_format_name: id
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: subsidy {
    type: number
    sql: case when make ilike '%wacker%' and model ilike 'SW%' then 10000
                when (make ilike '%SANY%' and model ilike '%SY135%') then 11500
                when (make ilike '%SANY%' and model ilike '%SY155%') then 11500
                when (make ilike '%SANY%' and model ilike '%SY215%') then 17000
                when (make ilike '%SANY%' and model ilike '%SY225%') then 17000
                when (make ilike '%SANY%' and model ilike '%SY235%') then 17000
                when (make ilike '%SANY%' and model ilike '%SY265%') then 23000
                when (make ilike '%SANY%' and model ilike '%SY365%') then 28000
                when (make ilike '%SANY%' and model ilike '%SY500%') then 35000
                else 0
           end;;
    value_format_name: usd
  }

  dimension: sale_margin_amount {
    type: number
    sql: ${sale_amount} - ${net_book_value} ;;
    value_format_name: usd
  }

  dimension: sale_margin_percent {
    type: number
    sql: (${sale_amount} - ${net_book_value}) / ${sale_amount} ;;
    value_format_name: percent_2
  }

  dimension: credit_amount {
    type: number
    sql: ${TABLE}."CREDIT_AMOUNT" ;;
    value_format_name: usd
  }

  measure: total_sales {
    type: sum
    sql: ${sale_amount} ;;
    value_format_name:  usd
  }

  measure: total_used_sales {
    type: sum
    sql: ${sale_amount};;
    value_format_name: usd
    filters: [line_item_type_id: "81"]
  }

  measure: total_new_sales {
    type: sum
    sql: ${sale_amount} ;;
    value_format_name: usd
    filters: [line_item_type_id: "24"]
  }

  measure: total_new_dealership_sales {
    type: sum
    sql: ${sale_amount} ;;
    value_format_name:  usd
    filters: [line_item_type_id: "80"]
  }

  measure: total_subsidy {
    type: sum
    sql: ${subsidy} ;;
    value_format_name: usd
  }

  measure: avg_sales_price {
    type: average
    sql: ${sale_amount} ;;
    value_format_name:  usd
  }

  measure: total_oec {
    type: sum
    sql: ${oec} ;;
    value_format_name: usd
  }

  measure: avg_net_book_value {
    type: average
    sql: ${net_book_value} ;;
    value_format_name: usd
  }

  measure: total_net_book_value {
    type: sum
    sql: ${net_book_value} ;;
    value_format_name: usd
  }

  measure: total_used_net_book_value {
    type: sum
    sql: ${net_book_value} ;;
    value_format_name: usd
    filters: [line_item_type_id: "81"]
  }

  measure: total_new_net_book_value {
    type: sum
    sql: ${net_book_value} ;;
    value_format_name: usd
    filters: [line_item_type_id: "24"]
  }

  measure: total_new_fleet_credits {
    type: sum
    sql: ${credit_amount} ;;
    filters: [line_item_type_id: "24"]
    value_format_name: usd_0
  }

  measure: total_used_fleet_credits {
    type: sum
    sql: ${credit_amount} ;;
    filters: [line_item_type_id: "81"]
    value_format_name: usd_0
  }
  measure: total_dealship_fleet_credits {
    type: sum
    sql: ${credit_amount} ;;
    filters: [line_item_type_id: "80"]
    value_format_name: usd_0
  }

  measure: total_sale_margin_dollars {
    type: sum
    sql: ${sale_margin_amount} ;;
    value_format_name: usd
  }

  measure: avg_sale_margin_dollars {
    type: average
    sql: ${sale_margin_amount} ;;
    value_format_name: usd
  }

  set: detail {
    fields: [asset_id, company_id, sales_date, line_item_type_id, line_item_type, equipment_sale_type, sale_amount, net_book_value, salesperson_user_id,
      gl_billing_approved_date, sales_person_full_name, own_sale_flag, oem_deal_flag, branch_id, branch_name, district_id, district_name, region_id, make, region_name, credit_amount]
  }
}

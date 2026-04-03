view: assets_by_market {
  derived_table: {
    sql:
with latest_asset_cpoli_info as (
select
    *
from ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS as cpoli
qualify rank() over (partition by cpoli.ASSET_ID order by cpoli._ES_UPDATE_TIMESTAMP desc) = 1
),
latest_asset_rental_info as (
select
    *
from ES_WAREHOUSE.PUBLIC.RENTALS as rent
qualify rank() over (partition by rent.ASSET_ID order by rent.RENTAL_ID desc) = 1
),
latest_on_rent as (
select
    *
from latest_asset_rental_info as lari
where lari.RENTAL_STATUS_ID = 5 -- on rent
),
dual_tracker_mapping as
(
 SELECT
  da1854.ASSET_ID AS ASSET_ID,
  da172946.ASSET_ID AS SECONDARY_TRACKER_ASSET_ID
FROM platform.gold.dim_assets da1854
JOIN platform.gold.dim_assets da172946
  ON da1854.ASSET_COMPANY_ID = 1854
 AND da172946.ASSET_COMPANY_ID = 172946
 AND TRY_TO_NUMBER(da172946.ASSET_CUSTOM_NAME) = da1854.ASSET_ID
)
,dual_trackers as
(
SELECT asset_id
FROM dual_tracker_mapping
UNION
select SECONDARY_TRACKER_ASSET_ID as asset_id
FROM dual_tracker_mapping
)
SELECT
    asg.ASSET_ID,
    CASE
      WHEN asg.OWNER regexp 'IES\\d+.*' THEN 'Retail'
      WHEN asg.OWNER = 'IES-Attachments' THEN 'Retail'
      WHEN asg.OWNER = 'IES-RPO' THEN 'Retail'
      WHEN asg.OWNER = 'IES - Fleet Trade In' THEN 'Retail'
      ELSE ''
    END AS retail_type,
    assets.DESCRIPTION,
    asg.CATEGORY,
    asg.SERIAL_NUMBER,
    asg.VIN,
    aph.ASSET_INVOICE_URL AS invoice_numbers,
    aph.PURCHASE_ORDER_URL AS po_number,
    asg.OWNER,
    asg.CLASS,
    asg.MAKE,
    asg.MODEL,
    asg.EQUIPMENT_CLASS_ID,
    asg.YEAR,
    CASE
        WHEN {% parameter Include_Service_Branch %} = 'yes' THEN COALESCE(asg.RENTAL_BRANCH_ID,asg.SERVICE_BRANCH_ID, asg.INVENTORY_BRANCH_ID)
        ELSE COALESCE(asg.RENTAL_BRANCH_ID,asg.INVENTORY_BRANCH_ID)
    END AS asset_market_id,
    mark.market_name,
    askv.VALUE AS rental_status,
    asg.OEC,
    CASE
        WHEN COALESCE(asg.RENTAL_BRANCH_ID,asg.SERVICE_BRANCH_ID, asg.INVENTORY_BRANCH_ID) = asg.RENTAL_BRANCH_ID THEN 'Correct'
        WHEN COALESCE(asg.RENTAL_BRANCH_ID,asg.SERVICE_BRANCH_ID, asg.INVENTORY_BRANCH_ID) = asg.INVENTORY_BRANCH_ID THEN 'Correct'
        ELSE 'Service Branch'
    END AS branch_check,
    asg.SERVICE_BRANCH_ID,
    asg.RENTAL_BRANCH_ID,
    asg.INVENTORY_BRANCH_ID,
    CASE
        WHEN po.MODIFIED_AT > po.APPROVED_AT THEN 'pending_approval'
        WHEN po.MODIFIED_AT < po.APPROVED_AT THEN 'approved'
        WHEN po.APPROVED_AT is not null and po.MODIFIED_AT is null THEN 'approved'
        ELSE 'unknown'
    END as po_approval_status,
    laci.RECONCILIATION_STATUS,
    laci.ATTACHMENTS,
    laci.FINANCE_STATUS,
    iff(c.NAME ilike '%(RPO)%','RPO','') as RPO_FLAG,
    aph.FREIGHT_AMOUNT,
    case when exists (select 1
                      from ES_WAREHOUSE.PUBLIC.RENTALS r
                      where r.asset_id = asg.asset_id) then 'Used'
                      else 'New'
                      end as usage_status,
     CASE WHEN askv.VALUE NOT IN ('Hard Down','Ready to Rent')
        AND (dt.asset_id is not null OR ASSET_RENTABLE = True)
        AND
        (
        usaot.ASSET_ID is not null --manual assets added
        OR usmft.MARKET_ID is not null --onsite market list
        OR dt.asset_id is not null --dual engine/tracker assets
        OR (market_region=2 and market_type in('Core Solutions','Advanced Solutions') AND market_active)
        )
        THEN true ELSE false END AS UMC_MONITORED
FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AS asg
LEFT JOIN FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT AS mark
    ON asset_market_id = mark.MARKET_ID
LEFT JOIN FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT dafo
    ON asg.ASSET_ID = dafo.ASSET_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS AS assets
    ON asg.ASSET_ID = assets.ASSET_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES AS askv
    ON asg.ASSET_ID = askv.ASSET_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY AS aph
    ON asg.ASSET_ID = aph.ASSET_ID
LEFT JOIN latest_asset_cpoli_info as laci
    ON asg.ASSET_ID = laci.ASSET_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDERS AS PO
    ON laci.COMPANY_PURCHASE_ORDER_ID = po.COMPANY_PURCHASE_ORDER_ID
LEFT JOIN latest_on_rent as lor
    ON asg.ASSET_ID = lor.ASSET_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.ORDERS as O
    ON lor.ORDER_ID = o.ORDER_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS as U
    ON o.USER_ID = u.USER_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES as C
    ON u.COMPANY_ID = C.COMPANY_ID
LEFT JOIN ANALYTICS.SERVICE.UMC_SEED_ASSET_OVERRIDES_TEMP usaot
    ON usaot.ASSET_ID = asg.ASSET_ID
    and usaot.IS_CURRENT
LEFT JOIN ANALYTICS.SERVICE.UMC_SEED_MARKET_FLAGS_TEMP usmft
    ON usmft.MARKET_ID = mark.MARKET_ID
    and usmft.IS_CURRENT
LEFT JOIN dual_trackers dt
    ON dt.asset_id = asg.ASSET_ID
WHERE askv.NAME = 'asset_inventory_status';;
  }

  parameter: Include_Service_Branch{
    type: string
    allowed_value: {
      value: "yes"
    }
    allowed_value: {
      value: "no"
    }
  }

  dimension: asset_id {
    description: "The unique ID of the asset"
    type: number
    sql:  ${TABLE}.ASSET_ID ;;
  }

  dimension: asset_description {
    description: "Asset description"
    type: string
    sql:  ${TABLE}.DESCRIPTION ;;
  }

  dimension: asset_category {
    description: "Asset category"
    type: string
    sql:  ${TABLE}.CATEGORY ;;
  }

  dimension: serial_number {
    type: string
    sql:  ${TABLE}.SERIAL_NUMBER ;;
  }

  dimension: vin {
    type: string
    sql:  ${TABLE}.VIN ;;
  }

  dimension: owner {
    type: string
    sql:  ${TABLE}.OWNER ;;
  }

  dimension: asset_class {
    type: string
    sql:  ${TABLE}.CLASS ;;
  }

  dimension: asset_make {
    type: string
    sql:  ${TABLE}.MAKE ;;
  }

  dimension: asset_model {
    type: string
    sql:  ${TABLE}.MODEL ;;
  }

  dimension: asset_year {
    type: number
    sql:  ${TABLE}.YEAR ;;
  }

  dimension: market_id {
    type: number
    sql:  ${TABLE}.asset_market_id ;;
  }

  dimension: market_name {
    type: string
    sql:  ${TABLE}.market_name ;;

    html:
      {% if branch_check._value == "Correct" %}

            <span style="background-color:rgba(0, 128, 0, 0.2);">{{ market_name._value }}</span>

      {% else %}

            <span style="background-color:rgba(255, 0, 0, 0.2);">{{ market_name._value }}</span>

      {% endif %} ;;
  }

  dimension: retail_type {
    type: string
    sql:  ${TABLE}.retail_type ;;

    html:
      {% if retail_type._value  == "Retail" %}

            <span style="background-color:rgba(255, 255, 0, 0.4);">{{ retail_type._value }}</span>

      {% else %}

      <span>{{ retail_type._value }}</span>

      {% endif %} ;;
  }

  dimension: rental_status {
    type: string
    sql:  ${TABLE}.rental_status ;;
  }

  dimension: oec {
    type: number
    sql:  ${TABLE}.OEC ;;
  }

  dimension: invoice_numbers {
    type: string
    sql: ${TABLE}.invoice_numbers ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}.po_number ;;
  }

  measure: oec_sum {
    type: sum
    sql:  ${TABLE}.OEC  ;;
  }

  dimension: service_branch_id {
    type:  number
    sql: ${TABLE}.service_branch_id ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}.rental_branch_id ;;
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}.inventory_branch_id ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}.equipment_class_id ;;
  }

  dimension: usage_status {
    type: string
    sql: ${TABLE}.usage_status ;;
  }

  dimension: branch_check {
    type: string
    sql: ${TABLE}.branch_check ;;

    html:
      {% if branch_check._value  == "Correct" %}

      <span style="background-color:green;">{{ branch_check._value }}</span>

      {% else %}

      <span style="background-color:red;">{{ branch_check._value }}</span>

      {% endif %} ;;
  }

  dimension: po_approval_status{
    type: string
    sql: ${TABLE}.po_approval_status ;;
  }

  dimension: reconciliation_status{
    type: string
    sql: ${TABLE}.reconciliation_status ;;
  }

  dimension: attachments{
    type: string
    sql: ${TABLE}.attachments ;;
  }

  dimension: financial_status{
    type: string
    sql: ${TABLE}.finance_status ;;
  }

  dimension:  RPO_flag{
    type: string
    label: "RPO"
    sql: ${TABLE}.RPO_flag ;;
  }

  dimension: freight_amount {
    type: number
    sql: ${TABLE}.FREIGHT_AMOUNT ;;
  }

  dimension: umc_monitored {
    type: yesno
    sql: ${TABLE}.UMC_MONITORED ;;
  }

  measure: count_assets {
    type:  count
  }
}

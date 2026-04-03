
view: tam_saas_referral_program {
  derived_table: {
    sql:with all_tam_referrals as (
  select
    DEAL.deal_id as hubspot_deal_id,
    property_createdate as lead_create_date,
    property_closedate as lead_close_date,
    COALESCE(
      NULLIF(TRIM(SPLIT_PART(property_dealname, '-', 1)), ''),
      TRIM(property_company_name),
      TRIM(property_dealname)
    ) AS hubspot_company_name,
    REGEXP_REPLACE(TO_VARCHAR(property_es_admin_id), '^=', '') as company_id,
    lower(REGEXP_REPLACE(property_tam_email_address, '\\s+', '')) as tam_email,
    -- lower(property_tam_email_address) as tam_email,
    deal.property_tam_name as tam_name,
    deal.property_tam,
    deal.property_deal_owner_2,
    deal.property_deal_owner_title,
    deal.owner_id
  from ANALYTICS.HUBSPOT_CUSTOMER_SUCCESS.DEAL DEAL
  where
    DEAL.PROPERTY_DIRECT_SALE_MORE_THAN_100_ASSETS = 'T3 TAM Referral'
    AND deal.deal_id not in (select merged_deal_id from analytics.hubspot_customer_success.merged_deal)
    AND deal.IS_DELETED = FALSE
    -- and deal.deal_id = 35664498235
),


all_tam_clean as (
  select
    atr.*,
    row_number() over(partition by hubspot_company_name order by lead_create_date) rn
  from all_tam_referrals atr
  qualify rn = 1
),

datatype_fix_to_static_data as (
  select
    REGEXP_REPLACE(TO_VARCHAR(hubspot_contract_data.company_id), '^=', '') as company_id,
    c.name as company_name,
    TO_VARCHAR(hubspot_contract_data.SALES_REF_ID) as CONTRACT_DEAL_ID,
    hubspot_contract_data.PRODUCT_ID,
    hubspot_contract_data.CONTRACT_LINKED_DEVICE_TYPE,
    hubspot_contract_data.CONTRACT_QUANTITY,
    hubspot_contract_data.CONTRACT_MRR,
    hubspot_contract_data.CONTRACT_UNIT_COST,
    hubspot_contract_data.CONTRACT_CLOSE_DATE,
    hubspot_contract_data.CONTRACT_TERMS_IN_MONTHS,
    hubspot_contract_data.CONTRACT_TERMS_END_DATE,
    hubspot_contract_data.CONTRACT_INSTALL_TYPE,
    hubspot_contract_data.CONTRACT_BUNDLE_INSTALL_STATUS,
    TO_VARCHAR(hubspot_contract_data.LI_ID) as LI_ID
  from analytics.t3_saas_billing.hubspot_contract_data hubspot_contract_data
JOIN es_warehouse.public.companies c
  ON TO_VARCHAR(c.company_id) = hubspot_contract_data.company_id
),

datatype_fix_to_deals as (
  select
    TO_VARCHAR(DEAL_ID) as DEAL_ID,
    REGEXP_REPLACE(OWNER_ID, '{^0-9', '') as OWNER_ID
  from analytics.hubspot_customer_success.deal
),

datatype_fix_to_owners as (
  select
    owner.OWNER_ID as ACCT_EXEC_HS_ID,
    CONCAT(owner.FIRST_NAME, ' ', owner.LAST_NAME) as ACCT_EXEC_NAME,
    owner.EMAIL as ACCT_EXEC_EMAIL,
    REGEXP_REPLACE(owner.OWNER_ID, '{^0-9', '') as OWNER_ID
  from analytics.hubspot_customer_success.owner
),

-- No changes needed in static_data beyond using fixed datatype_fix_to_static_data
static_data as (
  select
    hubspot_contract_data.company_id,
    c.name as company_name,
    hubspot_contract_data.CONTRACT_DEAL_ID,
    hubspot_contract_data.PRODUCT_ID,
    product_mapping.CONTRACT_NAME,
    hubspot_contract_data.CONTRACT_LINKED_DEVICE_TYPE,
    hubspot_contract_data.CONTRACT_QUANTITY,
    hubspot_contract_data.CONTRACT_MRR,
    hubspot_contract_data.CONTRACT_UNIT_COST,
    hubspot_contract_data.CONTRACT_CLOSE_DATE,
    hubspot_contract_data.CONTRACT_TERMS_IN_MONTHS,
    hubspot_contract_data.CONTRACT_TERMS_END_DATE,
    hubspot_contract_data.CONTRACT_INSTALL_TYPE,
    hubspot_contract_data.CONTRACT_BUNDLE_INSTALL_STATUS,
    owners.ACCT_EXEC_HS_ID,
    owners.ACCT_EXEC_NAME,
    owners.ACCT_EXEC_EMAIL,
    hubspot_contract_data.LI_ID
  from datatype_fix_to_static_data hubspot_contract_data
  join analytics.t3_saas_billing.product_mapping product_mapping
    on hubspot_contract_data.PRODUCT_ID = product_mapping.PRODUCT_ID
  join es_warehouse.public.companies c on c.company_id = TO_NUMBER(hubspot_contract_data.company_id)
  left join datatype_fix_to_deals deal
    on deal.deal_id = hubspot_contract_data.CONTRACT_DEAL_ID
  left join datatype_fix_to_owners owners
    on deal.owner_id = owners.owner_id
)

, line_items_cidm as (
    select
        DEAL.PROPERTY_ES_ADMIN_ID as ES_ADMIN_ID,
        DEAL.PROPERTY_COMPANY_NAME as COMPANY_NAME,
        LINE_ITEM.PROPERTY_PRODUCT_NAME as PRODUCT_NAME,
        LINE_ITEM.PROPERTY_DESCRIPTION as HUBSPOT_DESCRIPTION,
        LINE_ITEM.PROPERTY_HS_SKU as HS_SKU,
        LINE_ITEM.PROPERTY_BUNDLE_DESCRIPTION as BUNDLE_DESCRIPTION,
        LINE_ITEM.PROPERTY_NAME as PROPERTY_NAME,
        TO_VARCHAR(LINE_ITEM.PROPERTY_LINKED_ASSET_TYPE) as LINKED_ASSET_TYPE,
        LINE_ITEM.PROPERTY_QUANTITY as QUANTITY,
        LINE_ITEM.PROPERTY_AMOUNT as AMOUNT,
        DIV0NULL(LINE_ITEM.PROPERTY_AMOUNT, LINE_ITEM.PROPERTY_QUANTITY) as ITEM_MRR,
        TO_VARCHAR(DEAL.DEAL_ID) as DEAL_ID,
        LINE_ITEM.PROPERTY_HS_TERM_IN_MONTHS as TERMS_IN_MONTHS,
        CAST(DEAL.PROPERTY_ACTUAL_CLOSE_DATE as DATE) AS CLOSE_DATE,
        CAST(DATEADD(MONTH,  LINE_ITEM.PROPERTY_HS_TERM_IN_MONTHS, DEAL.PROPERTY_ACTUAL_CLOSE_DATE) as DATE) as TERMS_END_DATE,
        DEAL.PROPERTY_INSTALLATION_TYPE_ as INSTALL_TYPE,
        LINE_ITEM.PRODUCT_ID as PRODUCT_ID,
        OWNER.OWNER_ID as ACCT_EXEC_HS_ID,
        CONCAT(OWNER.FIRST_NAME, ' ',OWNER.LAST_NAME) as ACCT_EXEC_NAME,
        OWNER.EMAIL as ACCT_EXEC_EMAIL,
        CIDM.CONTRACT_NAME as CONTRACT_NAME,
        TO_VARCHAR(LINE_ITEM.ID) as LI_ID,
    from
        ANALYTICS.HUBSPOT_CUSTOMER_SUCCESS.LINE_ITEM
    left join
         ANALYTICS.HUBSPOT_CUSTOMER_SUCCESS.LINE_ITEM_DEAL
         on LINE_ITEM.ID = LINE_ITEM_DEAL.LINE_ITEM_ID
    left join
        ANALYTICS.HUBSPOT_CUSTOMER_SUCCESS.DEAL
        on DEAL.DEAL_ID = LINE_ITEM_DEAL.DEAL_ID
    left join
        ANALYTICS.HUBSPOT_CUSTOMER_SUCCESS.OWNER
        on OWNER.OWNER_ID = DEAL.OWNER_ID
    left join
        ANALYTICS.T3_SAAS_BILLING.PRODUCT_MAPPING CIDM
        on CIDM.PRODUCT_ID = LINE_ITEM.PRODUCT_ID
    where
        DEAL.DEAL_PIPELINE_STAGE_ID in ('20251023', '179039634', 'bc1beaf7-7b0e-4542-b7c8-d982ae89d2ff')
        and LINE_ITEM.PROPERTY_LINKED_ASSET_TYPE IS NOT NULL
        and LINE_ITEM.PROPERTY_LINKED_ASSET_TYPE != 'iBeacon'
        and LINE_ITEM._FIVETRAN_DELETED = 'FALSE'
        and CIDM.CONTRACT_NAME != 'Exclude'
        and CIDM.CONTRACT_NAME IS NOT NULL
        AND LINE_ITEM.PRODUCT_ID <> '157688483' -- EW Remove once install charges are configured
)
, line_item_scrub as (
    select
        SUM(line_items_cidm.QUANTITY) as QUANTITY,
        SUM(line_items_cidm.AMOUNT) as CONTRACT_MRR,
        line_items_cidm.ES_ADMIN_ID as ES_ADMIN_ID,
        line_items_cidm.COMPANY_NAME as COMPANY_NAME,
        line_items_cidm.DEAL_ID as CONTRACT_DEAL_ID,
        line_items_cidm.PRODUCT_ID as PRODUCT_ID,
        line_items_cidm.CONTRACT_NAME AS CONTRACT_NAME,
        case
            when line_items_cidm.LINKED_ASSET_TYPE ='T3FleetCam' then 'T3Camera'
            when line_items_cidm.LINKED_ASSET_TYPE ='Morey Slap-N-Track' then 'Slap-N-Track'
            else line_items_cidm.LINKED_ASSET_TYPE
        end as LINKED_ASSET_TYPE,
        line_items_cidm.TERMS_IN_MONTHS as TERMS_IN_MONTHS,
        line_items_cidm.CLOSE_DATE as CONTRACT_CLOSE_DATE,
        line_items_cidm.TERMS_END_DATE as TERMS_END_DATE,
        line_items_cidm.INSTALL_TYPE as INSTALL_TYPE,
        case
            when line_items_cidm.PROPERTY_NAME like '%Includes Install%' then 'Install Included'
            when line_items_cidm.PROPERTY_NAME like '%Includes Install' then 'Install Included'
            when line_items_cidm.PROPERTY_NAME like 'Includes Install%' then 'Install Included'
            else 'Install Not Included'
        end as BUNDLE_INSTALL_STATUS,
        line_items_cidm.ACCT_EXEC_HS_ID as ACCT_EXEC_HS_ID,
        line_items_cidm.ACCT_EXEC_NAME as ACCT_EXEC_NAME,
        line_items_cidm.ACCT_EXEC_EMAIL as ACCT_EXEC_EMAIL,
        line_items_cidm.LI_ID as LI_ID
    from
        line_items_cidm
    group by
        line_items_cidm. ITEM_MRR,
        line_items_cidm.ES_ADMIN_ID,
        line_items_cidm.COMPANY_NAME,
        line_items_cidm.DEAL_ID,
        line_items_cidm.PROPERTY_NAME,
        line_items_cidm.LINKED_ASSET_TYPE,
        line_items_cidm.TERMS_END_DATE,
        line_items_cidm.TERMS_IN_MONTHS,
        line_items_cidm.CLOSE_DATE,
        line_items_cidm.TERMS_END_DATE,
        line_items_cidm.INSTALL_TYPE,
        line_items_cidm.CONTRACT_NAME,
        line_items_cidm.PRODUCT_ID,
        line_items_cidm.ACCT_EXEC_HS_ID,
        line_items_cidm.ACCT_EXEC_NAME,
        line_items_cidm.ACCT_EXEC_EMAIL,
        line_items_cidm.LI_ID
    order by
        line_items_cidm. DEAL_ID
)
, new_data as (
--T3 SALES HUBSPOT CONTRACT LINES--
select
    TO_VARCHAR(line_item_scrub.ES_ADMIN_ID) as ES_ADMIN_ID,
    line_item_scrub.COMPANY_NAME as HUBSPOT_COMPANY_NAME,
    line_item_scrub.CONTRACT_DEAL_ID as CONTRACT_DEAL_ID,
    line_item_scrub.PRODUCT_ID as PRODUCT_ID,
    line_item_scrub.CONTRACT_NAME as CONTRACT_NAME,
    line_item_scrub.LINKED_ASSET_TYPE as CONTRACT_LINKED_DEVICE_TYPE,
    line_item_scrub.QUANTITY as CONTRACT_QUANTITY,
    line_item_scrub.CONTRACT_MRR as CONTRACT_MRR,
    DIV0NULL(line_item_scrub.CONTRACT_MRR, line_item_scrub.QUANTITY) as CONTRACT_UNIT_COST,
    line_item_scrub.CONTRACT_CLOSE_DATE as CONTRACT_CLOSE_DATE,
    line_item_scrub.TERMS_IN_MONTHS as CONTRACT_TERMS_IN_MONTHS,
    line_item_scrub.TERMS_END_DATE as CONTRACT_TERMS_END_DATE,
    line_item_scrub.INSTALL_TYPE as CONTRACT_INSTALL_TYPE,
    line_item_scrub.BUNDLE_INSTALL_STATUS as CONTRACT_BUNDLE_INSTALL_STATUS,
    line_item_scrub.ACCT_EXEC_HS_ID as ACCT_EXEC_HS_ID,
    line_item_scrub.ACCT_EXEC_NAME as ACCT_EXEC_NAME,
    line_item_scrub.ACCT_EXEC_EMAIL as ACCT_EXEC_EMAIL,
    line_item_scrub.LI_ID AS LI_ID
from
    line_item_scrub
where
    line_item_scrub.ES_ADMIN_ID is not null
    and line_item_scrub.CONTRACT_CLOSE_DATE > date_trunc('month', current_date())
    and line_item_scrub.ES_ADMIN_ID not like '%TraPac%'
    and line_item_scrub.ES_ADMIN_ID not like 'Typo%'
    and line_item_scrub.ES_ADMIN_ID not like 'mlanz%'
    -- and line_item_scrub.CONTRACT_NAME not in ('TELEMATICS SERVICE AEMP FEED', 'TELEMATICS SERVICE TIME CARDS', 'TELEMATICS SERVICE BLUETOOTH BUNDLE', 'TELEMATICS SERVICE PREMIER SUPPORT', 'TELEMATICS SERVICE T3 AI FACIAL RECOGNITION LICENSE')
order by
    line_item_scrub.ES_ADMIN_ID
)
, union_results as (select * from static_data union select * from new_data)

, contracts_clean as (
    select
        REGEXP_REPLACE(company_id, '\\s+', '') AS company_id,
        date_trunc(month, contract_close_date) contract_close_date,
        sum(contract_quantity) contract_quantity
    from union_results ur
    group by 1, 2
)

,first_close_months AS (
    SELECT
        company_id,
        MIN(contract_close_date) AS first_close_month
    FROM contracts_clean
    where contract_close_date >= '2025-04-01'
    GROUP BY company_id
)

, contracts_in_3_month_window AS (
    SELECT
        c.company_id,
        c.contract_close_date,
        c.contract_quantity
    FROM contracts_clean c
    JOIN first_close_months f
        ON c.company_id = f.company_id
       AND c.contract_close_date BETWEEN f.first_close_month
                                     AND DATEADD(month, 2, f.first_close_month)
)

, hubspot_contract_sum_units as (
    select
        company_id,
        sum(contract_quantity) contract_quantity
    from contracts_in_3_month_window
    group by company_id
    )

      , t3_sub_invoices as (
      select distinct
          i.company_id,
          i.invoice_id as invoice_id,
          i.invoice_date::date as invoice_date,
          i.paid as invoice_paid,
          i.paid_date as invoice_paid_date
      from
          es_warehouse.public.invoices i
          join es_warehouse.public.line_items li on li.invoice_id = i.invoice_id
      where
          li.line_item_type_id = 33
          AND i.invoice_no not ilike '%deleted%'
      )
      , ranking_t3_sub_invoices as (
      select
          company_id,
          invoice_id,
          invoice_date,
          invoice_paid,
          invoice_paid_date,
          ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY invoice_date) AS rn
      from
          t3_sub_invoices
      where invoice_date >= DATE '2025-04-01'
      qualify
          rn <= 3
      )

SELECT
    coalesce(mrx.region_name, REGEXP_REPLACE(SPLIT_PART(cd.default_cost_centers_full_path, '/', 2), '^.*?\\s', '')) as region_name,
    mrx.district,
    mrx.market_name,
    mrx.market_id,
    cd.market_id cd_market_id,
    cd.default_cost_centers_full_path,
    tm.hubspot_deal_id,
    tm.lead_create_date,
    tm.lead_close_date,
    tm.hubspot_company_name,
    tm.company_id,
    tm.tam_email,
    u.user_id AS tam_user_id,
    u.employee_id AS tam_employee_id,
    coalesce(CONCAT(u.first_name, ' ', u.last_name), tm.tam_name) AS tam_name,
    hc.contract_quantity,

    -- Month One
    MAX(IFF(ri.rn = 1, ri.invoice_id, NULL)) AS month_one_invoice_id,
    MAX(IFF(ri.rn = 1, ri.invoice_date, NULL)) AS month_one_invoice_date,
    MAX(IFF(ri.rn = 1 AND ri.invoice_paid = TRUE, TRUE, FALSE)) AS month_one_invoice_paid,
    MAX(IFF(ri.rn = 1 AND ri.invoice_paid = TRUE, ri.invoice_paid_date, NULL)) AS month_one_invoice_paid_date,

    -- Month Two
    MAX(IFF(ri.rn = 2, ri.invoice_id, NULL)) AS month_two_invoice_id,
    MAX(IFF(ri.rn = 2, ri.invoice_date, NULL)) AS month_two_invoice_date,
    MAX(IFF(ri.rn = 2 AND ri.invoice_paid = TRUE, TRUE, FALSE)) AS month_two_invoice_paid,
    MAX(IFF(ri.rn = 2 AND ri.invoice_paid = TRUE, ri.invoice_paid_date, NULL)) AS month_two_invoice_paid_date,

    -- Month Three
    MAX(IFF(ri.rn = 3, ri.invoice_id, NULL)) AS month_three_invoice_id,
    MAX(IFF(ri.rn = 3, ri.invoice_date, NULL)) AS month_three_invoice_date,
    MAX(IFF(ri.rn = 3 AND ri.invoice_paid = TRUE, TRUE, FALSE)) AS month_three_invoice_paid,
    MAX(IFF(ri.rn = 3 AND ri.invoice_paid = TRUE, ri.invoice_paid_date, NULL)) AS month_three_invoice_paid_date,

    -- Eligibility & Payout
    IFF(
        MAX(IFF(ri.rn = 1 AND ri.invoice_paid = TRUE, TRUE, FALSE)) = TRUE AND
        MAX(IFF(ri.rn = 2 AND ri.invoice_paid = TRUE, TRUE, FALSE)) = TRUE AND
        MAX(IFF(ri.rn = 3 AND ri.invoice_paid = TRUE, TRUE, FALSE)) = TRUE,
        TRUE, FALSE
    ) AS eligible_for_payout,

    IFF(
        MAX(IFF(ri.rn = 1 AND ri.invoice_paid = TRUE, TRUE, FALSE)) = TRUE AND
        MAX(IFF(ri.rn = 2 AND ri.invoice_paid = TRUE, TRUE, FALSE)) = TRUE AND
        MAX(IFF(ri.rn = 3 AND ri.invoice_paid = TRUE, TRUE, FALSE)) = TRUE AND
        hc.contract_quantity > 0,
        hc.contract_quantity * 5, NULL
    ) AS payout_amount

FROM
    all_tam_clean tm
    LEFT JOIN hubspot_contract_sum_units hc ON tm.company_id = hc.company_id
    LEFT JOIN es_warehouse.public.users u ON LOWER(u.email_address) = tm.tam_email
    LEFT JOIN ranking_t3_sub_invoices ri ON ri.company_id = tm.company_id
    left join analytics.payroll.company_directory cd on u.email_address = cd.work_email
    left join analytics.public.market_region_xwalk mrx on mrx.market_id = cd.market_id
GROUP BY
    mrx.region_name,
    mrx.district,
    mrx.market_name,
    mrx.market_id,
    cd.market_id,
    cd.default_cost_centers_full_path,
    tm.hubspot_deal_id,
    tm.lead_create_date,
    tm.lead_close_date,
    tm.hubspot_company_name,
    tm.company_id,
    tm.tam_email,
    u.user_id,
    u.employee_id,
    u.first_name,
    u.last_name,
    tm.tam_name,
    hc.contract_quantity

ORDER BY
    tm.hubspot_company_name;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: referrals {
    type: count
    drill_fields: [detail*]
  }

  measure: dead_deals {
    type: count
    filters: [lead_closed: "yes"]
    drill_fields: [detail*]
  }

  measure: converted_deals {
    type: count
    filters: [lead_successful: "yes"]
    drill_fields: [detail*]
  }

  measure: open_deals {
    type: count
    filters: [lead_open: "yes"]
    drill_fields: [detail*]
  }

  measure: win_rate {
    type: number
    sql: ${converted_deals} / nullifzero((${dead_deals} + ${converted_deals})) ;;
    value_format_name: percent_1
    drill_fields: [detail*]
  }

  dimension: has_contract_quantity {
    type: yesno
    sql: ${contract_quantity} > 0 ;;
  }


  measure: trackers_added {
    type: sum
    sql: ${contract_quantity} ;;
    drill_fields: [lead_start_date, tam_name, hubspot_company_name, view_hubspot_deal, trackers_added]
    filters: [has_contract_quantity: "yes"]
  }


  dimension: region {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district  {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  measure: tam_count {
    type: count_distinct
    sql: ${tam_name} ;;
    drill_fields: [tam_name, referrals, trackers_added]
  }

  dimension: hubspot_deal_id {
    type: number
    sql: ${TABLE}."HUBSPOT_DEAL_ID" ;;
  }

  dimension_group: lead_create_date {
    type: time
    sql: ${TABLE}."LEAD_CREATE_DATE" ;;
  }

  dimension_group: lead_close_date {
    type: time
    sql: ${TABLE}."LEAD_CLOSE_DATE" ;;
  }

  dimension: hubspot_company_name {
    type: string
    sql: ${TABLE}."HUBSPOT_COMPANY_NAME" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: tam_email {
    type: string
    sql: ${TABLE}."TAM_EMAIL" ;;
  }

  dimension: tam_user_id {
    type: number
    sql: ${TABLE}."TAM_USER_ID" ;;
  }

  dimension: tam_name {
    type: string
    sql: ${TABLE}."TAM_NAME" ;;
  }

  dimension: tam_employee_id {
    type: string
    sql: ${TABLE}."TAM_EMPLOYEE_ID" ;;
  }

  dimension: contract_quantity {
    type: number
    sql: ${TABLE}."CONTRACT_QUANTITY" ;;
  }

  dimension: month_one_invoice_id {
    type: number
    sql: ${TABLE}."MONTH_ONE_INVOICE_ID" ;;
  }

  dimension: month_one_invoice_date {
    type: date
    sql: ${TABLE}."MONTH_ONE_INVOICE_DATE" ;;
  }

  dimension: month_one_invoice_paid {
    type: yesno
    sql: ${TABLE}."MONTH_ONE_INVOICE_PAID" ;;
  }

  dimension_group: month_one_invoice_paid_date {
    type: time
    sql: ${TABLE}."MONTH_ONE_INVOICE_PAID_DATE" ;;
  }

  dimension: month_two_invoice_id {
    type: number
    sql: ${TABLE}."MONTH_TWO_INVOICE_ID" ;;
  }

  dimension: month_two_invoice_date {
    type: date
    sql: ${TABLE}."MONTH_TWO_INVOICE_DATE" ;;
  }

  dimension: month_two_invoice_paid {
    type: yesno
    sql: ${TABLE}."MONTH_TWO_INVOICE_PAID" ;;
  }

  dimension_group: month_two_invoice_paid_date {
    type: time
    sql: ${TABLE}."MONTH_TWO_INVOICE_PAID_DATE" ;;
  }

  dimension: month_three_invoice_id {
    type: number
    sql: ${TABLE}."MONTH_THREE_INVOICE_ID" ;;
  }

  dimension: month_three_invoice_date {
    type: date
    sql: ${TABLE}."MONTH_THREE_INVOICE_DATE" ;;
  }

  dimension: month_three_invoice_paid {
    type: yesno
    sql: ${TABLE}."MONTH_THREE_INVOICE_PAID" ;;
  }

  dimension_group: month_three_invoice_paid_date {
    type: time
    sql: ${TABLE}."MONTH_THREE_INVOICE_PAID_DATE" ;;
  }

  dimension: eligible_for_payout {
    type: yesno
    sql: ${TABLE}."ELIGIBLE_FOR_PAYOUT" ;;
  }

  dimension: payout_amount {
    type: number
    sql: ${TABLE}."PAYOUT_AMOUNT" ;;
  }

  dimension: lead_closed {
    type: yesno
    sql: ${lead_close_date_raw} is not null AND ${contract_quantity} is null ;;
  }

  dimension: lead_open {
    type: yesno
    sql: ${lead_close_date_raw} is null ;;
  }

  dimension: lead_successful {
    type: yesno
    sql: ${contract_quantity} is not null AND ${lead_close_date_date} is not null ;;
  }

  dimension: lead_start_date {
    group_label: "HTML Formatted Date"
    label: "Lead Create Date"
    type: date
    sql: ${lead_create_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: lead_close_date {
    group_label: "HTML Formatted Date"
    label: "Lead Closed Date"
    type: date
    sql: ${lead_close_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: view_hubspot_deal {
    type: string
    sql: ${hubspot_deal_id} ;;
    html: <font color="#0063f3"><u><a href="https://app.hubspot.com/contacts/3056744/record/0-3/{{ hubspot_deal_id._filterable_value }}" target="_blank">View Hubspot Deal ➔ </a></font></u>;;
  }

  dimension: lead_status {
    type: string
    sql:
    case
    when ${lead_successful} then 'Lead Converted'
    when ${lead_closed} then 'Dead Deal'
    else 'Open'
    end
    ;;
    html: {% if value == 'Lead Converted' %}

    <span style="color: #00CB86;">◉ </span>{{rendered_value}}

    {% elsif value == 'Dead Deal' %}

    <span style="color: #b02a3e;">◉ </span>{{rendered_value}}

    {% else %}

    <span style="color: #FFBF00;">◉ </span>{{rendered_value}}

    {% endif %}

    ;;
  }

  set: detail {
    fields: [
        lead_start_date,
        tam_name,
        hubspot_company_name,
        trackers_added
    ]
  }
}

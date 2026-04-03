view: t3_saas_tam_referral_to_company_id {
  derived_table: {
    sql:

    --SUMMARY
with all_tam_referrals as (
  select
    DEAL.deal_id as hubspot_deal_id,
    date(property_createdate) as lead_create_date,
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
    and deal.property_es_admin_id is not null
    and deal.property_tam_email_address is not null
    -- and deal.deal_id = 35664498235
)

, all_tam_clean as (
  select
    atr.*,
    row_number() over(partition by hubspot_company_name order by lead_create_date) rn
  from all_tam_referrals atr
  qualify rn = 1
)

, first_hubspot_contract as (
select
    min(hubspot_contract_data.CONTRACT_CLOSE_DATE) as FIRST_CLOSE_DATE,
    REGEXP_REPLACE(TO_VARCHAR(hubspot_contract_data.company_id), '^=', '') as company_id
from
    analytics.t3_saas_billing.hubspot_contract_data hubspot_contract_data
group by
    hubspot_contract_data.company_id
)

select
    all_tam_clean.COMPANY_ID,
    all_tam_clean.TAM_EMAIL
from
    all_tam_clean
left join
    first_hubspot_contract
    on first_hubspot_contract.COMPANY_ID = all_tam_clean.COMPANY_ID
where
    all_tam_clean.LEAD_CREATE_DATE < first_hubspot_contract.FIRST_CLOSE_DATE
      ;;
  }


  dimension: COMPANY_ID {
    type: string
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: TAM_EMAIL {
    type: string
    sql: ${TABLE}.TAM_EMAIL ;;
  }

}

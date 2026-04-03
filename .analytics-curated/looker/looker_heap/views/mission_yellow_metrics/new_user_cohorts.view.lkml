view: new_user_cohorts {
  derived_table: {
    sql:
     with generate_series as (
    select * from table(generate_series(
    '2020-01-01'::timestamp_tz,
    LAST_DAY(current_date)::timestamp_tz,
    'month'))
)
, active_rental_months as (
select
    gs.series::date as rental_month,
    c.company_id,
    count(*) as rental_counts
from
    generate_series gs
    join rentals r on gs.series::date BETWEEN date_trunc('month',r.start_date)::date AND date_trunc('month',r.end_date)::date
    left join orders o on o.order_id = r.order_id
    left join users u on u.user_id = o.user_id
    left join companies c on u.company_id = c.company_id
where
    r.rental_type_id != 4
    AND r.deleted = false
    AND c.company_id not in (1854,10859,16184,420,155,23515,11606,77198,5383,4110,88180,37906,36810,42268,84297,58589)
group by
    rental_month,
    c.company_id
)
, first_rental_month as (
select
    company_id,
    min(rental_month) as first_rental_month
from
    active_rental_months
where
    rental_counts >= 1
group by
    company_id
)
, own_companies as (
select
    ao.asset_company_id as company_id,
    date_trunc('month',a.date_created) as asset_create_month,
    count(a.asset_id) as total_assets
from
    analytics.bi_ops.asset_ownership ao
    left join es_warehouse.public.assets a on a.asset_id = ao.asset_id
where
    asset_type_id in (1,2,3)
    AND ownership in ('CUSTOMER','OWN')
group by
    ao.asset_company_id,
    asset_create_month
)
, first_own_month as (
select
    company_id,
    min(asset_create_month) as first_owned_asset_month
from
    own_companies
where
    total_assets >= 1
group by
    company_id
)
, credit_app as (
select
    company_id,
    min(date_trunc('month',date_received)) as credit_app_received_date
from
    analytics.bi_ops.credit_app_master_retool
group by
    company_id
)
, heap_user_session_month as (
select
    u.company_id,
    u.user_id,
    u._user_id as es_user_id,
    date_trunc('month',cast(u.joindate as date)) as first_session_month
from
    NON_PROD_BUSINESS_DATA_VAULT.HEAP_T3_PLATFORM_PRODUCTION_HEAP.TBL_USERS u
    left join es_warehouse.public.users eu on u._user_id = eu.user_id
where
    u.company_id not in (1854,10859,16184,420,155,23515,11606,4110,5383,77198,88180,37906,36810)
    and (eu.first_name not ilike '%t3%' and eu.first_name not ilike '%customer%' and eu.first_name not ilike '%track%' and eu.first_name not ilike '%accounts%')
    and (eu.last_name not ilike '%support%' and eu.last_name not ilike '%payable%')
    and (u.company_name not ilike '%test%' and u.company_name not ilike '%do not use%' and u.company_name not ilike '%don%t use%')
    and u.mimic_user = 'No'
    and u.company_id is not null
)
select
    gs.series::date as month,
    case
        when first_rental_month <= month AND first_owned_asset_month <= month then 'Hybrid'
        when first_rental_month <= month AND first_owned_asset_month is null then 'Rental'
        when first_rental_month is null AND first_owned_asset_month <= month then 'T3'
        when first_rental_month is null AND first_owned_asset_month is null AND credit_app_received_date <= month then 'Intent To Rent'
        else 'No Assets/Rentals'
    end as cohort,
    hd.company_id,
    hd.user_id as heap_user_id,
    hd.es_user_id,
    c.name as company_name,
    concat(u.first_name,' ',u.last_name) as user_name
from
    generate_series gs
    join heap_user_session_month hd on hd.first_session_month::date = gs.series::date
    left join first_rental_month r on r.first_rental_month::date <= gs.series::date and r.company_id = hd.company_id
    left join first_own_month om on om.first_owned_asset_month::date <= gs.series::date and om.company_id = hd.company_id
    left join credit_app cp on cp.credit_app_received_date::date <= gs.series::date AND cp.company_id = hd.company_id
    left join es_warehouse.public.companies c on c.company_id = hd.company_id
    left join es_warehouse.public.users u on u.user_id = hd.es_user_id
          ;;
  }

  dimension_group: month {
    type: time
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: cohort {
    type: string
    sql: ${TABLE}."COHORT" ;;
  }

  dimension_group: grouped_date {
    type: time
    label: "New User"
    sql: ${TABLE}."MONTH" ;;
    convert_tz: no
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: heap_user_id {
    type: number
    sql: ${TABLE}."HEAP_USER_ID" ;;
  }

  dimension: es_user_id {
    type: number
    sql: ${TABLE}."ES_USER_ID" ;;
  }

  dimension: company_name {
    type: string
    label: "Company"
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: formatted_month {
    group_label: "HTML Formatted Date"
    label: "Month"
    type: date
    sql: ${grouped_date_date} ;;
    html: {{ rendered_value | date: "%h %Y"  }};;
    convert_tz: no
  }

  measure: new_users{
    type: count_distinct
    sql: ${heap_user_id} ;;
    drill_fields: [user_info*]
  }

  measure: new_rental_users {
    label: "New Rental Users"
    type: count
    filters: [cohort: "Rental"]
    # type: count_distinct
    # sql: case when ${cohort} = 'Rental' then ${heap_user_id} else null end;;
    drill_fields: [user_info*]
  }

  measure: new_hyrbid_users {
    label: "New Hybrid Users"
    type: count
    filters: [cohort: "Hybrid"]
    # type: count_distinct
    # sql: case when ${cohort} = 'Hybrid' then ${heap_user_id} else null end;;
    drill_fields: [user_info*]
  }

  measure: new_t3_sub_users {
    label: "New T3 Sub Users"
    type: count
    filters: [cohort: "T3"]
    # type: count_distinct
    # sql: case when ${cohort} = 'T3' then ${heap_user_id} else null end;;
    drill_fields: [user_info*]
  }

  measure: new_intent_to_rent_users {
    label: "New Intent to Rent Users"
    type: count
    filters: [cohort: "Intent To Rent"]
    # type: count_distinct
    # sql: case when ${cohort} = 'Intent To Rent' then ${heap_user_id} else null end;;
    drill_fields: [user_info*]
  }

  measure: new_unknown_users {
    label: "New No Assets/Rentals Users"
    type: count
    filters: [cohort: "No Assets/Rentals"]
    # type: count_distinct
    # sql: case when ${cohort} = 'No Assets/Rentals' then ${heap_user_id} else null end;;
    drill_fields: [user_info*]
  }

  set: user_info {
    fields: [
      formatted_month,
      company_name,
      user_name,
      cohort
    ]
  }

}

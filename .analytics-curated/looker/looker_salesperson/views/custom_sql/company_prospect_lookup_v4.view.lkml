view: company_prospect_lookup_v4 {
  derived_table: {
    sql:  with invoices_info as (
              SELECT
                u.company_id,
                c.name,
                o.salesperson_user_id,
                u2.first_name,
                u2.last_name,
                sum(i.line_item_amount) as total_spend,
                max(i.start_date::DATE) as latest_invoice_date
              FROM
                ES_WAREHOUSE.PUBLIC.orders o
                join ES_WAREHOUSE.PUBLIC.users u on o.user_id = u.user_id
                join ES_WAREHOUSE.PUBLIC.companies c on u.company_id = c.company_id
                join ES_WAREHOUSE.PUBLIC.users u2 on o.salesperson_user_id = u2.user_id
                join ES_WAREHOUSE.PUBLIC.invoices i on o.order_id = i.order_id
              WHERE
                i.invoice_date > (current_date - INTERVAL '12 months')
                AND u.company_id is not null
                AND o.salesperson_user_id is not null
              GROUP BY
                u.company_id,
                c.name,
                o.salesperson_user_id,
                u.company_id,
                u2.first_name,
                u2.last_name
              ),
              rank_last_invoice as (
              select
                *,
                row_number ()
                over (
                partition by
                  company_id
                order by
                  latest_invoice_date desc
                ) rank_number
              from
                invoices_info
              where
                total_spend > 0
              order by
                company_id
              ),
              sales_rep_rank_one as (
              select
                company_id,
                case when rank_number = 1 then concat(first_name,' ',last_name) end as sales_rep_rank_one
              from
                rank_last_invoice
              where
                rank_number = 1
              ),
              sales_rep_rank_two as (
              select
                company_id,
                case when rank_number = 2 then concat(first_name,' ',last_name) end as sales_rep_rank_two
              from
                rank_last_invoice
              where
                rank_number = 2
              ),
              sales_rep_rank_three as (
              select
                company_id,
                case when rank_number = 3 then concat(first_name,' ',last_name) end as sales_rep_rank_three
              from
                rank_last_invoice
              where
                rank_number = 3
              ),
              company_sales_rep_ranking as (
              select
                ro.company_id,
                sales_rep_rank_one,
                sales_rep_rank_two,
                sales_rep_rank_three
              from
                sales_rep_rank_one ro
                left join sales_rep_rank_two rw on ro.company_id = rw.company_id
                left join sales_rep_rank_three rt on ro.company_id = rt.company_id
              ),
            company_sales_rep_ranking as (   select
        c.name,
        c.company_id,
        concat(l.street_1,' ',l.street_2) as street_address,
        l.city,
        s.abbreviation,
                cr.sales_rep_rank_one,
                cr.sales_rep_rank_two,
                cr.sales_rep_rank_three
      from
        ES_WAREHOUSE.PUBLIC.companies c
        left join ES_WAREHOUSE.PUBLIC.locations l on c.billing_location_id = l.location_id
        left join ES_WAREHOUSE.PUBLIC.states s on s.state_id = l.state_id
        left join company_sales_rep_ranking cr on cr.company_id = c.company_id
      where
        c.timezone not like '%Auckland%')
         select u.company_id::varchar(15000) as company_prospect_id, ex.company_name as company_name,
regexp_replace(u.phone_number, '[^0-9]', '') as phone_number,(u.first_name||' '||u.last_name) as contact_name ,csrr.sales_rep_rank_one as sales_representative_rank_one ,
csrr.sales_rep_rank_two as sales_representative_rank_two ,
csrr.sales_rep_rank_three as sales_representative_rank_three ,
ex.folder_url as folder_url, l.street_1 as street_address_1,l.city as city,l.zip_code::varchar(255) as zip_code, s.abbreviation as state
,'' as created_by_user
from ES_WAREHOUSE."PUBLIC".users  as u
left join ANALYTICS.webapps.crm__existing__companies__mapping__v4 as ex
on u.company_id = ex.company_id
left join company_sales_rep_ranking as csrr
on u.company_id = csrr.company_id
left join ES_WAREHOUSE."PUBLIC".companies c on u.company_id = c.company_id
left join ES_WAREHOUSE."PUBLIC".locations l on c.billing_location_id = l.location_id
left join ES_WAREHOUSE."PUBLIC".states s on s.state_id = l.state_id
where (u.phone_number is not null and u.phone_number <> '')
and folder_url is not null
and ex.company_name <> 'testpaul'
union all
        select pm.prospect_id as company_prospect_id , pm.company_name as company_name,
regexp_replace(pm.contact_phone_1, '[^0-9]', '') as phone_number, pm.contact_name_1 as contact_name ,u.first_name ||' '||u.last_name as sales_representative_rank_one ,
'' as sales_representative_rank_two ,
'' as sales_representative_rank_three ,
pm.folder_url as folder_url, pm.company_address as street_address_1,pm.company_city as city,pm.company_zipcode::varchar(255) as zip_code, pm.company_state as state
,u2.first_name ||' '||u2.last_name as created_by_user
from ANALYTICS.webapps.crm__prospects__mapping__v4 as pm
left join analytics.prospects.prospects__to__existing__companies__mapping__v4 as pex
on pm.prospect_id = pex.prospect_id
left join ES_WAREHOUSE."PUBLIC".users as  u
on pm.sales_representative_email_address = u.email_address
left join ES_WAREHOUSE."PUBLIC".users as  u2
on pm.created_by = u2.email_address
where (pm.contact_phone_1 is not null or pm.contact_phone_1 <> '')
and pm.folder_url is not null
and pm.company_name <> 'testpaul'
and pex.prospect_id is null
union all
select pm.prospect_id as company_prospect_id , pm.company_name as company_name,
regexp_replace(pm.contact_phone_2, '[^0-9]', '') as phone_number, pm.contact_name_2 as contact_name ,u.first_name ||' '||u.last_name as sales_representative_rank_one ,
'' as sales_representative_rank_two ,
'' as sales_representative_rank_three ,
pm.folder_url as folder_url, pm.company_address as street_address_1,pm.company_city as city,pm.company_zipcode as zip_code, pm.company_state as state
,u2.first_name ||' '||u2.last_name as created_by_user
from ANALYTICS.webapps.crm__prospects__mapping__v4 as pm
left join analytics.prospects.prospects__to__existing__companies__mapping__v4 as pex
on pm.prospect_id = pex.prospect_id
left join ES_WAREHOUSE."PUBLIC".users as  u
on pm.sales_representative_email_address = u.email_address
left join ES_WAREHOUSE."PUBLIC".users as  u2
on pm.created_by = u2.email_address
where (pm.contact_phone_2 is not null or pm.contact_phone_2 <> '')
and pm.folder_url is not null
and pm.company_name <> 'testpaul'
and pex.prospect_id is null
union all
select pm.prospect_id as company_prospect_id , pm.company_name as company_name,
regexp_replace(pm.contact_phone_3, '[^0-9]', '') as phone_number, pm.contact_name_3 as contact_name ,u.first_name ||' '||u.last_name as sales_representative_rank_one ,
'' as sales_representative_rank_two ,
'' as sales_representative_rank_three ,
pm.folder_url as folder_url, pm.company_address as street_address_1,pm.company_city as city,pm.company_zipcode as zip_code, pm.company_state as state
,u2.first_name ||' '||u2.last_name as created_by_user
from ANALYTICS.webapps.crm__prospects__mapping__v4 as pm
left join analytics.prospects.prospects__to__existing__companies__mapping__v4 as pex
on pm.prospect_id = pex.prospect_id
left join ES_WAREHOUSE."PUBLIC".users as  u
on pm.sales_representative_email_address = u.email_address
left join ES_WAREHOUSE."PUBLIC".users as  u2
on pm.created_by = u2.email_address
where (pm.contact_phone_3 is not null or pm.contact_phone_3 <> '')
and pm.folder_url is not null
and pm.company_name <> 'testpaul'
and pex.prospect_id is null
union all
select pm.prospect_id as company_prospect_id , pm.company_name as company_name,
regexp_replace(pm.company_phone, '[^0-9]', '') as phone_number, pm.contact_name_1 as contact_name,u.first_name ||' '||u.last_name as sales_representative_rank_one ,
'' as sales_representative_rank_two ,
'' as sales_representative_rank_three ,
pm.folder_url as folder_url, pm.company_address as street_address_1,pm.company_city as city,pm.company_zipcode as zip_code, pm.company_state as state
,u2.first_name ||' '||u2.last_name as created_by_user
from ANALYTICS.webapps.crm__prospects__mapping__v4 as pm
left join analytics.prospects.prospects__to__existing__companies__mapping__v4 as pex
on pm.prospect_id = pex.prospect_id
left join ES_WAREHOUSE."PUBLIC".users as  u
on pm.sales_representative_email_address = u.email_address
left join ES_WAREHOUSE."PUBLIC".users as  u2
on pm.created_by = u2.email_address
where (pm.company_phone is not null or pm.company_phone <> '')
and pm.folder_url is not null
and pm.company_name <> 'testpaul'
and pex.prospect_id is null
 ;;
  }

  dimension: company_prospect_id {
    type: string
    sql: ${TABLE}.company_prospect_id ;;
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/229?Company%20Prospect%20Project%20ID={{ company_prospect_id._filterable_value | url_encode }}" target="_blank">{{ company_prospect_id._filterable_value }}</a></font></u>;;
  }

  dimension:created_by_user {
    type: string
    sql: ${TABLE}.created_by_user ;;
  }

  dimension: is_prospect_note {
    type: yesno
    sql: left(${company_prospect_id},1) = 'P' ;;
  }

  dimension: company_prospect_name {
    type: string
    html:
    {% if is_prospect_note._value == 'Yes' %}
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/275?Prospect%20Name={{ company_name._filterable_value | url_encode }}" target="_blank">{{ company_name._filterable_value }}</a></font></u>
    {% else %}
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name._filterable_value | url_encode }}" target="_blank">{{ company_name._filterable_value }}</a></font></u>
    {% endif %} ;;
    sql: ${TABLE}.company_name ;;}

  dimension: contact_name {
    type: string
    sql: ${TABLE}.contact_name ;;}

  dimension: street_address_1 {
    type: string
    sql: ${TABLE}.street_address_1 ;;
  }



  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }



  dimension: zip_code {
    type: string
    sql: ${TABLE}.zip_code ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }



  dimension: company_name {
    type: string
    html:
       {% if is_prospect_note._value == 'Yes' %}
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/133?Prospect%20Name={{ company_name._filterable_value | url_encode }}" target="_blank">{{ company_name._value }}</a></font></u>
        {% else %}
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name._filterable_value | url_encode }}" target="_blank">{{ company_name._value }}</a></font></u>
        {% endif %} ;;
    sql: ${company_prospect_name};;
  }


  dimension: phone_number {
    type: string
    sql: ${TABLE}.phone_number ;;
  }



  dimension: sales_representative_rank_one {
    type: string
    sql: ${TABLE}.sales_representative_rank_one ;;
  }

  dimension: sales_representative_rank_two {
    type: string
    sql: ${TABLE}.sales_representative_rank_two ;;
  }

  dimension: sales_representative_rank_three {
    type: string
    sql: ${TABLE}.sales_representative_rank_three ;;
  }

  dimension: navbar_crm {
    html: <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/232" >
      <img border="0" alt="altText" src="https://img.icons8.com/pastel-glyph/64/000000/warehouse.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      PROSPECTS & EXISTING CUSTOMERS
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/226" >
      <img border="0" alt="altText" src="https://cdn2.iconfinder.com/data/icons/gconstruct/2118/gconstruct1-18.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      DODGE PROJECTS
      </f>
      </i></p>
      <p align="center">
      <a href="https://staging-ba.equipmentshare.com/crm/create_prospect" >
      <img border="0" alt="altText" src="https://img.icons8.com/ios/50/000000/keypad.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      CREATE PROSPECT
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/206" >
      <img border="0" alt="altText" src="https://img.icons8.com/carbon-copy/100/000000/purchase-order.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      VIEW PROSPECTS
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/229" >
      <img border="0" alt="altText" src="https://img.icons8.com/material-two-tone/24/000000/wireless-cloud-access.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      PROSPECT ACTIONS
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/52" >
      <img border="0" alt="altText" src="https://img.icons8.com/wired/64/000000/purchase-order.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      EXISTING CUSTOMER LOOKUP
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/273" >
      <img border="0" alt="altText" src="https://img.icons8.com/carbon-copy/100/000000/calendar.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      EXISTING CUSTOMER ACTIONS
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/234" >
      <img border="0" alt="altText" src="https://img.icons8.com/windows/32/000000/help.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      HELP
      </f>
      </i></p>
      ;;
    sql:  ${TABLE}.company_prospect_id ;;
  }
}

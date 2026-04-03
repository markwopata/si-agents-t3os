view: churn_company {
  derived_table: {
    sql: with company_ids as (
select distinct
try_cast(property_es_admin_id as int) as company_id
from analytics.hubspot_customer_success.ticket
where property_churn_type = 'Company Churn'
and property_closed_date >= dateadd(month, -13, dateadd(day, 1, last_day(getdate(), month)))
and try_cast(property_es_admin_id as int) is not null
)
select
        c.company_id
    ,   max(p.name) company_name
 from company_ids c
 left join es_warehouse.public.companies p on c.company_id = p.company_id
 group by c.company_id ;;
  }


    dimension: company_id {
      type: number
      sql: ${TABLE}."COMPANY_ID" ;;
    }

    dimension: company_name {
      type: string
      sql: ${TABLE}."COMPANY_NAME" ;;
    }


  set: company_count_drill{
    fields:[company_name
    ]
  }

  set: arr_lost_drill{
    fields:[arr_lost_drill*
    ]
  }

  set: devices_lost_drill{
    fields:[devices_lost_drill*
    ]
  }

  set: assets_lost_drill{
    fields:[assets_lost_drill*
    ]
  }

    set: detail {
      fields: [
        company_id,
        company_name
      ]
    }
  }

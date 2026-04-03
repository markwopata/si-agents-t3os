
view: tam_company_permissions {
  derived_table: {
    sql: with salesperson_list as (
      select COMPANY_ID,
             listagg(distinct TAM_EMAIL_ADDRESS) within group ( order by TAM_EMAIL_ADDRESS ) as all_salesperson_emails
      from ANALYTICS.BI_OPS.SALESPERSON_RENTALS_AND_RESERVATIONS
      group by COMPANY_ID
      ),
      salesperson_customers as (
      select COMPANY_ID,
             true as can_view_company_flag
      from salesperson_list sl
      where contains(all_salesperson_emails,'{{ _user_attributes['email'] }}') --- liquid tam email
      )
      select *
      from salesperson_customers ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: can_view_company_flag {
    type: yesno
    sql: ${TABLE}."CAN_VIEW_COMPANY_FLAG" ;;
  }

  set: detail {
    fields: [
        company_id,
  can_view_company_flag
    ]
  }
}

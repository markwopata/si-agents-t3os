view: sub_renters {
 derived_table: {
  sql: SELECT distinct asset_id, sub_renter_company_id,sub_renting_company,sub_renter_id,sub_renting_contact
                FROM BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__BY_DAY_UTILIZATION bdu
                 WHERE (bdu.owner_company_id = {{ _user_attributes['company_id'] }} OR bdu.rental_company_id = {{ _user_attributes['company_id'] }})
                   --AND bdu.date >= {% date_start date_filter %}::date
                   --AND bdu.date <= {% date_end date_filter %}::date
 ;;
  }

measure: count {
  type: count
  drill_fields: [detail*]
}

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

dimension: sub_renter_company_id {
  type: number
  sql: ${TABLE}."SUB_RENTER_COMPANY_ID" ;;
}

dimension: sub_renting_company {
  type: string
  sql: ${TABLE}."SUB_RENTING_COMPANY" ;;
}

dimension: sub_renter_id {
  type: number
  sql: ${TABLE}."SUB_RENTER_ID" ;;
}

dimension: sub_renting_contact {
  type: string
  sql: ${TABLE}."SUB_RENTING_CONTACT" ;;
}

  filter: date_filter {
    type: date_time
  }

set: detail {
  fields: [
    sub_renter_company_id,
    sub_renting_company,
    sub_renter_id,
    sub_renting_contact
  ]
}
}

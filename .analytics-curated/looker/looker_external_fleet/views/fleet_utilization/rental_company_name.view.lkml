view: rental_company_name {
  derived_table: {
    sql: SELECT asset_id, rental_company_name
                FROM BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__BY_DAY_UTILIZATION bdu
                 WHERE (bdu.owner_company_id = {{ _user_attributes['company_id'] }} OR bdu.rental_company_id = {{ _user_attributes['company_id'] }})
                --AND bdu.date >= {% date_start date_filter %}::date
                --AND bdu.date <= {% date_end date_filter %}::date
          GROUP BY ALL
 ;;
  }

  # measure: count {
  #   type: count
  #   drill_fields: [detail*]
  # }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: rental_company_name {
    type: string
    sql: ${TABLE}."RENTAL_COMPANY_NAME" ;;
  }



  # filter: date_filter {
  #   type: date_time
  # }

  # set: detail {
  #   fields: [
  #     sub_renter_company_id,
  #     sub_renting_company,
  #     sub_renter_id,
  #     sub_renting_contact
  #   ]
  # }
}

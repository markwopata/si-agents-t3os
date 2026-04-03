view: quote_lost {
  derived_table: {
    sql:

select coalesce(c.FINANCE_SEGMENT_QUARTERLY_NAME, 'Unknown')     as FINANCE_SEGMENT_QUARTERLY_NAME,
       coalesce(c.CUSTOMER_GEOGRAPHIC_RENTAL_SEGMENT, 'Unknown') as CUSTOMER_GEOGRAPHIC_RENTAL_SEGMENT,
       date_trunc('month', created_date)                         as CREATED_DATE,
       REGION_NAME,
       missed_rental_reason                                      AS LOST_REASON,
       count(*)                                                  AS COUNT
from quotes.quotes.quote q
         left join (select COMPANY_ID,
                           FINANCE_SEGMENT_QUARTERLY_NAME,
                           CUSTOMER_GEOGRAPHIC_RENTAL_SEGMENT
                    from analytics.commission.core_commission_increase_table
                    group by COMPANY_ID, FINANCE_SEGMENT_QUARTERLY_NAME,
                             CUSTOMER_GEOGRAPHIC_RENTAL_SEGMENT) c on c.COMPANY_ID = q.COMPANY_ID
         left join analytics.PUBLIC.MARKET_REGION_XWALK mr on q.BRANCH_ID = mr.MARKET_ID
where (order_id is null OR missed_rental_reason is not null)
group by missed_rental_reason, date_trunc('month', created_date), c.FINANCE_SEGMENT_QUARTERLY_NAME,
         c.CUSTOMER_GEOGRAPHIC_RENTAL_SEGMENT, REGION_NAME
order by date_trunc('month', created_date) desc, count(*) desc
  ;;}


  dimension: REGION_NAME {
    label: "Region Name"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: FINANCE_SEGMENT_QUARTERLY_NAME {
    label: "Finance Segment Quarterly"
    type: string
    sql: ${TABLE}."FINANCE_SEGMENT_QUARTERLY_NAME" ;;
  }

  dimension: CUSTOMER_GEOGRAPHIC_RENTAL_SEGMENT {
    label: "Customer Geographic Rental Segment"
    type: string
    sql: ${TABLE}."CUSTOMER_GEOGRAPHIC_RENTAL_SEGMENT" ;;
  }


  dimension_group: CREATED_DATE {
    type: time
    label: "Created Date"
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."CREATED_DATE" ;;
  }
  dimension: LOST_REASON {
    label: "Lost Reason"
    type: string
    sql: ${TABLE}."LOST_REASON" ;;
  }
  measure: COUNT {
    label: "Count"
    type: sum
    sql: ${TABLE}."COUNT" ;;
  }

}

view: classes_missing_rates {
   derived_table: {
     sql:
    select ec.EQUIPMENT_CLASS_ID,
       ec.NAME,
       count(aa.ASSET_ID)                                                  as ASSET_COUNT,
       sum(case when (aa.OEC > 0 or aa.OEC is not null) then 1 else 0 end) as NONZERO_OEC_COUNT,
       sum(aa.OEC)                                                         as TOTAL_OEC
from ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
         left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa on ec.EQUIPMENT_CLASS_ID = aa.EQUIPMENT_CLASS_ID
where ec.COMPANY_ID = 1854
  and ec.RENTABLE = TRUE
  and (DELETED = FALSE or DELETED is null)
  and ec.EQUIPMENT_CLASS_ID not in (select EQUIPMENT_CLASS_ID from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES)
group by ec.EQUIPMENT_CLASS_ID, ec.NAME
       ;;
   }

  dimension: EQUIPMENT_CLASS_ID {
    type: number
    sql: ${TABLE}.EQUIPMENT_CLASS_ID ;;
  }

  dimension: EQUIPMENT_CLASS {
    type: string
    sql: ${TABLE}.NAME ;;
  }

  dimension: ASSET_COUNT {
    type: number
    sql: ${TABLE}.ASSET_COUNT ;;
  }

  dimension: NONZERO_OEC_COUNT {
    type: number
    sql: ${TABLE}.NONZERO_OEC_COUNT ;;
  }

  dimension: TOTAL_OEC {
    type: number
    sql: ${TABLE}.TOTAL_OEC ;;
  }

  dimension: FINANCIAL_UTILIZATION_TARGET {
    type: number
    sql: 0.38 ;;
  }

  dimension: AVERAGE_OEC {
    type: number
    sql:case when ${NONZERO_OEC_COUNT} > 3 then ${TOTAL_OEC} / ${NONZERO_OEC_COUNT} else null end;;
  }

  measure: SUGGESTED_MONTH_RATE {
    type: number
    sql: round(${AVERAGE_OEC} * ${FINANCIAL_UTILIZATION_TARGET} / 13) ;;
  }

  measure: SUGGESTED_WEEK_RATE {
    type: number
    sql: round(${SUGGESTED_MONTH_RATE}/2.5) ;;
  }

  measure: SUGGESTED_DAY_RATE {
    type: number
    sql: round(${SUGGESTED_WEEK_RATE}/2.5) ;;
  }
}

view: asset_nbv_all_owners {
  derived_table: {
    sql:
      SELECT distinct
        NBV.ASSET_ID,
        NBV.COMPANY_NAME AS OWNER,
        ROUND(NBV.NBV, 2) AS NET_BOOK_VALUE,
        NBV.SCHEDULE AS FINANCIAL_SCHEDULE
      FROM
        ANALYTICS.DEBT.ASSET_NBV_ALL_OWNERS AS NBV
    ;;
  }

    dimension: asset_id {
      type: string
      sql: ${TABLE}.ASSET_ID ;;
    }

    dimension: owner {
      type: string
      sql: ${TABLE}.OWNER ;;
    }

    dimension: net_book_value {
     type: number
     sql: ${TABLE}.NET_BOOK_VALUE ;;
    }

   dimension: financial_schedule {
     type: string
     sql: ${TABLE}.FINANCIAL_SCHEDULE ;;
   }

 }

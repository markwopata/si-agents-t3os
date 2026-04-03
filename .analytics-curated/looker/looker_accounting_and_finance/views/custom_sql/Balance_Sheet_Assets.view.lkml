view: Balance_Sheet_Assets {
  derived_table: {
    sql:
      select
      afs.ASSET_ID,
      afs.COMPANY_ID,
      afs.MAKE,
      afs.MODEL,
      afs.CATEGORY,
      aa.CLASS,
      afs.ASSET_TYPE_ADJ,
      afs.FIRST_RENTAL,
      case
        when {% parameter report_month %} = 12 then iff(afs.FIRST_RENTAL < date_from_parts({% parameter report_year %}+1,1,1),'Y','N')
        else iff(afs.FIRST_RENTAL < date_from_parts({% parameter report_year %},{% parameter report_month %}+1,1),'Y','N')
      end as RENTED_Y_N,
      case
        when ASSET_TYPE_ADJ = 'rolling stock' then '1502'
        when RENTED_Y_N = 'N' then '1307'
        else '1500'
      end as GL_MAPPING,
      afs.OEC,
      afs.MARKET_ID::varchar as MARKET_ID,
      iff(AFS.DATE < '2023-01-01'::date,
        iff((m.name = 'Main Branch' or afs.MARKET_ID = 13481), 'CORP1', afs.MARKET_ID::varchar),
        iff((m.name = 'Main Branch' or afs.MARKET_ID = 13481), '1000000', afs.MARKET_ID::varchar)
        ) as ADJUSTED_MARKET_ID
      From analytics.PUBLIC.ASSET_FINANCING_SNAPSHOTS as afs
      left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE as aa
        on afs.ASSET_ID = aa.ASSET_ID
      left join ES_WAREHOUSE.PUBLIC.MARKETS as m
        on afs.MARKET_ID = m.MARKET_ID
      left join ES_WAREHOUSE.PUBLIC.BRANCH_ERP_REFS as ber
        on afs.MARKET_ID = ber.BRANCH_ID
      left join analytics.INTACCT.DEPARTMENT as d
        on ber.INTACCT_DEPARTMENT_ID = d.DEPARTMENTID
      where afs.DATE = last_day(date_from_parts({% parameter report_year %},{% parameter report_month %},1))
        and afs.CATEGORY in ('Owned Rental OEC', 'Owned Rolling Stock OEC')
        --and (d.status = 'active' and d.DEPARTMENTID is not null)
      ;;
  }
  parameter: report_month {
    label: "Month"
    type: number
    default_value: "9"
    allowed_value: {
      label: "January"
      value: "1"
    }
    allowed_value: {
      label: "February"
      value: "2"
    }
    allowed_value: {
      label: "March"
      value: "3"
    }
    allowed_value: {
      label: "April"
      value: "4"
    }
    allowed_value: {
      label: "May"
      value: "5"
    }
    allowed_value: {
      label: "June"
      value: "6"
    }
    allowed_value: {
      label: "July"
      value: "7"
    }
    allowed_value: {
      label: "August"
      value: "8"
    }
    allowed_value: {
      label: "September"
      value: "9"
    }
    allowed_value: {
      label: "October"
      value: "10"
    }
    allowed_value: {
      label: "November"
      value: "11"
    }
    allowed_value: {
      label: "December"
      value: "12"
    }
  }
  parameter: report_year {
    label: "Year"
    type: number
    default_value: "2024"
  }
  dimension: ASSET_ID {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: COMPANY_ID {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: MAKE {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: MODEL {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: CATEGORY {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: CLASS {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: ASSET_TYPE_ADJ {
    type: string
    sql: ${TABLE}."ASSET_TYPE_ADJ" ;;
  }
  dimension: FIRST_RENTAL {
    type: date
    sql: ${TABLE}."FIRST_RENTAL" ;;
  }
  dimension: RENTED_Y_N {
    type: string
    sql: ${TABLE}."RENTED_Y_N" ;;
  }
  dimension: GL_MAPPING {
    type: string
    sql: ${TABLE}."GL_MAPPING" ;;
  }
  dimension: OEC {
    type: number
    sql: ${TABLE}."OEC" ;;
  }
  dimension: MARKET_ID {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: ADJUSTED_MARKET_ID {
    type: string
    sql: ${TABLE}."ADJUSTED_MARKET_ID" ;;
  }
 }

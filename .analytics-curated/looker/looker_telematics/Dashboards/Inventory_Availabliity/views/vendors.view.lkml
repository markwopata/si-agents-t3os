view: vendors {
  derived_table: {
    sql: select *
         from ANALYTICS.FISHBOWL_STAGING.VENDORS
         where DEFAULTFLAG = TRUE;;
  }
  ##sql_table_name: "ANALYTICS"."FISHBOWL_STAGING"."VENDORS" ;;


  dimension: vendorid {
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: vendorname {
    type: string
    sql: REPLACE(${TABLE}."VENDORNAME", '"', '') ;;
  }

  dimension: isdefault {
    type: yesno
    sql: ${TABLE}."DEFAULTFLAG" ;;
  }

  dimension: partnumber {
    type: string
    sql: REPLACE(${TABLE}."VENDORPARTNUMBER", '"', '') ;;
  }

  dimension: partid {
    type: number
    sql: ${TABLE}."PARTID" ;;
  }

  }

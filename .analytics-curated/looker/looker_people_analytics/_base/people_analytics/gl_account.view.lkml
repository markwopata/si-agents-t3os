view: gl_account {
  sql_table_name:"ANALYTICS"."INTACCT"."GLACCOUNT" ;;

  dimension: accounttype {
    type: string
    sql: ${TABLE}."ACCOUNTTYPE"
    sql_where: ${TABLE}."ACCOUNTTYPE" <> 'balancesheet' ;;
  }

  dimension: accountno {
    type: string
    sql: ${TABLE}."ACCOUNTNO" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }
 }

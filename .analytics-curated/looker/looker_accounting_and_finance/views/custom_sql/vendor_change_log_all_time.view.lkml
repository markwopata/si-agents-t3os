view: vendor_change_log_all_time {
 derived_table: {
  sql:
    select
      vend.vendorid                   as VENDORID,
      vend.name                       as VENDORNAME,
      vend.taxid                      as VENDORTAXID,
      vend.createdby                  as CREATEDBY,
      ui.description                  as EMPLOYEENAME,
      vend.whencreated                as TIMESTAMPCREATED,
      CAST(vend.whencreated as DATE)  as CREATEDDATE
    from
      analytics.intacct.vendor vend
    join
      analytics.intacct.userinfo ui
        on
        vend.createdby = ui.recordno
        ;;

    }

  dimension: VENDORID {
    type: string
    sql: ${TABLE}.VENDORID;;
  }

  dimension: VENDORNAME {
    type: string
    sql: ${TABLE}.VENDORNAME;;
  }

  dimension: VENDORTAXID {
    type: string
    sql: ${TABLE}.VENDORTAXID;;
  }

  dimension: CREATEDBY {
    type: string
    sql: ${TABLE}.CREATEDBY;;
  }

  dimension: EMPLOYEENAME {
    type: string
    sql: ${TABLE}.EMPLOYEENAME;;
  }

  dimension: TIMESTAMPCREATED {
    type: date
    sql: ${TABLE}.TIMESTAMPCREATED;;
  }

  dimension: CREATEDDATE {
    type: date
    sql: ${TABLE}.CREATEDDATE;;
  }

  }

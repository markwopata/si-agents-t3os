view: collector_individual_targets {
  sql_table_name: "ANALYTICS"."TREASURY"."COLLECTOR_INDIVIDUAL_TARGETS_BRANCH_CUSTOMER" ;;


################## DIMENSIONS ##################

  dimension: branch_id {
    type: string
    value_format_name: id
    sql: iff(${TABLE}."BRANCH_ID" is null,'77777',${TABLE}."BRANCH_ID") ;;
  }

  dimension: quarter {
    type: string
    sql: ${TABLE}."QUARTER" ;;
  }

  dimension: manager {
    type: string
    suggest_persist_for: "1 minute"
    sql: ${TABLE}."MANAGER" ;;
  }

  dimension: manager_email_address {
    type:  string
    sql: ${TABLE}."MANAGER_EMAIL_ADDRESS"  ;;
  }

  dimension: collector_email_address {
    type:  string
    sql: ${TABLE}."COLLECTOR_EMAIL_ADDRESS"  ;;
  }

  dimension: director_email_address {
    type:  string
    sql: ${TABLE}."DIRECTOR_EMAIL_ADDRESS"  ;;
  }

  dimension: admin_email_address {
    type:  string
    sql: ${TABLE}."ADMIN_EMAIL_ADDRESS"  ;;
  }

  dimension: collector {
    type: string
    suggest_persist_for: "1 minute"
    sql:  ${TABLE}."COLLECTOR" ;;
  }

  dimension: company_id {
    type: string
    #suggest_persist_for: "1 minute"
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: combined_company_id {
    type: string
    #suggest_persist_for: "1 minute"
    sql: ${TABLE}."COMPANY_ID" ;;
  }


  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }





  dimension: is_collector  {
    type: yesno
    sql: (${collector_email_address} = '{{ _user_attributes['email'] }}') OR
         ('{{ _user_attributes['email'] }}' in (
        'lewis.hornsby@equipmentshare.com',
        'ashley.dominguez@equipmentshare.com',
        'trinity.rainey@equipmentshare.com',
        'tiffany.brown@equipmentshare.com',
        'greg.stegeman@equipmentshare.com',
        'rhiannon.mitchell@equipmentshare.com',
        'greg.huddleston@equipmentshare.com',
        'paul.logue@equipmentshare.com',
        'mark.wopata@equipmentshare.com',
        'jabbok@equipmentshare.com',
        'regina.stuart@equipmentshare.com',
        'trista.rivera@equipmentshare.com',
        'erica.parsons@equipmentshare.com'
        )) ;;
  }

  ################## PRIMARY KEY ##################

  dimension: key {
    type: string
    primary_key: yes
    sql: ${branch_id}||'-'||${company_id}||'-'||${type} ;;
  }


  ################## MEASURES ##################
  measure: collections_target {
    type: sum
    value_format_name: usd_0
    sql:coalesce(${TABLE}."COLLECTIONS_TARGET",0) ;;
  }

  measure: amount_to_be_collected {
    type: number
    sql: ${collections_target} - ${collections_actuals.collections} ;;
    value_format_name: usd_0
  }

}

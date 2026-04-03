include: "/_base/analytics/payroll/company_directory_vault.view.lkml"

view: +company_directory_vault {
  label: "Company Directory Vault"

  #dimension_group: _es_update_timestamp {
  #  type: time
  #  timeframes: [date,week,month,quarter,year]
  #  sql: date(${_es_update_timestamp}) ;;
  #  }

  #dimension_group: _es_update_timestamp_date {
  #  type: time
  #  timeframes: [date,week,month,quarter,year]
  #  sql: date(${_es_update_timestamp_date}) ;;
  #  }

}

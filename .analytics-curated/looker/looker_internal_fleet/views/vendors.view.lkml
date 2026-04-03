include: "/views/companies.view.lkml"

view: vendors {

  extends: [companies]

  dimension: name {
    label: "Vendor"
    type: string
    suggest_explore: vendors_suggest
    suggest_dimension: vendors_suggest.name
    sql:  ${TABLE}.name ;;
  }

}

view: vendors_suggest {

  dimension: name {
    type: string
    sql:  ${TABLE}.name ;;
  }

  derived_table: {
    sql: SELECT DISTINCT name FROM companies where supply_vendor = true ;;
  }

}

explore: vendors_suggest {}

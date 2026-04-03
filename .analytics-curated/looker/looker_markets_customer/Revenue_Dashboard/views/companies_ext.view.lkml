include: "/views/ES_WAREHOUSE/companies.view.lkml"
view: companies_ext {
  extends: [companies]

  dimension: is_floor_plan_company {
    description: "Yes for companies with name like IES#"
    type: yesno
    sql: ${name} REGEXP 'IES\\d.+' ;;
  }
}

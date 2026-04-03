include: "/_base/es_warehouse/public/users.view.lkml"

view: +users {

  dimension: full_name {
    type: string
    sql:
    TRIM(
      COALESCE(${first_name}, '') || ' ' || COALESCE(${last_name}, '')
    ) ;;
  }
  }

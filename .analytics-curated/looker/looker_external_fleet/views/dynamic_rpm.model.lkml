connection: "es_warehouse"

include: "/views/*.view.lkml"

explore: dynamic_rpm {
  case_sensitive: no
  sql_always_where: ${assets.company_id} = 163745 ;;

  join: assets {
    type: inner
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${dynamic_rpm.asset_id} ;;
  }

  join: asset_types {
    type: inner
    relationship: one_to_many
    sql_on: ${asset_types.asset_type_id} = ${assets.asset_type_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.category_id} = ${categories.category_id} ;;
  }

}

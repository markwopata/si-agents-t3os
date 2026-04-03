view: deals_not_sold {
    derived_table: {
      sql:
      select
          asset_id
        , make
        , model
        , year
        , inventory_branch_id
        , branch_name
      from data_science_stage.fleet_testing.deals_not_sold
    ;;
    }

    dimension: asset_id {
      type:  number
      primary_key: yes
      hidden:  no
      description: "Selected assets still available for incentivized used fleet sales. Contains Sany and Wacker Neuson models"
      sql:  ${TABLE}."ASSET_ID" ;;
    }

    dimension: OEM {
      type:  string
      description: "Corresponds to es_warehouse.public.assets MAKE field. Original equipment manufacturer of asset"
      sql:  ${TABLE}."MAKE" ;;
    }

  dimension: Model {
    type:  string
    description: "Corresponds to es_warehouse.public.assets MODEL field. Model of asset make"
    sql:  ${TABLE}."MODEL" ;;
  }

  dimension: Year {
    type:  string
    description: "Corresponds to es_warehouse.public.assets YEAR field. Year asset was made"
    sql:  ${TABLE}."YEAR" ;;
  }

  dimension: location_id {
    type:  string
    description: "Corresponds to es_warehouse.public.assets INVENTORY_BRANCH_ID field. Current inventory location of asset"
    sql:  ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: branch_name {
    type:  string
    description: "Corresponds to es_warehouse.public.markets NAME field. Current name of inventory location of asset"
    sql:  ${TABLE}."BRANCH_NAME" ;;
  }
}

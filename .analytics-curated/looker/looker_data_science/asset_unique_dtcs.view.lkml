view: asset_unique_dtcs {
  derived_table: {
    sql:
      select
        asset_id,
        make,
        model,
        company_name,
        market_name,
        unique_dtc_codes_reported
      from data_science.public.ape_asset_unique_dtcs
      ;;
  }
  dimension: asset_id {}
  dimension: make {}
  dimension: model {}
  dimension: company_name {}
  dimension: market_name {}
  dimension: unique_dtc_codes_reported {}
}

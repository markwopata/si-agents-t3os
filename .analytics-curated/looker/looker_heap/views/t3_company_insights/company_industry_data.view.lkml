view: company_industry_data {

 derived_table: {
  sql: SELECT * FROM ANALYTICS.T3_ANALYTICS.VW_COMPANY_ASSETS_AND_INDUSTRY_DETAILS ;;
}


  ########################
  # Primary Key
  ########################
  dimension: company_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.company_id ;;
    label: "Company ID"
    description: "Unique identifier for the company."
  }

  ########################
  # Company Info
  ########################
  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
    label: "Company Name"
    description: "Name of the company."
  }

  ########################
  # Asset and Tracker Metrics
  ########################
  dimension: assets {
    type: number
    sql: ${TABLE}.assets ;;
    label: "Total Assets"
    description: "Total number of assets the company has."
  }

  dimension: trackers_installed {
    type: number
    sql: ${TABLE}.trackers_installed ;;
    label: "Trackers Installed"
    description: "Number of trackers currently installed on the company's assets."
  }

  dimension: average_trackers_per_asset {
    type: number
    sql: ${TABLE}.average_trackers_per_asset ;;
    label: "Average Trackers per Asset"
    description: "Average number of trackers per asset for this company."
  }

  # percent_trackers_installed is stored as a numeric value (e.g., 50.0 for 50%)
  # Convert it to a true percentage
  dimension: percent_trackers_installed {
    type: number
    sql: ${TABLE}.percent_trackers_installed / 100 ;;
    label: "Percent of Assets with Trackers"
    value_format: "0.0%"
    description: "Percentage of the company's assets that have trackers installed."
  }

  dimension: customer_assets {
    type: number
    sql: ${TABLE}.customer_assets ;;
    label: "Customer-Owned Assets"
    description: "Number of assets owned by the customer."
  }

  dimension: own_assets {
    type: number
    sql: ${TABLE}.own_assets ;;
    label: "Company-Owned Assets"
    description: "Number of assets owned by the company itself (ownership type 'OWN')."
  }

  ########################
  # Industry and Classification Fields
  ########################
  dimension: sic_code {
    type: string
    sql: ${TABLE}.sic_code ;;
    label: "SIC Code"
    description: "Standard Industrial Classification code associated with the company."
  }

  dimension: sic_descr {
    type: string
    sql: ${TABLE}.sic_descr ;;
    label: "SIC Description"
    description: "Description of the SIC code."
  }

  dimension: sic_industry_grouping {
    type: string
    sql: ${TABLE}.sic_industry_grouping ;;
    label: "SIC Industry Grouping"
    description: "Industry grouping derived from the SIC code."
  }

  dimension: dnb_industry_code {
    type: string
    sql: ${TABLE}.dnb_industry_code ;;
    label: "DNB Industry Code"
    description: "Dun & Bradstreet industry classification code."
  }

  dimension: dnb_industry_descr {
    type: string
    sql: ${TABLE}.dnb_industry_descr ;;
    label: "DNB Industry Description"
    description: "Description of the DNB industry code."
  }

  dimension: naics_code {
    type: string
    sql: ${TABLE}.naics_code ;;
    label: "NAICS Code"
    description: "North American Industry Classification System code."
  }

  dimension: es_classification {
    type: string
    sql: ${TABLE}.es_classification ;;
    label: "ES Classification"
    description: "EquipmentShare-specific classification of the company."
  }

  dimension: es_classification_detailed {
    type: string
    sql: ${TABLE}.es_classification_detailed ;;
    label: "ES Classification Detailed"
    description: "More detailed EquipmentShare classification."
  }

  dimension: sic_major_grouping {
    type: string
    sql: ${TABLE}.sic_major_grouping ;;
    label: "SIC Major Grouping"
    description: "Major industry grouping under SIC."
  }

  dimension: major_grouping {
    type: string
    sql: ${TABLE}.major_grouping ;;
    label: "Major Grouping"
    description: "Higher-level industry category based on SIC."
  }

  dimension: sic_division {
    type: string
    sql: ${TABLE}.sic_division ;;
    label: "SIC Division"
    description: "Division level classification under SIC."
  }

  dimension: division {
    type: string
    sql: ${TABLE}.division ;;
    label: "Division"
    description: "Industry division classification."
  }

  ########################
  # Measures
  ########################
  measure: count {
    type: count
    label: "Company Count"
    description: "Count of rows (companies) in the current result set."
  }

  # Count distinct companies by SIC industry grouping
  measure: companies_by_sic_industry {
    type: count_distinct
     sql: ${company_id} ;;
    label: "Companies by SIC Industry Grouping"
    description: "Number of distinct companies that have an SIC industry grouping."
  }

  # Count distinct companies by DNB industry code
  measure: companies_by_dnb_industry {
    type: count_distinct
    sql: ${company_id} ;;
    label: "Companies by DNB Industry Code"
    description: "Number of distinct companies that have a DNB industry code."
  }

  # A measure for average percent trackers installed across a selection of companies
  measure: avg_percent_trackers_installed {
    type: average
    sql: ${percent_trackers_installed} ;;
    value_format: "0.0%"
    label: "Avg Percent of Trackers Installed"
    description: "Average percentage of trackers installed across the selected companies."
  }

  dimension: is_vip_customer {
    type: yesno
    sql:
    CASE WHEN ${TABLE}.COMPANY_ID IN (50, 8935, 2968, 7978, 5437, 5658, 24008, 11674, 60574, 10924)
         THEN TRUE
         ELSE FALSE
    END
  ;;
  }


  ########################
  # Sets and Drills
  ########################
  set: company_industry_details {
    fields: [
      company_id,
      company_name,
      sic_code,
      sic_descr,
      sic_industry_grouping,
      dnb_industry_code,
      dnb_industry_descr,
      naics_code,
      es_classification,
      es_classification_detailed
    ]
  }

  # Example drill-enabled measure:
  measure: total_assets_sum {
    type: sum
    sql: ${assets} ;;
    label: "Total Assets (Sum)"
    description: "Sum of assets for selected companies."
    drill_fields: [company_industry_details*, assets, trackers_installed, percent_trackers_installed]
  }

}

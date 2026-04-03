view: dot {
  sql_table_name: "ANALYTICS"."PUBLIC"."DOT"
    ;;

  dimension: allowed_to_operate {
    type: string
    sql: ${TABLE}."allowedToOperate" ;;
  }

  dimension: bipd_insurance_on_file {
    type: string
    sql: ${TABLE}."bipdInsuranceOnFile" ;;
  }

  dimension: bipd_insurance_required {
    type: string
    sql: ${TABLE}."bipdInsuranceRequired" ;;
  }

  dimension: bipd_required_amount {
    type: string
    sql: ${TABLE}."bipdRequiredAmount" ;;
  }

  dimension: bond_insurance_on_file {
    type: string
    sql: ${TABLE}."bondInsuranceOnFile" ;;
  }

  dimension: bond_insurance_required {
    type: string
    sql: ${TABLE}."bondInsuranceRequired" ;;
  }

  dimension: broker_authority_status {
    type: string
    sql: ${TABLE}."brokerAuthorityStatus" ;;
  }

  dimension: cargo_insurance_on_file {
    type: string
    sql: ${TABLE}."cargoInsuranceOnFile" ;;
  }

  dimension: cargo_insurance_required {
    type: string
    sql: ${TABLE}."cargoInsuranceRequired" ;;
  }

  dimension: carrier_operation {
    type: string
    sql: ${TABLE}."carrierOperation" ;;
  }

  dimension: carriercensus {
    type: string
    sql: ${TABLE}."carrier/census" ;;
  }

  dimension: census_type_id {
    type: string
    sql: ${TABLE}."censusTypeId" ;;
  }

  dimension: common_authority_status {
    type: string
    sql: ${TABLE}."commonAuthorityStatus" ;;
  }

  dimension: contract_authority_status {
    type: string
    sql: ${TABLE}."contractAuthorityStatus" ;;
  }

  dimension: crash_total {
    type: string
    sql: ${TABLE}."crashTotal" ;;
  }

  dimension: dba_name {
    type: string
    sql: ${TABLE}."dbaName" ;;
  }

  dimension: dot_number {
    type: string
    sql: ${TABLE}."dotNumber" ;;
  }

  dimension: driver_insp {
    type: string
    sql: ${TABLE}."driverInsp" ;;
  }

  dimension: driver_oos_insp {
    type: string
    sql: ${TABLE}."driverOosInsp" ;;
  }

  dimension: driver_oos_rate {
    type: string
    sql: ${TABLE}."driverOosRate" ;;
  }

  dimension: driver_oos_rate_national_average {
    type: string
    sql: ${TABLE}."driverOosRateNationalAverage" ;;
  }

  dimension: ein {
    type: string
    sql: ${TABLE}."EIN" ;;
  }

  dimension: fatal_crash {
    type: string
    sql: ${TABLE}."fatalCrash" ;;
  }

  dimension: hazmat_insp {
    type: string
    sql: ${TABLE}."hazmatInsp" ;;
  }

  dimension: hazmat_oos_insp {
    type: string
    sql: ${TABLE}."hazmatOosInsp" ;;
  }

  dimension: hazmat_oos_rate {
    type: string
    sql: ${TABLE}."hazmatOosRate" ;;
  }

  dimension: hazmat_oos_rate_national_average {
    type: string
    sql: ${TABLE}."hazmatOosRateNationalAverage" ;;
  }

  dimension: inj_crash {
    type: string
    sql: ${TABLE}."injCrash" ;;
  }

  dimension: is_passenger_carrier {
    type: string
    sql: ${TABLE}."isPassengerCarrier" ;;
  }

  dimension: iss_score {
    type: string
    sql: ${TABLE}."issScore" ;;
  }

  dimension: legal_name {
    type: string
    sql: ${TABLE}."legalName" ;;
  }

  dimension: mcs150_outdated {
    type: string
    sql: ${TABLE}."mcs150Outdated" ;;
  }

  dimension: oos_date {
    type: string
    sql: ${TABLE}."oosDate" ;;
  }

  dimension: oos_rate_national_average_year {
    type: string
    sql: ${TABLE}."oosRateNationalAverageYear" ;;
  }

  dimension: phy_city {
    type: string
    sql: ${TABLE}."phyCity" ;;
  }

  dimension: phy_country {
    type: string
    sql: ${TABLE}."phyCountry" ;;
  }

  dimension: phy_state {
    type: string
    sql: ${TABLE}."phyState" ;;
  }

  dimension: phy_street {
    type: string
    sql: ${TABLE}."phyStreet" ;;
  }

  dimension: phy_zipcode {
    type: string
    sql: ${TABLE}."phyZipcode" ;;
  }

  dimension: review_date {
    type: string
    sql: ${TABLE}."reviewDate" ;;
  }

  dimension: review_type {
    type: string
    sql: ${TABLE}."reviewType" ;;
  }

  dimension: safety_rating {
    type: string
    sql: ${TABLE}."safetyRating" ;;
  }

  dimension: safety_rating_date {
    type: string
    sql: ${TABLE}."safetyRatingDate" ;;
  }

  dimension: safety_review_date {
    type: string
    sql: ${TABLE}."safetyReviewDate" ;;
  }

  dimension: safety_review_type {
    type: string
    sql: ${TABLE}."safetyReviewType" ;;
  }

  dimension: snapshot_date {
    type: string
    sql: ${TABLE}."snapshotDate" ;;
  }

  dimension: status_code {
    type: string
    sql: ${TABLE}."statusCode" ;;
  }

  dimension: total_drivers {
    type: string
    sql: ${TABLE}."totalDrivers" ;;
  }

  dimension: total_power_units {
    type: string
    sql: ${TABLE}."totalPowerUnits" ;;
  }

  dimension: towaway_crash {
    type: string
    sql: ${TABLE}."towawayCrash" ;;
  }

  dimension: vehicle_insp {
    type: string
    sql: ${TABLE}."vehicleInsp" ;;
  }

  dimension: vehicle_oos_insp {
    type: string
    sql: ${TABLE}."vehicleOosInsp" ;;
  }

  dimension: vehicle_oos_rate {
    type: string
    sql: ${TABLE}."vehicleOosRate" ;;
  }

  dimension: vehicle_oos_rate_national_average {
    type: string
    sql: ${TABLE}."vehicleOosRateNationalAverage" ;;
  }

  measure: count {
    type: count
    drill_fields: [dba_name, legal_name]
  }
}

view: itl_parts_on_rent {
  derived_table: {
    sql: with date_series_cte as
    (
             select SERIES as DTE
             from table (ES_WAREHOUSE.PUBLIC.GENERATE_SERIES('2022-01-01'::timestamp_tz,
                                                             current_timestamp::timestamp_tz, '1 hour'))
    ),
     v_part_rental as
         (
             select VPR.PK_KEY,
                    VPR.BRANCH_ID,
                    VPR.BRANCH,
                    VPR.COMPANY_ID,
                    VPR.COMPANY_NAME,
                    VPR.PART_ID,
                    VPR.PART_NUMBER,
                    VPR.DESCRIPTION,
                    VPR.START_DATE::date start_hour,
                    coalesce(VPR.END_DATE, current_date)::date   end_hour,
                    datediff(day, start_hour, coalesce(end_hour, current_date)) as days_on_rent
             from ANALYTICS.TOOLS_TRAILER.V_PART_RENTAL VPR
        ),
     partition_cte as (
         select dsc.DTE,
                vpr2.BRANCH_ID,
                vpr2.BRANCH,
                vpr2.COMPANY_ID,
                vpr2.COMPANY_NAME,
                vpr2.PART_ID,
                vpr2.DESCRIPTION,
                count(vpr2.PART_NUMBER) number_on_rent

         from v_part_rental vpr2
            join date_series_cte dsc
                on dsc.DTE >= vpr2.start_hour
                    and dsc.DTE <= vpr2.end_hour
         group by dsc.DTE, vpr2.part_id, vpr2.BRANCH_ID, vpr2.BRANCH, vpr2.COMPANY_ID, vpr2.COMPANY_NAME, vpr2.DESCRIPTION
     ),
     rank_cte as (
         select dte,
                BRANCH_ID,
                BRANCH,
                COMPANY_ID,
                COMPANY_NAME,
                PART_ID,
                DESCRIPTION,
                number_on_rent,
                row_number() over (partition by DATE_TRUNC(day, dte) order by number_on_rent desc) as rn

         from partition_cte
     )
select date_trunc(day, dte) as dte,
       BRANCH_ID,
       BRANCH,
       COMPANY_ID,
       COMPANY_NAME,
       PART_ID,
       DESCRIPTION,
       max(number_on_rent) as number_on_rent

from rank_cte
group by date_trunc(day, dte), BRANCH_ID, BRANCH, COMPANY_ID, COMPANY_NAME, PART_ID, DESCRIPTION;;
  }

  dimension: pk {
    type: number
    label: "PK"
    sql: ${TABLE}."PK" ;;
  }

  dimension: branch_id {
    type: number
    label: "Market ID"
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch {
    type: string
    label: "Market Name"
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: company_id {
    type: number
    label: "Company ID"
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company {
    type: string
    label: "Company Name"
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: dte {
    type: date
    convert_tz: no
    label: "Date"
    sql: ${TABLE}."DTE" ;;
  }

  dimension: part_id {
    type: number
    label: "Part ID"
    sql: ${TABLE}."PART_ID" ;;
  }

  # dimension: part_number {
  #   type: string
  #   label: "Part Number"
  #   sql: ${TABLE}."PART_NUMBER" ;;
  # }

  dimension: description {
    type: string
    label: "Part Description"
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  # dimension: start_date {
  #   type: date
  #   convert_tz: no
  #   label: "Rental Start Date"
  #   sql: ${TABLE}."START_DATE" ;;
  # }

  # dimension: end_date {
  #   type: date
  #   convert_tz: no
  #   label: "Rental End Date"
  #   sql: ${TABLE}."END_DATE" ;;
  # }

  dimension: pk_part_id {
    type: string
    label: "PK - Part ID"
    sql: coalesce(${TABLE}."PK","-",${TABLE}."PART_ID") ;;
  }

  measure: number_on_rent_sum {
    type: sum
    label: "Number of Parts On-Rent"
    sql: ${TABLE}."NUMBER_ON_RENT" ;;
  }

  set: detail {
    fields: [
      pk,
      branch_id,
      part_id,
      description,
      dte
      ]

  }











}

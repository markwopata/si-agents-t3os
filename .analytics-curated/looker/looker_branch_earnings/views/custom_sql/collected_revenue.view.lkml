view: collected_revenue {
  derived_table: {
    sql:
with RATE_ACHIEVEMENT_CTE as (select
                                    RP.INVOICE_ID
                                  , coalesce(avg(RP.PERCENT_DISCOUNT), 0) as RATE_ACHIEVEMENT
                                  from ANALYTICS.PUBLIC.RATEACHIEVEMENT_POINTS RP
                                 group by RP.INVOICE_ID),
       INVOICE_CTE as (select
                           I.INVOICE_ID
                         , I.INVOICE_NO
                         , C.NAME
                         , A.SERIAL_NUMBER
                         , VLI.BRANCH_ID
                         , MRX.MARKET_NAME
                         , MRX.REGION_DISTRICT
                         , MRX.REGION
                         , MRX.REGION_NAME
                         , I.PAID_DATE
                         , I.BILLING_APPROVED_DATE
                         , sum(VLI.AMOUNT) as COLLECTED_REVENUE
                         from ES_WAREHOUSE.PUBLIC.INVOICES I
                                  join ANALYTICS.PUBLIC.V_LINE_ITEMS VLI
                                  on I.INVOICE_ID = VLI.INVOICE_ID
                                  left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK MRX
                                  on VLI.BRANCH_ID = MRX.MARKET_ID
                                  join ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE as RMR
                                  on MRX.MARKET_ID = RMR.MARKET_ID
                                  left join ANALYTICS.GS.PLEXI_PERIODS PP
                                  on date_trunc(month, TRUNC::date) = date_trunc(month, I.BILLING_APPROVED_DATE::date)
                                  left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE A
                                  on VLI.ASSET_ID = A.ASSET_ID
                                  join ES_WAREHOUSE.PUBLIC.COMPANIES c
                                  on i.COMPANY_ID = c.COMPANY_ID
                        where datediff('hour', I.BILLING_APPROVED_DATE, I.PAID_DATE) / 24 < 120
                          and I.COMPANY_ID not in
                              (1854, 8151, 7201, 31113, 31175, 31177, 31180, 31293, 31294, 31295, 32149)
                          and VLI.LINE_ITEM_TYPE_ID in (6, 8, 108, 109) --Commissions Line Items
                          and datediff(month, date_trunc(month, BRANCH_EARNINGS_START_MONTH::DATE),
                                       date_trunc(month, I.BILLING_APPROVED_DATE)) >= 12
                          --and I.PAID_DATE >= '2022-04-01 00:00:00.000'  ----- Change to desired date
                          -- and I.PAID_DATE < '2023-04-01 00:00:00.000'   ----- Change to desired date
                        group by VLI.BRANCH_ID, MRX.MARKET_NAME, MRX.REGION_DISTRICT, MRX.REGION, MRX.REGION_NAME,
                                 I.INVOICE_ID, I.PAID_DATE, I.BILLING_APPROVED_DATE, RMR.MARKET_START_MONTH, A.SERIAL_NUMBER,
                                 I.INVOICE_NO, C.NAME)
select
    IC.INVOICE_ID
  , IC.INVOICE_NO
  , IC.NAME as company_name
  , IC.BILLING_APPROVED_DATE
  , IC.BRANCH_ID
  , IC.MARKET_NAME
  , IC.REGION_DISTRICT as DISTRICT
  , IC.REGION
  , IC.REGION_NAME
  --, sum(IC.COLLECTED_REVENUE) as COLLECTED_REVENUE
  ,  sum(case when rate_achievement is null and ((SUBSTR(TRIM(ic.serial_number), 1, 3) = 'RR-'
            or SUBSTR(TRIM(ic.serial_number), 1, 2) = 'RR'))
            then 0 else ic.COLLECTED_REVENUE end) as COLLECTED_REVENUE
  from INVOICE_CTE IC
           left join RATE_ACHIEVEMENT_CTE RA
           on RA.INVOICE_ID = IC.INVOICE_ID
 where coalesce(RA.RATE_ACHIEVEMENT, 0) < 0.24
  AND date_trunc(month, ic.paid_date) in (select trunc::date from analytics.gs.plexi_periods
                    where {% condition display %} DISPLAY {% endcondition %})
 group by IC.INVOICE_ID, IC.INVOICE_NO, IC.NAME, IC.BRANCH_ID, IC.MARKET_NAME, IC.REGION_DISTRICT, IC.REGION, IC.REGION_NAME, IC.BILLING_APPROVED_DATE
;;
  }

   filter: display {
     type: string
     suggestions: [
      "January 2021","February 2021","March 2021","April 2021","May 2021","June 2021","July 2021","August 2021","September 2021","October 2021","November 2021","December 2021",
      "January 2022","February 2022","March 2022","April 2022","May 2022","June 2022", "July 2022","August 2022","September 2022","October 2022","November 2022","December 2022",
      "January 2023","February 2023","March 2023","April 2023","May 2023","June 2023", "July 2023","August 2023","September 2023","October 2023","November 2023","December 2023"
      ]
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
   }

  parameter: report_period {
    #label: "Period"
    type: string
    full_suggestions: yes
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  parameter: report_month {
    label: "Month"
    type: number
    #default_value: "8"
    allowed_value: {
      label: "January"
      value: "1"
    }
    allowed_value: {
      label: "February"
      value: "2"
    }
    allowed_value: {
      label: "March"
      value: "3"
    }
    allowed_value: {
      label: "April"
      value: "4"
    }
    allowed_value: {
      label: "May"
      value: "5"
    }
    allowed_value: {
      label: "June"
      value: "6"
    }
    allowed_value: {
      label: "July"
      value: "7"
    }
    allowed_value: {
      label: "August"
      value: "8"
    }
    allowed_value: {
      label: "September"
      value: "9"
    }
    allowed_value: {
      label: "October"
      value: "10"
    }
    allowed_value: {
      label: "November"
      value: "11"
    }
    allowed_value: {
      label: "December"
      value: "12"
    }
  }

  parameter: report_year {
    label: "Year"
    type: number
    allowed_value: {value: "2021"}
    allowed_value: {value: "2022"}
    allowed_value: {value: "2023"}
  }

  dimension: market_id {
    type: string
    #primary_key: yes
    label: "Market ID"
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: market_name {
    type: string
    label: "Market Name"
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    label: "District"
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: invoice_id {
    label: "Invoice ID"
    type: number
    primary_key: yes
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_no {
    label: "Invoice Number"
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
    html: <a style="color:rgb(26, 115, 232)" href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ collected_revenue.invoice_no }}" target="_blank">{{value}}</a> ;;
  }

  # dimension: link_agg {
  #   label: "Links"
  #   html:
  #       {% if be_transaction_listing.url_admin._value != null %}
  #     <a href = "https://admin.equipmentshare.com/#/home/transactions/invoices/{{ collected_revenue.invoice_no._value }}" target="_blank">
  #       <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png" width="16" height="16"> Admin</a>
  #     &nbsp;
  #   {% endif %}
  #   ;;
  # }

  dimension: company_name {
    label: "Company Name"
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: paid_date {
    label: "Paid Date"
    type: date
    sql: ${TABLE}."PAID_DATE" ;;
  }

  dimension: billing_approved_date {
    label: "Billing Approved Date"
    type: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: region_name {
    type: string
    label: "Region Name"
    sql: ${TABLE}."REGION_NAME";;
  }

  dimension: months_open {
    type: number
    label: "Months Open"
    sql: ${TABLE}."MONTHS_OPEN" ;;
  }

  dimension: collected_revenue {
    type: number
    label: "Collected Revenue"
    sql: ${TABLE}."COLLECTED_REVENUE" ;;
  }

  measure: collected_revenue_sum {
    type: sum
    label: "Collected Revenue"
    sql: ${collected_revenue} ;;
    link: {
      label: "Detail View"
      url: "@{lk_collected_revenue_detail}?f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[collected_revenue.display]={{ _filters['collected_revenue.display'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}&f[market_region_xwalk.region_district]={{ _filters['market_region_xwalk.region_district'] | url_encode }}&Markets+Greater+Than+12+Months+Open?={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&toggle=det"
    }
  }

  set: detail {
    fields: [
      market_id,
      market_name,
      district,
      region_name
    ]
  }








}

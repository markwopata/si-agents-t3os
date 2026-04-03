view: oem_assets_vendor_scorecard {
  derived_table: {
    sql:
select vendorid
    , vendor_name
    , mapped_vendor_name
    , v.category
    , preferred
    , vendor_type
    , vendor_type_2
    , responsible_ssm
    , sage_vendor_category
    , aa.make
    , aa.asset_id
    , aa.oec
    , aa.oec / 12 as oec_per_month
    , datediff(day, date_trunc(month, current_date()), current_date()) as days_elapsed_current_mth
    , datediff(day, date_trunc(month, current_date()), date_trunc(month, dateadd(month, 1, current_date()))) as days_in_current_mth
    , days_elapsed_current_mth / days_in_current_mth as percent_of_current_mth
    , (oec_per_month) * (datediff(month, date_trunc(year, current_date()), current_date()) + percent_of_current_mth) as ytd_oec
from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
          left join (
                      select tvm.vendorid
                           , tvm.vendor_name
                           , tvm.mapped_vendor_name
                           , tvm.preferred
                           , tvm.category
                           , tvm.vendor_type
                           , tvm.vendor_type_2
                           , tvm.responsible_ssm
                           , v.vendor_category as sage_vendor_category
                           , iff(tvm.mapped_vendor_name <> 'Doosan / Bobcat', tvm.mapped_vendor_name, 'DOOSAN') as join1
                           , iff(join1 = 'DOOSAN', 'BOBCAT', null) as join2
                      from ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING as tvm
                      join ANALYTICS.INTACCT.VENDOR v
                        on v.vendorid = tvm.vendorid
                      where tvm.primary_vendor ilike 'yes') as v
            on upper(join1) = aa.make or upper(join2) = aa.make
-- where (aa.COMPANY_ID IN ( --Dropped because we are inner joining to cost of maintance which is already split up by month and asset so we have had cost on that asset during that month we want to count it.
--         select COMPANY_ID
--         FROM ANALYTICS.PUBLIC.ES_COMPANIES
--         where owned )
--     --CONTRACTOR OWNED/OWN PROGRAM
--     OR aa.asset_id IN (
--         SELECT DISTINCT AA.asset_id
--         FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
--         JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
--             ON VPP.ASSET_ID = AA.ASSET_ID
--         WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
--             AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31'))
--         )
;;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.vendor_name ;;
  }

  dimension: mapped_vendor_name {
    type: string
    sql: ${TABLE}.mapped_vendor_name ;;
  }

  # dimension: tier { #Tier renamed category on 1/29/26
  #   type: string
  #   sql: ${TABLE}.category ;;
  # }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: preferred {
    type: yesno
    sql: ${TABLE}.preferred;;
  }

  dimension: vendor_type {
    type: string
    sql: ${TABLE}.vendor_type ;;
  }

  dimension: vendor_type_2 {
    type: string
    sql: ${TABLE}.vendor_type_2 ;;
  }

  dimension: responsible_ssm {
    type: string
    sql: ${TABLE}.responsible_ssm ;;
  }

  dimension: sage_vendor_category {
    type: string
    sql: ${TABLE}.sage_vendor_category ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: unique {
    type: string
    primary_key: yes
    sql: concat(${asset_id}, ${vendor_name}) ;;
  }

  dimension: oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.oec ;;
  }

  dimension: oec_div_by_12 {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.oec_per_month ;;
  }

  measure: oec_per_month {
    type: sum
    value_format_name: usd_0
    sql: ${oec_div_by_12} ;;
  }

  dimension: oec_to_date {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.ytd_oec;;
  }

  measure: ytd_oec {
    type: sum
    value_format_name: usd_0
    sql: ${oec_to_date} ;;
  }

  parameter: drop_down_selection {
    type: string
    allowed_value: { value: "Vendor Name"}
    allowed_value: { value: "Mapped Vendor Name"}
    allowed_value: { value: "Preferred"}
    allowed_value: { value: "Category"}
    allowed_value: { value: "Vendor Type"}
    allowed_value: { value: "Sage Vendor Category"}
    allowed_value: { value: "Responsible SSM"}
  }

  dimension: dynamic_axis {
    label_from_parameter: drop_down_selection
    sql:
    {% if drop_down_selection._parameter_value == "'Vendor Name'" %}
      ${vendor_name}
    {% elsif drop_down_selection._parameter_value == "'Mapped Vendor Name'" %}
      ${mapped_vendor_name}
    {% elsif drop_down_selection._parameter_value == "'Category'" %}
      ${category}
    {% elsif drop_down_selection._parameter_value == "'Preferred'" %}
      ${preferred}
    {% elsif drop_down_selection._parameter_value == "'Vendor Type'" %}
      ${vendor_type}
    {% elsif drop_down_selection._parameter_value == "'Sage Vendor Category'" %}
      ${sage_vendor_category}
    {% elsif drop_down_selection._parameter_value == "'Responsible SSM'" %}
      ${responsible_ssm}
    {% else %}
      NULL
    {% endif %} ;;
  }
}

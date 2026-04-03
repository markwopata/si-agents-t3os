view: kpi_inputs {
  derived_table: {
    sql:
        with oec_cte as (
      select
          ad.market_id::varchar                                                   mkt_id,
          'OEC'                                                            type,
          'OEC'                                                            code,
          'Original Equipment Cost'                                        gl_acct,
          'BFAA'                                                    acctno,
          'OEC'                                                   descr,
          date_trunc(month, ad.gl_date::date)                          gl_date,
          null                                            doc_no,
          null                                                             url_sage,
          null                                                             url_yooz,
          SUM(ad.OEC)                                                amt
      from
          analytics.branch_earnings.asset_detail ad
      where 1=1
           {% if report_month._parameter_value == "''" %}
              and date_part(month, gle.entry_date) = {% parameter report_month %}
              and date_part(year, gle.entry_date) = {% parameter report_year %}
           {% endif %}
      group by mkt_id, type, code, gl_acct, acctno, descr, gl_date, doc_no, url_sage, url_yooz
    ),

      unioned_cte as (
      select
      MKT_ID::varchar mkt_id,
      TYPE,
      CODE,
      GL_ACCT,
      ACCTNO,
      DESCR,
      date_trunc(month, GL_DATE) gl_date,
      DOC_NO,
      URL_SAGE,
      URL_YOOZ,
      AMT
      from ANALYTICS.PUBLIC.BRANCH_EARNINGS_DDS_SNAP
      {% if report_month._parameter_value == "''" %}
      where date_part(month, GL_DATE) = {% parameter report_month %}
      and date_part(year, GL_DATE) = {% parameter report_year %}
      {% endif %}

      union all
      select * from oec_cte
      ),

      final_cte as (
      select
      case
      when mkt_id = '15967' then '33163'             -- Mobile, AL
      when mkt_id = '24562' then '23627'             -- VLP Garden City
      when mkt_id = '24563' then '23626'             -- VLP Joplin
      when mkt_id = '24564' then '15977'             -- VLP Wichita
      when mkt_id = '24565' then '13574'             -- VLP Topeka
      when mkt_id = '42165' then '9'                 -- Ascend CHB to Pasadena
      else mkt_id
      end                                                              market_id,
      type,
      code,
      iff(code = 'interco', 'EXP', left(code, 3))                      revexp,
      iff(code = 'interco', code, right(code, length(code)-3))         dept,
      case
      when lower(gl_acct) like '%commission%'                      then 'Comm'
      when lower(gl_acct) like '%overtime%'                        then 'OT'
      when gl_acct like '%OT%'                                     then 'OT'
      when lower(gl_acct) like '%payroll%'                         then 'Reg'
      when acctno = '1700' and lower(descr) like '%commission%'    then 'Comm'
      when acctno = '1700' and lower(descr) like '%overtime%'      then 'OT'
      when acctno = '1700' and descr like '%OT%'                   then 'OT'
      when acctno = '1700' and lower(descr) like '%payroll%'       then 'Reg'
      end pr_type,
      gl_acct,
      acctno,
      gl_date,
      sum(amt)                                                         activity
      from unioned_cte
      group by mkt_id, type, code, revexp, dept, pr_type, gl_acct, acctno, gl_date
      )

      select
      F.market_id                                                              mkt_id,
      m.name                                                                   mkt_name,
      datediff('month',RO.BRANCH_EARNINGS_START_MONTH,gl_date) + 1                      months_open,
      gl_date,
      abs(sum(case when code = 'OEC' then activity else 0 end))                oec,
      abs(sum(case when acctno = 'FAAA' then activity
      when acctno = 'TAIR' then activity
      when acctno = '5000' then activity
      else 0 end))                                                     rent_rev,
      abs(sum(case when code = 'REVdel' then activity else 0 end))             del_rev,
      abs(sum(case when acctno = '5009' then activity else 0 end))             pd_del_rev,
      abs(sum(case when acctno in ('6014','6015','6016','6019','6020','6031') then activity else 0 end))             del_exp,
      abs(sum(case when pr_type is not null then activity else 0 end))         comp,
      abs(sum(case when pr_type in ('OT', 'Reg') then activity else 0 end))    wages,
      abs(sum(case when pr_type = 'OT' then activity else 0 end))              overtime,
      abs(sum(case when acctno in ('6014', '6031') then activity else 0 end))  hauling,
      sum(case when code <> 'OEC' then activity else 0 end)                    net_income
      from final_cte F
      join ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE             RO
      on F.market_id = RO.MARKET_ID::varchar
      join es_warehouse.public.markets m
      on F.market_id = m.market_id::varchar
      group by mkt_id, mkt_name, gl_date, months_open
      ;;
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
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: oec_sum {
    type: sum
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/dashboards-next/531?Period={{ _filters['plexi_periods.display'] | url_encode }}&Market+Name={{ _filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;District+Number={{ _filters['market_region_xwalk.region_district'] | url_encode }}&toggle=det"
    }
    sql: ${TABLE}."OEC" ;;
  }

  measure: rent_rev_sum {
    type: sum
    sql: ${TABLE}."RENT_REV" ;;
  }

  measure: del_rev_sum {
    type: sum
    sql: ${TABLE}."DEL_REV" ;;
  }

  measure: pd_del_rev_sum {
    type: sum
    sql: ${TABLE}."PD_DEL_REV" ;;
  }

  measure: del_exp_sum {
    type: sum
    sql: ${TABLE}."DEL_EXP" ;;
  }

  measure: comp_sum {
    type: sum
    sql: ${TABLE}."COMP" ;;
  }

  measure: wages_sum {
    type: sum
    sql: ${TABLE}."WAGES" ;;
  }

  measure: overtime_sum {
    type: sum
    sql: ${TABLE}."OVERTIME" ;;
  }

  measure: hauling_sum {
    type: sum
    sql: ${TABLE}."HAULING" ;;
  }

  measure: rent_to_oec {
    label: "Rent Revenue Percent of OEC"
    type: number
    sql:  case when ${oec_sum} = 0 then 0 else ${rent_rev_sum} / ${oec_sum} end;;
  }

  measure: del_to_rev {
    label: "Delivery Gross Revenue Percent of Rent Revenue"
    type: number
    sql: case when ${rent_rev_sum} = 0 then 0 else ${del_rev_sum} / ${rent_rev_sum} end;;
  }

  measure: hauling_to_rev {
    label: "Outside Hauling Percent of Rent Revenue"
    type: number
    sql: case when ${rent_rev_sum} = 0 then 0 else ${hauling_sum} / ${rent_rev_sum} end;;
  }

  measure: labor_to_rev {
    label: "Total Labor Percent of Rent Revenue"
    type: number
    sql: case when ${rent_rev_sum} = 0 then 0 else ${comp_sum} / ${rent_rev_sum} end ;;
  }

  measure: ot_to_rev {
    label: "Overtime Percent of Total Labor"
    type: number
    sql: case when ${wages_sum} = 0 then 0 else ${overtime_sum} / ${wages_sum} end ;;
  }

  measure: delivery_recovery {
    label: "Delivery Recovery Percent"
    type: number
    sql: case when ${del_exp_sum} = 0 then 0 else ${pd_del_rev_sum} / ${del_exp_sum} end  ;;
  }

  measure: net_income  {
    label: "Net Income"
    type: sum
    sql:  ${TABLE}."NET_INCOME" ;;
  }

  dimension: mkt_id {
    type: string
    sql: ${TABLE}."MKT_ID" ;;
  }

  dimension: mkt_name {
    type: string
    sql: ${TABLE}."MKT_NAME" ;;
    suggest_explore: market_region_xwalk
    suggest_dimension: market_region_xwalk.market_name
  }

  dimension: months_open_old {
    type: number
    sql:  ${TABLE}."MONTHS_OPEN" ;;
  }

  dimension: gl_date {
    type: date
    convert_tz: no
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: oec {
    type: number
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/dashboards-next/531?Period={{ _filters['plexi_periods.display'] | url_encode }}&Market+Name={{ _filters['mkt_name'] | url_encode }}&amp;Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;Region+District={{ _filters['market_region_xwalk.region_district'] | url_encode }}&toggle=det"
    }
    sql: ${TABLE}."OEC" ;;
  }

  dimension: rent_rev {
    type: number
    sql: ${TABLE}."RENT_REV" ;;
  }

  dimension: comp {
    type: number
    sql: ${TABLE}."COMP" ;;
  }

  dimension: wages {
    type: number
    sql: ${TABLE}."WAGES" ;;
  }

  dimension: overtime {
    type: number
    sql: ${TABLE}."OVERTIME" ;;
  }

  dimension: hauling {
    type: number
    sql: ${TABLE}."HAULING" ;;
  }

  dimension: months_open {
    type: number
    sql: datediff(months, ${revmodel_market_rollout_conservative.branch_earnings_start_month_raw}, ${plexi_periods.date})+1 ;;
  }

  dimension: greater_twelve_months_open {
    label: "Markets Greater Than 12 Months Open?"
    type: yesno
    sql: ${months_open} > 12;;
  }

  measure: financial_utilization {
    label: "Financial Utilization %"
    type: number
    sql: ${rent_to_oec} * 12 ;;
  }

}

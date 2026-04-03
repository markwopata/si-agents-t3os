view: target_market_account_comp {
  derived_table: {
    sql:
with max_published_month as(
select max(trunc::date) as max_published_month
 from analytics.gs.plexi_periods
 where period_published = 'published')

, comp_date_param as(
select dateadd(month,-12, (select max_published_month from max_published_month)) as start_date
     , (select max_published_month from max_published_month) as end_date)

, comp_oec_core as(
select count(market_id) as market_ct
     , avg(oec) as comp_oec
     , avg(service_total_oec) as comp_rental_fleet_oec
 from analytics.branch_earnings.high_level_financials
 where gl_date between (select start_date from comp_date_param) and (select end_date from comp_date_param)
  and market_id in(18702,63125,24007,24079,35789,15984,16835,40682))

, comp_oec_adv as(
select count(market_id) as market_ct
     , avg(oec) as comp_oec
     , avg(service_total_oec) as comp_rental_fleet_oec
 from analytics.branch_earnings.high_level_financials
 where gl_date between (select start_date from comp_date_param) and (select end_date from comp_date_param)
  and market_id in(102247,109985,78665,95837))

, comp_revenues_core as(
select count(distinct (m.market_id || date_trunc(month,be.gl_date))) as be_market_ct
     , sum(case when be.type in('Rental Revenues','Service Revenues','Retail Revenues','Miscellaneous Revenues') then be.amt else 0 end)/count(distinct (m.market_id || date_trunc(month,be.gl_date))) as comp_total_rev
     , sum(case when be.type in('Rental Revenues') then be.amt else 0 end)/count(distinct (m.market_id || date_trunc(month,be.gl_date))) as comp_rental_rev
     , sum(case when be.type in('Rental Revenues','Service Revenues') then be.amt else 0 end)/count(distinct (m.market_id || date_trunc(month,be.gl_date))) as comp_rental_service_rev
     , sum(case when be.type in('Retail Revenues') then be.amt else 0 end)/count(distinct (m.market_id || date_trunc(month,be.gl_date))) as comp_retail_rev
 from analytics.public.BRANCH_EARNINGS_DDS_SNAP be
 join analytics.branch_earnings.market m on be.mkt_id = m.child_market_id
 where date_trunc(month,be.gl_date) between (select start_date from comp_date_param) and (select end_date from comp_date_param)
  and m.market_id in(18702,63125,24007,24079,35789,15984,16835,40682))

, comp_revenues_adv as(
select count(distinct (m.market_id || date_trunc(month,be.gl_date))) as be_market_ct
     , sum(case when be.type in('Rental Revenues','Service Revenues','Retail Revenues','Miscellaneous Revenues') then be.amt else 0 end)/count(distinct (m.market_id || date_trunc(month,be.gl_date))) as comp_total_rev
     , sum(case when be.type in('Rental Revenues') then be.amt else 0 end)/count(distinct (m.market_id || date_trunc(month,be.gl_date))) as comp_rental_rev
     , sum(case when be.type in('Rental Revenues','Service Revenues') then be.amt else 0 end)/count(distinct (m.market_id || date_trunc(month,be.gl_date))) as comp_rental_service_rev
     , sum(case when be.type in('Retail Revenues') then be.amt else 0 end)/count(distinct (m.market_id || date_trunc(month,be.gl_date))) as comp_retail_rev
 from analytics.public.BRANCH_EARNINGS_DDS_SNAP be
 join analytics.branch_earnings.market m on be.mkt_id = m.child_market_id
 where date_trunc(month,be.gl_date) between (select start_date from comp_date_param) and (select end_date from comp_date_param)
  and m.market_id in(102247,109985,78665,95837))

, comp_market_accts_core as(
select be.acctno as account_no
     , be.gl_acct as account_name
     , coalesce(pbm.revexp,be.revexp) as rev_exp
     , coalesce(pbm.display_name,be.type) as type
     , round(sum(be.amt)/(select market_ct from comp_oec_core),2) as comp_amount
     , (comp_amount/
        (case
          when coalesce(pbm.revexp,be.revexp) = 'REV' then (select comp_rental_fleet_oec from comp_oec_core)
          when coalesce(pbm.display_name,be.type) = 'Facilities Expenses' then (select comp_rental_fleet_oec from comp_oec_core)
          when be.acctno in('5009','6000','6009','6010','6014','6014','6015','6016','6019','6020','6031','6031','6032','6050','6308') then (select comp_rental_rev from comp_revenues_core)
          when be.acctno in('6302','6305','6310','6311','6327','GDDA','GDDAB') then (select comp_rental_service_rev from comp_revenues_core)
          when be.acctno in('GDDAA') then (select comp_retail_rev from comp_revenues_core)
          else (select comp_total_rev from comp_revenues_core)
         end)) as pct_comp
     , (case
          when coalesce(pbm.revexp,be.revexp) = 'REV' then 'Annualized % of OEC'
          when coalesce(pbm.display_name,be.type) = 'Facilities Expenses' then 'Annualized % of OEC'
          when be.acctno in('5009','6000','6009','6010','6014','6014','6015','6016','6019','6020','6031','6031','6032','6050','6308') then '% of Rental Revenue'
          when be.acctno in('6302','6305','6310','6311','6327','GDDA','GDDAB') then '% of Rental & Service Revenue'
          when be.acctno in('GDDAA') then '% of Retail Revenue'
          else '% of Total Revenue'
         end) as comp_metric
 from analytics.public.branch_earnings_dds_snap be
 left join analytics.gs.plexi_bucket_mapping pbm on be.acctno = pbm.sage_gl
 join analytics.branch_earnings.market m on be.mkt_id = m.child_market_id
 where date_trunc(month,be.gl_date) between (select start_date from comp_date_param) and (select end_date from comp_date_param)
  and m.market_id in(18702,63125,24007,24079,35789,15984,16835,40682)
 group by all)

, comp_market_accts_adv as(
select be.acctno as account_no
     , be.gl_acct as account_name
     , coalesce(pbm.revexp,be.revexp) as rev_exp
     , coalesce(pbm.display_name,be.type) as type
     , round(sum(be.amt)/(select market_ct from comp_oec_adv),2) as comp_amount
     , (comp_amount/
        (case
          when coalesce(pbm.revexp,be.revexp) = 'REV' then (select comp_rental_fleet_oec from comp_oec_core)
          when coalesce(pbm.display_name,be.type) = 'Facilities Expenses' then (select comp_rental_fleet_oec from comp_oec_core)
          when be.acctno in('5009','6000','6009','6010','6014','6014','6015','6016','6019','6020','6031','6031','6032','6050','6308') then (select comp_rental_rev from comp_revenues_adv)
          when be.acctno in('6302','6305','6310','6311','6327','GDDA','GDDAB') then (select comp_rental_service_rev from comp_revenues_adv)
          when be.acctno in('GDDAA') then (select comp_retail_rev from comp_revenues_adv)
          else (select comp_total_rev from comp_revenues_adv)
         end)) as pct_comp
     , (case
          when coalesce(pbm.revexp,be.revexp) = 'REV' then 'Annualized % of OEC'
          when coalesce(pbm.display_name,be.type) = 'Facilities Expenses' then 'Annualized % of OEC'
          when be.acctno in('5009','6000','6009','6010','6014','6014','6015','6016','6019','6020','6031','6031','6032','6050','6308') then '% of Rental Revenue'
          when be.acctno in('6302','6305','6310','6311','6327','GDDA','GDDAB') then '% of Rental & Service Revenue'
          when be.acctno in('GDDAA') then '% of Retail Revenue'
          else '% of Total Revenue'
         end) as comp_metric
 from analytics.public.branch_earnings_dds_snap be
 left join analytics.gs.plexi_bucket_mapping pbm on be.acctno = pbm.sage_gl
 join analytics.branch_earnings.market m on be.mkt_id = m.child_market_id
 where date_trunc(month,be.gl_date) between (select start_date from comp_date_param) and (select end_date from comp_date_param)
  and m.market_id in(102247,109985,78665,95837)
 group by all)

, actuals_oec as(
select market_id
     , gl_date as gl_month
     , count(market_id) as market_count
     , avg(oec) as actual_oec
     , avg(service_total_oec) as actual_rental_fleet_oec
 from analytics.branch_earnings.high_level_financials hlf
 where gl_date between (select start_date from comp_date_param) and (select end_date from comp_date_param)
 group by all)

, actuals_revenues as(
select m.market_id
     , date_trunc(month,gl_date) as gl_month
     , sum(case when be.type in('Rental Revenues','Service Revenues','Retail Revenues','Miscellaneous Revenues') then be.amt else 0 end)/count(distinct date_trunc(month,be.gl_date)) as actual_total_rev
     , sum(case when be.type in('Rental Revenues') then be.amt else 0 end)/count(distinct date_trunc(month,be.gl_date)) as actual_rental_rev
     , sum(case when be.type in('Rental Revenues','Service Revenues') then be.amt else 0 end)/count(distinct date_trunc(month,be.gl_date)) as actual_rental_service_rev
     , sum(case when be.type in('Retail Revenues') then be.amt else 0 end)/count(distinct date_trunc(month,be.gl_date)) as actual_retail_rev
 from analytics.public.BRANCH_EARNINGS_DDS_SNAP be
 join analytics.branch_earnings.market m on be.mkt_id = m.child_market_id
 where date_trunc(month,be.gl_date) between (select start_date from comp_date_param) and (select end_date from comp_date_param)
 group by all)

, actuals as(
select m.region_name
     , 'd-' || m.district as district
     , m.market_id
     , m.market_name
     , m.market_type
     , datediff(month, m.branch_earnings_start_month, date_trunc(month,current_date)) + 1 as months_open_current
     , date_trunc(month,be.gl_date) as gl_month
     , coalesce(pbm.revexp,be.revexp) as rev_exp
     , coalesce(pbm.display_name,be.type) as type
     , be.acctno as account_no
     , be.gl_acct as account_name
     , round(sum(be.amt)/count(distinct date_trunc(month,be.gl_date)),2) as actual_amount
 from analytics.public.BRANCH_EARNINGS_DDS_SNAP be
 left join analytics.gs.plexi_bucket_mapping pbm on be.acctno = pbm.sage_gl
 join analytics.branch_earnings.market m on be.mkt_id = m.child_market_id
 where date_trunc(month,be.gl_date) between (select start_date from comp_date_param) and (select end_date from comp_date_param)
 group by all)

select a.region_name
     , a.district
     , a.market_id
     , a.market_name
     , a.market_type
     , a.months_open_current
     , a.gl_month
     , pp.display as month_year
     , (case
         when a.rev_exp = 'REV' then 'Revenue'
         else 'Expense'
        end) as rev_exp
     , a.type
     , a.account_no
     , a.account_name
     , (case
         when a.account_no in('5021','7008','6003','6300','6101','GBAA','GBBA','GCAA','GDCB','GDDAA','7503','6320','7100','7102','7902','7009','6201','7701','7003','7401'
                             ,'7404','7904','7006','7903','6306','6032','6307','7409','7901','6031','6016','7403','7400','7302','6308','6301','6014','7004','GCBA','GDDAB'
                             ,'GDDAA','6009','6309','6327','6007','6305','6000','6302','7304','6031','6020','6015','IAAA','6014','6311','HFAB','7705','6019','6008','GCBA'
                             ,'GDDA','6310') then 'Controllable'
         else 'Fixed'
        end) as cost_type
     , tmc.comp_metric
     , (case
            when tmc.comp_metric = '% of Total Revenue' then ar.actual_total_rev
            when tmc.comp_metric = '% of Rental Revenue' then ar.actual_rental_rev
            when tmc.comp_metric = '% of Rental & Service Revenue' then ar.actual_rental_service_rev
            when tmc.comp_metric = '% of Retail Revenue' then ar.actual_retail_rev
            else ao.actual_rental_fleet_oec
           end) as comp_metric_amount
     , abs(case
            when tmc.comp_metric = '% of Total Revenue' then a.actual_amount/nullif(ar.actual_total_rev,0)
            when tmc.comp_metric = '% of Rental Revenue' then a.actual_amount/nullif(ar.actual_rental_rev,0)
            when tmc.comp_metric = '% of Rental & Service Revenue' then a.actual_amount/nullif(ar.actual_rental_service_rev,0)
            when tmc.comp_metric = '% of Retail Revenue' then a.actual_amount/nullif(ar.actual_retail_rev,0)
            else (a.actual_amount*12)/nullif(ao.actual_rental_fleet_oec,0)
           end) as actual_pct_of_metric
     , abs(case
            when a.market_type = 'Core Solutions' and tmc.comp_metric = 'Annualized % of OEC' then (tmc.comp_amount*12)/nullif(tmc.comp_amount/nullif(tmc.pct_comp,0),0)
            when a.market_type = 'Advanced Solutions' and tmc.comp_metric = 'Annualized % of OEC' then (tma.comp_amount*12)/nullif(tma.comp_amount/nullif(tma.pct_comp,0),0)
            when a.market_type = 'Core Solutions' then tmc.pct_comp
            when a.market_type = 'Advanced Solutions' then tma.pct_comp
           end) as target_pct_of_metric
     , a.actual_amount
     , round((case
          when tmc.comp_metric = '% of Total Revenue' then ar.actual_total_rev
          when tmc.comp_metric = '% of Rental Revenue' then ar.actual_rental_rev
          when tmc.comp_metric = '% of Rental & Service Revenue' then ar.actual_rental_service_rev
          when tmc.comp_metric = '% of Retail Revenue' then ar.actual_retail_rev
          else ao.actual_rental_fleet_oec
         end) * nvl((case when a.market_type = 'Core Solutions' then tmc.pct_comp
                          when a.market_type = 'Advanced Solutions' then tma.pct_comp end),0),2) as target_amount
     , (case
         when a.rev_exp = 'EXP' then round(target_amount - a.actual_amount,2)
         else round(a.actual_amount - target_amount,2)
        end) as target_delta
 from actuals a
 join analytics.gs.plexi_periods pp on a.gl_month::date = pp.trunc::date
 left join actuals_oec ao on a.market_id = ao.market_id and a.gl_month = ao.gl_month
 left join actuals_revenues ar on a.market_id = ar.market_id and a.gl_month = ar.gl_month
 left join comp_market_accts_core tmc on a.account_no = tmc.account_no and a.account_name = tmc.account_name and a.rev_exp = tmc.rev_exp and a.type = tmc.type
 left join comp_market_accts_adv tma on a.account_no = tma.account_no and a.account_name = tma.account_name and a.rev_exp = tma.rev_exp and a.type = tma.type
 where a.region_name in('Southeast','Florida')
  and a.type not ilike '%sales%'
  and a.account_no not in('IBAB','HGAD','JAAA','HIAB','HIAC')
  and a.account_name not ilike '%commission%'
  and a.market_type in('Core Solutions','Advanced Solutions')
      ;;
  }

  dimension: region_name {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    label: "MarketID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    label: "Market"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: months_open_current {
    type: number
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: gl_month_date {
    type: date
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension_group: gl_month {
    label: "GL Month"
    type: time
    timeframes: [raw, month, year]
    sql: ${TABLE}."GL_MONTH" ;;
  }

  dimension: month_year {
    label: "Month"
    type: string
    sql: ${TABLE}."MONTH_YEAR" ;;
  }

  dimension: rev_exp {
    label: "Rev/Exp"
    type: string
    sql: ${TABLE}."REV_EXP" ;;
  }

  dimension: type {
    label: "Department"
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: account_no {
    label: "AccountNo"
    type: string
    sql: ${TABLE}."ACCOUNT_NO" ;;
  }

  dimension: account_name {
    label: "Account"
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: cost_type {
    type: string
    sql: ${TABLE}."COST_TYPE" ;;
  }

  dimension: comp_metric {
    type: string
    sql: ${TABLE}."COMP_METRIC" ;;
  }

  measure: comp_metric_amount {
    label: "Comp Metric Amount"
    type: sum
    sql: ${TABLE}."COMP_METRIC_AMOUNT" ;;
  }

  measure: actual_pct_of_metric {
    label: "Actual % of Metric"
    type: number
    value_format_name: percent_4
    sql: abs(sum(case
                  when ${TABLE}."COMP_METRIC" = 'Annualized % of OEC' then (${TABLE}."ACTUAL_AMOUNT"*12)
                  else ${TABLE}."ACTUAL_AMOUNT"
                 end)/sum(nullif(${TABLE}."COMP_METRIC_AMOUNT",0))) ;;
  }

  measure: target_pct_of_metric {
    label: "Target % of Metric"
    type: max
    value_format_name: percent_4
    sql: ${TABLE}."TARGET_PCT_OF_METRIC" ;;
  }

  measure: actual_amount {
    type: sum
    value_format_name: decimal_2
    sql: ${TABLE}."ACTUAL_AMOUNT" ;;
  }

  measure: target_amount {
    type: sum
    value_format_name: decimal_2
    sql: ${TABLE}."TARGET_AMOUNT" ;;
  }

  measure: target_delta {
    type: sum
    value_format_name: decimal_2
    sql: ${TABLE}."TARGET_DELTA" ;;
  }
}

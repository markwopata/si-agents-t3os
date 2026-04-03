view: monthly_payment_breakout {
  parameter: filter_date {
    type: date
  }
  derived_table: {
    sql:--this code is used to create monthly payment breakdowns for Lakeisha
--
with filter_date as (
  select {% parameter filter_date %}::date as filter_date
)
,ach_dt as
(
    select
        PHOENIX_ID,
        max(date) as ach_date
    from
        ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT,
         filter_date
    where
          gaap_non_gaap = 'Non-GAAP'
      and CUSTOMTYPE = 'Payment'
      and current_version = 'Yes'
      and date <= last_day(filter_date)
    group by PHOENIX_ID
)
,closest_dt as
(
    select
      phoenix_id, max(date) as closest_dt
    from
      ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT txdt,
         filter_date
    where
      txdt.gaap_non_gaap = 'Non-GAAP'
    and txdt.CUSTOMTYPE = 'MonthTotal'
    and current_version = 'Yes'
      and date <=
      last_day(filter_date)
    group by
      phoenix_id
)
,get_cur_bal as
(
   select
          b.phoenix_id,
          b.balance as balance,
          b.OEC,
          b.ENTITY,
          b.FINANCING_FACILITY_TYPE
   from
      closest_dt a
   left join
      ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT b
   on
        a.phoenix_id = b.phoenix_id
        and a.closest_dt = b.date
    where
          b.gaap_non_gaap = 'Non-GAAP'
      and b.CUSTOMTYPE = 'MonthTotal'
      and b.current_version = 'Yes'
)
,prev_mnth_closest_dt as
(
    select
      phoenix_id, max(date) as closest_dt
    from
      ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT txdt,
         filter_date
    where
      txdt.gaap_non_gaap = 'Non-GAAP'
    and txdt.CUSTOMTYPE = 'MonthTotal'
    and current_version = 'Yes'
      and date <=
      add_months(last_day(filter_date),-1)
    group by
      phoenix_id
)
--select * from prev_mnth_closest_dt where PHOENIX_ID = 1053
   --select add_months(last_day(filter_date),-1) from filter_date
,get_prev_bal as
(
   select
        b.phoenix_id,
        b.balance as prev_balance
   from
      prev_mnth_closest_dt a
   left join
      ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT b
   on
        a.phoenix_id = b.phoenix_id
        and a.closest_dt = b.date
    where
          b.gaap_non_gaap = 'Non-GAAP'
    and b.CUSTOMTYPE = 'MonthTotal'
    and b.current_version = 'Yes'
)
--select * from get_prev_bal where PHOENIX_ID = 1593
,pmt_cnt as
(
    select PHOENIX_ID,
           DATE,
           CUSTOMTYPE,
           SUM(COUNTER) AS PMTS_THIS_MONTH
    FROM
         filter_date,
    (select
        *,
        1 as counter
    from
        ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT)
    WHERE CUSTOMTYPE = 'Payment'
        and CURRENT_VERSION = 'Yes'
        and GAAP_NON_GAAP = 'Non-GAAP'
        and date between date_trunc('MONTH',filter_date) AND LAST_DAY((filter_date))
    GROUP BY PHOENIX_ID, DATE, CUSTOMTYPE
)
--select * from pmt_cnt_1 where PHOENIX_ID = 1053
,combine as
(
    select
        a.PHOENIX_ID,
        a.balance as cur_balance,
           a.OEC,
           a.ENTITY,
           a.FINANCING_FACILITY_TYPE,
        coalesce(b.prev_balance,0) as prev_balance
         ,coalesce(c.ach_date,null) as ach_date
        ,COALESCE(D.PMTS_THIS_MONTH,0) AS PMTS_THIS_MONTH
    from
        get_cur_bal a
        left join
        get_prev_bal b
        on a.PHOENIX_ID = b.PHOENIX_ID
        left join
        ach_dt c
        on a.PHOENIX_ID = c.PHOENIX_ID
        LEFT JOIN
        pmt_cnt D
        ON A.PHOENIX_ID = D.PHOENIX_ID
)
   --SELECT * FROM combine WHERE PHOENIX_ID = 1053
,add_pmt_info as
    (
        select y.phoenix_id,
               y.cur_balance,
               y.prev_balance,
               y.oec,
               y.ENTITY,
               y.FINANCING_FACILITY_TYPE,
               coalesce(tpd.principal, 0)  as principal,
               coalesce(tpd.interest, 0)   as interest,
               coalesce(tpd.NEGATIVECF, 0) as total_payment,
               y.ach_date,
               Y.PMTS_THIS_MONTH
        from filter_date,
             (select PHOENIX_ID,
                     cur_balance,
                     prev_balance,
                     oec,
                     ENTITY,
                     FINANCING_FACILITY_TYPE,
                     ach_date,
                     PMTS_THIS_MONTH
              from combine) as y
                 left join
             (select PHOENIX_ID,
                     principal,
                     interest,
                     NEGATIVECF,
                     date
              from ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT,
                   filter_date
              where gaap_non_gaap = 'Non-GAAP'
                and CUSTOMTYPE = 'MonthTotal'
                and current_version = 'Yes'
                and date = last_day(filter_date)) as tpd
             on tpd.PHOENIX_ID = y.PHOENIX_ID
    )
,pit as
    (
        select
               b.financial_schedule_id,
               b.lender,
               b.schedule as tval_loan_name,
               a.total_payment,
               a.principal,
               a.interest,
               a.ach_date,
               a.PMTS_THIS_MONTH,
               a.cur_balance as current_balance,
               a.prev_balance as prior_month_balance,
               a.OEC as orig_bal,
               a.ENTITY,
               a.FINANCING_FACILITY_TYPE as agreement_type,
               a.PHOENIX_ID,
               b.sage_loan_id,
               b.SAGE_LENDER_ID,
               b.SAGE_ACCOUNT_NUMBER
        from
            add_pmt_info a
        left join
            ANALYTICS.DEBT.PHOENIX_ID_TYPES b
        on a.PHOENIX_ID = b.PHOENIX_ID
    )
,add_sage_lender as
    (
        select
            a.*,
            b.name as sage_lender_name
        from
            pit a
            left join
            ANALYTICS.INTACCT.VENDOR b
            on a.SAGE_LENDER_ID = b.VENDORID
    )
,
pmt_schedule as
    (
        select PMT_SCHEDULE_ID, min(DATE) as commencement_date,
                max(date) as maturity_date
        from ANALYTICS.DEBT.LOAN_AMORTIZATION
        group by PMT_SCHEDULE_ID
    ),
loan_attributes as
    (
        select FINANCIAL_SCHEDULE_ID, PMT_SCHEDULE_ID, NOMINAL_RATE
        from ANALYTICS.DEBT.LOAN_ATTRIBUTES
        where
         not GAAP and not PENDING and RECORD_STOP_DATE like '9999%'
    ),
nbv_asset as
    (select aa.ASSET_ID,
            aa.oec - least(aa.oec *
                           case
                               when aa.asset_type_id in (2, 3)
                                   then .9 / (7 * 12) -- vehicle salvage = 10%, equip = 20%
                               else .8 / (10 * 12) end *
                           greatest(0, -- Prevent negative months diff
                           /*months*/ coalesce(datediff(month, case
                                                                   when aa.asset_type_id = 1
                                                                       then aa.FIRST_RENTAL
                                                                   else coalesce(aa.PURCHASE_DATE, aa.DATE_CREATED) end,
                                                        fd.filter_date) + 0.5,
                                               0)
                           ),
/*Salvage Value*/aa.oec *
                 case when aa.asset_type_id in (2, 3) then .9 else .8 end) *
                     case when aa.FIRST_RENTAL is null and aa.asset_type_id = 1 then 0 else 1 end NBV
     from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa,
          filter_date fd)
,
nbv_fsid as
(
    select aph.FINANCIAL_SCHEDULE_ID, round(sum(n.NBV),2) as nbv
    from nbv_asset n
    left join ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY aph
    on n.ASSET_ID = aph.ASSET_ID
    group by aph.FINANCIAL_SCHEDULE_ID
)
select asl.*, la.NOMINAL_RATE, ps.commencement_date, ps.maturity_date, COALESCE(nf.nbv,0) AS NBV
from add_sage_lender asl
left join loan_attributes la
    on asl.FINANCIAL_SCHEDULE_ID = la.FINANCIAL_SCHEDULE_ID
left join pmt_schedule ps
on la.PMT_SCHEDULE_ID = ps.PMT_SCHEDULE_ID
left join nbv_fsid nf
on asl.FINANCIAL_SCHEDULE_ID = nf.FINANCIAL_SCHEDULE_ID;;
}
  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}.financial_schedule_id ;;
  }
  dimension: phoenix_id {
    description: "Phoenix ID"
    type: number
    sql: ${TABLE}.phoenix_id ;;
    link: {
      label: "Go to Amortization Schedule!"
      url:"https://equipmentshare.looker.com/dashboards-next/379?Tval%20Loan%20Name=&Phoenix%20ID={{ value }}"
    }
  }
  dimension: principal {
    description: "Principal portion of total payment"
    type: number
    sql: ${TABLE}.principal ;;
  }
  dimension: interest {
    description: "Interest portion of total payment"
    type: number
    sql: ${TABLE}.interest ;;
  }
  dimension: total_payment {
    description: "Total Payment (i.e. interest plus principal)"
    type: number
    sql: ${TABLE}.total_payment ;;
  }
  dimension: ach_date {
    description: "Expected date of draft out of Simmons Bank account"
    type: date
    sql: ${TABLE}.ach_date ;;
  }
  dimension: pmts_this_month {
    description: "Number of payments made this month"
    type: number
    sql: ${TABLE}.pmts_this_month ;;
  }
  dimension: orig_bal {
    description: "Original Balance of Loan"
    type: number
    sql: ${TABLE}.orig_bal ;;
  }
  dimension: current_balance {
    description: "Current Balance of Loan"
    type: number
    sql: ${TABLE}.current_balance ;;
  }
  dimension: agreement_type {
    description: "Loan, Capital Lease, or Operating Lease?"
    type: string
    sql: ${TABLE}.agreement_type ;;
  }
  dimension: entity {
    description: "ES = EquipmentShare, IES1 = Innovative Equipment Services, IES2 = VLP, MESCO"
    type: string
    sql: ${TABLE}.entity ;;
  }
  dimension: prior_month_balance {
    description: "Balance of Loan as of end of previous month"
    type: number
    sql: ${TABLE}.prior_month_balance ;;
  }
  dimension: sage_loan_id {
    description: "Sage ID associated with the loan"
    type: string
    sql: ${TABLE}.sage_loan_id ;;
  }
  dimension: tval_loan_name {
    description: "Loan name used in tval online label field"
    type: string
    sql: ${TABLE}.tval_loan_name ;;
    link: {
      label: "Click to see all assets on this loan!"
      url:"https://equipmentshare.looker.com/dashboards-next/348?Sage+Loan+ID=&Schedule={{ value }}"
    }
  }
  dimension: sage_lender_id {
    description: "Lender ID from Sage"
    type: string
    sql: ${TABLE}.sage_lender_id ;;
  }
  dimension: lender {
    description: "Lender name used in debt tables"
    type: string
    sql: ${TABLE}.lender ;;
  }
  dimension: sage_lender_name {
    description: "Lender name used in Sage"
    type: string
    sql: ${TABLE}.sage_lender_name ;;
  }
  dimension: SAGE_ACCOUNT_NUMBER {
    description: "Account number in Sage"
    type: number
    sql: ${TABLE}.SAGE_ACCOUNT_NUMBER ;;
  }
  dimension: nominal_rate {
    description: "Nominal Interest Rate"
    type: number
    sql: ${TABLE}.NOMINAL_RATE ;;
  }
  dimension: commencement_date {
    description: "Commencement Date"
    type: date
    sql: ${TABLE}.COMMENCEMENT_DATE ;;
  }
  dimension: maturity_date {
    description: "Maturity Date"
    type: date
    sql: ${TABLE}.MATURITY_DATE ;;
  }
  dimension: nbv {
    description: "Sum of net book value of collateral."
    type: number
    sql: ${TABLE}.NBV ;;
  }
}

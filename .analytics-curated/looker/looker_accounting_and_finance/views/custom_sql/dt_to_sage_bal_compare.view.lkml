view: dt_to_sage_bal_compare {
  parameter: as_of_date {
    type: date
  }
  derived_table: {
    sql:
with filter_date as (
    select
         case when {% parameter as_of_date %}::date is null then
              current_timestamp::date
          else
              {% parameter as_of_date %}::date end filter_date
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
          b.FINANCING_FACILITY_TYPE,
          b.commencement_date,
          b.MATURITY_DATE
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
,add_pit as (
       select b.SCHEDULE, b.SAGE_ACCOUNT_NUMBER, b.lender, b.sage_loan_id as sage_loan_id_from_pit,
              b.financial_schedule_id, a.*
       from get_cur_bal a
                left join
            ANALYTICS.DEBT.PHOENIX_ID_TYPES b
            on a.PHOENIX_ID = b.PHOENIX_ID
   )
      --select * from add_pit;
,combine_slid as (
    select sage_loan_id_from_pit, sum(balance) as bal_by_slid
    from add_pit
    group by sage_loan_id_from_pit
   )
,add_combo as (
    select a.*, b.bal_by_slid, 1 as cntr
    from add_pit a
    left join
        combine_slid b
    on a.sage_loan_id_from_pit = b.sage_loan_id_from_pit
   )
      --select * from add_combo;
,cnt_by_slid as (
    select sage_loan_id_from_pit, sum(cntr) as num_loans_by_slid
    from add_combo
    group by sage_loan_id_from_pit
   )
 --  select * from cnt_by_slid where num_loans_by_slid > 1;
 ,final_pit as (
     select a.*, b.num_loans_by_slid
     from add_combo a
     left join
         cnt_by_slid b
     on a.sage_loan_id_from_pit = b.sage_loan_id_from_pit
   )
--select * from final_pit;
,get_amounts as (
    SELECT
           ul.name as sage_id,
           (cast(glt.tr_type as integer)*-1)*cast(glt.amount as float) as princ_amt
    FROM
         ANALYTICS.INTACCT.UD_LOAN ul
    LEFT JOIN
            ANALYTICS.INTACCT.VENDOR vd
    ON cast(vd.recordno as text) = ul.rvendor
    LEFT JOIN
             ANALYTICS.INTACCT.GLENTRY glt
    ON ul.id = cast(glt.gldimud_loan as text),
        filter_date fd
    WHERE
          glt.state = 'Posted'
        AND glt.accountno = '2500'
        and glt.entry_date <= fd.filter_date
)
,get_sage_bal as (
       select a.sage_id as sage_id_from_sage,
              --cast(round(sum(a.princ_amt),2) as float) as current_balance
              round(sum(a.princ_amt), 2) as current_sage_balance
       from get_amounts a
       group by a.sage_id
   )
,final as (
       select a.schedule,
              a.SAGE_ACCOUNT_NUMBER,
              a.lender,
              a.sage_loan_id_from_pit,
              a.FINANCIAL_SCHEDULE_ID,
              a.PHOENIX_ID,
              a.balance as DT_BAL_BY_FSID,
              a.oec,
              a.ENTITY,
              a.FINANCING_FACILITY_TYPE,
              a.COMMENCEMENT_DATE,
              a.MATURITY_DATE,
              a.bal_by_slid as DT_bal_by_slid,
              a.num_loans_by_slid as num_loans_per_slid,
              b.sage_id_from_sage,
              b.current_sage_balance
       from final_pit a
                full outer join
            get_sage_bal b
            on a.sage_loan_id_from_pit = b.sage_id_from_sage
   )
select *, coalesce(current_sage_balance,0) - coalesce(DT_bal_by_slid,0) as variance
   from final
;;
  }
  dimension: phoenix_id {
    description: "Phoenix ID"
    type: number
    sql: ${TABLE}.phoenix_id ;;
  }
  dimension: entity {
    description: "Entity"
    type: string
    sql: ${TABLE}.entity ;;
  }
  dimension: financing_facility_type {
    description: "Loan, Capital Lease, or Operating Lease?"
    type: string
    sql: ${TABLE}.financing_facility_type ;;
  }
  dimension: DT_BAL_BY_FSID {
    description: "Balance at the loan level according to the debt table"
    type: number
    value_format_name: usd
    sql: ${TABLE}.DT_BAL_BY_FSID ;;
  }
  dimension: schedule {
    description: "Loan name in debt table (From TVAL)"
    type: string
    sql: ${TABLE}.schedule ;;
  }
  dimension: lender {
    type: string
    sql: ${TABLE}.lender ;;
  }
  dimension: sage_loan_id_from_pit {
    type: string
    sql: ${TABLE}.sage_loan_id_from_pit ;;
  }
  dimension: sage_id_from_sage {
    type: string
    sql: ${TABLE}.sage_id_from_sage ;;
  }
  dimension: financial_schedule_id {
    description: "ID in ESTrack"
    type: number
    sql: ${TABLE}.financial_schedule_id ;;
  }
  dimension: oec {
    description: "Original loan balance in the debt table."
    type: number
    sql: ${TABLE}.oec ;;
  }
  dimension: sage_account_number {
    type: string
    sql: ${TABLE}.sage_account_number ;;
  }
  dimension: commencement_date {
    description: "Commencement date"
    type: date
    sql: ${TABLE}.commencement_date ;;
  }
  dimension: maturity_date {
    description: "Maturity date"
    type: date
    sql: ${TABLE}.maturity_date ;;
  }
  dimension: dt_bal_by_slid {
    description: "Balance at the sage loan ID level according to the debt table"
    type: number
    sql: ${TABLE}.dt_bal_by_slid ;;
  }
  dimension: num_loans_per_slid {
    type: number
    sql: ${TABLE}.num_loans_per_slid ;;
  }
  dimension: current_sage_balance {
    type: number
    sql: ${TABLE}.current_sage_balance ;;
  }
  dimension: variance {
    type: number
    sql: ${TABLE}.variance ;;
  }
  measure: display_as_of_date {
    description: "Balance as of this date"
    label: "Balance as of this date"
    type: date
    label_from_parameter: as_of_date
    sql:select
         case when {% parameter as_of_date %}::date is null then
              current_timestamp::date
          else
              {% parameter as_of_date %}::date end filter_date
          ;;
  }
}

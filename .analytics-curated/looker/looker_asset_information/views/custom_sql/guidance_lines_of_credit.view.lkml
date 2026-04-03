view: guidance_lines_of_credit {

  derived_table: {
    sql: select ph.lender, gloc.revolving as revolving,
      sum(case when dt.date = '2022-10-31' then dt.balance else 0 end) as balance
      ,sum(case when dt.date = '2022-10-31' then dt.principal else 0 end) as principal,
      gloc.guidance_line_amount as guidance_line,
     case when gloc.revolving= 'Yes' then (gloc.guidance_line_amount - sum(case when dt.date = '2022-10-31' then dt.balance else 0 end)) else 0 end as availability
      from analytics.debt.TV6_XML_DEBT_TABLE_CURRENT as dt
      inner join analytics.debt.phoenix_id_types as ph
      on dt.phoenix_id = ph.phoenix_id
      inner join analytics.debt.guidance_lines as gloc
      on ph.financial_lender_id = gloc.financial_lender_id
      where dt.customType = 'MonthTotal'
      and dt.gaap_non_gaap = 'Non-GAAP'
      and current_version = 'Yes'
      and ph.financial_lender_id in (
      486,
      367,
      300,
      539,
      497,
      301,
      461,
      437,
      440,
      298,
      369,
      453,
      372,
      449,
      496,
      456,
      488,
      441,
      537,
      607,
      622,
      125,
      602,
      430,
      458,
      371,
      565,
      13,
      627,
      12,
      447,
      489,
      618,
      532,
      609,
      619,
      457,
      23,
      634,
      483,
      475,
      445,
      53,
      633,
      443,
      547,
      549,
      680,
      677,
      365,
      563,
      550,
      568,
      455,
      544,
      543,
      535,
      452,
      629,
      608,
      552,
      477,
      626,
      620,
      632,
      612,
      462,
      46,
      460,
      530,
      610,
      30,
      614,
      678,
      675,
      436,
      115,
      674,
      463,
      603,
      606,
      616,
      611,
      467,
      484,
      466,
      635,
      493,
      541,
      481,
      628,
      639,
      637,
      433,
      495,
      469,
      479,
      640,
      442,
      564,
      551,
      676,
      459,
      478,
      465,
      545,
      491,
      474,
      476,
      613,
      431,
      100,
      434,
      623,
      542,
      567,
      454,
      464,
      534,
      538,
      617,
      473,
      615,
      621,
      482,
      1,
      566,
      470,
      604,
      553,
      485,
      492,
      439,
      673,
      462,
      42,
      562,
      438,
      305,
      546,
      451,
      29,
      444
      )
      group by ph.lender, gloc.revolving, gloc.guidance_line_amount

             ;;
  }

  dimension: lender {
    type: string
    sql: ${TABLE}.lender ;;
  }

  dimension: financial_lender_id {
    type: number
    sql: ${TABLE}.lender ;;
  }

  dimension: revolving {
    type: string
    sql: ${TABLE}.revolving ;;
  }

  measure: guidance_line {
    type: number
    sql: sum(${TABLE}.guidance_line) ;;
  }

  measure: principal {
    type: number
    sql: sum(${TABLE}.principal) ;;
  }

  measure: balance {
    type: number
    sql: sum(${TABLE}.balance) ;;
  }

  measure: availability {
    type: number
    sql: sum(${TABLE}.availability) ;;
  }

}

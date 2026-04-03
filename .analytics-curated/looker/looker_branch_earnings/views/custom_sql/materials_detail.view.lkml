view: materials_detail {
  derived_table: {
    sql:
      select
        mgd.pk,
        mgd.market_id,
        mbm.branch_id,
        mgd.entry_date,
        mgd.gl_account_number,
        mgd.entry_description,
        mgd.entry_amount,
        mgd.account_name,
        mgd.url_journal,
        mgd.fk_journal_id,
        mgd.fk_gl_entry_id,
        mgd.journal_transaction_number,
        mgd.product_category,
        mgd.short_description,
        mgd.status,
        mrx.market_name
      from Analytics.materials.int_materials_gl_detail mgd
      left join analytics.intacct_models.materials_branch_map mbm
      on mgd.market_id = mbm.market_id
      join  analytics.public.market_region_xwalk mrx
      on mgd.market_id = mrx.market_id;;
  }

  dimension: pk {
    primary_key: yes
    type: string
    sql: ${TABLE}.pk ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}.branch_id ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension_group: entry_date {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}.entry_date ;;
  }

  dimension: gl_account_number {
    type: string
    sql: ${TABLE}.gl_account_number ;;
  }

  dimension: entry_description {
    type: string
    sql: ${TABLE}.entry_description ;;
  }

  measure: entry_amount {
    type: sum
    sql: ${TABLE}.entry_amount ;;
    value_format: "#,##0.00"
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.account_name ;;
  }

  dimension: url_journal {
    type: string
    sql: ${TABLE}.url_journal ;;
    link: {
      label: "Open Journal"
      url: "${TABLE}.url_journal"
    }
  }

  dimension: fk_journal_id {
    type: string
    sql: ${TABLE}.fk_journal_id ;;
  }

  dimension: fk_gl_entry_id {
    type: string
    sql: ${TABLE}.fk_gl_entry_id ;;
  }

  dimension: journal_transaction_number {
    type: string
    sql: ${TABLE}.journal_transaction_number ;;
  }

  dimension: product_category {
    type: string
    sql: ${TABLE}.product_category ;;
  }

  dimension: short_description {
    type: string
    sql: ${TABLE}.short_description ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  measure: revenue {
    type: sum
    sql: CASE
        WHEN ${TABLE}.gl_account_number IN ('5015', 'FABFL') THEN ${TABLE}.entry_amount
        ELSE 0
       END ;;
    value_format_name: usd
  }

  measure: cogs {
    type: sum
    sql: CASE
        WHEN ${TABLE}.gl_account_number IN ('GADEL', '6034') THEN ${TABLE}.entry_amount
        ELSE 0
       END ;;
    value_format_name: usd
  }

  measure: payroll {
    type: sum
    sql:
    CASE
      WHEN ${account_name} ILIKE '%Payroll%' THEN ${TABLE}.entry_amount
      ELSE 0
    END ;;
    value_format_name: usd
  }

  measure: payroll_to_revenue {
    type: number
    sql: CASE
        WHEN ${revenue} != 0 THEN -${payroll} / ${revenue}
        ELSE NULL
        END;;
    value_format_name:  percent_2
  }

  measure: gross_margin {
    type: number
    sql: ${revenue} + ${cogs} ;;
    value_format_name: usd
  }

  measure: gross_margin_pct {
    type: number
    sql: CASE
        WHEN ${revenue} != 0 THEN (${revenue} + ${cogs}) / ${revenue}
        ELSE NULL
       END ;;
    value_format_name: percent_2
  }


  measure: net_margin_pct {
    type: number
    sql: CASE
        WHEN ${revenue} != 0 THEN (${entry_amount}) / ${revenue}
        ELSE NULL
       END ;;
    value_format_name: percent_2
  }







}

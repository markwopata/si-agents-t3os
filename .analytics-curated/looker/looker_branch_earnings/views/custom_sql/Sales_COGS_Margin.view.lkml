view: sales_cogs_margin {
  derived_table: {
    sql:
select m.market_id as MKT_ID
     , m.market_name as MKT_NAME
     , day(sn.GL_DATE) as day
     , month(sn.GL_DATE) as month
     , year(sn.GL_DATE) as year
     , sn.gl_date
     , sn.REVEXP
     , sn.ACCTNO
     , sn.GL_ACCT
     , coalesce(regexp_substr(sn.DESCR, ' Asset: ([0-9]*)',1,1,'e'),regexp_substr(sn.DESCR, ' Asset ID: ([0-9]*)',1,1,'e')) as asset_id
     , i.invoice_no
     , regexp_substr(sn.DESCR, ' InvoiceID: ([0-9]*)',1,1,'e') as invoice_id
     , sn.DESCR
     , sn.doc_no
     , sn.pk
     , sn.amt
     , (case when sn.revexp = 'REV' then sn.amt else 0 end) as revenue_amount
     , (case when sn.revexp = 'EXP' then sn.amt else 0 end) as expense_amount
     , 'https://admin.equipmentshare.com/#/home/transactions/invoices/' || regexp_substr(sn.DESCR, ' InvoiceID: ([0-9]*)',1,1,'e') as invoice_url
     , sn.URL_ADMIN
  from analytics.public.BRANCH_EARNINGS_DDS_SNAP as sn
  join analytics.branch_earnings.market m on sn.mkt_id = m.child_market_id
  left join es_warehouse.public.invoices i on regexp_substr(sn.DESCR, ' InvoiceID: ([0-9]*)',1,1,'e') = i.invoice_id::varchar
  where 1 = 1
    and (sn.acctno in('FBAA','FBBA','GBAA','GBBA','6101')
          --or (sn.descr ilike '%Dealership Equipment Sale: %' or sn.descr ilike '%Dealership Equipment Sale %')
          )
    and date_trunc('month', sn.gl_date)::date in (
      select trunc::date from analytics.gs.plexi_periods where {% condition period_name %} display {% endcondition %})
    ;;
  }

  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  parameter: report_month {
    label: "Month"
    type: number
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
    default_value: "2025"
    allowed_value: {value: "2025"}
  }

  dimension: gl_date {
    label: "GL Date"
    type: date
    sql: ${TABLE}.GL_DATE ;;
  }

  dimension: MARKET_ID {
    label: "MarketID"
    type: string
    sql: ${TABLE}.MKT_ID;;
  }

  dimension: MARKET_NAME {
    label: "Market"
    type: string
    sql: ${TABLE}.MKT_NAME;;
  }

  dimension: DESCRIPTION {
    label: "Description"
    type: string
    sql: ${TABLE}.DESCR;;
  }

  dimension: ASSET_ID {
    label: "AssetID"
    type: string
    value_format_name: id
    sql: ${TABLE}.ASSET_ID;;
  }

  dimension: INVOICE_ID {
    label: "InvoiceID"
    type: string
    value_format_name: id
    sql: ${TABLE}.INVOICE_ID;;
  }

  dimension: INVOICE_NUMBER {
    label: "InvoiceNo"
    type: string
    value_format_name: id
    sql: ${TABLE}.INVOICE_NO;;
    # drill_fields: [INVOICE_NUMBER]
    # link: {
    #   label: "Filter by Invoice"
    #   url: "@{db_dealership_sales_margin}?Month={{ _filters['report_month'] }}&Year={{ _filters['report_year'] }}&Market+Name={{ _filters['MARKET_NAME'] }}&Invoice+Number={{ value }}&Region+Name={{ _filters['market_region_xwalk.region_name'] }}&District={{ _filters['market_region_xwalk.district'] }}"
    # }
  }

  dimension: PK {
    type: string
    sql: ${TABLE}.PK;;
  }

  dimension: REVEXP {
    type: string
    sql: ${TABLE}.REVEXP ;;
  }

  dimension: AMOUNT {
    type: number
    value_format: "0.##"
    sql: ${TABLE}.AMT;;
  }

  dimension: ACCOUNT_NUMBER {
    label: "AccountNo"
    type: string
    sql: ${TABLE}.ACCTNO ;;
  }

  dimension: ACCOUNT_NAME {
    label: "Account"
    type: string
    sql: ${TABLE}.GL_ACCT ;;
  }

  measure: amount {
    label: "Amount"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."AMT" ;;
  }

  measure: revenue {
    label: "Revenue"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."REVENUE_AMOUNT" ;;
  }

  measure: expense {
    label: "Expense"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."EXPENSE_AMOUNT" ;;
  }

  measure: margin {
    label: "Margin"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."REVENUE_AMOUNT" + ${TABLE}."EXPENSE_AMOUNT" ;;
  }

  measure: margin_pct {
    label: "Margin %"
    type: number
    value_format_name: percent_2
    sql: CASE
          WHEN NULLIF(SUM(${TABLE}."REVENUE_AMOUNT"),0) IS NOT NULL THEN
           (SUM(${TABLE}."REVENUE_AMOUNT") + SUM(${TABLE}."EXPENSE_AMOUNT"))/NULLIF(SUM(${TABLE}."REVENUE_AMOUNT"),0)
         END;;
  }

  dimension: URL {
    label: "Admin Link"
    type: string
    html: {% if value != null %}
    <a href = "{{ value }}" target="_blank">
    <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png" width="16" height="16"> Admin</a>
    &nbsp;
    {% endif %};;
    sql: ${TABLE}.URL_ADMIN;;
  }

  dimension: INVOICE_URL {
    label: "Invoice Link"
    type: string
    html: {% if value != null %}
          <a href = "{{ value }}" target="_blank">
          <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png" width="16" height="16"> Admin</a>
          &nbsp;
          {% endif %};;
    sql: ${TABLE}.INVOICE_URL;;
  }

}

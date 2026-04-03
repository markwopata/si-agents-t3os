view: plexi_bucket_mapping {
  derived_table: {
    sql:
      select
        pbm._row as pk,
        pbm.display_name as account_category,
        pbm.sort_group as sort_category_number,
        pbm."GROUP" as short_account_category,
        pbm.gaap_account as is_gaap_account,
        coalesce(pbm.sage_name, gla.title) as gl_account_name,
        pbm.sage_gl as gl_account_number
      from
        analytics.gs.plexi_bucket_mapping as pbm
        left join analytics.intacct.glaccount as gla
          on pbm.sage_gl = gla.accountno
      where
        not pbm.exclude_flag
    ;;
  }

  dimension: pk {
    description: "Primary key"
    type: number
    primary_key: yes
    sql: ${TABLE}."PK" ;;
  }

  dimension: account_category {
    type: string
    sql: ${TABLE}."ACCOUNT_CATEGORY" ;;
  }

  dimension: short_account_category {
    type: string
    sql: ${TABLE}."SHORT_ACCOUNT_CATEGORY" ;;
  }

  dimension: sort_category_number {
    type: number
    sql: ${TABLE}."SORT_CATEGORY_NUMBER" ;;
  }

  dimension: is_gaap_account {
    type: yesno
    sql: ${TABLE}."IS_GAAP_ACCOUNT" ;;
  }

  dimension: gl_account_name {
    label: "GL Account Name"
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NAME" ;;
  }

  dimension: gl_account_number {
    label: "GL Account Number"
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NUMBER" ;;
  }

  measure: count {
    type: count
  }
}

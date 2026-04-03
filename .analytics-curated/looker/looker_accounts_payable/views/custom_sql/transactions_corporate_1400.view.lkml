#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: transactions_corporate_1400 {
  derived_table: {
    sql: with debit as (
    select
        createdby,
        department,
        try_cast(department as NUMBER) as numeric_department,
        amount,
        tr_type,
        entry_date,
        accountno,
        recordno,
        batchtitle

    from
        analytics.intacct.glentry
    where
        tr_type = 1
        and entry_date >= '2023-01-01'
        and numeric_department >= 1000000
        and numeric_department <= 1010000
        and accountno = '1400'
        and statistical = 'F'
        and location = 'E1'


)
, credit as (
    select
        createdby,
        department,
        try_cast(department as NUMBER) as numeric_department,
        amount,
        tr_type,
        entry_date,
        accountno,
        recordno,
        batchtitle

    from
        analytics.intacct.glentry
    where
        tr_type = -1
        and entry_date >= '2023-01-01'
        and numeric_department >= 1000000
        and numeric_department <= 1010000
        and accountno = '1400'
        and statistical = 'F'
        and location = 'E1'
)
select
    u.description                                             as USER_NAME,
    d.department                                              as DEPARTMENT,
    d.accountno                                               as GL_ACCOUNT,
    d.amount                                                  as AMOUNT,
    c.tr_type                                                 as CREDITED,
    d.entry_date                                              as POST_DATE,
    d.batchtitle                                              as HEADER_MEMO



from
    debit d
left join
    credit c on d.amount = c.amount
left join
    analytics.intacct.userinfo as u on d.createdby = u.recordno
left join
    Analytics.external_sharing.sage_corporate_actuals_sv s on s.glentry_recordno = d.recordno

    where
    credited is NULL
    and glentry_recordno is not null ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }

  dimension: gl_account {
    type: string
    sql: ${TABLE}."GL_ACCOUNT" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: credited {
    type: number
    sql: ${TABLE}."CREDITED" ;;
  }

  dimension: post_date {
    type: date
    sql: ${TABLE}."POST_DATE" ;;
  }

  dimension: header_memo {
    type: string
    sql: ${TABLE}."HEADER_MEMO" ;;
  }

  set: detail {
    fields: [
      user_name,
      department,
      gl_account,
      amount,
      credited,
      post_date,
      header_memo
    ]
  }
}

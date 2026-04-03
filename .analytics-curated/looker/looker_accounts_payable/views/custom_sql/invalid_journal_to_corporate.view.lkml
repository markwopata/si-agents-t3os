#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: invalid_journal_to_corporate {
  derived_table: {
    sql: with debit as
(
    select
        e.createdby,
        e.entry_date,
        e.department,
        e.accountno,
        e.tr_type,
        e.amount,
        b.journal,
        batchtitle
    from
        analytics.intacct.glentry e

    left join
        ANALYTICS.INTACCT.GLBATCH b on b.RECORDNO = e.BATCHNO
    where
        tr_type = 1
        and e.entry_date >= '2023-01-01'
        and e.statistical = 'F'
        and e.department = '1000000'
        and e.accountno != '7101'
        and e.accountno != '7113'
        and e.accountno != '7118'
        and e.accountno != '7119'
        and e.accountno != '7409'
        and e.accountno != '7435'
        and b.journal = 'APJ'
        and location = 'E1'


)
, credit as (
    select
        e.createdby,
        e.entry_date,
        e.department,
        e.accountno,
        e.tr_type,
        e.amount,
        b.journal,
        batchtitle
    from
        analytics.intacct.glentry e

    left join
        ANALYTICS.INTACCT.GLBATCH b on b.RECORDNO = e.BATCHNO
    where
        tr_type = -1
        and e.entry_date >= '2023-01-01'
        and e.statistical = 'F'
        and e.department = '1000000'
        and e.accountno != '7101'
        and e.accountno != '7113'
        and e.accountno != '7118'
        and e.accountno != '7119'
        and e.accountno != '7409'
        and e.accountno != '7435'
        and b.journal = 'APJ'
        and location = 'E1'
    )

select
    u.description                                             as USER_NAME,
    d.department                                              as DEPARTMENT,
    d.accountno                                               as GL_ACCOUNT,
    d.amount                                                  as AMOUNT,
    c.tr_type                                                 as CREDITED,
    d.entry_date                                              as POST_DATE,
    d.journal,
    d.batchtitle                                              as HEADER_MEMO


from
    debit d
left join
    credit c on d.amount = c.amount
left join
    analytics.intacct.userinfo as u on d.createdby = u.recordno

    where
        credited is NULL;;
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

  dimension: journal {
    type: string
    sql: ${TABLE}."JOURNAL" ;;
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
    journal,
    header_memo
  ]
  }
}

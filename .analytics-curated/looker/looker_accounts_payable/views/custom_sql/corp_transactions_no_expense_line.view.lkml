#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: corp_transactions_no_expense_line {
  derived_table: {
    sql: with debit as
(
    select
        createdby,
        entry_date,
        department,
        try_cast(department as NUMBER) as numeric_department,
        accountno,
        gldimexpense_line,
        tr_type,
        amount,
        batchtitle
    from
        analytics.intacct.glentry
    where
        tr_type = 1
        and entry_date >= '2023-01-01'
        and statistical = 'F'
        and numeric_department >= 1000001
        and numeric_department < 1010000
        and gldimexpense_line is NULL
        and location = 'E1'


)
, credit as (
    select
        createdby,
        entry_date,
        department,
        try_cast(department as NUMBER) as numeric_department,
        accountno,
        gldimexpense_line,
        tr_type,
        amount,
        batchtitle
    from
        analytics.intacct.glentry
    where
        tr_type = -1
        and entry_date >= '2023-01-01'
        and statistical = 'F'
        and numeric_department >= 1000001
        and numeric_department < 1010000
        and gldimexpense_line is NULL
        and location = 'E1'
    )
select
    u.description                                             as USER_NAME,
    d.department                                              as DEPARTMENT,
    d.accountno                                               as GL_ACCOUNT,
    d.amount                                                  as AMOUNT,
    c.tr_type                                                 as CREDITED,
    d.entry_date                                              as POST_DATE,
    d.gldimexpense_line                                       as EXPENSE_LINE,
    d.batchtitle                                              as HEADER_MEMO


FROM
    debit d
left join
    credit c on d.amount = c.amount
LEFT JOIN
    ANALYTICS.INTACCT.USERINFO u on u.RECORDNO = d.CREATEDBY
where
    credited is NULL
;;
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

dimension: expense_line {
  type: string
  sql: ${TABLE}."EXPENSE_LINE" ;;
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
    expense_line,
    header_memo
  ]
  }
}

view: memo_intercom_tags {
  derived_table: {
    sql: with metrics_memo_months as (
      select distinct
              date_trunc('month',billing_approved_date) as month
          ,   dateadd(month, -12, date_trunc('month',billing_approved_date)) as ytd_start_month
      from es_warehouse.public.invoices
      where date_trunc('month',billing_approved_date) is not null
      and date_trunc('month',billing_approved_date) >= '2023-01-01'
      and date_trunc('month',billing_approved_date) < date_trunc('month', current_date)
      ),
      distinct_months as (
      select month as month from metrics_memo_months
      union
      select ytd_start_month as month from metrics_memo_months
      )
      select
              m.month as intercom_conv_month
          ,   ch.id as conversation_id
          ,   t.name as tag_name
       from distinct_months m
       join analytics.intercom.conversation_history ch on m.month = date_trunc('month', cast(ch.created_at as date))
       join analytics.intercom.conversation_tag_history cth on ch.id = cth.conversation_id
       join analytics.intercom.tag t on t.id = cth.tag_id
       where t.name is not null
      and t.name not like '%Test%' ;;
  }

  dimension: intercom_conv_month {
    type: date_month
    convert_tz: no
    sql: ${TABLE}."INTERCOM_CONV_MONTH" ;;
  }

  dimension: tag_name {
    type: string
    sql: ${TABLE}."TAG_NAME" ;;
  }

  measure: conversation_count {
    type: count_distinct
    sql: ${TABLE}."CONVERSATION_ID" ;;
  }

}

view: sage_cpltd {
  parameter: as_of_date {
    type: date
  }
  derived_table: {
    sql:
with filter_date as
(
  select {% parameter as_of_date %} as filter_date
         --'2021-03-31'::date as filter_date
),
SAGE_CPLTD_1 AS
(
  select round(sum(cast(amount as double precision) * cast(tr_type as integer) * -1)) as sage_cpltd
      from ANALYTICS.INTACCT.GLENTRY gt,
      filter_date
      where
      gt.state = 'Posted'
      AND
        gt.accountno = '2400'
        and
        gt.entry_date <= coalesce(filter_date,TO_TIMESTAMP(CURRENT_DATE))
)
SELECT * FROM SAGE_CPLTD_1
                  ;;
  }
  dimension: sage_cpltd {
    description: "CPLTD according to the debt table"
    type: number
    sql: ${TABLE}.sage_cpltd ;;
  }
  measure: display_as_of_date {
    description: "CPLTD as of this date"
    label: "CPLTD as of this date"
    type: date
    label_from_parameter: as_of_date
    sql:  {% parameter as_of_date %}
          --(date (date (date_trunc('month', {% parameter as_of_date %})) + interval '1 year') - interval '1 day')::date
          ;;
  }
}

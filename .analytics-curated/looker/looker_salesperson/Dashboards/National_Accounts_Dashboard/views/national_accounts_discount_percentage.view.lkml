view: national_accounts_discount_percentage {
  derived_table: {
    sql:
        with max_update_date as (
              select
                  max(hlfs.gl_date) as max_date
              from
                  analytics.branch_earnings.high_level_financials hlfs
                  JOIN analytics.gs.plexi_periods pp on pp.trunc::date = hlfs.gl_date::date
              where
                  period_published = 'published'
              )
              , market_open_length as (
              select
                  market_id,
                  IFF(datediff(months,branch_earnings_start_month,max_date)+1 > 12,TRUE,FALSE) as months_open_over_12
              from
                  ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE
                  CROSS JOIN max_update_date
              where
                  market_id BETWEEN 0 AND 500000
                  AND market_id != 15967
        )

        , national_accounts as (
          SELECT
            bcp.company_id,
            c.name as company,
            pcr.parent_company_name,
            COALESCE(CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
                           THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
                           ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END,
                     'Unassigned') as assigned_nam,
            lower(cd.work_email) as nam_email
          FROM es_warehouse.public.billing_company_preferences bcp
          JOIN es_warehouse.public.companies c ON bcp.company_id = c.company_id
          LEFT JOIN analytics.bi_ops.v_parent_company_relationships pcr ON c.company_id = pcr.company_id
          LEFT JOIN analytics.commission.nam_company_assignments nca ON nca.company_id = c.company_id
          LEFT JOIN es_warehouse.public.users u on u.user_id = nca.nam_user_id
          LEFT JOIN analytics.payroll.company_directory cd ON lower(u.EMAIL_ADDRESS) = lower(cd.WORK_EMAIL)
          WHERE bcp.PREFS:national_account = TRUE
            AND current_timestamp() BETWEEN nca.effective_start_date AND nca.effective_end_date
      )

        --, final_query as (
              select
                  rp.invoice_date_created,
                  i.invoice_no,
                  mrx.region_name as region,
                  mrx.district,
                  rp.market_id,
                  mrx.market_name as market,
                  mrx.market_type,
                  COALESCE(bs.name, 'No Class Listed') AS business_segment_name,
                  mol.months_open_over_12,
                  rp.online_rate,
                  rp.company_id,
                  rp.company_name,
                  na.parent_company_name,
                  na.assigned_nam,
                  rp.salesperson_user_id,
                  CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
                   THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
                   ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END as salesperson,
                  rp.amount,
                  percent_discount,
              from
                  analytics.public.rateachievement_points rp
                  JOIN analytics.public.market_region_xwalk mrx on rp.market_id = mrx.market_id
                  LEFT JOIN es_warehouse.public.invoices i on rp.invoice_id = i.invoice_id
                  LEFT JOIN es_warehouse.public.equipment_classes ec on ec.equipment_class_id = rp.equipment_class_id
                  LEFT JOIN market_open_length mol on mol.market_id = rp.market_id
                  LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id
                  LEFT JOIN national_accounts na ON rp.company_id = na.company_id
                  LEFT JOIN es_warehouse.public.users u ON u.user_id = rp.salesperson_user_id
                  LEFT JOIN analytics.payroll.company_directory cd ON lower(u.email_address) = lower(cd.work_email)
              where
                  rp.invoice_date_created::date >= current_date - interval '29 days'
                  AND (ec.name is null OR UPPER(ec.name) not like UPPER('%bucket%'))
                  AND mrx.division_name = 'Rental'
                  /*AND rp.salesperson_user_id IN (SELECT user_id
                                                 FROM analytics.commission.employee_commission_info
                                                 WHERE commission_type_id = 6)
                  */
                  AND rp.company_id IN (SELECT company_id
                                        FROM es_warehouse.public.billing_company_preferences
                                        WHERE PREFS:national_account = TRUE)
                  AND (({{ _user_attributes['job_role'] }} = 'nam' AND na.nam_email = '{{ _user_attributes['email'] }}')
                       -- Hardcode for Jessica to only see Tyler Levin's accounts
                       OR ('{{ _user_attributes['email'] }}' = 'jessica.howard@equipmentshare.com' AND lower(na.nam_email) = 'tyler.levins@equipmentshare.com')
                       OR ('{{ _user_attributes['email'] }}' <> 'jessica.howard@equipmentshare.com' AND {{ _user_attributes['job_role'] }} <> 'nam'));;
        # )
        # SELECT *
        # FROM final_query
        # WHERE
        #   (
        #     ('salesperson' = {{ _user_attributes['department'] }} AND SP_EMAIL ILIKE '{{ _user_attributes['email'] }}')
        #     )
        #     OR
        #     (
        #     ('salesperson' != {{ _user_attributes['department'] }}
        #       AND
        #       ('developer' = {{ _user_attributes['department'] }}
        #       OR 'god view' = {{ _user_attributes['department'] }}
        #       OR 'managers' = {{ _user_attributes['department'] }}
        #       OR 'finance' = {{ _user_attributes['department'] }}
        #       OR 'collectors' = {{ _user_attributes['department'] }}
        #       )
        #     )
        #     );;
  }

  dimension_group: invoice_date_created {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE_CREATED" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: invoice_no_with_link {
    label: "Invoice Number With Link"
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
    html: <font color="#0063f3 "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_no}}" target="_blank">{{ invoice_no._value }}</a></font></u> ;;
  }

  dimension: sp_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: sp_name {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: parent_company {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME";;
  }

  dimension: assigned_nam {
    type: string
    sql: ${TABLE}."ASSIGNED_NAM" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: business_segment {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT_NAME" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: months_open_over_12 {
    type: yesno
    sql: ${TABLE}."MONTHS_OPEN_OVER_12" ;;
  }

  dimension: online_rate {
    type: number
    sql: ${TABLE}."ONLINE_RATE" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd_0
  }

  measure: total_discount {
    type: sum
    sql: ${online_rate} - ${amount};;
    value_format: "$#,##0"
  }

  dimension: percent_discount {
    type: number
    sql: ${TABLE}."PERCENT_DISCOUNT" ;;
  }

  measure: total_inv_amt {
    type: sum
    sql: ${amount} ;;
    value_format: "0"
  }

  measure: total_discount_percentage {
    type: number
    # sql: IFF(((${total_percent_discount}*${total_online_rate})/${total_online_rate}) is null,1,((${total_percent_discount}*${total_online_rate})/${total_online_rate})) ;;
    sql: case when sum(${online_rate}) != 0 and sum(${percent_discount}) is not null then (sum(${percent_discount}*${online_rate})/sum(${online_rate}))
      else 1 end;;
    value_format_name: percent_1
  }

  measure: weighted_percentage_discount_formatted {
    type: number
    sql: ${total_discount_percentage} ;;
    html: {% if total_discount_percentage._value < 0.1599 %}

            <span style="color: goldenrod;"> {{total_discount_percentage._rendered_value }} </span>

      {% elsif total_discount_percentage._value >= 0.16 and total_discount_percentage._value <= 0.3099 %}

      <span style="color: #ee7772;"> {{total_discount_percentage._rendered_value }} </span>

      {% elsif total_discount_percentage._value <= 0.3099 %}

      <span style="color: #ee7772;"> {{total_discount_percentage._rendered_value }} </span>

      {% else %}

      <span style="color: #b02a3e;"> {{total_discount_percentage._rendered_value }} </span>

      {% endif %};;
  }
}

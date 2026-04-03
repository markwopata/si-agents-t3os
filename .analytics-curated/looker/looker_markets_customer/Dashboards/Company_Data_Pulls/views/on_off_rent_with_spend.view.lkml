view: on_off_rent_with_spend {
  derived_table: {
    sql: WITH rental_amounts AS(
        select
          r.rental_id,
          po.name as purchase_order,
          sum(li.amount) as amount,
          max(i.date_created) as latest_invoice_date
        from
          es_warehouse.public.orders o
          join es_warehouse.public.rentals r on o.order_id = r.order_id
          join analytics.public.v_line_items li on r.rental_id = li.rental_id
          left join es_warehouse.public.users u on u.user_id = o.user_id
          join es_warehouse.public.companies c on c.company_id = u.company_id
          left join es_warehouse.public.invoices i on i.invoice_id = li.invoice_id
          left join es_warehouse.public.purchase_orders po on po.purchase_order_id = i.purchase_order_id
        where
          {% if show_children._parameter_value == "'Yes'" %}
            --show parent company relationships
            c.company_id IN (
              SELECT company_id
              FROM analytics.bi_ops.v_parent_company_relationships
              WHERE {% condition company_filter %} CONCAT(parent_company_id, ' - ', parent_company_name) {% endcondition %}
            )
          {% else %}
            --company filter
            {% condition company_filter %} CONCAT(c.company_id, ' - ', c.name) {% endcondition %}
          {% endif %}
        group by
          r.rental_id, po.name
      )

      , rental_locations AS (
        select r.rental_id, listagg(l.nickname,', ') as jobsite
        from es_warehouse.public.rentals r
        left join es_warehouse.public.orders o on r.order_id = o.order_id
        left join es_warehouse.public.users u on u.user_id = o.user_id
        left join es_warehouse.public.companies c on u.company_id = c.company_id
        left join es_warehouse.public.rental_location_assignments rla on rla.rental_id = r.rental_id
        left join es_warehouse.public.locations l on l.location_id = rla.location_id
        where
          {% if show_children._parameter_value == "'Yes'" %}
            --show parent company relationships
            c.company_id IN (
              SELECT company_id
              FROM analytics.bi_ops.v_parent_company_relationships
              WHERE {% condition company_filter %} CONCAT(parent_company_id, ' - ', parent_company_name) {% endcondition %}
            )
          {% else %}
            --company filter
            {% condition company_filter %} CONCAT(c.company_id, ' - ', c.name) {% endcondition %}
          {% endif %}
        group by
          r.rental_id
      )

      , phases_and_jobs as (
          select
            r.rental_id
          , j.name as phase_job_name
          , jp.name as job_name
          from es_warehouse.public.orders o
          left join es_warehouse.public.rentals r on (r.order_id = o.order_id)
          join es_warehouse.public.jobs j on (j.job_id = o.job_id) and j.parent_job_id is not null
          left join es_warehouse.public.jobs jp on (j.parent_job_id = jp.job_id)
          where r.asset_id is not null
            and r.deleted = false
            and o.deleted = false
       union
          select
            r.rental_id
          , NULL as phase_job_name
          , j.name as job_name
          from es_warehouse.public.orders o
          left join es_warehouse.public.rentals r on (r.order_id = o.order_id)
          join es_warehouse.public.jobs j on (j.job_id = o.job_id) and j.parent_job_id is null
          where r.asset_id is not null
            and r.deleted = false
            and o.deleted = false
      )

      , current_assets AS (
        SELECT
            rental_id,
            asset_id as current_asset_id
        FROM ES_WAREHOUSE.PUBLIC.EQUIPMENT_ASSIGNMENTS
        QUALIFY ROW_NUMBER() OVER(PARTITION BY rental_id ORDER BY start_date desc) = 1
      )

      , all_rentals AS(
        select
            r.rental_id,
            o.order_id,
            o.sub_renter_id,
            r.asset_id as rental_asset_id,
            coalesce(a.asset_class,pt.description,' ') as asset_class,
            coalesce(amt.purchase_order,po.name) as purchase_order_name,
            r.start_date::date as rental_start_date,
            r.end_date::date as rental_end_date,
            ac.next_cycle_inv_date::date::date as next_cycle_date,
            ac.total_days_on_rent,
            ac.days_left as billing_days_left,
            round(coalesce(amt.amount,0)+
              case when coalesce(amt.purchase_order,po.name) <> po.name then 0
                   when amt.latest_invoice_date BETWEEN ac.START_THIS_RENTAL_CYCLE AND ac.END_THIS_RENTAL_CYCLE THEN 0
              else coalesce(rrc.cheapest_option,0) end
            ,2) as to_date_rental,
            'On Rent' as rental_status,
            c.company_id,
            c.name as company_name,
            r.price_per_day,
            r.price_per_week,
            r.price_per_month,
            coalesce(r.quantity,1) as quantity,
            --l.nickname as jobsite
            l.jobsite,
            concat(u.first_name,' ',u.last_name,' (',u.phone_number,')') as order_by_with_phone_number,
            m.name as order_branch_location
        from
            es_warehouse.public.rentals r
            left join es_warehouse.public.assets a on a.asset_id = r.asset_id
            left join es_warehouse.public.admin_cycle ac on ac.rental_id = r.rental_id and ac.asset_id = r.asset_id
            left join es_warehouse.public.orders o on r.order_id = o.order_id
            left join es_warehouse.public.purchase_orders po on po.purchase_order_id = o.purchase_order_id
            left join es_warehouse.public.companies poc on po.company_id = poc.company_id
            left join es_warehouse.public.users u on u.user_id = o.user_id
            join es_warehouse.public.companies c on c.company_id = u.company_id
            left join rental_amounts amt on amt.rental_id = r.rental_id
            left join es_warehouse.public.remaining_rental_cost rrc on rrc.rental_id = r.rental_id and o.purchase_order_id = po.purchase_order_id
            left join rental_locations l on l.rental_id = r.rental_id
            left join es_warehouse.public.rental_part_assignments rpa on rpa.rental_id = r.rental_id
            left join es_warehouse.inventory.parts p on p.part_id = rpa.part_id
            left join es_warehouse.inventory.part_types pt on pt.part_type_id = p.part_type_id
            left join es_warehouse.public.markets m on m.market_id = o.market_id
        where
          --match on purchase order table
            {% if show_children._parameter_value == "'Yes'" %}
              poc.company_id IN (
                SELECT company_id
                FROM analytics.bi_ops.v_parent_company_relationships
                WHERE {% condition company_filter %} CONCAT(parent_company_id, ' - ', parent_company_name) {% endcondition %}
              )
            {% else %}
              {% condition company_filter %} CONCAT(poc.company_id, ' - ', poc.name) {% endcondition %}
            {% endif %}
          AND
          --match on companies table
            {% if show_children._parameter_value == "'Yes'" %}
              c.company_id IN (
                SELECT company_id
                FROM analytics.bi_ops.v_parent_company_relationships
                WHERE {% condition company_filter %} CONCAT(parent_company_id, ' - ', parent_company_name) {% endcondition %}
              )
            {% else %}
              --company filter on companies table
              {% condition company_filter %} CONCAT(c.company_id, ' - ', c.name) {% endcondition %}
            {% endif %}
          AND r.rental_status_id = 5

       UNION

        select
            r.rental_id,
            o.order_id,
            o.sub_renter_id,
            r.asset_id,
            coalesce(a.asset_class,pt.description,' ') as asset_class,
            coalesce(amt.purchase_order,po.name) as purchase_order_name,
            r.start_date::date as rental_start_date,
            r.end_date::date as rental_end_date,
            NULL,
            NULL,
            NULL,
            round(coalesce(amt.amount,0),2),
            'Off Rent',
            c.company_id,
            c.name,
            r.price_per_day,
            r.price_per_week,
            r.price_per_month,
            coalesce(r.quantity,1) as quantity,
            --l.nickname as jobsite
            l.jobsite,
            concat(u.first_name,' ',u.last_name,' (',u.phone_number,')') as order_by_with_phone_number,
            m.name as order_branch_location
        from
            es_warehouse.public.rentals r
            left join es_warehouse.public.orders o on r.order_id = o.order_id
            left join es_warehouse.public.users u on u.user_id = o.user_id
            join es_warehouse.public.companies c on c.company_id = u.company_id
            left join es_warehouse.public.assets a on r.asset_id = a.asset_id
            left join es_warehouse.public.purchase_orders po on po.purchase_order_id = o.purchase_order_id
            left join es_warehouse.public.companies poc on po.company_id = poc.company_id
            left join rental_amounts amt on amt.rental_id = r.rental_id
            left join es_warehouse.public.rental_part_assignments rpa on rpa.rental_id = r.rental_id
            left join es_warehouse.inventory.parts p on p.part_id = rpa.part_id
            left join es_warehouse.inventory.part_types pt on pt.part_type_id = p.part_type_id
            left join rental_locations l on l.rental_id = r.rental_id
            left join es_warehouse.public.markets m on m.market_id = o.market_id
        where
              '2021-01-01'::date <= r.end_date::date
          and r.start_date::date <= current_date
          AND
          --match on purchase order table
            {% if show_children._parameter_value == "'Yes'" %}
              poc.company_id IN (
                SELECT company_id
                FROM analytics.bi_ops.v_parent_company_relationships
                WHERE {% condition company_filter %} CONCAT(parent_company_id, ' - ', parent_company_name) {% endcondition %}
              )
            {% else %}
              {% condition company_filter %} CONCAT(poc.company_id, ' - ', poc.name) {% endcondition %}
            {% endif %}
          AND
          --match on companies table
            {% if show_children._parameter_value == "'Yes'" %}
              c.company_id IN (
                SELECT company_id
                FROM analytics.bi_ops.v_parent_company_relationships
                WHERE {% condition company_filter %} CONCAT(parent_company_id, ' - ', parent_company_name) {% endcondition %}
              )
            {% else %}
              --company filter on companies table
              {% condition company_filter %} CONCAT(c.company_id, ' - ', c.name) {% endcondition %}
            {% endif %}
          and r.rental_status_id <> 5
      )

      SELECT
        r.*,
        a.current_asset_id,
        pj.phase_job_name,
        pj.job_name,
        c.name sub_renting_company,
        concat(u.first_name, ' ', u.last_name) as sub_renting_contact
      FROM all_rentals r
      LEFT JOIN current_assets a ON r.rental_id = a.rental_id
      LEFT JOIN phases_and_jobs pj ON r.rental_id = pj.rental_id
      left join es_warehouse.public.sub_renters sr on sr.sub_renter_id = r.sub_renter_id
      left join es_warehouse.public.users u on sr.sub_renter_ordered_by_id = u.user_id
      left join es_warehouse.public.companies c on sr.sub_renter_company_id = c.company_id;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format: "0"
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
    value_format: "0"
  }

  dimension: rental_asset_id {
    type: number
    sql: ${TABLE}."RENTAL_ASSET_ID" ;;
    value_format: "0"
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: purchase_order_name {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NAME" ;;
  }

  dimension: rental_start_date {
    type: date
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }

  dimension: rental_end_date {
    type: date
    sql: ${TABLE}."RENTAL_END_DATE" ;;
  }

  dimension: next_cycle_date {
    type: date
    sql: ${TABLE}."NEXT_CYCLE_DATE" ;;
  }

  dimension: total_days_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_DAYS_ON_RENT" ;;
  }

  dimension: billing_days_left {
    type: number
    sql: ${TABLE}."BILLING_DAYS_LEFT" ;;
  }

  dimension: to_date_rental {
    type: number
    sql: ${TABLE}."TO_DATE_RENTAL" ;;
    value_format_name: usd_0
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format: "0"
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd_0
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd_0
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd_0
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
  }

  dimension: order_by_with_phone_number {
    type: string
    sql: ${TABLE}."ORDER_BY_WITH_PHONE_NUMBER" ;;
  }

  dimension: order_branch_location {
    type: string
    sql: ${TABLE}."ORDER_BRANCH_LOCATION" ;;
  }

  dimension: current_asset_id {
    type: number
    sql: ${TABLE}."CURRENT_ASSET_ID" ;;
    value_format: "0"
  }

  dimension: asset_swap {
    type: string
    sql: CASE WHEN ${rental_asset_id} = ${current_asset_id} THEN 'No'
              WHEN ${rental_asset_id} IS NULL AND ${current_asset_id} IS NULL THEN 'No'
              ELSE 'Yes' END
              ;;
  }

  dimension: phase_job_name {
    type: string
    sql: ${TABLE}."PHASE_JOB_NAME" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  filter: company_filter {}

  parameter: show_children {
    allowed_value: {value: "Yes"}
    allowed_value: {value: "No"}
  }

  dimension: sub_renting_contact {
    type: string
    sql: ${TABLE}."SUB_RENTING_CONTACT" ;;
  }

  dimension: sub_renting_company {
    type: string
    sql: ${TABLE}."SUB_RENTING_COMPANY" ;;
  }

  set: detail {
    fields: [
      rental_id,
      order_id,
      rental_asset_id,
      asset_class,
      purchase_order_name,
      rental_start_date,
      rental_end_date,
      next_cycle_date,
      total_days_on_rent,
      billing_days_left,
      to_date_rental,
      rental_status,
      company_id,
      company_name,
      price_per_day,
      price_per_week,
      price_per_month,
      quantity,
      jobsite,
      order_by_with_phone_number,
      order_branch_location,
      current_asset_id,
      phase_job_name,
      job_name
    ]
  }
}

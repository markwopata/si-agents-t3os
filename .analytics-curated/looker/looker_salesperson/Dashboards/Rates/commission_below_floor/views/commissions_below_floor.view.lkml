view: commissions_below_floor {

  derived_table: {

    sql:
     with below_floor as (select a.line_item_id, a.RATE_TIER_ID, name, commission_percentage, category
from fleet_optimization.gold.fact_rate_achievement a
         left join analytics.RATE_ACHIEVEMENT.COMMISSION_RATE_TIERS b on a.rate_tier_id = b.rate_tier_id
         where a.BILLING_APPROVED_DATE::date >= '2025-09-01'
         ),

      --select * from es_warehouse.public.company_rental_rates limit 100
      --select * from es_warehouse.public.line_items limit 100

      original_snapshots as (

        select line_item_id,
        AMOUNT,
        price_per_unit,
        row_number() over(partition by line_item_id order by dbt_valid_from asc) as rank
        from fleet_optimization.snapshots.fact_rate_achievement_snapshot
        qualify rank = 1

      ),
      manual_adjustments AS (select bf.line_item_id,
                                 o.amount,
                                 o.price_per_unit
                                 from fleet_optimization.gold.fact_rate_achievement as bf
                                 left join original_snapshots as o
                                 on bf.line_item_id = o.line_item_id
                                 where o.amount != bf.amount),

line_items as (select      f.line_item_id,
                           li.LINE_ITEM_TYPE_ID,
                           li.INVOICE_ID,
                           r.EQUIPMENT_CLASS_ID,
                           ec.BUSINESS_SEGMENT_ID,
                           r.RENTAL_ID,
                           i.COMPANY_ID,
                           i.SHIP_TO:location_id::number                                                            as location_id,
                           li.BRANCH_ID,
                           rr.DISTRICT,
                           rr.REGION,
                           o.DATE_CREATED                                                                           as order_created_date,
                           i.BILLING_APPROVED_DATE,
                           li.AMOUNT,
                           li.PRICE_PER_UNIT,
                           li.NUMBER_OF_UNITS,
                           li.extended_data,
                           li.EXTENDED_DATA:rental:cheapest_period_hour_count                                       as hours,
                           li.EXTENDED_DATA:rental:cheapest_period_day_count                                        as days,
                           li.EXTENDED_DATA:rental:cheapest_period_week_count                                       as weeks,
                           li.EXTENDED_DATA:rental:cheapest_period_four_week_count                                  as four_weeks,
                           li.EXTENDED_DATA:rental:cheapest_period_month_count                                      as months,
                           li.EXTENDED_DATA:rental:cheapest_period_cycle_max_count                                  as cycles,
                           datediff(day, i.START_DATE, i.END_DATE)                                                  as cycle_length,
                           case
                               when r.PRICE_PER_WEEK is null and r.PRICE_PER_MONTH is null and
                                    r.PRICE_PER_DAY is not null then true
                               else false end                                                                       as DAILY_BILLING_FLAG,
                           case
                               when li.EXTENDED_DATA:rental:price_per_four_weeks::number is not null then 'four_week'
                               when li.EXTENDED_DATA:rental:price_per_month::number is not null then 'monthly'
                               else null end                                                                        as BILLING_TYPE,
                           case
                               when bcp.prefs:four_week_billing_date::timestamptz is null then false
                               else true end                                                                        as PRORATED_FLAG --added
                    from fleet_optimization.gold.fact_rate_achievement as f
                             left join  ES_WAREHOUSE.PUBLIC.LINE_ITEMS li on li.line_item_id = f.line_item_id
                             left join ES_WAREHOUSE.PUBLIC.INVOICES i on li.INVOICE_ID = i.INVOICE_ID
                             left join ES_WAREHOUSE.PUBLIC.RENTALS r on li.RENTAL_ID = r.RENTAL_ID
                             left join ES_WAREHOUSE.PUBLIC.ORDERS o on r.ORDER_ID = o.ORDER_ID
                             left join ES_WAREHOUSE.PUBLIC.MARKETS m on o.MARKET_ID = m.MARKET_ID
                             left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
                                       on r.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
                             left join ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr on li.BRANCH_ID = rr.MARKET_ID
                             left join ES_WAREHOUSE.PUBLIC.BILLING_COMPANY_PREFERENCES bcp
                                       on bcp.COMPANY_ID = i.COMPANY_ID --added
                      and m.COMPANY_ID = 1854
                      and i.BILLING_APPROVED_DATE::date >= '2024-09-01'
                      qualify row_number() over(partition by f.line_item_id order by li.date_updated desc) = 1 --do we need this? Clawbacks?


                      ),





 location_rates as (select li.LINE_ITEM_ID,
                               lrr.PRICE_PER_MONTH as location_price_per_month,
                               lrr.PRICE_PER_WEEK  as location_price_per_week,
                               lrr.PRICE_PER_DAY   as location_price_per_day,
                               lrr.PRICE_PER_HOUR  as location_price_per_hour
                        from line_items li
                                 left join fleet_optimization.gold.dim_rates lrr
                                           on lrr.rate_scope = 'LOCATION' and
                                           lrr.company_id = li.company_id and
                                           li.EQUIPMENT_CLASS_ID = lrr.EQUIPMENT_CLASS_ID and
                                              li.location_id = lrr.LOCATION_ID and
                                              li.BILLING_APPROVED_DATE between lrr.effective_start_ts and lrr.RATE_ACHIEVEMENT_EXPIRATION_TS
                        where lrr.PRICE_PER_MONTH is not null
                        and li.BILLING_APPROVED_DATE >= '2025-08-15'
                        ),

    company_rates as (select li.LINE_ITEM_ID,
                              crr.PRICE_PER_MONTH as company_month,
                              crr.PRICE_PER_WEEK  as company_week,
                              crr.PRICE_PER_DAY   as company_day,
                              crr.PRICE_PER_HOUR  as company_hour
                       from line_items li
                                left join fleet_optimization.gold.dim_rates crr
                                          on li.EQUIPMENT_CLASS_ID = crr.EQUIPMENT_CLASS_ID and
                                             crr.rate_scope = 'COMPANY' AND
                                             li.COMPANY_ID = crr.COMPANY_ID and
                                             li.BILLING_APPROVED_DATE between crr.EFFECTIVE_START_TS and crr.RATE_ACHIEVEMENT_EXPIRATION_TS
                       where crr.PRICE_PER_MONTH is not null
                       and BILLING_APPROVED_DATE >= '2025-08-15'
                       ),

discount_rates as (select li.LINE_ITEM_ID,
                              drr.PRICE_PER_MONTH as discount_month,
                              drr.PRICE_PER_WEEK  as discount_week,
                              drr.PRICE_PER_DAY   as discount_day,
                              drr.PRICE_PER_HOUR  as discount_hour
                       from line_items li
                       left join analytics.rate_achievement.rate_regions as rr
                       on rr.market_id = li.branch_id
                                left join fleet_optimization.gold.dim_rates drr
                                          on li.EQUIPMENT_CLASS_ID = drr.EQUIPMENT_CLASS_ID and
                                             rr.district = drr.district and
                                             drr.rate_scope = 'DISTRICT' AND
                                             li.BILLING_APPROVED_DATE between drr.EFFECTIVE_START_TS and drr.RATE_ACHIEVEMENT_EXPIRATION_TS
                       where drr.PRICE_PER_MONTH is not null
                       and BILLING_APPROVED_DATE >= '2025-08-15'
                       ),
     -- returns all relevant rates
      company_below_floor as (select
      li.line_item_id,
      bf.name as rate_tier,
      li.line_item_type_id,
      li.invoice_id,
      r.rental_id,
      r.equipment_class_id as rental_equipment_class_id,
      li.amount,
      li.extended_data:rental:cheapest_period_day_count::number as cheapest_period_day,
      li.extended_data:rental:cheapest_period_hour_count::number as cheapest_period_hour,
      li.extended_data:rental:cheapest_period_week_count::number as cheapest_period_week,
      li.extended_data:rental:cheapest_period_month_count::number as cheapest_period_month,
      li.extended_data:rental:price_per_hour::number as line_item_price_per_hour,
      li.extended_data:rental:price_per_day::number as line_item_price_per_day,
      li.extended_data:rental:price_per_week::number as line_item_price_per_week,
      li.extended_data:rental:price_per_month::number as line_item_price_per_month,
      li.extended_data:rental:price_per_four_weeks::number as line_item_price_per_four_weeks,
      li.extended_data:rental:cheapest_period_cycle_max_count::number as cycle_max,
      li.extended_data:rental:cheapest_period_four_week_count::number as cheapest_period_four_week,
      i.billing_approved_date,
      li.number_of_units,
      case when li.line_item_type_id = 8 then datediff(hour, i.start_date, i.end_date) else null end as rental_length_hours,
      i.company_id,
      ec.equipment_class_id as invoice_equipment_class_id,
      crr.company_hour as customer_rate_hour, --pulls in actual customer and location rates for comparison in output. Used to create flags
      crr.company_day as customer_rate_day,
      crr.company_week as customer_rate_week,
      crr.company_month as customer_rate_month,
      lrr.location_price_per_hour as location_rate_hour,
      lrr.location_price_per_day as location_rate_day,
      lrr.location_price_per_week as location_rate_week,
      lrr.location_price_per_month as location_rate_month,

      li.branch_id,
      r.start_date as rental_start_date,

--      br.price_per_hour as historical_price_per_hour,
--      br.price_per_day as historical_price_per_day,
 --     br.price_per_week as historical_price_per_week,
--      br.price_per_month as historical_price_per_month,
--   the above becomes redundant with the revision of the company_rates cte. company rates are now the rates active at the time of the agreed upon date for those customer rates.
      dr.discount_month as deal_rate,
      m.price_per_unit as original_price,
      m.amount as original_amount
      from below_floor as bf
      left join line_items as  li
      on li.line_item_id = bf.line_item_id
      left join es_warehouse.public.invoices as i
      on li.invoice_id = i.invoice_id
       left join es_warehouse.public.rentals as r
      on r.rental_id = li.rental_id
      left join es_warehouse.public.equipment_classes as ec
      on ec.equipment_class_id = r.equipment_class_id
      left join company_rates as crr
      on crr.line_item_id = li.line_item_id
     left join discount_rates as dr
     on dr.line_item_id = bf.line_item_id
      left join location_rates as lrr
      on lrr.line_item_id = bf.line_item_id
      left join analytics.rate_achievement.rate_achievement_commissions_details as cd
      on cd.line_item_id = bf.line_item_id
      left join manual_adjustments as m
      on m.line_item_id = bf.line_item_id

     ),







      outputs as (select distinct
      cbf.*,
      crr.company_hour as company_hour,
      crr.company_day as company_day,
      crr.company_week as company_week,
      crr.company_month as company_month,
      lr.location_price_per_hour as location_price_per_hour,
      lr.location_price_per_day as location_price_per_day,
      lr.location_price_per_week as location_price_per_week,
      lr.location_price_per_month as location_price_per_month,
      bcp.rental_billing_cycle_strategy,
      case when bcp.prefs:four_week_billing_date = 'null' then null else bcp.PREFS:four_week_billing_date end as four_week_billing_date,
      f.price_per_hour as time_of_rental_price_per_hour,
      f.price_per_day as time_of_rental_price_per_day,
      f.price_per_week as time_of_rental_price_per_week,
      f.price_per_month as time_of_rental_price_per_month,
      f.date_created,
      case when customer_rate_month < deal_rate and customer_rate_month < company_month then TRUE
      when customer_rate_hour < company_hour then TRUE
      when customer_rate_day < company_day then TRUE
      when customer_rate_week < company_week then TRUE
      when customer_rate_month < company_month then TRUE else FALSE end as customer_rate_flag,
      case when cbf.AMOUNT < (coalesce(cheapest_period_day * f.price_per_day, 0)) + (coalesce(cheapest_period_week * f.price_per_week, 0)) + (coalesce(cheapest_period_hour * f.price_per_hour, 0)) + coalesce(cheapest_period_month * f.price_per_month, 0) + coalesce(cheapest_period_four_week * f.price_per_month, 0) then TRUE else FALSE end as current_rate_flag,
      case when original_price IS NOT NULL THEN TRUE else FALSE end as manual_adjustment_flag,
      case when location_rate_hour < location_price_per_hour then TRUE
      when location_rate_day < location_price_per_day then TRUE
      when location_rate_week < location_price_per_week then TRUE
      when location_rate_month < location_price_per_month then TRUE else FALSE end as location_rate_flag,
      case when cbf.rental_equipment_class_id != cbf.invoice_equipment_class_id THEN TRUE ELSE FALSE END as IS_SWAP



      from company_below_floor as cbf
      left join line_items as li
      on li.line_item_id = cbf.line_item_id
      left join es_warehouse.public.branch_rental_rates as f
     on li.EQUIPMENT_CLASS_ID = f.EQUIPMENT_CLASS_ID and li.BRANCH_ID = f.BRANCH_ID and f.rate_type_id = 3 and
                                      li.BILLING_APPROVED_DATE >= f.DATE_CREATED and li.BILLING_APPROVED_DATE <
                                                                                     coalesce(f.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz)

      left join location_rates as lr
      on lr.line_item_id = cbf.line_item_id
      left join company_rates as crr
      on crr.line_item_id = cbf.line_item_id
      left join es_warehouse.public.billing_company_preferences as bcp
      on bcp.company_id = cbf.company_id)

     select *
     from outputs
     where invoice_id is not null;;























  }


  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format: "##########0"

  }


  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format: "##########0"

  }

  dimension: rental_equipment_class_id {

    type: number
    sql: ${TABLE}."RENTAL_EQUIPMENT_CLASS_ID";;
    value_format: "##########0"

  }

  dimension: invoice_equipment_class_id {

    type: number
    sql: ${TABLE}."INVOICE_EQUIPMENT_CLASS_ID";;
    value_format: "##########0"

  }

  dimension: rate_tier {

    type: string
    sql: ${TABLE}."RATE_TIER" ;;

  }

  dimension: billing_approved_date {

    type: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;

  }

  dimension: last_rate_update {

    type: date
    sql: ${TABLE}."DATE_CREATED" ;;

  }

  dimension: line_item_id {

    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
    value_format: "##########0"
  }

  dimension: invoice_id {

    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format: "##########0"
  }

  dimension: rental_billing_cycle_strategy{

    type: string
    sql: ${TABLE}."RENTAL_BILLING_CYCLE_STRATEGY" ;;

  }

  dimension: four_week_billing_date {

    type: date
    sql: ${TABLE}."FOUR_WEEK_BILLING_DATE" ;;

  }

  dimension: cheapest_period_hour {
    type: string
    sql: ${TABLE}."CHEAPEST_PERIOD_HOUR" ;;
  }

  dimension: cheapest_period_day {
    type: string
    sql: ${TABLE}."CHEAPEST_PERIOD_DAY" ;;
  }

  dimension: cheapest_period_week {
    type: string
    sql: ${TABLE}."CHEAPEST_PERIOD_WEEK" ;;
  }

  dimension: cheapest_period_month {
    type: string
    sql: ${TABLE}."CHEAPEST_PERIOD_MONTH" ;;
  }

dimension: line_item_hour {

  type: number
  sql: ${TABLE}."LINE_ITEM_PRICE_PER_HOUR" ;;
  value_format_name: usd_0
}

  dimension: line_item_day {

    type: number
    sql: ${TABLE}."LINE_ITEM_PRICE_PER_DAY" ;;
    value_format_name: usd_0
  }

  dimension: line_item_week {

    type: number
    sql: ${TABLE}."LINE_ITEM_PRICE_PER_WEEK" ;;
    value_format_name: usd_0
  }

  dimension: line_item_month {

    type: number
    sql: ${TABLE}."LINE_ITEM_PRICE_PER_MONTH" ;;
    value_format_name: usd_0
  }

  dimension: line_item_four_weeks {

    type: number
    sql: ${TABLE}."LINE_ITEM_PRICE_PER_FOUR_WEEKS" ;;
    value_format_name: usd_0
  }

  dimension: cycle_max {
    type: number
    sql: ${TABLE}."CYCLE_MAX" ;;

  }

  dimension: cheapest_four_week {
    type: number
    sql: ${TABLE}."CHEAPEST_PERIOD_FOUR_WEEK" ;;

  }

  dimension: cheapest_period_details_html {
    label: "Cheapest Period Details"
    type: string
    sql: '' ;;

    html:
    <span>Hour:
      {% if commissions_below_floor.cheapest_period_hour._value != null %}
        {{ commissions_below_floor.cheapest_period_hour._value | number_with_delimiter }}
      {% else %}
        —
      {% endif %}
    </span><br/>

      <span>Day:
      {% if commissions_below_floor.cheapest_period_day._value != null %}
      {{ commissions_below_floor.cheapest_period_day._value | number_with_delimiter }}
      {% else %}
      —
      {% endif %}
      </span><br/>

      <span>Week:
      {% if commissions_below_floor.cheapest_period_week._value != null %}
      {{ commissions_below_floor.cheapest_period_week._value | number_with_delimiter }}
      {% else %}
      —
      {% endif %}
      </span><br/>

      <span>Month:
      {% if commissions_below_floor.cheapest_period_month._value != null %}
      {{ commissions_below_floor.cheapest_period_month._value | number_with_delimiter }}
      {% else %}
      —
      {% endif %}
      </span><br/>

      <span>Four Week:
      {% if commissions_below_floor.cheapest_four_week._value != null %}
      {{ commissions_below_floor.cheapest_four_week._value | number_with_delimiter }}
      {% else %}
      —
      {% endif %}
      </span><br/>

      <span>Cycle Max:
      {% if commissions_below_floor.cycle_max._value != null %}
      {{ commissions_below_floor.cycle_max._value | number_with_delimiter }}
      {% else %}
      —
      {% endif %}
      </span>
      ;;
  }


    dimension: price_details_html {
      label: "Pricing Details"
      type: string
      sql: '' ;;

      html:
          <span>Hour:
            {% if commissions_below_floor.line_item_hour._value != null %}
              ${{ commissions_below_floor.line_item_hour._value | number_with_delimiter }}
            {% else %}
              —
            {% endif %}
          </span><br/>

        <span>Day:
        {% if commissions_below_floor.line_item_day._value != null %}
        ${{ commissions_below_floor.line_item_day._value | number_with_delimiter }}
        {% else %}
        —
        {% endif %}
        </span><br/>

        <span>Week:
        {% if commissions_below_floor.line_item_week._value != null %}
        ${{ commissions_below_floor.line_item_week._value | number_with_delimiter }}
        {% else %}
        —
        {% endif %}
        </span><br/>

        <span>Month:
        {% if commissions_below_floor.line_item_month._value != null %}
        ${{ commissions_below_floor.line_item_month._value | number_with_delimiter }}
        {% else %}
        —
        {% endif %}
        </span><br/>

        <span>Four Weeks:
        {% if commissions_below_floor.line_item_four_weeks._value != null %}
        ${{ commissions_below_floor.line_item_four_weeks._value | number_with_delimiter }}
        {% else %}
        —
        {% endif %}
        </span>
        ;;
    }




 dimension: max_cycle_length {

  type: string
  sql: ${TABLE}."RENTAL_BILLING_CYCLE_STRATEGY" ;;

 }


  dimension: rate_type_id {

    type: number
    sql: ${TABLE}."RATE_TYPE_ID" ;;
  }

  dimension: amount {

    type: number
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;

  }

  dimension: number_of_units {

    type: number
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;


  }

  dimension: rental_length {

    type: string
    sql: FLOOR(${TABLE}."RENTAL_LENGTH_HOURS"/24)||' Days '|| MOD(${TABLE}."RENTAL_LENGTH_HOURS", 24) || ' Hours' ;;


  }

  dimension: company_id {

    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format: "##########0"

  }



  dimension: company_hour {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."CUSTOMER_RATE_HOUR" ;;

  }


  dimension: company_day {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."CUSTOMER_RATE_DAY" ;;

  }

  dimension: company_week {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."CUSTOMER_RATE_WEEK" ;;

  }

  dimension: company_month {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."CUSTOMER_RATE_MONTH" ;;

  }

  dimension: company_rates {

    type: string
    sql:'$'||FLOOR(${company_hour})||'/'||'$'||FLOOR(${company_day})||'/'||'$'||FLOOR(${company_week})||'/'||'$'||FLOOR(${company_month}) ;;

  }

  dimension: historical_hour {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."COMPANY_HOUR" ;;

  }

  dimension: historical_day {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."COMPANY_DAY" ;;

  }

  dimension: historical_week {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."COMPANY_WEEK" ;;

  }

  dimension: historical_month {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."COMPANY_MONTH" ;;

  }

  dimension: company_agreed_upon_date_pricing {

    type: string
    sql: '$'||FLOOR(${historical_hour})||'/'||'$'||FLOOR(${historical_day})||'/'||'$'||FLOOR(${historical_week})||'/'||'$'||FLOOR(${historical_month}) ;;

  }

  dimension: current_hour {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."TIME_OF_RENTAL_PRICE_PER_HOUR" ;;

  }


  dimension: current_day {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."TIME_OF_RENTAL_PRICE_PER_DAY" ;;

  }


  dimension: current_week {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."TIME_OF_RENTAL_PRICE_PER_WEEK" ;;

  }


  dimension: current_month {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."TIME_OF_RENTAL_PRICE_PER_MONTH" ;;

  }

  dimension: billing_date_pricing{

    type: string
    sql: '$'||FLOOR(${current_hour})||'/'||'$'||FLOOR(${current_day})||'/'||'$'||FLOOR(${current_week})||'/'||'$'||FLOOR(${current_month}) ;;

  }

  dimension: deal_rate {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."DEAL_RATE" ;;


  }


  dimension: location_hour {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."LOCATION_PRICE_PER_HOUR" ;;

  }

  dimension: location_day{

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."LOCATION_PRICE_PER_DAY" ;;

  }

  dimension: location_week {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."LOCATION_PRICE_PER_WEEK" ;;

  }

  dimension: location_month {

    type: number
    value_format_name: usd_0
    sql: ${TABLE}."LOCATION_PRICE_PER_MONTH" ;;

  }

  dimension: location_actual_hour {

    type: number
    sql: ${TABLE}."LOCATION_RATE_HOUR" ;;
    value_format_name: usd_0
  }

  dimension: location_actual_day {

    type: number
    sql: ${TABLE}."LOCATION_RATE_DAY" ;;
    value_format_name: usd_0
  }

  dimension: location_actual_week {

    type: number
    sql: ${TABLE}."LOCATION_RATE_WEEK" ;;
    value_format_name: usd_0
  }

  dimension: location_actual_month {

    type: number
    sql: ${TABLE}."LOCATION_RATE_MONTH" ;;

  }

  dimension: location_rates {

    type: string
    sql: '$'||FLOOR(${location_actual_hour})||'/'||'$'||FLOOR(${location_actual_day})||'/'||'$'||FLOOR(${location_actual_week})||'/'||'$'||FLOOR(${location_actual_month})  ;;

  }

  dimension: location_agreed_upon_date_pricing {

    type: string
    sql: '$'||FLOOR(${location_hour})||'/'||'$'||FLOOR(${location_day})||'/'||'$'||FLOOR(${location_week})||'/'||'$'||FLOOR(${location_month})  ;;


  }

  dimension: original_price {

    type: number
    value_format_name: usd
    sql: ${TABLE}."ORIGINAL_PRICE" ;;

  }

  dimension: manual_adjustment_flag {

    type: yesno
    sql: ${TABLE}."MANUAL_ADJUSTMENT_FLAG" ;;

  }


  dimension: location_rate_flag {

    type: yesno
    sql: ${TABLE}."LOCATION_RATE_FLAG" ;;

  }


  dimension: current_rate_flag {

    type: yesno
    sql: ${TABLE}."CURRENT_RATE_FLAG" ;;

  }

  dimension: customer_rate_flag {

    type: yesno
    sql: ${TABLE}."CUSTOMER_RATE_FLAG" ;;

  }


  dimension: is_swap {
    type: yesno
    sql: ${TABLE}."IS_SWAP" ;;
  }
















}

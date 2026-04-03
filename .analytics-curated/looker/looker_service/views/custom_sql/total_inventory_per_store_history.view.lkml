view: total_inventory_per_store_history {
#UNDER CONSTRUCTION
  derived_table: {
    sql:with snap_values
    as (select distinct dateadd(day, -1, date_trunc(month, current_date()))::date as last_month_closed_stamp -- which will be last month closed
                      , DATEADD(month, -1, last_month_closed_stamp)               as thirty_day_stamp
                      , DATEADD(month, -2, last_month_closed_stamp)               as sixty_day_stamp
                      , DATEADD(month, -3, last_month_closed_stamp)               as ninety_day_stamp
                      , DATEADD(month, -4, last_month_closed_stamp)               as hundred_twenty_day_stamp
        from ANALYTICS.PUBLIC.INVENTORY_BALANCES_SNAPSHOT)

   , ltc_last_month_closed as (select ti.PART_ID, t.FROM_ID, max(t.DATE_COMPLETED::date) as last_consumed_date
                               from ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
                                        join ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
                                             on ti.TRANSACTION_ID = t.TRANSACTION_ID
                                        join ES_WAREHOUSE.INVENTORY.TRANSACTION_TYPES tt
                                             on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
                               where tt.TRANSACTION_TYPE_ID in (3, 7, 10, 13)
                                 and t.DATE_CANCELLED is null
                                 and t.from_id != 432
                                 and t.date_completed <= (select last_month_closed_stamp
                                                          from snap_values)
                               group by ti.PART_ID, t.FROM_ID)

   , last_month_closed as (select ibs.store_part_id
                                , ibs.PART_ID
                                , ibs.store_id
                                , ibs.TIMESTAMP::date                                                               as the_date
                                , ibs.quantity
                                , acs.AVG_COST
                                , ibs.quantity * acs.AVG_COST                                                       as total_snap_balance
                                , iff(datediff(month, ltc.last_consumed_date, the_date) > 12, total_snap_balance,
                                      0)                                                                            as dead_stock_balance
                           from ANALYTICS.PUBLIC.INVENTORY_BALANCES_SNAPSHOT ibs
                                    join snap_values sv
                                         on ibs.TIMESTAMP::date = sv.last_month_closed_stamp
                                    join analytics.PUBLIC.AVERAGE_COST_SNAPSHOT acs
                                         on ibs.PART_ID = acs.CURRENT_PART_ID
                                             and ibs.STORE_ID = acs.STORE_ID
                                             and last_day(ibs.TIMESTAMP, month) = acs.SNAPSHOT_DATE
                                    join ltc_last_month_closed ltc
                                         on ibs.part_id = ltc.PART_ID
                                             and ibs.STORE_ID = ltc.FROM_ID
                           where ibs.timestamp like '% 17:0%')

   , ltc_thirty_day as (select ti.PART_ID, t.FROM_ID, max(t.DATE_COMPLETED::date) as last_consumed_date
                        from ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
                                 join ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
                                      on ti.TRANSACTION_ID = t.TRANSACTION_ID
                                 join ES_WAREHOUSE.INVENTORY.TRANSACTION_TYPES tt
                                      on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
                        where tt.TRANSACTION_TYPE_ID in (3, 7, 10, 13)
                          and t.DATE_CANCELLED is null
                          and t.from_id != 432
                          and t.date_completed <= (select thirty_day_stamp
                                                   from snap_values)
                        group by ti.PART_ID, t.FROM_ID)

   , thirty_day as (select ibs.store_part_id
                         , ibs.PART_ID
                         , ibs.store_id
                         , ibs.TIMESTAMP::date                                                               as the_date
                         , ibs.quantity
                         , acs.AVG_COST
                         , ibs.quantity * acs.AVG_COST                                                       as total_snap_balance
                         , iff(datediff(month, ltc.last_consumed_date, the_date) > 12, total_snap_balance,
                               0)                                                                            as dead_stock_balance
                    from ANALYTICS.PUBLIC.INVENTORY_BALANCES_SNAPSHOT ibs
                             join snap_values sv1
                                  on ibs.TIMESTAMP::date = sv1.thirty_day_stamp
                             join analytics.PUBLIC.AVERAGE_COST_SNAPSHOT acs
                                  on ibs.PART_ID = acs.CURRENT_PART_ID
                                      and ibs.STORE_ID = acs.STORE_ID
                                      and last_day(ibs.TIMESTAMP, month) = acs.SNAPSHOT_DATE
                             join ltc_thirty_day ltc
                                  on ibs.part_id = ltc.PART_ID
                                      and ibs.STORE_ID = ltc.FROM_ID
                    where ibs.timestamp like '% 17:0%')

   , ltc_sixty_day as (select ti.PART_ID, t.FROM_ID, max(t.DATE_COMPLETED::date) as last_consumed_date
                       from ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
                                join ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
                                     on ti.TRANSACTION_ID = t.TRANSACTION_ID
                                join ES_WAREHOUSE.INVENTORY.TRANSACTION_TYPES tt
                                     on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
                       where tt.TRANSACTION_TYPE_ID in (3, 7, 10, 13)
                         and t.DATE_CANCELLED is null
                         and t.from_id != 432
                         and t.date_completed <= (select sixty_day_stamp
                                                  from snap_values)
                       group by ti.PART_ID, t.FROM_ID)

   , sixty_day as (select ibs.store_part_id
                        , ibs.PART_ID
                        , ibs.store_id
                        , ibs.TIMESTAMP::date                                                               as the_date
                        , ibs.quantity
                        , acs.AVG_COST
                        , ibs.quantity * acs.AVG_COST                                                       as total_snap_balance
                        , iff(datediff(month, ltc.last_consumed_date, the_date) > 12, total_snap_balance,
                              0)                                                                            as dead_stock_balance
                   from ANALYTICS.PUBLIC.INVENTORY_BALANCES_SNAPSHOT ibs
                            join snap_values sv2
                                 on ibs.TIMESTAMP::date = sv2.sixty_day_stamp
                            join analytics.PUBLIC.AVERAGE_COST_SNAPSHOT acs
                                 on ibs.PART_ID = acs.CURRENT_PART_ID
                                     and ibs.STORE_ID = acs.STORE_ID
                                     and last_day(ibs.TIMESTAMP, month) = acs.SNAPSHOT_DATE
                            join ltc_sixty_day ltc
                                 on ibs.part_id = ltc.PART_ID
                                     and ibs.STORE_ID = ltc.FROM_ID
                   where ibs.timestamp like '% 17:0%')

   , ltc_ninety_day as (select ti.PART_ID, t.FROM_ID, max(t.DATE_COMPLETED::date) as last_consumed_date
                        from ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
                                 join ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
                                      on ti.TRANSACTION_ID = t.TRANSACTION_ID
                                 join ES_WAREHOUSE.INVENTORY.TRANSACTION_TYPES tt
                                      on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
                        where tt.TRANSACTION_TYPE_ID in (3, 7, 10, 13)
                          and t.DATE_CANCELLED is null
                          and t.from_id != 432
                          and t.date_completed <= (select ninety_day_stamp
                                                   from snap_values)
                        group by ti.PART_ID, t.FROM_ID)

   , ninety_day as (select ibs.store_part_id
                         , ibs.PART_ID
                         , ibs.store_id
                         , ibs.TIMESTAMP::date                                                               as the_date
                         , ibs.quantity
                         , acs.AVG_COST
                         , ibs.quantity * acs.AVG_COST                                                       as total_snap_balance
                         , iff(datediff(month, ltc.last_consumed_date, the_date) > 12, total_snap_balance,
                               0)                                                                            as dead_stock_balance
                    from ANALYTICS.PUBLIC.INVENTORY_BALANCES_SNAPSHOT ibs
                             join snap_values sv3
                                  on ibs.TIMESTAMP::date = sv3.ninety_day_stamp
                             join analytics.PUBLIC.AVERAGE_COST_SNAPSHOT acs
                                  on ibs.PART_ID = acs.CURRENT_PART_ID
                                      and ibs.STORE_ID = acs.STORE_ID
                                      and last_day(ibs.TIMESTAMP, month) = acs.SNAPSHOT_DATE
                             join ltc_ninety_day ltc
                                  on ibs.part_id = ltc.PART_ID
                                      and ibs.STORE_ID = ltc.FROM_ID
                    where ibs.timestamp like '% 17:0%')

   , ltc_hundred_twenty_day as (select ti.PART_ID, t.FROM_ID, max(t.DATE_COMPLETED::date) as last_consumed_date
                                from ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
                                         join ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
                                              on ti.TRANSACTION_ID = t.TRANSACTION_ID
                                         join ES_WAREHOUSE.INVENTORY.TRANSACTION_TYPES tt
                                              on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
                                where tt.TRANSACTION_TYPE_ID in (3, 7, 10, 13)
                                  and t.DATE_CANCELLED is null
                                  and t.from_id != 432
                                  and t.date_completed <= (select hundred_twenty_day_stamp
                                                           from snap_values)
                                group by ti.PART_ID, t.FROM_ID)

   , hundred_twenty_day as (select ibs.store_part_id
                                 , ibs.PART_ID
                                 , ibs.store_id
                                 , ibs.TIMESTAMP::date                                                               as the_date
                                 , ibs.quantity
                                 , acs.AVG_COST
                                 , ibs.quantity * acs.AVG_COST                                                       as total_snap_balance
                                 , iff(datediff(month, ltc.last_consumed_date, the_date) > 12, total_snap_balance,
                                       0)                                                                            as dead_stock_balance
                            from ANALYTICS.PUBLIC.INVENTORY_BALANCES_SNAPSHOT ibs
                                     join snap_values sv4
                                          on ibs.TIMESTAMP::date = sv4.hundred_twenty_day_stamp
                                     join analytics.PUBLIC.AVERAGE_COST_SNAPSHOT acs
                                          on ibs.PART_ID = acs.CURRENT_PART_ID
                                              and ibs.STORE_ID = acs.STORE_ID
                                              and last_day(ibs.TIMESTAMP, month) = acs.SNAPSHOT_DATE
                                     join ltc_hundred_twenty_day ltc
                                          on ibs.part_id = ltc.PART_ID
                                              and ibs.STORE_ID = ltc.FROM_ID
                            where ibs.timestamp like '% 17:0%')

select *
from last_month_closed
union
select *
from thirty_day
union
select *
from sixty_day
union
select *
from ninety_day
union
select *
from hundred_twenty_day;;
  }

  dimension: key_field {
    primary_key: yes
    type: string
    sql: concat(cast(${TABLE}."STORE_PART_ID" as string)
              ,' '
              ,cast(${TABLE}."THE_DATE" as string)
              --,' '
              --,cast(${TABLE}."PART_ID" as string)
              --,' '
              --,cast(${TABLE}."STORE_ID" as string)
             )  ;;
  }

  dimension: store_part_id {
    type: number
    #primary_key: yes
    value_format_name: id
    sql: ${TABLE}."STORE_PART_ID" ;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: store_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."STORE_ID" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: avg_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}."AVG_COST" ;;
  }

  dimension: total_in_inventory {
    type: number
    value_format_name: usd
    sql: ${TABLE}."TOTAL_SNAP_BALANCE" ;;
  }

  dimension: dead_stock_dollars {
    type: number
    sql: ${TABLE}.dead_stock_balance ;;
  }

  dimension_group: snapshot_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."THE_DATE" ;;
  }


} # end of view

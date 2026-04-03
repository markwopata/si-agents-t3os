view: bad_transfers {
  derived_table: {
    sql:
      with penalized_markets as (select asset_id,
                                  oec,
                                  from_market_id,
                                  from_market_name,
                                  from_date_end,
                                  datediff(month, from_date_end, EQUIPMENT_CHARGE_DATE) + abt.FROM_AGE_AT_TRANSFER as months_open,
                                  coalesce(FROM_AGE_AT_TRANSFER,0) as from_age_at_transfer,
                                  coalesce('Asset ' || abt.ASSET_ID || ' transferred from ' || abt.FROM_MARKET_NAME ||
                                           ' to '
                                               || abt.to_market_name || ' prior to month 12 and has not rented',
                                           'bad transfer')    as reason,
                                  to_market_id,
                                  to_market_name,
                                  coalesce(TO_AGE_AT_TRANSFER,0) as to_age_at_transfer,
                                  EQUIPMENT_CHARGE_DATE,
                                  -round(EQUIPMENT_CHARGE, 2) as EQUIPMENT_CHARGE,
                                  pp.display,
                                  mrx.REGION_DISTRICT,
                                  mrx.REGION_NAME,
                                  mrx.market_type
                           from analytics.INTACCT_MODELS.INT_ASSET_BAD_TRANSFERS abt
                                    left join analytics.INTACCT_MODELS.STG_ANALYTICS_GS__PLEXI_PERIODS pp
                                              on date_trunc(month, EQUIPMENT_CHARGE_DATE) = pp.trunc
                                    join analytics.public.MARKET_REGION_XWALK mrx
                                         on abt.FROM_MARKET_ID = mrx.MARKET_ID),

-- Now identify markets that will benefit from this
     beneficiary_markets as (select asset_id,
                                    oec,
                                    abt.to_market_id           as from_market_id,
                                    abt.to_market_name         as from_market_name,
                                    from_date_end,
                                    datediff(month, from_date_end, EQUIPMENT_CHARGE_DATE) + abt.TO_AGE_AT_TRANSFER as months_open,
                                    coalesce(abt.TO_AGE_AT_TRANSFER,0)    as from_age_at_transfer,
                                    coalesce('Asset ' || abt.ASSET_ID || ' transferred from ' || abt.FROM_MARKET_NAME ||
                                             ' to '
                                                 || abt.to_market_name || ' prior to month 12 and has not rented',
                                             'bad transfer')   as reason,
                                    abt.FROM_MARKET_ID         as to_market_id,
                                    abt.FROM_MARKET_NAME       as to_market_name,
                                    coalesce(abt.FROM_AGE_AT_TRANSFER,0)   as to_age_at_transfer,
                                    EQUIPMENT_CHARGE_DATE,
                                    round(EQUIPMENT_CHARGE, 2) as EQUIPMENT_CHARGE,
                                    pp.display,
                                    mrx.REGION_DISTRICT,
                                    mrx.REGION_NAME,
                                    mrx.market_type
                             from analytics.INTACCT_MODELS.INT_ASSET_BAD_TRANSFERS abt
                                      left join analytics.INTACCT_MODELS.STG_ANALYTICS_GS__PLEXI_PERIODS pp
                                                on date_trunc(month, EQUIPMENT_CHARGE_DATE) = pp.trunc
                                      join analytics.public.MARKET_REGION_XWALK mrx
                                           on abt.to_market_id = mrx.MARKET_ID)

select *, month(EQUIPMENT_CHARGE_DATE) as mth, year(EQUIPMENT_CHARGE_DATE) as year
from penalized_markets pm
where equipment_charge is not null
  and abs(equipment_charge) > 0
union all
select *, month(EQUIPMENT_CHARGE_DATE) as mth, year(EQUIPMENT_CHARGE_DATE) as year
from beneficiary_markets bm
where EQUIPMENT_CHARGE is not null
  and abs(equipment_charge) > 0




      ;;
  } dimension: asset_id {
    label: "Asset ID"
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }


  measure: OEC {
    label: "OEC"
    type: sum
    sql: ${TABLE}."OEC" ;;
    value_format_name: usd
  }

  dimension: from_market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."FROM_MARKET_ID" ;;
  }
  dimension: from_market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."FROM_MARKET_NAME" ;;
  }
  dimension: to_market_id {
    label: "Receiving Market ID"
    type: string
    sql: ${TABLE}."TO_MARKET_ID" ;;
  }
  dimension: to_market_name {
    label: "Receiving Market Name"
    type: string
    sql: ${TABLE}."TO_MARKET_NAME" ;;
  }
  dimension: equipment_charge_date {
    label: "Month"
    type: date
    sql: ${TABLE}."EQUIPMENT_CHARGE_DATE" ;;
  }
  measure: equipment_charge {
    label: "Equipment Charge"
    type: sum
    sql: ${TABLE}."EQUIPMENT_CHARGE" ;;
    value_format_name: usd
  }
  dimension: period {
    label: "Period"
    type: string
    sql: ${TABLE}."DISPLAY" ;;
  }
  dimension: region {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  dimension: district {
    label: "District"
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }
  dimension: market_type {
    label: "Market Type"
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }
  dimension: reason {
    label: "Reason"
    type: string
    sql: ${TABLE}."REASON" ;;
  }
  dimension: months_open {
    type: number
    sql: ${TABLE}."MONTHS_OPEN" ;;
  }
  dimension: months_open_greater_than_twelve {
    label: "Markets Greater Than 12 Months Open?"
    type: yesno
    sql: ${TABLE}."MONTHS_OPEN" > 12;;
  }

}

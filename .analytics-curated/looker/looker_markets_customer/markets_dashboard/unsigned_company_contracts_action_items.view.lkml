view: unsigned_company_contracts_action_items {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    # indexes: ["market_id","company_id"]
    sql:
    /*with company_orders_cte AS (SELECT o.market_id
                                 , xw.market_name
                                 , xw.district
                                 , xw.region_name
                                 , cc.date_signed::date AS date_signed
                                 , c.company_id
                                 , nt.NAME as net_terms
                                 , c.name
                                 , o.order_id
                                 , r.rental_id
                                 , r.asset_id
                                 , r.end_date::date     as end_date
                            FROM ES_WAREHOUSE.public.orders o
                                     LEFT JOIN ES_WAREHOUSE.public.contracts cc
                                               ON o.order_id = cc.order_id
                                     LEFT JOIN analytics.public.market_region_xwalk xw
                                               ON o.market_id = xw.market_id
                                     LEFT JOIN es_warehouse.public.users u
                                               ON o.user_id = u.user_id
                                     LEFT JOIN es_warehouse.public.companies c
                                               ON u.company_id = c.company_id
                                     LEFT JOIN ES_WAREHOUSE.PUBLIC.NET_TERMS nt
                                               on c.NET_TERMS_ID = nt.NET_TERMS_ID
                                     LEFT JOIN es_warehouse.public.rentals r
                                               ON o.order_id = r.order_id
                                     LEFT JOIN es_warehouse.public.assets a
                                               ON r.asset_id = a.asset_id
                                     LEFT JOIN es_warehouse.public.equipment_classes_models_xref x
                                               ON a.equipment_model_id = x.equipment_model_id
                                     JOIN rolling_classes rc
                                          ON x.equipment_class_id = rc.equipment_class_id),
     most_recent_contract AS
         (SELECT max(date_signed) as most_recent_signed_contract,
                 company_id
          FROM company_orders_cte
          GROUP BY company_id)
SELECT mrc.most_recent_signed_contract, coc.*
FROM company_orders_cte coc
         JOIN most_recent_contract mrc
              ON coc.company_id = mrc.company_id
WHERE coalesce(date_signed, '1970-01-01')::date < '2020-05-08'::date
  AND coalesce(coc.end_date, '2099-12-31')::date >= current_date*/

  WITH most_recent_contract AS -- Latest signed contract per company
     (SELECT max(date_signed) as most_recent_signed_contract,
             company_id
      FROM es_warehouse.public.company_contracts
      GROUP BY company_id
      )

    SELECT
      cc.company_contract_id,
      cc.company_id,
      c.name as company_name,
      nt.NAME as net_terms,
      cc.created_date,
      cc.status_id,
      cc.date_signed,
      o.market_id,
      xw.market_name,
      xw.district,
      xw.region_name,
      xw.market_type,
      o.order_id, -- order with most recent rental id with on rent asset for company/market combo for companies with unsigned contract
      o.rental_id, -- most recent rental id of company/market pair with on rent asset for companies with unsigned contract
      o.date_created as rental_date_created,
      mrc.most_recent_signed_contract
    FROM es_warehouse.public.company_contracts AS cc

    JOIN (                        -- Find each comapny/market pair with assets on rent, and each pairs oldest rental
      SELECT o.company_id, o.market_id, o.order_id, r.rental_id, r.date_created
            from es_warehouse.public.orders o
            JOIN es_warehouse.public.rentals r on r.order_id = o.order_id
            where r.rental_status_id = 5 and coalesce(r.end_date, '2099-12-31')::date > current_date
            QUALIFY ROW_NUMBER() OVER(PARTITION BY o.company_id, o.market_id ORDER BY r.date_created DESC) = 1
            ) o on o.company_id = cc.company_id
    LEFT JOIN analytics.public.market_region_xwalk xw on xw.market_id = o.market_id
    JOIN most_recent_contract mrc ON mrc.company_id = cc.company_id
    JOIN es_warehouse.public.companies co on co.company_id = cc.company_id
    LEFT JOIN es_warehouse.public.companies c on c.company_id = cc.company_id
    LEFT JOIN ES_WAREHOUSE.PUBLIC.NET_TERMS nt on c.NET_TERMS_ID = nt.NET_TERMS_ID
    WHERE   (cc.date_signed IS NULL OR cc.status_id = 'voided') AND
            (mrc.most_recent_signed_contract IS NULL OR mrc.most_recent_signed_contract <= current_timestamp) AND

            NOT EXISTS (              -- Checking to make sure there is not a newer signed contract with envelope id
                SELECT 1
                FROM es_warehouse.public.company_contracts AS cc2
                WHERE cc2.company_id   = cc.company_id
                  AND cc2.created_date > cc.created_date
                  AND COALESCE(cc2.envelope_id, '') <> ''
            )
                 and (co.has_msa = FALSE or co.has_msa is null)

            ;;
  }
  #May 8, 2020 is hardcoded due to that was the date legal changed the contracts. Anything signed before then is basically useless

  # From Sept 5th,2025 on theres new logic that increased total number of unsigned contracts.  Removing out of date tie to "rolling classes"

  # Define your dimensions and measures here, like this:
  dimension: most_recent_signed_contract {
    type: date
    sql: ${TABLE}."MOST_RECENT_SIGNED_CONTRACT" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: date_signed {
    type: time
    timeframes: [date]
    sql: ${TABLE}."DATE_SIGNED" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: company_contract_id {
    type: string
    sql: ${TABLE}."COMPANY_CONTRACT_ID" ;;
  }

  dimension: primary_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: concat(${company_contract_id}, ${company_id}, ${market_id}, ${order_id}) ;;
  }

  dimension_group: created_date {
    type: time
    label: "Contract Created"
    timeframes: [date]
    sql: ${TABLE}."CREATED_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: rental_date_created {
    type: time
    label: "Rental Created"
    timeframes: [date]
    sql: ${TABLE}."RENTAL_DATE_CREATED" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: status_id {
    label: "Contract Status"
    type: string
    sql: ${TABLE}."STATUS_ID" ;;
    html:
    {% if value == 'voided' %}
    {{ rendered_value | capitalize }} <br />
    <font color="#0063f3 "><a href="https://admin.equipmentshare.com/#/home/companies/{{company_id._filterable_value | url_encode}}/settings"target="_blank">  Resend Contract ➔ </a></font>
    {% else %}
      {{ rendered_value | capitalize }}
    {% endif %} ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY_NAME";;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{filterable_value | url_encode}}&Company+ID="target="_blank"> {{rendered_value}}  ➔ </a></font>
    ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{filterable_value | url_encode}}&Company+ID="target="_blank"> {{rendered_value}}  ➔ </a></font>
    <td>
    <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>

     <br />
    <span style="color: #8C8C8C;"> Net Terms: {{net_terms._value}} </span>
    </td>
    ;;
  }

  dimension: market_id {
    group_label: "Location Information"
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market {
    group_label: "Location Information"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }


  dimension: district {
    group_label: "Location Information"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    group_label: "Location Information"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: market_type {
    group_label: "Location Information"
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: net_terms {
    type: string
    sql: ${TABLE}."NET_TERMS" ;;
  }

  dimension: rental_id {
    label: "Most Recent Rental ID With Current AOR"
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: order_id {
    label: "Most Recent Order ID With Current AOR"
    type: number
    sql: ${TABLE}."ORDER_ID";;
    html: <font color="#0063f3"><u><a href="https://admin.equipmentshare.com/#/home/orders/{{ order_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }


  #dimension_group: rental_end {
  #  type: time
  #  timeframes: [date]
  #  sql: ${TABLE}."END_DATE" ;;
  #  html: {{ rendered_value | date: "%b %d, %Y" }};;
  #}

  measure: unsigned_company_contracts {
    type: count_distinct
    sql: ${company_id} ;;
    drill_fields: [unsigned_contracts_details*]
  }

  measure: unsigned_company_contracts_net_terms {
    type: count_distinct
    label: "Unsigned Company Contracts on Net Terms"
    sql: ${company_id};;
    filters: [net_terms: "Net%"]
    drill_fields: [unsigned_contracts_details*]
  }

  measure: unsigned_company_contracts_COD {
    type: count_distinct
    label: "Unsigned Company Contracts on COD"
    sql: ${company_id} ;;
    filters: [net_terms: "Cash on Delivery"]
    drill_fields: [unsigned_contracts_details*]
  }

  set: unsigned_contracts_details {
    fields: [company, company_id, net_terms, created_date_date, status_id, market, order_id, rental_id, rental_date_created_date]
  }


}

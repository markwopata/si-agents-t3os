view: links {
  derived_table: {
    sql:
      SELECT distinct
          market_id,
          market_name,
          region_name as region,
          district as district,
          market_type
      FROM analytics.public.market_region_xwalk mrx
      WHERE {% condition region_name_filter_mapping %} mrx.region_name {% endcondition %}
        and {% condition district_filter_mapping %} mrx.district {% endcondition %}
        and {% condition market_name_filter_mapping %} mrx.market_name {% endcondition %}
        and {% condition market_type_filter_mapping %} mrx.market_type {% endcondition %}
      ;;
  }

  filter: region_name_filter_mapping {
    type: string
  }

  filter: district_filter_mapping {
    type: string
  }

  filter: market_name_filter_mapping {
    type: string
  }

  filter: market_type_filter_mapping {
    type: string
  }

  filter: greater_twelve_months_open_filter_mapping {
    type: string
  }

  filter: period_filter_mapping {
    type: string
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
    primary_key: yes
  }

  dimension: market {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}.market_type ;;
  }

  dimension: pl_detail_link {
    type: string
    sql: 'P&L Detail' ;;
    html:
      <a
        style="color:rgb(26, 115, 232)"
        href="@{lk_be_pl_detail__links_filters}"
        target="_blank"
        rel="noopener noreferrer">
        {{value}}
      </a>
      ;;
  }

  dimension: how_do_i_improve_link {
    type: string
    sql: 'How do I improve?' ;;
    html:
      <a
        style="color:rgb(26, 115, 232)"
        href="@{db_how_do_i_improve}?Period={{ _filters['plexi_periods.display'] | url_encode }}&amp;Market+Name={{ _filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;Region+District={{ _filters['market_region_xwalk.region_district'] | url_encode }}&amp;Markets+Greater+Than+12+Months+Open?={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&amp;toggle=det"
        target="_blank"
        rel="noopener noreferrer">
        {{value}}
      </a>
      ;;
  }

  dimension: branch_comparison_link {
    type: string
    sql: 'Branch Comparison' ;;
    html:
      <a
        style="color:rgb(26, 115, 232)"
        href="@{db_branch_comparison}?Market+Name={{ _filters['market_region_xwalk.market_name'] | url_encode }}&amp;toggle=det"
        target="_blank"
        rel="noopener noreferrer">
        {{value}}
      </a>
      ;;
  }

  dimension: ap_accrual_link {
    type: string
    sql: 'AP Accrual Detail' ;;
    html:
      <a
        style="color:rgb(26, 115, 232)"
        href="@{db_ap_accruals}?&amp;Market+Name={{ _filters['market_region_xwalk.market_name'] | url_encode }}&amp;Period={{ _filters['plexi_periods.display'] | url_encode }}&amp;District+Number={{ _filters['market_region_xwalk.region_district'] | url_encode }}&amp;Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&amp;Markets+Greater+Than+12+Months+Open?={{ _filters['revmodel_market_rollout_conservative.greater_twelve_months_open'] | url_encode }}&amp;Market+Type={{ _filters['market_region_xwalk.market_type'] | url_encode }}&amp;toggle=det"
        target="_blank"
        rel="noopener noreferrer">
        {{value}}
      </a>
      ;;
  }

  dimension: unassigned_tech_hours_link {
    type: string
    sql: 'Unassigned Tech Hours Detail' ;;
    html:
      <a
        style="color:rgb(26, 115, 232)"
        href="@{db_unassigned_tech_hours_detail}?Period={{ _filters['plexi_periods.display'] | url_encode }}&amp;Market+Name={{ _filters['market_region_xwalk.market_name'] | url_encode }}&amp;Region+District={{ _filters['market_region_xwalk.region_district'] | url_encode }}&amp;toggle=det"
        target="_blank"
        rel="noopener noreferrer">
        {{value}}
      </a>
      ;;
  }

  measure: quick_links {
    group_label: "Quick Links Card"
    label: " " # Space so that the column doesn't have a heading
    type: sum
    sql: 1 ;;

    html:
      {% assign s_table = "font-family: Verdana, Arial, sans-serif; color:#323232; width:100%; max-width:100%; border-collapse:collapse; table-layout: fixed; font-size:12px; text-align:left !important; word-break: normal !important; overflow-wrap: break-word !important; white-space: normal !important;" %}
      {% assign s_cell = "padding: 0; vertical-align: middle;" %}
      {% assign s_link = "display:block; width:100%; box-sizing:border-box; padding: 2px 3px;" %}
      {% assign s_arrow = "float:right; font-size: 14px; padding: 0 2px;" %}
      {% assign s_text = "display:block; padding-right: 22px;" %}
      {% assign s_subtitle = "font-size: 10px; color:rgb(126, 126, 126); text-decoration:none;" %}
      {% assign s_hr = "border:0; border-top:1px solid #DCDCDC; margin:0;" %}

      {% assign f_market_name = _filters['links.market_name_filter_mapping'] | default: '' | url_encode %}
      {% assign f_period = _filters['links.period_filter_mapping'] | default: '' | url_encode %}
      {% assign f_region_name = _filters['links.region_name_filter_mapping'] | default: '' | url_encode %}
      {% assign f_region_district = _filters['links.district_filter_mapping'] | default: '' | url_encode %}
      {% assign f_gt_12 = _filters['links.greater_twelve_months_open_filter_mapping'] | default: '' | url_encode %}
      {% assign f_market_type = _filters['links.market_type_filter_mapping'] | default: '' | url_encode %}

      <table role="presentation" style="{{ s_table }}">
        <tr>
          <td colspan="2" style="font-size: 14px; font-weight: 600; padding: 0 0 4px 0;">Quick Links</td>
        </tr>

        <tr>
          <td colspan="2" style="{{ s_cell }}">
            <a
              href="@{lk_be_pl_detail}?f[market_region_xwalk.market_name]={{ f_market_name }}&amp;f[plexi_periods.display]={{ f_period }}&amp;f[market_region_xwalk.region_name]={{ f_region_name }}&amp;f[market_region_xwalk.region_district]={{ f_region_district }}&amp;f[revmodel_market_rollout_conservative.greater_twelve_months_open]={{ f_gt_12 }}&amp;f[market_region_xwalk.market_type]={{ f_market_type }}&amp;toggle=det"
              target="_blank"
              rel="noopener noreferrer"
              style="{{ s_link }}">
              <span style="{{ s_arrow }}">➔</span>
              <span style="{{ s_text }}">Traditional P&amp;L View</span>
            </a>
          </td>
        </tr>
        <tr><td colspan="2"><hr style="{{ s_hr }}"></td></tr>

        <tr>
          <td colspan="2" style="{{ s_cell }}">
            <a
              href="@{lk_be_trailing_12_months_view}?f[market_region_xwalk.market_name]={{ f_market_name }}&amp;f[plexi_periods.display]={{ f_period }}&amp;f[market_region_xwalk.region_name]={{ f_region_name }}&amp;f[market_region_xwalk.region_district]={{ f_region_district }}&amp;f[revmodel_market_rollout_conservative.greater_twelve_months_open]={{ f_gt_12 }}&amp;f[market_region_xwalk.market_type]={{ f_market_type }}&amp;toggle=det"
              target="_blank"
              rel="noopener noreferrer"
              style="{{ s_link }}">
              <span style="{{ s_arrow }}">➔</span>
              <span style="{{ s_text }}">
                Trailing 12 Months View
                <span style="{{ s_subtitle }}"> TTM P&amp;L</span>
              </span>
            </a>
          </td>
        </tr>
        <tr><td colspan="2"><hr style="{{ s_hr }}"></td></tr>

        <tr>
          <td colspan="2" style="{{ s_cell }}">
            <a
              href="@{db_trending_branch_earnings}?Market+Name={{ f_market_name }}&amp;Region+Name={{ f_region_name }}&amp;District={{ f_region_district }}&amp;Market+Greater+Than+12+Months+%28Yes+%2F+No%29={{ f_gt_12 }}&amp;Market+Type={{ f_market_type }}&amp;toggle=det"
              target="_blank"
              rel="noopener noreferrer"
              style="{{ s_link }}">
              <span style="{{ s_arrow }}">➔</span>
              <span style="{{ s_text }}">Trending Branch Earnings</span>
            </a>
          </td>
        </tr>
        <tr><td colspan="2"><hr style="{{ s_hr }}"></td></tr>

        <tr>
          <td colspan="2" style="{{ s_cell }}">
            <a
              href="@{db_how_do_i_improve}?Period={{ f_period }}&amp;Market+Name={{ f_market_name }}&amp;Region+Name={{ f_region_name }}&amp;Region+District={{ f_region_district }}&amp;Markets+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29={{ f_gt_12 }}&amp;Market+Type={{ f_market_type }}&amp;toggle=det"
              target="_blank"
              rel="noopener noreferrer"
              style="{{ s_link }}">
              <span style="{{ s_arrow }}">➔</span>
              <span style="{{ s_text }}">
                How do I improve?
                <span style="{{ s_subtitle }}"> Suggestions to Improve Profitability</span>
              </span>
            </a>
          </td>
        </tr>
        <tr><td colspan="2"><hr style="{{ s_hr }}"></td></tr>

        <tr>
          <td colspan="2" style="{{ s_cell }}">
            <a
              href="@{db_unassigned_tech_hours_detail}?Period={{ f_period }}&amp;Market+Name={{ f_market_name }}&amp;District={{ f_region_district }}&amp;Region={{ f_region_name }}&amp;Market+Type={{ f_market_type }}&amp;Markets+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29={{ f_gt_12 }}&amp;toggle=det"
              target="_blank"
              rel="noopener noreferrer"
              style="{{ s_link }}">
              <span style="{{ s_arrow }}">➔</span>
              <span style="{{ s_text }}">Unassigned Tech Hours Detail</span>
            </a>
          </td>
        </tr>
        <tr><td colspan="2"><hr style="{{ s_hr }}"></td></tr>

        <tr>
          <td colspan="2" style="{{ s_cell }}">
            <a
              href="@{db_oec_detail}?Period={{ f_period }}&amp;Market+Name={{ f_market_name }}&amp;District+Number={{ f_region_district }}&amp;Region+Name={{ f_region_name }}&amp;Market+Type={{ f_market_type }}&amp;Markets+Greater+Than+12+Months+Open%3F+%28Yes+%2F+No%29={{ f_gt_12 }}&amp;toggle=det"
              target="_blank"
              rel="noopener noreferrer"
              style="{{ s_link }}">
              <span style="{{ s_arrow }}">➔</span>
              <span style="{{ s_text }}">OEC Detail</span>
            </a>
          </td>
        </tr>
        <tr><td colspan="2"><hr style="{{ s_hr }}"></td></tr>

        <tr>
          <td colspan="2" style="{{ s_cell }}">
            <a
              href="@{db_market_dashboard}?Market={{ f_market_name }}&amp;District={{ f_region_district }}&amp;Region={{ f_region_name }}&amp;Market+Type={{ f_market_type }}&amp;Months+Open+Over+12+%28Yes+%2F+No%29={{ f_gt_12 }}&amp;toggle=det"
              target="_blank"
              rel="noopener noreferrer"
              style="{{ s_link }}">
              <span style="{{ s_arrow }}">➔</span>
              <span style="{{ s_text }}">Market Dashboard</span>
            </a>
          </td>
        </tr>
        <tr><td colspan="2"><hr style="{{ s_hr }}"></td></tr>

        <tr>
          <td colspan="2" style="{{ s_cell }}">
            <a
              href="@{link_es_ops_branch_earnings}"
              target="_blank"
              rel="noopener noreferrer"
              style="{{ s_link }}">
              <span style="{{ s_arrow }}">➔</span>
              <span style="{{ s_text }}">ES Ops Branch Earnings Reference + FAQ</span>
            </a>
          </td>
        </tr>
        
      </table>
      ;;
  }
}

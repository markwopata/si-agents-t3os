view: aod_asset_sparklines {
  derived_table: {
    sql: SELECT
    asset_id as asset_id_num,
    asset_year_make_model,
    company_id,
    company_name,
    market_name,
    make,
    model,
    spn,
    spn_name,
    prob_grey_30,
    prob_red_30,
    prob_amber_30,
    prob_green_30,
    avg_value_30,
    ref_avg_value_30,
    PROB_GREY_14,
    PROB_RED_14,
    PROB_AMBER_14,
    PROB_GREEN_14,
    AVG_VALUE_14,
    REF_AVG_VALUE_14,
    open_work_orders,
    usage_percentage_remaining,
    Service_interval_name,
    USAGE_PERCENTAGE_REMAINING_COLOR,
    DATA_SCIENCE_WORK_ORDER,
    LINK_T3,
    LINK_DRILLDOWN,
    RANKING_BY_SPN_PROB_14,
    avg_value_min_14,
    floor(least(avg_value_min_30, ref_avg_value_min_30, 9999) * 0.98) as lower_bound_30,
    ceil(greatest(avg_value_max_30, ref_avg_value_max_30, -9999) * 1.02) as upper_bound_30,
    floor(least(avg_value_min_14, ref_avg_value_min_14, 9999) * 0.98) as lower_bound_14,
    ceil(greatest(avg_value_max_14, ref_avg_value_max_14, -9999) * 1.02) as upper_bound_14,
    get(HTML_COLORS, 16)::string as HTML1,
    get(HTML_COLORS, 17)::string as HTML2,
    get(HTML_COLORS, 18)::string as HTML3,
    get(HTML_COLORS, 19)::string as HTML4,
    get(HTML_COLORS, 20)::string as HTML5,
    get(HTML_COLORS, 21)::string as HTML6,
    get(HTML_COLORS, 22)::string as HTML7,
    get(HTML_COLORS, 23)::string as HTML8,
    get(HTML_COLORS, 24)::string as HTML9,
    get(HTML_COLORS, 25)::string as HTML10,
    get(HTML_COLORS, 26)::string as HTML11,
    get(HTML_COLORS, 27)::string as HTML12,
    get(HTML_COLORS, 28)::string as HTML13,
    get(HTML_COLORS, 29)::string as HTML14
    from aod_aggregated
    where avg_value_min_30 is not null
    ;;
  }
  dimension: asset_id_num {hidden: no}
  dimension: company_id {hidden: no}
  dimension: company_name {hidden: no}
  dimension: market_name {hidden: no}
  dimension: make {hidden: no}
  dimension: model {hidden: no}
  dimension: RANKING_BY_SPN_PROB_14 {hidden: no type: number}
  dimension: SPN {hidden: no type: number}
  dimension: avg_value_min_14 {hidden: no type: number}

  dimension: ASSET_YEAR_MAKE_MODEL {hidden: yes}
  dimension: LINK_T3 {hidden: yes}
  dimension: asset_id {
    type:  string
    sql: 1;;
    html: <p style ="color:#0000FF"><u><a href="{{LINK_T3}}" target="_blank">{{ASSET_YEAR_MAKE_MODEL}}</a></u></p>;;
  }

  dimension: LINK_DRILLDOWN {hidden: yes}
  dimension: PROB_GREY_14 {hidden: yes}
  dimension: PROB_RED_14 {hidden: yes}
  dimension: PROB_AMBER_14 {hidden: yes}
  dimension: PROB_GREEN_14 {hidden: yes}
  dimension: HTML1 {hidden: yes}
  dimension: HTML2 {hidden: yes}
  dimension: HTML3 {hidden: yes}
  dimension: HTML4 {hidden: yes}
  dimension: HTML5 {hidden: yes}
  dimension: HTML6 {hidden: yes}
  dimension: HTML7 {hidden: yes}
  dimension: HTML8 {hidden: yes}
  dimension: HTML9 {hidden: yes}
  dimension: HTML10 {hidden: yes}
  dimension: HTML11 {hidden: yes}
  dimension: HTML12 {hidden: yes}
  dimension: HTML13 {hidden: yes}
  dimension: HTML14 {hidden: yes}
  dimension: abnormal_probabilities_last_14_days_old{
    sql: 1;;
    html: <a href="{{LINK_DRILLDOWN}}" target="_blank"><img height="30" width="200" src="https://quickchart.io/chart?chs=200x30&cht=bvs&chd=a:{{PROB_GREY_14._value}}|{{PROB_RED_14._value}}|{{PROB_AMBER_14._value}}|{{PROB_GREEN_14._value}}&chco=aaaaaa,aa2222,aaaa22,c"></a>;;
  }
  dimension: abnormal_probabilities_last_14_days{
    sql: 1;;
    html: <a href="{{LINK_DRILLDOWN}}" target="_blank">
    <span height="50">
      <span height="50" width="10" style="background-color:{{HTML1}};font-size:20px;">&nbsp&nbsp</span>
      <span height="50" width="10" style="background-color:{{HTML2}};font-size:20px;">&nbsp&nbsp</span>
      <span height="50" width="10" style="background-color:{{HTML3}};font-size:20px;">&nbsp&nbsp</span>
      <span height="50" width="10" style="background-color:{{HTML4}};font-size:20px;">&nbsp&nbsp</span>
      <span height="50" width="10" style="background-color:{{HTML5}};font-size:20px;">&nbsp&nbsp</span>
      <span height="50" width="10" style="background-color:{{HTML6}};font-size:20px;">&nbsp&nbsp</span>
      <span height="50" width="10" style="background-color:{{HTML7}};font-size:20px;">&nbsp&nbsp</span>
      <span height="50" width="10" style="background-color:{{HTML8}};font-size:20px;">&nbsp&nbsp</span>
      <span height="50" width="10" style="background-color:{{HTML9}};font-size:20px;">&nbsp&nbsp</span>
      <span height="50" width="10" style="background-color:{{HTML10}};font-size:20px;">&nbsp&nbsp</span>
      <span height="50" width="10" style="background-color:{{HTML11}};font-size:20px;">&nbsp&nbsp</span>
      <span height="50" width="10" style="background-color:{{HTML12}};font-size:20px;">&nbsp&nbsp</span>
      <span height="50" width="10" style="background-color:{{HTML13}};font-size:20px;">&nbsp&nbsp</span>
      <span height="50" width="10" style="background-color:{{HTML14}};font-size:20px;">&nbsp&nbsp</span>


    </span></a>;;
    }


  dimension: lower_bound_14 {hidden: yes type: number}
  dimension: upper_bound_14 {hidden: yes type: number}
  dimension: REF_AVG_VALUE_14 {hidden: yes}
  dimension: AVG_VALUE_14 {hidden: yes}
  dimension: engine_data_last_14_days{
    sql: 1;;
    html: <a href="{{LINK_DRILLDOWN}}" target="_blank"><img height="50" width="400" src="https://quickchart.io/chart?w=400&h=50&c={type:%27line%27,options:{scales:{yAxes:[{ticks:{min:{{lower_bound_14._value}},max:{{upper_bound_14._value}},maxTicksLimit:2},gridLines:{display:false}}],xAxes:[{gridLines:{display:false}}]},plugins:{legend:false}},data:{labels:[%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27],datasets:[{data:[{{AVG_VALUE_14._value}}],fill:false,backgroundColor:%27%2388222277%27,borderColor:%27%2388222277%27},{data:[{{REF_AVG_VALUE_14._value}}],fill:false,backgroundColor:%27%2322228877%27,borderColor:%27%2322228877%27}]}}"></a>;;
  }



  dimension: USAGE_PERCENTAGE_REMAINING_COLOR {hidden: yes}
  dimension: usage_percentage_remaining {hidden: yes type: number}
  dimension: Service_interval_name {hidden: yes}
  dimension: open_work_orders {hidden: yes type: number}
  dimension: DATA_SCIENCE_WORK_ORDER {hidden: yes}
  dimension: service_percent_remaining {
    sql: 1;;
    html: <p style="text-align:left;color:{{USAGE_PERCENTAGE_REMAINING_COLOR}}">{{usage_percentage_remaining}}% - {{Service_interval_name}} ({{open_work_orders}} open work orders)
    <a href = "https://app.estrack.com/#/home/service/work-orders/{{DATA_SCIENCE_WORK_ORDER}}">{{DATA_SCIENCE_WORK_ORDER}}</a></p>
    <div style="float: left
    ; width:{{usage_percentage_remaining}}%
    ; background-color: {{USAGE_PERCENTAGE_REMAINING_COLOR}}
    ; text-align:left
    ; color: #FFFFFF
    ; border-radius: 5px"> <p style="margin-bottom: 0; margin-left: 4px;">&nbsp;</p></div>;;
  }

  dimension: PROB_GREY_30 {hidden: yes}
  dimension: PROB_RED_30 {hidden: yes}
  dimension: PROB_AMBER_30 {hidden: yes}
  dimension: PROB_GREEN_30 {hidden: yes}
  dimension: lower_bound_30 {hidden: yes type: number}
  dimension: upper_bound_30 {hidden: yes type: number}
  dimension: REF_AVG_VALUE_30 {hidden: yes}
  dimension: AVG_VALUE_30 {hidden: yes}
  dimension: spn_name {hidden: yes}
  dimension: DRILLDOWN_BLOCK {
    sql:  1;;
    html: <div height="500" style="border: thin solid black"><p style="font-size:30px">{{spn_name}}</p><br>
    <img height="100" width="800" src="https://quickchart.io/chart?w=800&h=100&c={type:%27line%27,options:{scales:{yAxes:[{ticks:{min:{{lower_bound_30._value}},max:{{upper_bound_30._value}},maxTicksLimit:2},gridLines:{display:false}}],xAxes:[{gridLines:{display:false}}]},plugins:{legend:false}},data:{labels:[%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27],datasets:[{data:[{{AVG_VALUE_14._value}}],fill:false,backgroundColor:%27%2388222277%27,borderColor:%27%2388222277%27},{data:[{{REF_AVG_VALUE_14._value}}],fill:false,backgroundColor:%27%2322228877%27,borderColor:%27%2322228877%27}]}}">
    <br>
    <img height="50" width="800" src="https://quickchart.io/chart?chs=800x50&cht=bvs&chd=a:{{PROB_GREY_30._value}}|{{PROB_RED_30._value}}|{{PROB_AMBER_30._value}}|{{PROB_GREEN_30._value}}&chco=aaaaaa,aa2222,aaaa22,22aa22">
</div>
<div height="50">&nbsp</div>

    ;;

  }


}

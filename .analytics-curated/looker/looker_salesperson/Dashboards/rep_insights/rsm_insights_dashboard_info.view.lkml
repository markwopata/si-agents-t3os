view: rsm_insights_dashboard_info {
  derived_table: {
    sql: SELECT 1 as filler ;;
  }

  measure: dashboard_info_icon {
    type: sum
    sql: 0 ;;
    drill_fields: [dashboard_info]
    html:
    <a href="#drillmenu" target="_self">
    <font size="4">
    Understanding the Dashboard Metrics
    </font>
    <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/60d0867d1398775f9a3669b2_logo-256x256.png" style="width 24px; height: 24px;">
    </a>
    ;;
  }

  measure: dashboard_info {
    type: string
    sql: DISTINCT ' ' ;;
    html:
    <div style= "
    display: border-box;
    vertical-align: top;
    border: 1px solid #D6D6D6;
    height: 50vh;
    width: 98%;
    border_radius: 4px;
    background-color: #F4F4F4;
    text-align: left;
    font-size: 18px;
    font-family: PT Sans;
    margin: 20px auto;
    padding: 10px;
    box-shadown: rgba(0, 0, 0, 0.35) 0px 5px 15px;
    overflow: auto;
    ">
    <div style="font-weight: 600">Previous Month Rental Revenue Under 125K:</div>
    <ul style="">
      <li>Generate a list of TAMs with less than $125K rental revenue in the previous calendar month.</li>
      <li>Then, determine the number of consecutive calendar months since the last that each of those TAMs has been below $125K rental revenue per month.</li>
    </ul>
    <div style="font-weight: 600">Prior Month New Accounts Under 5:</div>
    <ul style="">
      <li>Generate a list of TAMs with less than 5 new accounts in the previous calendar month.</li>
      <li>Then, determine the number of consecutive calendar months since the last that each of those TAMs has been below 5 new accounts per month.</li>
    </ul>
    <div style="font-weight: 600">Average Monthly Assets on Rent:</div>
    <ul style="">
      <li>Generate a list of TAMs whose month-to-date average assets on rent is less than the prior calendar month’s average, resulting in 1 “month down”.</li>
      <li>Subsequent “months down” are added if the monthly average of assets on rent continues to increase as we go backward in time.</li>
      <li>TAMs in the displayed data set meet at least one of the following sets of conditions:
        <ul>
          <li>Total months down is 3 months or more</li>
          <li>Percent change from the last peak in monthly average AOR to the MTD average is at least a 10% decrease</li>
        </ul>
        OR
        <ul>
          <li>Total months down is at most 2 months</li>
          <li>Percent change is at least a 10% decrease</li>
          <li>Last peak in monthly average AOR is at least 5 assets</li>
          <li>The decrease from the last peak in monthly average AOR to the MTD average is at least 5 assets</li>
        </ul>
      </li>
    </ul>
    <div style="font-weight: 600">Daily Assets on Rent:</div>
    <ul style="">
      <li>Generate a list of TAMs who have less assets on rent today than yesterday, resulting in 1 “day down”.</li>
      <li>Subsequent “days down” are added if daily AOR continues to increase as we go backward in time.</li>
      <li>TAMs in the displayed data set meet at least one of the following sets of conditions:
        <ul>
          <li>Total days down is at least 2</li>
          <li>Percent change in assets on rent from the last daily peak to today is at least a 10% decrease</li>
        </ul>
        OR
        <ul>
          <li>Total days down is at least 2</li>
          <li>Percent change in AOR is at least a 50% decrease</li>
          <li>Last peak in daily AOR is greater than 2</li>
        </ul>
        OR
        <ul>
          <li>Total days down is 1</li>
          <li>Percent change is at least a 20% decrease</li>
          <li>The last peak in daily AOR was greater than 10</li>
        </ul>
      </li>
    </ul>
    <div style="font-weight: 600">Average Monthly Actively Renting Customers:</div>
    <ul style="">
      <li>Generate a list of TAMs whose month-to-date average actively renting customers is less than the prior calendar month’s average, resulting in 1 “month down”.</li>
      <li>Subsequent “months down” are added if the monthly average of ARC continues to increase as we go backward in time.</li>
      <li>TAMs in the displayed data set meet at least one of the following sets of conditions:
        <ul>
          <li>Total months down is 3 months or more</li>
          <li>Percent change from the last peak in monthly average ARC to the MTD average is at least a 4% decrease</li>
        </ul>
        OR
        <ul>
          <li>Total months down is at most 2 months</li>
          <li>Percent change is at least a 10% decrease</li>
          <li>Last peak in monthly average ARC is at least 8 customers</li>
          <li>The decrease from the last peak in monthly average ARC to the MTD average is at least 4 customers</li>
        </ul>
      </li>
    </ul>
    <div style="font-weight: 600">Daily Actively Renting Customers:</div>
    <ul style="">
      <li>Generate a list of TAMs who have less ARC today than yesterday, resulting in 1 “day down”.</li>
      <li>Subsequent “days down” are added if daily ARC continues to increase as we go backward in time.</li>
      <li>TAMs in the displayed data set meet at least one of the following sets of conditions:
        <ul>
          <li>Total days down is at least 3</li>
          <li>Percent change in ARC from the last daily peak to today is at least a 2% decrease</li>
        </ul>
        OR
        <ul>
          <li>Total days down is at most 2</li>
          <li>Percent change is at least an 8% decrease</li>
          <li>Last peak in daily ARC is at least 10</li>
          <li>ARC decreases at least 2 customers from last daily peak to today</li>
        </ul>
      </li>
    </ul>
    </div>
    ;;
  }
}

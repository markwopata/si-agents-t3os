view: driver_evaluation_dashboard_info {
  derived_table: {
    sql: SELECT 1 as filler ;;
  }

  measure: dashboard_info_icon {
    type: sum
    sql: 0 ;;
    drill_fields: [dashboard_info]
    html:
      <a href="#drillmenu" target="_self">
      <font size="5">View Scoring Rules</font> <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/60d0867d1398775f9a3669b2_logo-256x256.png" style="width 24px; height: 24px;">
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
      <div style="font-weight: 600">Policy Violations</div>
      <ul style="">
        <li>Camera Covered = 5pts</li>
        <li>Driver Smoking = 5pts</li>
        <li>Driver Using Cell Phone = 8pts</li>
        <li>No Seat Belt = 10pts</li>
      </ul>
      <div style="font-weight: 600">Safety Violations</div>
      <ul style="">
        <li>Driver Distracted = 3pts</li>
        <li>Following Distance Warning = 1pt
          <ul>
            <li>When not followed by Harsh Braking</li>
          </ul>
        </li>
        <li>Harsh Braking = 1pt
          <ul>
            <li>When not preceded by a Follow Distance Warning</li>
          </ul>
        </li>
        <li>Following Distance Warning and Harsh Braking = 4pts
          <ul>
            <li>When Follow Distance Warning and Harsh Braking events occur in a quick succession of 30 seconds.</li>
            <li>This is a custom event created by code logic and not in fleetcam. The follow distance and harsh braking will be individual events in fleetcam.</li>
          </ul>
        </li>
        <li>Forward Collision Warning = 3pts</li>
      </ul>
      <div style="font-weight: 600">Speeding Violations</div>
      <ul style="">
        <li>10-20 MPH Over Speed Limit = 1pt</li>
        <li>20+ MPH Over Speed Limit = 8pts</li>
      </ul>
      <div style="font-weight: 600">Coaching Recommendation</div>
      <ul style="">
        <li>A driver is recommended coaching based on the selected week's driving if:
          <ul>
            <li>Their weekly points total exceeds 200 points</li>
            <li>They have accrued any non-cell-phone policy points that week</li>
            <li>They have accrued 40 cell phone policy points</li>
            <li>Their weekly drive time is over 20 hours, and they have a ratio of violations:hours driven that is greater than 5:2 that week</li>
            <li>Their weekly drive time is over 1 hour, and they have a ratio of violations:hours driven that is greater than 5:1 that week</li>
          </ul>
        </li>
      </ul>
      <div style="font-weight: 600">Primary and Secondary Violation</div>
      <ul style="">
        <li>These are the top violations by point total that week--not necessarily by violation count</li>
      </ul>
      </div>
      ;;
  }

  measure: asset_assignment_link {
    type: sum
    sql: 0 ;;
    html:
      <a href="https://equipmentshare.looker.com/dashboards/1753?Inventory+District=&Inventory+Branch=&Inventory+Region=&Asset+Assignment+Group=" target="_blank">
      <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/60d0867d1398775f9a3669b2_logo-256x256.png" style="width 24px; height: 24px;"> <font size="5">Latest Assignments by Asset</font>
      </a>
      ;;
  }
}

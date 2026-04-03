view: historical_combo_revenue_info {

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
    height: 90vh;
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
    <div style="font-weight: 600">Associated Primary Rental Revenue:</div>
    <ul style="">
      <li>The sum of line item (6, 8, 108, 109) amounts on approved invoices where the salesperson is the primary salesperson</li>

    </ul>
    <div style="font-weight: 600">Commission-Split Primary Rental Revenue:</div>
    <ul style="">
      <li>The portion of the sum of line item (6, 8, 108, 109) amounts on approved invoices for the primary after accounting for the number of secondary salespeople on the invoice
      <ul><li>100% of total sum with ZERO secondary salespeople on the invoice</li>
      <li>50% of total sum with any number of secondary salespeople on the invoice</li></ul></li>
    </ul>

    <div style="font-weight: 600">Associated Secondary Rental Revenue:</div>
    <ul style="">
      <li>The sum of line item (6, 8, 108, 109) amounts on approved invoices where the salesperson is a secondary salesperson</li>
    </ul>

    <div style="font-weight: 600">Commission-Split Secondary Rental Revenue:</div>
    <ul style="">
      <li>The portion of the sum of line item (6, 8, 108, 109) amounts on approved invoices for a secondary salesperson after accounting for the number of secondary salespeople on the invoice
      <ul>50% of the total sum with only 1 secondary salesperson listed on invoice
      <li>25% of the total sum with 2 secondary salespeople listed on invoice </li></ul>
    </ul>
  </li>

   <div style="font-weight: 600">Associated Ancillary Revenue:</div>
    <ul style="">
      <li>The sum of line item (5, 44) amounts on approved invoices where the salesperson is the primary salesperson</li>
    </ul>

        <div style="font-weight: 600">Commission-Split Ancillary Revenue:</div>
    <ul style="">
      <li>The portion of the sum of line item (5, 44) amounts on approved invoices for the primary after accounting for the number of secondary salespeople on the invoice
      <ul>100% of total sum with ZERO secondary salespeople on the invoice
      <li>50% of total sum with any number of secondary salespeople on the invoice</li></ul>
    </ul>

    <div style="font-weight: 600">Onsite Fuel Revenue:</div>
    <ul style="">
      <li>The sum of line item (129, 130, 131, 132) amounts on approved invoices where the salesperson is the primary salesperson</li>
    </ul>
    </div>
    ;;
  }
}

# Documentation

The goal of this dashboard is to provide visibility to users that are assigned a company vehicle.
These employees use an app on their phone to track and approve the trips that are recorded in the **sworks.vehicle_usage_tracker.es_vehicle_trips** table.
The **sworks.vehicle_usage_tracker.user_asset_assignments** table maps a user to their assigned vehicles for a specific time period.
You may see instances where a user has trips with an asset that fall outside the start and end dates in the **user_asset_assignments** table because
Fleet has the ability to change those dates after trips have already been approved.




### Lease value

The **analytics.tax.annual_vehicle_lease_value** table must be updated every year after reporting is complete.
A new version of the table is available from the IRS each year. Append that data to the existing table, and
update the payroll_year column. Appending data this way allows us to analyze previous years with the appropriate
lease value amounts.

[IRS Definition](https://www.irs.gov/publications/p15b#en_US_2022_publink1000193789)
If the vehicle value is > 59999 then use (value * 0.25) + 500
2023 - No changes to this table were needed because the IRS valuation table did not differ from 2022. The existing rows in the table were appended with the new payroll year.


## Definitions

#### Days With Vehicle

- Number of calendar days the vehicle was in use during the selected date range.
- This will be blank if the start date of the filter is after the assignment end date.


#### Calendar Day Proration

- Days With Vehicle divided by Days In Year
- Shown as a percentage


#### Personal Use Fuel

- Personal Miles multiplied by 0.055


#### Personal Use Percentage

- Personal Miles divided by Total Miles
- Shown as a percentage


#### Vehicle Annual Lease Value

- Value determined by the IRS based on the cost of the vehicle


#### Personal Use Lease Value

- Vehicle Annual Lease Value * Calendar Day Proration * Personal Use Percent


#### Taxable Use Fringe

- Personal Use Lease Value + Personal Use Fuel

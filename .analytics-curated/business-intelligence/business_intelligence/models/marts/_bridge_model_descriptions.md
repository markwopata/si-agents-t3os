{% docs bridge_user_employee %}
This model creates a 1:1 mapping for any ESDB user (company_id = 1854) that is also an employee.
It checks for matching `employee_id` if available and then defaults to matching emails after removing anything with the pattern of `deleted-[numbers]-` (`^deleted-[0-9]+-`).
{% enddocs %}

{% docs bridge_quote_salesperson %}
This gives a many-to-many relationship between quotes and salespeople, since a quote has the potential
of having multiple salespeople. Quotes don't necessarily need to be assigned to a salesperson (can be any person 
in EquipmentShare) so this ties together dim_quotes, dim_users, and dim_salesperson_enhanced to allow 
analysis of salesperson performance within quotes.
{% enddocs %}

{% docs bridge_order_salesperson %}
This gives a many-to-many relationship between orders and salespeople, since an order has the potential
of having multiple salespeople. Orders don't necessarily need to be assigned to a salesperson (can be any person 
in EquipmentShare) so this ties together dim_orders, dim_users, and dim_salesperson_enhanced to allow 
analysis of salesperson performance within orders.
{% enddocs %}

{% docs bridge_invoice_salesperson %}
This gives a many-to-many relationship between invoices and salespeople, since an order has the potential
of having multiple salespeople. Invoices don't necessarily need to be assigned to a salesperson (can be any person 
in EquipmentShare) so this ties together dim_invoices, dim_users, and dim_salesperson_enhanced to allow 
analysis of salesperson performance within orders. 
{% enddocs %}
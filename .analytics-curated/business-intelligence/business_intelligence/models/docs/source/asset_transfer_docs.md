{% docs asset_transfer__transfer_order_id %} 
The timestamp when the record was processed and inserted/updated by a dbt run job.
{% enddocs %}

{% docs asset_transfer__transfer_order_number %} 
This is the numerical value of the transfer order.
{% enddocs %}

{% docs asset_transfer__from_branch_id %} 
Branch/market the asset is being transferred from.
{% enddocs %}

{% docs asset_transfer__to_branch_id %} 
Branch/market the asset is being transferred to.
{% enddocs %}

{% docs asset_transfer__requester_user_id %} 
The user that requested the asset transfer.
{% enddocs %}

{% docs asset_transfer__receiver_user_id %} 
The user that is receiving the asset transfer.
{% enddocs %}

{% docs asset_transfer__status %} 
The user that is receiving the asset transfer. Available statuses are:
* `Requested` - transfer request is created, and `date_created` is populated
* `Request Cancelled` - transfer request can be cancelled after initial request, and `date_request_cancelled` is populated
* `Rejected` - transfer request can be rejected after initial request, and `date_rejected` is populated
* `Approved` - transfer request is approved, and `date_approved` is populated
* `Transfer Cancelled` - transfer is cancelled after request was already approved, and `date_transfer_cancelled` is populated
* `Received` - receiving branch has received the asset, and `date_received` is popoulated
{% enddocs %} 

{% docs asset_transfer__transfer_type_id %} 
The transfer type id that ties to `asset_transfer.public.transfer_types`.
{% enddocs %}

{% docs asset_transfer__is_rental_transfer %} 
Boolean indicating whether the transfer is a rental.
{% enddocs %}

{% docs asset_transfer__is_closed %} 
Boolean indicating whether the transfer is active or completed.
An asset can only ever have one active transfer.
{% enddocs %}

{% docs asset_transfer__requester_note %} 
Note from the user requesting the transfer.
{% enddocs %}

{% docs asset_transfer__request_date_created %} 
Date the asset transfer request was made.
{% enddocs %}

{% docs asset_transfer__date_updated %} 
Date the asset transfer entry was modified in the database.
{% enddocs %}

{% docs asset_transfer__date_approved %} 
Date the asset transfer was approved for transfer.
{% enddocs %}

{% docs asset_transfer__date_received %} 
Date the asset transfer request was received.
{% enddocs %}

{% docs asset_transfer__date_rejected %} 
Date the asset transfer request was rejected.
{% enddocs %}

{% docs asset_transfer__date_transfer_cancelled %} 
Date the asset transfer was cancelled.
{% enddocs %}

{% docs asset_transfer__date_request_cancelled %} 
Date the asset transfer request was cancelled.
{% enddocs %}

{% docs asset_transfer__cancellation_note %} 
Note attached to the cancellation of the asset transfer. 
This can be populated for either when the transfer status is `Request Cancelled` or `Transfer Cancelled`.
{% enddocs %}

{% docs asset_transfer__approver_note %} 
Note attached to the approval of the asset transfer.
{% enddocs %}

{% docs asset_transfer__approver_user_id %} 
The user that is approving the asset transfer.
{% enddocs %}

{% docs asset_transfer__transfer_type_name %} 
Name of the transfer type. Available transfer types are:
* `Internal Ownership`
* `Internal Custody`
{% enddocs %}
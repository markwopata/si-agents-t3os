{% docs asset_transfer_types %} 
This table stores the types of asset transfers.
{% enddocs %}

{% docs asset_transfer_orders %} 
This table records all asset transfer activity.
Transfer status changes occur in this order:
* `Requested` - transfer request is created, and `date_created` is populated
* `Request Cancelled` - transfer request can be cancelled after initial request, and `date_request_cancelled` is populated
* `Rejected` - transfer request can be rejected after initial request, and `date_rejected` is populated
* `Approved` - transfer request is approved, and `date_approved` is populated
* `Transfer Cancelled` - transfer is cancelled after request was already approved, and `date_transfer_cancelled` is populated
* `Received` - receiving branch has received the asset, and `date_received` is popoulated
{% enddocs %}
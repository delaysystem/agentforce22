// One-shot backfill: sets Order.Product_Type__c on the demo seed orders.
// Values mirror the Product2.Family of each order's line item (Solar,
// except 00000114 = Final Sale). Safe to re-run (idempotent by OrderNumber).
// Run: sf apex run --file scripts/apex/backfill_product_type.apex
Map<String, String> typeByNumber = new Map<String, String>{
    '00000109' => 'Solar',
    '00000110' => 'Solar',
    '00000111' => 'Solar',
    '00000112' => 'Solar',
    '00000113' => 'Solar',
    '00000114' => 'Final Sale',
    '00000115' => 'Solar'
};
List<Order> orders = [
    SELECT Id, OrderNumber, Product_Type__c
    FROM Order
    WHERE OrderNumber IN :typeByNumber.keySet()
];
Integer updated = 0;
for (Order o : orders) {
    String want = typeByNumber.get(o.OrderNumber);
    if (o.Product_Type__c != want) {
        o.Product_Type__c = want;
        updated++;
    }
}
update orders;
System.debug('BACKFILL: ' + updated + ' of ' + orders.size() + ' orders updated.');

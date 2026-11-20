// Seeds demo data for the Service Agent (Order Status and Returns) demo.
// Demo project in a Salesforce demo org, test data only, not a client project.
// Run: sf apex run --file scripts/apex/seed_demo_data.apex
// Idempotency guard: aborts when the DEMO account already exists (re-run
// produces no duplicates; delete demo rows first for a fresh seed).

final Integer RETURN_WINDOW_DAYS = 30; // Origin: config/agent/demo-config.json returnWindowDays
final String DEMO_ACCOUNT_NAME = 'DEMO Test Customer - Agent Demo';

List<Account> existing = [
  SELECT Id
  FROM Account
  WHERE Name = :DEMO_ACCOUNT_NAME
  LIMIT 1
];
if (!existing.isEmpty()) {
  System.debug('SEED_ABORT: demo account already exists, no rows created.');
  return;
}

Date today = Date.today();
Pricebook2 stdPb = [
  SELECT Id
  FROM Pricebook2
  WHERE IsStandard = TRUE
  LIMIT 1
];

// --- Account ---
Account demoAccount = new Account(
  Name = DEMO_ACCOUNT_NAME,
  Description = 'DEMO account for the Service Agent demo. Test data only.'
);
insert demoAccount;

// --- Products (Family drives the product-type eligibility check) ---
Product2 solar = new Product2(
  Name = 'DEMO Solar Panel Mini',
  Family = 'Solar',
  IsActive = true,
  Description = 'DEMO returnable product. Test data only.'
);
Product2 finalSale = new Product2(
  Name = 'DEMO Display Stand',
  Family = 'Final Sale',
  IsActive = true,
  Description = 'DEMO non-returnable product (Family = Final Sale). Test data only.'
);
insert new List<Product2>{ solar, finalSale };

PricebookEntry solarPbe = new PricebookEntry(
  Pricebook2Id = stdPb.Id,
  Product2Id = solar.Id,
  UnitPrice = 499.00,
  IsActive = true
);
PricebookEntry finalSalePbe = new PricebookEntry(
  Pricebook2Id = stdPb.Id,
  Product2Id = finalSale.Id,
  UnitPrice = 49.00,
  IsActive = true
);
insert new List<PricebookEntry>{ solarPbe, finalSalePbe };

// --- Orders: one per demo scenario ---
List<Order> orders = new List<Order>{
  new Order(
    AccountId = demoAccount.Id,
    EffectiveDate = today.addDays(-6),
    Status = 'Draft',
    Pricebook2Id = stdPb.Id,
    Description = 'DEMO in-transit order. Test data only.',
        Product_Type__c = 'Solar',
    Shipment_Status__c = 'In Transit',
    Carrier__c = 'UPS',
    Tracking_Link__c = 'https://demo.example.com/track/1ZDEMO999INTRANSIT',
    Delivery_Estimate__c = today.addDays(4)
  ),
  new Order(
    AccountId = demoAccount.Id,
    EffectiveDate = today.addDays(-12),
    Status = 'Draft',
    Pricebook2Id = stdPb.Id,
    Description = 'DEMO delivered in-window order. Test data only.',
        Product_Type__c = 'Solar',
    Shipment_Status__c = 'Delivered',
    Carrier__c = 'FedEx',
    Tracking_Link__c = 'https://demo.example.com/track/FDXDEMO888DELIVERED',
    Delivery_Estimate__c = today.addDays(-10),
    Delivered_Date__c = today.addDays(-10)
  ),
  new Order(
    AccountId = demoAccount.Id,
    EffectiveDate = today.addDays(-(RETURN_WINDOW_DAYS + 46)),
    Status = 'Draft',
    Pricebook2Id = stdPb.Id,
    Description = 'DEMO delivered out-of-window order. Test data only.',
        Product_Type__c = 'Solar',
    Shipment_Status__c = 'Delivered',
    Carrier__c = 'DHL',
    Tracking_Link__c = 'https://demo.example.com/track/DHLDEMO777OLD',
    Delivery_Estimate__c = today.addDays(-(RETURN_WINDOW_DAYS + 45)),
    Delivered_Date__c = today.addDays(-(RETURN_WINDOW_DAYS + 45))
  ),
  new Order(
    AccountId = demoAccount.Id,
    EffectiveDate = today.addDays(-20),
    Status = 'Draft',
    Pricebook2Id = stdPb.Id,
    Description = 'DEMO lost order (must escalate). Test data only.',
        Product_Type__c = 'Solar',
    Shipment_Status__c = 'Lost',
    Carrier__c = 'UPS',
    Tracking_Link__c = 'https://demo.example.com/track/1ZDEMO666LOST',
    Delivery_Estimate__c = today.addDays(-12)
  ),
  new Order(
    AccountId = demoAccount.Id,
    EffectiveDate = today.addDays(-9),
    Status = 'Draft',
    Pricebook2Id = stdPb.Id,
    Description = 'DEMO damaged order (must escalate). Test data only.',
        Product_Type__c = 'Solar',
    Shipment_Status__c = 'Damaged',
    Carrier__c = 'FedEx',
    Tracking_Link__c = 'https://demo.example.com/track/FDXDEMO555DAMAGED',
    Delivery_Estimate__c = today.addDays(-7),
    Delivered_Date__c = today.addDays(-8)
  ),
  new Order(
    AccountId = demoAccount.Id,
    EffectiveDate = today.addDays(-7),
    Status = 'Draft',
    Pricebook2Id = stdPb.Id,
    Description = 'DEMO final-sale delivered order (not returnable). Test data only.',
        Product_Type__c = 'Final Sale',
    Shipment_Status__c = 'Delivered',
    Carrier__c = 'USPS',
    Tracking_Link__c = 'https://demo.example.com/track/USPSDEMO444FINALSALE',
    Delivery_Estimate__c = today.addDays(-5),
    Delivered_Date__c = today.addDays(-5)
  ),
  new Order(
    AccountId = demoAccount.Id,
    EffectiveDate = today,
    Status = 'Draft',
    Pricebook2Id = stdPb.Id,
    Description = 'DEMO processing order (not shipped yet). Test data only.',
        Product_Type__c = 'Solar',
    Shipment_Status__c = 'Processing'
  )
};
insert orders;

// --- One OrderItem per order (Final Sale item only on the final-sale order) ---
List<OrderItem> items = new List<OrderItem>();
for (Integer i = 0; i < orders.size(); i++) {
  Boolean isFinalSale = (i == 5);
  items.add(
    new OrderItem(
      OrderId = orders[i].Id,
      PricebookEntryId = isFinalSale ? finalSalePbe.Id : solarPbe.Id,
      Quantity = 1,
      UnitPrice = isFinalSale ? 49.00 : 499.00
    )
  );
}
insert items;

// --- Knowledge articles (Return Policy FAQ) ---
List<Knowledge__kav> articles = new List<Knowledge__kav>{
  new Knowledge__kav(
    Title = 'DEMO: What is the return window?',
    UrlName = 'demo-what-is-the-return-window',
    Language = 'en_US',
    Summary = 'DEMO article: the return window is 30 days from delivery.',
    FAQ_Question__c = 'What is the return window?',
    FAQ_Answer__c = 'DEMO answer: you can return eligible items within 30 days of delivery. The window starts on the delivered date shown on your order.',
    Featured_in_Communities__c = false,
    Requires_Revision__c = false
  ),
  new Knowledge__kav(
    Title = 'DEMO: How do I start a return?',
    UrlName = 'demo-how-do-i-start-a-return',
    Language = 'en_US',
    Summary = 'DEMO article: starting a return with your order number.',
    FAQ_Question__c = 'How do I start a return?',
    FAQ_Answer__c = 'DEMO answer: give us your order number, the item, and the reason. If the order is within the 30-day return window we create a return request and give you a reference number.',
    Featured_in_Communities__c = false,
    Requires_Revision__c = false
  ),
  new Knowledge__kav(
    Title = 'DEMO: Which items cannot be returned?',
    UrlName = 'demo-which-items-cannot-be-returned',
    Language = 'en_US',
    Summary = 'DEMO article: Final Sale items cannot be returned.',
    FAQ_Question__c = 'Which items cannot be returned?',
    FAQ_Answer__c = 'DEMO answer: items marked Final Sale cannot be returned. Lost or damaged orders are escalated to a human agent instead of a standard return.',
    Featured_in_Communities__c = false,
    Requires_Revision__c = false
  )
};
insert articles;

List<Knowledge__kav> inserted = [
  SELECT KnowledgeArticleId
  FROM Knowledge__kav
  WHERE Id IN :articles
];
for (Knowledge__kav kav : inserted) {
  KbManagement.PublishingService.publishArticle(kav.KnowledgeArticleId, true);
}

// --- Report (captured into evidence/seed-report.json by the operator) ---
List<Order> seeded = [
  SELECT OrderNumber, Shipment_Status__c, Description
  FROM Order
  WHERE AccountId = :demoAccount.Id
  ORDER BY OrderNumber
];
for (Order o : seeded) {
  System.debug(
    'SEED_ORDER: ' +
      o.OrderNumber +
      ' | ' +
      o.Shipment_Status__c +
      ' | ' +
      o.Description
  );
}
System.debug('SEED_DONE: account=' + demoAccount.Id);

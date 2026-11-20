// Real debug runs of the three agent-action flows against demo seed data.
// Run: sf apex run --file scripts/apex/debug_flows.apex
// Every branch is exercised; output is captured to evidence/flow-debug-*.log.
// NOTE: case R1 creates one real Return_Request__c (DEMO-labeled). All other cases
// create nothing; the out-of-window case asserts the Return_Request__c count first.

// ---------- Get_Order_Details ----------
// G1: existing order by number
try {
  Flow.Interview.Get_Order_Details g1 = new Flow.Interview.Get_Order_Details(
    new Map<String, Object>{ 'orderNumber' => '00000109' }
  );
  g1.start();
  System.debug(
    'FLOWCASE G1 by-number found=' +
      g1.getVariableValue('found') +
      ' shipment=' +
      g1.getVariableValue('shipmentStatus') +
      ' carrier=' +
      g1.getVariableValue('carrier') +
      ' msg=' +
      g1.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// G2: unknown order number
try {
  Flow.Interview.Get_Order_Details g2 = new Flow.Interview.Get_Order_Details(
    new Map<String, Object>{ 'orderNumber' => '00000999' }
  );
  g2.start();
  System.debug(
    'FLOWCASE G2 bad-number found=' +
      g2.getVariableValue('found') +
      ' msg=' +
      g2.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// G3: account only (latest order wins)
try {
  Account demoAccount = [
    SELECT Id
    FROM Account
    WHERE Name = 'DEMO Test Customer - Agent Demo'
    LIMIT 1
  ];
  Flow.Interview.Get_Order_Details g3 = new Flow.Interview.Get_Order_Details(
    new Map<String, Object>{ 'accountId' => demoAccount.Id }
  );
  g3.start();
  System.debug(
    'FLOWCASE G3 by-account found=' +
      g3.getVariableValue('found') +
      ' shipment=' +
      g3.getVariableValue('shipmentStatus') +
      ' msg=' +
      g3.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// G4: neither input
try {
  Flow.Interview.Get_Order_Details g4 = new Flow.Interview.Get_Order_Details(
    new Map<String, Object>()
  );
  g4.start();
  System.debug(
    'FLOWCASE G4 empty found=' +
      g4.getVariableValue('found') +
      ' msg=' +
      g4.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// ---------- Create_Return_Request ----------
Integer returnsBefore = [SELECT COUNT() FROM Return_Request__c];

// R2: out-of-window (must NOT create)
try {
  Flow.Interview.Create_Return_Request r2 = new Flow.Interview.Create_Return_Request(
    new Map<String, Object>{
      'orderNumber' => '00000111',
      'itemDescription' => 'DEMO Solar Panel Mini',
      'reason' => 'changed mind'
    }
  );
  r2.start();
  System.debug(
    'FLOWCASE R2 out-of-window created=' +
      r2.getVariableValue('created') +
      ' escalate=' +
      r2.getVariableValue('escalate') +
      ' msg=' +
      r2.getVariableValue('resultMessage')
  );
  System.debug(
    'FLOWCASE R2 returnsBefore=' +
      returnsBefore +
      ' returnsAfter=' +
      [SELECT COUNT() FROM Return_Request__c]
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// R3: lost (must escalate, no create)
try {
  Flow.Interview.Create_Return_Request r3 = new Flow.Interview.Create_Return_Request(
    new Map<String, Object>{
      'orderNumber' => '00000112',
      'itemDescription' => 'DEMO Solar Panel Mini',
      'reason' => 'never arrived'
    }
  );
  r3.start();
  System.debug(
    'FLOWCASE R3 lost created=' +
      r3.getVariableValue('created') +
      ' escalate=' +
      r3.getVariableValue('escalate') +
      ' msg=' +
      r3.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// R4: Final Sale type (must escalate, no create)
try {
  Flow.Interview.Create_Return_Request r4 = new Flow.Interview.Create_Return_Request(
    new Map<String, Object>{
      'orderNumber' => '00000114',
      'itemDescription' => 'DEMO Display Stand',
      'reason' => 'changed mind'
    }
  );
  r4.start();
  System.debug(
    'FLOWCASE R4 final-sale created=' +
      r4.getVariableValue('created') +
      ' escalate=' +
      r4.getVariableValue('escalate') +
      ' productType=' +
      r4.getVariableValue('productType') +
      ' msg=' +
      r4.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// R5: not delivered yet (no create, no escalate)
try {
  Flow.Interview.Create_Return_Request r5 = new Flow.Interview.Create_Return_Request(
    new Map<String, Object>{
      'orderNumber' => '00000109',
      'itemDescription' => 'DEMO Solar Panel Mini',
      'reason' => 'changed mind'
    }
  );
  r5.start();
  System.debug(
    'FLOWCASE R5 in-transit created=' +
      r5.getVariableValue('created') +
      ' escalate=' +
      r5.getVariableValue('escalate') +
      ' msg=' +
      r5.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// R6: unknown order (no create)
try {
  Flow.Interview.Create_Return_Request r6 = new Flow.Interview.Create_Return_Request(
    new Map<String, Object>{
      'orderNumber' => '00000999',
      'itemDescription' => 'anything',
      'reason' => 'anything'
    }
  );
  r6.start();
  System.debug(
    'FLOWCASE R6 bad-number created=' +
      r6.getVariableValue('created') +
      ' msg=' +
      r6.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// R1: eligible in-window order (creates ONE real Return_Request__c)
try {
  Flow.Interview.Create_Return_Request r1 = new Flow.Interview.Create_Return_Request(
    new Map<String, Object>{
      'orderNumber' => '00000110',
      'itemDescription' => 'DEMO Solar Panel Mini',
      'reason' => 'arrived scratched'
    }
  );
  r1.start();
  System.debug(
    'FLOWCASE R1 eligible created=' +
      r1.getVariableValue('created') +
      ' eligible=' +
      r1.getVariableValue('eligible') +
      ' recordId=' +
      r1.getVariableValue('returnRecordId') +
      ' ref=' +
      r1.getVariableValue('referenceNumber') +
      ' msg=' +
      r1.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// ---------- SearchPolicyArticles (Apex action) ----------
// A1: matching terms (real SOSL over published articles)
try {
  SearchPolicyArticles.ArticleQuery aq1 = new SearchPolicyArticles.ArticleQuery();
  aq1.searchTerms = 'return window';
  List<SearchPolicyArticles.ArticleResult> ar1 = SearchPolicyArticles.search(
    new List<SearchPolicyArticles.ArticleQuery>{ aq1 }
  );
  System.debug(
    'FLOWCASE A1 match found=' +
      ar1[0].found +
      ' title=' +
      ar1[0].articleTitle +
      ' msg=' +
      ar1[0].resultMessage
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// A2: product-type phrasing (the query Title-Contains missed)
try {
  SearchPolicyArticles.ArticleQuery aq2 = new SearchPolicyArticles.ArticleQuery();
  aq2.searchTerms = 'Final Sale';
  List<SearchPolicyArticles.ArticleResult> ar2 = SearchPolicyArticles.search(
    new List<SearchPolicyArticles.ArticleQuery>{ aq2 }
  );
  System.debug(
    'FLOWCASE A2 final-sale found=' +
      ar2[0].found +
      ' title=' +
      ar2[0].articleTitle +
      ' msg=' +
      ar2[0].resultMessage
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// A3: no match (escalate, no invented policy)
try {
  SearchPolicyArticles.ArticleQuery aq3 = new SearchPolicyArticles.ArticleQuery();
  aq3.searchTerms = 'quantum teleportation zyxwvuts';
  List<SearchPolicyArticles.ArticleResult> ar3 = SearchPolicyArticles.search(
    new List<SearchPolicyArticles.ArticleQuery>{ aq3 }
  );
  System.debug(
    'FLOWCASE A3 no-match found=' +
      ar3[0].found +
      ' escalate=' +
      ar3[0].escalate +
      ' msg=' +
      ar3[0].resultMessage
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// A4: blank terms
try {
  SearchPolicyArticles.ArticleQuery aq4 = new SearchPolicyArticles.ArticleQuery();
  aq4.searchTerms = '   ';
  List<SearchPolicyArticles.ArticleResult> ar4 = SearchPolicyArticles.search(
    new List<SearchPolicyArticles.ArticleQuery>{ aq4 }
  );
  System.debug(
    'FLOWCASE A4 blank found=' + ar4[0].found + ' msg=' + ar4[0].resultMessage
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// P1: policy phrase match, window question (exact F1 script wording)
try {
  Flow.Interview.Search_Policy_Content p1 = new Flow.Interview.Search_Policy_Content(
    new Map<String, Object>{ 'searchTerms' => 'What is the return window?' }
  );
  p1.start();
  System.debug(
    'FLOWCASE P1 window found=' +
      p1.getVariableValue('found') +
      ' title=' +
      p1.getVariableValue('articleTitle') +
      ' msg=' +
      p1.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// P2: policy phrase match, start question (exact F2 script wording)
try {
  Flow.Interview.Search_Policy_Content p2 = new Flow.Interview.Search_Policy_Content(
    new Map<String, Object>{ 'searchTerms' => 'How do I start a return?' }
  );
  p2.start();
  System.debug(
    'FLOWCASE P2 start found=' +
      p2.getVariableValue('found') +
      ' title=' +
      p2.getVariableValue('articleTitle') +
      ' msg=' +
      p2.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// P3: policy phrase match, Final Sale question (exact F3 script wording,
// mixed case on purpose)
try {
  Flow.Interview.Search_Policy_Content p3 = new Flow.Interview.Search_Policy_Content(
    new Map<String, Object>{ 'searchTerms' => 'Can I return a Final Sale item?' }
  );
  p3.start();
  System.debug(
    'FLOWCASE P3 final found=' +
      p3.getVariableValue('found') +
      ' title=' +
      p3.getVariableValue('articleTitle') +
      ' msg=' +
      p3.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// P4: policy no-match (exact F4 script wording) must raise escalate
try {
  Flow.Interview.Search_Policy_Content p4 = new Flow.Interview.Search_Policy_Content(
    new Map<String, Object>{ 'searchTerms' => 'What is your warranty on teleporters?' }
  );
  p4.start();
  System.debug(
    'FLOWCASE P4 no-match found=' +
      p4.getVariableValue('found') +
      ' escalate=' +
      p4.getVariableValue('escalate') +
      ' msg=' +
      p4.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// P5: policy blank terms
try {
  Flow.Interview.Search_Policy_Content p5 = new Flow.Interview.Search_Policy_Content(
    new Map<String, Object>{ 'searchTerms' => '   ' }
  );
  p5.start();
  System.debug(
    'FLOWCASE P5 blank found=' +
      p5.getVariableValue('found') +
      ' msg=' +
      p5.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// H1: handoff case logging (creates ONE real DEMO Case)
try {
  Flow.Interview.Log_Handoff_Case h1 = new Flow.Interview.Log_Handoff_Case(
    new Map<String, Object>{
      'orderNumber' => '00000112',
      'issueSummary' => 'Order never arrived; agent looked up status (Lost).'
    }
  );
  h1.start();
  System.debug(
    'FLOWCASE H1 handoff caseId=' +
      h1.getVariableValue('caseId') +
      ' caseNumber=' +
      h1.getVariableValue('caseNumber') +
      ' msg=' +
      h1.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}
// H2: handoff with blank summary (default text)
try {
  Flow.Interview.Log_Handoff_Case h2 = new Flow.Interview.Log_Handoff_Case(
    new Map<String, Object>{ 'orderNumber' => '', 'issueSummary' => '' }
  );
  h2.start();
  System.debug(
    'FLOWCASE H2 blank-summary caseNumber=' +
      h2.getVariableValue('caseNumber') +
      ' msg=' +
      h2.getVariableValue('resultMessage')
  );
} catch (Exception e) {
  System.debug('FLOWCASE FAULT: ' + e.getMessage());
}

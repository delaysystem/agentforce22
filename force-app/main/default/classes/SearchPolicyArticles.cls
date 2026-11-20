public with sharing class SearchPolicyArticles {
    // SUPERSEDED for the live agent (v3+): the Einstein Agent license cannot
    // access Knowledge__kav, so the FAQ topic now uses the Search_Policy_Content
    // flow over Custom Metadata. Kept, deployed, and tested for admin-context
    // use and as evidence. Demo project, test data only.
    //
    // Agent action for the Return Policy FAQ topic: full-text search over
    // published Knowledge articles.
    //
    // Why Apex (brief: Apex only if Flow cannot do it cleanly): a Flow lookup
    // cannot filter Knowledge long-text fields (FAQ_Question__c /
    // FAQ_Answer__c) — the query faults — and Title-only matching misses
    // legitimate paraphrases ("send it back", "Final Sale"). Evidence:
    // evidence/flow-debug-002.log (faults) and the paraphrase probes in the
    // work report. SOSL searches title, question, and answer together.
    //
    // Bulk safety: one SOSL per request, no DML, no SOQL in loops. The agent
    // invokes this action with exactly one request per call; multi-request
    // calls iterate within the per-transaction SOSL limit.
    @InvocableMethod(
        label='Search Policy Articles'
        description='Full-text search over published return-policy Knowledge articles. Returns the article title with the answer. Demo project, test data only.'
        category='Knowledge'
    )
    public static List<ArticleResult> search(List<ArticleQuery> queries) {
        List<ArticleResult> results = new List<ArticleResult>();
        for (ArticleQuery query : queries) {
            results.add(searchOne(query));
        }
        return results;
    }

    private static ArticleResult searchOne(ArticleQuery query) {
        ArticleResult result = new ArticleResult();
        result.found = false;
        result.escalate = false;
        String terms = query == null ? null : query.searchTerms;
        if (String.isBlank(terms)) {
            result.resultMessage = 'Please tell me what the policy question is about.';
            return result;
        }
        String cleaned = sanitize(terms);
        if (String.isBlank(cleaned)) {
            result.resultMessage = 'Please tell me what the policy question is about.';
            return result;
        }
        List<List<SObject>> matches = Search.query(
            'FIND {' +
                cleaned +
                '} IN ALL FIELDS RETURNING Knowledge__kav(' +
                'Id, Title, FAQ_Question__c, FAQ_Answer__c ' +
                'WHERE PublishStatus = \'Online\' AND Language = \'en_US\'' +
                ') LIMIT 1'
        );
        List<Knowledge__kav> articles = (List<Knowledge__kav>) matches[0];
        if (articles.isEmpty()) {
            result.escalate = true;
            result.resultMessage = 'I couldn\'t find a published policy article about that. ' +
                'I only answer policy questions from published articles, so I\'m ' +
                'escalating this to a human agent.';
            return result;
        }
        result.found = true;
        result.articleTitle = articles[0].Title;
        result.articleAnswer = articles[0].FAQ_Answer__c;
        result.resultMessage = 'Found article: ' + articles[0].Title + '.';
        return result;
    }

    // SOSL FIND braces and quotes come from the caller; neutralize them so
    // user phrasing cannot break the query syntax.
    private static String sanitize(String terms) {
        String cleaned = terms.trim().replace('{', ' ').replace('}', ' ');
        cleaned = cleaned.replaceAll('\\s+', ' ').trim();
        return String.escapeSingleQuotes(cleaned);
    }

    public class ArticleQuery {
        @InvocableVariable(
            required=true
            description='Keywords or phrasing from the customer policy question, e.g. return window.'
        )
        public String searchTerms;
    }

    public class ArticleResult {
        @InvocableVariable(
            description='True when a published policy article matched.'
        )
        public Boolean found;
        @InvocableVariable(
            description='True when no article matched and a human should take over.'
        )
        public Boolean escalate;
        @InvocableVariable(description='Title of the matched article.')
        public String articleTitle;
        @InvocableVariable(description='Answer text of the matched article.')
        public String articleAnswer;
        @InvocableVariable(description='Plain-language result message.')
        public String resultMessage;
    }
}

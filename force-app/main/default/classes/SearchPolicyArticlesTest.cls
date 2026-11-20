@IsTest
private class SearchPolicyArticlesTest {
    private static SearchPolicyArticles.ArticleQuery queryFor(String terms) {
        SearchPolicyArticles.ArticleQuery query = new SearchPolicyArticles.ArticleQuery();
        query.searchTerms = terms;
        return query;
    }

    @TestSetup
    static void setup() {
        Knowledge__kav article = new Knowledge__kav(
            Title = 'Test: What is the return window?',
            UrlName = 'test-what-is-the-return-window',
            Language = 'en_US',
            Summary = 'Test article for SearchPolicyArticlesTest.',
            FAQ_Question__c = 'What is the return window?',
            FAQ_Answer__c = 'Test answer: 30 days from delivery.',
            Featured_in_Communities__c = false,
            Requires_Revision__c = false
        );
        insert article;
        Knowledge__kav inserted = [
            SELECT KnowledgeArticleId
            FROM Knowledge__kav
            WHERE Id = :article.Id
        ];
        KbManagement.PublishingService.publishArticle(
            inserted.KnowledgeArticleId,
            true
        );
    }

    @IsTest
    static void findsPublishedArticle() {
        Knowledge__kav article = [
            SELECT Id, Title
            FROM Knowledge__kav
            WHERE PublishStatus = 'Online'
            LIMIT 1
        ];
        Test.setFixedSearchResults(new List<Id>{ article.Id });

        List<SearchPolicyArticles.ArticleResult> results = SearchPolicyArticles.search(
            new List<SearchPolicyArticles.ArticleQuery>{
                queryFor('return window')
            }
        );

        System.assertEquals(1, results.size(), 'One result per request.');
        System.assertEquals(true, results[0].found, 'Published article matches.');
        System.assertEquals(
            article.Title,
            results[0].articleTitle,
            'Transcript shows the article title.'
        );
        System.assert(
            results[0].articleAnswer.contains('30 days'),
            'Answer text comes from the article record.'
        );
        System.assertEquals(false, results[0].escalate, 'No escalation on match.');
    }

    @IsTest
    static void noMatchEscalates() {
        Test.setFixedSearchResults(new List<Id>());

        List<SearchPolicyArticles.ArticleResult> results = SearchPolicyArticles.search(
            new List<SearchPolicyArticles.ArticleQuery>{
                queryFor('quantum teleportation warranty')
            }
        );

        System.assertEquals(false, results[0].found, 'Nothing matches.');
        System.assertEquals(true, results[0].escalate, 'No match escalates.');
        System.assertEquals(null, results[0].articleAnswer, 'No invented answer.');
    }

    @IsTest
    static void blankTermsAsksForClarification() {
        List<SearchPolicyArticles.ArticleResult> results = SearchPolicyArticles.search(
            new List<SearchPolicyArticles.ArticleQuery>{ queryFor('   ') }
        );

        System.assertEquals(false, results[0].found, 'Blank terms find nothing.');
        System.assertEquals(
            false,
            results[0].escalate,
            'Blank terms ask the user, not escalate.'
        );
    }

    @IsTest
    static void handlesMultipleRequests() {
        Knowledge__kav article = [
            SELECT Id
            FROM Knowledge__kav
            WHERE PublishStatus = 'Online'
            LIMIT 1
        ];
        Test.setFixedSearchResults(new List<Id>{ article.Id });

        List<SearchPolicyArticles.ArticleResult> results = SearchPolicyArticles.search(
            new List<SearchPolicyArticles.ArticleQuery>{
                queryFor('return window'),
                queryFor('   ')
            }
        );

        System.assertEquals(2, results.size(), 'One result per request.');
        System.assertEquals(true, results[0].found, 'First request matches.');
        System.assertEquals(false, results[1].found, 'Second request is blank.');
    }
}

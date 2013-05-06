# SPARQL for Objective-C

A library that generate SPARQL queries and request a endpoints

## Exemple

A quick and easy sparql request to understand how it works.

    SPARQL *sparql = [[SPARQL alloc] init];
    [sparql addWhereWithSubject:@"http://dbpedia.org/resource/Daft_Punk" predicate:@"?p" andObject:@"?o"];
    [sparql executeQueryWithSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSArray *items = [[(NSDictionary *)JSON objectForKey:@"results"] objectForKey:@"bindings"];
        
        
    } orFailure:nil];

##Attributes

- `NSString *baseUrl` url of the sparql endpoint
- `NSString *method` GET or POST
- `NSString *queryParameterName` the name of the query variable
- `NSString *formatParameterName` the name of the format varaible
- `NSString *formatParameterValue` by default in JSON
- `BOOL distinct` say if the query is distinct
- `int limit` the limit of results
- `int offset` where to start
- `BOOL debug` will print in the the console the query is set to YES


## Methods

    - (void)addPrefixeWithNamespace:(NSString *)ns andURI:(NSString *)uri;
You can add prefixes in your query

    - (void)addVariableWithName:(NSString *)name;
Add a varaible to select, if there is no variable, the query will be buid with *

    - (void)addVariablesWithNames:(NSArray *)names;
Same as addVariableWithName: but with a list of NSString

    - (void)selectInGraph:(NSString *)graph;
You can specify the URI of the graph where the select will be perform
    
    - (void)insertInGraph:(NSString *)graph;
By setting the URI graph, the query will perform an insert
    
    - (void)deleteInGraph:(NSString *)graph withCondition:(NSString *)condition;
By setting the URI graph and a condition, the query will perform a delete

    - (void)addWhereWithSubject:(NSString *)subject predicate:(NSString *)predicate andObject:(NSString *)object;
Generate a where condition in the query
    
    - (void)addOptionalWhereWithSubject:(NSString *)subject predicate:(NSString *)predicate andObject:(NSString *)object;
Same as addWhereWithSubject:predicate:andObject: but in an optional bloc
    
    - (void)addComplexeOptionalWhereWithSPARQLObject:(SPARQL *)sparqlObject;
Will create an optional bloc with more complex conditions with an other SPARQL object

    - (void)addUnionWithSPARQLObject:(SPARQL *)sparqlObject;
Create a union bloc

    - (void)addFilter:(NSString *)filter;
Add a filter in the where bloc of the query

    - (void)addOrderByOnVariable:(NSString *)variable inASC:(BOOL)asc;
Create an order by rule. If ASC is NO a DESC rule will be created

    - (void)executeQueryWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                          orFailure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
Perform the request on the endpoint. For now only the JSON format is supported

    - (NSString *)query;
Get the Sparql query as a String

    - (NSString *)buildWhere;
Generate only the where part of the query.
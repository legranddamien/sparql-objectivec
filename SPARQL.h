//
//Copyright (C) 2013 Damien Legrand
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software
//and associated documentation files (the "Software"), to deal in the Software without restriction,
//including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#import <Foundation/Foundation.h>
#import "AFJSONRequestOperation.h"

@interface SPARQL : NSObject {
    NSMutableArray *prefixes;
    NSMutableArray *variables;
    NSMutableArray *wheres;
    NSMutableArray *orderBys;
    NSMutableArray *unions;
    
    NSString *selectGraph;
    NSString *insertGraph;
    NSString *deleteGraph;
    NSString *deleteCondition;
}

@property (strong, nonatomic) NSString *baseUrl;
@property (strong, nonatomic) NSString *method;
@property (strong, nonatomic) NSString *queryParameterName;
@property (strong, nonatomic) NSString *formatParameterName;
@property (strong, nonatomic) NSString *formatParameterValue;
@property (nonatomic) BOOL distinct;
@property (nonatomic) int limit;
@property (nonatomic) int offset;
@property (nonatomic) BOOL debug;

- (id) initWithBaseUrl:(NSString *)url;

#pragma marks - Methods

- (void)addPrefixeWithNamespace:(NSString *)ns andURI:(NSString *)uri;

- (void)addVariableWithName:(NSString *)name;
- (void)addVariablesWithNames:(NSArray *)names;

- (void)selectInGraph:(NSString *)graph;
- (void)insertInGraph:(NSString *)graph;
- (void)deleteInGraph:(NSString *)graph withCondition:(NSString *)condition;

- (void)addWhereWithSubject:(NSString *)subject predicate:(NSString *)predicate andObject:(NSString *)object;
- (void)addOptionalWhereWithSubject:(NSString *)subject predicate:(NSString *)predicate andObject:(NSString *)object;
- (void)addComplexeOptionalWhereWithSPARQLObject:(SPARQL *)sparqlObject;

- (void)addUnionWithSPARQLObject:(SPARQL *)sparqlObject;

- (void)addFilter:(NSString *)filter;

- (void)addOrderByOnVariable:(NSString *)variable inASC:(BOOL)asc;

- (void)executeQueryWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                      orFailure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

- (NSString *)query;

- (NSString *)buildWhere;

@end


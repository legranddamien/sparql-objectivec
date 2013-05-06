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

#import "SPARQL.h"

@interface SPARQL ()

- (void)configuration;
- (NSString *)verifyVariable:(NSString *)string;
- (NSString *)verifyURL:(NSString *)string;
- (NSString *)buildQuery;

@end

@implementation SPARQL

#pragma mark - Constructors

-(void)configuration
{
    self.baseUrl                = @"http://dbpedia.org/sparql";
    self.queryParameterName     = @"query";
    self.formatParameterName    = @"format";
    self.formatParameterValue   = @"json";
    self.method                 = @"GET";
    self.distinct               = NO;
    self.limit                  = -1;
    self.offset                 = -1;
    self.debug                  = NO;
}


- (id)init
{
    self = [super init];
    
    if(self)
    {
        [self configuration];
    }
    
    return self;
}

- (id)initWithBaseUrl:(NSString *)url
{
    self = [self init];
    
    if(self)
    {
        self.baseUrl = url;
    }
    
    return self;
}

#pragma marks - Methods

- (void)addPrefixeWithNamespace:(NSString *)ns andURI:(NSString *)uri
{
    if (prefixes == nil) prefixes = [[NSMutableArray alloc] init];
    
    [prefixes addObject:[NSString stringWithFormat:@"PREFIXE %@ : <%@>", ns, uri]];
}

- (void)addVariableWithName:(NSString *)name
{
    if (variables == nil) variables = [[NSMutableArray alloc] init];
    
    [variables addObject:[self verifyVariable:name]];
}

- (void)addVariablesWithNames:(NSArray *)names
{
    for (NSString *name in names)
    {
        [self addVariableWithName:name];
    }
}

- (void)selectInGraph:(NSString *)graph
{
    selectGraph = graph;
}

- (void)insertInGraph:(NSString *)graph
{
    insertGraph = graph;
}

- (void)deleteInGraph:(NSString *)graph withCondition:(NSString *)condition
{
    deleteGraph = graph;
    deleteCondition = condition;
}

- (void)addWhereWithSubject:(NSString *)subject predicate:(NSString *)predicate andObject:(NSString *)object
{
    if (wheres == nil) wheres = [[NSMutableArray alloc] init];
    [wheres addObject:[NSString stringWithFormat:@"%@ %@ %@", [self verifyURL:subject], [self verifyURL:predicate], [self verifyURL:object]]];
}

- (void)addOptionalWhereWithSubject:(NSString *)subject predicate:(NSString *)predicate andObject:(NSString *)object
{
    if (wheres == nil) wheres = [[NSMutableArray alloc] init];
    [wheres addObject:[NSString stringWithFormat:@"OPTIONAL { %@ %@ %@ }", [self verifyURL:subject], [self verifyURL:predicate], [self verifyURL:object]]];
}

- (void)addComplexeOptionalWhereWithSPARQLObject:(SPARQL *)sparqlObject
{
    if (wheres == nil) wheres = [[NSMutableArray alloc] init];
    [wheres addObject:[NSString stringWithFormat:@"OPTIONAL %@", [sparqlObject buildWhere]]];
}

- (void)addUnionWithSPARQLObject:(SPARQL *)sparqlObject
{
    if (unions == nil) unions = [[NSMutableArray alloc] init];
    [unions addObject:[sparqlObject buildWhere]];
}

- (void)addFilter:(NSString *)filter
{
    if (wheres == nil) wheres = [[NSMutableArray alloc] init];
    [wheres addObject:[NSString stringWithFormat:@"FILTER( %@ )", filter]];
}

- (void)addOrderByOnVariable:(NSString *)variable inASC:(BOOL)asc
{
    if (orderBys == nil) orderBys = [[NSMutableArray alloc] init];
    [orderBys addObject:[NSString stringWithFormat:@"%@(%@)", (asc) ? @"ASC" : @"DESC", [self verifyVariable:variable]]];
}

- (void)executeQueryWithSuccess:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                      orFailure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSString *data = [NSString stringWithFormat:@"%@=%@&%@=%@",
                      self.queryParameterName,
                      (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)[self buildQuery], NULL, CFSTR("/?&+"), kCFStringEncodingUTF8)),
                      self.formatParameterName,
                      self.formatParameterValue];
    
    NSURL *url;
    if([self.method isEqualToString:@"GET"])
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", self.baseUrl, data]];
    }
    else
    {
        url = [NSURL URLWithString:self.baseUrl];
    }
    
    if(_debug) NSLog(@"URL = %@", url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = self.method;
    if(![self.method isEqualToString:@"GET"]) request.HTTPBody = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        success(request, response, JSON);
    } failure:failure];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [operation start];
}

- (NSString *)buildWhere
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    if(wheres == nil || [wheres count] == 0) return string;
    
    [string appendString:@" { "];
    
    int count = 0;
    for (NSString *where in wheres)
    {
        [string appendString:where];
        if(count < [wheres count]-1) [string appendString:@" ."];
        
        [string appendString:@" "];
        
        count++;
    }
    
    [string appendString:@"}"];
    
    return string;
}

#pragma marks - Private Methods

- (NSString *)verifyVariable:(NSString *)string
{
    if(![string hasPrefix:@"?"] && ![string hasPrefix:@"("]) return [NSString stringWithFormat:@"?%@", string];
    return string;
}

- (NSString *)verifyURL:(NSString *)string
{
    if ([string hasPrefix:@"http://"]) return [NSString stringWithFormat:@"<%@>", string];
    return string;
}

- (NSString *)buildQuery
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    //PREFIXES
    if(prefixes != nil && [prefixes count])
    {
        for (NSString *prefixe in prefixes)
        {
            [string appendFormat:@"%@ ", prefixe];
        }
    }
    
    //VARIABLES
    if(insertGraph != nil) [string appendFormat:@"INSERT IN GRAPH <%@> ", insertGraph];
    else if(deleteGraph != nil) [string appendFormat:@"DELETE FROM <%@> { %@ }", deleteGraph, deleteCondition];
    else [string appendString:@"SELECT "];
    
    if(self.distinct) [string appendString:@"DISTINCT "];
    
    if (variables != nil && [variables count] && insertGraph == nil && deleteGraph == nil)
    {
        for (NSString *variable in variables)
        {
            [string appendFormat:@"%@ ", variable];
        }
    }
    else if(insertGraph == nil && deleteGraph == nil)
    {
        [string appendString:@"* "];
    }
    
    //WHERES
    if(insertGraph == nil) [string appendString:@"WHERE"];
    if(selectGraph != nil) [string appendFormat:@" { GRAPH <%@>", selectGraph];
    
    if(unions != nil && [unions count]) [string appendString:@" {"];
    
    NSString *w = [self buildWhere];
    
    [string appendString:w];
    
    //UNIONS
    if(unions != nil && [unions count])
    {
        BOOL first = YES;
        for (SPARQL *u in unions)
        {
            NSString *us = [u buildWhere];
            
            if(![us isEqualToString:@""])
            {
                if(first)
                {
                    first = NO;
                    if (![w isEqualToString:@""]) [string appendString:@"UNION"];
                }
                else
                {
                    [string appendString:@"UNION"];
                }
                
                [string appendString:us];
            }
        }
        
        [string appendString:@" } "];
    }
    
    if(selectGraph != nil) [string appendString:@" } "];
    
    
    //ORDER BY
    if(orderBys != nil && [orderBys count])
    {
        [string appendString:@"ORDER BY "];
        for (NSString *orderby in orderBys)
        {
            [string appendFormat:@"%@ ", orderby];
        }
    }
    
    //LIMIT
    if(self.limit != -1) [string appendFormat:@"LIMIT %d ", self.limit];
    
    //OFFSET
    if(self.offset != -1) [string appendFormat:@"OFFSET %d ", self.offset];
    
    if(_debug) NSLog(@"%@", string);
    
    return string;
}

- (NSString *)query
{
    return [self buildQuery];
}


@end

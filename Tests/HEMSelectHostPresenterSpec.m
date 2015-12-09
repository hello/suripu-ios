//
//  HEMSelectHostPresenter.m
//  Sense
//
//  Created by Kevin MacWhinnie on 12/9/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "HEMSelectHostPresenter.h"
#import "HEMNonsenseScanService.h"

@interface HEMSelectHostPresenter () <HEMNonsenseScanServiceDelegate>

- (nullable NSString*)hostAtIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic) NSMutableArray<NSNetService*>* nonsenseHosts;

@end

SPEC_BEGIN(HEMSelectHostPresenterSpec)

__block HEMNonsenseScanService* service;
__block HEMSelectHostPresenter* presenter;

beforeEach(^{
    service = [HEMNonsenseScanService new];
    presenter = [[HEMSelectHostPresenter alloc] initWithService:service];
});

describe(@"-hostAtIndexPath:", ^{
    it(@"should return api hosts", ^{
        NSString *apiHost = [presenter hostAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                          inSection:0]];
        [[apiHost should] equal:@"https://dev-api.hello.is"];
    });
    
    it(@"should return nonsense hosts", ^{
        NSNetService* nonsense = [[NSNetService alloc] initWithDomain:@""
                                                                 type:@"_http._tcp."
                                                                 name:@"nonsense-server"
                                                                 port:9000];
        [presenter nonsenseScanService:service detectedHost:nonsense];
        [service stub:@selector(addressForNonsense:) andReturn:@"http://192.168.0.22:9000"];
        
        NSString* nonsenseHost = [presenter hostAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                               inSection:1]];
        [[nonsenseHost should] equal:@"http://192.168.0.22:9000"];
    });
});

describe(@"managing nonsense hosts", ^{
    __block UITableView* fakeTableView;
    
    beforeEach(^{
        fakeTableView = [KWMock nullMockForClass:UITableView.class];
        [presenter bindTableView:fakeTableView whenDonePerform:^(NSString * _Nonnull host) {
            // Do nothing.
        }];
    });
    
    it(@"should add the host and reload the table view", ^{
        [[fakeTableView shouldEventually] receive:@selector(reloadData)];
        
        NSNetService* nonsense = [[NSNetService alloc] initWithDomain:@""
                                                                 type:@"_http._tcp."
                                                                 name:@"nonsense-server"
                                                                 port:9000];
        [presenter nonsenseScanService:service detectedHost:nonsense];
        [[@(presenter.nonsenseHosts.count) should] equal:@1];
    });
    
    it(@"should remove the host and reload the table view", ^{
        NSNetService* nonsense = [[NSNetService alloc] initWithDomain:@""
                                                                 type:@"_http._tcp."
                                                                 name:@"nonsense-server"
                                                                 port:9000];
        [presenter nonsenseScanService:service detectedHost:nonsense];
        [[@(presenter.nonsenseHosts.count) should] equal:@1];
        
        [[fakeTableView shouldEventually] receive:@selector(reloadData)];
        
        [presenter nonsenseScanService:service hostDisappeared:nonsense];
        [[@(presenter.nonsenseHosts.count) should] equal:@0];
    });
});

SPEC_END

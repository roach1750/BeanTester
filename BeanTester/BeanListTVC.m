//
//  BeanListTVC.m
//  BeanTester
//
//  Created by Andrew Roach on 3/8/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

#import "BeanListTVC.h"
#import <PTDBeanManager.h>
#import "BeanVC.h"

@interface BeanListTVC () <PTDBeanManagerDelegate, PTDBeanDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *beans;
@property (strong, nonatomic) PTDBeanManager *beanManager;

@end

@implementation BeanListTVC

- (void)viewDidLoad {
    
    self.beans = [NSMutableDictionary dictionary];

    self.beanManager = [[PTDBeanManager alloc] initWithDelegate:self];
    
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
    self.beanManager.delegate = self;
    [self.tableView reloadData];
}

- (IBAction)reload:(UIBarButtonItem *)sender {
    if(self.beanManager.state == BeanManagerState_PoweredOn){
        NSError *error;
        [self.beanManager startScanningForBeans_error:&error];
        if (error) {
            NSLog(@"ERROR while trying to reload: %@", [error localizedDescription]);
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.beans count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Bean" forIndexPath:indexPath];
    
    PTDBean *currentBean = [self.beans.allValues objectAtIndex:indexPath.row];
    
    cell.textLabel.text = currentBean.name;
    
    NSString* state;
    switch (currentBean.state) {
        case BeanState_Unknown:
            state = @"Unknown";
            break;
        case BeanState_Discovered:
            state = @"Disconnected";
            break;
        case BeanState_AttemptingConnection:
            state = @"Connecting...";
            break;
        case BeanState_AttemptingValidation:
            state = @"Connecting...";
            break;
        case BeanState_ConnectedAndValidated:
            state = @"Connected";
            break;
        case BeanState_AttemptingDisconnection:
            state = @"Disconnecting...";
            break;
        default:
            state = @"Invalid";
            break;
    }
    
    cell.detailTextLabel.text = state;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}









#pragma mark - BeanManagerDelegate Callbacks

- (void)beanManagerDidUpdateState:(PTDBeanManager *)manager{
    if(self.beanManager.state == BeanManagerState_PoweredOn){
        [self.beanManager startScanningForBeans_error:nil];
    }
    else if (self.beanManager.state == BeanManagerState_PoweredOff) {
        
        NSLog(@"ERROR: Turn on bluetooth");
        return;
    }
}
- (void)BeanManager:(PTDBeanManager*)beanManager didDiscoverBean:(PTDBean*)bean error:(NSError*)error{
    NSUUID * key = bean.identifier;
    if (![self.beans objectForKey:key]) {
        // New bean
        NSLog(@"BeanManager:didDiscoverBean:error %@", bean);
        [self.beans setObject:bean forKey:key];
    }
    [self.tableView reloadData];
}
- (void)BeanManager:(PTDBeanManager*)beanManager didConnectToBean:(PTDBean*)bean error:(NSError*)error{
    if (error) {
        NSLog(@"ERROR while trying to connect: %@", [error localizedDescription]);
        return;
    }
    
    [self.beanManager stopScanningForBeans_error:&error];
    if (error) {
        NSLog(@"ERROR while trying to disconnect: %@", [error localizedDescription]);
        return;
    }
    [self.tableView reloadData];
}

- (void)BeanManager:(PTDBeanManager*)beanManager didDisconnectBean:(PTDBean*)bean error:(NSError*)error{
    [self.tableView reloadData];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PTDBean * bean = [self.beans.allValues objectAtIndex:indexPath.row];
        BeanVC *destController = segue.destinationViewController;
        destController.bean = bean;
        destController.beanManager = self.beanManager;
}


@end

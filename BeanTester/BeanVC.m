//
//  BeanVC.m
//  BeanTester
//
//  Created by Andrew Roach on 3/8/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

#import "BeanVC.h"
#import "PTDBeanRadioConfig.h"

@interface BeanVC () <PTDBeanManagerDelegate, PTDBeanDelegate>
@property (weak, nonatomic) IBOutlet UILabel *beanNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@end

@implementation BeanVC

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self update];
}

- (void)update {
    if (self.bean.state == BeanState_Discovered) {
        [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
        self.connectButton.enabled = YES;
    }
    else if (self.bean.state == BeanState_ConnectedAndValidated) {
        [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        self.connectButton.enabled = YES;
    }
}


- (IBAction)connectButtonPressed:(UIButton *)sender {
    if (self.bean.state == BeanState_Discovered) {
        self.bean.delegate = self;
        [self.beanManager connectToBean:self.bean error:nil];
        self.beanManager.delegate = self;
        self.connectButton.enabled = NO;
    }
    else {
        self.bean.delegate = self;
        [self.beanManager disconnectBean:self.bean error:nil];
    }
}



#pragma mark - BeanManagerDelegate Callbacks

- (void)beanManagerDidUpdateState:(PTDBeanManager *)manager{
    
}

- (void)BeanManager:(PTDBeanManager*)beanManager didDiscoverBean:(PTDBean*)bean error:(NSError*)error{
}

- (void)BeanManager:(PTDBeanManager*)beanManager didConnectToBean:(PTDBean*)bean error:(NSError*)error{
    self.beanNameLabel.text = bean.name;
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    
    [self.beanManager stopScanningForBeans_error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    [self update];
}

- (void)BeanManager:(PTDBeanManager*)beanManager didDisconnectBean:(PTDBean*)bean error:(NSError*)error{
    if (bean == self.bean) {
        [self update];
    }
}

#pragma mark BeanDelegate

-(void)bean:(PTDBean*)device error:(NSError*)error {
    NSLog(@"Connecting Error: %@", [error localizedDescription]);
}

- (void)dealloc {
    self.bean.delegate = nil;
}



@end

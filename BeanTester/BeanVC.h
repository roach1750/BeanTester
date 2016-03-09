//
//  BeanVC.h
//  BeanTester
//
//  Created by Andrew Roach on 3/8/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PTDBeanManager.h>

@interface BeanVC : UIViewController
@property (nonatomic, strong) PTDBean *bean;
@property (nonatomic, strong) PTDBeanManager *beanManager;
@end

//
//  AutoUpdateSplashController.h
//  marguerite
//
//  Created by Hypnotoad on 4/22/14.
//  Copyright (c) 2014 Cardinal Devs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STAN_MARG_AutoUpdateSplashController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel* mainStatusLabel;
@property (nonatomic, retain) IBOutlet UILabel* currentActionLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* spinner;
@property (nonatomic, retain) IBOutlet UIProgressView* progressView;

@end

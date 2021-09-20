//
//  SGPlayerViewController.h
//  Ethereal
//
//  Created by Kevin Bradley on 1/24/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGPlayerViewController : UIViewController
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) NSString *avFormatName;
- (instancetype)initWithMediaURL:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END

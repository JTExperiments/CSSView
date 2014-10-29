//
//  InterfaCSS+IBDesignable.h
//  CSSView
//
//  Created by James Tang on 30/10/14.
//  Copyright (c) 2014 James Tang. All rights reserved.
//

#import "InterfaCSS.h"
@import UIKit;

@interface InterfaCSS (Private)
- (ISSStyleSheet*) loadStyleSheetFromFileURL:(NSURL*)styleSheetFile;
@end


@interface UIView (IBDesignable)

@property (nonatomic, copy) IBInspectable NSString *styleCSS;

@end


IB_DESIGNABLE @interface IBView : UIView @end
IB_DESIGNABLE @interface IBLabel : UILabel @end
IB_DESIGNABLE @interface IBButton : UIButton @end

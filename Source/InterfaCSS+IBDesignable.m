//
//  InterfaCSS+IBDesignable.m
//  CSSView
//
//  Created by James Tang on 30/10/14.
//  Copyright (c) 2014 James Tang. All rights reserved.
//

#import "CSSView-Swift.h"
#import "InterfaCSS+IBDesignable.h"

@implementation UIView (IBDesignable)

- (void)setStyleCSS:(NSString *)styleCSS {
    self.styleClassISS = styleCSS;
}

- (NSString *)styleCSS {
    return self.styleClassISS;
}

#pragma mark Debug

- (NSString *)debugStyleDescription {
    return [NSString stringWithFormat:@"%@ %@", self.class, self.styleClassISS];
}

- (void)displayStyleDescription {
    // TODO: Override by subclass
}

#pragma mark Interface Builder

+ (void)load {
    [[InterfaCSS sharedInstance] loadStyleSheetFromMainBundleFile:@"default.css"];
}

- (void)prepareForInterfaceBuilder {

    [[self class] load];

    [[InterfaCSS sharedInstance] applyStyling:self includeSubViews:true];
}


@end


@implementation IBView


@end


@implementation IBLabel

- (void)displayStyleDescription {
    self.text = [self debugStyleDescription];
}

@end


@implementation IBButton

- (void)displayStyleDescription {
    [self setTitle:[self debugStyleDescription] forState:UIControlStateNormal];
}

@end

//
//  InterfaCSS+IBDesignable.swift
//  CSSView
//
//  Created by James Tang on 30/10/14.
//  Copyright (c) 2014 James Tang. All rights reserved.
//

import UIKit

extension InterfaCSS {
    func loadStyleSheetFromMainBundleFile (styleSheetFileName: String) -> ISSStyleSheet? {

        if let url = NSBundle(forClass: self.dynamicType).URLForResource(styleSheetFileName, withExtension: nil) {

            return self.loadStyleSheetFromFileURL(url)
        }
        return nil;
    }
}

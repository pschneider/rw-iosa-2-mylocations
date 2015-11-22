//
//  String+AddText.swift
//  MyLocations
//
//  Created by Patrick Schneider on 22/11/15.
//  Copyright © 2015 Patrick Schneider. All rights reserved.
//

import Foundation

extension String {
    mutating func addText(text: String?, withSeparator separator: String = "") -> String {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
        return self
    }
}

//
//  Functions.swift
//  MyLocations
//
//  Created by Patrick Schneider on 13/11/15.
//  Copyright © 2015 Patrick Schneider. All rights reserved.
//

import Foundation
import Dispatch

func afterDelay(seconds: Double, closure: () -> Void) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), closure)
}
//
//  Location.swift
//  MyLocations
//
//  Created by Patrick Schneider on 15/11/15.
//  Copyright © 2015 Patrick Schneider. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Location: NSManagedObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }

    var subtitle: String? {
        return category
    }
}

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

    // MARK: Photo handling
    var hasPhoto: Bool {
        return photoID != nil
    }

    var photoPath: String {
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.integerValue).jpg"
        return (applicationDocumentsDirectory as NSString).stringByAppendingPathComponent(filename)
    }

    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoPath)
    }

    func removePhotoFile() {
        if hasPhoto {
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(photoPath) {
                do {
                    try fileManager.removeItemAtPath(photoPath)
                } catch {
                    print("Error removing file: \(error)")
                }
            }
        }
    }

    class func nextPhotoID() -> Int {
        // @TODO try to implement this via core data
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentID = userDefaults.integerForKey("PhotoID")
        userDefaults.setInteger(currentID + 1, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }

    // MARK: MKAnnotation
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

//
//  MapViewController.swift
//  MyLocations
//
//  Created by Patrick Schneider on 21/11/15.
//  Copyright © 2015 Patrick Schneider. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!

    // MARK: Properties
    var managedObjectContext: NSManagedObjectContext!
    var locations: [Location] = []

    // MARK: Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        if !locations.isEmpty {
            showLocations()
        }
    }

    // MARK: Actions
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(region, animated: true)
    }

    @IBAction func showLocations() {
        let region = regionForAnnotations(locations)
        mapView.setRegion(region, animated: true)
    }

    // MARK: Helper
    func updateLocations() {
        // could also be done with nsfetechedresultscontroller
        mapView.removeAnnotations(locations)

        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)

        //        let fetchRequest = NSFetchRequest(entityName: String)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity

        locations = try! managedObjectContext.executeFetchRequest(fetchRequest) as! [Location]

        mapView.addAnnotations(locations)
    }

    func regionForAnnotations(annotations: [MKAnnotation]) -> MKCoordinateRegion {
        var region: MKCoordinateRegion

        switch annotations.count {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        case 1:
            let annotation = annotations.first!
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)

            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.latitude, annotation.coordinate.longitude)

                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }

            let center = CLLocationCoordinate2D(
                latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)

            let extraSpace = 1.1
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)

            region = MKCoordinateRegion(center: center, span: span)
        }
        return mapView.regionThatFits(region)
    }


}
// MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {

}

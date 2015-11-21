//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Patrick Schneider on 09/11/15.
//  Copyright © 2015 Patrick Schneider. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

// global private, so only once created, expensive to create, lazy
private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    // MARK: Outlets
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!

    // MARK: Properties
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    var date = NSDate()
    var descriptionText = ""
    var image: UIImage? {
        didSet {
            if let image = image {
                imageView.image = image
                imageView.hidden = false
                imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
                addPhotoLabel.hidden = true
            }
        }
    }

    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    var managedObjectContext: NSManagedObjectContext!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = locationToEdit {
            title = "Edit Location"
        }

        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName

        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)

        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        } else {
            addressLabel.text = "No Address found"
        }

        dateLabel.text = formatDate(date)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }

    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }

    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        // unwind segue from category picker view controller
        let controller = segue.sourceViewController as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }

    // MARK: UITapGestureRecognizer
    @IBAction func hideKeyboard(sender: UITapGestureRecognizer) {
        let indexPath = tableView.indexPathForRowAtPoint(sender.locationInView(tableView))
        // if let indexPath = indexPath where indexPath.section == 0 && indexPath.row == 0
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }

    // MARK: Helper
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var text = ""
        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        if let s = placemark.thoroughfare {
            text += s + " "
        }
        if let s = placemark.locality {
            text += s + " "
        }
        if let s = placemark.administrativeArea {
            text += s + " "
        }
        if let s = placemark.postalCode {
            text += s + " "
        }
        if let s = placemark.country {
            text += s + " "
        }
        return text
    }

    func formatDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }

    // MARK: Action
    @IBAction func done(sender: AnyObject) {
        let hudView = HudView.hudInView(navigationController!.view, animated: true)

        let location: Location
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext) as! Location
        }

        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark

        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        afterDelay(0.6) { self.dismissViewControllerAnimated(true, completion: nil) }
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Tableview Delegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return 88
        case (2, 2):
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        case (1, _):
            if imageView.hidden {
                return 44
            } else {
                // image ratio
                let ratio = image!.size.width / image!.size.height
                // calculate new height
                imageView.frame.size.height = imageView.frame.size.width / ratio
                return imageView.frame.size.height + 20 // + margins
            }
        default:
            return 44
        }
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            pickPhoto()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}
// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func pickPhoto() {
        if true || UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }

    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)

        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default) { _ in self.takePhotoWithCamera() }
        alertController.addAction(takePhotoAction)

        let chooseFormLibraryAction = UIAlertAction(title: "Choose from Library", style: .Default) { _ in
            self.choosePhotoFromLibrary()
        }
        alertController.addAction(chooseFormLibraryAction)

        presentViewController(alertController, animated: true, completion: nil)

    }

    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

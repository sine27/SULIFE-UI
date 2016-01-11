//
//  EditEventTVC.swift
//  SuLife
//
//  Created by Sine Feng on 11/27/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit
import MapKit

class EditEventTVC: UITableViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextField: UITextView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var switchButton: UISwitch!
    
    var startDate : NSString = ""
    var endDate : NSString = ""
    var coordinateForEvent = CLLocationCoordinate2D()
    
    var shareOrNot = false
    
    var eventDetail : EventModel!
    var locationDetail : LocationModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let date : NSDate = dateSelected != nil ? (dateSelected?.convertedDate())! : NSDate()
        
        titleTextField.text = eventDetail.title as String
        detailTextField.text = eventDetail.detail as String
        locationTextField.text = eventDetail.locationName as String
        
        startTimePicker.setDate(date, animated: true)
        endTimePicker.setDate(date, animated: true)
        
        coordinateForEvent.latitude = eventDetail.lat as CLLocationDegrees
        coordinateForEvent.longitude = eventDetail.lng as CLLocationDegrees
        
        startTimePicker.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        endTimePicker.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        startTime.text = NSDateFormatter.localizedStringFromDate((eventDetail!.startTime), dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        endTime.text = NSDateFormatter.localizedStringFromDate((eventDetail!.endTime), dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        if (eventDetail.share == false) {
            switchButton.setOn(false, animated: false)
        }
        
        // Tab The blank place, close keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    func DismissKeyboard () {
        view.endEditing(true)
    }
    
    // Mark : Text field
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == locationTextField) {
            tableView.setContentOffset(CGPoint(x: 0,y: 120), animated: true)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        tableView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }
    
    // Mark : Text field END
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (section == 0) {
            return 2
        } else if (section == 1) {
            return 6
        } else if (section == 2) {
            return 1
        }
        return 1
    }
    
    func datePickerValueChanged (datePicker: UIDatePicker) {
        
        startTime.text = NSDateFormatter.localizedStringFromDate(startTimePicker.date, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        endTime.text = NSDateFormatter.localizedStringFromDate(endTimePicker.date, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        saveAction()
    }
    
    
    func saveAction () {
        let title = titleTextField.text!
        let detail = detailTextField.text!
        let eventLocation = locationTextField.text!
        let lng = coordinateForEvent.longitude as NSNumber
        let lat = coordinateForEvent.latitude as NSNumber
        
        if (title.isEmpty || detail.isEmpty || eventLocation.isEmpty || lng == 0 || lat == 0) {
            let myAlert = UIAlertController(title: "Edit Event Failed!", message: "All fields required!", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            myAlert.addAction(okAction)
            self.presentViewController(myAlert, animated:true, completion:nil)
            return
        }
        
        // Get date from input and convert format
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        startDate = dateFormatter.stringFromDate(startTimePicker.date)
        endDate = dateFormatter.stringFromDate(endTimePicker.date)
        
        // Post to server
        let post:NSString = "title=\(title)&detail=\(detail)&starttime=\(startDate)&endtime=\(endDate)&share=\(shareOrNot)&locationName=\(eventLocation)&lng=\(lng)&lat=\(lat)"
        
        NSLog("PostData: %@",post);
        
        let editEventURL = eventURL + "/" + (eventDetail!.id as String)
        
        jsonData = commonMethods.sendRequest(editEventURL, postString: post, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        print("JSON data returned : ", jsonData)
        if (jsonData.objectForKey("message") == nil) {
            // Check if need stopActivityIndicator()
            return
        }
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue?.identifier == "editToMap") {
            let viewController = segue?.destinationViewController as! MapDetailVC
            let title = eventDetail!.title
            let lng = eventDetail!.lng
            let lat = eventDetail!.lat
            let loc_coords = CLLocationCoordinate2D(latitude: lat as CLLocationDegrees, longitude: lng as CLLocationDegrees)
            viewController.eventLocation = LocationModel(placeName: title as String, coordinate: loc_coords)
        }
    }
    
    
    @IBAction func shareEvent(sender: UISwitch) {
        if sender.on {
            shareOrNot = true
        } else {
            shareOrNot = false
        }
    }
    
    // MARK : pass information to new Event
    
    @IBAction func unwindToParent(segue: UIStoryboardSegue) {
        if let childVC = segue.sourceViewController as? SearchMapVC {
            // update this VC (parent) using newly created data from child
            if ((childVC.placeNameForEvent != nil) && (childVC.coordinateForEvent != nil)) {
                self.locationTextField.text = childVC.placeNameForEvent
                self.coordinateForEvent = childVC.coordinateForEvent!
                locationDetail!.placeName = childVC.placeNameForEvent!
                locationDetail!.coordinate = childVC.coordinateForEvent!
            } else {
                self.locationTextField.text = eventDetail.locationName as String
                self.coordinateForEvent.latitude = self.eventDetail!.lat as CLLocationDegrees
                self.coordinateForEvent.longitude = self.eventDetail!.lng as CLLocationDegrees
                locationDetail!.placeName = eventDetail.locationName as String
                locationDetail!.coordinate.latitude = self.eventDetail!.lat as CLLocationDegrees
                locationDetail!.coordinate.longitude = self.eventDetail!.lng as CLLocationDegrees
            }
        }
    }
}

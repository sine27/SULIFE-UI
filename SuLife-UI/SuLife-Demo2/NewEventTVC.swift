//
//  NewEventTVC.swift
//  SuLife
//
//  Created by Sine Feng on 11/27/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit
import MapKit

class NewEventTVC: UITableViewController {
    
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
    
    var locationDetail : LocationModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        let date : NSDate = dateSelected != nil ? (dateSelected?.convertedDate())! : NSDate()
        
        startTimePicker.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        endTimePicker.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        startTimePicker.setDate(date, animated: true)
        endTimePicker.setDate(date, animated: true)
        
        startTime.text = NSDateFormatter.localizedStringFromDate(startTimePicker.date, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        endTime.text = NSDateFormatter.localizedStringFromDate(endTimePicker.date, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        switchButton.setOn(false, animated: false)
        
        // Tab The blank place, close keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)

    }
    
    func DismissKeyboard () {
        view.endEditing(true)
    }
    
    
    // Mark : Text field
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.titleTextField {
            self.detailTextField.becomeFirstResponder()
        } else if textField == self.detailTextField {
            self.locationTextField.becomeFirstResponder()
        } else if textField == self.locationTextField {
            textField.resignFirstResponder()
        }
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

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
    
    
    @IBAction func addButtonTapped(sender: UIBarButtonItem) {
        addAction()
    }
    
    
    func addAction () {
        // Get title and detail from input
        let eventTitle = titleTextField.text!
        let eventDetail = detailTextField.text!
        let eventLocation = locationTextField.text!
        let lng = coordinateForEvent.longitude as NSNumber
        let lat = coordinateForEvent.latitude as NSNumber
        
        if (eventTitle.isEmpty || eventDetail.isEmpty || eventLocation.isEmpty || lng == 0 || lat == 0) {
            let myAlert = UIAlertController(title: "Add Event Failed!", message: "All fields required!", preferredStyle: UIAlertControllerStyle.Alert)
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
        let post:NSString = "title=\(eventTitle)&detail=\(eventDetail)&starttime=\(startDate)&endtime=\(endDate)&share=\(shareOrNot)&locationName=\(eventLocation)&lng=\(lng)&lat=\(lat)"
        
        NSLog("PostData: %@",post);
        
        jsonData = commonMethods.sendRequest(eventURL, postString: post, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        print("JSON data returned : ", jsonData)
        if (jsonData.objectForKey("message") == nil) {
            // Check if need stopActivityIndicator()
            return
        }
        self.navigationController!.popToRootViewControllerAnimated(true)
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
                self.locationTextField.text = "Please Get Coordinates of Map"
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "newToMap" && locationDetail?.coordinate != nil) {
            let viewController = segue.destinationViewController as! SearchMapVC
            let title = locationDetail!.placeName
            let lat = locationDetail!.coordinate.latitude
            let lng = locationDetail!.coordinate.longitude
            let loc_coords = CLLocationCoordinate2D(latitude: lat as CLLocationDegrees, longitude: lng as CLLocationDegrees)
            viewController.eventLocation = LocationModel(placeName: title as String, coordinate: loc_coords)
        }
    }
}

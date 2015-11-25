//
//  EditEventVC.swift
//  SuLife-Demo2
//
//  Created by Sine Feng on 11/13/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit
import MapKit

class EditEventVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextField: UITextView!
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    
    @IBOutlet weak var switchButton: UISwitch!
    
    var coordinateForEvent = CLLocationCoordinate2D()
    
    var startDate : NSString = ""
    var endDate : NSString = ""
    var shareOrNot : Bool = false
    
    var eventDetail : EventModel!
    var locationDetail : LocationModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleTextField.text = eventDetail.title as String
        detailTextField.text = eventDetail.detail as String
        locationTextField.text = eventDetail.locationName as String
        
        startTimePicker.setDate(eventDetail.startTime, animated: true)
        endTimePicker.setDate(eventDetail.endTime, animated: true)
        
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
            scrollView.setContentOffset(CGPoint(x: 0,y: 120), animated: true)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }
    
    // Mark : Text field END
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func datePickerValueChanged (datePicker: UIDatePicker) {
        
        startTime.text = NSDateFormatter.localizedStringFromDate(startTimePicker.date, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        endTime.text = NSDateFormatter.localizedStringFromDate(endTimePicker.date, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
    }
    
    @IBAction func saveButtonTapped(sender: UIButton) {
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
            } else {
                self.locationTextField.text = eventDetail.locationName as String
                self.coordinateForEvent.latitude = self.eventDetail!.lat as CLLocationDegrees
                self.coordinateForEvent.longitude = self.eventDetail!.lng as CLLocationDegrees
            }
        }
    }
}

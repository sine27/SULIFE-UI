//
//  NewTaskVC.swift
//  SuLife-Demo2
//
//  Created by Sine Feng on 11/6/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class NewTaskVC: UIViewController {
    
    // MARK : prepare for common methods
    
    let commonMethods = CommonMethodCollection()
    var jsonData = NSDictionary()
    var params : String = ""
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextField: UITextView!
    
    @IBOutlet weak var timeLable: UILabel!
    
    @IBOutlet weak var taskTimePicker: UIDatePicker!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var taskTime : NSString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        taskTimePicker.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        let date : NSDate = dateSelected != nil ? (dateSelected?.convertedDate())! : NSDate()
        
        taskTimePicker.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        taskTimePicker.setDate(date, animated: true)
        
        timeLable.text = NSDateFormatter.localizedStringFromDate(taskTimePicker.date, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
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
        } 
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == detailTextField) {
            scrollView.setContentOffset(CGPoint(x: 0,y: 20), animated: true)
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
        
        timeLable.text = NSDateFormatter.localizedStringFromDate(taskTimePicker.date, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)

    }
    
    @IBAction func addTaskTapped(sender: UIButton) {
        addAction()
    }

    func addAction() {
        let taskTitle = titleTextField.text!
        let taskDetail = detailTextField.text!
        
        if (taskTitle.isEmpty || taskDetail.isEmpty) {
            let myAlert = UIAlertController(title: "Edit Task Failed!", message: "All fields required!", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            myAlert.addAction(okAction)
            self.presentViewController(myAlert, animated:true, completion:nil)
            return
        }
        
        // Get date from input and convert format
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        taskTime = dateFormatter.stringFromDate(taskTimePicker.date)
        
        // MARK : post request to server
        
        params = "title=\(taskTitle)&detail=\(taskDetail)&establishTime=\(taskTime)"
        jsonData = commonMethods.sendRequest(taskURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        print("JSON data returned : ", jsonData)
        if (jsonData.objectForKey("message") == nil) {
            // Check if need stopActivityIndicator()
            return
        }
        
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
}


//
//  NewTaskTVC.swift
//  SuLife
//
//  Created by Sine Feng on 11/28/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class NewTaskTVC: UITableViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextField: UITextView!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var taskTimePicker: UIDatePicker!
    @IBOutlet weak var timeCell: UITableViewCell!
    
    var taskTime : NSString = ""
    
    @IBAction func timeTapped(sender: UIButton) {
        timeCell.hidden = !timeCell.hidden
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeCell.hidden = true
        
        taskTimePicker.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        let date : NSDate = dateSelected != nil ? (dateSelected?.convertedDate())! : NSDate()
        
        taskTimePicker.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        taskTimePicker.setDate(date, animated: true)
        
        timeButton.setTitle((NSDateFormatter.localizedStringFromDate(taskTimePicker.date, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)), forState: UIControlState.Normal)

        
        // Tab The blank place, close keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func DismissKeyboard () {
        view.endEditing(true)
    }
    
    // Mark : Text field
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == titleTextField) {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == detailTextField) {
            tableView.setContentOffset(CGPoint(x: 0,y: 20), animated: true)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        tableView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }
    // Mark : Text field END

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (section == 0) {
            return 1
        } else if (section == 1) {
            return 2
        }
        return 1
 
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (indexPath.section == 1 && indexPath.row == 1 && timeCell.hidden == true) {
            return 0.0
        } else if (indexPath.section == 1 && indexPath.row == 1 && timeCell.hidden == false) {
            return 150.0
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    func datePickerValueChanged (datePicker: UIDatePicker) {
        
        timeButton.setTitle((NSDateFormatter.localizedStringFromDate(taskTimePicker.date, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)), forState: UIControlState.Normal)
    }
    
    @IBAction func addTaskTapped(sender: UIBarButtonItem) {
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
        
        if (jsonData.objectForKey("message") == nil) {
            // Check if need stopActivityIndicator()
            return
        }
        
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
}

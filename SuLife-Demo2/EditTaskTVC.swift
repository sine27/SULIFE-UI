//
//  EditTaskTVC.swift
//  SuLife
//
//  Created by Sine Feng on 11/28/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class EditTaskTVC: UITableViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextField: UITextView!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var taskTimePicker: UIDatePicker!
    @IBOutlet weak var timeCell: UITableViewCell!
    
    var taskTime : NSString = ""
    
    var taskDetail : TaskModel?

    @IBAction func timeTapped(sender: UIButton) {
        timeCell.hidden = !timeCell.hidden
        tableView.beginUpdates()
        tableView.endUpdates()

    }

    // MARK : Activity indicator >>>>>
    private var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
    private var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    func activityIndicator() {
        
        blur.frame = CGRectMake(30, 30, 60, 60)
        blur.layer.cornerRadius = 10
        blur.center = self.view.center
        blur.clipsToBounds = true
        
        spinner.frame = CGRectMake(0, 0, 50, 50)
        spinner.hidden = false
        spinner.center = self.view.center
        spinner.startAnimating()
        
        self.view.addSubview(blur)
        self.view.addSubview(spinner)
    }
    
    func stopActivityIndicator() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        blur.removeFromSuperview()
    }

    // <<<<<
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        titleTextField.text = taskDetail!.title as String
        detailTextField.text = taskDetail!.detail as String
        taskTimePicker.setDate(taskDetail!.taskTime, animated: true)

        taskTimePicker.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)

        let timeTitle : String = NSDateFormatter.localizedStringFromDate(taskTimePicker.date, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        print(timeTitle)
        timeButton.setTitle(timeTitle, forState: .Normal)
        
        timeCell.hidden = true
        
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
        tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
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
    
    @IBAction func saveTaskTapped(sender: UIBarButtonItem) {
        activityIndicator()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            self.saveAction()
            
            dispatch_async(dispatch_get_main_queue(), {
                self.navigationController!.popToRootViewControllerAnimated(true)
                self.stopActivityIndicator()
            })
        })
    }
    
    func saveAction () {
        let title = titleTextField.text!
        let detail = detailTextField.text!
        
        if (title.isEmpty || detail.isEmpty) {
            dispatch_async(dispatch_get_main_queue(), {
                self.stopActivityIndicator()
            })
            commonMethods.displayAlertMessage("Edit Task Failed!", userMessage: "All fields required!", sender: self)
            return
        }

        // Get date from input and convert format
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        taskTime = dateFormatter.stringFromDate(taskTimePicker.date)
        
        
        // MARK : post request to server
        let edittaskURL = taskURL + "/" + (taskDetail!.id as String)
        params = "title=\(title)&detail=\(detail)&establishTime=\(taskTime)"
        jsonData = commonMethods.sendRequest(edittaskURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        if (jsonData.objectForKey("message") == nil) {
            dispatch_async(dispatch_get_main_queue(), {
                self.stopActivityIndicator()
            })
            return
        }
    }
}

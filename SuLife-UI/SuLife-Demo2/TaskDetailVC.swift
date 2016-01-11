//
//  TaskDetailVC.swift
//  SuLife-Demo2
//
//  Created by Sine Feng on 11/6/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class TaskDetailVC: UIViewController {
    
    // MARK : prepare for common methods
    
    let commonMethods = CommonMethodCollection()
    var jsonData = NSDictionary()
    var params : String = ""
    
    @IBOutlet weak var titleTextField: UITextView!
    @IBOutlet weak var detailTextField: UITextView!
    @IBOutlet weak var timeLable: UILabel!
    
    @IBOutlet weak var undoButton: UIButton!
    
    var taskDetail : TaskModel!
    
    var task:NSDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.userInteractionEnabled = false
        detailTextField.userInteractionEnabled = false
        
        titleTextField.text = taskDetail.title as String
        detailTextField.text = taskDetail.detail as String
        
        timeLable.text = NSDateFormatter.localizedStringFromDate((taskDetail!.taskTime), dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        if (taskDetail?.finish == false) {
            undoButton.hidden = true
        }
    }
    
    @IBAction func deleteItem(sender: AnyObject) {
        
        let myAlert = UIAlertController(title: "Delete task", message: "Are You Sure to Delete This task? ", preferredStyle: UIAlertControllerStyle.Alert)
        
        myAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            myAlert .dismissViewControllerAnimated(true, completion: nil)
        }))
        
        myAlert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action: UIAlertAction!) in
        
            // MARK : post request to server
            let deleteurl = taskURL + "/" + ((self.taskDetail?.id)! as String)
            self.params = ""
            self.jsonData = self.commonMethods.sendRequest(deleteurl, postString: self.params, postMethod: "delete", postHeader: accountToken, accessString: "x-access-token", sender: self)
            
            print("JSON data returned : ", self.jsonData)
           	if (self.jsonData.objectForKey("message") == nil) {
                // Check if need stopActivityIndicator()
                return
            }
            
            self.navigationController!.popToRootViewControllerAnimated(true)
            
        }))
        
        presentViewController(myAlert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue?.identifier == "taskToEdittask") {
            let viewController = segue?.destinationViewController as! EditTaskVC
            let id = taskDetail!.id
            let title = taskDetail!.title
            let detail = taskDetail!.detail
            let taskTime = taskDetail!.taskTime
            let finish = taskDetail!.finish
            viewController.taskDetail = TaskModel(title: title, detail: detail, time: taskTime, finish: finish, id: id)
        }
    }
    
    @IBAction func undoMarkTapped(sender: UIButton) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let title = taskDetail!.title
        let detail = taskDetail!.detail
        let taskTime = dateFormatter.stringFromDate(taskDetail!.taskTime)
        let finished = false
        
        
        // MARK : post request to server
        
        let edittaskURL = taskURL + "/" + (taskDetail!.id as String)
        params = "title=\(title)&detail=\(detail)&establishTime=\(taskTime)&finished=\(finished)"
        jsonData = commonMethods.sendRequest(edittaskURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        print("JSON data returned : ", jsonData)
        if (jsonData.objectForKey("message") == nil) {
            // Check if need stopActivityIndicator()
            return
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
        
}


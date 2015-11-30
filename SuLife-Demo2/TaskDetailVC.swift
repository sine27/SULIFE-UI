//
//  TaskDetailVC.swift
//  SuLife-Demo2
//
//  Created by Sine Feng on 11/6/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class TaskDetailVC: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextView!
    @IBOutlet weak var detailTextField: UITextView!
    @IBOutlet weak var timeLable: UILabel!
    
    @IBOutlet weak var undoButton: UIButton!
    
    var taskDetail : TaskModel!
    
    var task:NSDictionary = NSDictionary()
    
    // MARK : Activity indicator >>>>>
    private var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
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
        
        activityIndicator()
        
        let myAlert = UIAlertController(title: "Delete task", message: "Are You Sure to Delete This task? ", preferredStyle: UIAlertControllerStyle.Alert)
        
        myAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            myAlert .dismissViewControllerAnimated(true, completion: nil)
        }))
        
        myAlert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action: UIAlertAction!) in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                // MARK : post request to server
                let deleteurl = taskURL + "/" + ((self.taskDetail?.id)! as String)
                params = ""
                jsonData = commonMethods.sendRequest(deleteurl, postString: params, postMethod: "delete", postHeader: accountToken, accessString: "x-access-token", sender: self)
                
                if (jsonData.objectForKey("message") == nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.stopActivityIndicator()
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationController!.popViewControllerAnimated(true)
                    self.stopActivityIndicator()
                })
            })
        }))
        self.presentViewController(myAlert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue?.identifier == "taskToEdittask") {
            let viewController = segue?.destinationViewController as! EditTaskTVC
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
        
        activityIndicator()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            // MARK : post request to server
            
            let edittaskURL = taskURL + "/" + (self.taskDetail!.id as String)
            params = "title=\(title)&detail=\(detail)&establishTime=\(taskTime)&finished=\(finished)"
            jsonData = commonMethods.sendRequest(edittaskURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
            
            print("JSON data returned : ", jsonData)
            if (jsonData.objectForKey("message") == nil) {
                // Check if need stopActivityIndicator()
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.navigationController?.popViewControllerAnimated(true)
                self.stopActivityIndicator()
            })
        })
    }
}


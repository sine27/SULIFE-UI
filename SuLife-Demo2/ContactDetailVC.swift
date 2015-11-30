//
//  ContactDetailVC.swift
//  SuLife-Demo2
//
//  Created by Sine Feng on 11/12/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class ContactDetailVC: UIViewController {
    
    @IBOutlet weak var firstNameTextView: UITextView!
    @IBOutlet weak var lastNameTextView: UITextView!
    @IBOutlet weak var emailTextView: UITextView!
    
    var contactDetail : ContactsModel?
    //var contact : NSDictionary = NSDictionary()
    
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

        // Do any additional setup after loading the view.
        firstNameTextView.userInteractionEnabled = false
        lastNameTextView.userInteractionEnabled = false
        emailTextView.userInteractionEnabled = false
        
        firstNameTextView.text = contactDetail?.firstName as? String
        lastNameTextView.text = contactDetail?.lastName as? String
        emailTextView.text = contactDetail?.email as? String
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deleteContactTapped(sender: UIButton) {
        
        activityIndicator()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            // MARK : post request to server
            
            let deleteurl = deleteContactURL + "/" + ((self.contactDetail?.id)! as String)
            params = ""
            jsonData = commonMethods.sendRequest(deleteurl, postString: params, postMethod: "DELETE", postHeader: accountToken, accessString: "x-access-token", sender: self)
            
            print("JSON data returned : ", jsonData)
            if (jsonData.objectForKey("message") == nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopActivityIndicator()
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                let myAlert = UIAlertController(title: "Delete Contact", message: "Are You Sure to Delete This Contact? ", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                    myAlert .dismissViewControllerAnimated(true, completion: nil)
                }))
                myAlert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action: UIAlertAction!) in
                    self.navigationController!.popViewControllerAnimated(true)
                }))
                self.presentViewController(myAlert, animated: true, completion: nil)
                
                self.stopActivityIndicator()
            })
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue?.identifier == "showSharedEvents") {
            let vc = segue?.destinationViewController as! SharedEventsTVC
                
            let firstname = contactDetail!.firstName
            let lastname = contactDetail!.lastName
            let email = contactDetail!.email
            let userid = contactDetail!.id
            vc.contactDetail = ContactsModel(firstName: firstname, lastName: lastname, email: email, id: userid)
        }
    }
}

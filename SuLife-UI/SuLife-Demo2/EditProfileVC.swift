//
//  EditProfileVC.swift
//  SuLife-Demo2
//
//  Created by Sine Feng on 11/10/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController {
    
    // MARK : prepare for common methods
    
    let commonMethods = CommonMethodCollection()
    var jsonData = NSDictionary()
    var params : String = ""

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        stopActivityIndicator()
    }
    
    // <<<<<
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        firstNameTextField.userInteractionEnabled = true
        lastNameTextField.userInteractionEnabled = true
        emailTextField.userInteractionEnabled = true
        
        firstNameTextField.text = userInformation?.firstName as? String
        lastNameTextField.text = userInformation?.lastName as? String
        emailTextField.text = userInformation?.email as? String
    
    // Mark : Text field >>>>>
        
        // Tab The blank place, close keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func DismissKeyboard () {
        view.endEditing(true)
    }
    
   
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.firstNameTextField {
            self.lastNameTextField.becomeFirstResponder()
        } else if textField == self.lastNameTextField {
            self.emailTextField.becomeFirstResponder()
        } else if textField == self.emailTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == emailTextField) {
            scrollView.setContentOffset(CGPoint(x: 0,y: 100), animated: true)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }
    
    // <<<<<
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTapped(sender: UIButton) {
        saveAction()
    }
    
    func saveAction () {
        
        let firstname = firstNameTextField.text! as NSString
        let lastname = lastNameTextField.text! as NSString
        let email = emailTextField.text! as NSString
        
        if (firstname.isEqualToString(userInformation!.firstName as String) && lastname.isEqualToString(userInformation!.lastName as String) && email.isEqualToString(userInformation!.email as String)) {
            commonMethods.displayAlertMessage("Save Failed", userMessage: "Nothing Changed!", sender: self)
        } else {
            
            activityIndicator()
            
            // MARK : post request to server
            
            params = "firstname=\(firstname)&lastname=\(lastname)&email=\(email)"
            jsonData = commonMethods.sendRequest(profileURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
            
            print("JSON data returned : ", jsonData)
           	if (jsonData.objectForKey("message") == nil) {
                stopActivityIndicator()
                return
            }

            // Upload local profile
            userInformation = UserModel(firstName: firstname, lastName: lastname, email: email, id: accountToken)
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
}

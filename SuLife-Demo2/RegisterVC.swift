//
//  RegisterVC.swift
//  SuLife
//
//  Created by Sine Feng on 10/12/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController, UITextFieldDelegate {
    
    // MARK : properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userFisrtNameTextField: UITextField!
    @IBOutlet weak var userLastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userRepeatPasswordTextField: UITextField!
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        stopActivityIndicator()
    }
    
    // <<<<<
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK : keyboard issue >>>>>
        // Tab The blank place, close keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func DismissKeyboard () {
        view.endEditing(true)
    }
    
    // Mark : Text Filed position
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.userFisrtNameTextField {
            self.userLastNameTextField.becomeFirstResponder()
        } else if textField == self.userLastNameTextField {
            self.usernameTextField.becomeFirstResponder()
        } else if textField == self.usernameTextField {
            self.userEmailTextField.becomeFirstResponder()
        } else if textField == self.userEmailTextField {
            self.userPasswordTextField.becomeFirstResponder()
        } else if textField == self.userPasswordTextField {
            self.userRepeatPasswordTextField.becomeFirstResponder()
        } else if textField == self.userRepeatPasswordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == usernameTextField) {
            scrollView.setContentOffset(CGPoint(x: 0,y: 20), animated: true)
        } else if (textField == userEmailTextField) {
            scrollView.setContentOffset(CGPoint(x: 0,y: 100), animated: true)
        } else if (textField == userPasswordTextField) {
            scrollView.setContentOffset(CGPoint(x: 0,y: 180), animated: true)
        } else if (textField == userRepeatPasswordTextField) {
            scrollView.setContentOffset(CGPoint(x: 0,y: 260), animated: true)
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
    
    @IBAction func registerButtonTapped(sender: UIButton) {
        
        sender.userInteractionEnabled = false
        
        // store input
        let userFirstName = userFisrtNameTextField.text!
        let userLastName = userLastNameTextField.text!
        let username = usernameTextField.text!
        let userEmail = userEmailTextField.text!
        let userPassword = userPasswordTextField.text!
        let userRepeatPassword = userRepeatPasswordTextField.text!
        
        
        // Check for empty fields
        if (userFirstName.isEmpty || userLastName.isEmpty || username.isEmpty || userEmail.isEmpty || userPassword.isEmpty || userRepeatPassword.isEmpty)
        {
            // Display alert message and return
            commonMethods.displayAlertMessage("Input Error", userMessage: "Fill Up Required Fields", sender: self)
        }
            
            // Check password && repeat password
        else if (userPassword != userRepeatPassword)
        {
            // Display alert message and return
            commonMethods.displayAlertMessage("Input Error", userMessage: "Password Does Not Match", sender: self)
        }
        
        else {
            
            activityIndicator()
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                // MARK : post request to server >>>>>
                
                //  register
                
                params = "email=\(username)&password=\(userPassword)"
                jsonData = commonMethods.sendRequest(registerURL, postString: params, postMethod: "POST", postHeader: "", accessString: "", sender: self)
                print("JSON data returned : ", jsonData)
                if (jsonData.objectForKey("message") == nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.stopActivityIndicator()
                    })
                    return
                }
                
                accountToken = jsonData.valueForKey("Access_Token") as! NSString as String
                
                // auto login
                
                params = "email=\(username)&password=\(userPassword)"
                jsonData = commonMethods.sendRequest(loginURL, postString: params, postMethod: "POST", postHeader: "", accessString: "", sender: self)
                print("JSON data returned : ", jsonData)
                if (jsonData.objectForKey("message") == nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.stopActivityIndicator()
                    })
                    return
                }  else {
                    print("Success Message : ", jsonData.valueForKey("message"))
                }
                
                // Send user's information to database
                
                params = "firstname=\(userFirstName)&lastname=\(userLastName)&email=\(userEmail)"
                jsonData = commonMethods.sendRequest(profileURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
                print("JSON data returned : ", jsonData)
                if (jsonData.objectForKey("message") == nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.stopActivityIndicator()
                    })
                    return
                } else {
                    print("Success Message : ", jsonData.valueForKey("message"))
                }
                
                // get user's profile
                jsonData = commonMethods.sendRequest(profileURL, postString: "", postMethod: "get", postHeader: accountToken, accessString: "x-access-token", sender: self)
                if (jsonData.objectForKey("message") == nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.stopActivityIndicator()
                    })
                    commonMethods.displayAlertMessage("System Error", userMessage: "Post Profile Failed!", sender: self)
                    return
                }
                let jsonInform = jsonData.valueForKey("profile") as! NSDictionary
                let firstName = jsonInform.valueForKey("firstname") as! NSString
                let lastName = jsonInform.valueForKey("lastname") as! NSString
                let email = jsonInform.valueForKey("email") as! NSString
                let id = jsonInform.valueForKey("userid") as! NSString
                
                userInformation = UserModel(firstName: firstName, lastName: lastName, email: email, id: id)
                
                // <<<<<
                
                dispatch_async(dispatch_get_main_queue(), {
                    // registration successful, TO: StartVC
                    
                    let myAlert = UIAlertController(title: "Registration Successful", message: "Hi \(userFirstName)!\n Welcom do SuLife!", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                        self.performSegueWithIdentifier("registerToMain", sender: self)
                    })
                    
                    myAlert.addAction(okAction)
                    self.presentViewController(myAlert, animated:true, completion:nil)
                    
                    self.stopActivityIndicator()
                })
            })
        }
    }
}

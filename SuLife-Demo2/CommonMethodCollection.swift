//
//  CommonMethodCollection.swift
//  SuLife
//
//  Created by Sine Feng on 11/23/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit
import MapKit

public class CommonMethodCollection: NSObject {
    
    // ======================================================================================================
    // MARK : Post data to server
    
    public func sendRequest (postURL: String, postString: NSString, postMethod: String, postHeader: String, accessString: String, sender: AnyObject) -> NSDictionary
    {
        // result to return
        var jsonResult: NSDictionary = NSDictionary()
        
        // initialize request information
        let url: NSURL = NSURL(string: postURL)!
        let request = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
        // // post without body requested
        if (postString != "") {
            let postData: NSData = postString.dataUsingEncoding(NSASCIIStringEncoding)!
            // TEST : check parameters
            print(NSString(data: postData, encoding: NSASCIIStringEncoding))
            request.HTTPBody = postData
        }
        // post without hearder requested
        if ( postHeader != "" ) {
            request.setValue(postHeader, forHTTPHeaderField: accessString)
        }
        
        request.HTTPMethod = postMethod
        
        var reponseError: NSError?
        var response: NSURLResponse?
        var responseData: NSData?
        
        do {
            responseData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
        } catch let error as NSError {
            reponseError = error
            print(reponseError)
            responseData = nil
        }
        
        if ( responseData != nil )
        {
            let responseHTTP = response as! NSHTTPURLResponse!
            print("JSON response : ", response)
            if (responseHTTP != nil)
            {
                let responseCode = responseHTTP.statusCode
                print("Response code : ", responseCode)
                
                // Response ok
                if (responseCode >= 200 && responseCode < 300)
                {
                    let responseNSString: NSString = NSString(data: responseData!, encoding:NSUTF8StringEncoding)!
                    print("Response : ", responseNSString)
                    
                    // Convert NSData to NSDictionary
                    do {
                        jsonResult = try NSJSONSerialization.JSONObjectWithData(responseData!, options: []) as! NSDictionary
                        print("JSON Dictionary : ", jsonResult)
                    } catch let httpError {
                        print(httpError)
                        let jsonStr = NSString(data: responseData!, encoding: NSUTF8StringEncoding)
                        print("Error could not parse JSON: '\(jsonStr)'")
                    }
                }
                else {
                    if (postURL == registerURL) {
                        displayAlertMessage("Registeration Failed", userMessage: "Username used!\nPlease user another username\nor try login !", sender: sender)
                    } else if (postURL == forgetPasswordURL) {
                        displayAlertMessage("Input Error", userMessage: "No such user!", sender: sender)
                    } else if (postURL == changePasswordURL) {
                        displayAlertMessage("Input Error", userMessage: "wrong old password!", sender: sender)
                    } else if (postURL == NotificationURL) {
                        displayAlertMessage("Alert", userMessage: "Do not have notification!", sender: sender)
                    } else {
                        self.displayAlertMessage("System Error", userMessage: "Response code invalid!", sender: sender)
                    }
                }
            }
                
            // input error included
            else {
                
                // Check post URL
                if (postURL == loginURL) {
                    displayAlertMessage("Login Failed", userMessage: "Please check your Username and Password!\nIf you haven't registered,\ntry register first!", sender: sender)
                } else {
                    self.displayAlertMessage("System Error", userMessage: "Response nil!", sender: sender)
                }
                
            }

        }
        else {
            self.displayAlertMessage("Connection Error", userMessage: "Lost connection!", sender: sender)
        }
        
        // NOTE : objectForKey to detect nil
        return jsonResult
    }
    
    // ========================================================================================================
    // MARK : General alert message without handler
    
    public func displayAlertMessage(userTitle: String, userMessage: String, sender: AnyObject)
    {
        let myAlert = UIAlertController(title: userTitle, message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction)
        sender.presentViewController(myAlert, animated:true, completion:nil)
    }
    
    // =========================================================================================================
    // MARK : Date format
    
    public func dateFromString (str : String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.dateFromString(str)
        return date!
    }
    
    public func stringFromDate (date : NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let strDate = dateFormatter.stringFromDate(date)
        return strDate
    }
    
    // ==========================================================================================================
    // MARK : time format
    
    public func getFixedDate (stringFromServer : NSString, styleType : Int) -> String {
        let fixedString = stringFromServer.substringToIndex(stringFromServer.rangeOfString(".").location - 3).stringByReplacingOccurrencesOfString("T", withString: " ")
        let date = self.dateFromString(fixedString)
        
        // Type 0 : HH:ss
        
        if (styleType == 0) {
            return NSDateFormatter.localizedStringFromDate((date), dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        }
        
        // type 1 : Nov 15, 2015
        
        if (styleType == 1) {
            return NSDateFormatter.localizedStringFromDate((date), dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        }
        
        // type 2 : 15/11/2015 23:35
        
        if (styleType == 1) {
            return NSDateFormatter.localizedStringFromDate((date), dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        }
        
        return ""
    }
}



// MARK : TODO Checks

// session.dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void).resume()
// Cannot figure out why not able to read completionHandler in task


// >>>>>>>>>>>>>>>>>>>>>>>>>>>
/*
public func sendRequest (postURL: String, postString: NSString, postMethod: String, postHeader: String, accessString: String, sender: AnyObject) -> NSDictionary
{
    // result to return
    var jsonResult: NSDictionary = NSDictionary()
    
    // initialize request information
    let url: NSURL = NSURL(string: postURL)!
    let request = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 3.0)
    // // post without body requested
    if (postString != "") {
        let postData: NSData = postString.dataUsingEncoding(NSASCIIStringEncoding)!
        // TEST : check parameters
        print(NSString(data: postData, encoding: NSASCIIStringEncoding))
        request.HTTPBody = postData
    }
    // post without hearder requested
    if ( postHeader != "" ) {
        request.setValue(postHeader, forHTTPHeaderField: accessString)
    }
    
    request.HTTPMethod = postMethod
    
    print("......... 2 ..........")
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
        data, response, error in
        
        if error != nil {
            print("Error [dataTaskWithRequest] : \(error)")
            return
        }
        
        if data == nil {
            print("Error [response data = nil]")
            return
        }
        
        // NSURLResponse to NSHTTPURLResponse, check status of response
        
        let responseHTTP = response as! NSHTTPURLResponse!
        if (responseHTTP != nil)
        {
            let responseCode = responseHTTP.statusCode
            NSLog("Response code: %ld", responseCode)
            
            // Response ok
            if (responseCode >= 200 && responseCode < 300)
            {
                let responseData: NSString = NSString(data: data!, encoding:NSUTF8StringEncoding)!
                NSLog("Response: %@", responseData)
                
                // Convert NSData to NSDictionary
                do {
                    jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                    let success: NSString = jsonResult.valueForKey("message") as! NSString
                    print("Message recieved from JSON: \(success)")
                } catch let httpError {
                    print(httpError)
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: '\(jsonStr)'")
                }
            }
                
                // Response error
            else {
                self.displayAlertMessage("System Error", userMessage: "Response code invalid!", sender: sender)
            }
        }
        else {
            self.displayAlertMessage("System Error", userMessage: "Response nil!", sender: sender)
        }
    }
    
    task.resume()
    
    print("......... 4 ..........")
    
    // check responseData is empty: (message: NSDictionary).allkeys.count = 0
    return jsonResult
}
*/
// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


/*
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
    dispatch_async(dispatch_get_main_queue(), {
        self.stopActivityIndicator()
    })
})
*/




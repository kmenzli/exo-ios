// Copyright (C) 2003-2015 eXo Platform SAS.
//
// This is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as
// published by the Free Software Foundation; either version 3 of
// the License, or (at your option) any later version.
//
// This software is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this software; if not, write to the Free
// Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
// 02110-1301 USA, or see the FSF site: http://www.fsf.org.

import UIKit
import WebKit

class eXoWebBaseController: UIViewController {
    let kRequestTimeout = 10.0 //in seconds
    
    var webView:WKWebView?
    var serverURL:String? // The WebView begin with this link (sent by Server Selection/ Input Server, Basically is the link to platform)
 
    override func viewDidLoad() {        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
    Initilalize the WKWebView & setup
    */
    func setupWebView (webViewContainer : UIView) {
        let wkWebViewConfiguration = WKWebViewConfiguration()
        webView = WKWebView (frame:CGRectMake(0,0,webViewContainer.bounds.size.width, webViewContainer.bounds.size.height), configuration: wkWebViewConfiguration)        
        //Load the page web
        let url = NSURL(string: serverURL!)
        // check PLF version and go back if it's less than 4.3
        Tool.getPlatformVersion(url!, success: { (version) -> Void in
            if (version < Config.minimumPlatformVersionSupported) {
                // show warning message from main thread
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.alertPlatformVersionNotSupported()
                })
            }
        }) { (errorCode) -> Void in
            // failure during the execution of the request, let go...
        }
        // load URL in webview
        let request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: kRequestTimeout)//NSURLRequest(URL: url!)
        webView?.loadRequest(request)
        webViewContainer.addSubview(webView!)
        
        // disable the autosizing to use manual constraints
        webView?.translatesAutoresizingMaskIntoConstraints = false;
        
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        if (webView?.superview != nil) {
            let webViewContainer = webView?.superview!
            // Setup Constraints for WebView. All margin to superview = 0
            webViewContainer?.addConstraint(NSLayoutConstraint(item: webViewContainer!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: webView!, attribute: .Top, multiplier: 1.0, constant: 0.0))
            webViewContainer?.addConstraint(NSLayoutConstraint(item: webViewContainer!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: webView!, attribute: .Leading, multiplier: 1.0, constant: 0.0))
            webViewContainer?.addConstraint(NSLayoutConstraint(item: webViewContainer!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: webView!, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
            webViewContainer?.addConstraint(NSLayoutConstraint(item: webViewContainer!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: webView!, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
            
        }
    }
    
    func alertPlatformVersionNotSupported() {
        let alert:UIAlertController = UIAlertController.init(
            title: NSLocalizedString("ServerManager.Title.Warning", comment:""),
            message: NSLocalizedString("ServerManager.Message.WarningVersionNotSupported",comment:""),
            preferredStyle: UIAlertControllerStyle.Alert)
        let action:UIAlertAction = UIAlertAction.init(
            title: NSLocalizedString("Word.Back",comment:""),
            style: UIAlertActionStyle.Default,
            handler: { (action) -> Void in
                let navigationVC:UINavigationController = self.navigationController!
//                if (navigationVC.viewControllers.count > 1) {
                    // come back to the previous screen
                    navigationVC.popViewControllerAnimated(true)
//                } else {
                    // probably started from the quick action
                    // open the home screen
//                    navigationVC.popToRootViewControllerAnimated(true)
//                }
        })
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
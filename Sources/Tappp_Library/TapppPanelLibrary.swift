import Foundation
import WebKit
// import Sentry

public protocol alertDelegate: class {
    func myVCDidFinish(text: String)
}

public protocol hidePanelView {
    func hidePanelfromLibrary()
}

public protocol frameHeightDelegate {
    func updateLatestFrameheight(height: CGFloat)
}

public protocol frameHeightStatusDelegate {
    func updateLatestFrameStatus(flag: String)
}

public enum ValidationState {
    case valid
    case invalid(String)
}

public protocol tapppErrorMessage: AnyObject {
    func handleError(_ error: NSError)
}

@objc(WebkitClass1)
public class WebkitClass1: BaseClass {
    public lazy var webView = WKWebView()
    public var delegate: alertDelegate?
//    public var errorDelegate: tapppErrorMessage?
    public var delegateHide: hidePanelView?
    public var delegateHeight: frameHeightDelegate?
    public var delegateStatus: frameHeightStatusDelegate?

    private var sportsbook = ""
    private var subscriberArr = [String]()
    var view = UIView()

    var jsonString = String()
    public var isPanelAvailable = false
    public var observing = false
    public var portraitFlag = true
    public var isPanelFullScreen = false
    var webViewHeightConstraint: NSLayoutConstraint?
    private var actualHeight = 0.0
    public var appDict: [String: Any]?
    public var capturedDefaultValueDict: [String: Any]?
    public var capturedisVideo: Bool = true
    public var isEncodedRequest: Bool = false
    public var isDefaultValue: Bool = false
//    public var isUserAuthnToken: Bool = false
    var JWTPanelData = [String: Any]()
    override public init() {}
//    @objc
    public func initPanel(tapppContext: inout [String: Any], currView: UIView) {
        if let gameInfo = tapppContext[TapppContext.Sports.Context] as? [String: Any] {
            if (gameInfo.keys.contains { $0.contains(TapppContext.Request.ENCODED_REQUEST) } && gameInfo[TapppContext.Request.ENCODED_REQUEST] as! String != "" && gameInfo[TapppContext.Request.ENCODED_REQUEST] != nil) {
                isEncodedRequest = true

            } else {
                print("JWT String is nil or empty or not passed")
            }

            if isEncodedRequest {
                let jwtString = gameInfo[TapppContext.Request.ENCODED_REQUEST] as? String

                if var decodedJWTData = decodeJWT(jwt: jwtString!) {
                    JWTPanelData[TapppContext.Sports.GAME_ID] = decodedJWTData[TapppContext.Sports.GAME_ID]
                    JWTPanelData[TapppContext.User.USER_ID] = decodedJWTData[TapppContext.User.USER_ID]
                    JWTPanelData[TapppContext.Sports.BOOK_ID] = decodedJWTData[TapppContext.Sports.BOOK_ID]
                    JWTPanelData[TapppContext.Sports.BROADCASTER_NAME] = decodedJWTData[TapppContext.Sports.BROADCASTER_NAME]
                    JWTPanelData[TapppContext.Environment.ENVIRONMENT] = decodedJWTData[TapppContext.Environment.ENVIRONMENT]
                    JWTPanelData[TapppContext.Request.ENCODED_REQUEST] = gameInfo[TapppContext.Request.ENCODED_REQUEST]

                    tapppContext[TapppContext.Sports.Context] = JWTPanelData
                } else {
                    print("JWT decoding failed.")
                }
            }
        } else {
//            print("gameInfo is nil or not tranfered")
        }

//        Function to decode JWT
        func decodeJWT(jwt: String) -> [String: Any]? {
            let parts = jwt.components(separatedBy: ".")

            guard parts.count == 3,
                  let header = parts[0].base64Decoded(),
                  let payload = parts[1].base64Decoded() else {
                let domainString = "JWT decoding failed."
                let error = NSError(domain: domainString, code: 0, userInfo: nil)
                errorDelegate?.handleError(error)

                return nil
            }

            guard let headerJSON = try? JSONSerialization.jsonObject(with: header, options: []) as? [String: Any],
                  let payloadJSON = try? JSONSerialization.jsonObject(with: payload, options: []) as? [String: Any] else {
                let domainString = "Error parsing JSON in JWT."
                let error = NSError(domain: domainString, code: 0, userInfo: nil)
                errorDelegate?.handleError(error)
                return nil
            }

            return payloadJSON
        }

        actualHeight = currView.frame.size.height
        webView = WKWebView()

        // Code for debugging
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        } else {
            // Fallback on earlier versions
        }

        if checkNilInputParam(panelData: tapppContext, currView: currView) {
            switch checkPanelDataParam(panelData: tapppContext, currView: currView) {
            case .valid:
                let contentController = webView.configuration.userContentController
                contentController.add(self, name: "toggleMessageHandler")
                contentController.add(self, name: "showPanelData")
                contentController.add(self, name: "tapppPanelAction")
                view = currView

                guard let dict = objectPanelData[TapppContext.Sports.Context] as? [String: Any] else {
                    return
                }

                guard let broadcasterName = dict[TapppContext.Sports.BROADCASTER_NAME] as? String else {
                    return
                }

                guard let device = dict[TapppContext.Sports.DEVICE] as? String else {
                    return
                }

                /* guard let environment = dict[TapppContext.Environment.ENVIRONMENT] as? String  else {
                     return
                 } */
                isPanelFullScreen = dict["isPanelFullScreen"] as? Bool ?? false
                webView.translatesAutoresizingMaskIntoConstraints = !isPanelFullScreen

                let environment = dict[TapppContext.Environment.ENVIRONMENT] as? String ?? ""

                let appVersion = TapppContext.AppInfo.APP_VERSION_VALUE

                let inputURL: String = String(format: "https://registry.tappp.com/appInfo?broadcasterName=%@&device=%@&environment=%@&appVersion=%@", broadcasterName, device, environment, appVersion)
                geRegistryServiceDetail(inputURL: inputURL) { responseURL in
                    self.appURL = responseURL!
                } completion2: { defaultValueDict in
                    // Assign the defaultValueDict to the captured property
                    self.capturedDefaultValueDict = defaultValueDict
                } completion3: { isDefaultValue in
                    self.isDefaultValue = isDefaultValue
                } completion4: {
                    appdict in self.appDict = appdict
                }
            case let .invalid(err):

                exceptionHandleHTML(errMsg: err)

                let error = NSError(domain: "MethodName: init : \(err) \(tapppContext.description)", code: 0, userInfo: nil)
                errorDelegate?.handleError(error)
            }
        } else {
            let error = NSError(domain: "Nil Input parameter in init.", code: 0, userInfo: nil)
            errorDelegate?.handleError(error)
        }

        btnInfo = UIButton(frame: CGRect(x: view.frame.width - 60, y: 30, width: 50, height: 50))
        btnInfo.clipsToBounds = true
        btnInfo.contentMode = .scaleAspectFill
        btnInfo.isHidden = true
        btnInfo.addTarget(self,
                          action: #selector(buttonAction),
                          for: .touchUpInside)
        btnInfo.translatesAutoresizingMaskIntoConstraints = true
        btnInfo.autoresizingMask = [UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleRightMargin, UIView.AutoresizingMask.flexibleTopMargin, UIView.AutoresizingMask.flexibleBottomMargin]
        view.addSubview(btnInfo)

        guard let dict = objectPanelData[TapppContext.Sports.Context] as? [String: Any] else {
            return
        }

        portraitFlag = dict["displayPortraitIcon"] as? Bool ?? true

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged(notification:)),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
    }
    
    public func showToast(message: String) {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }

        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alert.view.backgroundColor = .systemBlue
//        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        alert.view.backgroundColor = .systemBlue
        


        rootViewController.present(alert, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            alert.dismiss(animated: true, completion: nil)
        }
    }


    @objc public func orientationChanged(notification: NSNotification) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            let device = notification.object as! UIDevice
            let deviceOrientation = device.orientation
            switch deviceOrientation {
            case .landscapeLeft, .landscapeRight:
                // UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true, completion: nil)
                btnInfo.isHidden = true
                webView.isHidden = false
            case .portrait, .portraitUpsideDown:
                if isPanelFullScreen {
                    btnInfo.isHidden = true
                    webView.isHidden = false
                  
                } else {
                    if portraitFlag {
                        if !isPanelClosed {
                            btnInfo.isHidden = false
                            webView.isHidden = true
                            // Show toast only when switching to portrait
//                                                let message = "For best experience switch to landscape mode."
//                                                showToast(message: message)
                        } else {
                            btnInfo.isHidden = true
                            webView.isHidden = true
                        }
                    } else {
                        btnInfo.isHidden = true
                        webView.isHidden = true
                    }
                }
            case .faceUp, .faceDown:
                print("faceup facedown state")
            case .unknown: // handle unknown
                print("Unknown state")
            @unknown default: break // handle unknown default
            }
        }
    }

    @objc
    func buttonAction() {
        // Show toast only when switching to portrait
                            let message = "For best experience switch to landscape mode."
                            showToast(message: message)
        
        
//        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let firstAction: UIAlertAction = UIAlertAction(title: "For best experience switch to landscape mode.", style: .default) { _ in
//            print("First Action pressed")
//        }
//        actionSheetController.addAction(firstAction)
//        let subview = actionSheetController.view.subviews.first! as UIView
//        // let alertContentView = subview.subviews.first! as UIView
//        if let firstSubview = actionSheetController.view.subviews.first, let alertContentView = firstSubview.subviews.first {
//            for view in alertContentView.subviews {
//                view.backgroundColor = .blue
//            }
//        }
//
//        actionSheetController.view.tintColor = .white
//        actionSheetController.popoverPresentationController?.sourceView = webView // works for both iPhone & iPad
//        UIApplication.shared.delegate?.window??.rootViewController?.present(actionSheetController, animated: true, completion: nil)
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
//            actionSheetController.dismiss(animated: true)
//        }
    }

    @objc
    public func startPanel() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.appURL.count > 0 {
                timer.invalidate()
                self.view.addSubview(self.webView)
                self.webView.navigationDelegate = self
                if self.isPanelFullScreen {
                    NSLayoutConstraint.activate([
                        self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                        self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                        self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                        self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
                    ])
                } else {
                    self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                }
                // self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                self.webView.backgroundColor = UIColor.clear
                self.webView.isOpaque = false

                
//                FIRST Attempt
//                let customBundle = Bundle(for: WebkitClass1.self)
//                print("Custombundle: ",customBundle)
//                guard let resourceURL = customBundle.resourceURL?.appendingPathComponent("dist.bundle") else { return }
//                print("Resource URL: ",resourceURL)
//                guard let resourceBundle = Bundle(url: resourceURL) else { return }
//                print("resourceBundle: ",resourceBundle)
//                guard let jsFileURL = resourceBundle.url(forResource: "index", withExtension: "html") else { return }
//                print("jsFileURL: ",jsFileURL)
//                self.webView.loadFileURL(jsFileURL, allowingReadAccessTo: jsFileURL.deletingLastPathComponent())
                
//                Hii
                
//                Hii
                
//                Second Attempt
                // Constructing the file path to the 'index.html' file within the Swift package's structure
//                let currentFileURL = URL(fileURLWithPath: #file)
//                print("currentFileUrl: ",currentFileURL)
//                let packageURL = currentFileURL
//                    .deletingLastPathComponent() // TapppPanelLibrary/Sources/TapppPanelLibrary/dist
//                    .deletingLastPathComponent() // TapppPanelLibrary/Sources/TapppPanelLibrary
//                    .deletingLastPathComponent() // TapppPanelLibrary/Sources
//                    .deletingLastPathComponent() // TapppPanelLibrary
//                let indexPath = packageURL.appendingPathComponent("Tappp_Library/Sources/Tappp_Library/dist/index.html")
//                print("indexPath: ",indexPath)
//                self.webView.loadFileURL(indexPath, allowingReadAccessTo: indexPath.deletingLastPathComponent())
                
                // Checking if the 'index.html' file exists at the specified path
//                if FileManager.default.fileExists(atPath: indexPath.path) {
//                    do {
//                        let htmlContent = try String(contentsOf: indexPath)
//                        // Perform operations with the HTML content
//                        print(htmlContent)
//                    } catch {
//                        print("Error reading index.html:", error.localizedDescription)
//                    }
//                } else {
//                    print("index.html file not found")
//                }
                
//                Third Attepmt
//                if let indexHTMLPath = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "Tappp_Library/dist") {
//                    // Load the HTML content or perform necessary operations with the index.html file path
//                    do {
//                        let htmlContent = try String(contentsOfFile: indexHTMLPath)
//                        print(htmlContent) // Print the HTML content
//                    } catch {
//                        print("Error reading HTML file:", error.localizedDescription)
//                    }
//                } else {
//                    print("index.html file not found")
//                }
                
//                Forth Attempt
                // Assuming 'index.html' is in the 'dist' folder within the package
                let myBundle = Bundle(for: WebkitClass1.self)
                print("MyBundle: ",myBundle)
                    if let indexPath = myBundle.url(forResource: "index", withExtension: "html", subdirectory: "dist") {
                        // Loading 'index.html' file using WKWebView
                        print("Index Path: ",indexPath)
                        self.webView.loadFileURL(indexPath, allowingReadAccessTo: indexPath.deletingLastPathComponent())
                    } else {
                        print("index.html file not found")
                    }
                } else {
                    print("index.html file not found")
                }
//hii

                
                

                self.isPanelAvailable = true
                self.webView.configuration.preferences.javaScriptEnabled = true
                // self.webView.configuration.userContentController.add(self, name: self.mNativeToWebHandler)
            }
        }
    

    public func loadDataJS(objPanelData: [String: Any]) {
        print("inside load data js")
        var dict = [String: Any]()
        var gameId = ""
        var bookId = ""
        var userId = ""
        var broadcasterName = ""
        var env = ""
        var device = ""
        var encodedRequest = ""
        var UserAuthnToken = ""
        var channelId = ""
        var widthVal = ""

        if isDefaultValue {
            dict = capturedDefaultValueDict ?? [:]

            widthVal = dict[TapppContext.Request.WIDTH_VALUE] as! String

            channelId = dict[TapppContext.Sports.CHANNEL_ID] as! String

        } else {
            dict = (objPanelData[TapppContext.Sports.Context] as? [String: Any])!

            guard let widthDict = dict[TapppContext.Request.WIDTH] as? [String: Any] else {
                return
            }

            widthVal = widthDict[TapppContext.Request.VALUE] as! String
        }

        if let appInfoDict = capturedDefaultValueDict {
            channelId = appInfoDict[TapppContext.Sports.CHANNEL_ID] as! String

        } else {
            channelId = TapppContext.DeviceInfo.SMART_APP
        }

        guard let broadcasterName = dict[TapppContext.Sports.BROADCASTER_NAME] as? String else {
            return
        }

        encodedRequest = ""
        if dict[TapppContext.Request.ENCODED_REQUEST] != nil {
            encodedRequest = dict[TapppContext.Request.ENCODED_REQUEST] as! String
        }

        UserAuthnToken = ""
        if dict[TapppContext.User.USER_AUTHN_TOKEN] != nil {
            UserAuthnToken = dict[TapppContext.User.USER_AUTHN_TOKEN] as! String
        }

        gameId = dict[TapppContext.Sports.GAME_ID] as! String

        bookId = dict[TapppContext.Sports.BOOK_ID] as! String

        userId = dict[TapppContext.User.USER_ID] as! String

        env = dict[TapppContext.Environment.ENVIRONMENT] as! String

        device = dict[TapppContext.Sports.DEVICE] as! String

        print("appURL before setting: ", appURL)

        webView.evaluateJavaScript("handleMessage('\(gameId)', '\(bookId)', '\(widthVal)', '\(broadcasterName)', '\(userId)', '\(frameUnit)', '\(appURL)', '\(TapppContext.CURRENT_DEVICE)','\(env)', '\(encodedRequest)', '\(UserAuthnToken)', '\(device)','\(channelId)');", completionHandler: { result, _ in
            if let val = result as? String {
                print(val)
            } else {
                //                print("result is NIL")
            }
        })
    }

    public func subscribe(event: String, completion: (String) -> Void) {
        subscriberArr.append(event)
        completion("subscriber configured")
    }

    public func unSubscribe(event: String, completion: (String) -> Void) {
        if let index = subscriberArr.firstIndex(of: event) {
            subscriberArr.remove(at: index)
        }
        completion("unSubscriber configured")
    }

    public func stopPanel() {
        if #available(iOS 14.0, *) {
            webView.configuration.userContentController.removeAllScriptMessageHandlers()
        } else {
            // Fallback on earlier versions
        }
        webView.removeFromSuperview()
    }

    // conditional code based on API.
    public func showPanel() {
        startPanel()
    }

    public func hidePanel() {
        if isPanelAvailable {
            isPanelAvailable = false
            delegateHide?.hidePanelfromLibrary()
        } else {
            let error = NSError(domain: "Error in hide panel. Trying to hide invisible panel.", code: 0, userInfo: nil)
            // SentrySDK.capture(error: error)
        }
    }
}

extension WebkitClass1: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        guard let dict = message.body as? [String : AnyObject] else {
//            return
//        }

        if message.name == "tapppPanelAction" {
            print(message.body as? String)
            let responseObj = message.body as? String ?? ""
            managePanelState(obj: responseObj)
        }

        if message.name == "toggleMessageHandler", let dict = message.body as? NSDictionary {
            let userName = dict["message"] as! String
            if subscriberArr.contains(where: { $0 == "toastDisplay" }) {
                delegate?.myVCDidFinish(text: userName)
            }
        } else if message.name == "showPanelData" {
        }
    }

    public func managePanelState(obj: String) {
        delegateStatus?.updateLatestFrameStatus(flag: obj)
        if obj == TapppContext.ActionState.MINIMIZE || obj == TapppContext.ActionState.CLOSE {
            delegateHeight?.updateLatestFrameheight(height: 120.0)
            /* if UIDevice.current.userInterfaceIdiom == .phone {
                 self.btnInfo.isHidden = true
                 self.isPanelClosed = true
             } */
        } else {
            delegateHeight?.updateLatestFrameheight(height: actualHeight)
        }
    }
}

extension WebkitClass1: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadDataJS(objPanelData: objectPanelData)
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let error = NSError(domain: "Webview failed loading \(error.localizedDescription)", code: 0, userInfo: nil)
        // SentrySDK.capture(error: error)
    }
}

extension String {
    func base64Decoded() -> Data? {
        let padding = String(repeating: "=", count: (4 - count % 4) % 4)
        guard let data = Data(base64Encoded: self + padding, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return data
    }
}

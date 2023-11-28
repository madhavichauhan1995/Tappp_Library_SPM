import Foundation
import UIKit

public class BaseClass: NSObject {
    var frameUnit = ""
    var objectPanelData = [String: Any]()
    public var appURL = ""
    var btnInfo = UIButton()
    var isPanelClosed = false
    public var errorDelegate: tapppErrorMessage?
}

// MARK: - Data Validations

extension BaseClass {
    public func checkNilInputParam(panelData: [String: Any]?, currView: UIView?) -> Bool {
        if currView == nil {
            return false
        }
        if panelData == nil {
            return false
        }
        return true
    }

    public func checkPanelDataParam(panelData: [String: Any]?, currView: UIView?) -> ValidationState {
        var internalPaneldata = [String: Any]()

        // an array to hold missing keys
        var missingKeys = [String]()

        if let pData = panelData?[TapppContext.Sports.Context] as? [String: Any] {
            internalPaneldata = pData
        } else {
            return .invalid(TapppContext.ErrorMessage.GAMEINFO_OBJECT_NOT_FOUND)
        }

        if let gId = internalPaneldata[TapppContext.Sports.GAME_ID] as? String {
            if gId.count > 0 {
            } else {
                missingKeys.append(TapppContext.ErrorMessage.GAMEID_NULL_EMPTY)
            }
        } else {
            missingKeys.append(TapppContext.ErrorMessage.GAMEID_NOT_FOUND)
        }

        if let uId = internalPaneldata[TapppContext.User.USER_ID] as? String {
            if uId.count > 0 {
            } else {
                missingKeys.append(TapppContext.ErrorMessage.USERID_NULL_EMPTY)
            }
        } else {
            missingKeys.append(TapppContext.ErrorMessage.USERID_NOT_FOUND)
        }

        if let bName = internalPaneldata[TapppContext.Sports.BROADCASTER_NAME] as? String {
            if bName.count > 0 {
            } else {
                missingKeys.append(TapppContext.ErrorMessage.BROADCASTERNAME_NULL_EMPTY)
            }
        } else {
            missingKeys.append(TapppContext.ErrorMessage.BROADCASTERNAME_NOT_FOUND)
        }

        if let env = internalPaneldata[TapppContext.Environment.ENVIRONMENT] as? String {
            if env.count == 0 {
                missingKeys.append(TapppContext.ErrorMessage.ENVIRONMENT_NULL_EMPTY)
                internalPaneldata[TapppContext.Environment.ENVIRONMENT] = TapppContext.Environment.DEV
            }
        } else {
            missingKeys.append(TapppContext.ErrorMessage.ENVIRONMENT_NOT_FOUND)
            internalPaneldata[TapppContext.Environment.ENVIRONMENT] = TapppContext.Environment.DEV
        }

        if let bId = internalPaneldata[TapppContext.Sports.BOOK_ID] as? String {
            if bId.count > 0 {
            } else {
                exceptionHandleHTML(errMsg: TapppContext.ErrorMessage.BOOKID_NULL_EMPTY)
                internalPaneldata[TapppContext.Sports.BOOK_ID] = "1000009"
            }
        } else {
            exceptionHandleHTML(errMsg: TapppContext.ErrorMessage.BOOKID_NOT_FOUND)
            internalPaneldata[TapppContext.Sports.BOOK_ID] = "1000009"
        }

        if let device = internalPaneldata[TapppContext.Sports.DEVICE] as? String {
            if device.count > 0 {
            } else {
                exceptionHandleHTML(errMsg: TapppContext.ErrorMessage.DEVICE_NULL_EMPTY)
                internalPaneldata[TapppContext.Sports.DEVICE] = TapppContext.DeviceInfo.SMART_APP
            }
        } else {
            exceptionHandleHTML(errMsg: TapppContext.ErrorMessage.DEVICE_NOT_FOUND)
            internalPaneldata[TapppContext.Sports.DEVICE] = TapppContext.DeviceInfo.SMART_APP
        }

        if let widthInfo = internalPaneldata[TapppContext.Request.WIDTH] as? [String: Any] {
            if let unit = widthInfo[TapppContext.Request.UNIT] as? String, unit.count > 0 {
                frameUnit = unit
            } else {
                frameUnit = TapppContext.Request.UNIT_VAL
            }
            if let val = widthInfo[TapppContext.Request.VALUE] as? String, val.count > 0 {
                print("From reference app val", val)
            } else {
                var widthInfoUD = [String: Any]()
                widthInfoUD[TapppContext.Request.UNIT] = "%"
                widthInfoUD[TapppContext.Request.VALUE] = "100"
                internalPaneldata[TapppContext.Request.WIDTH] = widthInfoUD
            }
        } else {
            var widthInfoUD = [String: Any]()
            widthInfoUD[TapppContext.Request.UNIT] = "%"
            widthInfoUD[TapppContext.Request.VALUE] = "100"
            internalPaneldata[TapppContext.Request.WIDTH] = widthInfoUD
        }

        // Return invalid with all missingKeys if any missing values are found
        if !missingKeys.isEmpty {
            return .invalid(missingKeys.joined(separator: ", "))
        }

        objectPanelData[TapppContext.Sports.Context] = internalPaneldata
        return .valid
    }

    public func exceptionHandleHTML(errMsg: String) {
        // FIXME: need to setup for duplicate width key.
    }
}

// MARK: - GraphQL APIs.

extension BaseClass {
    public func getGameAwards(inputURL: String) {
        let url = URL(string: inputURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: url!) { data, _, error in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let status = json?["code"] as? Int, status == 200 {
                        if let urlDict = json?["data"] as? [[String: Any]], let urlAddr = urlDict.first {
                            // self.playVideo()
                        }
                    }
                } catch {
                    // TODO: add error delegate so reference app knows ( completed )
                    let domainString = "JSON Parsing Error: \(error.localizedDescription)"
                    let error = NSError(domain: domainString, code: 0, userInfo: nil)
                    self.errorDelegate?.handleError(error)
                }
                // let image = UIImage(data: data)
            } else if let error = error {
                // TODO: add error delegate so reference app knows ( completed )
                let domainString = "HTTP Request Failed: \(error.localizedDescription)"
                let error = NSError(domain: domainString, code: 0, userInfo: nil)
                self.errorDelegate?.handleError(error)
            }
        }
        task.resume()
    }

    public func geRegistryServiceDetail(inputURL: String, completion: @escaping (String?) -> Void, completion2: @escaping ([String: Any]?) -> Void, completion3: @escaping (Bool) -> Void, completion4: @escaping ([String: Any]?) -> Void) {
        let url = URL(string: inputURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: url!) { data, _, error in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let status = json?["code"] as? Int, status == 200 {
                        if let urlDict = json?["data"] as? [[String: Any]], let urlAddr = urlDict.first {
                            let appDict = urlAddr["appInfo"] as? [String: Any]

                            if let appdict = appDict as? [String: Any] {
                                completion4(appdict as? [String: Any])
                            }

                            if let defaultValue = appDict?["defaultValues"] as? [String: Any] {
                                completion2(defaultValue as? [String: Any])
                            }

                            if let isDefaultValue = appDict?["isDefaultValueEnabled"] {
                                print("isDefaultValueEnabled1:- ", isDefaultValue)
                                completion3(isDefaultValue as! Bool)
                            }

                            let microAppList = appDict?["microAppList"] as? [[String: Any]]

                            let iconURL = appDict?["iconMinimize"] as? String
                            if !iconURL!.isEmpty {
                                self.setImageFromStringrURL(stringUrl: iconURL!)
                            }

                            for microApp in microAppList! {
                                if let chanelList = microApp["chanelList"] as? [[String: Any]], microApp["appId"] as? String == TapppContext.AppInfo.APP_ID_FMG {
                                    for channel in chanelList {
                                        if let channelName = channel["chanelName"] as? String, channelName == TapppContext.DeviceInfo.SMART_APP {
                                            if let appURL = channel["appURL"] as? String {
                                                completion(appURL)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else if let status = json?["code"] as? Int, status == 404 {
                        // TODO: add error delegate so reference app knows ( completed )

                        if let errorMessage = json?["message"] as? String {
                            let domainString = "app info error: \(errorMessage)"
                            let error = NSError(domain: domainString, code: 0, userInfo: nil)
                            self.errorDelegate?.handleError(error)
                        }
                    }
                } catch {
                    // TODO: add error delegate so reference app knows ( completed )
                    print(error)
                    let domainString = "JSON Parsing Error: \(error.localizedDescription)"
                    let error = NSError(domain: domainString, code: 0, userInfo: nil)
                    self.errorDelegate?.handleError(error)
                }
                // let image = UIImage(data: data)
            } else if let error = error {
                // TODO: add error delegate so reference app knows ( completed )
                let domainString = "HTTP Request Failed: \(error.localizedDescription)"
                let error = NSError(domain: domainString, code: 0, userInfo: nil)
                self.errorDelegate?.handleError(error)
            }
        }
        task.resume()
    }

    func setImageFromStringrURL(stringUrl: String) {
        if let url = URL(string: stringUrl) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                // Error handling...
                guard let imageData = data else { return }

                DispatchQueue.main.async {
                    self.btnInfo.setImage(UIImage(data: imageData), for: .normal)
                }
            }.resume()
        }
    }
}

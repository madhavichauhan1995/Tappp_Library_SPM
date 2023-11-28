import Foundation
import UIKit

public class TapppContext {
    public static let CURRENT_DEVICE = UIDevice.current.model
    public static let CURRENTDEVICE_SIZE = UIScreen.main.bounds.size
    public static let CURRENT_OS_VERSION = UIDevice.current.systemVersion
    public static let USERDEFAULTS = UserDefaults.standard
    public static let GLOBAL_LANG = "en"
    public static let GLOBAL_POSITION = "topRight"

    public init() {}

    public struct Environment {
        public static let PROD = "prod"
        public static let STAGE = "stage"
        public static let TEST = "test"
        public static let DEV = "dev"
        public static let ENVIRONMENT = "env"
        public static let SANDBOX = "sandbox"
    }

    public struct Sports {
        public static let GAME_ID = "gameId"
        public static let BROADCASTER_NAME = "broadcasterName"
        public static let TRN = "TRN"
        public static let NFL = "NFL"
        public static let Context = "gameInfo"
        public static let BOOK_ID = "bookId"
        public static let DEVICE = "device"
        public static let JWT_GAME_INFO = "jwtGameInfo"
        public static let CHANNEL_ID = "channelId"
    }

    public struct User {
        public static let USER_ID = "userId"
        public static let USER_AUTHN_TOKEN = "USER_AUTHN_TOKEN"
    }

    public struct Request {
        public static let WIDTH = "width"
        public static let VALUE = "value"
        public static let LANGUAGE = "lang"
        public static let WIDTH_VALUE = "widthValue"

        public static let CONTEST_ID = "contest_id"
        public static let OFFER_ID = "offer_id"
        public static let OUTCOME_ID = "outcome_id"

        public static let POSITION = "position"
        public static let UNIT = "unit"
        public static let PANELMULTIPLIER = "panelSizeMultiplier"
        public static let UNIT_VAL = "px"
        public static let ENCODED_REQUEST = "encodedRequest"
    }

    public struct ErrorMessage {
        public static let GAMESETTING_OBJECT_NOT_FOUND = "Panel Settings not found"
        public static let PANEL_INFO_OBJECT_NOT_FOUND = "Panel Data not found"
        public static let GAMEINFO_OBJECT_NOT_FOUND = "GameInfo object not found"
        public static let GAMEID_NOT_FOUND = "GameId not found"
        public static let GAMEID_NULL_EMPTY = "GameId null or empty"
        public static let USERID_NOT_FOUND = "UserId not found"
        public static let USERID_NULL_EMPTY = "UserId null or empty"
        public static let BOOKID_NOT_FOUND = "BookId not found"
        public static let BOOKID_NULL_EMPTY = "BookId null or empty"
        public static let WIDTH_OBJECT_NOT_FOUND = "Width object not found"
        public static let WIDTH_IS_ZERO = "Width value is zero(0)"
        public static let DEVICE_NOT_FOUND = "Device type not found"
        public static let DEVICE_NULL_EMPTY = "Device type is null or empty"
        public static let ENVIRONMENT_NOT_FOUND = "Environment not found"
        public static let ENVIRONMENT_NULL_EMPTY = "Environment null or empty"
        public static let BROADCASTERNAME_NOT_FOUND = "Broadcaster Name not found"
        public static let BROADCASTERNAME_NULL_EMPTY = "Broadcaster Name null or empty"
    }

    public struct ActionState {
        public static let OPEN = "OPEN"
        public static let CLOSE = "CLOSE"
        public static let MINIMIZE = "MINIMIZE"
        public static let MAXIMIZE = "MAXIMIZE"
    }

    public struct AppInfo {
        public static let APP_VERSION = "appVersion"
        public static let MINIMIZE_ICON = "MINIMIZE_ICON"
        public static let APP_VERSION_VALUE = "1.1"

        public static let APP_ID_FMG = "FMG"
        public static let APP_ID_RMG = "RMG"
    }

    public struct DeviceInfo {
        public static let SMART_APP = "smartApp"
        public static let DEVICE = "device"
        public static let DEVICE_TYPE = "deviceType"
        public static let WEB = "web"
        public static let WEBAPP = "webApp"
        public static let iPhone = "iPhone"
        public static let iPad = "iPad"
    }
}

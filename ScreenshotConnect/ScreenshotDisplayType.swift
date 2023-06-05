//
//  ScreenshotDisplayType.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 03.06.23.
//

import Foundation

// From: https://developer.apple.com/documentation/appstoreconnectapi/screenshotdisplaytype
enum ScreenshotDisplayType: String, Codable, Hashable {
    case iPhone67 = "APP_IPHONE_67"
    case iPhone65 = "APP_IPHONE_65"
    case iPhone61 = "APP_IPHONE_61"
    case iPhone58 = "APP_IPHONE_58"
    case iPhone55 = "APP_IPHONE_55"
    case iPhone47 = "APP_IPHONE_47"
    case iPhone40 = "APP_IPHONE_40"
    case iPhone35 = "APP_IPHONE_35"
    case iPadPro3Gen129 = "APP_IPAD_PRO_3GEN_129"
    case iPadPro3Gen11 = "APP_IPAD_PRO_3GEN_11"
    case iPadPro129 = "APP_IPAD_PRO_129"
    case iPad105 = "APP_IPAD_105"
    case iPad97 = "APP_IPAD_97"
    case watchUltra = "APP_WATCH_ULTRA"
    case watch7 = "APP_WATCH_SERIES_7"
    case watch4 = "APP_WATCH_SERIES_4"
    case watch3 = "APP_WATCH_SERIES_3"
    case desktop = "APP_DESKTOP"
    case appleTV = "APP_APPLE_TV"
    case iMessageIPhone67 = "IMESSAGE_APP_IPHONE_67"
    case iMessageIPhone65 = "IMESSAGE_APP_IPHONE_65"
    case iMessageIPhone61 = "IMESSAGE_APP_IPHONE_61"
    case iMessageIPhone58 = "IMESSAGE_APP_IPHONE_58"
    case iMessageIPhone55 = "IMESSAGE_APP_IPHONE_55"
    case iMessageIPhone47 = "IMESSAGE_APP_IPHONE_47"
    case iMessageIPhone40 = "IMESSAGE_APP_IPHONE_40"
    case iMessageIPadPro3Gen129 = "IMESSAGE_APP_IPAD_PRO_3GEN_129"
    case iMessageIPadPro3Gen11 = "IMESSAGE_APP_IPAD_PRO_3GEN_11"
    case iMessageIPadPro129 = "IMESSAGE_APP_IPAD_PRO_129"
    case iMessageIPad105 = "IMESSAGE_APP_IPAD_105"
    case iMessageIPad97 = "IMESSAGE_APP_IPAD_97"
    
    var displayName: String {
        switch self {
        case .iPhone67:
            return "iPhone 6.7\" Display"
        case .iPhone65:
            return "iPhone 6.5\" Display"
        case .iPhone61:
            return "iPhone 6.1\" Display"
        case .iPhone58:
            return "iPhone 5.8\" Display"
        case .iPhone55:
            return "iPhone 5.5\" Display"
        case .iPhone47:
            return "iPhone 4.7\" Display"
        case .iPhone40:
            return "iPhone 4.0\" Display"
        case .iPhone35:
            return "iPhone 3.5\" Display"
        case .iPadPro3Gen129:
            return "iPad Pro 12.9\" Display (from 3rd generation)"
        case .iPadPro3Gen11:
            return "iPad Pro 11\" Display (from 3rd generation)"
        case .iPadPro129:
            return "iPad Pro 12.9\" Display (up to 2nd generation)"
        case .iPad105:
            return "iPad 10.5\" Display"
        case .iPad97:
            return "iPad 9.7\" Display"
        case .watchUltra:
            return "Apple Watch Ultra"
        case .watch7:
            return "Apple Watch 7+"
        case .watch4:
            return "Apple Watch 4-6"
        case .watch3:
            return "Apple Watch 3"
        case .desktop:
            return "Desktop"
        case .appleTV:
            return "Apple TV"
        case .iMessageIPhone67:
            return "iMessage on " + Self.iPhone67.displayName
        case .iMessageIPhone65:
            return "iMessage on " + Self.iPhone65.displayName
        case .iMessageIPhone61:
            return "iMessage on " + Self.iPhone61.displayName
        case .iMessageIPhone58:
            return "iMessage on " + Self.iPhone58.displayName
        case .iMessageIPhone55:
            return "iMessage on " + Self.iPhone55.displayName
        case .iMessageIPhone47:
            return "iMessage on " + Self.iPhone47.displayName
        case .iMessageIPhone40:
            return "iMessage on " + Self.iPhone40.displayName
        case .iMessageIPadPro3Gen129:
            return "iMessage on " + Self.iPadPro3Gen129.displayName
        case .iMessageIPadPro3Gen11:
            return "iMessage on " + Self.iPadPro3Gen11.displayName
        case .iMessageIPadPro129:
            return "iMessage on " + Self.iPadPro129.displayName
        case .iMessageIPad105:
            return "iMessage on " + Self.iPad105.displayName
        case .iMessageIPad97:
            return "iMessage on " + Self.iPad97.displayName
        }
    }
}

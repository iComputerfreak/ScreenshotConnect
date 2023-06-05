//
//  Preferences.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 05.06.23.
//

import Foundation
import Combine

final class Preferences {
    
    static let standard = Preferences(userDefaults: .standard)
    fileprivate let userDefaults: UserDefaults
    
    /// Sends through the changed key path whenever a change occurs.
    var preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    @UserDefault("issuerID")
    var issuerID: String = ""
    @UserDefault("privateKeyID")
    var privateKeyID: String = ""
    @UserDefault("privateKey")
    var privateKey: Data = .init()
    @UserDefault("devices")
    var devices: [Device] = [
        Device(name: "iPhone 8 Plus", screenshotDisplayType: .iPhone55),
        Device(name: "iPhone 11 Pro", screenshotDisplayType: .iPhone65),
        Device(name: "iPad Pro (12.9-inch) (2nd generation)", screenshotDisplayType: .iPadPro129),
        Device(name: "iPad Pro (12.9-inch) (6th generation)", screenshotDisplayType: .iPadPro3Gen129),
    ]
}

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        get { fatalError("Wrapped value should not be used.") }
        set { fatalError("Wrapped value should not be used.") }
    }
    
    init(wrappedValue: Value, _ key: String) {
        self.defaultValue = wrappedValue
        self.key = key
    }
    
    public static subscript(
        _enclosingInstance instance: Preferences,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Preferences, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<Preferences, Self>
    ) -> Value {
        get {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            let defaultValue = instance[keyPath: storageKeyPath].defaultValue
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            container.set(newValue, forKey: key)
            instance.preferencesChangedSubject.send(wrappedKeyPath)
        }
    }
}

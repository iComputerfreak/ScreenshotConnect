//
//  PublisherObservableObject.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 05.06.23.
//

import Combine

final class PublisherObservableObject: ObservableObject {
    
    var subscriber: AnyCancellable?
    
    init(publisher: AnyPublisher<Void, Never>) {
        subscriber = publisher.sink(receiveValue: { [weak self] _ in
            self?.objectWillChange.send()
        })
    }
}

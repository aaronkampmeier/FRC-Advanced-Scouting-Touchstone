////
////  EventSelector.swift
////  FRC Advanced Scouting Touchstone
////
////  Created by Aaron Kampmeier on 7/17/19.
////  Copyright © 2019 Kampfire Technologies. All rights reserved.
////
//
//import SwiftUI
//import Combine
//import AWSAppSync
//

//
//@available(iOS 13.0.0, *)
//struct EventSelector : View {
//    @ObservedObject var eventModel: EventSelectorModel
//    
//    var body: some View {
//        List(eventModel.events, id: \.eventKey) {event in
//            EventSelectorRow(eventInfo: event)
//                .tapAction {
//                    NotificationCenter.default.post(name: .FASTSelectedEventChanged, object: self, userInfo: ["eventKey":event.eventKey])
//                    
//            }
//        }
//        
////        List {
////
////            ForEach(eventModel.events, id: \.eventKey) {event in
////                EventSelectorRow(eventInfo: event)
////            }
////
////            HStack {
////                Text("Add Event")
////                Image("plus.circle")
////            }
////        }
//    }
//}
//
//#if DEBUG
//@available(iOS 13.0.0, *)
//struct EventSelector_Previews : PreviewProvider {
//    
//    static var previews: some View {
//        let model = EventSelectorModel(previewOverrideData: [ListTrackedEventsQuery.Data.ListTrackedEvent(eventKey: "2020mosl", eventName: "St. Louis Champ"), ListTrackedEventsQuery.Data.ListTrackedEvent(eventKey: "2020alin", eventName: "Area 51 Champ"), ListTrackedEventsQuery.Data.ListTrackedEvent(eventKey: "2020aztp", eventName: "Tempe Champ")])
//        
//        return Group {
//           EventSelector(eventModel: model)
//            .previewLayout(.fixed(width: 320, height: 400))
//            
//            EventSelector(eventModel: model)
//                .previewLayout(.fixed(width: 320, height: 400))
//                .colorScheme(.dark)
//        }
//    }
//}
//#endif
//
//@available(iOS 13.0, *)
//class EventSelectorModel: ObservedObject {
//    var willChange: PassthroughSubject<Void, Never>
//    
//    typealias PublisherType = PassthroughSubject<Void, Never>
//    
//    public var didChange: PassthroughSubject<Void, Never>
//    
//    var events: [ListTrackedEventsQuery.Data.ListTrackedEvent] = [] {
//        willSet {
//            willChange.send()
//        }
//        didSet {
//            didChange.send()
//        }
//    }
//    var currentEvent: String?
//    var chosenEvent: String?
//    
//    private var trackedEventsWatcher: GraphQLQueryWatcher<ListTrackedEventsQuery>?
//    
//    init(previewOverrideData: [ListTrackedEventsQuery.Data.ListTrackedEvent]) {
//        didChange = PassthroughSubject<Void, Never>()
//        
//        events = previewOverrideData
//        
//        willChange = PassthroughSubject<Void, Never>()
//    }
//    
//    init() {
//        didChange = PassthroughSubject<Void, Never>()
//        willChange = PassthroughSubject<Void, Never>()
//        
//        //Load all the events
//        trackedEventsWatcher = Globals.appDelegate.appSyncClient?.watch(query: ListTrackedEventsQuery(), cachePolicy: .returnCacheDataElseFetch, queue: DispatchQueue.global(qos: .userInteractive)) {[weak self] result, error in
//            DispatchQueue.main.async {
//                if Globals.handleAppSyncErrors(forQuery: "ListTrackedEventsQuery", result: result, error: error) {
//                    self?.events = result?.data?.listTrackedEvents?.map({ $0 ?? ListTrackedEventsQuery.Data.ListTrackedEvent(eventKey: "", eventName: "")
//                    }) ?? []
//                } else {
//                    
//                }
//            }
//        }
//        
//    }
//    
//    deinit {
//        trackedEventsWatcher?.cancel()
//    }
//}

//
//  EventSelectorRow.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 7/17/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct EventSelectorRow : View {
    var eventInfo: ListTrackedEventsQuery.Data.ListTrackedEvent
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(eventInfo.eventName)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(eventInfo.eventKey.trimmingCharacters(in: CharacterSet.letters))
                .font(.subheadline)
                .fontWeight(.light)
                .color(Color.secondary)
        }
    }
}

#if DEBUG
@available(iOS 13.0, *)
struct EventSelectorRow_Previews : PreviewProvider {
    static var previews: some View {
        EventSelectorRow(eventInfo: ListTrackedEventsQuery.Data.ListTrackedEvent(eventKey: "2020mosl", eventName: "St. Louis Champ"))
        .previewLayout(.fixed(width: 300, height: 44))
    }
}
#endif

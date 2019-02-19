//  This file was automatically generated and should not be edited.

import AWSAppSync

public enum CompetitionLevel: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case qm
  case ef
  case qf
  case sf
  case f
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "qm": self = .qm
      case "ef": self = .ef
      case "qf": self = .qf
      case "sf": self = .sf
      case "f": self = .f
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .qm: return "qm"
      case .ef: return "ef"
      case .qf: return "qf"
      case .sf: return "sf"
      case .f: return "f"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: CompetitionLevel, rhs: CompetitionLevel) -> Bool {
    switch (lhs, rhs) {
      case (.qm, .qm): return true
      case (.ef, .ef): return true
      case (.qf, .qf): return true
      case (.sf, .sf): return true
      case (.f, .f): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct TimeMarkerInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(event: String, time: Double, subOption: String? = nil) {
    graphQLMap = ["event": event, "time": time, "subOption": subOption]
  }

  public var event: String {
    get {
      return graphQLMap["event"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "event")
    }
  }

  public var time: Double {
    get {
      return graphQLMap["time"] as! Double
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "time")
    }
  }

  public var subOption: String? {
    get {
      return graphQLMap["subOption"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "subOption")
    }
  }
}

public final class AddTrackedEventMutation: GraphQLMutation {
  public static let operationString =
    "mutation AddTrackedEvent($eventKey: ID!) {\n  addTrackedEvent(eventKey: $eventKey) {\n    __typename\n    ...EventRanking\n  }\n}"

  public static var requestString: String { return operationString.appending(EventRanking.fragmentString) }

  public var eventKey: GraphQLID

  public init(eventKey: GraphQLID) {
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("addTrackedEvent", arguments: ["eventKey": GraphQLVariable("eventKey")], type: .object(AddTrackedEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(addTrackedEvent: AddTrackedEvent? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "addTrackedEvent": addTrackedEvent.flatMap { $0.snapshot }])
    }

    public var addTrackedEvent: AddTrackedEvent? {
      get {
        return (snapshot["addTrackedEvent"] as? Snapshot).flatMap { AddTrackedEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "addTrackedEvent")
      }
    }

    public struct AddTrackedEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["EventRanking"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventName", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String, userId: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "userID": userId, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var eventName: String {
        get {
          return snapshot["eventName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventName")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var rankedTeams: [RankedTeam?]? {
        get {
          return (snapshot["rankedTeams"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { RankedTeam(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "rankedTeams")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var eventRanking: EventRanking {
          get {
            return EventRanking(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct RankedTeam: GraphQLSelectionSet {
        public static let possibleTypes = ["RankedTeam"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
          GraphQLField("isPicked", type: .nonNull(.scalar(Bool.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(teamKey: String, isPicked: Bool) {
          self.init(snapshot: ["__typename": "RankedTeam", "teamKey": teamKey, "isPicked": isPicked])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var teamKey: String {
          get {
            return snapshot["teamKey"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "teamKey")
          }
        }

        public var isPicked: Bool {
          get {
            return snapshot["isPicked"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "isPicked")
          }
        }
      }
    }
  }
}

public final class RemoveTrackedEventMutation: GraphQLMutation {
  public static let operationString =
    "mutation RemoveTrackedEvent($eventKey: ID!) {\n  removeTrackedEvent(eventKey: $eventKey) {\n    __typename\n    eventKey\n    userID\n  }\n}"

  public var eventKey: GraphQLID

  public init(eventKey: GraphQLID) {
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeTrackedEvent", arguments: ["eventKey": GraphQLVariable("eventKey")], type: .object(RemoveTrackedEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(removeTrackedEvent: RemoveTrackedEvent? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "removeTrackedEvent": removeTrackedEvent.flatMap { $0.snapshot }])
    }

    public var removeTrackedEvent: RemoveTrackedEvent? {
      get {
        return (snapshot["removeTrackedEvent"] as? Snapshot).flatMap { RemoveTrackedEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "removeTrackedEvent")
      }
    }

    public struct RemoveTrackedEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["EventDeletion"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: GraphQLID, userId: GraphQLID) {
        self.init(snapshot: ["__typename": "EventDeletion", "eventKey": eventKey, "userID": userId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var eventKey: GraphQLID {
        get {
          return snapshot["eventKey"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }
    }
  }
}

public final class MoveRankedTeamMutation: GraphQLMutation {
  public static let operationString =
    "mutation MoveRankedTeam($eventKey: ID!, $teamKey: ID!, $toIndex: Int!) {\n  moveRankedTeam(eventKey: $eventKey, teamKey: $teamKey, toIndex: $toIndex) {\n    __typename\n    ...EventRanking\n  }\n}"

  public static var requestString: String { return operationString.appending(EventRanking.fragmentString) }

  public var eventKey: GraphQLID
  public var teamKey: GraphQLID
  public var toIndex: Int

  public init(eventKey: GraphQLID, teamKey: GraphQLID, toIndex: Int) {
    self.eventKey = eventKey
    self.teamKey = teamKey
    self.toIndex = toIndex
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey, "teamKey": teamKey, "toIndex": toIndex]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("moveRankedTeam", arguments: ["eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey"), "toIndex": GraphQLVariable("toIndex")], type: .object(MoveRankedTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(moveRankedTeam: MoveRankedTeam? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "moveRankedTeam": moveRankedTeam.flatMap { $0.snapshot }])
    }

    public var moveRankedTeam: MoveRankedTeam? {
      get {
        return (snapshot["moveRankedTeam"] as? Snapshot).flatMap { MoveRankedTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "moveRankedTeam")
      }
    }

    public struct MoveRankedTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["EventRanking"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventName", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String, userId: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "userID": userId, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var eventName: String {
        get {
          return snapshot["eventName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventName")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var rankedTeams: [RankedTeam?]? {
        get {
          return (snapshot["rankedTeams"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { RankedTeam(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "rankedTeams")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var eventRanking: EventRanking {
          get {
            return EventRanking(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct RankedTeam: GraphQLSelectionSet {
        public static let possibleTypes = ["RankedTeam"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
          GraphQLField("isPicked", type: .nonNull(.scalar(Bool.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(teamKey: String, isPicked: Bool) {
          self.init(snapshot: ["__typename": "RankedTeam", "teamKey": teamKey, "isPicked": isPicked])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var teamKey: String {
          get {
            return snapshot["teamKey"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "teamKey")
          }
        }

        public var isPicked: Bool {
          get {
            return snapshot["isPicked"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "isPicked")
          }
        }
      }
    }
  }
}

public final class SetTeamPickedMutation: GraphQLMutation {
  public static let operationString =
    "mutation SetTeamPicked($eventKey: ID!, $teamKey: ID!, $isPicked: Boolean!) {\n  setTeamPicked(eventKey: $eventKey, teamKey: $teamKey, isPicked: $isPicked) {\n    __typename\n    ...EventRanking\n  }\n}"

  public static var requestString: String { return operationString.appending(EventRanking.fragmentString) }

  public var eventKey: GraphQLID
  public var teamKey: GraphQLID
  public var isPicked: Bool

  public init(eventKey: GraphQLID, teamKey: GraphQLID, isPicked: Bool) {
    self.eventKey = eventKey
    self.teamKey = teamKey
    self.isPicked = isPicked
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey, "teamKey": teamKey, "isPicked": isPicked]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("setTeamPicked", arguments: ["eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey"), "isPicked": GraphQLVariable("isPicked")], type: .object(SetTeamPicked.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(setTeamPicked: SetTeamPicked? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "setTeamPicked": setTeamPicked.flatMap { $0.snapshot }])
    }

    public var setTeamPicked: SetTeamPicked? {
      get {
        return (snapshot["setTeamPicked"] as? Snapshot).flatMap { SetTeamPicked(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "setTeamPicked")
      }
    }

    public struct SetTeamPicked: GraphQLSelectionSet {
      public static let possibleTypes = ["EventRanking"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventName", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String, userId: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "userID": userId, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var eventName: String {
        get {
          return snapshot["eventName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventName")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var rankedTeams: [RankedTeam?]? {
        get {
          return (snapshot["rankedTeams"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { RankedTeam(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "rankedTeams")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var eventRanking: EventRanking {
          get {
            return EventRanking(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct RankedTeam: GraphQLSelectionSet {
        public static let possibleTypes = ["RankedTeam"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
          GraphQLField("isPicked", type: .nonNull(.scalar(Bool.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(teamKey: String, isPicked: Bool) {
          self.init(snapshot: ["__typename": "RankedTeam", "teamKey": teamKey, "isPicked": isPicked])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var teamKey: String {
          get {
            return snapshot["teamKey"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "teamKey")
          }
        }

        public var isPicked: Bool {
          get {
            return snapshot["isPicked"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "isPicked")
          }
        }
      }
    }
  }
}

public final class UpdateScoutedTeamMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateScoutedTeam($eventKey: ID!, $teamKey: ID!, $attributes: AWSJSON!) {\n  updateScoutedTeam(eventKey: $eventKey, teamKey: $teamKey, attributes: $attributes) {\n    __typename\n    ...ScoutedTeam\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutedTeam.fragmentString) }

  public var eventKey: GraphQLID
  public var teamKey: GraphQLID
  public var attributes: String

  public init(eventKey: GraphQLID, teamKey: GraphQLID, attributes: String) {
    self.eventKey = eventKey
    self.teamKey = teamKey
    self.attributes = attributes
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey, "teamKey": teamKey, "attributes": attributes]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateScoutedTeam", arguments: ["eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey"), "attributes": GraphQLVariable("attributes")], type: .object(UpdateScoutedTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateScoutedTeam: UpdateScoutedTeam? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateScoutedTeam": updateScoutedTeam.flatMap { $0.snapshot }])
    }

    public var updateScoutedTeam: UpdateScoutedTeam? {
      get {
        return (snapshot["updateScoutedTeam"] as? Snapshot).flatMap { UpdateScoutedTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateScoutedTeam")
      }
    }

    public struct UpdateScoutedTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutedTeam"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("attributes", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamKey: GraphQLID, userId: GraphQLID, eventKey: String, attributes: String? = nil) {
        self.init(snapshot: ["__typename": "ScoutedTeam", "teamKey": teamKey, "userID": userId, "eventKey": eventKey, "attributes": attributes])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var teamKey: GraphQLID {
        get {
          return snapshot["teamKey"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var attributes: String? {
        get {
          return snapshot["attributes"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "attributes")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var scoutedTeam: ScoutedTeam {
          get {
            return ScoutedTeam(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class CreateScoutSessionMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateScoutSession($eventKey: ID!, $teamKey: ID!, $matchKey: ID!, $startState: AWSJSON!, $endState: AWSJSON!, $timeMarkers: [TimeMarkerInput]!) {\n  createScoutSession(eventKey: $eventKey, teamKey: $teamKey, matchKey: $matchKey, startState: $startState, endState: $endState, timeMarkers: $timeMarkers) {\n    __typename\n    ...ScoutSession\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutSession.fragmentString).appending(TimeMarkerFragment.fragmentString) }

  public var eventKey: GraphQLID
  public var teamKey: GraphQLID
  public var matchKey: GraphQLID
  public var startState: String
  public var endState: String
  public var timeMarkers: [TimeMarkerInput?]

  public init(eventKey: GraphQLID, teamKey: GraphQLID, matchKey: GraphQLID, startState: String, endState: String, timeMarkers: [TimeMarkerInput?]) {
    self.eventKey = eventKey
    self.teamKey = teamKey
    self.matchKey = matchKey
    self.startState = startState
    self.endState = endState
    self.timeMarkers = timeMarkers
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey, "teamKey": teamKey, "matchKey": matchKey, "startState": startState, "endState": endState, "timeMarkers": timeMarkers]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createScoutSession", arguments: ["eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey"), "matchKey": GraphQLVariable("matchKey"), "startState": GraphQLVariable("startState"), "endState": GraphQLVariable("endState"), "timeMarkers": GraphQLVariable("timeMarkers")], type: .object(CreateScoutSession.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createScoutSession: CreateScoutSession? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createScoutSession": createScoutSession.flatMap { $0.snapshot }])
    }

    public var createScoutSession: CreateScoutSession? {
      get {
        return (snapshot["createScoutSession"] as? Snapshot).flatMap { CreateScoutSession(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createScoutSession")
      }
    }

    public struct CreateScoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("matchKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("startState", type: .scalar(String.self)),
        GraphQLField("endState", type: .scalar(String.self)),
        GraphQLField("timeMarkers", type: .list(.object(TimeMarker.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, matchKey: String, teamKey: String, userId: GraphQLID, eventKey: String, startState: String? = nil, endState: String? = nil, timeMarkers: [TimeMarker?]? = nil) {
        self.init(snapshot: ["__typename": "ScoutSession", "key": key, "matchKey": matchKey, "teamKey": teamKey, "userID": userId, "eventKey": eventKey, "startState": startState, "endState": endState, "timeMarkers": timeMarkers.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var matchKey: String {
        get {
          return snapshot["matchKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "matchKey")
        }
      }

      public var teamKey: String {
        get {
          return snapshot["teamKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var startState: String? {
        get {
          return snapshot["startState"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "startState")
        }
      }

      public var endState: String? {
        get {
          return snapshot["endState"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "endState")
        }
      }

      public var timeMarkers: [TimeMarker?]? {
        get {
          return (snapshot["timeMarkers"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { TimeMarker(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "timeMarkers")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var scoutSession: ScoutSession {
          get {
            return ScoutSession(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct TimeMarker: GraphQLSelectionSet {
        public static let possibleTypes = ["TimeMarker"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("event", type: .nonNull(.scalar(String.self))),
          GraphQLField("time", type: .nonNull(.scalar(Double.self))),
          GraphQLField("subOption", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(event: String, time: Double, subOption: String? = nil) {
          self.init(snapshot: ["__typename": "TimeMarker", "event": event, "time": time, "subOption": subOption])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var event: String {
          get {
            return snapshot["event"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "event")
          }
        }

        public var time: Double {
          get {
            return snapshot["time"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "time")
          }
        }

        public var subOption: String? {
          get {
            return snapshot["subOption"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "subOption")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var timeMarkerFragment: TimeMarkerFragment {
            get {
              return TimeMarkerFragment(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }
    }
  }
}

public final class RemoveScoutSessionMutation: GraphQLMutation {
  public static let operationString =
    "mutation RemoveScoutSession($eventKey: ID!, $key: ID!) {\n  removeScoutSession(eventKey: $eventKey, key: $key) {\n    __typename\n    key\n    userID\n    matchKey\n    teamKey\n    eventKey\n  }\n}"

  public var eventKey: GraphQLID
  public var key: GraphQLID

  public init(eventKey: GraphQLID, key: GraphQLID) {
    self.eventKey = eventKey
    self.key = key
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey, "key": key]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeScoutSession", arguments: ["eventKey": GraphQLVariable("eventKey"), "key": GraphQLVariable("key")], type: .object(RemoveScoutSession.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(removeScoutSession: RemoveScoutSession? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "removeScoutSession": removeScoutSession.flatMap { $0.snapshot }])
    }

    public var removeScoutSession: RemoveScoutSession? {
      get {
        return (snapshot["removeScoutSession"] as? Snapshot).flatMap { RemoveScoutSession(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "removeScoutSession")
      }
    }

    public struct RemoveScoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("matchKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, userId: GraphQLID, matchKey: String, teamKey: String, eventKey: String) {
        self.init(snapshot: ["__typename": "ScoutSession", "key": key, "userID": userId, "matchKey": matchKey, "teamKey": teamKey, "eventKey": eventKey])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var matchKey: String {
        get {
          return snapshot["matchKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "matchKey")
        }
      }

      public var teamKey: String {
        get {
          return snapshot["teamKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }
    }
  }
}

public final class AddTeamCommentMutation: GraphQLMutation {
  public static let operationString =
    "mutation AddTeamComment($eventKey: String!, $teamKey: String!, $body: String!, $author: String!) {\n  addTeamComment(eventKey: $eventKey, teamKey: $teamKey, body: $body, author: $author) {\n    __typename\n    ...TeamComment\n  }\n}"

  public static var requestString: String { return operationString.appending(TeamComment.fragmentString) }

  public var eventKey: String
  public var teamKey: String
  public var body: String
  public var author: String

  public init(eventKey: String, teamKey: String, body: String, author: String) {
    self.eventKey = eventKey
    self.teamKey = teamKey
    self.body = body
    self.author = author
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey, "teamKey": teamKey, "body": body, "author": author]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("addTeamComment", arguments: ["eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey"), "body": GraphQLVariable("body"), "author": GraphQLVariable("author")], type: .object(AddTeamComment.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(addTeamComment: AddTeamComment? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "addTeamComment": addTeamComment.flatMap { $0.snapshot }])
    }

    public var addTeamComment: AddTeamComment? {
      get {
        return (snapshot["addTeamComment"] as? Snapshot).flatMap { AddTeamComment(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "addTeamComment")
      }
    }

    public struct AddTeamComment: GraphQLSelectionSet {
      public static let possibleTypes = ["TeamComment"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("author", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("body", type: .nonNull(.scalar(String.self))),
        GraphQLField("datePosted", type: .nonNull(.scalar(Int.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(author: String, userId: GraphQLID, body: String, datePosted: Int, key: GraphQLID, teamKey: String, eventKey: String) {
        self.init(snapshot: ["__typename": "TeamComment", "author": author, "userID": userId, "body": body, "datePosted": datePosted, "key": key, "teamKey": teamKey, "eventKey": eventKey])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var author: String {
        get {
          return snapshot["author"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "author")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var body: String {
        get {
          return snapshot["body"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "body")
        }
      }

      public var datePosted: Int {
        get {
          return snapshot["datePosted"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "datePosted")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var teamKey: String {
        get {
          return snapshot["teamKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var teamComment: TeamComment {
          get {
            return TeamComment(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class RemoveTeamCommentMutation: GraphQLMutation {
  public static let operationString =
    "mutation RemoveTeamComment($eventKey: String!, $key: String!) {\n  removeTeamComment(eventKey: $eventKey, key: $key) {\n    __typename\n    key\n    userID\n  }\n}"

  public var eventKey: String
  public var key: String

  public init(eventKey: String, key: String) {
    self.eventKey = eventKey
    self.key = key
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey, "key": key]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeTeamComment", arguments: ["eventKey": GraphQLVariable("eventKey"), "key": GraphQLVariable("key")], type: .object(RemoveTeamComment.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(removeTeamComment: RemoveTeamComment? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "removeTeamComment": removeTeamComment.flatMap { $0.snapshot }])
    }

    public var removeTeamComment: RemoveTeamComment? {
      get {
        return (snapshot["removeTeamComment"] as? Snapshot).flatMap { RemoveTeamComment(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "removeTeamComment")
      }
    }

    public struct RemoveTeamComment: GraphQLSelectionSet {
      public static let possibleTypes = ["TeamComment"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, userId: GraphQLID) {
        self.init(snapshot: ["__typename": "TeamComment", "key": key, "userID": userId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }
    }
  }
}

public final class ListTrackedEventsQuery: GraphQLQuery {
  public static let operationString =
    "query ListTrackedEvents {\n  listTrackedEvents {\n    __typename\n    eventKey\n    eventName\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listTrackedEvents", type: .list(.object(ListTrackedEvent.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listTrackedEvents: [ListTrackedEvent?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listTrackedEvents": listTrackedEvents.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    public var listTrackedEvents: [ListTrackedEvent?]? {
      get {
        return (snapshot["listTrackedEvents"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListTrackedEvent(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listTrackedEvents")
      }
    }

    public struct ListTrackedEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["EventRanking"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventName", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var eventName: String {
        get {
          return snapshot["eventName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventName")
        }
      }
    }
  }
}

public final class GetEventRankingQuery: GraphQLQuery {
  public static let operationString =
    "query GetEventRanking($key: ID!) {\n  getEventRanking(key: $key) {\n    __typename\n    ...EventRanking\n  }\n}"

  public static var requestString: String { return operationString.appending(EventRanking.fragmentString) }

  public var key: GraphQLID

  public init(key: GraphQLID) {
    self.key = key
  }

  public var variables: GraphQLMap? {
    return ["key": key]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getEventRanking", arguments: ["key": GraphQLVariable("key")], type: .object(GetEventRanking.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getEventRanking: GetEventRanking? = nil) {
      self.init(snapshot: ["__typename": "Query", "getEventRanking": getEventRanking.flatMap { $0.snapshot }])
    }

    public var getEventRanking: GetEventRanking? {
      get {
        return (snapshot["getEventRanking"] as? Snapshot).flatMap { GetEventRanking(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getEventRanking")
      }
    }

    public struct GetEventRanking: GraphQLSelectionSet {
      public static let possibleTypes = ["EventRanking"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventName", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String, userId: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "userID": userId, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var eventName: String {
        get {
          return snapshot["eventName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventName")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var rankedTeams: [RankedTeam?]? {
        get {
          return (snapshot["rankedTeams"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { RankedTeam(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "rankedTeams")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var eventRanking: EventRanking {
          get {
            return EventRanking(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct RankedTeam: GraphQLSelectionSet {
        public static let possibleTypes = ["RankedTeam"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
          GraphQLField("isPicked", type: .nonNull(.scalar(Bool.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(teamKey: String, isPicked: Bool) {
          self.init(snapshot: ["__typename": "RankedTeam", "teamKey": teamKey, "isPicked": isPicked])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var teamKey: String {
          get {
            return snapshot["teamKey"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "teamKey")
          }
        }

        public var isPicked: Bool {
          get {
            return snapshot["isPicked"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "isPicked")
          }
        }
      }
    }
  }
}

public final class ListAvailableEventsQuery: GraphQLQuery {
  public static let operationString =
    "query ListAvailableEvents($year: String) {\n  listAvailableEvents(year: $year) {\n    __typename\n    ...Event\n  }\n}"

  public static var requestString: String { return operationString.appending(Event.fragmentString) }

  public var year: String?

  public init(year: String? = nil) {
    self.year = year
  }

  public var variables: GraphQLMap? {
    return ["year": year]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listAvailableEvents", arguments: ["year": GraphQLVariable("year")], type: .list(.object(ListAvailableEvent.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listAvailableEvents: [ListAvailableEvent?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listAvailableEvents": listAvailableEvents.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    public var listAvailableEvents: [ListAvailableEvent?]? {
      get {
        return (snapshot["listAvailableEvents"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListAvailableEvent(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listAvailableEvents")
      }
    }

    public struct ListAvailableEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("event_code", type: .nonNull(.scalar(String.self))),
        GraphQLField("event_type", type: .nonNull(.scalar(Int.self))),
        GraphQLField("event_type_string", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("address", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("location_name", type: .scalar(String.self)),
        GraphQLField("short_name", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventCode: String, eventType: Int, eventTypeString: String, key: GraphQLID, address: String? = nil, name: String, year: Int, website: String? = nil, locationName: String? = nil, shortName: String? = nil) {
        self.init(snapshot: ["__typename": "Event", "event_code": eventCode, "event_type": eventType, "event_type_string": eventTypeString, "key": key, "address": address, "name": name, "year": year, "website": website, "location_name": locationName, "short_name": shortName])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var eventCode: String {
        get {
          return snapshot["event_code"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "event_code")
        }
      }

      public var eventType: Int {
        get {
          return snapshot["event_type"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "event_type")
        }
      }

      public var eventTypeString: String {
        get {
          return snapshot["event_type_string"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "event_type_string")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var address: String? {
        get {
          return snapshot["address"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "address")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var year: Int {
        get {
          return snapshot["year"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "year")
        }
      }

      public var website: String? {
        get {
          return snapshot["website"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "website")
        }
      }

      public var locationName: String? {
        get {
          return snapshot["location_name"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location_name")
        }
      }

      public var shortName: String? {
        get {
          return snapshot["short_name"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "short_name")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var event: Event {
          get {
            return Event(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class GetEventQuery: GraphQLQuery {
  public static let operationString =
    "query GetEvent($key: ID!) {\n  getEvent(key: $key) {\n    __typename\n    ...Event\n  }\n}"

  public static var requestString: String { return operationString.appending(Event.fragmentString) }

  public var key: GraphQLID

  public init(key: GraphQLID) {
    self.key = key
  }

  public var variables: GraphQLMap? {
    return ["key": key]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getEvent", arguments: ["key": GraphQLVariable("key")], type: .object(GetEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getEvent: GetEvent? = nil) {
      self.init(snapshot: ["__typename": "Query", "getEvent": getEvent.flatMap { $0.snapshot }])
    }

    public var getEvent: GetEvent? {
      get {
        return (snapshot["getEvent"] as? Snapshot).flatMap { GetEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getEvent")
      }
    }

    public struct GetEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("event_code", type: .nonNull(.scalar(String.self))),
        GraphQLField("event_type", type: .nonNull(.scalar(Int.self))),
        GraphQLField("event_type_string", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("address", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("location_name", type: .scalar(String.self)),
        GraphQLField("short_name", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventCode: String, eventType: Int, eventTypeString: String, key: GraphQLID, address: String? = nil, name: String, year: Int, website: String? = nil, locationName: String? = nil, shortName: String? = nil) {
        self.init(snapshot: ["__typename": "Event", "event_code": eventCode, "event_type": eventType, "event_type_string": eventTypeString, "key": key, "address": address, "name": name, "year": year, "website": website, "location_name": locationName, "short_name": shortName])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var eventCode: String {
        get {
          return snapshot["event_code"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "event_code")
        }
      }

      public var eventType: Int {
        get {
          return snapshot["event_type"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "event_type")
        }
      }

      public var eventTypeString: String {
        get {
          return snapshot["event_type_string"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "event_type_string")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var address: String? {
        get {
          return snapshot["address"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "address")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var year: Int {
        get {
          return snapshot["year"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "year")
        }
      }

      public var website: String? {
        get {
          return snapshot["website"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "website")
        }
      }

      public var locationName: String? {
        get {
          return snapshot["location_name"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location_name")
        }
      }

      public var shortName: String? {
        get {
          return snapshot["short_name"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "short_name")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var event: Event {
          get {
            return Event(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class ListTeamsQuery: GraphQLQuery {
  public static let operationString =
    "query ListTeams($eventKey: ID!) {\n  listTeams(eventKey: $eventKey) {\n    __typename\n    ...Team\n  }\n}"

  public static var requestString: String { return operationString.appending(Team.fragmentString) }

  public var eventKey: GraphQLID

  public init(eventKey: GraphQLID) {
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listTeams", arguments: ["eventKey": GraphQLVariable("eventKey")], type: .list(.object(ListTeam.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listTeams: [ListTeam?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listTeams": listTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    public var listTeams: [ListTeam?]? {
      get {
        return (snapshot["listTeams"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListTeam(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listTeams")
      }
    }

    public struct ListTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["Team"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("address", type: .scalar(String.self)),
        GraphQLField("city", type: .scalar(String.self)),
        GraphQLField("state_prov", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
        GraphQLField("rookie_year", type: .scalar(Int.self)),
        GraphQLField("team_number", type: .nonNull(.scalar(Int.self))),
        GraphQLField("website", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, address: String? = nil, city: String? = nil, stateProv: String? = nil, name: String, nickname: String, rookieYear: Int? = nil, teamNumber: Int, website: String? = nil) {
        self.init(snapshot: ["__typename": "Team", "key": key, "address": address, "city": city, "state_prov": stateProv, "name": name, "nickname": nickname, "rookie_year": rookieYear, "team_number": teamNumber, "website": website])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var address: String? {
        get {
          return snapshot["address"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "address")
        }
      }

      public var city: String? {
        get {
          return snapshot["city"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var stateProv: String? {
        get {
          return snapshot["state_prov"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "state_prov")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var nickname: String {
        get {
          return snapshot["nickname"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nickname")
        }
      }

      public var rookieYear: Int? {
        get {
          return snapshot["rookie_year"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "rookie_year")
        }
      }

      public var teamNumber: Int {
        get {
          return snapshot["team_number"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "team_number")
        }
      }

      public var website: String? {
        get {
          return snapshot["website"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "website")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var team: Team {
          get {
            return Team(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class GetTeamQuery: GraphQLQuery {
  public static let operationString =
    "query GetTeam($key: ID!) {\n  getTeam(key: $key) {\n    __typename\n    ...Team\n  }\n}"

  public static var requestString: String { return operationString.appending(Team.fragmentString) }

  public var key: GraphQLID

  public init(key: GraphQLID) {
    self.key = key
  }

  public var variables: GraphQLMap? {
    return ["key": key]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getTeam", arguments: ["key": GraphQLVariable("key")], type: .object(GetTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getTeam: GetTeam? = nil) {
      self.init(snapshot: ["__typename": "Query", "getTeam": getTeam.flatMap { $0.snapshot }])
    }

    public var getTeam: GetTeam? {
      get {
        return (snapshot["getTeam"] as? Snapshot).flatMap { GetTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getTeam")
      }
    }

    public struct GetTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["Team"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("address", type: .scalar(String.self)),
        GraphQLField("city", type: .scalar(String.self)),
        GraphQLField("state_prov", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
        GraphQLField("rookie_year", type: .scalar(Int.self)),
        GraphQLField("team_number", type: .nonNull(.scalar(Int.self))),
        GraphQLField("website", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, address: String? = nil, city: String? = nil, stateProv: String? = nil, name: String, nickname: String, rookieYear: Int? = nil, teamNumber: Int, website: String? = nil) {
        self.init(snapshot: ["__typename": "Team", "key": key, "address": address, "city": city, "state_prov": stateProv, "name": name, "nickname": nickname, "rookie_year": rookieYear, "team_number": teamNumber, "website": website])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var address: String? {
        get {
          return snapshot["address"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "address")
        }
      }

      public var city: String? {
        get {
          return snapshot["city"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var stateProv: String? {
        get {
          return snapshot["state_prov"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "state_prov")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var nickname: String {
        get {
          return snapshot["nickname"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nickname")
        }
      }

      public var rookieYear: Int? {
        get {
          return snapshot["rookie_year"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "rookie_year")
        }
      }

      public var teamNumber: Int {
        get {
          return snapshot["team_number"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "team_number")
        }
      }

      public var website: String? {
        get {
          return snapshot["website"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "website")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var team: Team {
          get {
            return Team(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class ListScoutedTeamsQuery: GraphQLQuery {
  public static let operationString =
    "query ListScoutedTeams($eventKey: ID!) {\n  listScoutedTeams(eventKey: $eventKey) {\n    __typename\n    ...ScoutedTeam\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutedTeam.fragmentString) }

  public var eventKey: GraphQLID

  public init(eventKey: GraphQLID) {
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listScoutedTeams", arguments: ["eventKey": GraphQLVariable("eventKey")], type: .list(.object(ListScoutedTeam.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listScoutedTeams: [ListScoutedTeam?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listScoutedTeams": listScoutedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    public var listScoutedTeams: [ListScoutedTeam?]? {
      get {
        return (snapshot["listScoutedTeams"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListScoutedTeam(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listScoutedTeams")
      }
    }

    public struct ListScoutedTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutedTeam"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("attributes", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamKey: GraphQLID, userId: GraphQLID, eventKey: String, attributes: String? = nil) {
        self.init(snapshot: ["__typename": "ScoutedTeam", "teamKey": teamKey, "userID": userId, "eventKey": eventKey, "attributes": attributes])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var teamKey: GraphQLID {
        get {
          return snapshot["teamKey"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var attributes: String? {
        get {
          return snapshot["attributes"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "attributes")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var scoutedTeam: ScoutedTeam {
          get {
            return ScoutedTeam(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class GetScoutedTeamQuery: GraphQLQuery {
  public static let operationString =
    "query GetScoutedTeam($eventKey: ID!, $teamKey: ID!) {\n  getScoutedTeam(eventKey: $eventKey, teamKey: $teamKey) {\n    __typename\n    ...ScoutedTeam\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutedTeam.fragmentString) }

  public var eventKey: GraphQLID
  public var teamKey: GraphQLID

  public init(eventKey: GraphQLID, teamKey: GraphQLID) {
    self.eventKey = eventKey
    self.teamKey = teamKey
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey, "teamKey": teamKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getScoutedTeam", arguments: ["eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey")], type: .object(GetScoutedTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getScoutedTeam: GetScoutedTeam? = nil) {
      self.init(snapshot: ["__typename": "Query", "getScoutedTeam": getScoutedTeam.flatMap { $0.snapshot }])
    }

    public var getScoutedTeam: GetScoutedTeam? {
      get {
        return (snapshot["getScoutedTeam"] as? Snapshot).flatMap { GetScoutedTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getScoutedTeam")
      }
    }

    public struct GetScoutedTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutedTeam"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("attributes", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamKey: GraphQLID, userId: GraphQLID, eventKey: String, attributes: String? = nil) {
        self.init(snapshot: ["__typename": "ScoutedTeam", "teamKey": teamKey, "userID": userId, "eventKey": eventKey, "attributes": attributes])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var teamKey: GraphQLID {
        get {
          return snapshot["teamKey"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var attributes: String? {
        get {
          return snapshot["attributes"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "attributes")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var scoutedTeam: ScoutedTeam {
          get {
            return ScoutedTeam(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class ListMatchesQuery: GraphQLQuery {
  public static let operationString =
    "query ListMatches($eventKey: ID!) {\n  listMatches(eventKey: $eventKey) {\n    __typename\n    ...Match\n  }\n}"

  public static var requestString: String { return operationString.appending(Match.fragmentString).appending(MatchAlliance.fragmentString) }

  public var eventKey: GraphQLID

  public init(eventKey: GraphQLID) {
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listMatches", arguments: ["eventKey": GraphQLVariable("eventKey")], type: .list(.object(ListMatch.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listMatches: [ListMatch?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listMatches": listMatches.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    public var listMatches: [ListMatch?]? {
      get {
        return (snapshot["listMatches"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListMatch(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listMatches")
      }
    }

    public struct ListMatch: GraphQLSelectionSet {
      public static let possibleTypes = ["Match"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("event_key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("comp_level", type: .nonNull(.scalar(CompetitionLevel.self))),
        GraphQLField("match_number", type: .nonNull(.scalar(Int.self))),
        GraphQLField("set_number", type: .scalar(Int.self)),
        GraphQLField("time", type: .scalar(Int.self)),
        GraphQLField("actual_time", type: .scalar(Int.self)),
        GraphQLField("predicted_time", type: .scalar(Int.self)),
        GraphQLField("alliances", type: .object(Alliance.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, eventKey: GraphQLID, compLevel: CompetitionLevel, matchNumber: Int, setNumber: Int? = nil, time: Int? = nil, actualTime: Int? = nil, predictedTime: Int? = nil, alliances: Alliance? = nil) {
        self.init(snapshot: ["__typename": "Match", "key": key, "event_key": eventKey, "comp_level": compLevel, "match_number": matchNumber, "set_number": setNumber, "time": time, "actual_time": actualTime, "predicted_time": predictedTime, "alliances": alliances.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var eventKey: GraphQLID {
        get {
          return snapshot["event_key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "event_key")
        }
      }

      public var compLevel: CompetitionLevel {
        get {
          return snapshot["comp_level"]! as! CompetitionLevel
        }
        set {
          snapshot.updateValue(newValue, forKey: "comp_level")
        }
      }

      public var matchNumber: Int {
        get {
          return snapshot["match_number"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "match_number")
        }
      }

      public var setNumber: Int? {
        get {
          return snapshot["set_number"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "set_number")
        }
      }

      public var time: Int? {
        get {
          return snapshot["time"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var actualTime: Int? {
        get {
          return snapshot["actual_time"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "actual_time")
        }
      }

      public var predictedTime: Int? {
        get {
          return snapshot["predicted_time"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "predicted_time")
        }
      }

      public var alliances: Alliance? {
        get {
          return (snapshot["alliances"] as? Snapshot).flatMap { Alliance(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "alliances")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var match: Match {
          get {
            return Match(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct Alliance: GraphQLSelectionSet {
        public static let possibleTypes = ["MatchAlliances"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("blue", type: .object(Blue.selections)),
          GraphQLField("red", type: .object(Red.selections)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(blue: Blue? = nil, red: Red? = nil) {
          self.init(snapshot: ["__typename": "MatchAlliances", "blue": blue.flatMap { $0.snapshot }, "red": red.flatMap { $0.snapshot }])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var blue: Blue? {
          get {
            return (snapshot["blue"] as? Snapshot).flatMap { Blue(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "blue")
          }
        }

        public var red: Red? {
          get {
            return (snapshot["red"] as? Snapshot).flatMap { Red(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "red")
          }
        }

        public struct Blue: GraphQLSelectionSet {
          public static let possibleTypes = ["MatchAlliance"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("score", type: .nonNull(.scalar(Int.self))),
            GraphQLField("team_keys", type: .list(.scalar(String.self))),
            GraphQLField("surrogate_team_keys", type: .list(.scalar(String.self))),
            GraphQLField("dq_team_keys", type: .list(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(score: Int, teamKeys: [String?]? = nil, surrogateTeamKeys: [String?]? = nil, dqTeamKeys: [String?]? = nil) {
            self.init(snapshot: ["__typename": "MatchAlliance", "score": score, "team_keys": teamKeys, "surrogate_team_keys": surrogateTeamKeys, "dq_team_keys": dqTeamKeys])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var score: Int {
            get {
              return snapshot["score"]! as! Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "score")
            }
          }

          public var teamKeys: [String?]? {
            get {
              return snapshot["team_keys"] as? [String?]
            }
            set {
              snapshot.updateValue(newValue, forKey: "team_keys")
            }
          }

          public var surrogateTeamKeys: [String?]? {
            get {
              return snapshot["surrogate_team_keys"] as? [String?]
            }
            set {
              snapshot.updateValue(newValue, forKey: "surrogate_team_keys")
            }
          }

          public var dqTeamKeys: [String?]? {
            get {
              return snapshot["dq_team_keys"] as? [String?]
            }
            set {
              snapshot.updateValue(newValue, forKey: "dq_team_keys")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }

          public struct Fragments {
            public var snapshot: Snapshot

            public var matchAlliance: MatchAlliance {
              get {
                return MatchAlliance(snapshot: snapshot)
              }
              set {
                snapshot += newValue.snapshot
              }
            }
          }
        }

        public struct Red: GraphQLSelectionSet {
          public static let possibleTypes = ["MatchAlliance"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("score", type: .nonNull(.scalar(Int.self))),
            GraphQLField("team_keys", type: .list(.scalar(String.self))),
            GraphQLField("surrogate_team_keys", type: .list(.scalar(String.self))),
            GraphQLField("dq_team_keys", type: .list(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(score: Int, teamKeys: [String?]? = nil, surrogateTeamKeys: [String?]? = nil, dqTeamKeys: [String?]? = nil) {
            self.init(snapshot: ["__typename": "MatchAlliance", "score": score, "team_keys": teamKeys, "surrogate_team_keys": surrogateTeamKeys, "dq_team_keys": dqTeamKeys])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var score: Int {
            get {
              return snapshot["score"]! as! Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "score")
            }
          }

          public var teamKeys: [String?]? {
            get {
              return snapshot["team_keys"] as? [String?]
            }
            set {
              snapshot.updateValue(newValue, forKey: "team_keys")
            }
          }

          public var surrogateTeamKeys: [String?]? {
            get {
              return snapshot["surrogate_team_keys"] as? [String?]
            }
            set {
              snapshot.updateValue(newValue, forKey: "surrogate_team_keys")
            }
          }

          public var dqTeamKeys: [String?]? {
            get {
              return snapshot["dq_team_keys"] as? [String?]
            }
            set {
              snapshot.updateValue(newValue, forKey: "dq_team_keys")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }

          public struct Fragments {
            public var snapshot: Snapshot

            public var matchAlliance: MatchAlliance {
              get {
                return MatchAlliance(snapshot: snapshot)
              }
              set {
                snapshot += newValue.snapshot
              }
            }
          }
        }
      }
    }
  }
}

public final class GetMatchQuery: GraphQLQuery {
  public static let operationString =
    "query GetMatch($matchKey: ID!) {\n  getMatch(matchKey: $matchKey) {\n    __typename\n    ...Match\n  }\n}"

  public static var requestString: String { return operationString.appending(Match.fragmentString).appending(MatchAlliance.fragmentString) }

  public var matchKey: GraphQLID

  public init(matchKey: GraphQLID) {
    self.matchKey = matchKey
  }

  public var variables: GraphQLMap? {
    return ["matchKey": matchKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getMatch", arguments: ["matchKey": GraphQLVariable("matchKey")], type: .object(GetMatch.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getMatch: GetMatch? = nil) {
      self.init(snapshot: ["__typename": "Query", "getMatch": getMatch.flatMap { $0.snapshot }])
    }

    public var getMatch: GetMatch? {
      get {
        return (snapshot["getMatch"] as? Snapshot).flatMap { GetMatch(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getMatch")
      }
    }

    public struct GetMatch: GraphQLSelectionSet {
      public static let possibleTypes = ["Match"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("event_key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("comp_level", type: .nonNull(.scalar(CompetitionLevel.self))),
        GraphQLField("match_number", type: .nonNull(.scalar(Int.self))),
        GraphQLField("set_number", type: .scalar(Int.self)),
        GraphQLField("time", type: .scalar(Int.self)),
        GraphQLField("actual_time", type: .scalar(Int.self)),
        GraphQLField("predicted_time", type: .scalar(Int.self)),
        GraphQLField("alliances", type: .object(Alliance.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, eventKey: GraphQLID, compLevel: CompetitionLevel, matchNumber: Int, setNumber: Int? = nil, time: Int? = nil, actualTime: Int? = nil, predictedTime: Int? = nil, alliances: Alliance? = nil) {
        self.init(snapshot: ["__typename": "Match", "key": key, "event_key": eventKey, "comp_level": compLevel, "match_number": matchNumber, "set_number": setNumber, "time": time, "actual_time": actualTime, "predicted_time": predictedTime, "alliances": alliances.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var eventKey: GraphQLID {
        get {
          return snapshot["event_key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "event_key")
        }
      }

      public var compLevel: CompetitionLevel {
        get {
          return snapshot["comp_level"]! as! CompetitionLevel
        }
        set {
          snapshot.updateValue(newValue, forKey: "comp_level")
        }
      }

      public var matchNumber: Int {
        get {
          return snapshot["match_number"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "match_number")
        }
      }

      public var setNumber: Int? {
        get {
          return snapshot["set_number"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "set_number")
        }
      }

      public var time: Int? {
        get {
          return snapshot["time"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "time")
        }
      }

      public var actualTime: Int? {
        get {
          return snapshot["actual_time"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "actual_time")
        }
      }

      public var predictedTime: Int? {
        get {
          return snapshot["predicted_time"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "predicted_time")
        }
      }

      public var alliances: Alliance? {
        get {
          return (snapshot["alliances"] as? Snapshot).flatMap { Alliance(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "alliances")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var match: Match {
          get {
            return Match(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct Alliance: GraphQLSelectionSet {
        public static let possibleTypes = ["MatchAlliances"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("blue", type: .object(Blue.selections)),
          GraphQLField("red", type: .object(Red.selections)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(blue: Blue? = nil, red: Red? = nil) {
          self.init(snapshot: ["__typename": "MatchAlliances", "blue": blue.flatMap { $0.snapshot }, "red": red.flatMap { $0.snapshot }])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var blue: Blue? {
          get {
            return (snapshot["blue"] as? Snapshot).flatMap { Blue(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "blue")
          }
        }

        public var red: Red? {
          get {
            return (snapshot["red"] as? Snapshot).flatMap { Red(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "red")
          }
        }

        public struct Blue: GraphQLSelectionSet {
          public static let possibleTypes = ["MatchAlliance"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("score", type: .nonNull(.scalar(Int.self))),
            GraphQLField("team_keys", type: .list(.scalar(String.self))),
            GraphQLField("surrogate_team_keys", type: .list(.scalar(String.self))),
            GraphQLField("dq_team_keys", type: .list(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(score: Int, teamKeys: [String?]? = nil, surrogateTeamKeys: [String?]? = nil, dqTeamKeys: [String?]? = nil) {
            self.init(snapshot: ["__typename": "MatchAlliance", "score": score, "team_keys": teamKeys, "surrogate_team_keys": surrogateTeamKeys, "dq_team_keys": dqTeamKeys])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var score: Int {
            get {
              return snapshot["score"]! as! Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "score")
            }
          }

          public var teamKeys: [String?]? {
            get {
              return snapshot["team_keys"] as? [String?]
            }
            set {
              snapshot.updateValue(newValue, forKey: "team_keys")
            }
          }

          public var surrogateTeamKeys: [String?]? {
            get {
              return snapshot["surrogate_team_keys"] as? [String?]
            }
            set {
              snapshot.updateValue(newValue, forKey: "surrogate_team_keys")
            }
          }

          public var dqTeamKeys: [String?]? {
            get {
              return snapshot["dq_team_keys"] as? [String?]
            }
            set {
              snapshot.updateValue(newValue, forKey: "dq_team_keys")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }

          public struct Fragments {
            public var snapshot: Snapshot

            public var matchAlliance: MatchAlliance {
              get {
                return MatchAlliance(snapshot: snapshot)
              }
              set {
                snapshot += newValue.snapshot
              }
            }
          }
        }

        public struct Red: GraphQLSelectionSet {
          public static let possibleTypes = ["MatchAlliance"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("score", type: .nonNull(.scalar(Int.self))),
            GraphQLField("team_keys", type: .list(.scalar(String.self))),
            GraphQLField("surrogate_team_keys", type: .list(.scalar(String.self))),
            GraphQLField("dq_team_keys", type: .list(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(score: Int, teamKeys: [String?]? = nil, surrogateTeamKeys: [String?]? = nil, dqTeamKeys: [String?]? = nil) {
            self.init(snapshot: ["__typename": "MatchAlliance", "score": score, "team_keys": teamKeys, "surrogate_team_keys": surrogateTeamKeys, "dq_team_keys": dqTeamKeys])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var score: Int {
            get {
              return snapshot["score"]! as! Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "score")
            }
          }

          public var teamKeys: [String?]? {
            get {
              return snapshot["team_keys"] as? [String?]
            }
            set {
              snapshot.updateValue(newValue, forKey: "team_keys")
            }
          }

          public var surrogateTeamKeys: [String?]? {
            get {
              return snapshot["surrogate_team_keys"] as? [String?]
            }
            set {
              snapshot.updateValue(newValue, forKey: "surrogate_team_keys")
            }
          }

          public var dqTeamKeys: [String?]? {
            get {
              return snapshot["dq_team_keys"] as? [String?]
            }
            set {
              snapshot.updateValue(newValue, forKey: "dq_team_keys")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }

          public struct Fragments {
            public var snapshot: Snapshot

            public var matchAlliance: MatchAlliance {
              get {
                return MatchAlliance(snapshot: snapshot)
              }
              set {
                snapshot += newValue.snapshot
              }
            }
          }
        }
      }
    }
  }
}

public final class ListScoutSessionsQuery: GraphQLQuery {
  public static let operationString =
    "query ListScoutSessions($eventKey: ID!, $teamKey: ID!, $matchKey: ID) {\n  listScoutSessions(eventKey: $eventKey, teamKey: $teamKey, matchKey: $matchKey) {\n    __typename\n    ...ScoutSession\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutSession.fragmentString).appending(TimeMarkerFragment.fragmentString) }

  public var eventKey: GraphQLID
  public var teamKey: GraphQLID
  public var matchKey: GraphQLID?

  public init(eventKey: GraphQLID, teamKey: GraphQLID, matchKey: GraphQLID? = nil) {
    self.eventKey = eventKey
    self.teamKey = teamKey
    self.matchKey = matchKey
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey, "teamKey": teamKey, "matchKey": matchKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listScoutSessions", arguments: ["eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey"), "matchKey": GraphQLVariable("matchKey")], type: .list(.object(ListScoutSession.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listScoutSessions: [ListScoutSession?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listScoutSessions": listScoutSessions.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    public var listScoutSessions: [ListScoutSession?]? {
      get {
        return (snapshot["listScoutSessions"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListScoutSession(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listScoutSessions")
      }
    }

    public struct ListScoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("matchKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("startState", type: .scalar(String.self)),
        GraphQLField("endState", type: .scalar(String.self)),
        GraphQLField("timeMarkers", type: .list(.object(TimeMarker.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, matchKey: String, teamKey: String, userId: GraphQLID, eventKey: String, startState: String? = nil, endState: String? = nil, timeMarkers: [TimeMarker?]? = nil) {
        self.init(snapshot: ["__typename": "ScoutSession", "key": key, "matchKey": matchKey, "teamKey": teamKey, "userID": userId, "eventKey": eventKey, "startState": startState, "endState": endState, "timeMarkers": timeMarkers.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var matchKey: String {
        get {
          return snapshot["matchKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "matchKey")
        }
      }

      public var teamKey: String {
        get {
          return snapshot["teamKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var startState: String? {
        get {
          return snapshot["startState"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "startState")
        }
      }

      public var endState: String? {
        get {
          return snapshot["endState"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "endState")
        }
      }

      public var timeMarkers: [TimeMarker?]? {
        get {
          return (snapshot["timeMarkers"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { TimeMarker(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "timeMarkers")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var scoutSession: ScoutSession {
          get {
            return ScoutSession(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct TimeMarker: GraphQLSelectionSet {
        public static let possibleTypes = ["TimeMarker"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("event", type: .nonNull(.scalar(String.self))),
          GraphQLField("time", type: .nonNull(.scalar(Double.self))),
          GraphQLField("subOption", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(event: String, time: Double, subOption: String? = nil) {
          self.init(snapshot: ["__typename": "TimeMarker", "event": event, "time": time, "subOption": subOption])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var event: String {
          get {
            return snapshot["event"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "event")
          }
        }

        public var time: Double {
          get {
            return snapshot["time"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "time")
          }
        }

        public var subOption: String? {
          get {
            return snapshot["subOption"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "subOption")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var timeMarkerFragment: TimeMarkerFragment {
            get {
              return TimeMarkerFragment(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }
    }
  }
}

public final class GetScoutSessionQuery: GraphQLQuery {
  public static let operationString =
    "query GetScoutSession($eventKey: ID!, $key: ID!) {\n  getScoutSession(eventKey: $eventKey, key: $key) {\n    __typename\n    ...ScoutSession\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutSession.fragmentString).appending(TimeMarkerFragment.fragmentString) }

  public var eventKey: GraphQLID
  public var key: GraphQLID

  public init(eventKey: GraphQLID, key: GraphQLID) {
    self.eventKey = eventKey
    self.key = key
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey, "key": key]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getScoutSession", arguments: ["eventKey": GraphQLVariable("eventKey"), "key": GraphQLVariable("key")], type: .object(GetScoutSession.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getScoutSession: GetScoutSession? = nil) {
      self.init(snapshot: ["__typename": "Query", "getScoutSession": getScoutSession.flatMap { $0.snapshot }])
    }

    public var getScoutSession: GetScoutSession? {
      get {
        return (snapshot["getScoutSession"] as? Snapshot).flatMap { GetScoutSession(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getScoutSession")
      }
    }

    public struct GetScoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("matchKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("startState", type: .scalar(String.self)),
        GraphQLField("endState", type: .scalar(String.self)),
        GraphQLField("timeMarkers", type: .list(.object(TimeMarker.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, matchKey: String, teamKey: String, userId: GraphQLID, eventKey: String, startState: String? = nil, endState: String? = nil, timeMarkers: [TimeMarker?]? = nil) {
        self.init(snapshot: ["__typename": "ScoutSession", "key": key, "matchKey": matchKey, "teamKey": teamKey, "userID": userId, "eventKey": eventKey, "startState": startState, "endState": endState, "timeMarkers": timeMarkers.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var matchKey: String {
        get {
          return snapshot["matchKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "matchKey")
        }
      }

      public var teamKey: String {
        get {
          return snapshot["teamKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var startState: String? {
        get {
          return snapshot["startState"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "startState")
        }
      }

      public var endState: String? {
        get {
          return snapshot["endState"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "endState")
        }
      }

      public var timeMarkers: [TimeMarker?]? {
        get {
          return (snapshot["timeMarkers"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { TimeMarker(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "timeMarkers")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var scoutSession: ScoutSession {
          get {
            return ScoutSession(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct TimeMarker: GraphQLSelectionSet {
        public static let possibleTypes = ["TimeMarker"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("event", type: .nonNull(.scalar(String.self))),
          GraphQLField("time", type: .nonNull(.scalar(Double.self))),
          GraphQLField("subOption", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(event: String, time: Double, subOption: String? = nil) {
          self.init(snapshot: ["__typename": "TimeMarker", "event": event, "time": time, "subOption": subOption])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var event: String {
          get {
            return snapshot["event"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "event")
          }
        }

        public var time: Double {
          get {
            return snapshot["time"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "time")
          }
        }

        public var subOption: String? {
          get {
            return snapshot["subOption"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "subOption")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var timeMarkerFragment: TimeMarkerFragment {
            get {
              return TimeMarkerFragment(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }
    }
  }
}

public final class ListEventOprsQuery: GraphQLQuery {
  public static let operationString =
    "query ListEventOprs($eventKey: ID!) {\n  listEventOprs(eventKey: $eventKey) {\n    __typename\n    ...TeamEventOPR\n  }\n}"

  public static var requestString: String { return operationString.appending(TeamEventOpr.fragmentString) }

  public var eventKey: GraphQLID

  public init(eventKey: GraphQLID) {
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listEventOprs", arguments: ["eventKey": GraphQLVariable("eventKey")], type: .list(.object(ListEventOpr.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listEventOprs: [ListEventOpr?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listEventOprs": listEventOprs.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    public var listEventOprs: [ListEventOpr?]? {
      get {
        return (snapshot["listEventOprs"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListEventOpr(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listEventOprs")
      }
    }

    public struct ListEventOpr: GraphQLSelectionSet {
      public static let possibleTypes = ["TeamEventOPR"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("opr", type: .scalar(Double.self)),
        GraphQLField("dpr", type: .scalar(Double.self)),
        GraphQLField("ccwm", type: .scalar(Double.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamKey: String, eventKey: String, opr: Double? = nil, dpr: Double? = nil, ccwm: Double? = nil) {
        self.init(snapshot: ["__typename": "TeamEventOPR", "teamKey": teamKey, "eventKey": eventKey, "opr": opr, "dpr": dpr, "ccwm": ccwm])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var teamKey: String {
        get {
          return snapshot["teamKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var opr: Double? {
        get {
          return snapshot["opr"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "opr")
        }
      }

      public var dpr: Double? {
        get {
          return snapshot["dpr"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "dpr")
        }
      }

      public var ccwm: Double? {
        get {
          return snapshot["ccwm"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "ccwm")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var teamEventOpr: TeamEventOpr {
          get {
            return TeamEventOpr(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class ListTeamEventStatusesQuery: GraphQLQuery {
  public static let operationString =
    "query ListTeamEventStatuses($eventKey: ID!) {\n  listTeamEventStatuses(eventKey: $eventKey) {\n    __typename\n    ...TeamEventStatus\n  }\n}"

  public static var requestString: String { return operationString.appending(TeamEventStatus.fragmentString) }

  public var eventKey: GraphQLID

  public init(eventKey: GraphQLID) {
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listTeamEventStatuses", arguments: ["eventKey": GraphQLVariable("eventKey")], type: .list(.object(ListTeamEventStatus.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listTeamEventStatuses: [ListTeamEventStatus?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listTeamEventStatuses": listTeamEventStatuses.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    public var listTeamEventStatuses: [ListTeamEventStatus?]? {
      get {
        return (snapshot["listTeamEventStatuses"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListTeamEventStatus(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listTeamEventStatuses")
      }
    }

    public struct ListTeamEventStatus: GraphQLSelectionSet {
      public static let possibleTypes = ["TeamEventStatus"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("qual", type: .object(Qual.selections)),
        GraphQLField("overall_status_str", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamKey: String, eventKey: String, qual: Qual? = nil, overallStatusStr: String? = nil) {
        self.init(snapshot: ["__typename": "TeamEventStatus", "teamKey": teamKey, "eventKey": eventKey, "qual": qual.flatMap { $0.snapshot }, "overall_status_str": overallStatusStr])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var teamKey: String {
        get {
          return snapshot["teamKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var qual: Qual? {
        get {
          return (snapshot["qual"] as? Snapshot).flatMap { Qual(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "qual")
        }
      }

      public var overallStatusStr: String? {
        get {
          return snapshot["overall_status_str"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "overall_status_str")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var teamEventStatus: TeamEventStatus {
          get {
            return TeamEventStatus(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct Qual: GraphQLSelectionSet {
        public static let possibleTypes = ["TeamEventStatusRank"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("num_teams", type: .scalar(Int.self)),
          GraphQLField("status", type: .scalar(String.self)),
          GraphQLField("ranking", type: .object(Ranking.selections)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(numTeams: Int? = nil, status: String? = nil, ranking: Ranking? = nil) {
          self.init(snapshot: ["__typename": "TeamEventStatusRank", "num_teams": numTeams, "status": status, "ranking": ranking.flatMap { $0.snapshot }])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var numTeams: Int? {
          get {
            return snapshot["num_teams"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "num_teams")
          }
        }

        public var status: String? {
          get {
            return snapshot["status"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "status")
          }
        }

        public var ranking: Ranking? {
          get {
            return (snapshot["ranking"] as? Snapshot).flatMap { Ranking(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "ranking")
          }
        }

        public struct Ranking: GraphQLSelectionSet {
          public static let possibleTypes = ["TeamEventStatusQualRanking"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("dq", type: .scalar(Int.self)),
            GraphQLField("matches_played", type: .scalar(Int.self)),
            GraphQLField("qual_average", type: .scalar(Double.self)),
            GraphQLField("rank", type: .scalar(Int.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(dq: Int? = nil, matchesPlayed: Int? = nil, qualAverage: Double? = nil, rank: Int? = nil) {
            self.init(snapshot: ["__typename": "TeamEventStatusQualRanking", "dq": dq, "matches_played": matchesPlayed, "qual_average": qualAverage, "rank": rank])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var dq: Int? {
            get {
              return snapshot["dq"] as? Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "dq")
            }
          }

          public var matchesPlayed: Int? {
            get {
              return snapshot["matches_played"] as? Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "matches_played")
            }
          }

          public var qualAverage: Double? {
            get {
              return snapshot["qual_average"] as? Double
            }
            set {
              snapshot.updateValue(newValue, forKey: "qual_average")
            }
          }

          public var rank: Int? {
            get {
              return snapshot["rank"] as? Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "rank")
            }
          }
        }
      }
    }
  }
}

public final class ListTeamCommentsQuery: GraphQLQuery {
  public static let operationString =
    "query ListTeamComments($eventKey: ID!, $teamKey: ID!) {\n  listTeamComments(eventKey: $eventKey, teamKey: $teamKey) {\n    __typename\n    ...TeamComment\n  }\n}"

  public static var requestString: String { return operationString.appending(TeamComment.fragmentString) }

  public var eventKey: GraphQLID
  public var teamKey: GraphQLID

  public init(eventKey: GraphQLID, teamKey: GraphQLID) {
    self.eventKey = eventKey
    self.teamKey = teamKey
  }

  public var variables: GraphQLMap? {
    return ["eventKey": eventKey, "teamKey": teamKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listTeamComments", arguments: ["eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey")], type: .list(.object(ListTeamComment.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listTeamComments: [ListTeamComment?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listTeamComments": listTeamComments.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    public var listTeamComments: [ListTeamComment?]? {
      get {
        return (snapshot["listTeamComments"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListTeamComment(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listTeamComments")
      }
    }

    public struct ListTeamComment: GraphQLSelectionSet {
      public static let possibleTypes = ["TeamComment"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("author", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("body", type: .nonNull(.scalar(String.self))),
        GraphQLField("datePosted", type: .nonNull(.scalar(Int.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(author: String, userId: GraphQLID, body: String, datePosted: Int, key: GraphQLID, teamKey: String, eventKey: String) {
        self.init(snapshot: ["__typename": "TeamComment", "author": author, "userID": userId, "body": body, "datePosted": datePosted, "key": key, "teamKey": teamKey, "eventKey": eventKey])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var author: String {
        get {
          return snapshot["author"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "author")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var body: String {
        get {
          return snapshot["body"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "body")
        }
      }

      public var datePosted: Int {
        get {
          return snapshot["datePosted"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "datePosted")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var teamKey: String {
        get {
          return snapshot["teamKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var teamComment: TeamComment {
          get {
            return TeamComment(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class OnAddTrackedEventSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnAddTrackedEvent($userID: ID!) {\n  onAddTrackedEvent(userID: $userID) {\n    __typename\n    eventKey\n    eventName\n  }\n}"

  public var userID: GraphQLID

  public init(userID: GraphQLID) {
    self.userID = userID
  }

  public var variables: GraphQLMap? {
    return ["userID": userID]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onAddTrackedEvent", arguments: ["userID": GraphQLVariable("userID")], type: .object(OnAddTrackedEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onAddTrackedEvent: OnAddTrackedEvent? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onAddTrackedEvent": onAddTrackedEvent.flatMap { $0.snapshot }])
    }

    public var onAddTrackedEvent: OnAddTrackedEvent? {
      get {
        return (snapshot["onAddTrackedEvent"] as? Snapshot).flatMap { OnAddTrackedEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onAddTrackedEvent")
      }
    }

    public struct OnAddTrackedEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["EventRanking"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventName", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var eventName: String {
        get {
          return snapshot["eventName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventName")
        }
      }
    }
  }
}

public final class OnRemoveTrackedEventSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnRemoveTrackedEvent($userID: ID!) {\n  onRemoveTrackedEvent(userID: $userID) {\n    __typename\n    eventKey\n    userID\n  }\n}"

  public var userID: GraphQLID

  public init(userID: GraphQLID) {
    self.userID = userID
  }

  public var variables: GraphQLMap? {
    return ["userID": userID]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onRemoveTrackedEvent", arguments: ["userID": GraphQLVariable("userID")], type: .object(OnRemoveTrackedEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onRemoveTrackedEvent: OnRemoveTrackedEvent? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onRemoveTrackedEvent": onRemoveTrackedEvent.flatMap { $0.snapshot }])
    }

    public var onRemoveTrackedEvent: OnRemoveTrackedEvent? {
      get {
        return (snapshot["onRemoveTrackedEvent"] as? Snapshot).flatMap { OnRemoveTrackedEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onRemoveTrackedEvent")
      }
    }

    public struct OnRemoveTrackedEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["EventDeletion"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: GraphQLID, userId: GraphQLID) {
        self.init(snapshot: ["__typename": "EventDeletion", "eventKey": eventKey, "userID": userId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var eventKey: GraphQLID {
        get {
          return snapshot["eventKey"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }
    }
  }
}

public final class OnUpdateTeamRankSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateTeamRank($userID: ID!, $eventKey: String!) {\n  onUpdateTeamRank(userID: $userID, eventKey: $eventKey) {\n    __typename\n    ...EventRanking\n  }\n}"

  public static var requestString: String { return operationString.appending(EventRanking.fragmentString) }

  public var userID: GraphQLID
  public var eventKey: String

  public init(userID: GraphQLID, eventKey: String) {
    self.userID = userID
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateTeamRank", arguments: ["userID": GraphQLVariable("userID"), "eventKey": GraphQLVariable("eventKey")], type: .object(OnUpdateTeamRank.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateTeamRank: OnUpdateTeamRank? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateTeamRank": onUpdateTeamRank.flatMap { $0.snapshot }])
    }

    public var onUpdateTeamRank: OnUpdateTeamRank? {
      get {
        return (snapshot["onUpdateTeamRank"] as? Snapshot).flatMap { OnUpdateTeamRank(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateTeamRank")
      }
    }

    public struct OnUpdateTeamRank: GraphQLSelectionSet {
      public static let possibleTypes = ["EventRanking"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventName", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String, userId: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "userID": userId, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var eventName: String {
        get {
          return snapshot["eventName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventName")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var rankedTeams: [RankedTeam?]? {
        get {
          return (snapshot["rankedTeams"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { RankedTeam(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "rankedTeams")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var eventRanking: EventRanking {
          get {
            return EventRanking(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct RankedTeam: GraphQLSelectionSet {
        public static let possibleTypes = ["RankedTeam"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
          GraphQLField("isPicked", type: .nonNull(.scalar(Bool.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(teamKey: String, isPicked: Bool) {
          self.init(snapshot: ["__typename": "RankedTeam", "teamKey": teamKey, "isPicked": isPicked])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var teamKey: String {
          get {
            return snapshot["teamKey"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "teamKey")
          }
        }

        public var isPicked: Bool {
          get {
            return snapshot["isPicked"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "isPicked")
          }
        }
      }
    }
  }
}

public final class OnSetTeamPickedSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnSetTeamPicked($userID: ID!, $eventKey: String!) {\n  onSetTeamPicked(userID: $userID, eventKey: $eventKey) {\n    __typename\n    ...EventRanking\n  }\n}"

  public static var requestString: String { return operationString.appending(EventRanking.fragmentString) }

  public var userID: GraphQLID
  public var eventKey: String

  public init(userID: GraphQLID, eventKey: String) {
    self.userID = userID
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onSetTeamPicked", arguments: ["userID": GraphQLVariable("userID"), "eventKey": GraphQLVariable("eventKey")], type: .object(OnSetTeamPicked.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onSetTeamPicked: OnSetTeamPicked? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onSetTeamPicked": onSetTeamPicked.flatMap { $0.snapshot }])
    }

    public var onSetTeamPicked: OnSetTeamPicked? {
      get {
        return (snapshot["onSetTeamPicked"] as? Snapshot).flatMap { OnSetTeamPicked(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onSetTeamPicked")
      }
    }

    public struct OnSetTeamPicked: GraphQLSelectionSet {
      public static let possibleTypes = ["EventRanking"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventName", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String, userId: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "userID": userId, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var eventName: String {
        get {
          return snapshot["eventName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventName")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var rankedTeams: [RankedTeam?]? {
        get {
          return (snapshot["rankedTeams"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { RankedTeam(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "rankedTeams")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var eventRanking: EventRanking {
          get {
            return EventRanking(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct RankedTeam: GraphQLSelectionSet {
        public static let possibleTypes = ["RankedTeam"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
          GraphQLField("isPicked", type: .nonNull(.scalar(Bool.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(teamKey: String, isPicked: Bool) {
          self.init(snapshot: ["__typename": "RankedTeam", "teamKey": teamKey, "isPicked": isPicked])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var teamKey: String {
          get {
            return snapshot["teamKey"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "teamKey")
          }
        }

        public var isPicked: Bool {
          get {
            return snapshot["isPicked"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "isPicked")
          }
        }
      }
    }
  }
}

public final class OnUpdateScoutedTeamSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateScoutedTeam($userID: ID!, $eventKey: ID!, $teamKey: ID!) {\n  onUpdateScoutedTeam(userID: $userID, eventKey: $eventKey, teamKey: $teamKey) {\n    __typename\n    ...ScoutedTeam\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutedTeam.fragmentString) }

  public var userID: GraphQLID
  public var eventKey: GraphQLID
  public var teamKey: GraphQLID

  public init(userID: GraphQLID, eventKey: GraphQLID, teamKey: GraphQLID) {
    self.userID = userID
    self.eventKey = eventKey
    self.teamKey = teamKey
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "eventKey": eventKey, "teamKey": teamKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateScoutedTeam", arguments: ["userID": GraphQLVariable("userID"), "eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey")], type: .object(OnUpdateScoutedTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateScoutedTeam: OnUpdateScoutedTeam? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateScoutedTeam": onUpdateScoutedTeam.flatMap { $0.snapshot }])
    }

    public var onUpdateScoutedTeam: OnUpdateScoutedTeam? {
      get {
        return (snapshot["onUpdateScoutedTeam"] as? Snapshot).flatMap { OnUpdateScoutedTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateScoutedTeam")
      }
    }

    public struct OnUpdateScoutedTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutedTeam"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("attributes", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamKey: GraphQLID, userId: GraphQLID, eventKey: String, attributes: String? = nil) {
        self.init(snapshot: ["__typename": "ScoutedTeam", "teamKey": teamKey, "userID": userId, "eventKey": eventKey, "attributes": attributes])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var teamKey: GraphQLID {
        get {
          return snapshot["teamKey"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var attributes: String? {
        get {
          return snapshot["attributes"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "attributes")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var scoutedTeam: ScoutedTeam {
          get {
            return ScoutedTeam(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class OnCreateScoutSessionSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateScoutSession($userID: ID!, $teamKey: String, $matchKey: String) {\n  onCreateScoutSession(userID: $userID, teamKey: $teamKey, matchKey: $matchKey) {\n    __typename\n    ...ScoutSession\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutSession.fragmentString).appending(TimeMarkerFragment.fragmentString) }

  public var userID: GraphQLID
  public var teamKey: String?
  public var matchKey: String?

  public init(userID: GraphQLID, teamKey: String? = nil, matchKey: String? = nil) {
    self.userID = userID
    self.teamKey = teamKey
    self.matchKey = matchKey
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "teamKey": teamKey, "matchKey": matchKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateScoutSession", arguments: ["userID": GraphQLVariable("userID"), "teamKey": GraphQLVariable("teamKey"), "matchKey": GraphQLVariable("matchKey")], type: .object(OnCreateScoutSession.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateScoutSession: OnCreateScoutSession? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateScoutSession": onCreateScoutSession.flatMap { $0.snapshot }])
    }

    public var onCreateScoutSession: OnCreateScoutSession? {
      get {
        return (snapshot["onCreateScoutSession"] as? Snapshot).flatMap { OnCreateScoutSession(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateScoutSession")
      }
    }

    public struct OnCreateScoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("matchKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("startState", type: .scalar(String.self)),
        GraphQLField("endState", type: .scalar(String.self)),
        GraphQLField("timeMarkers", type: .list(.object(TimeMarker.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, matchKey: String, teamKey: String, userId: GraphQLID, eventKey: String, startState: String? = nil, endState: String? = nil, timeMarkers: [TimeMarker?]? = nil) {
        self.init(snapshot: ["__typename": "ScoutSession", "key": key, "matchKey": matchKey, "teamKey": teamKey, "userID": userId, "eventKey": eventKey, "startState": startState, "endState": endState, "timeMarkers": timeMarkers.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var matchKey: String {
        get {
          return snapshot["matchKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "matchKey")
        }
      }

      public var teamKey: String {
        get {
          return snapshot["teamKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var startState: String? {
        get {
          return snapshot["startState"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "startState")
        }
      }

      public var endState: String? {
        get {
          return snapshot["endState"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "endState")
        }
      }

      public var timeMarkers: [TimeMarker?]? {
        get {
          return (snapshot["timeMarkers"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { TimeMarker(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "timeMarkers")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var scoutSession: ScoutSession {
          get {
            return ScoutSession(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct TimeMarker: GraphQLSelectionSet {
        public static let possibleTypes = ["TimeMarker"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("event", type: .nonNull(.scalar(String.self))),
          GraphQLField("time", type: .nonNull(.scalar(Double.self))),
          GraphQLField("subOption", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(event: String, time: Double, subOption: String? = nil) {
          self.init(snapshot: ["__typename": "TimeMarker", "event": event, "time": time, "subOption": subOption])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var event: String {
          get {
            return snapshot["event"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "event")
          }
        }

        public var time: Double {
          get {
            return snapshot["time"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "time")
          }
        }

        public var subOption: String? {
          get {
            return snapshot["subOption"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "subOption")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var timeMarkerFragment: TimeMarkerFragment {
            get {
              return TimeMarkerFragment(snapshot: snapshot)
            }
            set {
              snapshot += newValue.snapshot
            }
          }
        }
      }
    }
  }
}

public final class OnDeleteScoutSessionSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteScoutSession($userID: ID!, $key: ID, $matchKey: String, $teamKey: String) {\n  onDeleteScoutSession(userID: $userID, key: $key, matchKey: $matchKey, teamKey: $teamKey) {\n    __typename\n    key\n    matchKey\n    teamKey\n    eventKey\n  }\n}"

  public var userID: GraphQLID
  public var key: GraphQLID?
  public var matchKey: String?
  public var teamKey: String?

  public init(userID: GraphQLID, key: GraphQLID? = nil, matchKey: String? = nil, teamKey: String? = nil) {
    self.userID = userID
    self.key = key
    self.matchKey = matchKey
    self.teamKey = teamKey
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "key": key, "matchKey": matchKey, "teamKey": teamKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteScoutSession", arguments: ["userID": GraphQLVariable("userID"), "key": GraphQLVariable("key"), "matchKey": GraphQLVariable("matchKey"), "teamKey": GraphQLVariable("teamKey")], type: .object(OnDeleteScoutSession.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteScoutSession: OnDeleteScoutSession? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteScoutSession": onDeleteScoutSession.flatMap { $0.snapshot }])
    }

    public var onDeleteScoutSession: OnDeleteScoutSession? {
      get {
        return (snapshot["onDeleteScoutSession"] as? Snapshot).flatMap { OnDeleteScoutSession(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteScoutSession")
      }
    }

    public struct OnDeleteScoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("matchKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, matchKey: String, teamKey: String, eventKey: String) {
        self.init(snapshot: ["__typename": "ScoutSession", "key": key, "matchKey": matchKey, "teamKey": teamKey, "eventKey": eventKey])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var matchKey: String {
        get {
          return snapshot["matchKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "matchKey")
        }
      }

      public var teamKey: String {
        get {
          return snapshot["teamKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }
    }
  }
}

public final class OnAddTeamCommentSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnAddTeamComment($userID: ID!, $teamKey: String!) {\n  onAddTeamComment(userID: $userID, teamKey: $teamKey) {\n    __typename\n    ...TeamComment\n  }\n}"

  public static var requestString: String { return operationString.appending(TeamComment.fragmentString) }

  public var userID: GraphQLID
  public var teamKey: String

  public init(userID: GraphQLID, teamKey: String) {
    self.userID = userID
    self.teamKey = teamKey
  }

  public var variables: GraphQLMap? {
    return ["userID": userID, "teamKey": teamKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onAddTeamComment", arguments: ["userID": GraphQLVariable("userID"), "teamKey": GraphQLVariable("teamKey")], type: .object(OnAddTeamComment.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onAddTeamComment: OnAddTeamComment? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onAddTeamComment": onAddTeamComment.flatMap { $0.snapshot }])
    }

    public var onAddTeamComment: OnAddTeamComment? {
      get {
        return (snapshot["onAddTeamComment"] as? Snapshot).flatMap { OnAddTeamComment(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onAddTeamComment")
      }
    }

    public struct OnAddTeamComment: GraphQLSelectionSet {
      public static let possibleTypes = ["TeamComment"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("author", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("body", type: .nonNull(.scalar(String.self))),
        GraphQLField("datePosted", type: .nonNull(.scalar(Int.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(author: String, userId: GraphQLID, body: String, datePosted: Int, key: GraphQLID, teamKey: String, eventKey: String) {
        self.init(snapshot: ["__typename": "TeamComment", "author": author, "userID": userId, "body": body, "datePosted": datePosted, "key": key, "teamKey": teamKey, "eventKey": eventKey])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var author: String {
        get {
          return snapshot["author"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "author")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userID")
        }
      }

      public var body: String {
        get {
          return snapshot["body"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "body")
        }
      }

      public var datePosted: Int {
        get {
          return snapshot["datePosted"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "datePosted")
        }
      }

      public var key: GraphQLID {
        get {
          return snapshot["key"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var teamKey: String {
        get {
          return snapshot["teamKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamKey")
        }
      }

      public var eventKey: String {
        get {
          return snapshot["eventKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventKey")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var teamComment: TeamComment {
          get {
            return TeamComment(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public struct EventRanking: GraphQLFragment {
  public static let fragmentString =
    "fragment EventRanking on EventRanking {\n  __typename\n  eventKey\n  eventName\n  userID\n  rankedTeams {\n    __typename\n    teamKey\n    isPicked\n  }\n}"

  public static let possibleTypes = ["EventRanking"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("eventName", type: .nonNull(.scalar(String.self))),
    GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(eventKey: String, eventName: String, userId: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
    self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "userID": userId, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var eventKey: String {
    get {
      return snapshot["eventKey"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "eventKey")
    }
  }

  public var eventName: String {
    get {
      return snapshot["eventName"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "eventName")
    }
  }

  public var userId: GraphQLID {
    get {
      return snapshot["userID"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "userID")
    }
  }

  public var rankedTeams: [RankedTeam?]? {
    get {
      return (snapshot["rankedTeams"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { RankedTeam(snapshot: $0) } } }
    }
    set {
      snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "rankedTeams")
    }
  }

  public struct RankedTeam: GraphQLSelectionSet {
    public static let possibleTypes = ["RankedTeam"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
      GraphQLField("isPicked", type: .nonNull(.scalar(Bool.self))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(teamKey: String, isPicked: Bool) {
      self.init(snapshot: ["__typename": "RankedTeam", "teamKey": teamKey, "isPicked": isPicked])
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "__typename")
      }
    }

    public var teamKey: String {
      get {
        return snapshot["teamKey"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "teamKey")
      }
    }

    public var isPicked: Bool {
      get {
        return snapshot["isPicked"]! as! Bool
      }
      set {
        snapshot.updateValue(newValue, forKey: "isPicked")
      }
    }
  }
}

public struct Event: GraphQLFragment {
  public static let fragmentString =
    "fragment Event on Event {\n  __typename\n  event_code\n  event_type\n  event_type_string\n  key\n  address\n  name\n  year\n  website\n  location_name\n  short_name\n}"

  public static let possibleTypes = ["Event"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("event_code", type: .nonNull(.scalar(String.self))),
    GraphQLField("event_type", type: .nonNull(.scalar(Int.self))),
    GraphQLField("event_type_string", type: .nonNull(.scalar(String.self))),
    GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("address", type: .scalar(String.self)),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
    GraphQLField("year", type: .nonNull(.scalar(Int.self))),
    GraphQLField("website", type: .scalar(String.self)),
    GraphQLField("location_name", type: .scalar(String.self)),
    GraphQLField("short_name", type: .scalar(String.self)),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(eventCode: String, eventType: Int, eventTypeString: String, key: GraphQLID, address: String? = nil, name: String, year: Int, website: String? = nil, locationName: String? = nil, shortName: String? = nil) {
    self.init(snapshot: ["__typename": "Event", "event_code": eventCode, "event_type": eventType, "event_type_string": eventTypeString, "key": key, "address": address, "name": name, "year": year, "website": website, "location_name": locationName, "short_name": shortName])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var eventCode: String {
    get {
      return snapshot["event_code"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "event_code")
    }
  }

  public var eventType: Int {
    get {
      return snapshot["event_type"]! as! Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "event_type")
    }
  }

  public var eventTypeString: String {
    get {
      return snapshot["event_type_string"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "event_type_string")
    }
  }

  public var key: GraphQLID {
    get {
      return snapshot["key"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "key")
    }
  }

  public var address: String? {
    get {
      return snapshot["address"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "address")
    }
  }

  public var name: String {
    get {
      return snapshot["name"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "name")
    }
  }

  public var year: Int {
    get {
      return snapshot["year"]! as! Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "year")
    }
  }

  public var website: String? {
    get {
      return snapshot["website"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "website")
    }
  }

  public var locationName: String? {
    get {
      return snapshot["location_name"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "location_name")
    }
  }

  public var shortName: String? {
    get {
      return snapshot["short_name"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "short_name")
    }
  }
}

public struct Team: GraphQLFragment {
  public static let fragmentString =
    "fragment Team on Team {\n  __typename\n  key\n  address\n  city\n  state_prov\n  name\n  nickname\n  rookie_year\n  team_number\n  website\n}"

  public static let possibleTypes = ["Team"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("address", type: .scalar(String.self)),
    GraphQLField("city", type: .scalar(String.self)),
    GraphQLField("state_prov", type: .scalar(String.self)),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
    GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
    GraphQLField("rookie_year", type: .scalar(Int.self)),
    GraphQLField("team_number", type: .nonNull(.scalar(Int.self))),
    GraphQLField("website", type: .scalar(String.self)),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(key: GraphQLID, address: String? = nil, city: String? = nil, stateProv: String? = nil, name: String, nickname: String, rookieYear: Int? = nil, teamNumber: Int, website: String? = nil) {
    self.init(snapshot: ["__typename": "Team", "key": key, "address": address, "city": city, "state_prov": stateProv, "name": name, "nickname": nickname, "rookie_year": rookieYear, "team_number": teamNumber, "website": website])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var key: GraphQLID {
    get {
      return snapshot["key"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "key")
    }
  }

  public var address: String? {
    get {
      return snapshot["address"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "address")
    }
  }

  public var city: String? {
    get {
      return snapshot["city"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "city")
    }
  }

  public var stateProv: String? {
    get {
      return snapshot["state_prov"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "state_prov")
    }
  }

  public var name: String {
    get {
      return snapshot["name"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "name")
    }
  }

  public var nickname: String {
    get {
      return snapshot["nickname"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "nickname")
    }
  }

  public var rookieYear: Int? {
    get {
      return snapshot["rookie_year"] as? Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "rookie_year")
    }
  }

  public var teamNumber: Int {
    get {
      return snapshot["team_number"]! as! Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "team_number")
    }
  }

  public var website: String? {
    get {
      return snapshot["website"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "website")
    }
  }
}

public struct ScoutedTeam: GraphQLFragment {
  public static let fragmentString =
    "fragment ScoutedTeam on ScoutedTeam {\n  __typename\n  teamKey\n  userID\n  eventKey\n  attributes\n}"

  public static let possibleTypes = ["ScoutedTeam"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("teamKey", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("attributes", type: .scalar(String.self)),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(teamKey: GraphQLID, userId: GraphQLID, eventKey: String, attributes: String? = nil) {
    self.init(snapshot: ["__typename": "ScoutedTeam", "teamKey": teamKey, "userID": userId, "eventKey": eventKey, "attributes": attributes])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var teamKey: GraphQLID {
    get {
      return snapshot["teamKey"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "teamKey")
    }
  }

  public var userId: GraphQLID {
    get {
      return snapshot["userID"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "userID")
    }
  }

  public var eventKey: String {
    get {
      return snapshot["eventKey"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "eventKey")
    }
  }

  public var attributes: String? {
    get {
      return snapshot["attributes"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "attributes")
    }
  }
}

public struct Match: GraphQLFragment {
  public static let fragmentString =
    "fragment Match on Match {\n  __typename\n  key\n  event_key\n  comp_level\n  match_number\n  set_number\n  time\n  actual_time\n  predicted_time\n  alliances {\n    __typename\n    blue {\n      __typename\n      ...MatchAlliance\n    }\n    red {\n      __typename\n      ...MatchAlliance\n    }\n  }\n}"

  public static let possibleTypes = ["Match"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("event_key", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("comp_level", type: .nonNull(.scalar(CompetitionLevel.self))),
    GraphQLField("match_number", type: .nonNull(.scalar(Int.self))),
    GraphQLField("set_number", type: .scalar(Int.self)),
    GraphQLField("time", type: .scalar(Int.self)),
    GraphQLField("actual_time", type: .scalar(Int.self)),
    GraphQLField("predicted_time", type: .scalar(Int.self)),
    GraphQLField("alliances", type: .object(Alliance.selections)),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(key: GraphQLID, eventKey: GraphQLID, compLevel: CompetitionLevel, matchNumber: Int, setNumber: Int? = nil, time: Int? = nil, actualTime: Int? = nil, predictedTime: Int? = nil, alliances: Alliance? = nil) {
    self.init(snapshot: ["__typename": "Match", "key": key, "event_key": eventKey, "comp_level": compLevel, "match_number": matchNumber, "set_number": setNumber, "time": time, "actual_time": actualTime, "predicted_time": predictedTime, "alliances": alliances.flatMap { $0.snapshot }])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var key: GraphQLID {
    get {
      return snapshot["key"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "key")
    }
  }

  public var eventKey: GraphQLID {
    get {
      return snapshot["event_key"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "event_key")
    }
  }

  public var compLevel: CompetitionLevel {
    get {
      return snapshot["comp_level"]! as! CompetitionLevel
    }
    set {
      snapshot.updateValue(newValue, forKey: "comp_level")
    }
  }

  public var matchNumber: Int {
    get {
      return snapshot["match_number"]! as! Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "match_number")
    }
  }

  public var setNumber: Int? {
    get {
      return snapshot["set_number"] as? Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "set_number")
    }
  }

  public var time: Int? {
    get {
      return snapshot["time"] as? Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "time")
    }
  }

  public var actualTime: Int? {
    get {
      return snapshot["actual_time"] as? Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "actual_time")
    }
  }

  public var predictedTime: Int? {
    get {
      return snapshot["predicted_time"] as? Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "predicted_time")
    }
  }

  public var alliances: Alliance? {
    get {
      return (snapshot["alliances"] as? Snapshot).flatMap { Alliance(snapshot: $0) }
    }
    set {
      snapshot.updateValue(newValue?.snapshot, forKey: "alliances")
    }
  }

  public struct Alliance: GraphQLSelectionSet {
    public static let possibleTypes = ["MatchAlliances"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("blue", type: .object(Blue.selections)),
      GraphQLField("red", type: .object(Red.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(blue: Blue? = nil, red: Red? = nil) {
      self.init(snapshot: ["__typename": "MatchAlliances", "blue": blue.flatMap { $0.snapshot }, "red": red.flatMap { $0.snapshot }])
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "__typename")
      }
    }

    public var blue: Blue? {
      get {
        return (snapshot["blue"] as? Snapshot).flatMap { Blue(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "blue")
      }
    }

    public var red: Red? {
      get {
        return (snapshot["red"] as? Snapshot).flatMap { Red(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "red")
      }
    }

    public struct Blue: GraphQLSelectionSet {
      public static let possibleTypes = ["MatchAlliance"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("score", type: .nonNull(.scalar(Int.self))),
        GraphQLField("team_keys", type: .list(.scalar(String.self))),
        GraphQLField("surrogate_team_keys", type: .list(.scalar(String.self))),
        GraphQLField("dq_team_keys", type: .list(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(score: Int, teamKeys: [String?]? = nil, surrogateTeamKeys: [String?]? = nil, dqTeamKeys: [String?]? = nil) {
        self.init(snapshot: ["__typename": "MatchAlliance", "score": score, "team_keys": teamKeys, "surrogate_team_keys": surrogateTeamKeys, "dq_team_keys": dqTeamKeys])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var score: Int {
        get {
          return snapshot["score"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "score")
        }
      }

      public var teamKeys: [String?]? {
        get {
          return snapshot["team_keys"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "team_keys")
        }
      }

      public var surrogateTeamKeys: [String?]? {
        get {
          return snapshot["surrogate_team_keys"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "surrogate_team_keys")
        }
      }

      public var dqTeamKeys: [String?]? {
        get {
          return snapshot["dq_team_keys"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "dq_team_keys")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var matchAlliance: MatchAlliance {
          get {
            return MatchAlliance(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }

    public struct Red: GraphQLSelectionSet {
      public static let possibleTypes = ["MatchAlliance"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("score", type: .nonNull(.scalar(Int.self))),
        GraphQLField("team_keys", type: .list(.scalar(String.self))),
        GraphQLField("surrogate_team_keys", type: .list(.scalar(String.self))),
        GraphQLField("dq_team_keys", type: .list(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(score: Int, teamKeys: [String?]? = nil, surrogateTeamKeys: [String?]? = nil, dqTeamKeys: [String?]? = nil) {
        self.init(snapshot: ["__typename": "MatchAlliance", "score": score, "team_keys": teamKeys, "surrogate_team_keys": surrogateTeamKeys, "dq_team_keys": dqTeamKeys])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var score: Int {
        get {
          return snapshot["score"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "score")
        }
      }

      public var teamKeys: [String?]? {
        get {
          return snapshot["team_keys"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "team_keys")
        }
      }

      public var surrogateTeamKeys: [String?]? {
        get {
          return snapshot["surrogate_team_keys"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "surrogate_team_keys")
        }
      }

      public var dqTeamKeys: [String?]? {
        get {
          return snapshot["dq_team_keys"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "dq_team_keys")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var matchAlliance: MatchAlliance {
          get {
            return MatchAlliance(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public struct MatchAlliance: GraphQLFragment {
  public static let fragmentString =
    "fragment MatchAlliance on MatchAlliance {\n  __typename\n  score\n  team_keys\n  surrogate_team_keys\n  dq_team_keys\n}"

  public static let possibleTypes = ["MatchAlliance"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("score", type: .nonNull(.scalar(Int.self))),
    GraphQLField("team_keys", type: .list(.scalar(String.self))),
    GraphQLField("surrogate_team_keys", type: .list(.scalar(String.self))),
    GraphQLField("dq_team_keys", type: .list(.scalar(String.self))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(score: Int, teamKeys: [String?]? = nil, surrogateTeamKeys: [String?]? = nil, dqTeamKeys: [String?]? = nil) {
    self.init(snapshot: ["__typename": "MatchAlliance", "score": score, "team_keys": teamKeys, "surrogate_team_keys": surrogateTeamKeys, "dq_team_keys": dqTeamKeys])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var score: Int {
    get {
      return snapshot["score"]! as! Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "score")
    }
  }

  public var teamKeys: [String?]? {
    get {
      return snapshot["team_keys"] as? [String?]
    }
    set {
      snapshot.updateValue(newValue, forKey: "team_keys")
    }
  }

  public var surrogateTeamKeys: [String?]? {
    get {
      return snapshot["surrogate_team_keys"] as? [String?]
    }
    set {
      snapshot.updateValue(newValue, forKey: "surrogate_team_keys")
    }
  }

  public var dqTeamKeys: [String?]? {
    get {
      return snapshot["dq_team_keys"] as? [String?]
    }
    set {
      snapshot.updateValue(newValue, forKey: "dq_team_keys")
    }
  }
}

public struct ScoutSession: GraphQLFragment {
  public static let fragmentString =
    "fragment ScoutSession on ScoutSession {\n  __typename\n  key\n  matchKey\n  teamKey\n  userID\n  eventKey\n  startState\n  endState\n  timeMarkers {\n    __typename\n    ...TimeMarkerFragment\n  }\n}"

  public static let possibleTypes = ["ScoutSession"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("matchKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("startState", type: .scalar(String.self)),
    GraphQLField("endState", type: .scalar(String.self)),
    GraphQLField("timeMarkers", type: .list(.object(TimeMarker.selections))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(key: GraphQLID, matchKey: String, teamKey: String, userId: GraphQLID, eventKey: String, startState: String? = nil, endState: String? = nil, timeMarkers: [TimeMarker?]? = nil) {
    self.init(snapshot: ["__typename": "ScoutSession", "key": key, "matchKey": matchKey, "teamKey": teamKey, "userID": userId, "eventKey": eventKey, "startState": startState, "endState": endState, "timeMarkers": timeMarkers.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var key: GraphQLID {
    get {
      return snapshot["key"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "key")
    }
  }

  public var matchKey: String {
    get {
      return snapshot["matchKey"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "matchKey")
    }
  }

  public var teamKey: String {
    get {
      return snapshot["teamKey"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "teamKey")
    }
  }

  public var userId: GraphQLID {
    get {
      return snapshot["userID"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "userID")
    }
  }

  public var eventKey: String {
    get {
      return snapshot["eventKey"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "eventKey")
    }
  }

  public var startState: String? {
    get {
      return snapshot["startState"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "startState")
    }
  }

  public var endState: String? {
    get {
      return snapshot["endState"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "endState")
    }
  }

  public var timeMarkers: [TimeMarker?]? {
    get {
      return (snapshot["timeMarkers"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { TimeMarker(snapshot: $0) } } }
    }
    set {
      snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "timeMarkers")
    }
  }

  public struct TimeMarker: GraphQLSelectionSet {
    public static let possibleTypes = ["TimeMarker"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("event", type: .nonNull(.scalar(String.self))),
      GraphQLField("time", type: .nonNull(.scalar(Double.self))),
      GraphQLField("subOption", type: .scalar(String.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(event: String, time: Double, subOption: String? = nil) {
      self.init(snapshot: ["__typename": "TimeMarker", "event": event, "time": time, "subOption": subOption])
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "__typename")
      }
    }

    public var event: String {
      get {
        return snapshot["event"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "event")
      }
    }

    public var time: Double {
      get {
        return snapshot["time"]! as! Double
      }
      set {
        snapshot.updateValue(newValue, forKey: "time")
      }
    }

    public var subOption: String? {
      get {
        return snapshot["subOption"] as? String
      }
      set {
        snapshot.updateValue(newValue, forKey: "subOption")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(snapshot: snapshot)
      }
      set {
        snapshot += newValue.snapshot
      }
    }

    public struct Fragments {
      public var snapshot: Snapshot

      public var timeMarkerFragment: TimeMarkerFragment {
        get {
          return TimeMarkerFragment(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }
    }
  }
}

public struct TimeMarkerFragment: GraphQLFragment {
  public static let fragmentString =
    "fragment TimeMarkerFragment on TimeMarker {\n  __typename\n  event\n  time\n  subOption\n}"

  public static let possibleTypes = ["TimeMarker"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("event", type: .nonNull(.scalar(String.self))),
    GraphQLField("time", type: .nonNull(.scalar(Double.self))),
    GraphQLField("subOption", type: .scalar(String.self)),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(event: String, time: Double, subOption: String? = nil) {
    self.init(snapshot: ["__typename": "TimeMarker", "event": event, "time": time, "subOption": subOption])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var event: String {
    get {
      return snapshot["event"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "event")
    }
  }

  public var time: Double {
    get {
      return snapshot["time"]! as! Double
    }
    set {
      snapshot.updateValue(newValue, forKey: "time")
    }
  }

  public var subOption: String? {
    get {
      return snapshot["subOption"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "subOption")
    }
  }
}

public struct TeamEventOpr: GraphQLFragment {
  public static let fragmentString =
    "fragment TeamEventOPR on TeamEventOPR {\n  __typename\n  teamKey\n  eventKey\n  opr\n  dpr\n  ccwm\n}"

  public static let possibleTypes = ["TeamEventOPR"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("opr", type: .scalar(Double.self)),
    GraphQLField("dpr", type: .scalar(Double.self)),
    GraphQLField("ccwm", type: .scalar(Double.self)),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(teamKey: String, eventKey: String, opr: Double? = nil, dpr: Double? = nil, ccwm: Double? = nil) {
    self.init(snapshot: ["__typename": "TeamEventOPR", "teamKey": teamKey, "eventKey": eventKey, "opr": opr, "dpr": dpr, "ccwm": ccwm])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var teamKey: String {
    get {
      return snapshot["teamKey"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "teamKey")
    }
  }

  public var eventKey: String {
    get {
      return snapshot["eventKey"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "eventKey")
    }
  }

  public var opr: Double? {
    get {
      return snapshot["opr"] as? Double
    }
    set {
      snapshot.updateValue(newValue, forKey: "opr")
    }
  }

  public var dpr: Double? {
    get {
      return snapshot["dpr"] as? Double
    }
    set {
      snapshot.updateValue(newValue, forKey: "dpr")
    }
  }

  public var ccwm: Double? {
    get {
      return snapshot["ccwm"] as? Double
    }
    set {
      snapshot.updateValue(newValue, forKey: "ccwm")
    }
  }
}

public struct TeamEventStatus: GraphQLFragment {
  public static let fragmentString =
    "fragment TeamEventStatus on TeamEventStatus {\n  __typename\n  teamKey\n  eventKey\n  qual {\n    __typename\n    num_teams\n    status\n    ranking {\n      __typename\n      dq\n      matches_played\n      qual_average\n      rank\n    }\n  }\n  overall_status_str\n}"

  public static let possibleTypes = ["TeamEventStatus"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("qual", type: .object(Qual.selections)),
    GraphQLField("overall_status_str", type: .scalar(String.self)),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(teamKey: String, eventKey: String, qual: Qual? = nil, overallStatusStr: String? = nil) {
    self.init(snapshot: ["__typename": "TeamEventStatus", "teamKey": teamKey, "eventKey": eventKey, "qual": qual.flatMap { $0.snapshot }, "overall_status_str": overallStatusStr])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var teamKey: String {
    get {
      return snapshot["teamKey"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "teamKey")
    }
  }

  public var eventKey: String {
    get {
      return snapshot["eventKey"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "eventKey")
    }
  }

  public var qual: Qual? {
    get {
      return (snapshot["qual"] as? Snapshot).flatMap { Qual(snapshot: $0) }
    }
    set {
      snapshot.updateValue(newValue?.snapshot, forKey: "qual")
    }
  }

  public var overallStatusStr: String? {
    get {
      return snapshot["overall_status_str"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "overall_status_str")
    }
  }

  public struct Qual: GraphQLSelectionSet {
    public static let possibleTypes = ["TeamEventStatusRank"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("num_teams", type: .scalar(Int.self)),
      GraphQLField("status", type: .scalar(String.self)),
      GraphQLField("ranking", type: .object(Ranking.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(numTeams: Int? = nil, status: String? = nil, ranking: Ranking? = nil) {
      self.init(snapshot: ["__typename": "TeamEventStatusRank", "num_teams": numTeams, "status": status, "ranking": ranking.flatMap { $0.snapshot }])
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "__typename")
      }
    }

    public var numTeams: Int? {
      get {
        return snapshot["num_teams"] as? Int
      }
      set {
        snapshot.updateValue(newValue, forKey: "num_teams")
      }
    }

    public var status: String? {
      get {
        return snapshot["status"] as? String
      }
      set {
        snapshot.updateValue(newValue, forKey: "status")
      }
    }

    public var ranking: Ranking? {
      get {
        return (snapshot["ranking"] as? Snapshot).flatMap { Ranking(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "ranking")
      }
    }

    public struct Ranking: GraphQLSelectionSet {
      public static let possibleTypes = ["TeamEventStatusQualRanking"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("dq", type: .scalar(Int.self)),
        GraphQLField("matches_played", type: .scalar(Int.self)),
        GraphQLField("qual_average", type: .scalar(Double.self)),
        GraphQLField("rank", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(dq: Int? = nil, matchesPlayed: Int? = nil, qualAverage: Double? = nil, rank: Int? = nil) {
        self.init(snapshot: ["__typename": "TeamEventStatusQualRanking", "dq": dq, "matches_played": matchesPlayed, "qual_average": qualAverage, "rank": rank])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var dq: Int? {
        get {
          return snapshot["dq"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "dq")
        }
      }

      public var matchesPlayed: Int? {
        get {
          return snapshot["matches_played"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "matches_played")
        }
      }

      public var qualAverage: Double? {
        get {
          return snapshot["qual_average"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "qual_average")
        }
      }

      public var rank: Int? {
        get {
          return snapshot["rank"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "rank")
        }
      }
    }
  }
}

public struct TeamComment: GraphQLFragment {
  public static let fragmentString =
    "fragment TeamComment on TeamComment {\n  __typename\n  author\n  userID\n  body\n  datePosted\n  key\n  teamKey\n  eventKey\n}"

  public static let possibleTypes = ["TeamComment"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("author", type: .nonNull(.scalar(String.self))),
    GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("body", type: .nonNull(.scalar(String.self))),
    GraphQLField("datePosted", type: .nonNull(.scalar(Int.self))),
    GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(author: String, userId: GraphQLID, body: String, datePosted: Int, key: GraphQLID, teamKey: String, eventKey: String) {
    self.init(snapshot: ["__typename": "TeamComment", "author": author, "userID": userId, "body": body, "datePosted": datePosted, "key": key, "teamKey": teamKey, "eventKey": eventKey])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var author: String {
    get {
      return snapshot["author"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "author")
    }
  }

  public var userId: GraphQLID {
    get {
      return snapshot["userID"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "userID")
    }
  }

  public var body: String {
    get {
      return snapshot["body"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "body")
    }
  }

  public var datePosted: Int {
    get {
      return snapshot["datePosted"]! as! Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "datePosted")
    }
  }

  public var key: GraphQLID {
    get {
      return snapshot["key"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "key")
    }
  }

  public var teamKey: String {
    get {
      return snapshot["teamKey"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "teamKey")
    }
  }

  public var eventKey: String {
    get {
      return snapshot["eventKey"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "eventKey")
    }
  }
}
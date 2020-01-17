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

public struct S3ObjectInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(bucket: String, key: String, region: String, localUri: String, mimeType: String) {
    graphQLMap = ["bucket": bucket, "key": key, "region": region, "localUri": localUri, "mimeType": mimeType]
  }

  public var bucket: String {
    get {
      return graphQLMap["bucket"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bucket")
    }
  }

  public var key: String {
    get {
      return graphQLMap["key"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "key")
    }
  }

  public var region: String {
    get {
      return graphQLMap["region"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "region")
    }
  }

  public var localUri: String {
    get {
      return graphQLMap["localUri"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "localUri")
    }
  }

  public var mimeType: String {
    get {
      return graphQLMap["mimeType"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "mimeType")
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
    "mutation AddTrackedEvent($scoutTeam: ID!, $eventKey: ID!) {\n  addTrackedEvent(scoutTeam: $scoutTeam, eventKey: $eventKey) {\n    __typename\n    ...EventRanking\n  }\n}"

  public static var requestString: String { return operationString.appending(EventRanking.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("addTrackedEvent", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey")], type: .object(AddTrackedEvent.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String, scoutTeam: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "scoutTeam": scoutTeam, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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
    "mutation RemoveTrackedEvent($scoutTeam: ID!, $eventKey: ID!) {\n  removeTrackedEvent(scoutTeam: $scoutTeam, eventKey: $eventKey) {\n    __typename\n    eventKey\n    scoutTeam\n  }\n}"

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeTrackedEvent", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey")], type: .object(RemoveTrackedEvent.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: GraphQLID, scoutTeam: GraphQLID) {
        self.init(snapshot: ["__typename": "EventDeletion", "eventKey": eventKey, "scoutTeam": scoutTeam])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
        }
      }
    }
  }
}

public final class MoveRankedTeamMutation: GraphQLMutation {
  public static let operationString =
    "mutation MoveRankedTeam($scoutTeam: ID!, $eventKey: ID!, $teamKey: ID!, $toIndex: Int!) {\n  moveRankedTeam(scoutTeam: $scoutTeam, eventKey: $eventKey, teamKey: $teamKey, toIndex: $toIndex) {\n    __typename\n    ...EventRanking\n  }\n}"

  public static var requestString: String { return operationString.appending(EventRanking.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID
  public var teamKey: GraphQLID
  public var toIndex: Int

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID, teamKey: GraphQLID, toIndex: Int) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.teamKey = teamKey
    self.toIndex = toIndex
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "teamKey": teamKey, "toIndex": toIndex]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("moveRankedTeam", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey"), "toIndex": GraphQLVariable("toIndex")], type: .object(MoveRankedTeam.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String, scoutTeam: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "scoutTeam": scoutTeam, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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
    "mutation SetTeamPicked($scoutTeam: ID!, $eventKey: ID!, $teamKey: ID!, $isPicked: Boolean!) {\n  setTeamPicked(scoutTeam: $scoutTeam, eventKey: $eventKey, teamKey: $teamKey, isPicked: $isPicked) {\n    __typename\n    ...EventRanking\n  }\n}"

  public static var requestString: String { return operationString.appending(EventRanking.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID
  public var teamKey: GraphQLID
  public var isPicked: Bool

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID, teamKey: GraphQLID, isPicked: Bool) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.teamKey = teamKey
    self.isPicked = isPicked
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "teamKey": teamKey, "isPicked": isPicked]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("setTeamPicked", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey"), "isPicked": GraphQLVariable("isPicked")], type: .object(SetTeamPicked.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String, scoutTeam: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "scoutTeam": scoutTeam, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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
    "mutation UpdateScoutedTeam($scoutTeam: ID!, $eventKey: ID!, $teamKey: ID!, $image: S3ObjectInput, $attributes: AWSJSON!) {\n  updateScoutedTeam(scoutTeam: $scoutTeam, eventKey: $eventKey, teamKey: $teamKey, image: $image, attributes: $attributes) {\n    __typename\n    ...ScoutedTeam\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutedTeam.fragmentString).appending(Image.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID
  public var teamKey: GraphQLID
  public var image: S3ObjectInput?
  public var attributes: String

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID, teamKey: GraphQLID, image: S3ObjectInput? = nil, attributes: String) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.teamKey = teamKey
    self.image = image
    self.attributes = attributes
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "teamKey": teamKey, "image": image, "attributes": attributes]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateScoutedTeam", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey"), "image": GraphQLVariable("image"), "attributes": GraphQLVariable("attributes")], type: .object(UpdateScoutedTeam.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("attributes", type: .scalar(String.self)),
        GraphQLField("image", type: .object(Image.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamKey: GraphQLID, scoutTeam: GraphQLID, eventKey: String, attributes: String? = nil, image: Image? = nil) {
        self.init(snapshot: ["__typename": "ScoutedTeam", "teamKey": teamKey, "scoutTeam": scoutTeam, "eventKey": eventKey, "attributes": attributes, "image": image.flatMap { $0.snapshot }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

      public var image: Image? {
        get {
          return (snapshot["image"] as? Snapshot).flatMap { Image(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "image")
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

      public struct Image: GraphQLSelectionSet {
        public static let possibleTypes = ["Image"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
          GraphQLField("key", type: .nonNull(.scalar(String.self))),
          GraphQLField("region", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(bucket: String, key: String, region: String) {
          self.init(snapshot: ["__typename": "Image", "bucket": bucket, "key": key, "region": region])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var bucket: String {
          get {
            return snapshot["bucket"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bucket")
          }
        }

        public var key: String {
          get {
            return snapshot["key"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "key")
          }
        }

        public var region: String {
          get {
            return snapshot["region"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "region")
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

          public var image: Image {
            get {
              return Image(snapshot: snapshot)
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

public final class AddTeamCommentMutation: GraphQLMutation {
  public static let operationString =
    "mutation AddTeamComment($scoutTeam: ID!, $eventKey: String!, $teamKey: String!, $body: String!) {\n  addTeamComment(scoutTeam: $scoutTeam, eventKey: $eventKey, teamKey: $teamKey, body: $body) {\n    __typename\n    ...TeamComment\n  }\n}"

  public static var requestString: String { return operationString.appending(TeamComment.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: String
  public var teamKey: String
  public var body: String

  public init(scoutTeam: GraphQLID, eventKey: String, teamKey: String, body: String) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.teamKey = teamKey
    self.body = body
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "teamKey": teamKey, "body": body]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("addTeamComment", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey"), "body": GraphQLVariable("body")], type: .object(AddTeamComment.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("authorUserID", type: .nonNull(.scalar(GraphQLID.self))),
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

      public init(scoutTeam: GraphQLID, authorUserId: GraphQLID, body: String, datePosted: Int, key: GraphQLID, teamKey: String, eventKey: String) {
        self.init(snapshot: ["__typename": "TeamComment", "scoutTeam": scoutTeam, "authorUserID": authorUserId, "body": body, "datePosted": datePosted, "key": key, "teamKey": teamKey, "eventKey": eventKey])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
        }
      }

      public var authorUserId: GraphQLID {
        get {
          return snapshot["authorUserID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "authorUserID")
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
    "mutation RemoveTeamComment($scoutTeam: ID!, $eventKey: String!, $key: String!) {\n  removeTeamComment(scoutTeam: $scoutTeam, eventKey: $eventKey, key: $key) {\n    __typename\n    key\n    scoutTeam\n  }\n}"

  public var scoutTeam: GraphQLID
  public var eventKey: String
  public var key: String

  public init(scoutTeam: GraphQLID, eventKey: String, key: String) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.key = key
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "key": key]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeTeamComment", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "key": GraphQLVariable("key")], type: .object(RemoveTeamComment.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, scoutTeam: GraphQLID) {
        self.init(snapshot: ["__typename": "TeamComment", "key": key, "scoutTeam": scoutTeam])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
        }
      }
    }
  }
}

public final class CreateScoutSessionMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateScoutSession($scoutTeam: ID!, $eventKey: ID!, $teamKey: ID!, $matchKey: ID!, $recordedDate: AWSTimestamp!, $startState: AWSJSON, $endState: AWSJSON, $timeMarkers: [TimeMarkerInput]!) {\n  createScoutSession(scoutTeam: $scoutTeam, eventKey: $eventKey, teamKey: $teamKey, matchKey: $matchKey, recordedDate: $recordedDate, startState: $startState, endState: $endState, timeMarkers: $timeMarkers) {\n    __typename\n    ...ScoutSession\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutSession.fragmentString).appending(TimeMarkerFragment.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID
  public var teamKey: GraphQLID
  public var matchKey: GraphQLID
  public var recordedDate: Int
  public var startState: String?
  public var endState: String?
  public var timeMarkers: [TimeMarkerInput?]

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID, teamKey: GraphQLID, matchKey: GraphQLID, recordedDate: Int, startState: String? = nil, endState: String? = nil, timeMarkers: [TimeMarkerInput?]) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.teamKey = teamKey
    self.matchKey = matchKey
    self.recordedDate = recordedDate
    self.startState = startState
    self.endState = endState
    self.timeMarkers = timeMarkers
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "teamKey": teamKey, "matchKey": matchKey, "recordedDate": recordedDate, "startState": startState, "endState": endState, "timeMarkers": timeMarkers]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createScoutSession", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey"), "matchKey": GraphQLVariable("matchKey"), "recordedDate": GraphQLVariable("recordedDate"), "startState": GraphQLVariable("startState"), "endState": GraphQLVariable("endState"), "timeMarkers": GraphQLVariable("timeMarkers")], type: .object(CreateScoutSession.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("recordedDate", type: .scalar(Double.self)),
        GraphQLField("startState", type: .scalar(String.self)),
        GraphQLField("endState", type: .scalar(String.self)),
        GraphQLField("timeMarkers", type: .list(.object(TimeMarker.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, matchKey: String, teamKey: String, scoutTeam: GraphQLID, eventKey: String, recordedDate: Double? = nil, startState: String? = nil, endState: String? = nil, timeMarkers: [TimeMarker?]? = nil) {
        self.init(snapshot: ["__typename": "ScoutSession", "key": key, "matchKey": matchKey, "teamKey": teamKey, "scoutTeam": scoutTeam, "eventKey": eventKey, "recordedDate": recordedDate, "startState": startState, "endState": endState, "timeMarkers": timeMarkers.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

      public var recordedDate: Double? {
        get {
          return snapshot["recordedDate"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "recordedDate")
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
    "mutation RemoveScoutSession($scoutTeam: ID!, $eventKey: ID!, $key: ID!) {\n  removeScoutSession(scoutTeam: $scoutTeam, eventKey: $eventKey, key: $key) {\n    __typename\n    scoutTeam\n    key\n    matchKey\n    teamKey\n    eventKey\n  }\n}"

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID
  public var key: GraphQLID

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID, key: GraphQLID) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.key = key
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "key": key]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeScoutSession", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "key": GraphQLVariable("key")], type: .object(RemoveScoutSession.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("matchKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(scoutTeam: GraphQLID, key: GraphQLID, matchKey: String, teamKey: String, eventKey: String) {
        self.init(snapshot: ["__typename": "ScoutSession", "scoutTeam": scoutTeam, "key": key, "matchKey": matchKey, "teamKey": teamKey, "eventKey": eventKey])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

public final class CreateScoutingTeamMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateScoutingTeam($name: String!, $associatedFrcTeamNumber: Int!, $leadName: String!) {\n  createScoutingTeam(name: $name, associatedFrcTeamNumber: $associatedFrcTeamNumber, leadName: $leadName) {\n    __typename\n    ...ScoutingTeam\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutingTeam.fragmentString) }

  public var name: String
  public var associatedFrcTeamNumber: Int
  public var leadName: String

  public init(name: String, associatedFrcTeamNumber: Int, leadName: String) {
    self.name = name
    self.associatedFrcTeamNumber = associatedFrcTeamNumber
    self.leadName = leadName
  }

  public var variables: GraphQLMap? {
    return ["name": name, "associatedFrcTeamNumber": associatedFrcTeamNumber, "leadName": leadName]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createScoutingTeam", arguments: ["name": GraphQLVariable("name"), "associatedFrcTeamNumber": GraphQLVariable("associatedFrcTeamNumber"), "leadName": GraphQLVariable("leadName")], type: .object(CreateScoutingTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createScoutingTeam: CreateScoutingTeam? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createScoutingTeam": createScoutingTeam.flatMap { $0.snapshot }])
    }

    /// # Scouting Team Management
    public var createScoutingTeam: CreateScoutingTeam? {
      get {
        return (snapshot["createScoutingTeam"] as? Snapshot).flatMap { CreateScoutingTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createScoutingTeam")
      }
    }

    public struct CreateScoutingTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutingTeam"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("teamLead", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("associatedFrcTeamNumber", type: .nonNull(.scalar(Int.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamId: GraphQLID, teamLead: GraphQLID, associatedFrcTeamNumber: Int, name: String) {
        self.init(snapshot: ["__typename": "ScoutingTeam", "teamID": teamId, "teamLead": teamLead, "associatedFrcTeamNumber": associatedFrcTeamNumber, "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var teamId: GraphQLID {
        get {
          return snapshot["teamID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamID")
        }
      }

      /// # List of members
      public var teamLead: GraphQLID {
        get {
          return snapshot["teamLead"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamLead")
        }
      }

      /// # Team lead is also a member, so his/her info will be in the members dict
      public var associatedFrcTeamNumber: Int {
        get {
          return snapshot["associatedFrcTeamNumber"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "associatedFrcTeamNumber")
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

        public var scoutingTeam: ScoutingTeam {
          get {
            return ScoutingTeam(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class MakeScoutTeamInvitationMutation: GraphQLMutation {
  public static let operationString =
    "mutation MakeScoutTeamInvitation($scoutTeam: ID!, $expDate: AWSTimestamp!) {\n  makeScoutTeamInvitation(scoutTeam: $scoutTeam, expDate: $expDate) {\n    __typename\n    ...ScoutTeamInvitation\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutTeamInvitation.fragmentString) }

  public var scoutTeam: GraphQLID
  public var expDate: Int

  public init(scoutTeam: GraphQLID, expDate: Int) {
    self.scoutTeam = scoutTeam
    self.expDate = expDate
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "expDate": expDate]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("makeScoutTeamInvitation", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "expDate": GraphQLVariable("expDate")], type: .object(MakeScoutTeamInvitation.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(makeScoutTeamInvitation: MakeScoutTeamInvitation? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "makeScoutTeamInvitation": makeScoutTeamInvitation.flatMap { $0.snapshot }])
    }

    public var makeScoutTeamInvitation: MakeScoutTeamInvitation? {
      get {
        return (snapshot["makeScoutTeamInvitation"] as? Snapshot).flatMap { MakeScoutTeamInvitation(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "makeScoutTeamInvitation")
      }
    }

    public struct MakeScoutTeamInvitation: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutTeamInvitation"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("inviteID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("teamID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("secretCode", type: .nonNull(.scalar(String.self))),
        GraphQLField("expDate", type: .scalar(Int.self)),
        GraphQLField("creatorUserID", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(inviteId: GraphQLID, teamId: GraphQLID, secretCode: String, expDate: Int? = nil, creatorUserId: GraphQLID) {
        self.init(snapshot: ["__typename": "ScoutTeamInvitation", "inviteID": inviteId, "teamID": teamId, "secretCode": secretCode, "expDate": expDate, "creatorUserID": creatorUserId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var inviteId: GraphQLID {
        get {
          return snapshot["inviteID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "inviteID")
        }
      }

      public var teamId: GraphQLID {
        get {
          return snapshot["teamID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamID")
        }
      }

      public var secretCode: String {
        get {
          return snapshot["secretCode"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "secretCode")
        }
      }

      public var expDate: Int? {
        get {
          return snapshot["expDate"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "expDate")
        }
      }

      public var creatorUserId: GraphQLID {
        get {
          return snapshot["creatorUserID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "creatorUserID")
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

        public var scoutTeamInvitation: ScoutTeamInvitation {
          get {
            return ScoutTeamInvitation(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class RedeemInvitationMutation: GraphQLMutation {
  public static let operationString =
    "mutation RedeemInvitation($inviteID: ID!, $secretCode: String!, $memberName: String!) {\n  redeemInvitation(inviteID: $inviteID, secretCode: $secretCode, memberName: $memberName)\n}"

  public var inviteID: GraphQLID
  public var secretCode: String
  public var memberName: String

  public init(inviteID: GraphQLID, secretCode: String, memberName: String) {
    self.inviteID = inviteID
    self.secretCode = secretCode
    self.memberName = memberName
  }

  public var variables: GraphQLMap? {
    return ["inviteID": inviteID, "secretCode": secretCode, "memberName": memberName]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("redeemInvitation", arguments: ["inviteID": GraphQLVariable("inviteID"), "secretCode": GraphQLVariable("secretCode"), "memberName": GraphQLVariable("memberName")], type: .scalar(GraphQLID.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(redeemInvitation: GraphQLID? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "redeemInvitation": redeemInvitation])
    }

    public var redeemInvitation: GraphQLID? {
      get {
        return snapshot["redeemInvitation"] as? GraphQLID
      }
      set {
        snapshot.updateValue(newValue, forKey: "redeemInvitation")
      }
    }
  }
}

public final class ChangeMemberNameMutation: GraphQLMutation {
  public static let operationString =
    "mutation ChangeMemberName($scoutTeam: ID!, $newName: String!) {\n  changeMemberName(scoutTeam: $scoutTeam, newName: $newName) {\n    __typename\n    ...ScoutingTeamMember\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutingTeamMember.fragmentString) }

  public var scoutTeam: GraphQLID
  public var newName: String

  public init(scoutTeam: GraphQLID, newName: String) {
    self.scoutTeam = scoutTeam
    self.newName = newName
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "newName": newName]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("changeMemberName", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "newName": GraphQLVariable("newName")], type: .object(ChangeMemberName.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(changeMemberName: ChangeMemberName? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "changeMemberName": changeMemberName.flatMap { $0.snapshot }])
    }

    public var changeMemberName: ChangeMemberName? {
      get {
        return (snapshot["changeMemberName"] as? Snapshot).flatMap { ChangeMemberName(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "changeMemberName")
      }
    }

    public struct ChangeMemberName: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutingTeamMember"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .scalar(String.self)),
        GraphQLField("memberSince", type: .nonNull(.scalar(Int.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(userId: GraphQLID, name: String? = nil, memberSince: Int) {
        self.init(snapshot: ["__typename": "ScoutingTeamMember", "userID": userId, "name": name, "memberSince": memberSince])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
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

      public var name: String? {
        get {
          return snapshot["name"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var memberSince: Int {
        get {
          return snapshot["memberSince"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "memberSince")
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

        public var scoutingTeamMember: ScoutingTeamMember {
          get {
            return ScoutingTeamMember(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class EditScoutingTeamInfoMutation: GraphQLMutation {
  public static let operationString =
    "mutation EditScoutingTeamInfo($scoutTeam: ID!, $name: String!, $asscoiatedFrcTeamNumber: Int!) {\n  editScoutingTeamInfo(scoutTeam: $scoutTeam, name: $name, associatedFrcTeamNumber: $asscoiatedFrcTeamNumber) {\n    __typename\n    ...ScoutingTeam\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutingTeam.fragmentString) }

  public var scoutTeam: GraphQLID
  public var name: String
  public var asscoiatedFrcTeamNumber: Int

  public init(scoutTeam: GraphQLID, name: String, asscoiatedFrcTeamNumber: Int) {
    self.scoutTeam = scoutTeam
    self.name = name
    self.asscoiatedFrcTeamNumber = asscoiatedFrcTeamNumber
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "name": name, "asscoiatedFrcTeamNumber": asscoiatedFrcTeamNumber]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("editScoutingTeamInfo", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "name": GraphQLVariable("name"), "associatedFrcTeamNumber": GraphQLVariable("asscoiatedFrcTeamNumber")], type: .object(EditScoutingTeamInfo.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(editScoutingTeamInfo: EditScoutingTeamInfo? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "editScoutingTeamInfo": editScoutingTeamInfo.flatMap { $0.snapshot }])
    }

    public var editScoutingTeamInfo: EditScoutingTeamInfo? {
      get {
        return (snapshot["editScoutingTeamInfo"] as? Snapshot).flatMap { EditScoutingTeamInfo(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "editScoutingTeamInfo")
      }
    }

    public struct EditScoutingTeamInfo: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutingTeam"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("teamLead", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("associatedFrcTeamNumber", type: .nonNull(.scalar(Int.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamId: GraphQLID, teamLead: GraphQLID, associatedFrcTeamNumber: Int, name: String) {
        self.init(snapshot: ["__typename": "ScoutingTeam", "teamID": teamId, "teamLead": teamLead, "associatedFrcTeamNumber": associatedFrcTeamNumber, "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var teamId: GraphQLID {
        get {
          return snapshot["teamID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamID")
        }
      }

      /// # List of members
      public var teamLead: GraphQLID {
        get {
          return snapshot["teamLead"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamLead")
        }
      }

      /// # Team lead is also a member, so his/her info will be in the members dict
      public var associatedFrcTeamNumber: Int {
        get {
          return snapshot["associatedFrcTeamNumber"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "associatedFrcTeamNumber")
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

        public var scoutingTeam: ScoutingTeam {
          get {
            return ScoutingTeam(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class RemoveMemberMutation: GraphQLMutation {
  public static let operationString =
    "mutation RemoveMember($scoutTeam: ID!, $userToRemove: ID!) {\n  removeMember(scoutTeam: $scoutTeam, userToRemove: $userToRemove)\n}"

  public var scoutTeam: GraphQLID
  public var userToRemove: GraphQLID

  public init(scoutTeam: GraphQLID, userToRemove: GraphQLID) {
    self.scoutTeam = scoutTeam
    self.userToRemove = userToRemove
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "userToRemove": userToRemove]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeMember", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "userToRemove": GraphQLVariable("userToRemove")], type: .scalar(Bool.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(removeMember: Bool? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "removeMember": removeMember])
    }

    /// # Members should be able to remove themselves, leads should be able to remove anyone except themselves
    public var removeMember: Bool? {
      get {
        return snapshot["removeMember"] as? Bool
      }
      set {
        snapshot.updateValue(newValue, forKey: "removeMember")
      }
    }
  }
}

public final class TransferLeadMutation: GraphQLMutation {
  public static let operationString =
    "mutation TransferLead($scoutTeam: ID!, $newTeamLeadUserId: ID!) {\n  transferLead(scoutTeam: $scoutTeam, newTeamLeadUserId: $newTeamLeadUserId) {\n    __typename\n    ...ScoutingTeam\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutingTeam.fragmentString) }

  public var scoutTeam: GraphQLID
  public var newTeamLeadUserId: GraphQLID

  public init(scoutTeam: GraphQLID, newTeamLeadUserId: GraphQLID) {
    self.scoutTeam = scoutTeam
    self.newTeamLeadUserId = newTeamLeadUserId
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "newTeamLeadUserId": newTeamLeadUserId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("transferLead", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "newTeamLeadUserId": GraphQLVariable("newTeamLeadUserId")], type: .object(TransferLead.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(transferLead: TransferLead? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "transferLead": transferLead.flatMap { $0.snapshot }])
    }

    /// #Must do check to make sure it is not the lead
    public var transferLead: TransferLead? {
      get {
        return (snapshot["transferLead"] as? Snapshot).flatMap { TransferLead(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "transferLead")
      }
    }

    public struct TransferLead: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutingTeam"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("teamLead", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("associatedFrcTeamNumber", type: .nonNull(.scalar(Int.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamId: GraphQLID, teamLead: GraphQLID, associatedFrcTeamNumber: Int, name: String) {
        self.init(snapshot: ["__typename": "ScoutingTeam", "teamID": teamId, "teamLead": teamLead, "associatedFrcTeamNumber": associatedFrcTeamNumber, "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var teamId: GraphQLID {
        get {
          return snapshot["teamID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamID")
        }
      }

      /// # List of members
      public var teamLead: GraphQLID {
        get {
          return snapshot["teamLead"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamLead")
        }
      }

      /// # Team lead is also a member, so his/her info will be in the members dict
      public var associatedFrcTeamNumber: Int {
        get {
          return snapshot["associatedFrcTeamNumber"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "associatedFrcTeamNumber")
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

        public var scoutingTeam: ScoutingTeam {
          get {
            return ScoutingTeam(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class GetCompetitionModelQuery: GraphQLQuery {
  public static let operationString =
    "query GetCompetitionModel($year: String) {\n  getCompetitionModel(year: $year)\n}"

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
      GraphQLField("getCompetitionModel", arguments: ["year": GraphQLVariable("year")], type: .scalar(String.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getCompetitionModel: String? = nil) {
      self.init(snapshot: ["__typename": "Query", "getCompetitionModel": getCompetitionModel])
    }

    public var getCompetitionModel: String? {
      get {
        return snapshot["getCompetitionModel"] as? String
      }
      set {
        snapshot.updateValue(newValue, forKey: "getCompetitionModel")
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

    /// # The Blue Alliance Universal Calls
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

public final class ListTrackedEventsQuery: GraphQLQuery {
  public static let operationString =
    "query ListTrackedEvents($scoutTeam: ID!) {\n  listTrackedEvents(scoutTeam: $scoutTeam) {\n    __typename\n    ...EventRanking\n  }\n}"

  public static var requestString: String { return operationString.appending(EventRanking.fragmentString) }

  public var scoutTeam: GraphQLID

  public init(scoutTeam: GraphQLID) {
    self.scoutTeam = scoutTeam
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listTrackedEvents", arguments: ["scoutTeam": GraphQLVariable("scoutTeam")], type: .list(.object(ListTrackedEvent.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listTrackedEvents: [ListTrackedEvent?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listTrackedEvents": listTrackedEvents.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    /// # Scout Team Data Calls
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
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventName", type: .nonNull(.scalar(String.self))),
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String, scoutTeam: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "scoutTeam": scoutTeam, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

public final class GetEventRankingQuery: GraphQLQuery {
  public static let operationString =
    "query GetEventRanking($scoutTeam: ID!, $key: ID!) {\n  getEventRanking(scoutTeam: $scoutTeam, key: $key) {\n    __typename\n    ...EventRanking\n  }\n}"

  public static var requestString: String { return operationString.appending(EventRanking.fragmentString) }

  public var scoutTeam: GraphQLID
  public var key: GraphQLID

  public init(scoutTeam: GraphQLID, key: GraphQLID) {
    self.scoutTeam = scoutTeam
    self.key = key
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "key": key]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getEventRanking", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "key": GraphQLVariable("key")], type: .object(GetEventRanking.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String, scoutTeam: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "scoutTeam": scoutTeam, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

public final class ListScoutedTeamsQuery: GraphQLQuery {
  public static let operationString =
    "query ListScoutedTeams($scoutTeam: ID!, $eventKey: ID!) {\n  listScoutedTeams(scoutTeam: $scoutTeam, eventKey: $eventKey) {\n    __typename\n    ...ScoutedTeam\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutedTeam.fragmentString).appending(Image.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listScoutedTeams", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey")], type: .list(.object(ListScoutedTeam.selections))),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("attributes", type: .scalar(String.self)),
        GraphQLField("image", type: .object(Image.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamKey: GraphQLID, scoutTeam: GraphQLID, eventKey: String, attributes: String? = nil, image: Image? = nil) {
        self.init(snapshot: ["__typename": "ScoutedTeam", "teamKey": teamKey, "scoutTeam": scoutTeam, "eventKey": eventKey, "attributes": attributes, "image": image.flatMap { $0.snapshot }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

      public var image: Image? {
        get {
          return (snapshot["image"] as? Snapshot).flatMap { Image(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "image")
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

      public struct Image: GraphQLSelectionSet {
        public static let possibleTypes = ["Image"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
          GraphQLField("key", type: .nonNull(.scalar(String.self))),
          GraphQLField("region", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(bucket: String, key: String, region: String) {
          self.init(snapshot: ["__typename": "Image", "bucket": bucket, "key": key, "region": region])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var bucket: String {
          get {
            return snapshot["bucket"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bucket")
          }
        }

        public var key: String {
          get {
            return snapshot["key"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "key")
          }
        }

        public var region: String {
          get {
            return snapshot["region"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "region")
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

          public var image: Image {
            get {
              return Image(snapshot: snapshot)
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

public final class GetScoutedTeamQuery: GraphQLQuery {
  public static let operationString =
    "query GetScoutedTeam($scoutTeam: ID!, $eventKey: ID!, $teamKey: ID!) {\n  getScoutedTeam(scoutTeam: $scoutTeam, eventKey: $eventKey, teamKey: $teamKey) {\n    __typename\n    ...ScoutedTeam\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutedTeam.fragmentString).appending(Image.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID
  public var teamKey: GraphQLID

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID, teamKey: GraphQLID) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.teamKey = teamKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "teamKey": teamKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getScoutedTeam", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey")], type: .object(GetScoutedTeam.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("attributes", type: .scalar(String.self)),
        GraphQLField("image", type: .object(Image.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamKey: GraphQLID, scoutTeam: GraphQLID, eventKey: String, attributes: String? = nil, image: Image? = nil) {
        self.init(snapshot: ["__typename": "ScoutedTeam", "teamKey": teamKey, "scoutTeam": scoutTeam, "eventKey": eventKey, "attributes": attributes, "image": image.flatMap { $0.snapshot }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

      public var image: Image? {
        get {
          return (snapshot["image"] as? Snapshot).flatMap { Image(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "image")
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

      public struct Image: GraphQLSelectionSet {
        public static let possibleTypes = ["Image"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
          GraphQLField("key", type: .nonNull(.scalar(String.self))),
          GraphQLField("region", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(bucket: String, key: String, region: String) {
          self.init(snapshot: ["__typename": "Image", "bucket": bucket, "key": key, "region": region])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var bucket: String {
          get {
            return snapshot["bucket"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bucket")
          }
        }

        public var key: String {
          get {
            return snapshot["key"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "key")
          }
        }

        public var region: String {
          get {
            return snapshot["region"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "region")
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

          public var image: Image {
            get {
              return Image(snapshot: snapshot)
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

public final class ListTeamCommentsQuery: GraphQLQuery {
  public static let operationString =
    "query ListTeamComments($scoutTeam: ID!, $eventKey: ID!, $teamKey: ID!) {\n  listTeamComments(scoutTeam: $scoutTeam, eventKey: $eventKey, teamKey: $teamKey) {\n    __typename\n    ...TeamComment\n  }\n}"

  public static var requestString: String { return operationString.appending(TeamComment.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID
  public var teamKey: GraphQLID

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID, teamKey: GraphQLID) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.teamKey = teamKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "teamKey": teamKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listTeamComments", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey")], type: .list(.object(ListTeamComment.selections))),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("authorUserID", type: .nonNull(.scalar(GraphQLID.self))),
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

      public init(scoutTeam: GraphQLID, authorUserId: GraphQLID, body: String, datePosted: Int, key: GraphQLID, teamKey: String, eventKey: String) {
        self.init(snapshot: ["__typename": "TeamComment", "scoutTeam": scoutTeam, "authorUserID": authorUserId, "body": body, "datePosted": datePosted, "key": key, "teamKey": teamKey, "eventKey": eventKey])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
        }
      }

      public var authorUserId: GraphQLID {
        get {
          return snapshot["authorUserID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "authorUserID")
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

public final class ListScoutSessionsQuery: GraphQLQuery {
  public static let operationString =
    "query ListScoutSessions($scoutTeam: ID!, $eventKey: ID!, $teamKey: ID!, $matchKey: ID) {\n  listScoutSessions(scoutTeam: $scoutTeam, eventKey: $eventKey, teamKey: $teamKey, matchKey: $matchKey) {\n    __typename\n    ...ScoutSession\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutSession.fragmentString).appending(TimeMarkerFragment.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID
  public var teamKey: GraphQLID
  public var matchKey: GraphQLID?

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID, teamKey: GraphQLID, matchKey: GraphQLID? = nil) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.teamKey = teamKey
    self.matchKey = matchKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "teamKey": teamKey, "matchKey": matchKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listScoutSessions", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey"), "matchKey": GraphQLVariable("matchKey")], type: .list(.object(ListScoutSession.selections))),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("recordedDate", type: .scalar(Double.self)),
        GraphQLField("startState", type: .scalar(String.self)),
        GraphQLField("endState", type: .scalar(String.self)),
        GraphQLField("timeMarkers", type: .list(.object(TimeMarker.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, matchKey: String, teamKey: String, scoutTeam: GraphQLID, eventKey: String, recordedDate: Double? = nil, startState: String? = nil, endState: String? = nil, timeMarkers: [TimeMarker?]? = nil) {
        self.init(snapshot: ["__typename": "ScoutSession", "key": key, "matchKey": matchKey, "teamKey": teamKey, "scoutTeam": scoutTeam, "eventKey": eventKey, "recordedDate": recordedDate, "startState": startState, "endState": endState, "timeMarkers": timeMarkers.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

      public var recordedDate: Double? {
        get {
          return snapshot["recordedDate"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "recordedDate")
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

public final class ListSimpleScoutSessionsQuery: GraphQLQuery {
  public static let operationString =
    "query ListSimpleScoutSessions($scoutTeam: ID!, $eventKey: ID!, $teamKey: ID!, $matchKey: ID) {\n  listScoutSessions(scoutTeam: $scoutTeam, eventKey: $eventKey, teamKey: $teamKey, matchKey: $matchKey) {\n    __typename\n    key\n    matchKey\n    teamKey\n    eventKey\n    scoutTeam\n  }\n}"

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID
  public var teamKey: GraphQLID
  public var matchKey: GraphQLID?

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID, teamKey: GraphQLID, matchKey: GraphQLID? = nil) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.teamKey = teamKey
    self.matchKey = matchKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "teamKey": teamKey, "matchKey": matchKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listScoutSessions", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey"), "matchKey": GraphQLVariable("matchKey")], type: .list(.object(ListScoutSession.selections))),
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
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("matchKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, matchKey: String, teamKey: String, eventKey: String, scoutTeam: GraphQLID) {
        self.init(snapshot: ["__typename": "ScoutSession", "key": key, "matchKey": matchKey, "teamKey": teamKey, "eventKey": eventKey, "scoutTeam": scoutTeam])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
        }
      }
    }
  }
}

public final class GetScoutSessionQuery: GraphQLQuery {
  public static let operationString =
    "query GetScoutSession($scoutTeam: ID!, $eventKey: ID!, $key: ID!) {\n  getScoutSession(scoutTeam: $scoutTeam, eventKey: $eventKey, key: $key) {\n    __typename\n    ...ScoutSession\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutSession.fragmentString).appending(TimeMarkerFragment.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID
  public var key: GraphQLID

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID, key: GraphQLID) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.key = key
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "key": key]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getScoutSession", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "key": GraphQLVariable("key")], type: .object(GetScoutSession.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("recordedDate", type: .scalar(Double.self)),
        GraphQLField("startState", type: .scalar(String.self)),
        GraphQLField("endState", type: .scalar(String.self)),
        GraphQLField("timeMarkers", type: .list(.object(TimeMarker.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, matchKey: String, teamKey: String, scoutTeam: GraphQLID, eventKey: String, recordedDate: Double? = nil, startState: String? = nil, endState: String? = nil, timeMarkers: [TimeMarker?]? = nil) {
        self.init(snapshot: ["__typename": "ScoutSession", "key": key, "matchKey": matchKey, "teamKey": teamKey, "scoutTeam": scoutTeam, "eventKey": eventKey, "recordedDate": recordedDate, "startState": startState, "endState": endState, "timeMarkers": timeMarkers.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

      public var recordedDate: Double? {
        get {
          return snapshot["recordedDate"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "recordedDate")
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

public final class ListAllScoutSessionsQuery: GraphQLQuery {
  public static let operationString =
    "query ListAllScoutSessions($scoutTeam: ID!, $eventKey: ID!) {\n  listAllScoutSessions(scoutTeam: $scoutTeam, eventKey: $eventKey) {\n    __typename\n    ...ScoutSession\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutSession.fragmentString).appending(TimeMarkerFragment.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listAllScoutSessions", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey")], type: .list(.object(ListAllScoutSession.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listAllScoutSessions: [ListAllScoutSession?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listAllScoutSessions": listAllScoutSessions.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    /// # Delta Sync
    public var listAllScoutSessions: [ListAllScoutSession?]? {
      get {
        return (snapshot["listAllScoutSessions"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListAllScoutSession(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listAllScoutSessions")
      }
    }

    public struct ListAllScoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("matchKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("recordedDate", type: .scalar(Double.self)),
        GraphQLField("startState", type: .scalar(String.self)),
        GraphQLField("endState", type: .scalar(String.self)),
        GraphQLField("timeMarkers", type: .list(.object(TimeMarker.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, matchKey: String, teamKey: String, scoutTeam: GraphQLID, eventKey: String, recordedDate: Double? = nil, startState: String? = nil, endState: String? = nil, timeMarkers: [TimeMarker?]? = nil) {
        self.init(snapshot: ["__typename": "ScoutSession", "key": key, "matchKey": matchKey, "teamKey": teamKey, "scoutTeam": scoutTeam, "eventKey": eventKey, "recordedDate": recordedDate, "startState": startState, "endState": endState, "timeMarkers": timeMarkers.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

      public var recordedDate: Double? {
        get {
          return snapshot["recordedDate"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "recordedDate")
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

public final class ListScoutSessionsDeltaQuery: GraphQLQuery {
  public static let operationString =
    "query ListScoutSessionsDelta($scoutTeam: ID!, $eventKey: ID!, $lastSync: AWSTimestamp!) {\n  listScoutSessionsDelta(scoutTeam: $scoutTeam, eventKey: $eventKey, lastSync: $lastSync) {\n    __typename\n    ...ScoutSession\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutSession.fragmentString).appending(TimeMarkerFragment.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID
  public var lastSync: Int

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID, lastSync: Int) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.lastSync = lastSync
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "lastSync": lastSync]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listScoutSessionsDelta", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "lastSync": GraphQLVariable("lastSync")], type: .list(.object(ListScoutSessionsDeltum.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listScoutSessionsDelta: [ListScoutSessionsDeltum?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listScoutSessionsDelta": listScoutSessionsDelta.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    public var listScoutSessionsDelta: [ListScoutSessionsDeltum?]? {
      get {
        return (snapshot["listScoutSessionsDelta"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListScoutSessionsDeltum(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listScoutSessionsDelta")
      }
    }

    public struct ListScoutSessionsDeltum: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("matchKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("recordedDate", type: .scalar(Double.self)),
        GraphQLField("startState", type: .scalar(String.self)),
        GraphQLField("endState", type: .scalar(String.self)),
        GraphQLField("timeMarkers", type: .list(.object(TimeMarker.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, matchKey: String, teamKey: String, scoutTeam: GraphQLID, eventKey: String, recordedDate: Double? = nil, startState: String? = nil, endState: String? = nil, timeMarkers: [TimeMarker?]? = nil) {
        self.init(snapshot: ["__typename": "ScoutSession", "key": key, "matchKey": matchKey, "teamKey": teamKey, "scoutTeam": scoutTeam, "eventKey": eventKey, "recordedDate": recordedDate, "startState": startState, "endState": endState, "timeMarkers": timeMarkers.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

      public var recordedDate: Double? {
        get {
          return snapshot["recordedDate"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "recordedDate")
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

public final class ListEnrolledScoutingTeamsQuery: GraphQLQuery {
  public static let operationString =
    "query ListEnrolledScoutingTeams {\n  listEnrolledScoutingTeams {\n    __typename\n    ...ScoutingTeam\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutingTeam.fragmentString) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listEnrolledScoutingTeams", type: .list(.object(ListEnrolledScoutingTeam.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listEnrolledScoutingTeams: [ListEnrolledScoutingTeam?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listEnrolledScoutingTeams": listEnrolledScoutingTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    /// # Scouting Teams
    public var listEnrolledScoutingTeams: [ListEnrolledScoutingTeam?]? {
      get {
        return (snapshot["listEnrolledScoutingTeams"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListEnrolledScoutingTeam(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listEnrolledScoutingTeams")
      }
    }

    public struct ListEnrolledScoutingTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutingTeam"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("teamLead", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("associatedFrcTeamNumber", type: .nonNull(.scalar(Int.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamId: GraphQLID, teamLead: GraphQLID, associatedFrcTeamNumber: Int, name: String) {
        self.init(snapshot: ["__typename": "ScoutingTeam", "teamID": teamId, "teamLead": teamLead, "associatedFrcTeamNumber": associatedFrcTeamNumber, "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var teamId: GraphQLID {
        get {
          return snapshot["teamID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamID")
        }
      }

      /// # List of members
      public var teamLead: GraphQLID {
        get {
          return snapshot["teamLead"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamLead")
        }
      }

      /// # Team lead is also a member, so his/her info will be in the members dict
      public var associatedFrcTeamNumber: Int {
        get {
          return snapshot["associatedFrcTeamNumber"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "associatedFrcTeamNumber")
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

        public var scoutingTeam: ScoutingTeam {
          get {
            return ScoutingTeam(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class ListEnrolledScoutingTeamsWithMembersQuery: GraphQLQuery {
  public static let operationString =
    "query ListEnrolledScoutingTeamsWithMembers {\n  listEnrolledScoutingTeams {\n    __typename\n    ...ScoutingTeamWithMembers\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutingTeamWithMembers.fragmentString).appending(ScoutingTeamMember.fragmentString) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listEnrolledScoutingTeams", type: .list(.object(ListEnrolledScoutingTeam.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listEnrolledScoutingTeams: [ListEnrolledScoutingTeam?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listEnrolledScoutingTeams": listEnrolledScoutingTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    /// # Scouting Teams
    public var listEnrolledScoutingTeams: [ListEnrolledScoutingTeam?]? {
      get {
        return (snapshot["listEnrolledScoutingTeams"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListEnrolledScoutingTeam(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listEnrolledScoutingTeams")
      }
    }

    public struct ListEnrolledScoutingTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutingTeam"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("teamLead", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("associatedFrcTeamNumber", type: .nonNull(.scalar(Int.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("members", type: .list(.object(Member.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamId: GraphQLID, teamLead: GraphQLID, associatedFrcTeamNumber: Int, name: String, members: [Member?]? = nil) {
        self.init(snapshot: ["__typename": "ScoutingTeam", "teamID": teamId, "teamLead": teamLead, "associatedFrcTeamNumber": associatedFrcTeamNumber, "name": name, "members": members.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var teamId: GraphQLID {
        get {
          return snapshot["teamID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamID")
        }
      }

      /// # List of members
      public var teamLead: GraphQLID {
        get {
          return snapshot["teamLead"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamLead")
        }
      }

      /// # Team lead is also a member, so his/her info will be in the members dict
      public var associatedFrcTeamNumber: Int {
        get {
          return snapshot["associatedFrcTeamNumber"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "associatedFrcTeamNumber")
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

      /// # Scouting Team UUID
      public var members: [Member?]? {
        get {
          return (snapshot["members"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Member(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "members")
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

        public var scoutingTeamWithMembers: ScoutingTeamWithMembers {
          get {
            return ScoutingTeamWithMembers(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct Member: GraphQLSelectionSet {
        public static let possibleTypes = ["ScoutingTeamMember"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .scalar(String.self)),
          GraphQLField("memberSince", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(userId: GraphQLID, name: String? = nil, memberSince: Int) {
          self.init(snapshot: ["__typename": "ScoutingTeamMember", "userID": userId, "name": name, "memberSince": memberSince])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
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

        public var name: String? {
          get {
            return snapshot["name"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var memberSince: Int {
          get {
            return snapshot["memberSince"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "memberSince")
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

          public var scoutingTeamMember: ScoutingTeamMember {
            get {
              return ScoutingTeamMember(snapshot: snapshot)
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

public final class GetScoutingTeamQuery: GraphQLQuery {
  public static let operationString =
    "query GetScoutingTeam($scoutTeam: ID!) {\n  getScoutingTeam(scoutTeam: $scoutTeam) {\n    __typename\n    ...ScoutingTeam\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutingTeam.fragmentString) }

  public var scoutTeam: GraphQLID

  public init(scoutTeam: GraphQLID) {
    self.scoutTeam = scoutTeam
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getScoutingTeam", arguments: ["scoutTeam": GraphQLVariable("scoutTeam")], type: .object(GetScoutingTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getScoutingTeam: GetScoutingTeam? = nil) {
      self.init(snapshot: ["__typename": "Query", "getScoutingTeam": getScoutingTeam.flatMap { $0.snapshot }])
    }

    public var getScoutingTeam: GetScoutingTeam? {
      get {
        return (snapshot["getScoutingTeam"] as? Snapshot).flatMap { GetScoutingTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getScoutingTeam")
      }
    }

    public struct GetScoutingTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutingTeam"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("teamLead", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("associatedFrcTeamNumber", type: .nonNull(.scalar(Int.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamId: GraphQLID, teamLead: GraphQLID, associatedFrcTeamNumber: Int, name: String) {
        self.init(snapshot: ["__typename": "ScoutingTeam", "teamID": teamId, "teamLead": teamLead, "associatedFrcTeamNumber": associatedFrcTeamNumber, "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var teamId: GraphQLID {
        get {
          return snapshot["teamID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamID")
        }
      }

      /// # List of members
      public var teamLead: GraphQLID {
        get {
          return snapshot["teamLead"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamLead")
        }
      }

      /// # Team lead is also a member, so his/her info will be in the members dict
      public var associatedFrcTeamNumber: Int {
        get {
          return snapshot["associatedFrcTeamNumber"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "associatedFrcTeamNumber")
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

        public var scoutingTeam: ScoutingTeam {
          get {
            return ScoutingTeam(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }
    }
  }
}

public final class GetScoutingTeamWithMembersQuery: GraphQLQuery {
  public static let operationString =
    "query GetScoutingTeamWithMembers($scoutTeam: ID!) {\n  getScoutingTeam(scoutTeam: $scoutTeam) {\n    __typename\n    ...ScoutingTeamWithMembers\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutingTeamWithMembers.fragmentString).appending(ScoutingTeamMember.fragmentString) }

  public var scoutTeam: GraphQLID

  public init(scoutTeam: GraphQLID) {
    self.scoutTeam = scoutTeam
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getScoutingTeam", arguments: ["scoutTeam": GraphQLVariable("scoutTeam")], type: .object(GetScoutingTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getScoutingTeam: GetScoutingTeam? = nil) {
      self.init(snapshot: ["__typename": "Query", "getScoutingTeam": getScoutingTeam.flatMap { $0.snapshot }])
    }

    public var getScoutingTeam: GetScoutingTeam? {
      get {
        return (snapshot["getScoutingTeam"] as? Snapshot).flatMap { GetScoutingTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getScoutingTeam")
      }
    }

    public struct GetScoutingTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutingTeam"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("teamLead", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("associatedFrcTeamNumber", type: .nonNull(.scalar(Int.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("members", type: .list(.object(Member.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamId: GraphQLID, teamLead: GraphQLID, associatedFrcTeamNumber: Int, name: String, members: [Member?]? = nil) {
        self.init(snapshot: ["__typename": "ScoutingTeam", "teamID": teamId, "teamLead": teamLead, "associatedFrcTeamNumber": associatedFrcTeamNumber, "name": name, "members": members.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var teamId: GraphQLID {
        get {
          return snapshot["teamID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamID")
        }
      }

      /// # List of members
      public var teamLead: GraphQLID {
        get {
          return snapshot["teamLead"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamLead")
        }
      }

      /// # Team lead is also a member, so his/her info will be in the members dict
      public var associatedFrcTeamNumber: Int {
        get {
          return snapshot["associatedFrcTeamNumber"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "associatedFrcTeamNumber")
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

      /// # Scouting Team UUID
      public var members: [Member?]? {
        get {
          return (snapshot["members"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Member(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "members")
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

        public var scoutingTeamWithMembers: ScoutingTeamWithMembers {
          get {
            return ScoutingTeamWithMembers(snapshot: snapshot)
          }
          set {
            snapshot += newValue.snapshot
          }
        }
      }

      public struct Member: GraphQLSelectionSet {
        public static let possibleTypes = ["ScoutingTeamMember"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .scalar(String.self)),
          GraphQLField("memberSince", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(userId: GraphQLID, name: String? = nil, memberSince: Int) {
          self.init(snapshot: ["__typename": "ScoutingTeamMember", "userID": userId, "name": name, "memberSince": memberSince])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
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

        public var name: String? {
          get {
            return snapshot["name"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var memberSince: Int {
          get {
            return snapshot["memberSince"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "memberSince")
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

          public var scoutingTeamMember: ScoutingTeamMember {
            get {
              return ScoutingTeamMember(snapshot: snapshot)
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

public final class GetScoutingTeamPublicNameQuery: GraphQLQuery {
  public static let operationString =
    "query GetScoutingTeamPublicName($inviteID: ID!) {\n  getScoutingTeamPublicName(inviteID: $inviteID)\n}"

  public var inviteID: GraphQLID

  public init(inviteID: GraphQLID) {
    self.inviteID = inviteID
  }

  public var variables: GraphQLMap? {
    return ["inviteID": inviteID]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getScoutingTeamPublicName", arguments: ["inviteID": GraphQLVariable("inviteID")], type: .scalar(String.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getScoutingTeamPublicName: String? = nil) {
      self.init(snapshot: ["__typename": "Query", "getScoutingTeamPublicName": getScoutingTeamPublicName])
    }

    public var getScoutingTeamPublicName: String? {
      get {
        return snapshot["getScoutingTeamPublicName"] as? String
      }
      set {
        snapshot.updateValue(newValue, forKey: "getScoutingTeamPublicName")
      }
    }
  }
}

public final class ListScoutingTeamInvitationsQuery: GraphQLQuery {
  public static let operationString =
    "query ListScoutingTeamInvitations($scoutTeam: ID!) {\n  listScoutingTeamInvitations(scoutTeam: $scoutTeam) {\n    __typename\n    ...ScoutTeamInvitation\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutTeamInvitation.fragmentString) }

  public var scoutTeam: GraphQLID

  public init(scoutTeam: GraphQLID) {
    self.scoutTeam = scoutTeam
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listScoutingTeamInvitations", arguments: ["scoutTeam": GraphQLVariable("scoutTeam")], type: .list(.object(ListScoutingTeamInvitation.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listScoutingTeamInvitations: [ListScoutingTeamInvitation?]? = nil) {
      self.init(snapshot: ["__typename": "Query", "listScoutingTeamInvitations": listScoutingTeamInvitations.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
    }

    public var listScoutingTeamInvitations: [ListScoutingTeamInvitation?]? {
      get {
        return (snapshot["listScoutingTeamInvitations"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { ListScoutingTeamInvitation(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "listScoutingTeamInvitations")
      }
    }

    public struct ListScoutingTeamInvitation: GraphQLSelectionSet {
      public static let possibleTypes = ["ScoutTeamInvitation"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("inviteID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("teamID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("secretCode", type: .nonNull(.scalar(String.self))),
        GraphQLField("expDate", type: .scalar(Int.self)),
        GraphQLField("creatorUserID", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(inviteId: GraphQLID, teamId: GraphQLID, secretCode: String, expDate: Int? = nil, creatorUserId: GraphQLID) {
        self.init(snapshot: ["__typename": "ScoutTeamInvitation", "inviteID": inviteId, "teamID": teamId, "secretCode": secretCode, "expDate": expDate, "creatorUserID": creatorUserId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var inviteId: GraphQLID {
        get {
          return snapshot["inviteID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "inviteID")
        }
      }

      public var teamId: GraphQLID {
        get {
          return snapshot["teamID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamID")
        }
      }

      public var secretCode: String {
        get {
          return snapshot["secretCode"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "secretCode")
        }
      }

      public var expDate: Int? {
        get {
          return snapshot["expDate"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "expDate")
        }
      }

      public var creatorUserId: GraphQLID {
        get {
          return snapshot["creatorUserID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "creatorUserID")
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

        public var scoutTeamInvitation: ScoutTeamInvitation {
          get {
            return ScoutTeamInvitation(snapshot: snapshot)
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
    "subscription OnAddTrackedEvent($scoutTeam: ID!) {\n  onAddTrackedEvent(scoutTeam: $scoutTeam) {\n    __typename\n    scoutTeam\n    eventKey\n    eventName\n  }\n}"

  public var scoutTeam: GraphQLID

  public init(scoutTeam: GraphQLID) {
    self.scoutTeam = scoutTeam
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onAddTrackedEvent", arguments: ["scoutTeam": GraphQLVariable("scoutTeam")], type: .object(OnAddTrackedEvent.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventName", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(scoutTeam: GraphQLID, eventKey: String, eventName: String) {
        self.init(snapshot: ["__typename": "EventRanking", "scoutTeam": scoutTeam, "eventKey": eventKey, "eventName": eventName])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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
    "subscription OnRemoveTrackedEvent($scoutTeam: ID!) {\n  onRemoveTrackedEvent(scoutTeam: $scoutTeam) {\n    __typename\n    eventKey\n    scoutTeam\n  }\n}"

  public var scoutTeam: GraphQLID

  public init(scoutTeam: GraphQLID) {
    self.scoutTeam = scoutTeam
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onRemoveTrackedEvent", arguments: ["scoutTeam": GraphQLVariable("scoutTeam")], type: .object(OnRemoveTrackedEvent.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: GraphQLID, scoutTeam: GraphQLID) {
        self.init(snapshot: ["__typename": "EventDeletion", "eventKey": eventKey, "scoutTeam": scoutTeam])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
        }
      }
    }
  }
}

public final class OnUpdateTeamRankSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateTeamRank($scoutTeam: ID!, $eventKey: String!) {\n  onUpdateTeamRank(scoutTeam: $scoutTeam, eventKey: $eventKey) {\n    __typename\n    ...EventRanking\n  }\n}"

  public static var requestString: String { return operationString.appending(EventRanking.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: String

  public init(scoutTeam: GraphQLID, eventKey: String) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateTeamRank", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey")], type: .object(OnUpdateTeamRank.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String, scoutTeam: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "scoutTeam": scoutTeam, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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
    "subscription OnSetTeamPicked($scoutTeam: ID!, $eventKey: String!) {\n  onSetTeamPicked(scoutTeam: $scoutTeam, eventKey: $eventKey) {\n    __typename\n    ...EventRanking\n  }\n}"

  public static var requestString: String { return operationString.appending(EventRanking.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: String

  public init(scoutTeam: GraphQLID, eventKey: String) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onSetTeamPicked", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey")], type: .object(OnSetTeamPicked.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(eventKey: String, eventName: String, scoutTeam: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
        self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "scoutTeam": scoutTeam, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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
    "subscription OnUpdateScoutedTeam($scoutTeam: ID!, $eventKey: ID!, $teamKey: ID) {\n  onUpdateScoutedTeam(scoutTeam: $scoutTeam, eventKey: $eventKey, teamKey: $teamKey) {\n    __typename\n    ...ScoutedTeam\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutedTeam.fragmentString).appending(Image.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID
  public var teamKey: GraphQLID?

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID, teamKey: GraphQLID? = nil) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.teamKey = teamKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "teamKey": teamKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateScoutedTeam", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey")], type: .object(OnUpdateScoutedTeam.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("attributes", type: .scalar(String.self)),
        GraphQLField("image", type: .object(Image.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamKey: GraphQLID, scoutTeam: GraphQLID, eventKey: String, attributes: String? = nil, image: Image? = nil) {
        self.init(snapshot: ["__typename": "ScoutedTeam", "teamKey": teamKey, "scoutTeam": scoutTeam, "eventKey": eventKey, "attributes": attributes, "image": image.flatMap { $0.snapshot }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

      public var image: Image? {
        get {
          return (snapshot["image"] as? Snapshot).flatMap { Image(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "image")
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

      public struct Image: GraphQLSelectionSet {
        public static let possibleTypes = ["Image"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
          GraphQLField("key", type: .nonNull(.scalar(String.self))),
          GraphQLField("region", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(bucket: String, key: String, region: String) {
          self.init(snapshot: ["__typename": "Image", "bucket": bucket, "key": key, "region": region])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var bucket: String {
          get {
            return snapshot["bucket"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bucket")
          }
        }

        public var key: String {
          get {
            return snapshot["key"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "key")
          }
        }

        public var region: String {
          get {
            return snapshot["region"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "region")
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

          public var image: Image {
            get {
              return Image(snapshot: snapshot)
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

public final class OnUpdateScoutedTeamsSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateScoutedTeams($scoutTeam: ID!, $eventKey: ID!) {\n  onUpdateScoutedTeam(scoutTeam: $scoutTeam, eventKey: $eventKey) {\n    __typename\n    ...ScoutedTeam\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutedTeam.fragmentString).appending(Image.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: GraphQLID

  public init(scoutTeam: GraphQLID, eventKey: GraphQLID) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateScoutedTeam", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey")], type: .object(OnUpdateScoutedTeam.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("attributes", type: .scalar(String.self)),
        GraphQLField("image", type: .object(Image.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(teamKey: GraphQLID, scoutTeam: GraphQLID, eventKey: String, attributes: String? = nil, image: Image? = nil) {
        self.init(snapshot: ["__typename": "ScoutedTeam", "teamKey": teamKey, "scoutTeam": scoutTeam, "eventKey": eventKey, "attributes": attributes, "image": image.flatMap { $0.snapshot }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

      public var image: Image? {
        get {
          return (snapshot["image"] as? Snapshot).flatMap { Image(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "image")
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

      public struct Image: GraphQLSelectionSet {
        public static let possibleTypes = ["Image"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
          GraphQLField("key", type: .nonNull(.scalar(String.self))),
          GraphQLField("region", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(bucket: String, key: String, region: String) {
          self.init(snapshot: ["__typename": "Image", "bucket": bucket, "key": key, "region": region])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var bucket: String {
          get {
            return snapshot["bucket"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bucket")
          }
        }

        public var key: String {
          get {
            return snapshot["key"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "key")
          }
        }

        public var region: String {
          get {
            return snapshot["region"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "region")
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

          public var image: Image {
            get {
              return Image(snapshot: snapshot)
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

public final class OnAddTeamCommentSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnAddTeamComment($scoutTeam: ID!, $teamKey: String!) {\n  onAddTeamComment(scoutTeam: $scoutTeam, teamKey: $teamKey) {\n    __typename\n    ...TeamComment\n  }\n}"

  public static var requestString: String { return operationString.appending(TeamComment.fragmentString) }

  public var scoutTeam: GraphQLID
  public var teamKey: String

  public init(scoutTeam: GraphQLID, teamKey: String) {
    self.scoutTeam = scoutTeam
    self.teamKey = teamKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "teamKey": teamKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onAddTeamComment", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "teamKey": GraphQLVariable("teamKey")], type: .object(OnAddTeamComment.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("authorUserID", type: .nonNull(.scalar(GraphQLID.self))),
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

      public init(scoutTeam: GraphQLID, authorUserId: GraphQLID, body: String, datePosted: Int, key: GraphQLID, teamKey: String, eventKey: String) {
        self.init(snapshot: ["__typename": "TeamComment", "scoutTeam": scoutTeam, "authorUserID": authorUserId, "body": body, "datePosted": datePosted, "key": key, "teamKey": teamKey, "eventKey": eventKey])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
        }
      }

      public var authorUserId: GraphQLID {
        get {
          return snapshot["authorUserID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "authorUserID")
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

public final class OnCreateScoutSessionSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateScoutSession($scoutTeam: ID!, $eventKey: String!, $teamKey: String) {\n  onCreateScoutSession(scoutTeam: $scoutTeam, eventKey: $eventKey, teamKey: $teamKey) {\n    __typename\n    ...ScoutSession\n  }\n}"

  public static var requestString: String { return operationString.appending(ScoutSession.fragmentString).appending(TimeMarkerFragment.fragmentString) }

  public var scoutTeam: GraphQLID
  public var eventKey: String
  public var teamKey: String?

  public init(scoutTeam: GraphQLID, eventKey: String, teamKey: String? = nil) {
    self.scoutTeam = scoutTeam
    self.eventKey = eventKey
    self.teamKey = teamKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "eventKey": eventKey, "teamKey": teamKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateScoutSession", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "eventKey": GraphQLVariable("eventKey"), "teamKey": GraphQLVariable("teamKey")], type: .object(OnCreateScoutSession.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("recordedDate", type: .scalar(Double.self)),
        GraphQLField("startState", type: .scalar(String.self)),
        GraphQLField("endState", type: .scalar(String.self)),
        GraphQLField("timeMarkers", type: .list(.object(TimeMarker.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(key: GraphQLID, matchKey: String, teamKey: String, scoutTeam: GraphQLID, eventKey: String, recordedDate: Double? = nil, startState: String? = nil, endState: String? = nil, timeMarkers: [TimeMarker?]? = nil) {
        self.init(snapshot: ["__typename": "ScoutSession", "key": key, "matchKey": matchKey, "teamKey": teamKey, "scoutTeam": scoutTeam, "eventKey": eventKey, "recordedDate": recordedDate, "startState": startState, "endState": endState, "timeMarkers": timeMarkers.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

      public var recordedDate: Double? {
        get {
          return snapshot["recordedDate"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "recordedDate")
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
    "subscription OnDeleteScoutSession($scoutTeam: ID!, $key: ID, $matchKey: String, $teamKey: String) {\n  onDeleteScoutSession(scoutTeam: $scoutTeam, key: $key, matchKey: $matchKey, teamKey: $teamKey) {\n    __typename\n    scoutTeam\n    key\n    matchKey\n    teamKey\n    eventKey\n  }\n}"

  public var scoutTeam: GraphQLID
  public var key: GraphQLID?
  public var matchKey: String?
  public var teamKey: String?

  public init(scoutTeam: GraphQLID, key: GraphQLID? = nil, matchKey: String? = nil, teamKey: String? = nil) {
    self.scoutTeam = scoutTeam
    self.key = key
    self.matchKey = matchKey
    self.teamKey = teamKey
  }

  public var variables: GraphQLMap? {
    return ["scoutTeam": scoutTeam, "key": key, "matchKey": matchKey, "teamKey": teamKey]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteScoutSession", arguments: ["scoutTeam": GraphQLVariable("scoutTeam"), "key": GraphQLVariable("key"), "matchKey": GraphQLVariable("matchKey"), "teamKey": GraphQLVariable("teamKey")], type: .object(OnDeleteScoutSession.selections)),
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
        GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("matchKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(scoutTeam: GraphQLID, key: GraphQLID, matchKey: String, teamKey: String, eventKey: String) {
        self.init(snapshot: ["__typename": "ScoutSession", "scoutTeam": scoutTeam, "key": key, "matchKey": matchKey, "teamKey": teamKey, "eventKey": eventKey])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var scoutTeam: GraphQLID {
        get {
          return snapshot["scoutTeam"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "scoutTeam")
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

public struct EventRanking: GraphQLFragment {
  public static let fragmentString =
    "fragment EventRanking on EventRanking {\n  __typename\n  eventKey\n  eventName\n  scoutTeam\n  rankedTeams {\n    __typename\n    teamKey\n    isPicked\n  }\n}"

  public static let possibleTypes = ["EventRanking"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("eventName", type: .nonNull(.scalar(String.self))),
    GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("rankedTeams", type: .list(.object(RankedTeam.selections))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(eventKey: String, eventName: String, scoutTeam: GraphQLID, rankedTeams: [RankedTeam?]? = nil) {
    self.init(snapshot: ["__typename": "EventRanking", "eventKey": eventKey, "eventName": eventName, "scoutTeam": scoutTeam, "rankedTeams": rankedTeams.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

  public var scoutTeam: GraphQLID {
    get {
      return snapshot["scoutTeam"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "scoutTeam")
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

public struct Image: GraphQLFragment {
  public static let fragmentString =
    "fragment Image on Image {\n  __typename\n  bucket\n  key\n  region\n}"

  public static let possibleTypes = ["Image"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
    GraphQLField("key", type: .nonNull(.scalar(String.self))),
    GraphQLField("region", type: .nonNull(.scalar(String.self))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(bucket: String, key: String, region: String) {
    self.init(snapshot: ["__typename": "Image", "bucket": bucket, "key": key, "region": region])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var bucket: String {
    get {
      return snapshot["bucket"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "bucket")
    }
  }

  public var key: String {
    get {
      return snapshot["key"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "key")
    }
  }

  public var region: String {
    get {
      return snapshot["region"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "region")
    }
  }
}

public struct ScoutedTeam: GraphQLFragment {
  public static let fragmentString =
    "fragment ScoutedTeam on ScoutedTeam {\n  __typename\n  teamKey\n  scoutTeam\n  eventKey\n  attributes\n  image {\n    __typename\n    ...Image\n  }\n}"

  public static let possibleTypes = ["ScoutedTeam"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("teamKey", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("attributes", type: .scalar(String.self)),
    GraphQLField("image", type: .object(Image.selections)),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(teamKey: GraphQLID, scoutTeam: GraphQLID, eventKey: String, attributes: String? = nil, image: Image? = nil) {
    self.init(snapshot: ["__typename": "ScoutedTeam", "teamKey": teamKey, "scoutTeam": scoutTeam, "eventKey": eventKey, "attributes": attributes, "image": image.flatMap { $0.snapshot }])
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

  public var scoutTeam: GraphQLID {
    get {
      return snapshot["scoutTeam"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "scoutTeam")
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

  public var image: Image? {
    get {
      return (snapshot["image"] as? Snapshot).flatMap { Image(snapshot: $0) }
    }
    set {
      snapshot.updateValue(newValue?.snapshot, forKey: "image")
    }
  }

  public struct Image: GraphQLSelectionSet {
    public static let possibleTypes = ["Image"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
      GraphQLField("key", type: .nonNull(.scalar(String.self))),
      GraphQLField("region", type: .nonNull(.scalar(String.self))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(bucket: String, key: String, region: String) {
      self.init(snapshot: ["__typename": "Image", "bucket": bucket, "key": key, "region": region])
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "__typename")
      }
    }

    public var bucket: String {
      get {
        return snapshot["bucket"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "bucket")
      }
    }

    public var key: String {
      get {
        return snapshot["key"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "key")
      }
    }

    public var region: String {
      get {
        return snapshot["region"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "region")
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

      public var image: Image {
        get {
          return Image(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }
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
    "fragment ScoutSession on ScoutSession {\n  __typename\n  key\n  matchKey\n  teamKey\n  scoutTeam\n  eventKey\n  recordedDate\n  startState\n  endState\n  timeMarkers {\n    __typename\n    ...TimeMarkerFragment\n  }\n}"

  public static let possibleTypes = ["ScoutSession"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("key", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("matchKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("teamKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("eventKey", type: .nonNull(.scalar(String.self))),
    GraphQLField("recordedDate", type: .scalar(Double.self)),
    GraphQLField("startState", type: .scalar(String.self)),
    GraphQLField("endState", type: .scalar(String.self)),
    GraphQLField("timeMarkers", type: .list(.object(TimeMarker.selections))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(key: GraphQLID, matchKey: String, teamKey: String, scoutTeam: GraphQLID, eventKey: String, recordedDate: Double? = nil, startState: String? = nil, endState: String? = nil, timeMarkers: [TimeMarker?]? = nil) {
    self.init(snapshot: ["__typename": "ScoutSession", "key": key, "matchKey": matchKey, "teamKey": teamKey, "scoutTeam": scoutTeam, "eventKey": eventKey, "recordedDate": recordedDate, "startState": startState, "endState": endState, "timeMarkers": timeMarkers.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
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

  public var scoutTeam: GraphQLID {
    get {
      return snapshot["scoutTeam"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "scoutTeam")
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

  public var recordedDate: Double? {
    get {
      return snapshot["recordedDate"] as? Double
    }
    set {
      snapshot.updateValue(newValue, forKey: "recordedDate")
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
    "fragment TeamComment on TeamComment {\n  __typename\n  scoutTeam\n  authorUserID\n  body\n  datePosted\n  key\n  teamKey\n  eventKey\n}"

  public static let possibleTypes = ["TeamComment"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("scoutTeam", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("authorUserID", type: .nonNull(.scalar(GraphQLID.self))),
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

  public init(scoutTeam: GraphQLID, authorUserId: GraphQLID, body: String, datePosted: Int, key: GraphQLID, teamKey: String, eventKey: String) {
    self.init(snapshot: ["__typename": "TeamComment", "scoutTeam": scoutTeam, "authorUserID": authorUserId, "body": body, "datePosted": datePosted, "key": key, "teamKey": teamKey, "eventKey": eventKey])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var scoutTeam: GraphQLID {
    get {
      return snapshot["scoutTeam"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "scoutTeam")
    }
  }

  public var authorUserId: GraphQLID {
    get {
      return snapshot["authorUserID"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "authorUserID")
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

public struct ScoutingTeam: GraphQLFragment {
  public static let fragmentString =
    "fragment ScoutingTeam on ScoutingTeam {\n  __typename\n  teamID\n  teamLead\n  associatedFrcTeamNumber\n  name\n}"

  public static let possibleTypes = ["ScoutingTeam"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("teamID", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("teamLead", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("associatedFrcTeamNumber", type: .nonNull(.scalar(Int.self))),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(teamId: GraphQLID, teamLead: GraphQLID, associatedFrcTeamNumber: Int, name: String) {
    self.init(snapshot: ["__typename": "ScoutingTeam", "teamID": teamId, "teamLead": teamLead, "associatedFrcTeamNumber": associatedFrcTeamNumber, "name": name])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var teamId: GraphQLID {
    get {
      return snapshot["teamID"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "teamID")
    }
  }

  /// # List of members
  public var teamLead: GraphQLID {
    get {
      return snapshot["teamLead"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "teamLead")
    }
  }

  /// # Team lead is also a member, so his/her info will be in the members dict
  public var associatedFrcTeamNumber: Int {
    get {
      return snapshot["associatedFrcTeamNumber"]! as! Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "associatedFrcTeamNumber")
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
}

public struct ScoutingTeamWithMembers: GraphQLFragment {
  public static let fragmentString =
    "fragment ScoutingTeamWithMembers on ScoutingTeam {\n  __typename\n  teamID\n  teamLead\n  associatedFrcTeamNumber\n  name\n  members {\n    __typename\n    ...ScoutingTeamMember\n  }\n}"

  public static let possibleTypes = ["ScoutingTeam"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("teamID", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("teamLead", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("associatedFrcTeamNumber", type: .nonNull(.scalar(Int.self))),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
    GraphQLField("members", type: .list(.object(Member.selections))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(teamId: GraphQLID, teamLead: GraphQLID, associatedFrcTeamNumber: Int, name: String, members: [Member?]? = nil) {
    self.init(snapshot: ["__typename": "ScoutingTeam", "teamID": teamId, "teamLead": teamLead, "associatedFrcTeamNumber": associatedFrcTeamNumber, "name": name, "members": members.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var teamId: GraphQLID {
    get {
      return snapshot["teamID"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "teamID")
    }
  }

  /// # List of members
  public var teamLead: GraphQLID {
    get {
      return snapshot["teamLead"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "teamLead")
    }
  }

  /// # Team lead is also a member, so his/her info will be in the members dict
  public var associatedFrcTeamNumber: Int {
    get {
      return snapshot["associatedFrcTeamNumber"]! as! Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "associatedFrcTeamNumber")
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

  /// # Scouting Team UUID
  public var members: [Member?]? {
    get {
      return (snapshot["members"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Member(snapshot: $0) } } }
    }
    set {
      snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "members")
    }
  }

  public struct Member: GraphQLSelectionSet {
    public static let possibleTypes = ["ScoutingTeamMember"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
      GraphQLField("name", type: .scalar(String.self)),
      GraphQLField("memberSince", type: .nonNull(.scalar(Int.self))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(userId: GraphQLID, name: String? = nil, memberSince: Int) {
      self.init(snapshot: ["__typename": "ScoutingTeamMember", "userID": userId, "name": name, "memberSince": memberSince])
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "__typename")
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

    public var name: String? {
      get {
        return snapshot["name"] as? String
      }
      set {
        snapshot.updateValue(newValue, forKey: "name")
      }
    }

    public var memberSince: Int {
      get {
        return snapshot["memberSince"]! as! Int
      }
      set {
        snapshot.updateValue(newValue, forKey: "memberSince")
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

      public var scoutingTeamMember: ScoutingTeamMember {
        get {
          return ScoutingTeamMember(snapshot: snapshot)
        }
        set {
          snapshot += newValue.snapshot
        }
      }
    }
  }
}

public struct ScoutTeamInvitation: GraphQLFragment {
  public static let fragmentString =
    "fragment ScoutTeamInvitation on ScoutTeamInvitation {\n  __typename\n  inviteID\n  teamID\n  secretCode\n  expDate\n  creatorUserID\n}"

  public static let possibleTypes = ["ScoutTeamInvitation"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("inviteID", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("teamID", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("secretCode", type: .nonNull(.scalar(String.self))),
    GraphQLField("expDate", type: .scalar(Int.self)),
    GraphQLField("creatorUserID", type: .nonNull(.scalar(GraphQLID.self))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(inviteId: GraphQLID, teamId: GraphQLID, secretCode: String, expDate: Int? = nil, creatorUserId: GraphQLID) {
    self.init(snapshot: ["__typename": "ScoutTeamInvitation", "inviteID": inviteId, "teamID": teamId, "secretCode": secretCode, "expDate": expDate, "creatorUserID": creatorUserId])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var inviteId: GraphQLID {
    get {
      return snapshot["inviteID"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "inviteID")
    }
  }

  public var teamId: GraphQLID {
    get {
      return snapshot["teamID"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "teamID")
    }
  }

  public var secretCode: String {
    get {
      return snapshot["secretCode"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "secretCode")
    }
  }

  public var expDate: Int? {
    get {
      return snapshot["expDate"] as? Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "expDate")
    }
  }

  public var creatorUserId: GraphQLID {
    get {
      return snapshot["creatorUserID"]! as! GraphQLID
    }
    set {
      snapshot.updateValue(newValue, forKey: "creatorUserID")
    }
  }
}

public struct ScoutingTeamMember: GraphQLFragment {
  public static let fragmentString =
    "fragment ScoutingTeamMember on ScoutingTeamMember {\n  __typename\n  userID\n  name\n  memberSince\n}"

  public static let possibleTypes = ["ScoutingTeamMember"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("userID", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("name", type: .scalar(String.self)),
    GraphQLField("memberSince", type: .nonNull(.scalar(Int.self))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(userId: GraphQLID, name: String? = nil, memberSince: Int) {
    self.init(snapshot: ["__typename": "ScoutingTeamMember", "userID": userId, "name": name, "memberSince": memberSince])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
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

  public var name: String? {
    get {
      return snapshot["name"] as? String
    }
    set {
      snapshot.updateValue(newValue, forKey: "name")
    }
  }

  public var memberSince: Int {
    get {
      return snapshot["memberSince"]! as! Int
    }
    set {
      snapshot.updateValue(newValue, forKey: "memberSince")
    }
  }
}



extension S3Object: AWSS3ObjectProtocol {
  public func getBucketName() -> String {
      return bucket
  }

  public func getKeyName() -> String {
      return key
  }

  public func getRegion() -> String {
      return region
  }
}

extension S3ObjectInput: AWSS3ObjectProtocol, AWSS3InputObjectProtocol {
  public func getLocalSourceFileURL() -> URL? {
      return URL(string: self.localUri)
  }

  public func getMimeType() -> String {
      return self.mimeType
  }

  public func getBucketName() -> String {
      return self.bucket
  }

  public func getKeyName() -> String {
      return self.key
  }

  public func getRegion() -> String {
      return self.region
  }

}

import AWSS3
extension AWSS3PreSignedURLBuilder: AWSS3ObjectPresignedURLGenerator  {
  public func getPresignedURL(s3Object: AWSS3ObjectProtocol) -> URL? {
      let request = AWSS3GetPreSignedURLRequest()
      request.bucket = s3Object.getBucketName()
      request.key = s3Object.getKeyName()
      var url : URL?
      self.getPreSignedURL(request).continueWith { (task) -> Any? in
          url = task.result as URL?
          }.waitUntilFinished()
      return url
  }
}

extension AWSS3TransferUtility: AWSS3ObjectManager {

  public func download(s3Object: AWSS3ObjectProtocol, toURL: URL, completion: @escaping ((Bool, Error?) -> Void)) {

      let completionBlock: AWSS3TransferUtilityDownloadCompletionHandlerBlock = { task, url, data, error  -> Void in
          if let _ = error {
              completion(false, error)
          } else {
              completion(true, nil)
          }
      }
      let _ = self.download(to: toURL, bucket: s3Object.getBucketName(), key: s3Object.getKeyName(), expression: nil, completionHandler: completionBlock)
  }

  public func upload(s3Object: AWSS3ObjectProtocol & AWSS3InputObjectProtocol, completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
      let completionBlock : AWSS3TransferUtilityUploadCompletionHandlerBlock = { task, error  -> Void in
          if let _ = error {
              completion(false, error)
          } else {
              completion(true, nil)
          }
      }
      let _ = self.uploadFile(s3Object.getLocalSourceFileURL()!, bucket: s3Object.getBucketName(), key: s3Object.getKeyName(), contentType: s3Object.getMimeType(), expression: nil, completionHandler: completionBlock).continueWith { (task) -> Any? in
          if let err = task.error {
              completion(false, err)
          }
          return nil
      }
  }
}
//  This file was automatically generated and should not be edited.

import AWSAppSync

public struct CreateEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, code: String, eventType: Int, eventTypeString: String, location: String? = nil, name: String, year: Int, lastReloaded: Int? = nil, oprLastModified: Int? = nil, matchesLastModified: Int? = nil, statusesLastModified: Int? = nil) {
    graphQLMap = ["id": id, "code": code, "eventType": eventType, "eventTypeString": eventTypeString, "location": location, "name": name, "year": year, "lastReloaded": lastReloaded, "oprLastModified": oprLastModified, "matchesLastModified": matchesLastModified, "statusesLastModified": statusesLastModified]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var code: String {
    get {
      return graphQLMap["code"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "code")
    }
  }

  public var eventType: Int {
    get {
      return graphQLMap["eventType"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eventType")
    }
  }

  public var eventTypeString: String {
    get {
      return graphQLMap["eventTypeString"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eventTypeString")
    }
  }

  public var location: String? {
    get {
      return graphQLMap["location"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "location")
    }
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var year: Int {
    get {
      return graphQLMap["year"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "year")
    }
  }

  public var lastReloaded: Int? {
    get {
      return graphQLMap["lastReloaded"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lastReloaded")
    }
  }

  public var oprLastModified: Int? {
    get {
      return graphQLMap["oprLastModified"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "oprLastModified")
    }
  }

  public var matchesLastModified: Int? {
    get {
      return graphQLMap["matchesLastModified"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "matchesLastModified")
    }
  }

  public var statusesLastModified: Int? {
    get {
      return graphQLMap["statusesLastModified"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "statusesLastModified")
    }
  }
}

public struct UpdateEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, code: String? = nil, eventType: Int? = nil, eventTypeString: String? = nil, location: String? = nil, name: String? = nil, year: Int? = nil, lastReloaded: Int? = nil, oprLastModified: Int? = nil, matchesLastModified: Int? = nil, statusesLastModified: Int? = nil) {
    graphQLMap = ["id": id, "code": code, "eventType": eventType, "eventTypeString": eventTypeString, "location": location, "name": name, "year": year, "lastReloaded": lastReloaded, "oprLastModified": oprLastModified, "matchesLastModified": matchesLastModified, "statusesLastModified": statusesLastModified]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var code: String? {
    get {
      return graphQLMap["code"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "code")
    }
  }

  public var eventType: Int? {
    get {
      return graphQLMap["eventType"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eventType")
    }
  }

  public var eventTypeString: String? {
    get {
      return graphQLMap["eventTypeString"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eventTypeString")
    }
  }

  public var location: String? {
    get {
      return graphQLMap["location"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "location")
    }
  }

  public var name: String? {
    get {
      return graphQLMap["name"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var year: Int? {
    get {
      return graphQLMap["year"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "year")
    }
  }

  public var lastReloaded: Int? {
    get {
      return graphQLMap["lastReloaded"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lastReloaded")
    }
  }

  public var oprLastModified: Int? {
    get {
      return graphQLMap["oprLastModified"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "oprLastModified")
    }
  }

  public var matchesLastModified: Int? {
    get {
      return graphQLMap["matchesLastModified"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "matchesLastModified")
    }
  }

  public var statusesLastModified: Int? {
    get {
      return graphQLMap["statusesLastModified"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "statusesLastModified")
    }
  }
}

public struct DeleteEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateTeamInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(location: String? = nil, name: String, nickname: String, rookieYear: Int? = nil, teamNumber: Int, website: String? = nil, isPicked: Bool? = nil, programmingLanguage: String? = nil, computerVisionCapability: String? = nil, robotHeight: Double? = nil, robotLength: Double? = nil, robotWidth: Double? = nil, robotWeight: Double? = nil, frontImage: String? = nil, strategy: String? = nil, canBanana: Bool? = nil, driverXp: Double? = nil, driveTrain: String? = nil, otherAttributes: String? = nil) {
    graphQLMap = ["location": location, "name": name, "nickname": nickname, "rookieYear": rookieYear, "teamNumber": teamNumber, "website": website, "isPicked": isPicked, "programmingLanguage": programmingLanguage, "computerVisionCapability": computerVisionCapability, "robotHeight": robotHeight, "robotLength": robotLength, "robotWidth": robotWidth, "robotWeight": robotWeight, "frontImage": frontImage, "strategy": strategy, "canBanana": canBanana, "driverXP": driverXp, "driveTrain": driveTrain, "otherAttributes": otherAttributes]
  }

  public var location: String? {
    get {
      return graphQLMap["location"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "location")
    }
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var nickname: String {
    get {
      return graphQLMap["nickname"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "nickname")
    }
  }

  public var rookieYear: Int? {
    get {
      return graphQLMap["rookieYear"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "rookieYear")
    }
  }

  public var teamNumber: Int {
    get {
      return graphQLMap["teamNumber"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "teamNumber")
    }
  }

  public var website: String? {
    get {
      return graphQLMap["website"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "website")
    }
  }

  public var isPicked: Bool? {
    get {
      return graphQLMap["isPicked"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isPicked")
    }
  }

  public var programmingLanguage: String? {
    get {
      return graphQLMap["programmingLanguage"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "programmingLanguage")
    }
  }

  public var computerVisionCapability: String? {
    get {
      return graphQLMap["computerVisionCapability"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "computerVisionCapability")
    }
  }

  public var robotHeight: Double? {
    get {
      return graphQLMap["robotHeight"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "robotHeight")
    }
  }

  public var robotLength: Double? {
    get {
      return graphQLMap["robotLength"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "robotLength")
    }
  }

  public var robotWidth: Double? {
    get {
      return graphQLMap["robotWidth"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "robotWidth")
    }
  }

  public var robotWeight: Double? {
    get {
      return graphQLMap["robotWeight"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "robotWeight")
    }
  }

  public var frontImage: String? {
    get {
      return graphQLMap["frontImage"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "frontImage")
    }
  }

  public var strategy: String? {
    get {
      return graphQLMap["strategy"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "strategy")
    }
  }

  public var canBanana: Bool? {
    get {
      return graphQLMap["canBanana"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "canBanana")
    }
  }

  public var driverXp: Double? {
    get {
      return graphQLMap["driverXp"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "driverXp")
    }
  }

  public var driveTrain: String? {
    get {
      return graphQLMap["driveTrain"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "driveTrain")
    }
  }

  public var otherAttributes: String? {
    get {
      return graphQLMap["otherAttributes"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "otherAttributes")
    }
  }
}

public struct UpdateTeamInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, location: String? = nil, name: String? = nil, nickname: String? = nil, rookieYear: Int? = nil, teamNumber: Int? = nil, website: String? = nil, isPicked: Bool? = nil, programmingLanguage: String? = nil, computerVisionCapability: String? = nil, robotHeight: Double? = nil, robotLength: Double? = nil, robotWidth: Double? = nil, robotWeight: Double? = nil, frontImage: String? = nil, strategy: String? = nil, canBanana: Bool? = nil, driverXp: Double? = nil, driveTrain: String? = nil, otherAttributes: String? = nil) {
    graphQLMap = ["id": id, "location": location, "name": name, "nickname": nickname, "rookieYear": rookieYear, "teamNumber": teamNumber, "website": website, "isPicked": isPicked, "programmingLanguage": programmingLanguage, "computerVisionCapability": computerVisionCapability, "robotHeight": robotHeight, "robotLength": robotLength, "robotWidth": robotWidth, "robotWeight": robotWeight, "frontImage": frontImage, "strategy": strategy, "canBanana": canBanana, "driverXP": driverXp, "driveTrain": driveTrain, "otherAttributes": otherAttributes]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var location: String? {
    get {
      return graphQLMap["location"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "location")
    }
  }

  public var name: String? {
    get {
      return graphQLMap["name"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var nickname: String? {
    get {
      return graphQLMap["nickname"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "nickname")
    }
  }

  public var rookieYear: Int? {
    get {
      return graphQLMap["rookieYear"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "rookieYear")
    }
  }

  public var teamNumber: Int? {
    get {
      return graphQLMap["teamNumber"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "teamNumber")
    }
  }

  public var website: String? {
    get {
      return graphQLMap["website"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "website")
    }
  }

  public var isPicked: Bool? {
    get {
      return graphQLMap["isPicked"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isPicked")
    }
  }

  public var programmingLanguage: String? {
    get {
      return graphQLMap["programmingLanguage"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "programmingLanguage")
    }
  }

  public var computerVisionCapability: String? {
    get {
      return graphQLMap["computerVisionCapability"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "computerVisionCapability")
    }
  }

  public var robotHeight: Double? {
    get {
      return graphQLMap["robotHeight"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "robotHeight")
    }
  }

  public var robotLength: Double? {
    get {
      return graphQLMap["robotLength"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "robotLength")
    }
  }

  public var robotWidth: Double? {
    get {
      return graphQLMap["robotWidth"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "robotWidth")
    }
  }

  public var robotWeight: Double? {
    get {
      return graphQLMap["robotWeight"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "robotWeight")
    }
  }

  public var frontImage: String? {
    get {
      return graphQLMap["frontImage"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "frontImage")
    }
  }

  public var strategy: String? {
    get {
      return graphQLMap["strategy"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "strategy")
    }
  }

  public var canBanana: Bool? {
    get {
      return graphQLMap["canBanana"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "canBanana")
    }
  }

  public var driverXp: Double? {
    get {
      return graphQLMap["driverXp"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "driverXp")
    }
  }

  public var driveTrain: String? {
    get {
      return graphQLMap["driveTrain"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "driveTrain")
    }
  }

  public var otherAttributes: String? {
    get {
      return graphQLMap["otherAttributes"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "otherAttributes")
    }
  }
}

public struct DeleteTeamInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct TableEventFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: TableIDFilterInput? = nil, code: TableStringFilterInput? = nil, eventType: TableIntFilterInput? = nil, eventTypeString: TableStringFilterInput? = nil, location: TableStringFilterInput? = nil, name: TableStringFilterInput? = nil, year: TableIntFilterInput? = nil, lastReloaded: TableIntFilterInput? = nil, oprLastModified: TableIntFilterInput? = nil, matchesLastModified: TableIntFilterInput? = nil, statusesLastModified: TableIntFilterInput? = nil) {
    graphQLMap = ["id": id, "code": code, "eventType": eventType, "eventTypeString": eventTypeString, "location": location, "name": name, "year": year, "lastReloaded": lastReloaded, "oprLastModified": oprLastModified, "matchesLastModified": matchesLastModified, "statusesLastModified": statusesLastModified]
  }

  public var id: TableIDFilterInput? {
    get {
      return graphQLMap["id"] as! TableIDFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var code: TableStringFilterInput? {
    get {
      return graphQLMap["code"] as! TableStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "code")
    }
  }

  public var eventType: TableIntFilterInput? {
    get {
      return graphQLMap["eventType"] as! TableIntFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eventType")
    }
  }

  public var eventTypeString: TableStringFilterInput? {
    get {
      return graphQLMap["eventTypeString"] as! TableStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eventTypeString")
    }
  }

  public var location: TableStringFilterInput? {
    get {
      return graphQLMap["location"] as! TableStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "location")
    }
  }

  public var name: TableStringFilterInput? {
    get {
      return graphQLMap["name"] as! TableStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var year: TableIntFilterInput? {
    get {
      return graphQLMap["year"] as! TableIntFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "year")
    }
  }

  public var lastReloaded: TableIntFilterInput? {
    get {
      return graphQLMap["lastReloaded"] as! TableIntFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lastReloaded")
    }
  }

  public var oprLastModified: TableIntFilterInput? {
    get {
      return graphQLMap["oprLastModified"] as! TableIntFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "oprLastModified")
    }
  }

  public var matchesLastModified: TableIntFilterInput? {
    get {
      return graphQLMap["matchesLastModified"] as! TableIntFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "matchesLastModified")
    }
  }

  public var statusesLastModified: TableIntFilterInput? {
    get {
      return graphQLMap["statusesLastModified"] as! TableIntFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "statusesLastModified")
    }
  }
}

public struct TableIDFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: GraphQLID? = nil, eq: GraphQLID? = nil, le: GraphQLID? = nil, lt: GraphQLID? = nil, ge: GraphQLID? = nil, gt: GraphQLID? = nil, contains: GraphQLID? = nil, notContains: GraphQLID? = nil, between: [GraphQLID?]? = nil, beginsWith: GraphQLID? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith]
  }

  public var ne: GraphQLID? {
    get {
      return graphQLMap["ne"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: GraphQLID? {
    get {
      return graphQLMap["eq"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: GraphQLID? {
    get {
      return graphQLMap["le"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: GraphQLID? {
    get {
      return graphQLMap["lt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: GraphQLID? {
    get {
      return graphQLMap["ge"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: GraphQLID? {
    get {
      return graphQLMap["gt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: GraphQLID? {
    get {
      return graphQLMap["contains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: GraphQLID? {
    get {
      return graphQLMap["notContains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [GraphQLID?]? {
    get {
      return graphQLMap["between"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: GraphQLID? {
    get {
      return graphQLMap["beginsWith"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }
}

public struct TableStringFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: String? = nil, eq: String? = nil, le: String? = nil, lt: String? = nil, ge: String? = nil, gt: String? = nil, contains: String? = nil, notContains: String? = nil, between: [String?]? = nil, beginsWith: String? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith]
  }

  public var ne: String? {
    get {
      return graphQLMap["ne"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: String? {
    get {
      return graphQLMap["eq"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: String? {
    get {
      return graphQLMap["le"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: String? {
    get {
      return graphQLMap["lt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: String? {
    get {
      return graphQLMap["ge"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: String? {
    get {
      return graphQLMap["gt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: String? {
    get {
      return graphQLMap["contains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: String? {
    get {
      return graphQLMap["notContains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [String?]? {
    get {
      return graphQLMap["between"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: String? {
    get {
      return graphQLMap["beginsWith"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }
}

public struct TableIntFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Int? = nil, eq: Int? = nil, le: Int? = nil, lt: Int? = nil, ge: Int? = nil, gt: Int? = nil, contains: Int? = nil, notContains: Int? = nil, between: [Int?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between]
  }

  public var ne: Int? {
    get {
      return graphQLMap["ne"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Int? {
    get {
      return graphQLMap["eq"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Int? {
    get {
      return graphQLMap["le"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Int? {
    get {
      return graphQLMap["lt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Int? {
    get {
      return graphQLMap["ge"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Int? {
    get {
      return graphQLMap["gt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: Int? {
    get {
      return graphQLMap["contains"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: Int? {
    get {
      return graphQLMap["notContains"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [Int?]? {
    get {
      return graphQLMap["between"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }
}

public struct TableTeamFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: TableIDFilterInput? = nil, location: TableStringFilterInput? = nil, name: TableStringFilterInput? = nil, nickname: TableStringFilterInput? = nil, rookieYear: TableIntFilterInput? = nil, teamNumber: TableIntFilterInput? = nil, website: TableStringFilterInput? = nil, isPicked: TableBooleanFilterInput? = nil, programmingLanguage: TableStringFilterInput? = nil, computerVisionCapability: TableStringFilterInput? = nil, robotHeight: TableFloatFilterInput? = nil, robotLength: TableFloatFilterInput? = nil, robotWidth: TableFloatFilterInput? = nil, robotWeight: TableFloatFilterInput? = nil, frontImage: TableStringFilterInput? = nil, strategy: TableStringFilterInput? = nil, canBanana: TableBooleanFilterInput? = nil, driverXp: TableFloatFilterInput? = nil, driveTrain: TableStringFilterInput? = nil) {
    graphQLMap = ["id": id, "location": location, "name": name, "nickname": nickname, "rookieYear": rookieYear, "teamNumber": teamNumber, "website": website, "isPicked": isPicked, "programmingLanguage": programmingLanguage, "computerVisionCapability": computerVisionCapability, "robotHeight": robotHeight, "robotLength": robotLength, "robotWidth": robotWidth, "robotWeight": robotWeight, "frontImage": frontImage, "strategy": strategy, "canBanana": canBanana, "driverXP": driverXp, "driveTrain": driveTrain]
  }

  public var id: TableIDFilterInput? {
    get {
      return graphQLMap["id"] as! TableIDFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var location: TableStringFilterInput? {
    get {
      return graphQLMap["location"] as! TableStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "location")
    }
  }

  public var name: TableStringFilterInput? {
    get {
      return graphQLMap["name"] as! TableStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var nickname: TableStringFilterInput? {
    get {
      return graphQLMap["nickname"] as! TableStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "nickname")
    }
  }

  public var rookieYear: TableIntFilterInput? {
    get {
      return graphQLMap["rookieYear"] as! TableIntFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "rookieYear")
    }
  }

  public var teamNumber: TableIntFilterInput? {
    get {
      return graphQLMap["teamNumber"] as! TableIntFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "teamNumber")
    }
  }

  public var website: TableStringFilterInput? {
    get {
      return graphQLMap["website"] as! TableStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "website")
    }
  }

  public var isPicked: TableBooleanFilterInput? {
    get {
      return graphQLMap["isPicked"] as! TableBooleanFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isPicked")
    }
  }

  public var programmingLanguage: TableStringFilterInput? {
    get {
      return graphQLMap["programmingLanguage"] as! TableStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "programmingLanguage")
    }
  }

  public var computerVisionCapability: TableStringFilterInput? {
    get {
      return graphQLMap["computerVisionCapability"] as! TableStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "computerVisionCapability")
    }
  }

  public var robotHeight: TableFloatFilterInput? {
    get {
      return graphQLMap["robotHeight"] as! TableFloatFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "robotHeight")
    }
  }

  public var robotLength: TableFloatFilterInput? {
    get {
      return graphQLMap["robotLength"] as! TableFloatFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "robotLength")
    }
  }

  public var robotWidth: TableFloatFilterInput? {
    get {
      return graphQLMap["robotWidth"] as! TableFloatFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "robotWidth")
    }
  }

  public var robotWeight: TableFloatFilterInput? {
    get {
      return graphQLMap["robotWeight"] as! TableFloatFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "robotWeight")
    }
  }

  public var frontImage: TableStringFilterInput? {
    get {
      return graphQLMap["frontImage"] as! TableStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "frontImage")
    }
  }

  public var strategy: TableStringFilterInput? {
    get {
      return graphQLMap["strategy"] as! TableStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "strategy")
    }
  }

  public var canBanana: TableBooleanFilterInput? {
    get {
      return graphQLMap["canBanana"] as! TableBooleanFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "canBanana")
    }
  }

  public var driverXp: TableFloatFilterInput? {
    get {
      return graphQLMap["driverXp"] as! TableFloatFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "driverXp")
    }
  }

  public var driveTrain: TableStringFilterInput? {
    get {
      return graphQLMap["driveTrain"] as! TableStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "driveTrain")
    }
  }
}

public struct TableBooleanFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Bool? = nil, eq: Bool? = nil) {
    graphQLMap = ["ne": ne, "eq": eq]
  }

  public var ne: Bool? {
    get {
      return graphQLMap["ne"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Bool? {
    get {
      return graphQLMap["eq"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }
}

public struct TableFloatFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Double? = nil, eq: Double? = nil, le: Double? = nil, lt: Double? = nil, ge: Double? = nil, gt: Double? = nil, contains: Double? = nil, notContains: Double? = nil, between: [Double?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between]
  }

  public var ne: Double? {
    get {
      return graphQLMap["ne"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Double? {
    get {
      return graphQLMap["eq"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Double? {
    get {
      return graphQLMap["le"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Double? {
    get {
      return graphQLMap["lt"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Double? {
    get {
      return graphQLMap["ge"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Double? {
    get {
      return graphQLMap["gt"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: Double? {
    get {
      return graphQLMap["contains"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: Double? {
    get {
      return graphQLMap["notContains"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [Double?]? {
    get {
      return graphQLMap["between"] as! [Double?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }
}

public final class CreateEventMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateEvent($input: CreateEventInput!) {\n  createEvent(input: $input) {\n    __typename\n    id\n    code\n    eventType\n    eventTypeString\n    location\n    name\n    year\n    lastReloaded\n    oprLastModified\n    matchesLastModified\n    statusesLastModified\n  }\n}"

  public var input: CreateEventInput

  public init(input: CreateEventInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createEvent", arguments: ["input": GraphQLVariable("input")], type: .object(CreateEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createEvent: CreateEvent? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createEvent": createEvent.flatMap { $0.snapshot }])
    }

    public var createEvent: CreateEvent? {
      get {
        return (snapshot["createEvent"] as? Snapshot).flatMap { CreateEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createEvent")
      }
    }

    public struct CreateEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("code", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventType", type: .nonNull(.scalar(Int.self))),
        GraphQLField("eventTypeString", type: .nonNull(.scalar(String.self))),
        GraphQLField("location", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("lastReloaded", type: .scalar(Int.self)),
        GraphQLField("oprLastModified", type: .scalar(Int.self)),
        GraphQLField("matchesLastModified", type: .scalar(Int.self)),
        GraphQLField("statusesLastModified", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, code: String, eventType: Int, eventTypeString: String, location: String? = nil, name: String, year: Int, lastReloaded: Int? = nil, oprLastModified: Int? = nil, matchesLastModified: Int? = nil, statusesLastModified: Int? = nil) {
        self.init(snapshot: ["__typename": "Event", "id": id, "code": code, "eventType": eventType, "eventTypeString": eventTypeString, "location": location, "name": name, "year": year, "lastReloaded": lastReloaded, "oprLastModified": oprLastModified, "matchesLastModified": matchesLastModified, "statusesLastModified": statusesLastModified])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var code: String {
        get {
          return snapshot["code"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "code")
        }
      }

      public var eventType: Int {
        get {
          return snapshot["eventType"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventType")
        }
      }

      public var eventTypeString: String {
        get {
          return snapshot["eventTypeString"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventTypeString")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
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

      public var lastReloaded: Int? {
        get {
          return snapshot["lastReloaded"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastReloaded")
        }
      }

      public var oprLastModified: Int? {
        get {
          return snapshot["oprLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "oprLastModified")
        }
      }

      public var matchesLastModified: Int? {
        get {
          return snapshot["matchesLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "matchesLastModified")
        }
      }

      public var statusesLastModified: Int? {
        get {
          return snapshot["statusesLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "statusesLastModified")
        }
      }
    }
  }
}

public final class UpdateEventMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateEvent($input: UpdateEventInput!) {\n  updateEvent(input: $input) {\n    __typename\n    id\n    code\n    eventType\n    eventTypeString\n    location\n    name\n    year\n    lastReloaded\n    oprLastModified\n    matchesLastModified\n    statusesLastModified\n  }\n}"

  public var input: UpdateEventInput

  public init(input: UpdateEventInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateEvent", arguments: ["input": GraphQLVariable("input")], type: .object(UpdateEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateEvent: UpdateEvent? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateEvent": updateEvent.flatMap { $0.snapshot }])
    }

    public var updateEvent: UpdateEvent? {
      get {
        return (snapshot["updateEvent"] as? Snapshot).flatMap { UpdateEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateEvent")
      }
    }

    public struct UpdateEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("code", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventType", type: .nonNull(.scalar(Int.self))),
        GraphQLField("eventTypeString", type: .nonNull(.scalar(String.self))),
        GraphQLField("location", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("lastReloaded", type: .scalar(Int.self)),
        GraphQLField("oprLastModified", type: .scalar(Int.self)),
        GraphQLField("matchesLastModified", type: .scalar(Int.self)),
        GraphQLField("statusesLastModified", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, code: String, eventType: Int, eventTypeString: String, location: String? = nil, name: String, year: Int, lastReloaded: Int? = nil, oprLastModified: Int? = nil, matchesLastModified: Int? = nil, statusesLastModified: Int? = nil) {
        self.init(snapshot: ["__typename": "Event", "id": id, "code": code, "eventType": eventType, "eventTypeString": eventTypeString, "location": location, "name": name, "year": year, "lastReloaded": lastReloaded, "oprLastModified": oprLastModified, "matchesLastModified": matchesLastModified, "statusesLastModified": statusesLastModified])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var code: String {
        get {
          return snapshot["code"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "code")
        }
      }

      public var eventType: Int {
        get {
          return snapshot["eventType"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventType")
        }
      }

      public var eventTypeString: String {
        get {
          return snapshot["eventTypeString"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventTypeString")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
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

      public var lastReloaded: Int? {
        get {
          return snapshot["lastReloaded"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastReloaded")
        }
      }

      public var oprLastModified: Int? {
        get {
          return snapshot["oprLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "oprLastModified")
        }
      }

      public var matchesLastModified: Int? {
        get {
          return snapshot["matchesLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "matchesLastModified")
        }
      }

      public var statusesLastModified: Int? {
        get {
          return snapshot["statusesLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "statusesLastModified")
        }
      }
    }
  }
}

public final class DeleteEventMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteEvent($input: DeleteEventInput!) {\n  deleteEvent(input: $input) {\n    __typename\n    id\n    code\n    eventType\n    eventTypeString\n    location\n    name\n    year\n    lastReloaded\n    oprLastModified\n    matchesLastModified\n    statusesLastModified\n  }\n}"

  public var input: DeleteEventInput

  public init(input: DeleteEventInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteEvent", arguments: ["input": GraphQLVariable("input")], type: .object(DeleteEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteEvent: DeleteEvent? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteEvent": deleteEvent.flatMap { $0.snapshot }])
    }

    public var deleteEvent: DeleteEvent? {
      get {
        return (snapshot["deleteEvent"] as? Snapshot).flatMap { DeleteEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteEvent")
      }
    }

    public struct DeleteEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("code", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventType", type: .nonNull(.scalar(Int.self))),
        GraphQLField("eventTypeString", type: .nonNull(.scalar(String.self))),
        GraphQLField("location", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("lastReloaded", type: .scalar(Int.self)),
        GraphQLField("oprLastModified", type: .scalar(Int.self)),
        GraphQLField("matchesLastModified", type: .scalar(Int.self)),
        GraphQLField("statusesLastModified", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, code: String, eventType: Int, eventTypeString: String, location: String? = nil, name: String, year: Int, lastReloaded: Int? = nil, oprLastModified: Int? = nil, matchesLastModified: Int? = nil, statusesLastModified: Int? = nil) {
        self.init(snapshot: ["__typename": "Event", "id": id, "code": code, "eventType": eventType, "eventTypeString": eventTypeString, "location": location, "name": name, "year": year, "lastReloaded": lastReloaded, "oprLastModified": oprLastModified, "matchesLastModified": matchesLastModified, "statusesLastModified": statusesLastModified])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var code: String {
        get {
          return snapshot["code"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "code")
        }
      }

      public var eventType: Int {
        get {
          return snapshot["eventType"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventType")
        }
      }

      public var eventTypeString: String {
        get {
          return snapshot["eventTypeString"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventTypeString")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
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

      public var lastReloaded: Int? {
        get {
          return snapshot["lastReloaded"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastReloaded")
        }
      }

      public var oprLastModified: Int? {
        get {
          return snapshot["oprLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "oprLastModified")
        }
      }

      public var matchesLastModified: Int? {
        get {
          return snapshot["matchesLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "matchesLastModified")
        }
      }

      public var statusesLastModified: Int? {
        get {
          return snapshot["statusesLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "statusesLastModified")
        }
      }
    }
  }
}

public final class CreateTeamMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateTeam($input: CreateTeamInput!) {\n  createTeam(input: $input) {\n    __typename\n    id\n    location\n    name\n    nickname\n    rookieYear\n    teamNumber\n    website\n    isPicked\n    programmingLanguage\n    computerVisionCapability\n    robotHeight\n    robotLength\n    robotWidth\n    robotWeight\n    frontImage\n    strategy\n    canBanana\n    driverXP\n    driveTrain\n    otherAttributes\n  }\n}"

  public var input: CreateTeamInput

  public init(input: CreateTeamInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createTeam", arguments: ["input": GraphQLVariable("input")], type: .object(CreateTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createTeam: CreateTeam? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createTeam": createTeam.flatMap { $0.snapshot }])
    }

    public var createTeam: CreateTeam? {
      get {
        return (snapshot["createTeam"] as? Snapshot).flatMap { CreateTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createTeam")
      }
    }

    public struct CreateTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["Team"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
        GraphQLField("rookieYear", type: .scalar(Int.self)),
        GraphQLField("teamNumber", type: .nonNull(.scalar(Int.self))),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("isPicked", type: .scalar(Bool.self)),
        GraphQLField("programmingLanguage", type: .scalar(String.self)),
        GraphQLField("computerVisionCapability", type: .scalar(String.self)),
        GraphQLField("robotHeight", type: .scalar(Double.self)),
        GraphQLField("robotLength", type: .scalar(Double.self)),
        GraphQLField("robotWidth", type: .scalar(Double.self)),
        GraphQLField("robotWeight", type: .scalar(Double.self)),
        GraphQLField("frontImage", type: .scalar(String.self)),
        GraphQLField("strategy", type: .scalar(String.self)),
        GraphQLField("canBanana", type: .scalar(Bool.self)),
        GraphQLField("driverXP", type: .scalar(Double.self)),
        GraphQLField("driveTrain", type: .scalar(String.self)),
        GraphQLField("otherAttributes", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: String? = nil, name: String, nickname: String, rookieYear: Int? = nil, teamNumber: Int, website: String? = nil, isPicked: Bool? = nil, programmingLanguage: String? = nil, computerVisionCapability: String? = nil, robotHeight: Double? = nil, robotLength: Double? = nil, robotWidth: Double? = nil, robotWeight: Double? = nil, frontImage: String? = nil, strategy: String? = nil, canBanana: Bool? = nil, driverXp: Double? = nil, driveTrain: String? = nil, otherAttributes: String? = nil) {
        self.init(snapshot: ["__typename": "Team", "id": id, "location": location, "name": name, "nickname": nickname, "rookieYear": rookieYear, "teamNumber": teamNumber, "website": website, "isPicked": isPicked, "programmingLanguage": programmingLanguage, "computerVisionCapability": computerVisionCapability, "robotHeight": robotHeight, "robotLength": robotLength, "robotWidth": robotWidth, "robotWeight": robotWeight, "frontImage": frontImage, "strategy": strategy, "canBanana": canBanana, "driverXP": driverXp, "driveTrain": driveTrain, "otherAttributes": otherAttributes])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
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
          return snapshot["rookieYear"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "rookieYear")
        }
      }

      public var teamNumber: Int {
        get {
          return snapshot["teamNumber"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamNumber")
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

      public var isPicked: Bool? {
        get {
          return snapshot["isPicked"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isPicked")
        }
      }

      public var programmingLanguage: String? {
        get {
          return snapshot["programmingLanguage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "programmingLanguage")
        }
      }

      public var computerVisionCapability: String? {
        get {
          return snapshot["computerVisionCapability"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "computerVisionCapability")
        }
      }

      public var robotHeight: Double? {
        get {
          return snapshot["robotHeight"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotHeight")
        }
      }

      public var robotLength: Double? {
        get {
          return snapshot["robotLength"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotLength")
        }
      }

      public var robotWidth: Double? {
        get {
          return snapshot["robotWidth"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotWidth")
        }
      }

      public var robotWeight: Double? {
        get {
          return snapshot["robotWeight"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotWeight")
        }
      }

      public var frontImage: String? {
        get {
          return snapshot["frontImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "frontImage")
        }
      }

      public var strategy: String? {
        get {
          return snapshot["strategy"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "strategy")
        }
      }

      public var canBanana: Bool? {
        get {
          return snapshot["canBanana"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "canBanana")
        }
      }

      public var driverXp: Double? {
        get {
          return snapshot["driverXP"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "driverXP")
        }
      }

      public var driveTrain: String? {
        get {
          return snapshot["driveTrain"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "driveTrain")
        }
      }

      public var otherAttributes: String? {
        get {
          return snapshot["otherAttributes"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "otherAttributes")
        }
      }
    }
  }
}

public final class UpdateTeamMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateTeam($input: UpdateTeamInput!) {\n  updateTeam(input: $input) {\n    __typename\n    id\n    location\n    name\n    nickname\n    rookieYear\n    teamNumber\n    website\n    isPicked\n    programmingLanguage\n    computerVisionCapability\n    robotHeight\n    robotLength\n    robotWidth\n    robotWeight\n    frontImage\n    strategy\n    canBanana\n    driverXP\n    driveTrain\n    otherAttributes\n  }\n}"

  public var input: UpdateTeamInput

  public init(input: UpdateTeamInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateTeam", arguments: ["input": GraphQLVariable("input")], type: .object(UpdateTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateTeam: UpdateTeam? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateTeam": updateTeam.flatMap { $0.snapshot }])
    }

    public var updateTeam: UpdateTeam? {
      get {
        return (snapshot["updateTeam"] as? Snapshot).flatMap { UpdateTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateTeam")
      }
    }

    public struct UpdateTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["Team"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
        GraphQLField("rookieYear", type: .scalar(Int.self)),
        GraphQLField("teamNumber", type: .nonNull(.scalar(Int.self))),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("isPicked", type: .scalar(Bool.self)),
        GraphQLField("programmingLanguage", type: .scalar(String.self)),
        GraphQLField("computerVisionCapability", type: .scalar(String.self)),
        GraphQLField("robotHeight", type: .scalar(Double.self)),
        GraphQLField("robotLength", type: .scalar(Double.self)),
        GraphQLField("robotWidth", type: .scalar(Double.self)),
        GraphQLField("robotWeight", type: .scalar(Double.self)),
        GraphQLField("frontImage", type: .scalar(String.self)),
        GraphQLField("strategy", type: .scalar(String.self)),
        GraphQLField("canBanana", type: .scalar(Bool.self)),
        GraphQLField("driverXP", type: .scalar(Double.self)),
        GraphQLField("driveTrain", type: .scalar(String.self)),
        GraphQLField("otherAttributes", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: String? = nil, name: String, nickname: String, rookieYear: Int? = nil, teamNumber: Int, website: String? = nil, isPicked: Bool? = nil, programmingLanguage: String? = nil, computerVisionCapability: String? = nil, robotHeight: Double? = nil, robotLength: Double? = nil, robotWidth: Double? = nil, robotWeight: Double? = nil, frontImage: String? = nil, strategy: String? = nil, canBanana: Bool? = nil, driverXp: Double? = nil, driveTrain: String? = nil, otherAttributes: String? = nil) {
        self.init(snapshot: ["__typename": "Team", "id": id, "location": location, "name": name, "nickname": nickname, "rookieYear": rookieYear, "teamNumber": teamNumber, "website": website, "isPicked": isPicked, "programmingLanguage": programmingLanguage, "computerVisionCapability": computerVisionCapability, "robotHeight": robotHeight, "robotLength": robotLength, "robotWidth": robotWidth, "robotWeight": robotWeight, "frontImage": frontImage, "strategy": strategy, "canBanana": canBanana, "driverXP": driverXp, "driveTrain": driveTrain, "otherAttributes": otherAttributes])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
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
          return snapshot["rookieYear"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "rookieYear")
        }
      }

      public var teamNumber: Int {
        get {
          return snapshot["teamNumber"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamNumber")
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

      public var isPicked: Bool? {
        get {
          return snapshot["isPicked"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isPicked")
        }
      }

      public var programmingLanguage: String? {
        get {
          return snapshot["programmingLanguage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "programmingLanguage")
        }
      }

      public var computerVisionCapability: String? {
        get {
          return snapshot["computerVisionCapability"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "computerVisionCapability")
        }
      }

      public var robotHeight: Double? {
        get {
          return snapshot["robotHeight"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotHeight")
        }
      }

      public var robotLength: Double? {
        get {
          return snapshot["robotLength"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotLength")
        }
      }

      public var robotWidth: Double? {
        get {
          return snapshot["robotWidth"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotWidth")
        }
      }

      public var robotWeight: Double? {
        get {
          return snapshot["robotWeight"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotWeight")
        }
      }

      public var frontImage: String? {
        get {
          return snapshot["frontImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "frontImage")
        }
      }

      public var strategy: String? {
        get {
          return snapshot["strategy"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "strategy")
        }
      }

      public var canBanana: Bool? {
        get {
          return snapshot["canBanana"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "canBanana")
        }
      }

      public var driverXp: Double? {
        get {
          return snapshot["driverXP"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "driverXP")
        }
      }

      public var driveTrain: String? {
        get {
          return snapshot["driveTrain"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "driveTrain")
        }
      }

      public var otherAttributes: String? {
        get {
          return snapshot["otherAttributes"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "otherAttributes")
        }
      }
    }
  }
}

public final class DeleteTeamMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteTeam($input: DeleteTeamInput!) {\n  deleteTeam(input: $input) {\n    __typename\n    id\n    location\n    name\n    nickname\n    rookieYear\n    teamNumber\n    website\n    isPicked\n    programmingLanguage\n    computerVisionCapability\n    robotHeight\n    robotLength\n    robotWidth\n    robotWeight\n    frontImage\n    strategy\n    canBanana\n    driverXP\n    driveTrain\n    otherAttributes\n  }\n}"

  public var input: DeleteTeamInput

  public init(input: DeleteTeamInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteTeam", arguments: ["input": GraphQLVariable("input")], type: .object(DeleteTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteTeam: DeleteTeam? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteTeam": deleteTeam.flatMap { $0.snapshot }])
    }

    public var deleteTeam: DeleteTeam? {
      get {
        return (snapshot["deleteTeam"] as? Snapshot).flatMap { DeleteTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteTeam")
      }
    }

    public struct DeleteTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["Team"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
        GraphQLField("rookieYear", type: .scalar(Int.self)),
        GraphQLField("teamNumber", type: .nonNull(.scalar(Int.self))),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("isPicked", type: .scalar(Bool.self)),
        GraphQLField("programmingLanguage", type: .scalar(String.self)),
        GraphQLField("computerVisionCapability", type: .scalar(String.self)),
        GraphQLField("robotHeight", type: .scalar(Double.self)),
        GraphQLField("robotLength", type: .scalar(Double.self)),
        GraphQLField("robotWidth", type: .scalar(Double.self)),
        GraphQLField("robotWeight", type: .scalar(Double.self)),
        GraphQLField("frontImage", type: .scalar(String.self)),
        GraphQLField("strategy", type: .scalar(String.self)),
        GraphQLField("canBanana", type: .scalar(Bool.self)),
        GraphQLField("driverXP", type: .scalar(Double.self)),
        GraphQLField("driveTrain", type: .scalar(String.self)),
        GraphQLField("otherAttributes", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: String? = nil, name: String, nickname: String, rookieYear: Int? = nil, teamNumber: Int, website: String? = nil, isPicked: Bool? = nil, programmingLanguage: String? = nil, computerVisionCapability: String? = nil, robotHeight: Double? = nil, robotLength: Double? = nil, robotWidth: Double? = nil, robotWeight: Double? = nil, frontImage: String? = nil, strategy: String? = nil, canBanana: Bool? = nil, driverXp: Double? = nil, driveTrain: String? = nil, otherAttributes: String? = nil) {
        self.init(snapshot: ["__typename": "Team", "id": id, "location": location, "name": name, "nickname": nickname, "rookieYear": rookieYear, "teamNumber": teamNumber, "website": website, "isPicked": isPicked, "programmingLanguage": programmingLanguage, "computerVisionCapability": computerVisionCapability, "robotHeight": robotHeight, "robotLength": robotLength, "robotWidth": robotWidth, "robotWeight": robotWeight, "frontImage": frontImage, "strategy": strategy, "canBanana": canBanana, "driverXP": driverXp, "driveTrain": driveTrain, "otherAttributes": otherAttributes])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
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
          return snapshot["rookieYear"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "rookieYear")
        }
      }

      public var teamNumber: Int {
        get {
          return snapshot["teamNumber"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamNumber")
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

      public var isPicked: Bool? {
        get {
          return snapshot["isPicked"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isPicked")
        }
      }

      public var programmingLanguage: String? {
        get {
          return snapshot["programmingLanguage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "programmingLanguage")
        }
      }

      public var computerVisionCapability: String? {
        get {
          return snapshot["computerVisionCapability"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "computerVisionCapability")
        }
      }

      public var robotHeight: Double? {
        get {
          return snapshot["robotHeight"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotHeight")
        }
      }

      public var robotLength: Double? {
        get {
          return snapshot["robotLength"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotLength")
        }
      }

      public var robotWidth: Double? {
        get {
          return snapshot["robotWidth"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotWidth")
        }
      }

      public var robotWeight: Double? {
        get {
          return snapshot["robotWeight"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotWeight")
        }
      }

      public var frontImage: String? {
        get {
          return snapshot["frontImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "frontImage")
        }
      }

      public var strategy: String? {
        get {
          return snapshot["strategy"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "strategy")
        }
      }

      public var canBanana: Bool? {
        get {
          return snapshot["canBanana"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "canBanana")
        }
      }

      public var driverXp: Double? {
        get {
          return snapshot["driverXP"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "driverXP")
        }
      }

      public var driveTrain: String? {
        get {
          return snapshot["driveTrain"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "driveTrain")
        }
      }

      public var otherAttributes: String? {
        get {
          return snapshot["otherAttributes"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "otherAttributes")
        }
      }
    }
  }
}

public final class GetEventQuery: GraphQLQuery {
  public static let operationString =
    "query GetEvent($id: ID!) {\n  getEvent(id: $id) {\n    __typename\n    id\n    code\n    eventType\n    eventTypeString\n    location\n    name\n    year\n    lastReloaded\n    oprLastModified\n    matchesLastModified\n    statusesLastModified\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getEvent", arguments: ["id": GraphQLVariable("id")], type: .object(GetEvent.selections)),
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
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("code", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventType", type: .nonNull(.scalar(Int.self))),
        GraphQLField("eventTypeString", type: .nonNull(.scalar(String.self))),
        GraphQLField("location", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("lastReloaded", type: .scalar(Int.self)),
        GraphQLField("oprLastModified", type: .scalar(Int.self)),
        GraphQLField("matchesLastModified", type: .scalar(Int.self)),
        GraphQLField("statusesLastModified", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, code: String, eventType: Int, eventTypeString: String, location: String? = nil, name: String, year: Int, lastReloaded: Int? = nil, oprLastModified: Int? = nil, matchesLastModified: Int? = nil, statusesLastModified: Int? = nil) {
        self.init(snapshot: ["__typename": "Event", "id": id, "code": code, "eventType": eventType, "eventTypeString": eventTypeString, "location": location, "name": name, "year": year, "lastReloaded": lastReloaded, "oprLastModified": oprLastModified, "matchesLastModified": matchesLastModified, "statusesLastModified": statusesLastModified])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var code: String {
        get {
          return snapshot["code"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "code")
        }
      }

      public var eventType: Int {
        get {
          return snapshot["eventType"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventType")
        }
      }

      public var eventTypeString: String {
        get {
          return snapshot["eventTypeString"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventTypeString")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
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

      public var lastReloaded: Int? {
        get {
          return snapshot["lastReloaded"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastReloaded")
        }
      }

      public var oprLastModified: Int? {
        get {
          return snapshot["oprLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "oprLastModified")
        }
      }

      public var matchesLastModified: Int? {
        get {
          return snapshot["matchesLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "matchesLastModified")
        }
      }

      public var statusesLastModified: Int? {
        get {
          return snapshot["statusesLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "statusesLastModified")
        }
      }
    }
  }
}

public final class ListEventsQuery: GraphQLQuery {
  public static let operationString =
    "query ListEvents($filter: TableEventFilterInput, $limit: Int, $nextToken: String) {\n  listEvents(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      code\n      eventType\n      eventTypeString\n      location\n      name\n      year\n      lastReloaded\n      oprLastModified\n      matchesLastModified\n      statusesLastModified\n    }\n    nextToken\n  }\n}"

  public var filter: TableEventFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: TableEventFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listEvents", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listEvents: ListEvent? = nil) {
      self.init(snapshot: ["__typename": "Query", "listEvents": listEvents.flatMap { $0.snapshot }])
    }

    public var listEvents: ListEvent? {
      get {
        return (snapshot["listEvents"] as? Snapshot).flatMap { ListEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listEvents")
      }
    }

    public struct ListEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["EventConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .list(.object(Item.selections))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?]? = nil, nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "EventConnection", "items": items.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?]? {
        get {
          return (snapshot["items"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Item(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["Event"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("code", type: .nonNull(.scalar(String.self))),
          GraphQLField("eventType", type: .nonNull(.scalar(Int.self))),
          GraphQLField("eventTypeString", type: .nonNull(.scalar(String.self))),
          GraphQLField("location", type: .scalar(String.self)),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("year", type: .nonNull(.scalar(Int.self))),
          GraphQLField("lastReloaded", type: .scalar(Int.self)),
          GraphQLField("oprLastModified", type: .scalar(Int.self)),
          GraphQLField("matchesLastModified", type: .scalar(Int.self)),
          GraphQLField("statusesLastModified", type: .scalar(Int.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, code: String, eventType: Int, eventTypeString: String, location: String? = nil, name: String, year: Int, lastReloaded: Int? = nil, oprLastModified: Int? = nil, matchesLastModified: Int? = nil, statusesLastModified: Int? = nil) {
          self.init(snapshot: ["__typename": "Event", "id": id, "code": code, "eventType": eventType, "eventTypeString": eventTypeString, "location": location, "name": name, "year": year, "lastReloaded": lastReloaded, "oprLastModified": oprLastModified, "matchesLastModified": matchesLastModified, "statusesLastModified": statusesLastModified])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var code: String {
          get {
            return snapshot["code"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "code")
          }
        }

        public var eventType: Int {
          get {
            return snapshot["eventType"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "eventType")
          }
        }

        public var eventTypeString: String {
          get {
            return snapshot["eventTypeString"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "eventTypeString")
          }
        }

        public var location: String? {
          get {
            return snapshot["location"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "location")
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

        public var lastReloaded: Int? {
          get {
            return snapshot["lastReloaded"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "lastReloaded")
          }
        }

        public var oprLastModified: Int? {
          get {
            return snapshot["oprLastModified"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "oprLastModified")
          }
        }

        public var matchesLastModified: Int? {
          get {
            return snapshot["matchesLastModified"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "matchesLastModified")
          }
        }

        public var statusesLastModified: Int? {
          get {
            return snapshot["statusesLastModified"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "statusesLastModified")
          }
        }
      }
    }
  }
}

public final class GetTeamQuery: GraphQLQuery {
  public static let operationString =
    "query GetTeam($id: ID!) {\n  getTeam(id: $id) {\n    __typename\n    id\n    location\n    name\n    nickname\n    rookieYear\n    teamNumber\n    website\n    isPicked\n    programmingLanguage\n    computerVisionCapability\n    robotHeight\n    robotLength\n    robotWidth\n    robotWeight\n    frontImage\n    strategy\n    canBanana\n    driverXP\n    driveTrain\n    otherAttributes\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getTeam", arguments: ["id": GraphQLVariable("id")], type: .object(GetTeam.selections)),
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
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
        GraphQLField("rookieYear", type: .scalar(Int.self)),
        GraphQLField("teamNumber", type: .nonNull(.scalar(Int.self))),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("isPicked", type: .scalar(Bool.self)),
        GraphQLField("programmingLanguage", type: .scalar(String.self)),
        GraphQLField("computerVisionCapability", type: .scalar(String.self)),
        GraphQLField("robotHeight", type: .scalar(Double.self)),
        GraphQLField("robotLength", type: .scalar(Double.self)),
        GraphQLField("robotWidth", type: .scalar(Double.self)),
        GraphQLField("robotWeight", type: .scalar(Double.self)),
        GraphQLField("frontImage", type: .scalar(String.self)),
        GraphQLField("strategy", type: .scalar(String.self)),
        GraphQLField("canBanana", type: .scalar(Bool.self)),
        GraphQLField("driverXP", type: .scalar(Double.self)),
        GraphQLField("driveTrain", type: .scalar(String.self)),
        GraphQLField("otherAttributes", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: String? = nil, name: String, nickname: String, rookieYear: Int? = nil, teamNumber: Int, website: String? = nil, isPicked: Bool? = nil, programmingLanguage: String? = nil, computerVisionCapability: String? = nil, robotHeight: Double? = nil, robotLength: Double? = nil, robotWidth: Double? = nil, robotWeight: Double? = nil, frontImage: String? = nil, strategy: String? = nil, canBanana: Bool? = nil, driverXp: Double? = nil, driveTrain: String? = nil, otherAttributes: String? = nil) {
        self.init(snapshot: ["__typename": "Team", "id": id, "location": location, "name": name, "nickname": nickname, "rookieYear": rookieYear, "teamNumber": teamNumber, "website": website, "isPicked": isPicked, "programmingLanguage": programmingLanguage, "computerVisionCapability": computerVisionCapability, "robotHeight": robotHeight, "robotLength": robotLength, "robotWidth": robotWidth, "robotWeight": robotWeight, "frontImage": frontImage, "strategy": strategy, "canBanana": canBanana, "driverXP": driverXp, "driveTrain": driveTrain, "otherAttributes": otherAttributes])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
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
          return snapshot["rookieYear"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "rookieYear")
        }
      }

      public var teamNumber: Int {
        get {
          return snapshot["teamNumber"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamNumber")
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

      public var isPicked: Bool? {
        get {
          return snapshot["isPicked"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isPicked")
        }
      }

      public var programmingLanguage: String? {
        get {
          return snapshot["programmingLanguage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "programmingLanguage")
        }
      }

      public var computerVisionCapability: String? {
        get {
          return snapshot["computerVisionCapability"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "computerVisionCapability")
        }
      }

      public var robotHeight: Double? {
        get {
          return snapshot["robotHeight"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotHeight")
        }
      }

      public var robotLength: Double? {
        get {
          return snapshot["robotLength"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotLength")
        }
      }

      public var robotWidth: Double? {
        get {
          return snapshot["robotWidth"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotWidth")
        }
      }

      public var robotWeight: Double? {
        get {
          return snapshot["robotWeight"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotWeight")
        }
      }

      public var frontImage: String? {
        get {
          return snapshot["frontImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "frontImage")
        }
      }

      public var strategy: String? {
        get {
          return snapshot["strategy"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "strategy")
        }
      }

      public var canBanana: Bool? {
        get {
          return snapshot["canBanana"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "canBanana")
        }
      }

      public var driverXp: Double? {
        get {
          return snapshot["driverXP"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "driverXP")
        }
      }

      public var driveTrain: String? {
        get {
          return snapshot["driveTrain"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "driveTrain")
        }
      }

      public var otherAttributes: String? {
        get {
          return snapshot["otherAttributes"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "otherAttributes")
        }
      }
    }
  }
}

public final class ListTeamsQuery: GraphQLQuery {
  public static let operationString =
    "query ListTeams($filter: TableTeamFilterInput, $limit: Int, $nextToken: String) {\n  listTeams(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      location\n      name\n      nickname\n      rookieYear\n      teamNumber\n      website\n      isPicked\n      programmingLanguage\n      computerVisionCapability\n      robotHeight\n      robotLength\n      robotWidth\n      robotWeight\n      frontImage\n      strategy\n      canBanana\n      driverXP\n      driveTrain\n      otherAttributes\n    }\n    nextToken\n  }\n}"

  public var filter: TableTeamFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: TableTeamFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listTeams", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listTeams: ListTeam? = nil) {
      self.init(snapshot: ["__typename": "Query", "listTeams": listTeams.flatMap { $0.snapshot }])
    }

    public var listTeams: ListTeam? {
      get {
        return (snapshot["listTeams"] as? Snapshot).flatMap { ListTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listTeams")
      }
    }

    public struct ListTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["TeamConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .list(.object(Item.selections))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?]? = nil, nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "TeamConnection", "items": items.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?]? {
        get {
          return (snapshot["items"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Item(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["Team"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("location", type: .scalar(String.self)),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
          GraphQLField("rookieYear", type: .scalar(Int.self)),
          GraphQLField("teamNumber", type: .nonNull(.scalar(Int.self))),
          GraphQLField("website", type: .scalar(String.self)),
          GraphQLField("isPicked", type: .scalar(Bool.self)),
          GraphQLField("programmingLanguage", type: .scalar(String.self)),
          GraphQLField("computerVisionCapability", type: .scalar(String.self)),
          GraphQLField("robotHeight", type: .scalar(Double.self)),
          GraphQLField("robotLength", type: .scalar(Double.self)),
          GraphQLField("robotWidth", type: .scalar(Double.self)),
          GraphQLField("robotWeight", type: .scalar(Double.self)),
          GraphQLField("frontImage", type: .scalar(String.self)),
          GraphQLField("strategy", type: .scalar(String.self)),
          GraphQLField("canBanana", type: .scalar(Bool.self)),
          GraphQLField("driverXP", type: .scalar(Double.self)),
          GraphQLField("driveTrain", type: .scalar(String.self)),
          GraphQLField("otherAttributes", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, location: String? = nil, name: String, nickname: String, rookieYear: Int? = nil, teamNumber: Int, website: String? = nil, isPicked: Bool? = nil, programmingLanguage: String? = nil, computerVisionCapability: String? = nil, robotHeight: Double? = nil, robotLength: Double? = nil, robotWidth: Double? = nil, robotWeight: Double? = nil, frontImage: String? = nil, strategy: String? = nil, canBanana: Bool? = nil, driverXp: Double? = nil, driveTrain: String? = nil, otherAttributes: String? = nil) {
          self.init(snapshot: ["__typename": "Team", "id": id, "location": location, "name": name, "nickname": nickname, "rookieYear": rookieYear, "teamNumber": teamNumber, "website": website, "isPicked": isPicked, "programmingLanguage": programmingLanguage, "computerVisionCapability": computerVisionCapability, "robotHeight": robotHeight, "robotLength": robotLength, "robotWidth": robotWidth, "robotWeight": robotWeight, "frontImage": frontImage, "strategy": strategy, "canBanana": canBanana, "driverXP": driverXp, "driveTrain": driveTrain, "otherAttributes": otherAttributes])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var location: String? {
          get {
            return snapshot["location"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "location")
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
            return snapshot["rookieYear"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "rookieYear")
          }
        }

        public var teamNumber: Int {
          get {
            return snapshot["teamNumber"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "teamNumber")
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

        public var isPicked: Bool? {
          get {
            return snapshot["isPicked"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "isPicked")
          }
        }

        public var programmingLanguage: String? {
          get {
            return snapshot["programmingLanguage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "programmingLanguage")
          }
        }

        public var computerVisionCapability: String? {
          get {
            return snapshot["computerVisionCapability"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "computerVisionCapability")
          }
        }

        public var robotHeight: Double? {
          get {
            return snapshot["robotHeight"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "robotHeight")
          }
        }

        public var robotLength: Double? {
          get {
            return snapshot["robotLength"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "robotLength")
          }
        }

        public var robotWidth: Double? {
          get {
            return snapshot["robotWidth"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "robotWidth")
          }
        }

        public var robotWeight: Double? {
          get {
            return snapshot["robotWeight"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "robotWeight")
          }
        }

        public var frontImage: String? {
          get {
            return snapshot["frontImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "frontImage")
          }
        }

        public var strategy: String? {
          get {
            return snapshot["strategy"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "strategy")
          }
        }

        public var canBanana: Bool? {
          get {
            return snapshot["canBanana"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "canBanana")
          }
        }

        public var driverXp: Double? {
          get {
            return snapshot["driverXP"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "driverXP")
          }
        }

        public var driveTrain: String? {
          get {
            return snapshot["driveTrain"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "driveTrain")
          }
        }

        public var otherAttributes: String? {
          get {
            return snapshot["otherAttributes"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "otherAttributes")
          }
        }
      }
    }
  }
}

public final class OnCreateEventSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateEvent($id: ID, $code: String, $eventType: Int, $eventTypeString: String, $location: String) {\n  onCreateEvent(id: $id, code: $code, eventType: $eventType, eventTypeString: $eventTypeString, location: $location) {\n    __typename\n    id\n    code\n    eventType\n    eventTypeString\n    location\n    name\n    year\n    lastReloaded\n    oprLastModified\n    matchesLastModified\n    statusesLastModified\n  }\n}"

  public var id: GraphQLID?
  public var code: String?
  public var eventType: Int?
  public var eventTypeString: String?
  public var location: String?

  public init(id: GraphQLID? = nil, code: String? = nil, eventType: Int? = nil, eventTypeString: String? = nil, location: String? = nil) {
    self.id = id
    self.code = code
    self.eventType = eventType
    self.eventTypeString = eventTypeString
    self.location = location
  }

  public var variables: GraphQLMap? {
    return ["id": id, "code": code, "eventType": eventType, "eventTypeString": eventTypeString, "location": location]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateEvent", arguments: ["id": GraphQLVariable("id"), "code": GraphQLVariable("code"), "eventType": GraphQLVariable("eventType"), "eventTypeString": GraphQLVariable("eventTypeString"), "location": GraphQLVariable("location")], type: .object(OnCreateEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateEvent: OnCreateEvent? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateEvent": onCreateEvent.flatMap { $0.snapshot }])
    }

    public var onCreateEvent: OnCreateEvent? {
      get {
        return (snapshot["onCreateEvent"] as? Snapshot).flatMap { OnCreateEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateEvent")
      }
    }

    public struct OnCreateEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("code", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventType", type: .nonNull(.scalar(Int.self))),
        GraphQLField("eventTypeString", type: .nonNull(.scalar(String.self))),
        GraphQLField("location", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("lastReloaded", type: .scalar(Int.self)),
        GraphQLField("oprLastModified", type: .scalar(Int.self)),
        GraphQLField("matchesLastModified", type: .scalar(Int.self)),
        GraphQLField("statusesLastModified", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, code: String, eventType: Int, eventTypeString: String, location: String? = nil, name: String, year: Int, lastReloaded: Int? = nil, oprLastModified: Int? = nil, matchesLastModified: Int? = nil, statusesLastModified: Int? = nil) {
        self.init(snapshot: ["__typename": "Event", "id": id, "code": code, "eventType": eventType, "eventTypeString": eventTypeString, "location": location, "name": name, "year": year, "lastReloaded": lastReloaded, "oprLastModified": oprLastModified, "matchesLastModified": matchesLastModified, "statusesLastModified": statusesLastModified])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var code: String {
        get {
          return snapshot["code"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "code")
        }
      }

      public var eventType: Int {
        get {
          return snapshot["eventType"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventType")
        }
      }

      public var eventTypeString: String {
        get {
          return snapshot["eventTypeString"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventTypeString")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
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

      public var lastReloaded: Int? {
        get {
          return snapshot["lastReloaded"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastReloaded")
        }
      }

      public var oprLastModified: Int? {
        get {
          return snapshot["oprLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "oprLastModified")
        }
      }

      public var matchesLastModified: Int? {
        get {
          return snapshot["matchesLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "matchesLastModified")
        }
      }

      public var statusesLastModified: Int? {
        get {
          return snapshot["statusesLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "statusesLastModified")
        }
      }
    }
  }
}

public final class OnUpdateEventSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateEvent($id: ID, $code: String, $eventType: Int, $eventTypeString: String, $location: String) {\n  onUpdateEvent(id: $id, code: $code, eventType: $eventType, eventTypeString: $eventTypeString, location: $location) {\n    __typename\n    id\n    code\n    eventType\n    eventTypeString\n    location\n    name\n    year\n    lastReloaded\n    oprLastModified\n    matchesLastModified\n    statusesLastModified\n  }\n}"

  public var id: GraphQLID?
  public var code: String?
  public var eventType: Int?
  public var eventTypeString: String?
  public var location: String?

  public init(id: GraphQLID? = nil, code: String? = nil, eventType: Int? = nil, eventTypeString: String? = nil, location: String? = nil) {
    self.id = id
    self.code = code
    self.eventType = eventType
    self.eventTypeString = eventTypeString
    self.location = location
  }

  public var variables: GraphQLMap? {
    return ["id": id, "code": code, "eventType": eventType, "eventTypeString": eventTypeString, "location": location]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateEvent", arguments: ["id": GraphQLVariable("id"), "code": GraphQLVariable("code"), "eventType": GraphQLVariable("eventType"), "eventTypeString": GraphQLVariable("eventTypeString"), "location": GraphQLVariable("location")], type: .object(OnUpdateEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateEvent: OnUpdateEvent? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateEvent": onUpdateEvent.flatMap { $0.snapshot }])
    }

    public var onUpdateEvent: OnUpdateEvent? {
      get {
        return (snapshot["onUpdateEvent"] as? Snapshot).flatMap { OnUpdateEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateEvent")
      }
    }

    public struct OnUpdateEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("code", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventType", type: .nonNull(.scalar(Int.self))),
        GraphQLField("eventTypeString", type: .nonNull(.scalar(String.self))),
        GraphQLField("location", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("lastReloaded", type: .scalar(Int.self)),
        GraphQLField("oprLastModified", type: .scalar(Int.self)),
        GraphQLField("matchesLastModified", type: .scalar(Int.self)),
        GraphQLField("statusesLastModified", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, code: String, eventType: Int, eventTypeString: String, location: String? = nil, name: String, year: Int, lastReloaded: Int? = nil, oprLastModified: Int? = nil, matchesLastModified: Int? = nil, statusesLastModified: Int? = nil) {
        self.init(snapshot: ["__typename": "Event", "id": id, "code": code, "eventType": eventType, "eventTypeString": eventTypeString, "location": location, "name": name, "year": year, "lastReloaded": lastReloaded, "oprLastModified": oprLastModified, "matchesLastModified": matchesLastModified, "statusesLastModified": statusesLastModified])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var code: String {
        get {
          return snapshot["code"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "code")
        }
      }

      public var eventType: Int {
        get {
          return snapshot["eventType"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventType")
        }
      }

      public var eventTypeString: String {
        get {
          return snapshot["eventTypeString"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventTypeString")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
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

      public var lastReloaded: Int? {
        get {
          return snapshot["lastReloaded"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastReloaded")
        }
      }

      public var oprLastModified: Int? {
        get {
          return snapshot["oprLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "oprLastModified")
        }
      }

      public var matchesLastModified: Int? {
        get {
          return snapshot["matchesLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "matchesLastModified")
        }
      }

      public var statusesLastModified: Int? {
        get {
          return snapshot["statusesLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "statusesLastModified")
        }
      }
    }
  }
}

public final class OnDeleteEventSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteEvent($id: ID, $code: String, $eventType: Int, $eventTypeString: String, $location: String) {\n  onDeleteEvent(id: $id, code: $code, eventType: $eventType, eventTypeString: $eventTypeString, location: $location) {\n    __typename\n    id\n    code\n    eventType\n    eventTypeString\n    location\n    name\n    year\n    lastReloaded\n    oprLastModified\n    matchesLastModified\n    statusesLastModified\n  }\n}"

  public var id: GraphQLID?
  public var code: String?
  public var eventType: Int?
  public var eventTypeString: String?
  public var location: String?

  public init(id: GraphQLID? = nil, code: String? = nil, eventType: Int? = nil, eventTypeString: String? = nil, location: String? = nil) {
    self.id = id
    self.code = code
    self.eventType = eventType
    self.eventTypeString = eventTypeString
    self.location = location
  }

  public var variables: GraphQLMap? {
    return ["id": id, "code": code, "eventType": eventType, "eventTypeString": eventTypeString, "location": location]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteEvent", arguments: ["id": GraphQLVariable("id"), "code": GraphQLVariable("code"), "eventType": GraphQLVariable("eventType"), "eventTypeString": GraphQLVariable("eventTypeString"), "location": GraphQLVariable("location")], type: .object(OnDeleteEvent.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteEvent: OnDeleteEvent? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteEvent": onDeleteEvent.flatMap { $0.snapshot }])
    }

    public var onDeleteEvent: OnDeleteEvent? {
      get {
        return (snapshot["onDeleteEvent"] as? Snapshot).flatMap { OnDeleteEvent(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteEvent")
      }
    }

    public struct OnDeleteEvent: GraphQLSelectionSet {
      public static let possibleTypes = ["Event"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("code", type: .nonNull(.scalar(String.self))),
        GraphQLField("eventType", type: .nonNull(.scalar(Int.self))),
        GraphQLField("eventTypeString", type: .nonNull(.scalar(String.self))),
        GraphQLField("location", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("year", type: .nonNull(.scalar(Int.self))),
        GraphQLField("lastReloaded", type: .scalar(Int.self)),
        GraphQLField("oprLastModified", type: .scalar(Int.self)),
        GraphQLField("matchesLastModified", type: .scalar(Int.self)),
        GraphQLField("statusesLastModified", type: .scalar(Int.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, code: String, eventType: Int, eventTypeString: String, location: String? = nil, name: String, year: Int, lastReloaded: Int? = nil, oprLastModified: Int? = nil, matchesLastModified: Int? = nil, statusesLastModified: Int? = nil) {
        self.init(snapshot: ["__typename": "Event", "id": id, "code": code, "eventType": eventType, "eventTypeString": eventTypeString, "location": location, "name": name, "year": year, "lastReloaded": lastReloaded, "oprLastModified": oprLastModified, "matchesLastModified": matchesLastModified, "statusesLastModified": statusesLastModified])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var code: String {
        get {
          return snapshot["code"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "code")
        }
      }

      public var eventType: Int {
        get {
          return snapshot["eventType"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventType")
        }
      }

      public var eventTypeString: String {
        get {
          return snapshot["eventTypeString"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "eventTypeString")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
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

      public var lastReloaded: Int? {
        get {
          return snapshot["lastReloaded"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastReloaded")
        }
      }

      public var oprLastModified: Int? {
        get {
          return snapshot["oprLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "oprLastModified")
        }
      }

      public var matchesLastModified: Int? {
        get {
          return snapshot["matchesLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "matchesLastModified")
        }
      }

      public var statusesLastModified: Int? {
        get {
          return snapshot["statusesLastModified"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "statusesLastModified")
        }
      }
    }
  }
}

public final class OnCreateTeamSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateTeam($id: ID, $location: String, $name: String, $nickname: String, $rookieYear: Int) {\n  onCreateTeam(id: $id, location: $location, name: $name, nickname: $nickname, rookieYear: $rookieYear) {\n    __typename\n    id\n    location\n    name\n    nickname\n    rookieYear\n    teamNumber\n    website\n    isPicked\n    programmingLanguage\n    computerVisionCapability\n    robotHeight\n    robotLength\n    robotWidth\n    robotWeight\n    frontImage\n    strategy\n    canBanana\n    driverXP\n    driveTrain\n    otherAttributes\n  }\n}"

  public var id: GraphQLID?
  public var location: String?
  public var name: String?
  public var nickname: String?
  public var rookieYear: Int?

  public init(id: GraphQLID? = nil, location: String? = nil, name: String? = nil, nickname: String? = nil, rookieYear: Int? = nil) {
    self.id = id
    self.location = location
    self.name = name
    self.nickname = nickname
    self.rookieYear = rookieYear
  }

  public var variables: GraphQLMap? {
    return ["id": id, "location": location, "name": name, "nickname": nickname, "rookieYear": rookieYear]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateTeam", arguments: ["id": GraphQLVariable("id"), "location": GraphQLVariable("location"), "name": GraphQLVariable("name"), "nickname": GraphQLVariable("nickname"), "rookieYear": GraphQLVariable("rookieYear")], type: .object(OnCreateTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateTeam: OnCreateTeam? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateTeam": onCreateTeam.flatMap { $0.snapshot }])
    }

    public var onCreateTeam: OnCreateTeam? {
      get {
        return (snapshot["onCreateTeam"] as? Snapshot).flatMap { OnCreateTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateTeam")
      }
    }

    public struct OnCreateTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["Team"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
        GraphQLField("rookieYear", type: .scalar(Int.self)),
        GraphQLField("teamNumber", type: .nonNull(.scalar(Int.self))),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("isPicked", type: .scalar(Bool.self)),
        GraphQLField("programmingLanguage", type: .scalar(String.self)),
        GraphQLField("computerVisionCapability", type: .scalar(String.self)),
        GraphQLField("robotHeight", type: .scalar(Double.self)),
        GraphQLField("robotLength", type: .scalar(Double.self)),
        GraphQLField("robotWidth", type: .scalar(Double.self)),
        GraphQLField("robotWeight", type: .scalar(Double.self)),
        GraphQLField("frontImage", type: .scalar(String.self)),
        GraphQLField("strategy", type: .scalar(String.self)),
        GraphQLField("canBanana", type: .scalar(Bool.self)),
        GraphQLField("driverXP", type: .scalar(Double.self)),
        GraphQLField("driveTrain", type: .scalar(String.self)),
        GraphQLField("otherAttributes", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: String? = nil, name: String, nickname: String, rookieYear: Int? = nil, teamNumber: Int, website: String? = nil, isPicked: Bool? = nil, programmingLanguage: String? = nil, computerVisionCapability: String? = nil, robotHeight: Double? = nil, robotLength: Double? = nil, robotWidth: Double? = nil, robotWeight: Double? = nil, frontImage: String? = nil, strategy: String? = nil, canBanana: Bool? = nil, driverXp: Double? = nil, driveTrain: String? = nil, otherAttributes: String? = nil) {
        self.init(snapshot: ["__typename": "Team", "id": id, "location": location, "name": name, "nickname": nickname, "rookieYear": rookieYear, "teamNumber": teamNumber, "website": website, "isPicked": isPicked, "programmingLanguage": programmingLanguage, "computerVisionCapability": computerVisionCapability, "robotHeight": robotHeight, "robotLength": robotLength, "robotWidth": robotWidth, "robotWeight": robotWeight, "frontImage": frontImage, "strategy": strategy, "canBanana": canBanana, "driverXP": driverXp, "driveTrain": driveTrain, "otherAttributes": otherAttributes])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
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
          return snapshot["rookieYear"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "rookieYear")
        }
      }

      public var teamNumber: Int {
        get {
          return snapshot["teamNumber"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamNumber")
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

      public var isPicked: Bool? {
        get {
          return snapshot["isPicked"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isPicked")
        }
      }

      public var programmingLanguage: String? {
        get {
          return snapshot["programmingLanguage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "programmingLanguage")
        }
      }

      public var computerVisionCapability: String? {
        get {
          return snapshot["computerVisionCapability"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "computerVisionCapability")
        }
      }

      public var robotHeight: Double? {
        get {
          return snapshot["robotHeight"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotHeight")
        }
      }

      public var robotLength: Double? {
        get {
          return snapshot["robotLength"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotLength")
        }
      }

      public var robotWidth: Double? {
        get {
          return snapshot["robotWidth"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotWidth")
        }
      }

      public var robotWeight: Double? {
        get {
          return snapshot["robotWeight"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotWeight")
        }
      }

      public var frontImage: String? {
        get {
          return snapshot["frontImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "frontImage")
        }
      }

      public var strategy: String? {
        get {
          return snapshot["strategy"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "strategy")
        }
      }

      public var canBanana: Bool? {
        get {
          return snapshot["canBanana"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "canBanana")
        }
      }

      public var driverXp: Double? {
        get {
          return snapshot["driverXP"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "driverXP")
        }
      }

      public var driveTrain: String? {
        get {
          return snapshot["driveTrain"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "driveTrain")
        }
      }

      public var otherAttributes: String? {
        get {
          return snapshot["otherAttributes"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "otherAttributes")
        }
      }
    }
  }
}

public final class OnUpdateTeamSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateTeam($id: ID, $location: String, $name: String, $nickname: String, $rookieYear: Int) {\n  onUpdateTeam(id: $id, location: $location, name: $name, nickname: $nickname, rookieYear: $rookieYear) {\n    __typename\n    id\n    location\n    name\n    nickname\n    rookieYear\n    teamNumber\n    website\n    isPicked\n    programmingLanguage\n    computerVisionCapability\n    robotHeight\n    robotLength\n    robotWidth\n    robotWeight\n    frontImage\n    strategy\n    canBanana\n    driverXP\n    driveTrain\n    otherAttributes\n  }\n}"

  public var id: GraphQLID?
  public var location: String?
  public var name: String?
  public var nickname: String?
  public var rookieYear: Int?

  public init(id: GraphQLID? = nil, location: String? = nil, name: String? = nil, nickname: String? = nil, rookieYear: Int? = nil) {
    self.id = id
    self.location = location
    self.name = name
    self.nickname = nickname
    self.rookieYear = rookieYear
  }

  public var variables: GraphQLMap? {
    return ["id": id, "location": location, "name": name, "nickname": nickname, "rookieYear": rookieYear]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateTeam", arguments: ["id": GraphQLVariable("id"), "location": GraphQLVariable("location"), "name": GraphQLVariable("name"), "nickname": GraphQLVariable("nickname"), "rookieYear": GraphQLVariable("rookieYear")], type: .object(OnUpdateTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateTeam: OnUpdateTeam? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateTeam": onUpdateTeam.flatMap { $0.snapshot }])
    }

    public var onUpdateTeam: OnUpdateTeam? {
      get {
        return (snapshot["onUpdateTeam"] as? Snapshot).flatMap { OnUpdateTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateTeam")
      }
    }

    public struct OnUpdateTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["Team"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
        GraphQLField("rookieYear", type: .scalar(Int.self)),
        GraphQLField("teamNumber", type: .nonNull(.scalar(Int.self))),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("isPicked", type: .scalar(Bool.self)),
        GraphQLField("programmingLanguage", type: .scalar(String.self)),
        GraphQLField("computerVisionCapability", type: .scalar(String.self)),
        GraphQLField("robotHeight", type: .scalar(Double.self)),
        GraphQLField("robotLength", type: .scalar(Double.self)),
        GraphQLField("robotWidth", type: .scalar(Double.self)),
        GraphQLField("robotWeight", type: .scalar(Double.self)),
        GraphQLField("frontImage", type: .scalar(String.self)),
        GraphQLField("strategy", type: .scalar(String.self)),
        GraphQLField("canBanana", type: .scalar(Bool.self)),
        GraphQLField("driverXP", type: .scalar(Double.self)),
        GraphQLField("driveTrain", type: .scalar(String.self)),
        GraphQLField("otherAttributes", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: String? = nil, name: String, nickname: String, rookieYear: Int? = nil, teamNumber: Int, website: String? = nil, isPicked: Bool? = nil, programmingLanguage: String? = nil, computerVisionCapability: String? = nil, robotHeight: Double? = nil, robotLength: Double? = nil, robotWidth: Double? = nil, robotWeight: Double? = nil, frontImage: String? = nil, strategy: String? = nil, canBanana: Bool? = nil, driverXp: Double? = nil, driveTrain: String? = nil, otherAttributes: String? = nil) {
        self.init(snapshot: ["__typename": "Team", "id": id, "location": location, "name": name, "nickname": nickname, "rookieYear": rookieYear, "teamNumber": teamNumber, "website": website, "isPicked": isPicked, "programmingLanguage": programmingLanguage, "computerVisionCapability": computerVisionCapability, "robotHeight": robotHeight, "robotLength": robotLength, "robotWidth": robotWidth, "robotWeight": robotWeight, "frontImage": frontImage, "strategy": strategy, "canBanana": canBanana, "driverXP": driverXp, "driveTrain": driveTrain, "otherAttributes": otherAttributes])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
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
          return snapshot["rookieYear"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "rookieYear")
        }
      }

      public var teamNumber: Int {
        get {
          return snapshot["teamNumber"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamNumber")
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

      public var isPicked: Bool? {
        get {
          return snapshot["isPicked"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isPicked")
        }
      }

      public var programmingLanguage: String? {
        get {
          return snapshot["programmingLanguage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "programmingLanguage")
        }
      }

      public var computerVisionCapability: String? {
        get {
          return snapshot["computerVisionCapability"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "computerVisionCapability")
        }
      }

      public var robotHeight: Double? {
        get {
          return snapshot["robotHeight"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotHeight")
        }
      }

      public var robotLength: Double? {
        get {
          return snapshot["robotLength"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotLength")
        }
      }

      public var robotWidth: Double? {
        get {
          return snapshot["robotWidth"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotWidth")
        }
      }

      public var robotWeight: Double? {
        get {
          return snapshot["robotWeight"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotWeight")
        }
      }

      public var frontImage: String? {
        get {
          return snapshot["frontImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "frontImage")
        }
      }

      public var strategy: String? {
        get {
          return snapshot["strategy"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "strategy")
        }
      }

      public var canBanana: Bool? {
        get {
          return snapshot["canBanana"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "canBanana")
        }
      }

      public var driverXp: Double? {
        get {
          return snapshot["driverXP"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "driverXP")
        }
      }

      public var driveTrain: String? {
        get {
          return snapshot["driveTrain"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "driveTrain")
        }
      }

      public var otherAttributes: String? {
        get {
          return snapshot["otherAttributes"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "otherAttributes")
        }
      }
    }
  }
}

public final class OnDeleteTeamSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteTeam($id: ID, $location: String, $name: String, $nickname: String, $rookieYear: Int) {\n  onDeleteTeam(id: $id, location: $location, name: $name, nickname: $nickname, rookieYear: $rookieYear) {\n    __typename\n    id\n    location\n    name\n    nickname\n    rookieYear\n    teamNumber\n    website\n    isPicked\n    programmingLanguage\n    computerVisionCapability\n    robotHeight\n    robotLength\n    robotWidth\n    robotWeight\n    frontImage\n    strategy\n    canBanana\n    driverXP\n    driveTrain\n    otherAttributes\n  }\n}"

  public var id: GraphQLID?
  public var location: String?
  public var name: String?
  public var nickname: String?
  public var rookieYear: Int?

  public init(id: GraphQLID? = nil, location: String? = nil, name: String? = nil, nickname: String? = nil, rookieYear: Int? = nil) {
    self.id = id
    self.location = location
    self.name = name
    self.nickname = nickname
    self.rookieYear = rookieYear
  }

  public var variables: GraphQLMap? {
    return ["id": id, "location": location, "name": name, "nickname": nickname, "rookieYear": rookieYear]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteTeam", arguments: ["id": GraphQLVariable("id"), "location": GraphQLVariable("location"), "name": GraphQLVariable("name"), "nickname": GraphQLVariable("nickname"), "rookieYear": GraphQLVariable("rookieYear")], type: .object(OnDeleteTeam.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteTeam: OnDeleteTeam? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteTeam": onDeleteTeam.flatMap { $0.snapshot }])
    }

    public var onDeleteTeam: OnDeleteTeam? {
      get {
        return (snapshot["onDeleteTeam"] as? Snapshot).flatMap { OnDeleteTeam(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteTeam")
      }
    }

    public struct OnDeleteTeam: GraphQLSelectionSet {
      public static let possibleTypes = ["Team"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("location", type: .scalar(String.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
        GraphQLField("rookieYear", type: .scalar(Int.self)),
        GraphQLField("teamNumber", type: .nonNull(.scalar(Int.self))),
        GraphQLField("website", type: .scalar(String.self)),
        GraphQLField("isPicked", type: .scalar(Bool.self)),
        GraphQLField("programmingLanguage", type: .scalar(String.self)),
        GraphQLField("computerVisionCapability", type: .scalar(String.self)),
        GraphQLField("robotHeight", type: .scalar(Double.self)),
        GraphQLField("robotLength", type: .scalar(Double.self)),
        GraphQLField("robotWidth", type: .scalar(Double.self)),
        GraphQLField("robotWeight", type: .scalar(Double.self)),
        GraphQLField("frontImage", type: .scalar(String.self)),
        GraphQLField("strategy", type: .scalar(String.self)),
        GraphQLField("canBanana", type: .scalar(Bool.self)),
        GraphQLField("driverXP", type: .scalar(Double.self)),
        GraphQLField("driveTrain", type: .scalar(String.self)),
        GraphQLField("otherAttributes", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, location: String? = nil, name: String, nickname: String, rookieYear: Int? = nil, teamNumber: Int, website: String? = nil, isPicked: Bool? = nil, programmingLanguage: String? = nil, computerVisionCapability: String? = nil, robotHeight: Double? = nil, robotLength: Double? = nil, robotWidth: Double? = nil, robotWeight: Double? = nil, frontImage: String? = nil, strategy: String? = nil, canBanana: Bool? = nil, driverXp: Double? = nil, driveTrain: String? = nil, otherAttributes: String? = nil) {
        self.init(snapshot: ["__typename": "Team", "id": id, "location": location, "name": name, "nickname": nickname, "rookieYear": rookieYear, "teamNumber": teamNumber, "website": website, "isPicked": isPicked, "programmingLanguage": programmingLanguage, "computerVisionCapability": computerVisionCapability, "robotHeight": robotHeight, "robotLength": robotLength, "robotWidth": robotWidth, "robotWeight": robotWeight, "frontImage": frontImage, "strategy": strategy, "canBanana": canBanana, "driverXP": driverXp, "driveTrain": driveTrain, "otherAttributes": otherAttributes])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
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
          return snapshot["rookieYear"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "rookieYear")
        }
      }

      public var teamNumber: Int {
        get {
          return snapshot["teamNumber"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "teamNumber")
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

      public var isPicked: Bool? {
        get {
          return snapshot["isPicked"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "isPicked")
        }
      }

      public var programmingLanguage: String? {
        get {
          return snapshot["programmingLanguage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "programmingLanguage")
        }
      }

      public var computerVisionCapability: String? {
        get {
          return snapshot["computerVisionCapability"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "computerVisionCapability")
        }
      }

      public var robotHeight: Double? {
        get {
          return snapshot["robotHeight"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotHeight")
        }
      }

      public var robotLength: Double? {
        get {
          return snapshot["robotLength"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotLength")
        }
      }

      public var robotWidth: Double? {
        get {
          return snapshot["robotWidth"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotWidth")
        }
      }

      public var robotWeight: Double? {
        get {
          return snapshot["robotWeight"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "robotWeight")
        }
      }

      public var frontImage: String? {
        get {
          return snapshot["frontImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "frontImage")
        }
      }

      public var strategy: String? {
        get {
          return snapshot["strategy"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "strategy")
        }
      }

      public var canBanana: Bool? {
        get {
          return snapshot["canBanana"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "canBanana")
        }
      }

      public var driverXp: Double? {
        get {
          return snapshot["driverXP"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "driverXP")
        }
      }

      public var driveTrain: String? {
        get {
          return snapshot["driveTrain"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "driveTrain")
        }
      }

      public var otherAttributes: String? {
        get {
          return snapshot["otherAttributes"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "otherAttributes")
        }
      }
    }
  }
}
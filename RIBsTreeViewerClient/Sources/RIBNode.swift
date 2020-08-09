//
//  RIBNode.swift
//  RIBsTreeViewerClient
//
//  Created by sondt on 8/10/20.
//  Copyright © 2020 minipro. All rights reserved.
//

import Foundation

public protocol RIBNodeType: Encodable, Equatable {
    var nodeId: String { get }
    var name: String { get }
}

public struct RIBNode: RIBNodeType {
    public let nodeId: String
    public let name: String
    
    enum CodingKeys : String, CodingKey {
        case nodeId = "id"
        case name = "text"
    }
}

//
//  Tree.swift
//  RIBsTreeViewerClient
//
//  Created by sondt on 8/10/20.
//  Copyright © 2020 minipro. All rights reserved.
//

import Foundation

public class TreeNode<T: Equatable> {
    public var value: T
    
    public weak var parent: TreeNode?
    public var children = [TreeNode<T>]()
    
    public init(value: T) {
        self.value = value
    }
    
    public func addChild(_ node: TreeNode<T>) {
        children.append(node)
        node.parent = self
    }
    
    public func detacChild(_ node: TreeNode<T>) {
        guard let index = (children.firstIndex { $0.value == node.value }) else { return }
        let removedNode = children.remove(at: index)
        removedNode.parent = nil
    }
    
    public func search(_ value: T) -> TreeNode? {
        if value == self.value {
            return self
        }
        for child in children {
            if let found = child.search(value) {
                return found
            }
        }
        return nil
    }
}

extension TreeNode: Encodable where T: RIBNodeType {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "text"
        case children
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value.nodeId, forKey: .id)
        try container.encode(value.name, forKey: .name)
        try container.encode(children, forKey: .children)
    }
}

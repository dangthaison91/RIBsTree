//
//  RIBsTreeViewer.swift
//  RIBsTreeViewerClient
//
//  Created by yuki tamazawa on 2019/01/16.
//  Copyright © 2019 minipro. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RIBs

@available(iOS 13.0, *)
public class RIBsTreeViewer {
    lazy var appNode = RIBNode(nodeId: "app_node", name: "App")
    lazy var ribTree = TreeNode<RIBNode>(value: appNode)
    
    private lazy var webSocket: WebSocketClient = {
        guard let url = URL(string: socketURL) else {
            fatalError("Cannot get Socket URL from \(socketURL)")
        }
        return WebSocketClient(url: url)
    }()

    let socketURL: String
    
    private let disposeBag = DisposeBag()
    
    public init(socketURL: String = "ws://0.0.0.0:8080") {
        self.socketURL = socketURL
    }

    public func start(from router: Routing) {
        webSocket.connect()
        configureTracing(for: router, isRoot: true)
    }

    public func stop() {
        webSocket.disconnect()
    }
    
    func configureTracing(for router: Routing, isRoot: Bool) {
        if isRoot {
            updateTree(for: router, parent: router)
        }
        
        let resignActive = router.interactable.isActiveStream.skip(1).filter { $0 == false }
        
        let willAttachChild = router
            .lifecycle
            .compactMap { lifecycle -> Routing? in
                if case let .willAttachChild(child) = lifecycle {
                    return child
                } else {
                    return nil
                }
            }
            .takeUntil(resignActive)
        
        willAttachChild
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [weak self] child in
                /// Recursive observe child router
                self?.configureTracing(for: child, isRoot: false)
            })
            .disposed(by: disposeBag)
        
        
        willAttachChild
            .flatMap { child -> Observable<Routing> in
                let capturedChild = child
                return child.interactable.isActiveStream.filter { $0 }.compactMap { [weak capturedChild] _ in return capturedChild }
            }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [weak self] child in
                self?.updateTree(for: child, parent: router)
            })
            .disposed(by: disposeBag)
        
        router
            .lifecycle
            .compactMap { lifecycle -> Routing? in
                if case let .willDetachChild(child) = lifecycle {
                    return child
                } else {
                    return nil
                }
            }
            .takeUntil(resignActive)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [weak self] child in
                self?.removeTree(for: child, parent: router)
            })
            .disposed(by: disposeBag)
        
    }
    
    func updateTree(for router: Routing, parent: Routing) {
        defer {
            if let data = try? JSONEncoder().encode(ribTree) {
                webSocket.sendJSONData(data)
            }
        }
        
        let nextNode = node(for: router)
        let parenNode = node(for: parent)
        let treeNode = TreeNode<RIBNode>(value: nextNode)
        
        if let currentParent = ribTree.search(parenNode) {
            currentParent.addChild(treeNode)
        } else {
            ribTree.addChild(treeNode)
        }
    }

    func removeTree(for router: Routing, parent: Routing) {
        defer {
            if let data = try? JSONEncoder().encode(ribTree) {
                webSocket.sendJSONData(data)
            }
        }
        
        let nextNode = node(for: router)
        let treeNode = TreeNode<RIBNode>(value: nextNode)
        let parenNode = node(for: parent)

        
        if let parentNode = ribTree.search(parenNode) {
            parentNode.detacChild(treeNode)
        } else {
            debugPrint("Cannot detach child \(nextNode)")
        }
    }
    
    private func node(for router: Routing) -> RIBNode {
        let name = String(describing: type(of: router))
        let routerId = "\(ObjectIdentifier(router).hashValue)"
        let node = RIBNode(nodeId: routerId, name: name)
        return node
    }
}

@available(iOS 13.0, *)
extension RIBsTreeViewer: WebSocketClientDelegate {
    
    func onConnected(client: WebSocketClient) {}

    func onDisconnected(client: WebSocketClient) {}

    func onMessage(client: WebSocketClient, text: String) {}

    func onMessage(client: WebSocketClient, data: Data) {}

    func onError(client: WebSocketClient, error: Error) {}
}

@available(iOS 13.0, *)
protocol WebSocketClientDelegate: class {
    func onConnected(client: WebSocketClient)
    func onDisconnected(client: WebSocketClient)
    func onMessage(client: WebSocketClient, text: String)
    func onMessage(client: WebSocketClient, data: Data)
    func onError(client: WebSocketClient, error: Error)
}

@available(iOS 13.0, *)
class WebSocketClient: NSObject {

    weak var delegate: WebSocketClientDelegate?
    var webSocketTask: URLSessionWebSocketTask!
    var urlSession: URLSession!
    let delegateQueue = OperationQueue()
    let url: URL

    init(url: URL) {
        self.url = url
        super.init()
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: delegateQueue)
        self.webSocketTask = urlSession.webSocketTask(with: url)
    }

    func connect() {
        if webSocketTask.state == .completed {
            webSocketTask = urlSession.webSocketTask(with: url)
        }
        webSocketTask.resume()
        listen()
    }

    func disconnect() {
        webSocketTask.cancel(with: .goingAway, reason: nil)
    }

    func send(data: Data) {
        webSocketTask.send(.data(data)) { error in
            guard let error = error else {
                return
            }
            self.delegate?.onError(client: self, error: error)
        }
    }

    func send(text: String) {
        webSocketTask.send(.string(text)) { error in
            guard let error = error else {
                return
            }
            self.delegate?.onError(client: self, error: error)
        }
    }

    private func listen() {
        webSocketTask.receive { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self.delegate?.onMessage(client: self, data: data)
                case .string(let text):
                    self.delegate?.onMessage(client: self, text: text)
                @unknown default:
                    fatalError()
                }
            case .failure(let error):
                self.delegate?.onError(client: self, error: error)
            }
            self.listen()
        }
    }
}

@available(iOS 13.0, *)
extension WebSocketClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.delegate?.onConnected(client: self)
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.delegate?.onDisconnected(client: self)
    }
}

@available(iOS 13.0, *)
extension WebSocketClient {
    func sendJSONData(_ data: Data) {
        let jsonString = String(bytes: data, encoding: .utf8)!
        self.send(text: jsonString)
    }
}

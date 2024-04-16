//
//  CoinCapService.swift
//  Cypto-tracker
//
//  Created by Annmarie De Silva on 22/1/2024.
//
import Foundation
import Network
import Combine

class CoinCapService: NSObject, URLSessionTaskDelegate {
    private let session = URLSession(configuration: .default)
    private var websocketTask: URLSessionWebSocketTask?
    private var pingTryCount: Int = 0
    
    let coinDictionarySubject = CurrentValueSubject<[String: Cryptocurrency], Never>([:])
    var coinDictionary: [String: Cryptocurrency] { coinDictionarySubject.value }
    
    let connectionStateSubject = CurrentValueSubject<Bool, Never>(false)
    var isConnected: Bool { connectionStateSubject.value }
    
    private let monitor = NWPathMonitor()
    
    func connect() {
        let url = URL(string: "wss://ws.coincap.io/prices?assets=ALL")!
        websocketTask = session.webSocketTask(with: url)
        websocketTask?.delegate = self
        websocketTask?.resume()
        self.receiveMessage()
        self.schedulePing()
    }
    // TODO: check this
    func startMonitorConnection() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            if path.status == .satisfied, self.websocketTask == nil {
                self.connect()
            }
            if path.status != .satisfied {
                self.clearConnection()
            }
        }
        
        monitor.start(queue: .main)
    }
    
    private func receiveMessage() {
        websocketTask?.receive(completionHandler: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("message received: \(text)")
                    if let data = text.data(using: .utf8) {
                        self.onReceiveData(data)
                    }
                case .data(let data):
                    print("data received: \(data)")
                    self.onReceiveData(data)
                default: break
                }
            case .failure(let error):
                print("Failed to fetch message: \(error.localizedDescription)")
            }
        })
    }
    
    private func onReceiveData(_ data: Data) {
        guard let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String:String] else {
            return
        }
        var newDictionary = [String: Cryptocurrency]()
        dictionary.forEach { (key, value) in
            let value = Double(value) ?? 0
            newDictionary[key] = Cryptocurrency(name: key.capitalized, price: value)
        }
        
        let mergedDictionary = coinDictionary.merging(newDictionary) { $1 }
        coinDictionarySubject.send(mergedDictionary)
    }
    
    private func schedulePing() {
        let identifier = self.websocketTask?.taskIdentifier ?? -1
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self,
                  let task = self.websocketTask,
                  task.taskIdentifier == identifier else { return }
            // also check the pingTryCount because task.state does not get updated immediately
            // if the internet connection is lost, there is a timeout before this is updated
            if task.state == .running, self.pingTryCount < 2 {
                
                self.pingTryCount += 1
                print("Ping Count: \(self.pingTryCount)")
                task.sendPing { error in
                    if let error = error {
                        print("ping failed: \(error.localizedDescription)")
                    } else if self.websocketTask?.taskIdentifier == identifier {
                        self.pingTryCount = 0
                    }
                }
                // Calling here again to schedule ping every 5 seconds to check the condition of the connection
                self.schedulePing()
            } else {
                self.reconnect()
            }
        }
    }
    
    private func reconnect() {
        self.clearConnection()
        self.connect()
    }
    
    func clearConnection() {
        self.websocketTask?.cancel()
        self.websocketTask = nil
        self.pingTryCount = 0
        self.connectionStateSubject.send(false)
    }
    
    deinit {
        coinDictionarySubject.send(completion: .finished)
        connectionStateSubject.send(completion: .finished)
    }
}

extension CoinCapService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.connectionStateSubject.send(true)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.connectionStateSubject.send(false)
    }
}

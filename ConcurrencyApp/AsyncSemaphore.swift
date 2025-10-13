//
//  AsyncSemaphore.swift
//  ConcurrencyApp
//
//  Created by Eslam on 12/10/2025.
//

import Foundation

// MARK: - AsyncSemaphore
actor AsyncSemaphore {
    private var value: Int
    private var waitingContinuations: [CheckedContinuation<Void, Never>] = []
    
    init(value: Int) {
        self.value = value
    }
    
    func wait() async {
        if value > 0 {
            value -= 1
        } else {
            await withCheckedContinuation { continuation in
                waitingContinuations.append(continuation)
            }
        }
    }
    
    func signal() {
        if let continuation = waitingContinuations.first {
            waitingContinuations.removeFirst()
            continuation.resume()
        } else {
            value += 1
        }
    }
}

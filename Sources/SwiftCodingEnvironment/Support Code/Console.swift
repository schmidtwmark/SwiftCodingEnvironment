//
//  Console.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/16/24.
//

import SwiftUI

func timeDisplay(_ start: Date, _ end: Date) -> String{
    
    let interval = end.timeIntervalSince(start)
    if interval < 1 {
        return String(format: "%.0fms", interval * 1000)
    } else {
        return String(format: "%.2fs", interval)
    }
}

public enum RunState : Equatable {
    case idle
    case running
    case success
    case cancel
    case failed(String)
    
    
    var displayString: String {
        switch self {
        case .running: return "Running for "
        case .idle: return "Idle for "
        case .success: return "Success in "
        case .cancel: return "Canceled in "
        case .failed(let message): return message
        }
    }
    
    var color: Color {
        switch self {
        case .running, .idle: return .gray
        case .success: return .green
        case .failed: return .red
        case .cancel: return .yellow
       }
    }
    
    var icon: String {
        switch self {
        case .running, .idle: return "circle"
        case .success: return "checkmark.circle.fill"
        case .failed, .cancel: return "xmark.circle.fill"
        }
    }
    
    var isFailure: Bool {
        switch self {
        case .failed(_): return true
        default:  return false
        }
    }
}

@MainActor
public protocol Console : ObservableObject {
    
    init(colorScheme: ColorScheme, mainFunction: @escaping MainFunction<Self>)
    
    func tick()
    
    var state: RunState { get }
    
    var durationString: String { get }
    
    func start()
    
    func stop()
    
    func clear()
    
    var disableClear: Bool { get }
    
    var title: String { get }
}

struct ConsoleError: Error {
    var message: String
}

public typealias MainFunction<C: Console> = @Sendable (_ console: C) -> Void

@MainActor
public class BaseConsole<C: Console> {
    
    
    @Published public var state: RunState = .idle
    @Published var startTime : Date? = nil
    @Published var endTime : Date? = nil
    @Published var timeString = ""
    @Published var task: Task<Void, Never>? = nil
    
    public var mainFunction: MainFunction<C>
    
    public init(colorScheme: ColorScheme, mainFunction: @escaping MainFunction<C>) {
        self.mainFunction = mainFunction
    }
    
    
    public var durationString: String {
        if let startTime = startTime,
           let endTime = endTime {
            return timeDisplay(startTime, endTime)
        }
        return timeString
    }
    
    public func tick() {
        if let start = startTime {
            timeString = timeDisplay(start, Date())
        }
    }
    
    public func finish(_ newState: RunState) {
        state = newState
        task = nil
        endTime = Date()

    }
    
    public func stop() {
        task?.cancel()
        finish(.cancel)
    }
    
    public func clear() {
        startTime = nil
        endTime = nil
        state = .idle
    }
    
    public func start() {
        state = .running
        startTime = Date()
        self.task = Task.detached {
            await self.mainFunction(self as! C)
            self.sync({
                withAnimation {
                    self.finish(.success)
                }
            })
        }
    }
    
    final class UnsafeStorage<T>: @unchecked Sendable {
        private var value: T?
        
        func set(_ newValue: T) {
            value = newValue
        }
        
        func get() -> T? {
            value
        }
    }

    internal nonisolated func sync<T: Sendable>(_ asyncCall: @MainActor @escaping () async -> T) -> T {
        let semaphore = DispatchSemaphore(value: 0)
        let storage = UnsafeStorage<T>()
        
        DispatchQueue.main.async {
            Task {
                let value = await asyncCall()
                storage.set(value)
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        return storage.get()!
    }
}

public protocol ConsoleView: View {
    associatedtype ConsoleType : Console
    init(console: ConsoleType)
}

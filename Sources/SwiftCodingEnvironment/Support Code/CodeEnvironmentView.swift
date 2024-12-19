//
//  CodeEnvironmentView.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/14/24.
//

import SwiftUI
import Combine


let CORNER_RADIUS = 8.0

public struct CodeEnvironmentView<CV: ConsoleView>: View {
    public init(mainFunction: @escaping MainFunction<CV.ConsoleType>) {
        self.mainFunction = mainFunction
    }
    
    
    @Environment(\.colorScheme) var colorScheme
    var mainFunction: MainFunction<CV.ConsoleType>
    public var body: some View {
        InnerCodeEnvironmentView<CV>(colorScheme: colorScheme, mainFunction: mainFunction)
    }
}
struct InnerCodeEnvironmentView<CV: ConsoleView>: View {
    
    @StateObject var console: CV.ConsoleType
    init(colorScheme: ColorScheme, mainFunction: @escaping MainFunction<CV.ConsoleType>) {
        let c = CV.ConsoleType(colorScheme: colorScheme, mainFunction: mainFunction)
        _console = StateObject(wrappedValue: c)
    }
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(console.title)
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(.rect(topLeadingRadius: CORNER_RADIUS, topTrailingRadius: CORNER_RADIUS))
                Spacer()
                if console.state != .idle {
                    HStack {
                        if console.state == .running {
                            ProgressView()
                        } else {
                            Image(systemName: console.state.icon)
                        }
                        Text("\(console.state.displayString)\(!console.state.isFailure ?  console.durationString : "")")
                    }
                    .padding(5)
                    .background(console.state.color)
                    .clipShape(.rect(cornerRadius: CORNER_RADIUS))
                }
            }
            CV(console: console)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(.rect(bottomLeadingRadius: CORNER_RADIUS, bottomTrailingRadius: CORNER_RADIUS, topTrailingRadius: CORNER_RADIUS))
            Spacer(minLength: CORNER_RADIUS)
            HStack {
                Button {
                    if console.state == .running {
                        withAnimation {
                            console.stop()
                        }
                    } else {
                        withAnimation {
                            console.clear()
                            console.start()
                        }
                    }
                } label: {
                    Label(console.state == .running ? "Stop" : "Run", systemImage: console.state == .running ? "stop.circle" : "play")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .fontWeight(.heavy)
                }
                .tint(console.state == .running ? .red : .blue)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                
                if console.state != .running {
                    Button(role: .destructive) {
                        withAnimation {
                            console.clear()
                        }
                    } label: {
                        Label("Clear", systemImage: "trash")
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .fontWeight(.heavy)
                    }
                    .disabled(console.disableClear)
                    .frame(maxWidth: .infinity)
                }
            }
            
        }
        .onReceive(timer) { _ in
            console.tick()
        }
        .font(.system(.body, design: .monospaced))
        .padding()
    }
}

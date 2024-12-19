//
//  TextConsoleView.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/16/24.
//

import SwiftUI
import Combine

public struct TextConsoleView: ConsoleView {
    public init(console: TextConsole) {
        self.console = console
    }
    
    
    @ObservedObject var console: TextConsole
    @FocusState private var isTextFieldFocused: Bool

    public var body: some View {
        ScrollView {
            HStack {
                LazyVStack (alignment: .leading) {
                    ForEach(console.lines) { line in
                        VStack {
                            switch line.content {
                            case .output(let text):
                                Text(text)
                                    .frame(width: .infinity, height: 30.0)
                            case .input:
                                TextField("", text: $console.userInput)
                                    .onSubmit {
                                        console.submitInput(true)
                                    }
                                    .frame(height: 30.0)
                                    .focused($isTextFieldFocused)
                            }
                        }.border(.red)
                    }
                }
                Spacer()
            }
            .padding()
        }
        .defaultScrollAnchor(.bottom)
        .scrollIndicators(.visible)
        .task {
            console.setFocus = { focus in
                isTextFieldFocused = focus
            }
        }
    }
    
}

func textMain(console: TextConsole) async throws {
    let name = try await console.read("What is your name?")
    try await console.write("Hello \(name)")
}


#Preview {
    CodeEnvironmentView<TextConsoleView>(mainFunction: textMain)
}

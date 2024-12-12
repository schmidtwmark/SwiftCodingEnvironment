//
//  TextConsoleView.swift
//  StudentCodeTemplate
//
//  Created by Mark Schmidt on 11/16/24.
//

import SwiftUI
import Combine

public struct TextConsoleView: ConsoleView {
    public init(console: any Console) {
        self.console = console as! TextConsole
    }
    
    
    @ObservedObject var console: TextConsole
    @FocusState private var isTextFieldFocused: Bool

    public var body: some View {
        ScrollView {
            HStack {
                LazyVStack (alignment: .leading) {
                    ForEach(console.lines) { line in
                        switch line.content {
                        case .output(let text):
                            Text(text)
                                .frame(width: .infinity)
                        case .input:
                            TextField("", text: $console.userInput)
                                .onSubmit {
                                    console.submitInput(true)
                                }
                                .focused($isTextFieldFocused)
                        }
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

func main(console: TextConsole) async throws {
    
    let input = try await console.read("Enter a number")
    let num = Int(input) ?? 0
    for i in 0...num {
        
        try await console.write("\(i) iteration")
    }
}


#Preview {
    CodeEnvironmentView<TextConsole, TextConsoleView>(mainFunction: main)
}

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
                            case .input:
                                TextField("", text: $console.userInput)
                                    .onSubmit {
                                        console.submitInput(true)
                                    }
                                    .focused($isTextFieldFocused)
                            }
                        }.frame(width: .infinity, height: 25.0)
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

func textMain(console: TextConsole) {
    console.write("Hello World! 🦀")
//    let num = Int(console.read("Enter a number? 🦀"))!
//    for i in 0...num {
//        console.write("Num: \(i)")
//    }
}


#Preview {
    CodeEnvironmentView<TextConsoleView>(mainFunction: textMain)
}

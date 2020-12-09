//
//  File.swift
//  
//
//  Created by Mathias Quintero on 12/9/20.
//

import Foundation
import TokamakDOM

struct CustomTextField: View {
    let placeholder: String

    @Binding
    var text: String

    let onCommit: () -> Void

    @Environment(\.colorScheme)
    var colorScheme

    var css: String {
        return """
        background: transparent;
        border: none;
        outline: none;
        font-size: 40px;
        color: \(colorScheme == .light ? "black" : "white")
        """
    }

    var body: some View {
        DynamicHTML("input", [
            "type": "text",
            "value": text,
            "placeholder": placeholder,
            "style": css,
            "autofocus": ""
        ], listeners: [
            "keypress": { event in if event.key == "Enter" { onCommit() } },
            "input": { event in
                if let newValue = event.target.object?.value.string {
                    text = newValue
                }
            },
        ])
    }
}

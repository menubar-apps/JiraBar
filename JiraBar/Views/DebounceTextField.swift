//
//  DebounceTextField.swift
//  jiraBar
//
//  Created by Pavel Makhov on 2024-09-30.
//

import SwiftUI
import Combine

struct DebounceTextField: View {
    
    @State var publisher = PassthroughSubject<String, Never>()
    
    @State var label: String
    @Binding var value: String
    var valueChanged: ((_ value: String) -> Void)?
    
    @State var debounceSeconds = 0.5
    
    var body: some View {
        TextField(label, text: $value)
            .disableAutocorrection(true)
            .textFieldStyle(.roundedBorder)
            .onChange(of: value) { value in
                publisher.send(value)
            }
            .onReceive(
                publisher.debounce(
                    for: .seconds(debounceSeconds),
                    scheduler: DispatchQueue.main
                )
            ) { value in
                if let valueChanged = valueChanged {
                    valueChanged(value)
                }
            }
    }
}

//#Preview {
//    DebounceTextField()
//}

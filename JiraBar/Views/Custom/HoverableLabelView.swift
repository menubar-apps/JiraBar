//
//  HoverableLabelView.swift
//  jiraBar
//
//  Created by Pavel Makhov on 2023-09-23.
//

import SwiftUI

struct HoverableLabelView: View {
    
    let iconName: String
    @State private var isHovering = false

    var body: some View {
        Label("Settings", systemImage: iconName)
            .labelStyle(.iconOnly)
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous).fill(.secondary.opacity(isHovering ? 0.2 : 0))
            )
            .onHover { over in isHovering = over }
    }
}

struct HoverableButtonView_Previews: PreviewProvider {
    static var previews: some View {
        HoverableLabelView(iconName: "gearshape")
    }
}


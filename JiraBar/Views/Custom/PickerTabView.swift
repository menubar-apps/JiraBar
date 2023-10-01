//
//  PickerTabView.swift
//  jiraBar
//
//  Created by Pavel Makhov on 2023-09-21.
//

import SwiftUI
import Defaults

struct PickerTabView: View {
    var tabType: TabType
    @StateObject var viewModel: ViewModel
    @Default(.nameTab1) var nameTab1
    @Default(.nameTab2) var nameTab2
    @Default(.nameTab3) var nameTab3

    var body: some View {
        HStack(spacing: 4) {
            HStack {
//                if shouldShowCircle && !isLoaded {
//                    Circle()
//                        .fill(.blue)
//                        .frame(width: 8, height: 8)
//                } else
                if isLoaded {
                    ProgressView()
                        .scaleEffect(0.5, anchor: .center)
                }
            }.frame(width: 20)
            
            Text(tabName)
                .font(Font.footnote.weight(.medium))
                .padding(.vertical, 8)
                .multilineTextAlignment(.center)
                .contentShape(Rectangle())
//                .frame(width: 60)
            
//            Text(String("pullCount"))
//                .font(.subheadline)
//                .padding(2)
//                .foregroundColor(.primary)
//                .background(
//                    Capsule()
//                        .fill(Color(nsColor: NSColor.controlColor))
//                )
        }
    }
    
    private var tabName: String {
        switch tabType {
        case .first:
            return nameTab1
        case .second:
            return nameTab2
        case .third:
            return nameTab3
        }
    }
    
//    private var shouldShowCircle: Bool {
//        switch pullType {
//        case .assigned:
//            return viewModel.hasChangesInAssignedPulls
//        case .created:
//            return viewModel.hasChangesInCreatedPulls
//        case .reviewRequested:
//            return viewModel.hasChangesInReviewRequestedPulls
//        }
//    }
//
//    private var pullCount: Int {
//        switch pullType {
//        case .assigned:
//            return viewModel.assignedPulls.count
//        case .created:
//            return viewModel.createdPulls.count
//        case .reviewRequested:
//            return viewModel.reviewRequestedPulls.count
//        }
//    }
//
    private var isLoaded: Bool {
        switch tabType {
        case .first:
            return viewModel.tab1Loading
        case .second:
            return viewModel.tab2Loading
        case .third:
            return viewModel.tab3Loading
        }
    }
}

//struct PickerTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabView(pullType: .assigned, viewModel: ViewModel())
//    }
//}

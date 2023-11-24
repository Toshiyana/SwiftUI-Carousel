//
//  SingleColumnCarousel.swift
//  CarouselSample
//
//  Created by 柳元 俊輝 on 2023/11/19.
//

import SwiftUI

public struct SingleRowCarousel<Content: View, T: Identifiable>: View {
    private let content: (T) -> Content
    private let items: [T]
    private let horizontalSpacing: CGFloat
    private let trailingSpacing: CGFloat

    @Binding private var index: Int
    @GestureState private var dragOffset: CGFloat = 0

    public var body: some View {
        GeometryReader { proxy in
            let pageWidth = (proxy.size.width - (trailingSpacing + horizontalSpacing))
            let currentOffset = dragOffset - (CGFloat(index) * pageWidth)
            
            LazyHStack(alignment: .top, spacing: 0) {
                ForEach(items) { item in
                    content(item)
                        .frame(width: pageWidth, alignment: .leading)
                }
            }
            .padding(.horizontal, horizontalSpacing)
            .offset(x: currentOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if (index == 0 && value.translation.width > 0) || (index == items.count - 1 && value.translation.width < 0) {
                            state = value.translation.width / 4
                        } else {
                            state = value.translation.width
                        }
                    }
                    .onEnded { value in
                        let dragThreshold = pageWidth / 20
                        if value.translation.width > dragThreshold {
                            index -= 1
                        }
                        if value.translation.width < -dragThreshold {
                            index += 1
                        }
                        index = max(min(index, items.count - 1), 0)
                    }
            )
            .animation(.default, value: dragOffset == 0)
        }
    }

    public init(items: [T], horizontalSpacing: CGFloat, trailingSpacing: CGFloat, index: Binding<Int>, content: @escaping (T) -> Content) {
        self.content = content
        self.items = items
        self.horizontalSpacing = horizontalSpacing
        self.trailingSpacing = trailingSpacing
        self._index = index
    }
}

//struct CarouselItem: Identifiable {
//    let id = UUID()  // Unique identifier
//    let value: Int
//}

// In the preview
//struct SingleColumnCarousel_Previews: PreviewProvider {
//    @State var currentIndex = 0
//    static var items = [CarouselItem(value: 1), CarouselItem(value: 2), CarouselItem(value: 3), CarouselItem(value: 4), CarouselItem(value: 5)]
//    
//    static var previews: some View {
//        SingleColumnCarousel(items: items, horizontalSpacing: 10, trailingSpacing: 50, index: .constant(0)) { item in
//            Text("\(item.value)")
//                .frame(width: 320, height: 80)
//                .background(Color.blue)
//        }
//        .frame(height: 200)
//    }
//}

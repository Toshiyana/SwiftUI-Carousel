//
//  MultiColumnCarousel.swift
//  CarouselSample
//
//  Created by 柳元 俊輝 on 2023/11/20.
//

import SwiftUI
import Combine

public enum AutoScrollStatus {
    case inactive
    case active(TimeInterval)
}

public struct MultiRowsCarousel<Content: View, T: Identifiable>: View {
    private let content: (T) -> Content
    private let items: [T]
    private let groupSize: Int
    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat
    private let trailingSpacing: CGFloat
    private let autoScroll: AutoScrollStatus
    
    private var chunkedItems: [[T]]
    private var timer: Timer.TimerPublisher? {
        switch autoScroll {
        case .active(let timeInterval):
            return Timer.publish(every: timeInterval, on: .main, in: .common)
        case .inactive:
            return nil
        }
    }

    @Binding private var index: Int
    @GestureState private var dragOffset: CGFloat = 0
    
    @State private var isTimerActive = true
    @State private var cancellable: AnyCancellable?

    public var body: some View {
        GeometryReader { proxy in
            let pageWidth = (proxy.size.width - (trailingSpacing + horizontalSpacing))
            let currentOffset = dragOffset - (CGFloat(index) * pageWidth)
            
            LazyHStack(alignment: .top, spacing: 0) {
                ForEach(chunkedItems.indices, id: \.self) { index in
                    LazyVStack(alignment: .leading, spacing: verticalSpacing) {
                        ForEach(chunkedItems[index]) { item in
                            content(item)
                        }
                    }
                    .frame(width: pageWidth)
                }
            }
            .padding(.horizontal, horizontalSpacing)
            .offset(x: currentOffset)
            .gesture(
                DragGesture()
                    .onChanged { _ in
                        isTimerActive = false
                    }
                    .updating($dragOffset) { value, state, _ in
                        if (index == 0 && value.translation.width > 0) || (index == chunkedItems.count - 1 && value.translation.width < 0) {
                            state = value.translation.width / 4
                        } else {
                            state = value.translation.width
                        }
                    }
                    .onEnded { value in
                        isTimerActive = true
                        let dragThreshold = pageWidth / 20
                        if value.translation.width > dragThreshold {
                            index -= 1
                        }
                        if value.translation.width < -dragThreshold {
                            index += 1
                        }
                        index = max(min(index, chunkedItems.count - 1), 0)
                    }
            )
            .animation(.default, value: dragOffset == 0)
            .onAppear {
                cancellable = timer?
                    .autoconnect()
                    .sink { _ in

                        guard isTimerActive else {
                            return
                        }

                        withAnimation {
                            if self.index >= chunkedItems.count - 1 {
                                self.index = 0
                            } else {
                                self.index += 1
                            }
                        }
                    }
            }
            .onDisappear {
                cancellable?.cancel()
                cancellable = nil
            }
        }
    }

    public init(items: [T], groupSize: Int, horizontalSpacing: CGFloat, verticalSpacing: CGFloat, trailingSpacing: CGFloat, autoScroll: AutoScrollStatus, index: Binding<Int>, content: @escaping (T) -> Content) {
        self.content = content
        self.items = items
        self.groupSize = groupSize
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.trailingSpacing = trailingSpacing
        self.autoScroll = autoScroll
        self._index = index
        
        self.chunkedItems = stride(from: 0, to: items.count, by: groupSize).map {
            Array(items[$0 ..< min($0 + groupSize, items.count)])
        }
    }
}

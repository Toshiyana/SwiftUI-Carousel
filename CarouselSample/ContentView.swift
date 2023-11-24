//
//  ContentView.swift
//  CarouselSample
//
//  Created by 柳元 俊輝 on 2023/11/19.
//

import SwiftUI

private struct CarouselItem: Identifiable {
    let id = UUID()
    let value: Int
}

private struct SingleRowCarouselView: View {
    @State var currentIndex = 0
    let items = [CarouselItem(value: 1), CarouselItem(value: 2), CarouselItem(value: 3)]
    
    var body: some View {
        SingleRowCarousel(
            items: items,
            horizontalSpacing: 20,
            trailingSpacing: 40,
            index: $currentIndex)
        { item in
            Text("\(item.value)")
                .frame(width: 300, height: 80)
                .background(Color.blue)
        }
        .frame(height: 80)
    }
}


private struct MultiRowsCarouselView: View {
    @State var currentIndex = 0
    let items = [
        CarouselItem(value: 1), CarouselItem(value: 2), CarouselItem(value: 3),
        CarouselItem(value: 4), CarouselItem(value: 5), CarouselItem(value: 6),
        CarouselItem(value: 7), CarouselItem(value: 8), CarouselItem(value: 9),
    ]
    
    let groupSize = 3
    
    var body: some View {
            MultiRowsCarousel(
                items: items,
                groupSize: 3,
                horizontalSpacing: 20,
                verticalSpacing: 20,
                trailingSpacing: 10,
                autoScroll: .inactive,
                index: $currentIndex)
            { item in
                Text("\(item.value)")
                    .frame(width: 300, height: 80)
                    .background(Color.blue)
            }
            .frame(height: 280)
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            NavigationLink {
                SingleRowCarouselView()
            } label: {
                Text("Single Row Carousel")
            }
            
            
            NavigationLink {
                MultiRowsCarouselView()
            } label: {
                Text("Multi Rows Carousel")
            }
        }
    }
}

#Preview {
    ContentView()
}

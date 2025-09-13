//
//  WordView.swift
//  Musubi
//
//  Created by Royston Martha on 9/13/25.
//

import SwiftUI

struct WordView: View {
    let word: Words
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .top, spacing: 24) {
                        // Left section: meaning, JLPT, strength
                        VStack(alignment: .center, spacing: 12) {
                            Text(word.meaning)
                                .font(.largeTitle)
                                .bold()
                           
                                Text("JLPT: \(word.jlptLevel)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Strength: 5")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            
                        }
                        .padding()
                        Spacer()
                        // Right section: kanji and readings
                        WordRenderer(word: word)
                    }
                    // ... add more sections if needed
                }
            }
        }
    }
}

struct WordRenderer: View {
    let word: Words
    var body: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible(minimum: CGFloat(12), maximum: CGFloat(16)))]
        if word.specialReading {
            LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
                ForEach(Array(word.literal), id: \.self) { k in
                    Text(String(k))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                Text(word.reading)
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .padding()
        } else {
            // Show a grid of kanji with their readings below
            LazyVGrid(columns: columns, alignment: .center) {
                ForEach(Array(zip(Array(word.literal), word.renderedReading)), id: \.0) { pair in
                    
                        Text(String(pair.0))
                        .font(.system(size: 64, design: .default))
                        .dynamicTypeSize(.large ... .accessibility5)
                        Text(pair.1)
                            .font(.body)
                            .foregroundColor(.blue)
                    
                }
            }
            .padding()
        }
    }
}




#Preview {
    let word = Words(word: "食べる", readings: ["た","べ","る"], meaning: "to eat")
    WordView(word: word)
}

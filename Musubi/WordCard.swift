//
//  WordCard.swift
//  Musubi
//
//  Created by Royston Martha on 12/11/22.
//

import SwiftUI
import UIKit


fileprivate func noac() {}
fileprivate var noAction = noac

var thought = Word(key: "結び", yomi: ["むす","び"], meaning: "connect")


struct WordCard: View {
    
    // Word Information
    @State var word: Word
    @State var key: String
    @State var yomi: Array<String>
    @State var meaning: String
    @State private var edit = false
    
    // Body for the static word card
    var body: some View {
        VStack {
            ForEach(0..<Array(key).count, id: \.self) { i in  // Create a HStack to pair the character to its reading.
                HStack {
                    // The Character
                    Button(String(Array(key)[i]), action: {edit.toggle()})
                        .bold()
                        .font(.system(size: 128))
                        .foregroundColor(.primary)
                    // The respective reading
                    Button(yomi[i], action: {edit.toggle()})
                        .font(.system(size: 32))
                        .frame(width: 32)
                        .foregroundColor(.primary)
                }
            }
            Button(meaning, action: {edit.toggle()})
                .bold()
                .font(.system(size: 32))
                .foregroundColor(.primary)
        }.sheet(isPresented: $edit) {
            EditWordCard(editing: $word, key: $key, yomi: $yomi, meaning: $meaning)
        }.onChange(of: self.key) { newValue in
            word.key = newValue
        }.onChange(of: self.yomi){ newValue in
            word.yomi = newValue
        }.onChange(of: self.meaning){ newValue in
            word.meaning = newValue
        }
    }
    
}

struct EditWordCard: View {
    @FocusState private var bindingKey: Bool
    @State var dummy = ""
    @Binding var editing: Word
    @Binding var key: String
    @Binding var yomi: Array<String>
    @Binding var meaning: String
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                // Kanji View!
                TextField("", text: $key, axis: .vertical)
                    .bold()
                    .font(.system(size: 128))
                    .frame(width: 128)
                    .foregroundColor(.primary)
                    .focused($bindingKey)
                VStack{
                    bindingKey ?
                    ForEach(0..<1) { _ in
                        TextField("", text: $dummy, axis: .vertical)
                    } : ForEach(0..<Array(key).count, id: \.self) { i in
                            TextField("k", text: $yomi[i], axis: .vertical)
                    }
                }.font(.system(size: 32))
                    .frame(width: 32)
                    .frame(minHeight: 32)
            }
            TextField("", text: $meaning)
        }
    }
}


struct WordCard_Previews: PreviewProvider {
    static var previews: some View {
        WordCard(word: thought, key: thought.key, yomi: thought.yomi, meaning: thought.meaning)
    }
}

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
    @FocusState var editing: Bool
    
    @State var word: Word
    @State var key: String
    @State var dummy = ""
    @State var yomi: Array<String>
    @State var meaning: String
    @State private var edit = false
    
    // Body for the static word card
    var body: some View {
        ZStack{
            VStack {
                Spacer()
                // Create a HStack to pair the character to its reading.
                HStack {
                    // The Character
                    TextField("漢字", text: $key, axis: .vertical)
                        .bold()
                        .font(.system(size: 128))
                        .frame(maxWidth: 128, minHeight: 320, maxHeight: 780)
                        .foregroundColor(.primary)
                        .lineLimit(2...7).focused($editing)
                    
                    // The respective reading
                    VStack{
                        ForEach(0..<Array(key).count, id: \.self) { i in
                            Spacer()
                            TextField("〇", text: i < yomi.count ? $yomi[i] : $dummy, axis: .vertical)
                                .font(.system(size: 32))
                                .frame(maxWidth: 32, minHeight: 144)
                                .foregroundColor(.primary)
                                .lineLimit(5)
                                .focused($editing)
                                .backgroundStyle(.gray)
                        }
                        Spacer()
                    }
                }
                .frame(maxHeight: (CGFloat(key.count)+0.5)*128)
                .padding(.bottom, 32)
                TextField("意味", text: $meaning)
                    .bold()
                    .font(.system(size: 32))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }.onChange(of: self.key) { newValue in
                word.key = newValue
                word.yomi = ["","","","","","","","",""]
                yomi = word.yomi
                print("Key change!")
            }.onChange(of: self.yomi){ newValue in
                word.yomi = newValue
            }.onChange(of: self.meaning){ newValue in
                word.meaning = newValue
            }.onChange(of: self.dummy) { _ in
                // This is unique in indicating that the yomikata has become too long. Reset yomikata.
                word.yomi = ["","","","","","","","",""]
                yomi = word.yomi
                NSLog("Reset yomikata")
            }
        }.gesture(DragGesture(minimumDistance: 50).onEnded { gesture in
            if gesture.startLocation.y < gesture.location.y {
                let resign = #selector(UIResponder.resignFirstResponder)
                UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                
            }
        })
    }
    
}


struct WordCard_Previews: PreviewProvider {
    static var previews: some View {
        WordCard(word: thought, key: thought.key, yomi: thought.yomi, meaning: thought.meaning)
    }
}

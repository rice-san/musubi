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

var thought = Word(key: "巡回監督者よ", yomi: ["じゅん","かい", "かん", "とく", "しゃ", ""], meaning: "connect")


struct WordCard: View {
    
    // Word Information
    @FocusState var editing: Bool
    @State var dummy = ""
    @State var dummyArray = [""]
    @State var word: Word
    @State var key: String
    @State var yomi: Array<String>
    @State var meaning: String
    @State private var edit = false
    
    // Body for the static word card
    var body: some View {
        ZStack{
            VStack(alignment: .center) {
                Spacer()
                // Create a HStack to pair the character to its reading.
                HStack {
                    // The Character
                    KanjiView(key: $key, keyChanging: _editing)
                    // The respective reading, only render yomi when not editing and when not all hiragana
                    (editing || key.isHiragana ? YomiView(key: $dummy, yomi: $dummyArray) :
                    YomiView(key: $key, yomi: $yomi))
                        .padding(.top, 32)
                
                }
                MeaningView(meaning: $meaning)
                Spacer()
            }
            .onChange(of: self.key) { newValue in
                word.key = newValue
                word.yomi = ["","","","","","","","",""]
                yomi = word.yomi
                print("Key change!　\(word.key)")
            }.onChange(of: self.yomi){ newValue in
                word.yomi = newValue
                print("\(word.yomi)")
                print("\(word.yomikata)")
            }.onChange(of: self.meaning){ newValue in
                word.meaning = newValue
            }
        }.gesture(DragGesture(minimumDistance: 50).onEnded { gesture in
            if gesture.startLocation.y < gesture.location.y {
                let resign = #selector(UIResponder.resignFirstResponder)
                UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
                
            }
        })
    }
}

struct KanjiView: View {
    @Binding var key: String
    @FocusState var keyChanging: Bool
    var body : some View {
        // The Character
        VStack{
            Spacer()
            TextField("漢字", text: $key, axis: .vertical)
                .bold()
                .font(.system(size: 96))
                .padding(.leading)
                .frame(maxWidth: 128)
                .foregroundColor(.primary)
                .lineLimit(1...6)
                .focused($keyChanging)
            Spacer()
        }
    }
}

struct YomiView: View {
    @Binding var key: String
    @Binding var yomi: Array<String>
    @State var dummy = ""
    
    var body : some View {
        // The Character
        VStack(alignment: .center){
            ForEach(0..<Array(key).count, id: \.self) { i in
                TextField(
                    String(Array(key)[i]).isHiragana ? " " : "〇",
                    text: i < yomi.count ? $yomi[i] : $dummy,
                    axis: .vertical)
                    .font(.system(size: 24))
                    .frame(maxWidth: 32, minHeight: 96)
                    .padding(.bottom, 8)
                    .foregroundColor(.primary)
                    .lineLimit(5)
                    .backgroundStyle(.gray)
                    .disabled(String(Array(key)[i]).isHiragana)
                    
            }
        }.frame(maxHeight: .infinity)
            .padding(.bottom, 32)
    }
}

struct MeaningView : View {
    @Binding var meaning: String
    
    var body: some View {
        TextField("意味", text: $meaning)
            .bold()
            .font(.system(size: 32))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
    }
}

struct WordCard_Previews: PreviewProvider {
    static var previews: some View {
        WordCard(word: thought, key: thought.key, yomi: thought.yomi, meaning: thought.meaning)
    }
}

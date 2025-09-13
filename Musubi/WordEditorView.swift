//
//  WordEditorView.swift
//  Musubi
//
//  Created by Royston Martha on 3/14/23.
//

import SwiftUI

var idea = Word(key: "巡回監督者", yomi: ["じゅん","かい", "かん", "とく", "しゃ", ""], meaning: "circuit overseer")

struct WordEditorView: View {
    @State var meaning: String
    var body: some View {
        ZStack {
            VStack {
                HStack(alignment: .top){
                    VStack{
                        ForEach(0..<idea.kanji.count){ c in
                            KanjiCharView(char: idea.kanji[c]).appendYomikata(yomi: idea.yomi[c], draw: true)
                        }
                        
                    }.padding(.leading, 32)
                    Spacer()
                }.padding(.top, 16)
                Text(idea.meaning).padding()
                Spacer()
            }
        }
    }
    
}

struct KanjiCharView: View {
    var char: Character
    var body: some View {
        Button(String(char)){
            
        }
            .buttonStyle(.plain)
            .bold()
            .font(.system(size: 64))
    }
}

struct KanjiEditView: View {
    @Binding var key: String
    @FocusState var keyChanging: Bool
    var body: some View {
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

struct YomiKata: View {
    var yomi: String
    var body: some View {
        Button(String(yomi)){
            print("Reading tapped")
        }
            .offset(x:48)
            .frame(width: 16)
            .font(.system(size: 16))
            .buttonStyle(.plain)
    }
}

struct WordEditorView_Previews: PreviewProvider {
    static var previews: some View {
        WordEditorView(meaning: idea.meaning)
    }
}

extension KanjiCharView {
    func appendYomikata(yomi: String, draw: Bool) -> some View {
        ZStack {
            self
            
            if draw {
                YomiKata(yomi: yomi)
            }
        }
    }
}

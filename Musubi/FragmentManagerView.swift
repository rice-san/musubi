//
//  FragmentManagerView.swift
//  Musubi
//
//  Created by Royston Martha on 10/6/23.
//

import SwiftUI

// Create a collection of fragments.
var fragmentCollection = FragmentManager()


struct FragmentManagerView: View {
    var body: some View {
        VStack(alignment: .center) {
            PendingReviewView()
            NewFragmentControlsView()
            FragmentCollectionView()
        Spacer()
        }
        
        
    }
}

#Preview {
    FragmentManagerView()
}

struct PendingReviewView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack{
                Text("\(fragmentCollection.pendingFragments)")
                    .font(.custom("system", size: 96))
                    .foregroundStyle((fragmentCollection.pendingFragments > 0 ? Color(.black): Color(.gray)))
                Text("Pending")
            }
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            Spacer()
            
            VStack{
                Text("\(fragmentCollection.agedFragments)")
                    .font(.custom("system", size: 96))
                    .foregroundStyle((fragmentCollection.pendingFragments > 0 ? Color(.red): Color(.gray)))
                Text("Overdue")
            }
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            Spacer()
        }
        .padding(.top)
    }
}

struct NewFragmentControlsView: View {
    var body: some View {
        HStack{
            Spacer()
            AddKanjiFragmentButton()
            Spacer()
            AddHatsuonFragmentButton()
            Spacer()
            AddAudioFragmentButton()
            Spacer()
            AddImageFragmentButton()
            Spacer()
        }
        .padding(.top)
    }
}

// The currently edited fragment
struct EditingFragmentView: View {
    @Binding var key: String
    var body: some View {
        TextField("", text: $key)
    }
}

// Fragment Views

struct HatsuonFragmentView: View {
    var hatsuon: HatsuonFragment
    var body: some View {
        HStack {
            Text(hatsuon.hatsuon)
        }
    }
}

struct KanjiFragmentView: View {
    var kanji: KanjiFragment
    var body: some View {
        HStack {
            Text(kanji.kanji)
        }
    }
}

struct FragmentCollectionView: View {
    var body: some View {
        List {
            
        }
    }
}

struct AddImageFragmentButton: View {
    var body: some View {
        Button(action: {}, label: {
            Image(systemName: "camera.fill").padding(.all)
        }).font(.custom("system", fixedSize: 32)).foregroundStyle(Color(.white))
            .background(.red)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
    }
}

struct AddAudioFragmentButton: View {
    var body: some View {
        Button(action: {fragmentCollection.add(withHatuson: "しらない")}, label: {
            Image(systemName: "mic.fill").padding(.all)
        }).font(.custom("system", fixedSize: 32)).foregroundStyle(Color(.white))
            .background(.red)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
    }
}

struct AddKanjiFragmentButton: View {
    var body: some View {
        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
            Text("字").padding(.all)
        }).font(.custom("system", fixedSize: 32)).foregroundStyle(Color(.white))
            .background(.blue)
            .clipShape(Circle())
    }
}

struct AddHatsuonFragmentButton: View {
    var body: some View {
        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
            Text("あ").padding(.all)
        }).font(.custom("system", fixedSize: 32)).foregroundStyle(Color(.white))
            .background(.blue)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            
    }
}

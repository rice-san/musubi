//
//  FragmentManager.swift
//  Musubi
//
//  Created by Royston Martha on 10/6/23.
//

import Foundation

fileprivate let MaximumFragments = 100  // TODO: Allow these settings to be modified.
fileprivate let MaximumFragmentsPerDay = 10

class FragmentManager {
    
    var fragments = Array<Fragment>()
    
    var pendingFragments: Int {
        return fragments.count
    }
    
    var agedFragments: Int {
        var count = 0
        for fragment in fragments {
            if fragment.date.timeIntervalSinceNow > 604800 { // If older than a week
                count += 1
            }
        }
        return count
    }
    
    func add(withHatuson: String) {
        if fragments.count < MaximumFragments {
            fragments.append(HatsuonFragment(hatsuon: withHatuson))
        }
    }
    func add(withKanji: String) {
        if fragments.count < MaximumFragments {
            fragments.append(KanjiFragment(kanji: withKanji))
        }
    }
    //TODO: Add support for pictures and audio
}

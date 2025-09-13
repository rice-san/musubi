//
//  SRS.swift
//  Musubi
//
//  Created by Royston Martha on 9/12/25.
//

// TODO: Adjust formula if preferences dictate they care about pitch accent

import Foundation

extension Kanji {
    var completeness: Double {
        return 0.0
    }
    var reviewWeight: Double {
        return 0.0
    }
    
    func review(ease: reviewEase) {
        if ease != .forgotten {
            
        }
    }
}

extension Words {
    var completeness: Int {
        if self.meaning == "" || self.readings.contains("") {
            return 0 // Auto nerf if no meaning is included or reading isn't complete
        }
        var comp = 1 // If the basics are in - start at 1
        if self.examples.count > 0 {
            comp += max(self.examples.count, 3) // Up to 3 points for examples
        }
        if self.pitchCategory != .unknown && UserPreferences.shared.weightWordsOnPitch {
            comp += 2 // Wow bonus for just recording the pitch accent
        }
        
        return comp % 10 // Just ensure it's never over 10, even if it is.
    }
    var reviewWeight: Double {
        return 0.0
    }
    var nextReviewDate: Date? {
        return nil
    }
    func review(ease: reviewEase) {
        if ease != .forgotten {
            self.correctCount += 1
        }
    }
}


enum reviewEase: Double {
    case easy = 1.0
    case neutral = 2.0
    case difficult = 3.5
    case forgotten = 10.0
}

//
//  PlayerManager.swift
//  MP3 Player
//
//  Created by ILYA Paraskevich on 11.09.22.
//

import Foundation
import AVFoundation

class PlayerManager {
    
    static var shared = PlayerManager()
    
    var player = AVPlayer()
    
    func play(file: String) {
        guard let url = Bundle.main.url(forResource: file, withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = AVPlayer(url: url)
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}

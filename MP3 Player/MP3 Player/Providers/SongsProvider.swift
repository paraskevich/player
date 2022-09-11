//
//  SongsProvider.swift
//  MP3 Player
//
//  Created by ILYA Paraskevich on 11.09.22.
//

import Foundation

protocol SongsProvider {
    func getSongs(_ result: @escaping ([Song]?, Error?) -> ())
}

class SongsProviderImplementation: SongsProvider {
    
    private let songs: [Song] = [Song(songName: "We Wish You a Merry Christmas",
                              singerName: "Jim Brickman",
                              cover: "christmas",
                              audio: "Jim_Brickman_We_Wish_You_A_Merry_Christmas"),
                         Song(songName: "Wake Up Alone",
                              singerName: "Amy Winehouse",
                              cover: "amy",
                              audio: "Amy_Winehouse_Wake_Up_Alone"),
                         Song(songName: "What's the Difference",
                              singerName: "Dr Dre",
                              cover: "dr",
                              audio: "Dr_Dre_What_s_The_Difference")]
    
    func getSongs(_ result: @escaping ([Song]?, Error?) -> ()) {
        result(songs, nil)
    }
    
}

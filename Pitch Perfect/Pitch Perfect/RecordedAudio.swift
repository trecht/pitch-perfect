//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by tom on 4/5/15.
//  Copyright (c) 2015 tom. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    var filePathUrl: NSURL!
    var title: String!
    
    init(recordingPath: NSURL,recordingName: String) {
        filePathUrl = recordingPath
        title = recordingName
    }
}


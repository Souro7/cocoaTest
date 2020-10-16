//
//  Logger.swift
//  cocoaDemo
//
//  Created by Sourobrata Sarkar on 14/10/20.
//  Copyright © 2020 Sourobrata Sarkar. All rights reserved.
//

import Foundation

class Logger: NSObject {
    
    private lazy var filePath: String = {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = documentDirectory + "/appLog.txt"
        return path
    }()
    
    // Singleton
    static let shared = Logger()
    
    var isWriting: Bool = false
    
    func removeLogFile() {
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                debugPrint("Unable to clear log file")
            }
        }
    }
    
    func log(logString: String) {
        DispatchQueue.global(qos: .default).async {[weak self] in
            guard let weakSelf = self else {
                return
            }
            if !FileManager.default.fileExists(atPath: weakSelf.filePath) {
                FileManager.default.createFile(atPath: weakSelf.filePath, contents: nil, attributes: nil)
            }
            while weakSelf.isWriting {
                // Ignore writing in progress...
            }
            let log = "\n\(logString)"
            weakSelf.writeToFile(log)
        }
    }
    
    private func writeToFile(_ log: String) {
        isWriting = true
        guard let data = log.data(using: .utf8),
            let fileHandle = FileHandle(forWritingAtPath: filePath) else {
                isWriting = false
                return
        }
        fileHandle.seekToEndOfFile()
        fileHandle.write(data)
        fileHandle.closeFile()
        isWriting = false
    }
    
    func getLogFilePath() -> String {
        return filePath
    }
}

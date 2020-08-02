//
//  FullScreenViewController.swift
//  Pointters
//
//  Created by Mac on 2/23/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit

class FullScreenViewController: UIViewController {
    
    @IBOutlet var player: AAPlayer!
    
    var videoURL:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        player.delegate = self
        player.delegate2 = self
        player.playVideo(videoURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//*******************************************************//
//            MARK: - Extensions Methods                 //
//*******************************************************//

// AAPlayerDelegate
extension FullScreenViewController:AAPlayerDelegate {
    func startPlay() {
        player.startPlayback()
    }
    
    func stopPlay() {
        player.pausePlayback()
    }
    
    func callBackDownloadDidFinish(_ status: playerItemStatus?) {
        let status:playerItemStatus = status!
        switch status {
            case .readyToPlay:
                break
            case .failed:
                break
            default:
                break
        }
    }
}

// AAPlayerModeDelegate
extension FullScreenViewController:AAPlayerModeDelegate {
    func callBackDownloadDidModeChange(_ status:Bool,tag:Int) {
        navigationController?.popViewController(animated:true)
    }
}

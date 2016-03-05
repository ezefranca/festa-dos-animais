//
//  ViewController.swift
//  AnimaisFelizes
//
//  Created by Swift-301-SAB on 05/03/16.
//  Copyright © 2016 ezefranca. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    //MARK: Properties
    private var animalPlayers:[AVAudioPlayer] = []
    private var animalSounds = ["cat.wav", "dog.wav", "elephant.wav", "lion.wav"]
    private var musicPlayer : AVPlayer!
    private var playerItem : AVPlayerItem!
    
    private var bgPlayer : AVAudioPlayer!
    
    @IBOutlet weak var viewElapsedTime: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewElapsedTime.frame.size.width = 1.0;
        prepareAnimalPlayers()
        //playBackgroundMusic()
        playInternetMusic()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    //MARK: Actions
    @IBAction func playAnimalSound(sender:UIButton)
    {
        let player = animalPlayers[sender.tag]
        if player.playing{
            player.stop()
            player.currentTime = 0.0
            return
        }
        player.play()
    }
    
    //Mark: Methods
    
    private func prepareAnimalPlayers() {
        for sound in animalSounds{
            if let url = NSBundle.mainBundle().URLForResource(sound, withExtension: nil)
            {
                var player : AVAudioPlayer!
                do{
                    player = try AVAudioPlayer(contentsOfURL: url)
                    player.prepareToPlay()
                    animalPlayers.append(player)
                }catch {
                    print("Erro")
                }
            }
        }
        
        
    }
    
    private func playBackgroundMusic(){
        
        if let bgURL = NSBundle.mainBundle().URLForResource("bg", withExtension: "mp3"){
            
            do {
                bgPlayer = try AVAudioPlayer(contentsOfURL: bgURL)
                bgPlayer.volume = 0.5
                bgPlayer.delegate = self
                bgPlayer.prepareToPlay()
                bgPlayer.play()
                
                NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: "bgMusicPlayback:", userInfo: nil, repeats: true)
                
            }catch{
                print("Erro ao carregar background")
            }
        }
        
        
    }
    
    private func playInternetMusic(){
        if let url = NSURL(string: "https://archive.org/download/electronic_music_201403/SpringBook.mp3")
        {
            playerItem = AVPlayerItem(URL: url)
            musicPlayer = AVPlayer(playerItem: playerItem)
            
            musicPlayer.volume = 0.5
            musicPlayer.play()
            
            musicPlayer.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(1, 1), queue: dispatch_get_main_queue(), usingBlock: { (time: CMTime) -> Void in
                let timeRanges = self.playerItem.loadedTimeRanges
                let timeRange = timeRanges[0].CMTimeRangeValue
                let currentTime = CMTimeGetSeconds(self.playerItem.currentTime())
                let start = CMTimeGetSeconds(timeRange.start)
                let duration = CMTimeGetSeconds(self.playerItem.duration)
                let final = start + duration
                
                print("Tempo Atual: \(currentTime), Início: \(start), duration: \(duration), Fim: \(final)")
            })
        }
    }
    
    func bgMusicPlayback(timer:NSTimer){
        let percentPlayed = bgPlayer.currentTime / bgPlayer.duration
        var playBarFrame = viewElapsedTime.frame
        playBarFrame.size.width = CGFloat(percentPlayed) * view.frame.width
        viewElapsedTime.frame = playBarFrame
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let view = touches.first!.view!
        if view == self.view
        {
            if bgPlayer != nil
            {
                if bgPlayer.playing
                {
                    bgPlayer.stop()
                    return
                }
                bgPlayer.play()
            }
            return
        }
        let position = touches.first!.locationInView(self.view)
        let percent = position.x / (self.view.frame.size.width)
        let seconds = bgPlayer.duration * Double(percent)
        
        bgPlayer.currentTime = seconds
        bgPlayer.play()
    }
    
    
    
    
}


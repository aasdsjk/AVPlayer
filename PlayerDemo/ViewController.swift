//
//  ViewController.swift
//  PlayerDemo
//
//  Created by ning on 16/10/26.
//  Copyright © 2016年 songjk. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let screenW = UIScreen.main.bounds.width
let screenH = UIScreen.main.bounds.height
class ViewController: UIViewController {

    var topView : UIView!
    var bottomView : UIView!
    var downBtn : UIButton!
    var progressSlider : UISlider!
    var progress : UIProgressView!
    var timeLable : UILabel!
    var leftLable : UILabel!
    
    var previousBtn : UIButton!
    var startBtn : UIButton!
    var nextBtn : UIButton!
    
    var player : AVPlayer!
    var playerItem : AVPlayerItem!
    
    var timer : Timer!
    var alphaTimer : Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //横屏

        createPlayer()
        createTopViewAndBottomView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    override func viewDidDisappear(_ animated: Bool) {
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    fileprivate func createTopViewAndBottomView()  {
        self.view.backgroundColor = UIColor.black
        topView = UIView.init()
        topView.backgroundColor = UIColor.black
        topView.alpha = 0.5
        self.view.addSubview(topView)
        
        downBtn = UIButton.init(type: .custom)
        downBtn.setTitle("完成", for: .normal)
        downBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        downBtn.addTarget(self, action: #selector(downBtnClick), for: .touchUpInside)
        topView.addSubview(downBtn)
        
        progressSlider = UISlider.init()
        progressSlider.isContinuous = false
        progressSlider.addTarget(self, action: #selector(progressSliderValueChange), for: .valueChanged)
        progress = UIProgressView.init()
        progress.trackTintColor = UIColor.white
        progress.progressTintColor = UIColor.gray
        topView.addSubview(progress)
        topView.addSubview(progressSlider)
        
        
        timeLable = UILabel();
        timeLable.font = UIFont.systemFont(ofSize: 13.0)
        topView.addSubview(timeLable)
        leftLable = UILabel();
        leftLable.font = UIFont.systemFont(ofSize: 13.0)
        topView.addSubview(leftLable)
        
        bottomView = UIView.init()
        bottomView.backgroundColor = UIColor.black
        bottomView.alpha = 0.5
        
        previousBtn = UIButton.init(type: .custom)
        previousBtn.setImage(UIImage.init(named: "idx1"), for: .normal)
        
        
        
        startBtn = UIButton.init(type: .custom)
        startBtn.setImage(UIImage.init(named: "idx1"), for: .normal)
        startBtn.backgroundColor = UIColor.red
        startBtn.addTarget(self, action: #selector(startAndParuse(sender:)), for: .touchUpInside)
        
        nextBtn = UIButton.init(type: .custom)
        nextBtn.setImage(UIImage.init(named: "idx1"), for: .normal)
        nextBtn.addTarget(self, action: #selector(nextVideo), for: .touchUpInside)
        bottomView.addSubview(previousBtn)
        bottomView.addSubview(startBtn)
        bottomView.addSubview(nextBtn)
        self.view.addSubview(bottomView)
        
        timeLable.backgroundColor = UIColor.red
        leftLable.backgroundColor = UIColor.red
        contentMasnory()
        
        self.view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapView))
        self.view.addGestureRecognizer(tap)
        self.perform(#selector(alphaChange), with: self, afterDelay: 4)
        
        let swipe = UISwipeGestureRecognizer.init(target: self, action: #selector(swiptUp))
        swipe.direction = .up
        self.view.addGestureRecognizer(swipe)
        //        alphaTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(alphaChange), userInfo: nil, repeats: <#T##Bool#>)
    }
    
    fileprivate func createPlayer() {
        playerItem = AVPlayerItem.init(url: NSURL.init(string: "http://krtv.qiniudn.com/150522nextapp") as! URL)
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        player = AVPlayer.init(playerItem: playerItem)
        let playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = CGRect.init(x: 0, y: 0, width: screenW, height: screenH)
        playerLayer.videoGravity = AVLayerVideoGravityResize
        self.view.layer.addSublayer(playerLayer)
        player.play()
        
        addTimer()
        
    }
    
    func contentMasnory()  {
        topView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.trailing.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(50)
        }
        downBtn.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(10)
            make.height.equalTo(30)
            make.width.equalTo(40)
        }
        timeLable.snp.makeConstraints { (make) in
            make.left.equalTo(downBtn.snp.right).offset(10)
            make.top.equalTo(downBtn)
            make.height.equalTo(downBtn)
            make.width.equalTo(downBtn)
        }
        
        progressSlider.snp.makeConstraints { (make) in
            make.left.equalTo(timeLable.snp.right).offset(10)
            make.top.equalTo(timeLable)
            make.height.equalTo(timeLable)
            make.trailing.equalTo(-100)
        }
        progress.snp.makeConstraints { (make) in
            make.centerY.equalTo(progressSlider.snp.centerY).offset(0.5)
            make.left.equalTo(progressSlider.snp.left).offset(2)
            make.trailing.equalTo(progressSlider.snp.trailing).offset(-2)
            make.height.equalTo(1.5)
        }
        
        leftLable.snp.makeConstraints { (make) in
            make.left.equalTo(progressSlider.snp.right).offset(10)
            make.top.equalTo(10)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.bottom.equalTo(self.view.snp.bottom)
            make.trailing.equalTo(0)
            make.height.equalTo(50)
        }
        startBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(bottomView)
            make.centerY.equalTo(bottomView)
            make.height.equalTo(40)
            make.width.equalTo(30)
        }
        
        previousBtn.snp.makeConstraints { (make) in
            make.trailing.equalTo(startBtn.snp.leading).offset(-30)
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.top.equalTo(10)
        }
        nextBtn.snp.makeConstraints { (make) in
            make.left.equalTo(startBtn.snp.right).offset(30)
            make.width.equalTo(previousBtn)
            make.height.equalTo(previousBtn)
            make.top.equalTo(10)
        }
    }
    
    func startAndParuse(sender:UIButton)  {
        if sender.isSelected {
            player.play()
            addTimer()
            sender.isSelected = false
        }else{
            player.pause()
            removeTimer()
            sender.isSelected = true
        }
        
    }
    func nextVideo()  {
        //        player = nil
        player.pause()
        removeTimer()
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
        playerItem = nil
        //        player = nil
        let playerI = AVPlayerItem.init(url: NSURL.init(string: "http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4") as! URL)
        //
        player.replaceCurrentItem(with: playerI)
        
        //        let play = AVPlayer.init(playerItem: playerI)
        //        player = play
        playerItem = playerI
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        player.play()
        addTimer()
    }
    
    func addTimer()  {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerProgress), userInfo: nil, repeats: true)
        }
        
    }
    func removeTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil;
        }
    }
    func downBtnClick()  {
        removeTimer()
        self.dismiss(animated: true, completion: nil)
    }
    func tapView()  {
        if topView.alpha == 0.5 {
            UIView.animate(withDuration: 0.5, animations: {
                self.topView.alpha = 0
                self.bottomView.alpha = 0
            })
            
        }else{
            UIView.animate(withDuration: 0.5, animations: {
                self.topView.alpha = 0.5
                self.bottomView.alpha = 0.5
                //                self.perform(#selector(self.alphaChange), with: nil, afterDelay: 4)
            })
        }
    }
    func swiptUp()  {
        let currentBrigt = UIScreen.main.brightness
        let changeBrigt = currentBrigt + 5;
        UIScreen.main.brightness = changeBrigt
    }
    func alphaChange()  {
        if topView.alpha == 0.5 {
            UIView.animate(withDuration: 0.5, animations: {
                self.topView.alpha = 0
                self.bottomView.alpha = 0
            })
            
        }
    }
    func progressSliderValueChange()  {
        //        拖动改变视频播放进度
        if player.status == .readyToPlay {
            let total = Float(playerItem.duration.value/Int64(playerItem.duration.timescale))
            let dragedSeconds = floorf(total * progressSlider.value)
            
            let dragedCMTime = CMTime.init(value: CMTimeValue(dragedSeconds), timescale: 1)
            player.pause()
            removeTimer()
            player.seek(to: dragedCMTime, completionHandler: { (finish) in
                if finish  {
                    self.player.play()
                    self.addTimer()
                }
            })
            
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "loadedTimeRanges" {
            //            let timeinterval = self.availableDuration()//缓冲速度
            let duration = playerItem.duration
            let total = CMTimeGetSeconds(duration)
            progress.setProgress(Float(total), animated: false)
        }
        
    }
    
    
    func availableDuration() -> TimeInterval{
        let loadedTimeRanges = player.currentItem?.loadedTimeRanges
        let timeRange = loadedTimeRanges?.first?.timeRangeValue as CMTimeRange?
        let startSeconds = CMTimeGetSeconds(timeRange!.start)
        let durationSeconds = CMTimeGetSeconds(timeRange!.duration)
        let result = (startSeconds + durationSeconds)
        return result
        
    }
    func timerProgress()  {
        if playerItem.duration.timescale != 0 {
            progressSlider.maximumValue = 1.0
            let total = Float(playerItem.duration.value/Int64(playerItem.duration.timescale))
            progressSlider.value = Float(CMTimeGetSeconds(playerItem.currentTime()))/total
            let promin = NSInteger(CMTimeGetSeconds(playerItem.currentTime()))/60//当前秒
            let prosec = NSInteger(CMTimeGetSeconds(playerItem.currentTime()))%60//当前分
            
            let durmin = NSInteger(total)/60
            let dursec = NSInteger(total)%60
            
            let leftmin = durmin - promin
            let leftsec = dursec - prosec
            
            
            timeLable.text = NSString.init(format: "%02ld:%02ld", promin,prosec,durmin,dursec) as String
            
            leftLable.text = NSString.init(format: "-%02ld:%02ld", leftmin,leftsec) as String
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


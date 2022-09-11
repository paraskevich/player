//
//  ViewController.swift
//  MP3 Player
//
//  Created by ILYA Paraskevich on 5.09.22.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: - Views
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var singerNameLabel: UILabel!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var timeProgressLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    // MARK: - Properties
    
    private let horizontalPadding: CGFloat = 40
    private let playerManager: PlayerManager = .shared
    private var indexOfCellBeforeDragging = 0
    private var isPlaying: Bool = false
    private var currentSongIndex = 0
    private var sliderTimer: Timer?
    private var playList: [Song] = []
    private lazy var songsProvider: SongsProvider = SongsProviderImplementation()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlayList()
        setupViewsAppearance()
        setupCollectionView()
        setupPlayer()
        togglePlayerState()
    }
    
    // MARK: - Actions
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        togglePlayerState()
    }
    
    @IBAction func forwardButtonPressed(_ sender: Any) {
        isPlaying = false
        if currentSongIndex == playList.count - 1 {
            currentSongIndex = 0
        } else {
            currentSongIndex += 1
        }
        togglePlayerState()
        setupPlayer()
        collectionView.scrollToItem(at: IndexPath(item: currentSongIndex, section: 0),
                                    at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func backwardButtonPressed(_ sender: Any) {
        isPlaying = false
        if currentSongIndex == 0 {
            currentSongIndex = playList.count - 1
        } else {
            currentSongIndex -= 1
        }
        togglePlayerState()
        setupPlayer()
        collectionView.scrollToItem(at: IndexPath(item: currentSongIndex, section: 0),
                                    at: .centeredHorizontally, animated: true)
    }
    
    // MARK: - Methods
    
    private func setupPlayList() {
        songsProvider.getSongs { [weak self] songs, error in
            guard let self = self else { return }
            if let songs = songs {
                self.playList = songs
            } else {
                print(error.debugDescription)
            }
        }
    }
    
    private func setupViewsAppearance() {
        playPauseButton.layer.cornerRadius = playPauseButton.frame.height / 2
        songNameLabel.text = playList[currentSongIndex].songName
        singerNameLabel.text = playList[currentSongIndex].singerName
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "CoverCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "CoverCollectionViewCell")
    }
    
    private func setupPlayer() {
        playerSlider.setThumbImage(UIImage(named: "progress"), for: .normal)
        playerManager.play(file: playList[currentSongIndex].audio)
        songNameLabel.text = playList[currentSongIndex].songName
        singerNameLabel.text = playList[currentSongIndex].singerName
        setupProgressSlider()
    }
    
    private func togglePlayerState() {
        isPlaying.toggle()
        if isPlaying == false {
            playPauseButton.setImage(UIImage(systemName: "play.fill"),
                                     for: .normal)
            playerManager.player.pause()
        } else {
            playPauseButton.setImage(UIImage(systemName: "pause.fill"),
                                     for: .normal)
            playerManager.player.play()
        }
    }
    
}

// MARK: - Time tracker setting

extension ViewController {
    
    private func setupProgressSlider() {
        if let duration = playerManager.player.currentItem?.asset.duration {
            let seconds = CMTimeGetSeconds(duration)
            playerSlider.maximumValue = Float(seconds)
        }
        playerSlider.minimumValue = 0.0

        if let _ = self.sliderTimer {
            self.sliderTimer?.invalidate()
        }

        sliderTimer = Timer.scheduledTimer(timeInterval: 0,
                                           target: self,
                                           selector: #selector(sliderTimerTriggered),
                                           userInfo: nil,
                                           repeats: true)
        setupTotalTimeLabel()
    }
    
    @objc func sliderTimerTriggered() {
        let playerCurrentTime = playerManager.player.currentTime().seconds
        playerSlider.value = Float(playerCurrentTime)
        updateCurrentTimeLabel(Float(playerCurrentTime))
    }
    
    private func setupTotalTimeLabel() {
        if let duration = playerManager.player.currentItem?.asset.duration {
            let seconds = CMTimeGetSeconds(duration)
            if seconds.isNaN || seconds.isInfinite { return }
            durationLabel.text = timeLabelString(Int(seconds))
        }
    }
    
    private func updateCurrentTimeLabel(_ currentTimeInSeconds: Float) {
        if currentTimeInSeconds.isNaN || currentTimeInSeconds.isInfinite { return }
        timeProgressLabel.text = timeLabelString(Int(currentTimeInSeconds))
    }
    
    private func timeLabelString(_ duration: Int) -> String {
        let currentMinutes = Int(duration) / 60
        let currentSeconds = Int(duration) % 60

        return currentSeconds < 10 ? "\(currentMinutes):0\(currentSeconds)" : "\(currentMinutes):\(currentSeconds)"
    }
    
}

// MARK: - Collection view delegate & data source

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - horizontalPadding * 2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: horizontalPadding, bottom: 0, right: horizontalPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoverCollectionViewCell", for: indexPath)
        guard let collectionCell = cell as? CoverCollectionViewCell else { return cell }
        
        collectionCell.setupCell(with: playList[indexPath.item].cover)
        
        return collectionCell
    }
    
}

// MARK: - Scrolling collection view

extension ViewController {
    /// This extension allows collection view cells to automatically align to the center of the screen after using dragging gesture
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        /// Preparing to scroll
        let pageWidth = view.frame.width - 1.5 * horizontalPadding
        let proportionalOffset = collectionView.contentOffset.x / pageWidth
        indexOfCellBeforeDragging = Int(round(proportionalOffset))
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        /// Stop scrolling
        targetContentOffset.pointee = scrollView.contentOffset

        /// Calculate conditions
        let pageWidth = view.frame.width - 1.5 * horizontalPadding
        let collectionViewItemCount = playList.count
        let proportionalOffset = collectionView.contentOffset.x / pageWidth
        let indexOfMajorCell = Int(round(proportionalOffset))
        let swipeVelocityThreshold: CGFloat = 0.5
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < collectionViewItemCount && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        if didUseSwipeToSkipCell {
            /// Animate so that swipe is just continued
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = pageWidth * CGFloat(snapToIndex)
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: velocity.x,
                options: .allowUserInteraction,
                animations: {
                    scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                    scrollView.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            /// Pop back (against velocity)
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        /// Change the song
        let pageWidth = view.frame.width - 1.5 * horizontalPadding
        let proportionalOffset = collectionView.contentOffset.x / pageWidth
        currentSongIndex = Int(round(proportionalOffset))
        guard !(indexOfCellBeforeDragging == 0 && currentSongIndex == indexOfCellBeforeDragging), !(indexOfCellBeforeDragging == playList.count - 1 && currentSongIndex == indexOfCellBeforeDragging) else { return }
        isPlaying = false
        togglePlayerState()
        setupPlayer()
    }
    
}

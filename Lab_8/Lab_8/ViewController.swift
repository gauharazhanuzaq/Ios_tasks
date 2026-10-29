import UIKit
import AVFoundation

struct Music {
    let name: String
    let artist: String
    let fileNum: Int
}

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    
    @IBOutlet weak var musicPhoto: UIImageView!
    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var musicArtist: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    private let tracks = TrackLibrary.all
        private var currentIndex = 0
        private var isPlaying = false
        private var audioPlayer: AVAudioPlayer?

        override func viewDidLoad() {
            super.viewDidLoad()
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            loadTrack(at: currentIndex)
            refreshUI()
        }

        // MARK: - Actions

        @IBAction func playPauseMusic(_ sender: UIButton) {
            guard let player = audioPlayer else {
                print("No uploaded track.")
                return
            }
            if isPlaying {
                player.pause()
                isPlaying = false
            } else {
                player.play()
                isPlaying = true
            }
            refreshUI()
        }

        @IBAction func nextTap(_ sender: UIButton) {
            changeTrack(to: currentIndex + 1)
        }

        @IBAction func prevTap(_ sender: UIButton) {
            changeTrack(to: currentIndex - 1)
        }

        // MARK: - Playback

        private func changeTrack(to index: Int) {
            let wasPlaying = isPlaying
            currentIndex = (index % tracks.count + tracks.count) % tracks.count
            loadTrack(at: currentIndex)

            if wasPlaying, let player = audioPlayer {
                player.play()
                isPlaying = true
            } else {
                isPlaying = false
            }
            refreshUI()
        }

        private func loadTrack(at index: Int) {
            audioPlayer?.stop()
            audioPlayer = nil

            let track = tracks[index]
            guard let url = Bundle.main.url(forResource: track.fileName, withExtension: "mp3") else {
                print("File \(track.fileName) mp3 not found. Check Target Membership.")
                return
            }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.delegate = self
                player.prepareToPlay()
                audioPlayer = player
            } catch {
                print("Failed to open \(track.fileName).mp3: \(error.localizedDescription)")
            }
        }

        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            changeTrack(to: currentIndex + 1)  
        }

        // MARK: - UI

        private func refreshUI() {
            let track = tracks[currentIndex]
            musicName.text = track.title
            musicArtist.text = track.artist
            musicPhoto.image = UIImage(named: track.coverImageName)

            let iconName = isPlaying ? "pause.fill" : "play.fill"
            playButton.setImage(UIImage(systemName: iconName), for: .normal)
        }
}


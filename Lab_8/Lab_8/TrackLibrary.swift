import Foundation

struct Track {
    let title: String
    let artist: String
    let fileName: String
    let coverImageName: String 
}

enum TrackLibrary {
    static let all: [Track] = [
        Track(title: "Senshi magan shyn aitamyn", artist: "Aikyn Tolepbergen", fileName: "1", coverImageName: "1"),
        Track(title: "Medina", artist: "Jah Khalib", fileName: "2", coverImageName: "2"),
        Track(title: "Bud Moejj", artist: "Jaman T", fileName: "3", coverImageName: "3"),
        Track(title: "Radost", artist: "Saddradin&Andro", fileName: "4", coverImageName: "4"),
        Track(title: "Balkon", artist: "Elman&Jony", fileName: "5", coverImageName: "5"),
        Track(title: "Sobirai menya", artist: "Artem Pivovarov", fileName: "6", coverImageName: "6"),
        Track(title: "Nochnojj rejjis", artist: "Andro", fileName: "7", coverImageName: "7"),
        Track(title: "Dance in the Rain", artist: "Batyrkhan Shukenov", fileName: "8", coverImageName: "8"),
        Track(title: "Dance Monkey", artist: "Tones and I", fileName: "9", coverImageName: "9"),
        Track(title: "Sen", artist: "Shiza&Aikyn_Tolepbergen", fileName: "10", coverImageName: "10")
    ]
}

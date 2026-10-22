//
//  ViewController.swift
//  FavoritesRouletteFilms
//
//  Created by Gauhar Zhanuzak on 14.10.2026.
//

import UIKit

struct Favorite {
    let title: String
    let details: String
    let imageName: String
}

class ViewController: UIViewController {

    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!

    private let favorites: [Favorite] = [
        Favorite(title: "The Avengers", details: "A team of Marvel superheroes unites to defend Earth from an alien invasion.", imageName: "Avengers"),
        Favorite(title: "Black Panther", details: "King T'Challa returns to Wakanda and must protect his nation and its technology.", imageName: "Black_panther"),
        Favorite(title: "F1", details: "A veteran racing driver returns to Formula 1 to help a struggling team and its rookie.", imageName: "F1"),
        Favorite(title: "Divergent", details: "In a society split into factions, a girl discovers she doesn't fit into any of them.", imageName: "Divergent"),
        Favorite(title: "Spider-Man", details: "Teenager Peter Parker gains spider powers and learns what it means to be a hero.", imageName: "Spiderman"),
        Favorite(title: "Fantastic Four", details: "Four scientists gain extraordinary powers after a cosmic experiment goes wrong.", imageName: "Fant_4"),
        Favorite(title: "The Hunger Games", details: "In a dystopian world, Katniss volunteers to fight in a deadly televised contest.", imageName: "hunger_games"),
        Favorite(title: "Jumanji", details: "Players are pulled into a magical jungle game and must finish it to get home.", imageName: "jumanji"),
        Favorite(title: "The Maze Runner", details: "A boy with no memory wakes up in a giant maze and searches for a way out.", imageName: "Maze_runner"),
        Favorite(title: "The Intouchables", details: "A wealthy man with paralysis hires an unlikely caregiver, and they change each other's lives.", imageName: "oneplusone")
    ]

    private var lastIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        ImageView.contentMode = .scaleAspectFit
        TitleLabel.numberOfLines = 0
        DescriptionLabel.numberOfLines = 0
        showInitialState()
    }

    @IBAction func rouletteTapped(_ sender: UIButton) {
        showRandomFavorite()
    }

    private func showInitialState() {
        ImageView.image = UIImage(systemName: "questionmark.circle")
        TitleLabel.text = "Favorites Roulette"
        DescriptionLabel.text = "Tap the button to pick a random favorite movie."
    }

    private func showRandomFavorite() {
        // All indices except the previous one, so the same card never appears twice in a row
        let candidates = favorites.indices.filter { $0 != lastIndex }
        guard let index = candidates.randomElement() else { return }
        lastIndex = index
        print(index)
        let favorite = favorites[index]
        ImageView.image = UIImage(named: favorite.imageName)
        TitleLabel.text = favorite.title
        DescriptionLabel.text = favorite.details
    }
}

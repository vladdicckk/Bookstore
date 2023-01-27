//
//  FavouritesViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 10.01.2023.
//

import UIKit

class FavouritesViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet var mainView: UIView!
    // MARK: Properties
    private var presenter = BooksPresenter()         // Handles all the data
    private var collectionView: UICollectionView!
    
    // MARK: - Life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Books of the day"
        mainView.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        setupCollectionView()
        setupMainView()
    }
    
    // MARK: - Setup methods -
    /// Constructs the UICollectionView and adds it to the view.
    /// Registers all the Cells and Views that the UICollectionView will need
    private func setupMainView(){
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.25
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        mainView.addSubview(backgroundBlur)
        mainView.sendSubviewToBack(backgroundBlur)
        
        NSLayoutConstraint.activate([
            backgroundBlur.topAnchor.constraint(equalTo: mainView.topAnchor),
            backgroundBlur.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            backgroundBlur.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            backgroundBlur.bottomAnchor.constraint(equalTo: mainView.bottomAnchor)
        ])
    }
    private func setupCollectionView() {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.7
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        // Initialises the collection view with a CollectionViewLayout which we will define
        collectionView = UICollectionView.init(frame: .zero,
                                               collectionViewLayout: makeLayout())
        // Assigning data source and background color
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = backgroundBlur
        // Adding the collection view to the view
        mainView.addSubview(collectionView)
        
        // This line tells the system we will define our own constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraining the collection view to the 4 edges of the view
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 200),
            collectionView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor)
        ])
        
        // Registering all Cells and Classes we will need
        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeader.identifier)
        collectionView.register(RecomendedBooksCollectionViewCell.self,
                                forCellWithReuseIdentifier: RecomendedBooksCollectionViewCell.identifier)
        collectionView.register(RandomGenreCollectionViewCell.self,
                                forCellWithReuseIdentifier: RandomGenreCollectionViewCell.identifier)
        collectionView.register(RecentlyAddedBooksCollectionViewCell.self,
                                forCellWithReuseIdentifier: RecentlyAddedBooksCollectionViewCell.identifier)
    }
    
    
    // MARK: - Collection View Helper Methods -
    // In this section you can find all the layout related code
    
    /// Creates the appropriate UICollectionViewLayout for each section type
    private func makeLayout() -> UICollectionViewLayout {
        // Constructs the UICollectionViewCompositionalLayout
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnv: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch self.presenter.sectionType(for: sectionIndex) {
            case .singleList:   return self.createSingleListSection()
            case .doubleList:   return self.createDoubleListSection()
            case .tripleList:   return self.createTripleListSection()
            }
        }
        
        // Configure the Layout with interSectionSpacing
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        
        return layout
    }
    
    /// Creates the layout for the Featured styled sections
    private func createSingleListSection() -> NSCollectionLayoutSection {
        // Defining the size of a single item in this layout
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1))
        // Construct the Layout Item
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Configure the Layout Item
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        // Defining the size of a group in this layout
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .estimated(300),
                                                     heightDimension: .estimated(150))
        
        // Constructing the Layout Group
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize,
                                                           subitem: layoutItem,
                                                           count: 1)
        // Configuring the Layout Group
        layoutGroup.interItemSpacing = .fixed(8)
        
        // Constructing the Layout Section
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        
        // Configuring the Layout Section
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        
        // Constructing the Section Header
        let layoutSectionHeader = createSectionHeader()
        
        // Adding the Section Header to the Section Layout
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        
        
        return layoutSection
    }
    
    /// Creates a layout that shows 2 items per group and scrolls horizontally
    private func createDoubleListSection() -> NSCollectionLayoutSection {
        // Defining the size of a single item in this layout
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1))
        // Construct the Layout Item
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Configure the Layout Item
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        // Defining the size of a group in this layout
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .estimated(300),
                                                     heightDimension: .estimated(150))
        
        // Constructing the Layout Group
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize,
                                                           subitem: layoutItem,
                                                           count: 1)
        // Configuring the Layout Group
        layoutGroup.interItemSpacing = .fixed(8)
        
        // Constructing the Layout Section
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        
        // Configuring the Layout Section
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        
        // Constructing the Section Header
        let layoutSectionHeader = createSectionHeader()
        
        // Adding the Section Header to the Section Layout
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        
        return layoutSection
    }
    
    /// Creates a layout that shows 3 items per group and scrolls horizontally
    private func createTripleListSection() -> NSCollectionLayoutSection {
        // Defining the size of a single item in this layout
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1))
        // Construct the Layout Item
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Configure the Layout Item
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        // Defining the size of a group in this layout
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .estimated(300),
                                                     heightDimension: .estimated(150))
        // Constructing the Layout Group
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize,
                                                           subitem: layoutItem,
                                                           count: 1)
        // Configuring the Layout Group
        layoutGroup.interItemSpacing = .fixed(8)
        
        // Constructing the Layout Section
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        
        // Configuring the Layout Section
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        
        // Constructing the Section Header
        let layoutSectionHeader = createSectionHeader()
        
        // Adding the Section Header to the Section Layout
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        
        return layoutSection
    }
    
    /// Creates a layout that shows a list of small items based on the given amount.
    
    
    /// Creates a Layout for the SectionHeader
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        // Define size of Section Header
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95),
                                                             heightDimension: .estimated(80))
        
        // Construct Section Header Layout
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize,
                                                                              elementKind: UICollectionView.elementKindSectionHeader,
                                                                              alignment: .top)
        return layoutSectionHeader
    }
}

// MARK: - UICollectionViewDataSource -

extension FavouritesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    /// Tells the UICollectionView how many sections are needed
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter.numberOfSections
    }
    
    /// Tells the UICollectionView how many items the requested sections needs
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfItems(for: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bookInfo: BookInfoViewController = storyboard?.instantiateViewController(withIdentifier: "BookInfoViewController") as! BookInfoViewController
        present(bookInfo, animated: true)
    }
    /// Constructs and configures the item needed for the requested IndexPath
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Checks what section type we should use for this indexPath so we use the right cells for that section
        switch presenter.sectionType(for: indexPath.section) {
        case .singleList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecomendedBooksCollectionViewCell.identifier, for: indexPath) as? RecomendedBooksCollectionViewCell else {
                fatalError("Could not dequeue FeatureCell")
            }
            
            presenter.configure(item: cell, for: indexPath)
            
            return cell
            
        case .doubleList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RandomGenreCollectionViewCell.identifier, for: indexPath) as? RandomGenreCollectionViewCell else {
                fatalError("Could not dequeue MediumAppCell")
            }
            
            presenter.configure(item: cell, for: indexPath)
            
            return cell
        case .tripleList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentlyAddedBooksCollectionViewCell.identifier, for: indexPath) as? RecentlyAddedBooksCollectionViewCell else {
                fatalError("Could not dequeue SmallAppCell")
            }
            
            presenter.configure(item: cell, for: indexPath)
            
            return cell
        }
    }
    
    /// Constructs and configures the Supplementary Views for the UICollectionView
    /// In this project only used for the Section Headers
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.identifier, for: indexPath) as? SectionHeader else {
            fatalError("Could not dequeue SectionHeader")
        }
        
        // If the section has a title show it in the Section header, otherwise hide the titleLabel
        if let title = presenter.title(for: indexPath.section) {
            headerView.titleLabel.text = title
            headerView.titleLabel.isHidden = false
        } else {
            headerView.titleLabel.isHidden = true
        }
        
        // If the section has a subtitle show it in the Section header, otherwise hide the subtitleLabel
        if let subtitle = presenter.subtitle(for: indexPath.section) {
            headerView.subtitleLabel.text = subtitle
            headerView.subtitleLabel.isHidden = false
        } else {
            headerView.subtitleLabel.isHidden = true
        }
        
        return headerView
    }
}



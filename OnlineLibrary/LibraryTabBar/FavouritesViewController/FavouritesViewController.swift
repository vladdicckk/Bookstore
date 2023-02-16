//
//  FavouritesViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 10.01.2023.
//

import UIKit
import FirebaseFirestore

class FavouritesViewController: UIViewController, RecommendedBooksArr {
    // MARK: Outlets
    @IBOutlet var mainView: UIView!
    
    // MARK: Properties
    let db = Firestore.firestore()
    let firestoreManager = FirestoreManager()
    var presenter = BooksPresenter()         // Handles all the data
    private var collectionView: UICollectionView!
    private var appendingButton = UIButton()
    var recommendedBooksArr: [BookInfo]?
    var randomBooksArr: [BookInfo]?
    var recentlyAddedBooksArr: [BookInfo]?
    
    // MARK: - Life cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .done, target: self, action: #selector(refreshData))
        self.title = "Favourites"
        mainView.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        setupCollectionView()
        setupMainView()
        
        if appDelegate().currentBookstoreOwner != nil && appDelegate().currentReviewingOwnersProfile != nil {
            if #available(iOS 16.0, *) {
                appendingButton.isHidden = true
            } else {
                // Fallback on earlier versions
                appendingButton.isEnabled = false
            }
        }
        if appDelegate().currentBookstoreOwner == nil {
            appendingButton.isHidden = true
        }
        setupAppendingButton()
    }
    
    @objc func refreshData(sender: UIBarButtonItem) {
        var email = ""
        if appDelegate().currentBookstoreOwner != nil {
            guard let email_1 = appDelegate().currentBookstoreOwner?.email else { return }
            email = email_1
        } else {
            guard let email_2 = appDelegate().currentReviewingOwnersProfile?.email else { return }
            email = email_2
        }
        
        self.firestoreManager.getRecommendedBooks(email: email, completion: { arr in
            self.firestoreManager.configureRandomBooksOfRandomGenre(email: email, completion: { randArr in
                self.firestoreManager.configureRecentlyAddedBooks(email: email, completion: { recentArr in
                    self.recommendedBooksArr = arr
                    self.randomBooksArr = randArr
                    self.recentlyAddedBooksArr = recentArr
                    self.collectionView.reloadData()
                })
            })
        })
    }
    
    // MARK: - Setup methods -
    /// Constructs the UICollectionView and adds it to the view.
    /// Registers all the Cells and Views that the UICollectionView will need
    func setRecommendedBooks(arr: [BookInfo]) {
        self.recommendedBooksArr = arr
        collectionView.reloadData()
    }
    
    private func setupAppendingButton() {
        appendingButton.setTitle("Append books to recommended", for: .normal)
        appendingButton.addTarget(self, action: #selector(appendingButtonTapped), for: .allEvents)
        appendingButton.configuration = .tinted()
        
        view.addSubview(appendingButton)
        appendingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appendingButton.heightAnchor.constraint(equalToConstant: 20),
            appendingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            appendingButton.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: 20)
        ])
        
    }
    
    private func setupMainView() {
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
            blurView.alpha = 1
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
        collectionView.delegate = self
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
            switch self.presenter.sectionType(for: sectionIndex, dataSource: self.setupBooksData()) {
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(0.25))
        // Construct the Layout Item
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Configure the Layout Item
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        // Defining the size of a group in this layout
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .estimated(300),
                                                     heightDimension: .estimated(75))
        
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(0.25))
        // Construct the Layout Item
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Configure the Layout Item
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        // Defining the size of a group in this layout
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .estimated(300),
                                                     heightDimension: .estimated(75))
        
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(0.25))
        // Construct the Layout Item
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Configure the Layout Item
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        // Defining the size of a group in this layout
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .estimated(300),
                                                     heightDimension: .estimated(75))
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
        return presenter.numberOfItems(for: section, dataSource: self.setupBooksData())
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch presenter.sectionType(for: indexPath.section, dataSource: self.setupBooksData()) {
        case .singleList:
            let bookInfo: BookInfoViewController = storyboard?.instantiateViewController(withIdentifier: "BookInfoViewController") as! BookInfoViewController
            bookInfo.bookTitle = self.recommendedBooksArr?[indexPath.row].title
            bookInfo.language = self.recommendedBooksArr?[indexPath.row].language
            bookInfo.author = self.recommendedBooksArr?[indexPath.row].author
            bookInfo.genre = self.recommendedBooksArr?[indexPath.row].genre
            bookInfo.additionalInfo = self.recommendedBooksArr?[indexPath.row].additionalInfo
            bookInfo.publishYear = self.recommendedBooksArr?[indexPath.row].publishYear
            bookInfo.pagesCount = self.recommendedBooksArr?[indexPath.row].pagesCount
            bookInfo.price = self.recommendedBooksArr?[indexPath.row].price
            present(bookInfo, animated: true)
        case .doubleList:
            let bookInfo: BookInfoViewController = storyboard?.instantiateViewController(withIdentifier: "BookInfoViewController") as! BookInfoViewController
            bookInfo.bookTitle = self.randomBooksArr?[indexPath.row].title
            bookInfo.language = self.randomBooksArr?[indexPath.row].language
            bookInfo.author = self.randomBooksArr?[indexPath.row].author
            bookInfo.genre = self.randomBooksArr?[indexPath.row].genre
            bookInfo.additionalInfo = self.randomBooksArr?[indexPath.row].additionalInfo
            bookInfo.publishYear = self.randomBooksArr?[indexPath.row].publishYear
            bookInfo.pagesCount = self.randomBooksArr?[indexPath.row].pagesCount
            bookInfo.price = self.randomBooksArr?[indexPath.row].price
            present(bookInfo, animated: true)
        case .tripleList:
            let bookInfo: BookInfoViewController = storyboard?.instantiateViewController(withIdentifier: "BookInfoViewController") as! BookInfoViewController
            bookInfo.bookTitle = self.recentlyAddedBooksArr?[indexPath.row].title
            bookInfo.language = self.recentlyAddedBooksArr?[indexPath.row].language
            bookInfo.author = self.recentlyAddedBooksArr?[indexPath.row].author
            bookInfo.genre = self.recentlyAddedBooksArr?[indexPath.row].genre
            bookInfo.additionalInfo = self.recentlyAddedBooksArr?[indexPath.row].additionalInfo
            bookInfo.publishYear = self.recentlyAddedBooksArr?[indexPath.row].publishYear
            bookInfo.pagesCount = self.recentlyAddedBooksArr?[indexPath.row].pagesCount
            bookInfo.price = self.recentlyAddedBooksArr?[indexPath.row].price
            present(bookInfo, animated: true)
        }
    }
    /// Constructs and configures the item needed for the requested IndexPath
    func setupBooksData() -> [Section] {
        var dataSource: [Section] = []
        let recommendedBooksArr: [BookInfo] = self.recommendedBooksArr ?? [BookInfo(title: "", author: "", publishYear: 0, genre: "", pagesCount: 0, language: "", price: 0, additionalInfo: "", addingDate: "")]
        let randomBooksArr: [BookInfo] = self.randomBooksArr ?? [BookInfo(title: "", author: "", publishYear: 0, genre: "", pagesCount: 0, language: "", price: 0, additionalInfo: "", addingDate: "")]
        let recentlyAddedBooksArr: [BookInfo] = self.recentlyAddedBooksArr ?? [BookInfo(title: "", author: "", publishYear: 0, genre: "", pagesCount: 0, language: "", price: 0, additionalInfo: "", addingDate: "")]
        
        // We will initialise the dataSource in the init method.
        // First section: Recommended
        let recommendedBooks: [BookInfo] = recommendedBooksArr
        let section1 = Section(id: 1, type: .singleList, title: "Recommended", subtitle: "Recommended books by owner", data: recommendedBooks)
        
        dataSource.append(section1)
        
        // Second section: This weeks favorites
        let randomBooks: [BookInfo] = randomBooksArr
        let section2 = Section(id: 2, type: .doubleList, title: "Random genre", subtitle: "Some books of random genre that changes every day", data: randomBooks)
        
        dataSource.append(section2)
        
        // Third section: Recently added
        let recentlyAdded: [BookInfo] = recentlyAddedBooksArr
        let section3 = Section(id: 3, type: .tripleList, title: "Recently added", subtitle: "Last added books by owner", data: recentlyAdded)
        
        dataSource.append(section3)
        
        return dataSource
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Checks what section type we should use for this indexPath so we use the right cells for that section
        switch presenter.sectionType(for: indexPath.section, dataSource: self.setupBooksData()) {
        case .singleList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecomendedBooksCollectionViewCell.identifier, for: indexPath) as? RecomendedBooksCollectionViewCell else {
                fatalError("Could not dequeue FeatureCell")
            }
            self.presenter.configure(item: cell, for: indexPath, dataSource: self.setupBooksData())
            return cell
            
        case .doubleList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RandomGenreCollectionViewCell.identifier, for: indexPath) as? RandomGenreCollectionViewCell else {
                fatalError("Could not dequeue MediumAppCell")
            }
            self.presenter.configure(item: cell, for: indexPath, dataSource: self.setupBooksData())
            return cell
        case .tripleList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentlyAddedBooksCollectionViewCell.identifier, for: indexPath) as? RecentlyAddedBooksCollectionViewCell else {
                fatalError("Could not dequeue SmallAppCell")
            }
            self.presenter.configure(item: cell, for: indexPath, dataSource: self.setupBooksData())
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
        if let title = presenter.title(for: indexPath.section, dataSource: self.setupBooksData()) {
            headerView.titleLabel.text = title
            headerView.titleLabel.isHidden = false
        } else {
            headerView.titleLabel.isHidden = true
        }
        
        // If the section has a subtitle show it in the Section header, otherwise hide the subtitleLabel
        if let subtitle = presenter.subtitle(for: indexPath.section, dataSource: self.setupBooksData()) {
            headerView.subtitleLabel.text = subtitle
            headerView.subtitleLabel.isHidden = false
        } else {
            headerView.subtitleLabel.isHidden = true
        }
        return headerView
    }
    
    @objc func appendingButtonTapped(_ sender: UIButton!) {
        let vc: SortedBooksInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "SortedBooksInfoViewController") as! SortedBooksInfoViewController
        
        self.firestoreManager.getBooks(email: appDelegate().currentBookstoreOwner!.email, completion: { books in
            vc.books = books.sorted { $0.title.lowercased() < $1.title.lowercased() }
            vc.prefillRecBooksArr = self.recommendedBooksArr
            vc.isAppendingRecommended = true
            vc.delegate = self
            self.present(vc, animated: true)
        })
    }
}



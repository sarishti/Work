//
//  MainFeedViewController.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 8/10/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import UIKit

class MainFeedViewController: UIViewController, NewsFeedWebserviceProtocol, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var arrayArticles: [[Article]]?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollPager: ScrollPager!

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTransparent()

        fetchArticlesAndDisplay()
        initializeView()
//        collectionView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initializeView() {
        title = "MainFeedTitle".localized
        scrollPager.addSegmentsWithTitles(["", "", ""])
    }

    //MARK: - Webservice Calls

    func fetchArticlesAndDisplay() {
        fetchArticles(withData: nil) { (obj, success) in
            print(obj)
        }
    }

    //MARK: - CollectionView delegate & data source

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        return collectionView.dequeueReusableCellWithReuseIdentifier("ArticlesCollectionViewCell", forIndexPath: indexPath)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollPager.scrollViewDidScroll(scrollView)
    }



    // MARK: - Navigation



	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == Constants.segueShowArticleDetailVC {

			// if let nextScene = segue.destinationViewController as? ArticleDetailViewController {
			//
			// }
		}
	}

	// MARK : - Outlet Methods

    @IBAction func btnArticleTapped(sender: AnyObject) {
        	self.performSegueWithIdentifier(Constants.segueShowArticleDetailVC, sender: self)
    }



}

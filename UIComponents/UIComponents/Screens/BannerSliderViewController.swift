//
//  BannerSliderViewController.swift
//  UIComponents
//
//  Created by Eser Kucuker on 21.01.2022.
//
import SwiftUI
import UIKit

class BannerSliderViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var currentPage: Double = 0.0
    
    let pageCount = 5
    var timer = Timer()
    var counter = 0
 
    var offSet: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        
        pageControl.numberOfPages = pageCount
        pageControl.addTarget(self, action: #selector(pageControlDidChange), for: .valueChanged)
        
        configureScrollView() // Programmatically UIScrollView
        scrollView.contentSize.height = 1.0
        scrollView.showsHorizontalScrollIndicator = false
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(autoScroll),userInfo: nil, repeats: true)
    }
    
    
    @objc func autoScroll() {
           let totalPossibleOffset = CGFloat(pageCount - 1) * self.view.bounds.size.width
           if offSet == totalPossibleOffset {
               offSet = 0 // come back to the first image after the last image
           }
           else {
               offSet += self.view.bounds.size.width
           }
           DispatchQueue.main.async() {
               UIView.animate(withDuration: 0.0, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                   self.scrollView.contentOffset.x = CGFloat(self.offSet)
               }, completion: nil)
           }
       }
    
    @IBAction func pageControlDidChange(_ sender: UIPageControl) { // Made uiscrollView scroll when pagecontrol is changed.
        let current = sender.currentPage
        scrollView.setContentOffset(CGPoint(x: CGFloat(current) * view.frame.size.width, y: 0), animated: true)
        
    }
  
    private func configureScrollView(){
        
        scrollView.contentSize = CGSize(width: view.frame.size.width * CGFloat(pageCount), height: view.frame.size.height)
        
        scrollView.isPagingEnabled = true
        
        for index in 0..<pageCount{ //add content to scrollView.
            let page = UIView(frame: CGRect(x: CGFloat(index) * view.frame.size.width, y: 0, width: view.frame.size.width, height: scrollView.frame.size.height))
            page.backgroundColor = .random
            scrollView.addSubview(page)
        }
    }
    
}

extension BannerSliderViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { //change pagecontrol when scrollview did scroll
        currentPage = Double(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(currentPage)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if currentPage <= 0.0 && velocity.x < 0 { //scrollview slide head to end.
            targetContentOffset[0].x = CGFloat(4) * view.frame.size.width //change target point
        }
        if currentPage >= 4.0 && velocity.x > 0{ //scrollview slide end to head.
            targetContentOffset[0].x = CGFloat(0) * view.frame.size.width
        }
    }
}
extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }
}

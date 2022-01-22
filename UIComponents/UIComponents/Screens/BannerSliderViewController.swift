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
    var timer : Timer? = nil {
           willSet {
               timer?.invalidate()
           }
       }
    var counter = 0
 
    var offSet: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        
        pageControl.numberOfPages = pageCount
        pageControl.addTarget(self, action: #selector(pageControlDidChange), for: .valueChanged)
        
        configureScrollView()
        scrollView.contentSize.height = 1.0
        scrollView.showsHorizontalScrollIndicator = false
        timer = setTimer()
    }
    
    
    @objc func autoScroll() {
           let totalPossibleOffset = CGFloat(pageCount - 1) * self.view.bounds.size.width
           if offSet == totalPossibleOffset {
               offSet = 0
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
    
    @IBAction func pageControlDidChange(_ sender: UIPageControl) {
        stopTimer()
        let current = sender.currentPage
        scrollView.setContentOffset(CGPoint(x: CGFloat(current) * view.frame.size.width, y: 0), animated: true)
        startTimer()
    }
    
    private func startTimer() {
        stopTimer()
        guard self.timer == nil else { return }
        self.timer = setTimer()
    }

    private func stopTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
    }
    
    private func setTimer()-> Timer {
        let time = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.autoScroll), userInfo: nil, repeats: true)
        return time
    }
  
    private func configureScrollView(){
        
        scrollView.contentSize = CGSize(width: view.frame.size.width * CGFloat(pageCount), height: view.frame.size.height)
        
        scrollView.isPagingEnabled = true
        
        for index in 0..<pageCount{
            let page = UIView(frame: CGRect(x: CGFloat(index) * view.frame.size.width, y: 0, width: view.frame.size.width, height: scrollView.frame.size.height))
            page.backgroundColor = .random
            scrollView.addSubview(page)
        }
    }
    
}

extension BannerSliderViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { 
        currentPage = Double(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(currentPage)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        stopTimer()
        if currentPage <= 0.0 && velocity.x < 0 { //scrollview slide head to end.
            targetContentOffset[0].x = CGFloat(4) * view.frame.size.width //change target point
        }
        if currentPage >= 4.0 && velocity.x > 0{ //scrollview slide end to head.
            targetContentOffset[0].x = CGFloat(0) * view.frame.size.width
        }
        startTimer()
    }
}
extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }
}



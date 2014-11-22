//
//  ViewController.swift
//  Stormy
//
//  Created by Luke Lu on 9/21/14.
//  Copyright (c) 2014 Lusketeer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var refreshActivityIndicatior: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    private let apiKey = "416e966358e7e35e19caa49d6822c35f"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshActivityIndicatior.hidden = true
        getCurrentWeatherData()

        
    }
    
    func getCurrentWeatherData() -> Void {
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: "37.5196173,-122.2691473", relativeToURL: baseURL)
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL, completionHandler: {
            (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            if error == nil {
                let dataObject = NSData(contentsOfURL: location)
                let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject, options: nil, error: nil) as NSDictionary
                let currentWeather = Current(weatherDictionary: weatherDictionary)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.temperatureLabel.text = "\(currentWeather.temperature)"
                    self.iconView.image = currentWeather.icon!
                    self.currentTimeLabel.text = "@\(currentWeather.currentTime!)"
                    self.humidityLabel.text = "\(currentWeather.humidity)"
                    self.precipitationLabel.text = "\(currentWeather.precipProbability)"
                    self.summaryLabel.text = "\(currentWeather.summary)"
                    
                    // Stop refresh animation
                    self.refreshActivityIndicatior.stopAnimating()
                    self.refreshActivityIndicatior.hidden = true
                    self.refreshButton.hidden = false
                })
            } else {
                let networkIssueController = UIAlertController(title: "Error", message: "Unable to load data. Connectivity error", preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                networkIssueController.addAction(okButton)
                
                let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                networkIssueController.addAction(cancelButton)
                
                self.presentViewController(networkIssueController, animated: true, completion: nil)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Stop refresh animation
                    self.refreshActivityIndicatior.stopAnimating()
                    self.refreshActivityIndicatior.hidden = true
                    self.refreshButton.hidden = false
                })
            }
        })
        downloadTask.resume()

    }
    
    @IBAction func refresh() {
        getCurrentWeatherData()
        refreshButton.hidden = true
        refreshActivityIndicatior.hidden = false
        refreshActivityIndicatior.startAnimating()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


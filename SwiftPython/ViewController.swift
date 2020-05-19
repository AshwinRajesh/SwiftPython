//
//  ViewController.swift
//  SwiftPython
//
//  Created by Ashwin Rajesh on 4/27/20.
//  Copyright © 2020 AshwinR. All rights reserved.
//


import UIKit
import Foundation
import Swift

class ViewController: UIViewController {

    let rest = RestManager()
    
    @IBOutlet weak var bookData: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment any method you would like to test.
        // Results are printed on the console.
        
        // getNonExistingUser()
        //createUser()
        getBookList()
        //getSingleUser()
    }
    
    
    
    func getBookList() {
        guard let url = URL(string: "http://127.0.0.1:5000/api/v1/resources/multiply?num1=3&num2=4") else { return }
        
        // The following will make RestManager create the following URL:
        // https://reqres.in/api/users?page=2
        // rest.urlQueryParameters.add(value: "2", forKey: "page")
        
        rest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            if let data = results.data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let test: Data? = """
                {"books": [{"author": "Vernor Vinge","first_sentence": "The coldsleep itself was dreamless.","id": 0,"title": "A Fire Upon the Deep"},{"author": "Ursula K. LeGuin","first_sentence": "With a clamor of bells that set the swallows soaring, the Festival of Summer came to the city Omelas, bright-towered by the sea.","id": 1,"title": "The Ones Who Walk Away From Omelas"},{"author": "Samuel R. Delany","first_sentence": "to wound the autumnal city.","id": 2,"title": "Dhalgren"}],"length": 3}
                """.data(using: .utf8)
                let test2: Data? = """
                {
                    "page":1,
                    "per_page":6,
                    "total":12,
                    "total_pages":2,
                    "data": [
                      {
                        "id":1,
                        "email":"george.bluth@reqres.in",
                        "first_name":"George",
                        "last_name":"Bluth",
                        "avatar":"https://s3.amazonaws.com/uifaces/faces/twitter/calebogden/128.jpg"
                      }
                    ]
                }
                """.data(using: .utf8)
                let test3: Data? = """
                {"page":1,"per_page":6,"total":12,"total_pages":2,"data":[{"id":1,"email":"george.bluth@reqres.in","first_name":"George","last_name":"Bluth","avatar":"https://s3.amazonaws.com/uifaces/faces/twitter/calebogden/128.jpg"},{"id":2,"email":"janet.weaver@reqres.in","first_name":"Janet","last_name":"Weaver","avatar":"https://s3.amazonaws.com/uifaces/faces/twitter/josephstein/128.jpg"},{"id":3,"email":"emma.wong@reqres.in","first_name":"Emma","last_name":"Wong","avatar":"https://s3.amazonaws.com/uifaces/faces/twitter/olegpogodaev/128.jpg"},{"id":4,"email":"eve.holt@reqres.in","first_name":"Eve","last_name":"Holt","avatar":"https://s3.amazonaws.com/uifaces/faces/twitter/marcoramires/128.jpg"},{"id":5,"email":"charles.morris@reqres.in","first_name":"Charles","last_name":"Morris","avatar":"https://s3.amazonaws.com/uifaces/faces/twitter/stephenmoon/128.jpg"},{"id":6,"email":"tracey.ramos@reqres.in","first_name":"Tracey","last_name":"Ramos","avatar":"https://s3.amazonaws.com/uifaces/faces/twitter/bigmancho/128.jpg"}],"ad":{"company":"StatusCode Weekly","url":"http://statuscode.org/","text":"A weekly newsletter focusing on software development, infrastructure, the server, performance, and the stack end of things."}}
                """.data(using: .utf8)
                guard let userData = try? decoder.decode(Multiply.self, from: data) else { return }
                DispatchQueue.main.async {
                    self.bookData.text = String(userData.result!)
                }
            }
            
            print("\n\nResponse HTTP Headers:\n")
            
            if let response = results.response {
                for (key, value) in response.headers.allValues() {
                    print(key, value)
                }
            }
        }
    }
    
    
    func getNonExistingUser() {
        guard let url = URL(string: "https://reqres.in/api/users/100") else { return }
        
        rest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            if let _ = results.data, let response = results.response {
                if response.httpStatusCode != 200 {
                    print("\nRequest failed with HTTP status code", response.httpStatusCode, "\n")
                }
            }
        }
    }
    
    
    
    func createUser() {
        guard let url = URL(string: "https://reqres.in/api/users") else { return }
        
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
        rest.httpBodyParameters.add(value: "John", forKey: "name")
        rest.httpBodyParameters.add(value: "Developer", forKey: "job")
        
        rest.makeRequest(toURL: url, withHttpMethod: .post) { (results) in
            guard let response = results.response else { return }
            if response.httpStatusCode == 201 {
                guard let data = results.data else { return }
                let decoder = JSONDecoder()
                guard let jobUser = try? decoder.decode(JobUser.self, from: data) else { return }
                print(jobUser.description)
            }
        }
    }
    
    
    
    func getSingleUser() {
        guard let url = URL(string: "https://reqres.in/api/users/1") else { return }
        
        rest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            if let data = results.data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard let singleUserData = try? decoder.decode(SingleUserData.self, from: data),
                    let user = singleUserData.data,
                    let avatar = user.avatar,
                    let url = URL(string: avatar) else { return }
                
                self.rest.getData(fromURL: url, completion: { (avatarData) in
                    guard let avatarData = avatarData else { return }
                    let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                    let saveURL = cachesDirectory.appendingPathComponent("avatar.jpg")
                    try? avatarData.write(to: saveURL)
                    print("\nSaved Avatar URL:\n\(saveURL)\n")
                })
                
            }
        }
    }


}


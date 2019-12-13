//
//  ViewController.swift
//  Project5
//
//  Created by appinventiv on 01/12/19.
//  Copyright © 2019 a. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(startAgain))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords.append("silkworm")
        }
        
        startGame()
    }
    
    @objc func startAgain() {
        usedWords.removeAll(keepingCapacity: true)

        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords.append("silkworm")
        }

        title = allWords.randomElement()
              allWords.removeAll(keepingCapacity: true)
              tableView.reloadData()
        
    }
    
    func startGame() {
        
        title = allWords.randomElement()
        allWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }


}

extension ViewController {
    
    @objc func promptForAnswer() {
        
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true, completion: nil)
    }
    
    func submit(_ answer: String) {
        
        let lowerAns = answer.lowercased()
        
        if isPossible(word: lowerAns) {
            if isOriginal(word: lowerAns) {
                if isReal(word: lowerAns) {
                    usedWords.insert(answer.lowercased(), at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                } else {
                    showErrorMessage(title: "Word not recognized", msg: "You can't just make them up you know!")
                }
            } else {
                showErrorMessage(title: "Word already Used", msg: "Be more original!")
            }
        } else {
            showErrorMessage(title: "Word not possible", msg: "You cannot spell that word from \(title?.lowercased() ?? "")")
        }
        
               
    }
    
    func showErrorMessage(title errorTitle: String, msg errorMsg: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: .alert)
               let okAction = UIAlertAction(title: "OK", style: .default)
               ac.addAction(okAction)
               present(ac, animated: true, completion: nil)
    }
    
    func isPossible(word: String) -> Bool {
        
        guard var tempWord = title?.lowercased() else { return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            }
            else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        
        if word.count < 3 || word == title {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledrange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        
        return misspelledrange.location == NSNotFound
    }
}


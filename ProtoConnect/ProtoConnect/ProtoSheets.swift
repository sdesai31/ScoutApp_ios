//
//  ProtoSheets.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 3/24/24.
//

import Foundation

struct ProtoSheets {
    
    static let sheetID = "1kQ2fhadKcKZUZJ7NF9JNsHLgsa1BA7aZa3FT94kjTyo"
    
    
    static func generateRefreshToken(completion: @escaping ((String?) -> ())) {
        // Fixme - SD changed here to avoid push security error
        // let parameters = "client_id=732669493855"
        let parameters = "temp" //"client_id=732669493855-3fgtbnubtnk35n62sjtboed4sk14erhh.apps.googleusercontent.com&refresh_token=1%2F%2F06JwEdwYddtR2CgYIARAAGAYSNwF-L9IrqSHpnyVaP_k7bU2bAQ0WrWEevu44sn1TprgQ86G3MJF3LOYXXhP6uHuvEqDcXvpqps0%0A&grant_type=refresh_token"


        let postData =  parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!,timeoutInterval: Double.infinity)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                guard let data = data else {
                    print(String(describing: error))
                    completion(nil)
                    
                    return
                }
                guard let dataJSON = try JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                    completion(nil)
                    return
                }
                
                guard let dataBearerToken = dataJSON["access_token"] as? String else {
                    completion(nil)
                    return
                }
                completion(dataBearerToken)
            }
            catch {
                completion(nil)
            }
        }
        
        task.resume()
        
    }
    static func checkAvailableRowProtoSheet(bearerToken: String, teamNumber: String, matchNumber: String, completion: @escaping ((Int) -> ())) {
        
        var request = URLRequest(url: URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(sheetID)/values/\(teamNumber)!A1:Z1000/?majorDimension=COLUMNS")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                guard let data = data else {
                    print(String(describing: error))
                    return
                }
                guard let dataJSON = try JSONSerialization.jsonObject(with: data) as? [String:Any] else { return }
                print(dataJSON)
                guard let dataJSONValues = dataJSON["values"] as? [[String]] else { return }
                if (dataJSONValues.count > 0) {
                    var teamRow = dataJSONValues[0].firstIndex(of: matchNumber) ?? -1
                    
                    completion(teamRow)
                    
                }
                else {
                    completion(-1)
                }
                print(dataJSONValues)
            }
            catch {
                
                print(error)
                completion(0)
            }
        }.resume()
        
        
    }
    
    
    static func generateScoutingTeam(competitionKey: String) {
        generateRefreshToken { bearerToken in
            if let dataBearerToken = bearerToken {
                ProtoFirebase.getProtoUsers { users in
                    var userIndex = 0
                    var arrayCompetition = [String]()

                    ProtoLookup.teamCompetitionMatches(competitionKey: competitionKey) { allProtoMatches in
                        for matchInfo in allProtoMatches {
                            if let blueAlliance = ((matchInfo["alliances"] as? [String:Any])?["blue"] as? [String:Any])?["team_keys"] as? [String], let redAlliance = ((matchInfo["alliances"] as? [String:Any])?["red"] as? [String:Any])?["team_keys"] as? [String], let matchNumber = (((matchInfo["match_number"])) as? Int) {
                                
                                for oneTeam in redAlliance + blueAlliance {
                                    if (userIndex >= users.count) {
                                        userIndex = 0
                                    }
                                    arrayCompetition.append(users[userIndex].id + " " + oneTeam + " Match" + String(matchNumber))
                                    userIndex += 1
                                }
                                
                             

                                
                            }
                            
                        }
                        
                        print(arrayCompetition)
                        setScoutingTeamAssignments(scoutingTeams: arrayCompetition)
                        
                    }
                    
                }
            }
        }
    }
    
    static func getTeamScoutingAssignments(completion: @escaping (([String]) -> ())) {
        generateRefreshToken { bearerToken in
            if let dataBearerToken = bearerToken {
                
                    var request = URLRequest(url: URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(sheetID)/values/SCOUTING_ASSIGNMENTS!A1:Z1000/?majorDimension=ROWS")!,timeoutInterval: Double.infinity)
                    request.addValue("Bearer \(dataBearerToken)", forHTTPHeaderField: "Authorization")
                    
                    request.httpMethod = "GET"
                    
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        do {
                            guard let data = data else {
                                print(String(describing: error))
                                return
                            }
                            guard let dataJSON = try JSONSerialization.jsonObject(with: data) as? [String:Any] else { return }
                            print(dataJSON)
                            guard var dataJSONValues = dataJSON["values"] as? [[String]] else { return }
                                guard let currentID = ProtoFirebase.currentProtoUser?.id else { return }
                            let newJSONVals = dataJSONValues.map { oneArray in
                                return oneArray.first ?? "Error"
                            }
                                let allRowData = newJSONVals.filter { oneString in
                                    return oneString.contains(currentID)
                                }
                                
                                completion(allRowData)
                                
                                
                            
                            print(dataJSONValues)
                        }
                        catch {
                            print(error)
                            completion([])
                        }
                    }.resume()
                }
            
        }
    }
    static func getRowTeamNumberData(matchNumber: String, teamNumber: String, completion: @escaping (([String:Any]) -> ())) {
        generateRefreshToken { bearerToken in
            if let dataBearerToken = bearerToken {
                
                checkAvailableRowProtoSheet(bearerToken: dataBearerToken, teamNumber: teamNumber, matchNumber: matchNumber) { teamRowNumber in
                    
                    if (teamRowNumber == -1) {
                        completion([:])
                        return
                    }
                    var request = URLRequest(url: URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(sheetID)/values/\(teamNumber)!A1:Z1000/?majorDimension=ROWS")!,timeoutInterval: Double.infinity)
                    request.addValue("Bearer \(dataBearerToken)", forHTTPHeaderField: "Authorization")
                    
                    request.httpMethod = "GET"
                    
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        do {
                            guard let data = data else {
                                print(String(describing: error))
                                return
                            }
                            guard let dataJSON = try JSONSerialization.jsonObject(with: data) as? [String:Any] else { return }
                            print(dataJSON)
                            guard let dataJSONValues = dataJSON["values"] as? [[String]] else { return }
                            if (dataJSONValues.count > 0) {
                                let allRowData = dataJSONValues[teamRowNumber]
                                if allRowData.count == 16 {
                                    let matchNumber = allRowData[0]
                                    let penalties = Double(allRowData[1]) ?? 0
                                    let autoSpeakerAtp = Double(allRowData[2]) ?? 0
                                    let autoSpeakerMade = Double(allRowData[3]) ?? 0
                                    let autoAmpAtp = Double(allRowData[4]) ?? 0
                                    let autoAmpMade = Double(allRowData[5]) ?? 0
                                    let teleopSpeakerAtp = Double(allRowData[6]) ?? 0
                                    let teleopSpeakerMade = Double(allRowData[7]) ?? 0
                                    let teleopAmpAtp = Double(allRowData[8]) ?? 0
                                    let teleopAmpMade = Double(allRowData[9]) ?? 0
                                    let teleopDefensiveRating = Double(allRowData[10]) ?? 0
                                    let hang = allRowData[11].lowercased() == "true"
                                    let trapScore = allRowData[12].lowercased() == "true"
                                    let amplify = allRowData[13].lowercased() == "true"
                                    let harmony = allRowData[14].lowercased() == "true"
                                    let coopertition = allRowData[15].lowercased() == "true"
                                    
                                    completion([
                                        "matchNumber": matchNumber,
                                        "penalties": penalties,
                                        "autoSpeakerAtp": autoSpeakerAtp,
                                        "autoSpeakerMade": autoSpeakerMade,
                                        "autoAmpAtp": autoAmpAtp,
                                        "autoAmpMade": autoAmpMade,
                                        "teleopSpeakerAtp": teleopSpeakerAtp,
                                        "teleopSpeakerMade": teleopSpeakerMade,
                                        "teleopAmpAtp": teleopAmpAtp,
                                        "teleopAmpMade": teleopAmpMade,
                                        "teleopDefensiveRating": teleopDefensiveRating,
                                        "hang": hang,
                                        "trapScore": trapScore,
                                        "amplify": amplify,
                                        "harmony": harmony,
                                        "coopertition": coopertition
                                    ])
                                }
                                
                            }
                            print(dataJSONValues)
                        }
                        catch {
                            print(error)
                            completion([:])
                        }
                    }.resume()
                }
            }
        }
    }
    
    static func setRowTeamNumberData(data: Any, column: String, matchNumber: String, teamNumber: String) {
        generateRefreshToken { bearerToken in
            if let dataBearerToken = bearerToken {
                
                checkAvailableRowProtoSheet(bearerToken: dataBearerToken, teamNumber: teamNumber, matchNumber: matchNumber) { teamRowNumber in
                    if (teamRowNumber == -1) {
                        return
                    }
                    let parameters = "{\n    \"range\": \"\(teamNumber)!\(column)\(teamRowNumber+1):\(column)\(teamRowNumber+1)\",\n    \"majorDimension\": \"ROWS\",\n    \"values\": [\n      [\"\(data)\"]\n    ]\n  }"
                    let postData = parameters.data(using: .utf8)

                    var request = URLRequest(url: URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(sheetID)/values/\(teamNumber)!\(column)\(teamRowNumber+1):\(column)\(teamRowNumber+1)?valueInputOption=USER_ENTERED&includeValuesInResponse=false")!,timeoutInterval: Double.infinity)
                    request.addValue("Bearer \(dataBearerToken)", forHTTPHeaderField: "Authorization")
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                    request.httpMethod = "PUT"
                    request.httpBody = postData

                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                      guard let data = data else {
                        print(String(describing: error))
                        return
                      }
                      print(String(data: data, encoding: .utf8)!)
                    }

                    task.resume()

                }
            }
        }
    }
    static func setRowDataTeamNumber(data: [String], matchNumber: String, teamNumber: String) {
        generateRefreshToken { bearerToken in
            if let dataBearerToken = bearerToken {
                
                checkAvailableRowProtoSheet(bearerToken: dataBearerToken, teamNumber: teamNumber, matchNumber: matchNumber) { teamRowNumber in
                    if (teamRowNumber == -1) {
                        return
                    }
                    let parameters = "{\n    \"range\": \"\(teamNumber)!A\(teamRowNumber+1):P\(teamRowNumber+1)\",\n    \"majorDimension\": \"ROWS\",\n    \"values\": [\n      \(data)\n    ]\n  }"
                    let postData = parameters.data(using: .utf8)

                    var request = URLRequest(url: URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(sheetID)/values/\(teamNumber)!A\(teamRowNumber+1):P\(teamRowNumber+1)?valueInputOption=USER_ENTERED&includeValuesInResponse=false")!,timeoutInterval: Double.infinity)
                    request.addValue("Bearer \(dataBearerToken)", forHTTPHeaderField: "Authorization")
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                    request.httpMethod = "PUT"
                    request.httpBody = postData

                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                      guard let data = data else {
                        print(String(describing: error))
                        return
                      }
                      print(String(data: data, encoding: .utf8)!)
                    }

                    task.resume()

                }
            }
        }
    }
    static func setScoutingTeamAssignments(scoutingTeams: [String]) {
        generateRefreshToken { bearerToken in
            if let dataBearerToken = bearerToken {
                
                let parameters = "{\n    \"range\": \"SCOUTING_ASSIGNMENTS!A1\",\n    \"majorDimension\": \"COLUMNS\",\n    \"values\": [\n      " + "\(scoutingTeams)" + "   ]\n  }"
                let postData = parameters.data(using: .utf8)
                
                var request = URLRequest(url: URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(sheetID)/values/SCOUTING_ASSIGNMENTS!A1?valueInputOption=USER_ENTERED&includeValuesInResponse=false")!,timeoutInterval: Double.infinity)
                request.addValue("Bearer \(dataBearerToken)", forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                request.httpMethod = "PUT"
                request.httpBody = postData
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data else {
                        print(String(describing: error))
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                }
                
                task.resume()
                
            }
        }
        
    }
}

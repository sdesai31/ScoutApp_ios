//
//  ProtoLookup.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 3/25/23.
//

import Foundation


struct ProtoLookup {
    
    static var teamCompetitionsInfo: [[String:Any]] = []
    static var specificCompProtoMatches: [[String:Any]] = []
    
    static func teamLookup(teamNumber: String, completion: @escaping ([String:Any]) -> ()) {
        
        guard let teamURL = URL(string: "https://www.thebluealliance.com/api/v3/team/frc\(teamNumber)") else {
            
            completion([:])
            return
            
        }
        
        var teamURLReq = URLRequest(url: teamURL)
        
        teamURLReq.addValue("application/json", forHTTPHeaderField: "accept")
        teamURLReq.addValue("o1EnriHJtUA2ubAnQOM5p83dQUjK83eFEp1y1qjA3i1FhZwun8AFuWgHXDZbe9tc", forHTTPHeaderField: "X-TBA-Auth-Key")
        
        URLSession.shared.dataTask(with: teamURLReq) { teamURLData, teamURLResponse, teamURLError in
            if (teamURLError == nil) {
                guard let teamURLData = teamURLData else {
                    completion([:])
                    
                    return
                    
                }
                
                do {
                    guard let teamObject = try JSONSerialization.jsonObject(with: teamURLData) as? [String:Any] else {
                        completion([:])
                        
                        return
                        
                    }
                    if (teamObject["Error"] != nil) {
                        completion([:])
                    }
                    else {
                        completion(teamObject)
                    }
                }
                catch {
                    completion([:])
                    
                    print("ERROR")
                }
            }
            else {
                completion([:])
            }
        }.resume()
    }
    static func teamCompetitionKey(completion: @escaping (Bool) -> ()) {
        
        guard let teamURL = URL(string: "https://www.thebluealliance.com/api/v3/team/frc\(ProtoFirebase.currentProtoUser?.teamNum ?? "-1")/events/2024/keys") else {
            
            completion(false)
            return
            
        }
        let protoLocationInputDateFormatter: DateFormatter = {
            let tempDateOutputFormatter = DateFormatter()
            tempDateOutputFormatter.dateFormat = "yyyy-MM-dd"
            
            return tempDateOutputFormatter
        }()
        
        var teamURLReq = URLRequest(url: teamURL)
        
        teamURLReq.addValue("application/json", forHTTPHeaderField: "accept")
        teamURLReq.addValue("o1EnriHJtUA2ubAnQOM5p83dQUjK83eFEp1y1qjA3i1FhZwun8AFuWgHXDZbe9tc", forHTTPHeaderField: "X-TBA-Auth-Key")
        
        URLSession.shared.dataTask(with: teamURLReq) { teamURLData, teamURLResponse, teamURLError in
            if (teamURLError == nil) {
                guard let teamURLData = teamURLData else {
                    completion(false)
                    
                    return
                    
                }
                
                do {
                    guard let teamObject = try JSONSerialization.jsonObject(with: teamURLData) as? [String] else {
                        completion(false)
                        
                        return
                        
                    }
                    
                    
                    var i = 0
                    for eachTeamEventKey in teamObject {
                        teamCompetitionData(competitionKey: eachTeamEventKey) { oneTeamEventObject in
                            teamCompetitionsInfo.append(oneTeamEventObject)
                            i += 1
                            if (i >= teamObject.count) {
                                if teamCompetitionsInfo.count > 1 {
                                    teamCompetitionsInfo.sort { oneEventDict, twoEventDict in
                                        if let oneTeamNameCompetitionLocationStartDate = oneEventDict.keys.firstIndex(of: "start_date"), let oneTeamCompetitionStartDateValue = oneEventDict.values[oneTeamNameCompetitionLocationStartDate] as? String, let twoTeamNameCompetitionLocationStartDate = twoEventDict.keys.firstIndex(of: "start_date"), let twoTeamCompetitionStartDateValue = twoEventDict.values[twoTeamNameCompetitionLocationStartDate] as? String {
                                            if let oneTempDateStart = protoLocationInputDateFormatter.date(from: oneTeamCompetitionStartDateValue), let twoTempDateStart = protoLocationInputDateFormatter.date(from: twoTeamCompetitionStartDateValue) {
                                                if (oneTempDateStart > twoTempDateStart) {
                                                    return true
                                                }
                                                else {
                                                    return false
                                                    
                                                }
                                            }
                                            else {
                                                return false
                                                
                                            }
                                        }
                                        else {
                                            return false
                                        }
                                    }
                                }
                                
                                completion(true)
                            }
                            
                        }
                        
                    }
                    
                }
                catch {
                    completion(false)
                    
                    print("ERROR")
                }
            }
            else {
                completion(false)
            }
        }.resume()
    }
    static func teamCompetitionData(competitionKey: String, completion: @escaping ([String:Any]) -> ()) {
        
        guard let teamURL = URL(string: "https://www.thebluealliance.com/api/v3/event/\(competitionKey)") else {
            
            completion([:])
            return
            
        }
        
        var teamURLReq = URLRequest(url: teamURL)
        
        teamURLReq.addValue("application/json", forHTTPHeaderField: "accept")
        teamURLReq.addValue("o1EnriHJtUA2ubAnQOM5p83dQUjK83eFEp1y1qjA3i1FhZwun8AFuWgHXDZbe9tc", forHTTPHeaderField: "X-TBA-Auth-Key")
        
        URLSession.shared.dataTask(with: teamURLReq) { teamURLData, teamURLResponse, teamURLError in
            if (teamURLError == nil) {
                guard let teamURLData = teamURLData else {
                    completion([:])
                    
                    return
                    
                }
                
                do {
                    guard let teamObject = try JSONSerialization.jsonObject(with: teamURLData) as? [String:Any] else {
                        completion([:])
                        
                        return
                        
                    }
                    if (teamObject["Error"] != nil) {
                        completion([:])
                    }
                    else {
                        completion(teamObject)
                    }
                }
                catch {
                    completion([:])
                    
                    print("ERROR")
                }
            }
            else {
                completion([:])
            }
        }.resume()
    }
    
    static func teamCompetitionMatches(competitionKey: String, completion: @escaping ([[String:Any]]) -> ()) {
        
        guard let teamURL = URL(string: "https://www.thebluealliance.com/api/v3/event/2024\(competitionKey)/matches") else {
            
            completion([])
            return
            
        }
        
        var teamURLReq = URLRequest(url: teamURL)
        
        teamURLReq.addValue("application/json", forHTTPHeaderField: "accept")
        teamURLReq.addValue("o1EnriHJtUA2ubAnQOM5p83dQUjK83eFEp1y1qjA3i1FhZwun8AFuWgHXDZbe9tc", forHTTPHeaderField: "X-TBA-Auth-Key")
        
        URLSession.shared.dataTask(with: teamURLReq) { teamURLData, teamURLResponse, teamURLError in
            if (teamURLError == nil) {
                guard let teamURLData = teamURLData else {
                    completion([])

                    return

                }
                
                do {
                    guard var teamObject = try JSONSerialization.jsonObject(with: teamURLData) as? [[String:Any]] else {
                        completion([])

                        return
                        
                    }
                    
                    // Gets only qualification matches
                    teamObject.removeAll { oneTeamMatch in
                        return !(oneTeamMatch["key"] as? String ?? "").contains("\(competitionKey)_qm")
                    }
                    if (teamObject.count > 1) {
                        teamObject.sort { oneTeamMatch, twoTeamMatch in
                            guard let oneTeamNumber = oneTeamMatch["match_number"] as? Int else { return false }
                            guard let twoTeamNumber = twoTeamMatch["match_number"] as? Int else { return false }
                            return oneTeamNumber < twoTeamNumber
                        }
                    }
                    
                    specificCompProtoMatches = teamObject
                    completion(teamObject)
                   
                }
                catch {
                    completion([])

                print("ERROR")
                }
            }
            else {
                completion([])
            }
        }.resume()
    }
    
    
}

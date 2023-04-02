//
//  ProtoFirebase.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 3/25/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ProtoFirebase {
    
    
    
    // User property is stored in user
    struct ProtoUser: Codable, Identifiable {
        
        var id: String
        var firstName: String
        var lastName: String
        var email: String
        var teamNum: String
        var teamID: String
        var teamCode: String
        
    }
    
    static var currentProtoUser: ProtoUser? = nil {
        didSet {
            do {
                if currentProtoUser != nil {
                    let currentUserEncoder = try JSONEncoder().encode(currentProtoUser)
                    UserDefaults.standard.removeObject(forKey: "user")
                    UserDefaults.standard.set(try JSONSerialization.jsonObject(with: currentUserEncoder, options: .fragmentsAllowed), forKey: "user")
                }
                else {
                    UserDefaults.standard.removeObject(forKey: "user")

                }
                
            }
            catch {
                print("ERROR")
            }
        }
    }
    
    
    private static var userCollection = Firestore.firestore().collection("users")
    public static var teamCollection = Firestore.firestore().collection("teams")
    
    static func checkProtoUserExists(email: String, completion: @escaping (Bool) -> ()) {
        
        userCollection.whereField("email", isEqualTo: email).getDocuments { docs, error in
            if (error == nil) {
                guard let protoDocs = docs else {
                    completion(false)
                    return
                }
                if !(protoDocs.isEmpty) {
                    
                    guard let protoDocsData = protoDocs.documents.first?.data() else {
                        completion(false)
                        return
                    }
                    let protoID = protoDocsData["id"] as? String ?? "ERROR"
                    let protoFirst = protoDocsData["firstName"] as? String ?? "ERROR"
                    let protoLast = protoDocsData["lastName"] as? String ?? "ERROR"
                    let protoEmail = protoDocsData["email"] as? String ?? "ERROR"
                    let protoTeamNum = protoDocsData["teamNum"] as? String ?? "-1"
                    let protoTeamID = protoDocsData["teamID"] as? String ?? "-1"
                    let protoTeamCode = protoDocsData["teamCode"] as? String ?? "-1"

                    currentProtoUser = ProtoUser(id: protoID, firstName: protoFirst, lastName: protoLast, email: protoEmail, teamNum: protoTeamNum, teamID: protoTeamID, teamCode: protoTeamCode)
                    
                    
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
            else {
                completion(false)
            }
        }
    }
    
    static func retrieveSignedInProtoUser() -> Bool {
        
        guard let protoUserDict = UserDefaults.standard.object(forKey: "user") as? [String:Any] else { return false }
        
        let protoID = protoUserDict["id"] as? String ?? "ERROR"
        let protoFirst = protoUserDict["firstName"] as? String ?? "ERROR"
        let protoLast = protoUserDict["lastName"] as? String ?? "ERROR"
        let protoEmail = protoUserDict["email"] as? String ?? "ERROR"
        let protoTeamNum = protoUserDict["teamNum"] as? String ?? "-1"
        let protoTeamID = protoUserDict["teamID"] as? String ?? "-1"
        let protoTeamCode = protoUserDict["teamCode"] as? String ?? "-1"

        currentProtoUser = ProtoUser(id: protoID, firstName: protoFirst, lastName: protoLast, email: protoEmail, teamNum: protoTeamNum, teamID: protoTeamID, teamCode: protoTeamCode)
        
        return true
    }
    
    static func createProtoUser(firstName: String, lastName: String, email: String, teamNum: String, teamID: String, teamCode: String, completion: @escaping (Bool) -> ()) {
        currentProtoUser = ProtoUser(id: UUID().uuidString, firstName: firstName, lastName: lastName, email: email, teamNum: teamNum, teamID: teamID, teamCode: teamCode)
        do {
            try userCollection.document(email).setData(from: currentProtoUser) { didError in
                if (didError == nil) {
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
        }
        catch {
            print("ERROR")
            completion(false)
        }
    }
    
    
    static func addTeamNum(teamNum: String, teamDetails: [String:Any], completion: @escaping (Bool) -> ()) {
        
        
        guard let currentProtoUserEmail = currentProtoUser?.email else {
            completion(false)
            return
            
        }
        let teamCode = String(Int.random(in: 100000..<999999))
        let teamID = UUID().uuidString
        createProtoTeam(teamNum: teamNum, teamID: teamID, teamCode: teamCode, teamDetails: teamDetails, completion: { protoTeam in
            
            if (protoTeam) {
                currentProtoUser?.teamNum = teamNum
                currentProtoUser?.teamID = teamID
                currentProtoUser?.teamCode = teamCode
                userCollection.document(currentProtoUserEmail).updateData(["teamNum": teamNum, "teamID": teamID, "teamCode": teamCode])
                
                completion(true)
                
            }
            else {
                completion(false)
                
            }
        })
        
        
    }
    static func removeTeamNum() {
        
        
        guard let currentProtoUserEmail = currentProtoUser?.email else {
            return
            
        }
     
  
                currentProtoUser?.teamNum = "-1"
                currentProtoUser?.teamID = "-1"
                currentProtoUser?.teamCode = "-1"
                userCollection.document(currentProtoUserEmail).updateData(["teamNum": -1, "teamID": "-1", "teamCode": -1])
                
          
        
        
    }
    static func signOutUser() {
        currentProtoUser = nil
        
        
    }
    
    static func uploadCompetitionKeyMatch(playType: String, regionalKey: String, matchKey: String, teamNum: String, dataKey: String, dataValue: String) {
        guard let teamNumber = currentProtoUser?.teamID else { return  }
        Firestore.firestore().runTransaction { oneTransaction, oneError in
            if oneError?.pointee == nil {
                
                let oneTransactionDoc = teamCollection.document("\(teamNumber)").collection(regionalKey).document(matchKey).collection(teamNum).document(playType)
                do {
                    let oneDocSnap = try oneTransaction.getDocument(oneTransactionDoc)
                    if (oneDocSnap.exists) {
                        oneTransaction.updateData([dataKey:dataValue], forDocument: oneTransactionDoc)
                    }
                    else {
                        oneTransaction.setData([dataKey:dataValue], forDocument: oneTransactionDoc)
                    }
                    return nil
                    
                }
                catch {
                    print(error)
                    return nil
                    
                }
            }
            else {
                return nil
                
            }
            
            
        } completion: { compelted, error in
            print(error)
        }
        
        
    }
    static func retrieveCompetitionKeyMatch(playType: String, regionalKey: String, matchKey: String, teamNum: String, completion: @escaping (([String:Any]) -> ())) {
        guard let teamNumber = currentProtoUser?.teamID else {
            completion([:])
            return
        }
        teamCollection.document("\(teamNumber)").collection(regionalKey).document(matchKey).collection(teamNum).document(playType).getDocument { oneDocSnap, oneDocError in
            if oneDocError == nil {
                guard let oneDocSnap = oneDocSnap else {
                    completion([:])
                    return
                }
                if (oneDocSnap.exists) {
                    
                    guard let oneDocSnapData = oneDocSnap.data() else {
                        completion([:])
                        return
                    }
                    completion(oneDocSnapData)
                }
                else {
                    completion([:])
                    
                }
            }
        }
    }
    static func createProtoTeam(teamNum: String, teamID: String, teamCode: String, teamDetails: [String:Any], completion: @escaping (Bool) -> ()) {
        let teamName = teamDetails["nickname"] as? String ?? "None"
        let teamSchool = teamDetails["school_name"] as? String ?? "None"
        let teamCity = teamDetails["city"] as? String ?? "None"
        let teamCountry = teamDetails["country"] as? String ?? "None"
        
        teamCollection.document("\(teamID)").setData(["teamNum": teamNum, "teamID": teamID, "teamCode": teamCode, "name": teamName, "school": teamSchool, "city": teamCity, "country": teamCountry]) { error in
            if (error == nil) {
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    static func getProtoTeam(teamCode: String, completion: @escaping (Bool) -> ()) {
        guard let teamEmail = currentProtoUser?.email else { return  }

        teamCollection.whereField("teamCode", isEqualTo: teamCode).getDocuments { oneDocSnapshot, oneDocError in
            if oneDocError == nil {
                guard let oneDocSnapshot = oneDocSnapshot?.documents.first?.data() else { return }
                
                guard let oneDocTeamNum = oneDocSnapshot["teamNum"] as? String else { return }
                guard let oneDocTeamID = oneDocSnapshot["teamID"] as? String else { return }
    
                userCollection.document("\(teamEmail)").updateData(["teamNum": oneDocTeamNum, "teamID": oneDocTeamID, "teamCode": teamCode]) { error in
                    if (error == nil) {
                        currentProtoUser?.teamNum = oneDocTeamNum
                        currentProtoUser?.teamID = oneDocTeamID
                        currentProtoUser?.teamCode = teamCode
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                }
            }
            else {
                completion(false)
            }
        }
        
    }
    static func searchProtoTeams(teamSearch: String, completion: @escaping ([[String:Any]]) -> ()) {
        teamCollection.whereField("name", isGreaterThanOrEqualTo: teamSearch).getDocuments { oneDocSnapshot, oneDocError in
            if oneDocError == nil {
                guard let oneDocSnapshot = oneDocSnapshot?.documents else { return }
                completion(oneDocSnapshot.map { oneDocSnap in
                    return oneDocSnap.data()
                })
            }
        }
    }
}



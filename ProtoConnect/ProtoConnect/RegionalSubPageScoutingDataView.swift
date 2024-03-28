//
//  RegionalSubPageScoutingDataView.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 3/28/23.
//

import SwiftUI
import Neumorphic
import FirebaseFirestore

struct RegionalSubPageScoutingDataView: View {
    
    @State var redTeams: [String]
    @State var blueTeams: [String]
    @State var currentSelectedTeam: String = ""
    @State var regionalKey: String
    @State var matchNumber: String
    @State var assignments: [String]
    
    @State var autoSpeakerNotesMade: Int = 0
    @State var autoSpeakerNotesAttempted: Int = 0
    @State var autoAmpNotesMade: Int = 0
    @State var autoAmpNotesAttempted: Int = 0
    @State var teleopSpeakerNotesMade: Int = 0
    @State var teleopSpeakerNotesAttempted: Int = 0
    @State var teleopAmpNotesMade: Int = 0
    @State var teleopAmpNotesAttempted: Int = 0
    
    @State var robotHang: Bool = false
    @State var robotTrapScore: Bool = false
    @State var robotAmplify: Bool = false
    @State var robotCoopertition: Bool = false
    @State var robotHarmony: Bool = false
    
    @State var currentPlayType: String = "auto"
    @State var qrCodeVisible: Bool = false
    @State var qrCodeData: String = ""
    
    var body: some View {
        ScrollView {
            
            HStack {
                Text("Team \(currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color.black)
                    .padding()
                
                
                
                
                Spacer()
            }
            VStack {
               
                if (qrCodeVisible){
                    QRcodeGenerate(data: $qrCodeData)
                }
            }
            VStack {
                
                
                Picker("", selection: $currentSelectedTeam) {
                    ForEach(redTeams, id: \.self) { oneRedTeam in
                        Text(oneRedTeam.replacingOccurrences(of: "frc", with: ""))
                            .foregroundColor(.red)
                            .font(.headline)
                            .bold()
                            .tag(oneRedTeam)
                    }
                    ForEach(blueTeams, id: \.self) { oneBlueTeam in
                        Text(oneBlueTeam.replacingOccurrences(of: "frc", with: ""))
                            .foregroundColor(.blue)
                            .font(.headline)
                            .bold()
                            .tag(oneBlueTeam)
                    }
                }
                .onChange(of: currentSelectedTeam) { newValue in
                    guard let teamNumber = ProtoFirebase.currentProtoUser?.teamNum else {
                        return
                    }
                    updateRegionalData()
                    updateQRCode()
                    //                        ProtoFirebase.teamCollection.document("\(teamNumber)").collection(regionalKey).document(matchKey).collection(newValue).document(currentPlayType).addSnapshotListener { oneDocSnapshot, oneDocError in
                    //                            updateRegionalData()
                    //                        }
                }
                
                Picker("", selection: $currentPlayType) {
                    
                    Text("Auto")
                        .foregroundColor(.blue)
                        .font(.headline)
                        .bold()
                        .tag("auto")
                    Text("Teleoperated")
                        .foregroundColor(.blue)
                        .font(.headline)
                        .bold()
                        .tag("teleoperated")
                }
                .onChange(of: currentPlayType) { newValue in
                    guard let teamNumber = ProtoFirebase.currentProtoUser?.teamNum else {
                        return
                    }
                    updateQRCode()
                    //                        ProtoFirebase.teamCollection.document("\(teamNumber)").collection(regionalKey).document(matchKey).collection(currentSelectedTeam).document(newValue).addSnapshotListener { oneDocSnapshot, oneDocError in
                    //                            updateRegionalData()
                    //                        }
                }
                
                
            }
            .padding()
            .pickerStyle(.segmented)
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(redTeams.contains(currentSelectedTeam) ? Color.red : Color.blue)
            .cornerRadius(20)
            .padding()
            .softOuterShadow()
            
            VStack {
                HStack {
                    Text("Speaker")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .bold()
                        .foregroundColor(Color.black)
                        .padding()
                    
                    
                    Spacer()
                }
                VStack {
                    VStack {
                        if currentPlayType == "auto" {
                            Stepper {
                                Text("\(autoSpeakerNotesMade) Notes Made")
                                    .bold()
                            } onIncrement: {
                                autoSpeakerNotesMade += 1
                                autoSpeakerNotesAttempted += 1
                            } onDecrement: {
                                if (autoSpeakerNotesMade > 0) {
                                    autoSpeakerNotesMade -= 1
                                }
                            } onEditingChanged: { oneEditing in
                                
                            }
                            .padding(.horizontal)
                            .onChange(of: autoSpeakerNotesMade, perform: { newValue in
                                
                                ProtoSheets.setRowTeamNumberData(data: newValue, column: "D", matchNumber: String(matchNumber), teamNumber: currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))
                                updateQRCode()
                                
                            })
                        }
                        else {
                            Stepper {
                                Text("\(teleopSpeakerNotesMade) Notes Made")
                                    .bold()
                            } onIncrement: {
                                teleopSpeakerNotesMade += 1
                                teleopSpeakerNotesAttempted += 1
                            } onDecrement: {
                                if (teleopSpeakerNotesMade > 0) {
                                    teleopSpeakerNotesMade -= 1
                                }
                            } onEditingChanged: { oneEditing in
                                
                            }
                            .padding(.horizontal)
                            .onChange(of: teleopSpeakerNotesMade, perform: { newValue in
                                ProtoSheets.setRowTeamNumberData(data: newValue, column: "H", matchNumber: String(matchNumber), teamNumber: currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))
                                updateQRCode()
                                
                            })
                        }
                        
                    }
                    
                    Spacer()
                    VStack {
                        if (currentPlayType == "auto") {
                            Stepper {
                                Text("\(autoSpeakerNotesAttempted) Notes Attempted")
                                    .bold()
                            } onIncrement: {
                                autoSpeakerNotesAttempted += 1
                                
                            } onDecrement: {
                                if (autoSpeakerNotesAttempted > 0) {
                                    autoSpeakerNotesAttempted -= 1
                                }
                            } onEditingChanged: { oneEditing in
                                
                            }
                            .onChange(of: autoSpeakerNotesAttempted, perform: { newValue in
                                ProtoSheets.setRowTeamNumberData(data: newValue, column: "C", matchNumber: String(matchNumber), teamNumber: currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))
                                updateQRCode()
                            })
                        }
                        else {
                            Stepper {
                                Text("\(teleopSpeakerNotesAttempted) Notes Attempted")
                                    .bold()
                            } onIncrement: {
                                teleopSpeakerNotesAttempted += 1
                                
                            } onDecrement: {
                                if (teleopSpeakerNotesAttempted > 0) {
                                    teleopSpeakerNotesAttempted -= 1
                                }
                            } onEditingChanged: { oneEditing in
                                
                            }
                            .onChange(of: teleopSpeakerNotesAttempted, perform: { newValue in
                                ProtoSheets.setRowTeamNumberData(data: newValue, column: "G", matchNumber: String(matchNumber), teamNumber: currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))
                                updateQRCode()
                            })
                        }
                        
                        
                    }
                    .padding(.horizontal)
                    Spacer()
                    
                }
                .padding(.bottom)
                Spacer()
            }.frame(maxWidth: .infinity)
                .frame(height: 180)
                .background(LinearGradient(colors: [Color(red: 0.55, green: 0.78, blue: 0.93), Color(red: 0.58, green: 0.6, blue: 0.89)], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(20)
                .padding(10)
                .shadow(radius: 2)
            VStack {
                HStack {
                    Text("Amp")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .bold()
                        .foregroundColor(Color.black)
                        .padding()
                    
                    
                    Spacer()
                }
                VStack {
                    VStack {
                        
                        if currentPlayType == "auto" {
                            Stepper {
                                Text("\(autoAmpNotesMade) Notes Made")
                                    .bold()
                            } onIncrement: {
                                autoAmpNotesMade += 1
                                autoAmpNotesAttempted += 1
                            } onDecrement: {
                                if (autoAmpNotesMade > 0) {
                                    autoAmpNotesMade -= 1
                                }
                            } onEditingChanged: { oneEditing in
                                
                            }
                            .padding(.horizontal)
                            .onChange(of: autoAmpNotesMade, perform: { newValue in
                                
                                ProtoSheets.setRowTeamNumberData(data: newValue, column: "F", matchNumber: String(matchNumber), teamNumber: currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))
                                updateQRCode()
                                
                            })
                        }
                        else {
                            Stepper {
                                Text("\(teleopAmpNotesMade) Notes Made")
                                    .bold()
                            } onIncrement: {
                                teleopAmpNotesMade += 1
                                teleopAmpNotesAttempted += 1
                            } onDecrement: {
                                if (teleopAmpNotesMade > 0) {
                                    teleopAmpNotesMade -= 1
                                }
                            } onEditingChanged: { oneEditing in
                                
                            }
                            .padding(.horizontal)
                            .onChange(of: teleopAmpNotesMade, perform: { newValue in
                                
                                ProtoSheets.setRowTeamNumberData(data: newValue, column: "J", matchNumber: String(matchNumber), teamNumber: currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))
                                updateQRCode()
                                
                            })
                        }
                        
                    }
                    
                    Spacer()
                    VStack {
                        
                        if currentPlayType == "auto" {
                            Stepper {
                                Text("\(autoAmpNotesAttempted) Notes Attempted")
                                    .bold()
                            } onIncrement: {
                                autoAmpNotesAttempted += 1
                            } onDecrement: {
                                if (autoAmpNotesAttempted > 0) {
                                    autoAmpNotesAttempted -= 1
                                }
                            } onEditingChanged: { oneEditing in
                                
                            }
                            .onChange(of: autoAmpNotesAttempted, perform: { newValue in
                                ProtoSheets.setRowTeamNumberData(data: newValue, column: "E", matchNumber: String(matchNumber), teamNumber: currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))
                                updateQRCode()
                                
                            })
                        }
                        else {
                            Stepper {
                                Text("\(teleopAmpNotesAttempted) Notes Attempted")
                                    .bold()
                            } onIncrement: {
                                teleopAmpNotesAttempted += 1
                            } onDecrement: {
                                if (teleopAmpNotesAttempted > 0) {
                                    teleopAmpNotesAttempted -= 1
                                }
                            } onEditingChanged: { oneEditing in
                                
                            }
                            .onChange(of: teleopAmpNotesAttempted, perform: { newValue in
                                ProtoSheets.setRowTeamNumberData(data: newValue, column: "I", matchNumber: String(matchNumber), teamNumber: currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))
                                updateQRCode()
                                
                            })
                        }
                        
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.bottom)
                Spacer()
            }.frame(maxWidth: .infinity)
                .frame(height: 180)
                .background(LinearGradient(colors: [Color(red: 0.97, green: 0.81, blue: 0.41), Color(red: 0.98, green: 0.67, blue: 0.49)], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(20)
                .padding(10)
                .shadow(radius: 2)
            
            VStack {
                
                
                
                //                        if !robotParked {
                VStack {
                    VStack {
                        Toggle(isOn: $robotCoopertition) {
                            Text("Coopertition")
                                .font(.system(size: 23, weight: .bold, design: .rounded))
                                .bold()
                                .foregroundColor(Color.black)
                                .padding(.bottom, 1)
                            
                            
                        }
                        .padding(.horizontal)
                        .onChange(of: robotCoopertition, perform: { newValue in
                            ProtoSheets.setRowTeamNumberData(data: newValue, column: "P", matchNumber: String(matchNumber), teamNumber: currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))
                            updateQRCode()
                        })
                        Text("A ROBOT is DOCKED if it is contacting only the CHARGE STATION and/or other items also directly or transitively fully supported by the CHARGE STATION.")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .bold()
                            .foregroundColor(Color.Neumorphic.secondary)
                            .padding(.horizontal)
                    }
                    VStack {
                        
                        Toggle(isOn: $robotHang) {
                            Text("Hang")
                                .font(.system(size: 23, weight: .bold, design: .rounded))
                                .bold()
                                .foregroundColor(Color.black)
                                .padding(.bottom, 1)
                            
                            
                        }
                        .padding(.horizontal)
                        .onChange(of: robotHang, perform: { newValue in
                            ProtoSheets.setRowTeamNumberData(data: newValue, column: "L", matchNumber: String(matchNumber), teamNumber: currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))
                            updateQRCode()
                        })
                        Text("The state of the ROBOT if the following are true: the CHARGE STATION is LEVEL & all ALLIANCE ROBOTS contacting the CHARGE STATION are DOCKED.")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .bold()
                            .foregroundColor(Color.Neumorphic.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    VStack {
                        
                        Toggle(isOn: $robotAmplify) {
                            Text("Amplify")
                                .font(.system(size: 23, weight: .bold, design: .rounded))
                                .bold()
                                .foregroundColor(Color.black)
                                .padding(.bottom, 1)
                            
                            
                        }
                        .padding(.horizontal)
                        .onChange(of: robotAmplify, perform: { newValue in
                            ProtoSheets.setRowTeamNumberData(data: newValue, column: "N", matchNumber: String(matchNumber), teamNumber: currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))
                            updateQRCode()
                            
                        })
                        Text("The state of the ROBOT if the following are true: the CHARGE STATION is LEVEL & all ALLIANCE ROBOTS contacting the CHARGE STATION are DOCKED.")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .bold()
                            .foregroundColor(Color.Neumorphic.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    VStack {
                        
                        Toggle(isOn: $robotHarmony) {
                            Text("Harmony")
                                .font(.system(size: 23, weight: .bold, design: .rounded))
                                .bold()
                                .foregroundColor(Color.black)
                                .padding(.bottom, 1)
                            
                            
                        }
                        .padding(.horizontal)
                        .onChange(of: robotHarmony, perform: { newValue in
                            ProtoSheets.setRowTeamNumberData(data: newValue, column: "O", matchNumber: String(matchNumber), teamNumber: currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))
                            updateQRCode()
                            
                        })
                        Text("The state of the ROBOT if the following are true: the CHARGE STATION is LEVEL & all ALLIANCE ROBOTS contacting the CHARGE STATION are DOCKED.")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .bold()
                            .foregroundColor(Color.Neumorphic.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    VStack {
                        
                        Toggle(isOn: $robotTrapScore) {
                            Text("Trap Score")
                                .font(.system(size: 23, weight: .bold, design: .rounded))
                                .bold()
                                .foregroundColor(Color.black)
                                .padding(.bottom, 1)
                            
                            
                        }
                        .padding(.horizontal)
                        .onChange(of: robotTrapScore, perform: { newValue in
                            
                            ProtoSheets.setRowTeamNumberData(data: newValue, column: "M", matchNumber: String(matchNumber), teamNumber: currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))
                            updateQRCode()
                            
                        })
                        Text("A ROBOT is DOCKED if it is contacting only the CHARGE STATION and/or other items also directly or transitively fully supported by the CHARGE STATION.")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .bold()
                            .foregroundColor(Color.Neumorphic.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                }
                .padding(.vertical)
                
                //                        }
                
                
                
            }
            .frame(maxWidth: .infinity)
            //                .frame(height: currentPlayType == "auto" ? 100 : 325)
            .background(LinearGradient(colors: [Color(red: 0.883, green: 0.80, blue: 0.89), Color(red: 0.91, green: 0.89, blue: 0.94)], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(20)
            .padding()
            .shadow(radius: 2)
            
            Spacer()
            
        }
        .onAppear {
            if !ProtoFirebase.isAdmin {
                redTeams.removeAll { oneString in
                    return !assignments.contains(oneString)
                }
                blueTeams.removeAll { oneString in
                    return !assignments.contains(oneString)
                }
            }
            if (!redTeams.isEmpty) {
                currentSelectedTeam = redTeams.first ?? "frc-1"
            }
            else if (!blueTeams.isEmpty) {
                currentSelectedTeam = blueTeams.first ?? "frc-1"
            }
            updateRegionalData()
            
            
        }
        .toolbar(content: {
            ToolbarItem {
                Button(action: {
                    updateQRCode()
                    qrCodeVisible.toggle()
                } , label: {
                    Image(systemName: "qrcode")
                        .foregroundStyle(Color.black)
                        
                })
            }
        })
        
    }
    func updateQRCode() {
        qrCodeData = "\(matchNumber);\(currentSelectedTeam);\(autoSpeakerNotesMade);\(autoSpeakerNotesAttempted);\(autoAmpNotesMade);\(autoAmpNotesAttempted);\(teleopSpeakerNotesMade);\(teleopSpeakerNotesAttempted);\(teleopAmpNotesMade);\(teleopAmpNotesAttempted);\(robotHang);\(robotTrapScore);\(robotAmplify);\(robotCoopertition);\(robotHarmony)"
    }
    func returnData(str : String)->Data{
        let filter = CIFilter(name: "CIQRCodeGenerator")
        let data = str.data(using: .ascii, allowLossyConversion: false)
        filter?.setValue(data, forKey: "inputMessage")
        let image = filter?.outputImage
        let uiimage = UIImage(ciImage: image!)
        return uiimage.pngData()!
    }
    

    
    
    func updateRegionalData() {
        ProtoSheets.getRowTeamNumberData(matchNumber: String(matchNumber), teamNumber: currentSelectedTeam.replacingOccurrences(of: "frc", with: "")) { dataRetrieved in
            autoSpeakerNotesMade = Int(dataRetrieved["autoSpeakerMade"] as? Double ?? 0)
            autoSpeakerNotesAttempted = Int(dataRetrieved["autoSpeakerAtp"] as? Double ?? 0)
            autoAmpNotesMade = Int(dataRetrieved["autoAmpMade"] as? Double ?? 0)
            autoAmpNotesAttempted = Int(dataRetrieved["autoAmpAtp"] as? Double ?? 0)
            teleopSpeakerNotesMade = Int(dataRetrieved["teleopSpeakerMade"] as? Double ?? 0)
            teleopSpeakerNotesAttempted = Int(dataRetrieved["teleopSpeakerAtp"] as? Double ?? 0)
            teleopAmpNotesMade = Int(dataRetrieved["teleopAmpMade"] as? Double ?? 0)
            teleopAmpNotesAttempted = Int(dataRetrieved["teleopAmpAtp"] as? Double ?? 0)
            
            robotHang = dataRetrieved["hang"] as? Bool ?? false
            robotTrapScore = dataRetrieved["trapScore"] as? Bool ?? false
            robotCoopertition = dataRetrieved["coopertition"] as? Bool ?? false
            robotAmplify = dataRetrieved["amplify"] as? Bool ?? false
            robotHarmony = dataRetrieved["harmony"] as? Bool ?? false
        }
        //        ProtoFirebase.retrieveCompetitionKeyMatch(playType: currentPlayType, regionalKey: regionalKey, matchKey: matchKey, teamNum: currentSelectedTeam) { protoData in
        //
        //
        //
        //            highConesStepper = Int(protoData["highCones"] as? String ?? "0") ?? 0
        //            midConesStepper = Int(protoData["midCones"] as? String ?? "0") ?? 0
        //            lowConesStepper = Int(protoData["hybridCones"] as? String ?? "0") ?? 0
        //            highCubesStepper = Int(protoData["highCubes"] as? String ?? "0") ?? 0
        //            midCubesStepper = Int(protoData["midCubes"] as? String ?? "0") ?? 0
        //            lowCubesStepper = Int(protoData["hybridCubes"] as? String ?? "0") ?? 0
        //
        //            robotEngaged = protoData["chargeStation"] as? String ?? "" == "engaged" ? true : false
        //            robotDocked = protoData["chargeStation"] as? String ?? "" == "docked" ? true : false
        //            robotTaxi = protoData["taxi"] as? String ?? "" == "taxied" ? true : false
        //
        //        }
    }
    
}

struct RegionalSubPageScoutingDataView_Previews: PreviewProvider {
    static var previews: some View {
        //        Text("Hello")
        RegionalSubPageScoutingDataView(redTeams: ["frc2854", "frc972", "frc972"], blueTeams: ["frc1232", "frc2343", "frc3442"], regionalKey: "2024frc", matchNumber: "", assignments: [])
    }
}

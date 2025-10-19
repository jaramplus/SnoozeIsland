//
//  ChallengeWrapView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 5/18/25.
//

import SwiftUI

struct ChallengeCurrentView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var startMenu: Bool
    @Binding var control: Bool

    var body: some View {
                    VStack(spacing: 0) {
                        titleView()

                        VStack(spacing: 0) {
                            Text("\(snoozeViewModel.consecutiveSuccessCount)일째 습관 형성 중이에요!")
                                .font(.subheadline)
                            
                        }
                        .padding()

                        TimeView()
                            .padding(.horizontal)
                            .padding(.top, 8)

                        Button(action: {
                            withAnimation { control.toggle() }} ) {
                                HStack {
                                    Spacer()
                                    Text("다시 정하기")
                                    Spacer()
                                }
                        }
                        .buttonStyle(PrimaryButton())
                        .padding(.vertical, 16)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .mask {
                        RoundedRectangle(cornerRadius: 10.0)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 450)
    }
    
    
    private func titleView() -> some View {
        HStack(alignment: .center) {
            Spacer()
            Text("습관 형성")
                .font(.headline)
            Spacer()
        }
        .overlay {
            HStack {
                Button(action: { withAnimation { startMenu.toggle() }}) {
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.black)
                }
                .padding()
                Spacer()
            }
        }
    }
    
    private func TimeView() -> some View {
        VStack {
            HStack {
                Spacer()
                HStack {
                    Image(systemName: "moon.fill")
                    Text("기상")
                }
                .font(.system(size: 18))
                
                Spacer()
                Text((snoozeViewModel.wakeTime.formatted(myFormat)))
                    .padding()
                    .environment(\.locale, Locale.init(identifier: String(Locale.preferredLanguages[0].prefix(2))))
                    .overlay {
                        DatePicker("", selection: .constant(snoozeViewModel.wakeTime), displayedComponents: .hourAndMinute)
                            .datePickerStyle(.graphical)
                            .foregroundStyle(.clear)
                            .blendMode(.destinationOver)
                            .font(.system(size: 24))
                            .disabled(true)
                    }
                Spacer()
            }
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal)
            
            
            HStack {
                Spacer()
                HStack {
                    Image(systemName: "sun.max.fill")
                    Text("취침")
                    
                }
                .font(.system(size: 18))
                
                Spacer()
                Text(snoozeViewModel.sleepTime.formatted(myFormat))
                    .padding()
                    .overlay {
                        DatePicker("", selection: .constant(snoozeViewModel.sleepTime), displayedComponents: .hourAndMinute)
                            .datePickerStyle(.graphical)
                            .foregroundStyle(.clear)
                            .blendMode(.destinationOver)
                            .font(.system(size: 24))
                            .disabled(true)
                    }
                Spacer()
            }
            .padding(.vertical, 8)
            
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke()
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {    
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
    
    HomeView()
        .environmentObject(snoozeViewModel)
    
//    ChallengeWrapView(startMenu: .constant(true))
//        .environmentObject(snoozeViewModel)
}

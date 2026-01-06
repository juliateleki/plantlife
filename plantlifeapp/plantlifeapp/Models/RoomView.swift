//
//  RoomView.swift
//  plantlifeapp
//
//  Created by Julia Teleki on 1/5/26.
//

import SwiftUI
import SwiftData

struct RoomView: View {
    let plantName: String
    let plantRate: Double

    let room: RoomState
    let items: [DecorItem]
    let onTogglePlace: (DecorItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Living Room")
                .font(.title3).bold()

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.thinMaterial)
                    .frame(height: 260)

                VStack(spacing: 10) {
                    Text("🪴 \(plantName)")
                        .font(.title2)
                    Text("\(plantRate, specifier: "%.1f") coins / min")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Placed decor preview (MVP)
                  if room.isRugPlaced {
                      Text("🟫 Cozy Rug (placed)")
                          .padding(.top, 8)
                  } else {
                      Text("No decor placed yet")
                          .padding(.top, 8)
                          .foregroundStyle(.secondary)
                  }

                }
            }

            // Quick place/unplace controls (owned items only)
          let owned = items.filter { $0.isOwned && $0.roomType == RoomType.living }


            if !owned.isEmpty {
                Text("Your items")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(owned) { item in
                            Button {
                                onTogglePlace(item)
                            } label: {
                              Text(room.isRugPlaced ? "Remove \(item.name)" : "Place \(item.name)")

                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 14)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
    }
}

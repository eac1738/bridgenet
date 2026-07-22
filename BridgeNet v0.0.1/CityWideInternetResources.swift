//
//  CitywideInternetResources.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/22/26.
//

import Foundation

// Low-cost internet programs available to any qualifying Chicago household,
// regardless of ZIP code — pinned above the ZIP-distance results in the
// Internet finder the same way CitywideHousingResources are pinned in Housing.
//
// Verified July 2026 against xfinity.com, pcsforpeople.org, lifelinesupport.org,
// and fcc.gov. Pricing and eligibility rules can change, so each card links back
// to its source and encourages confirming details before applying.
//
// Note: the Affordable Connectivity Program (ACP), which used to add up to an
// extra $30/month discount, ended June 1, 2024 when Congress did not renew its
// funding, and has not been revived since. It's intentionally left off this
// list — Lifeline is the federal discount that's still active today.
enum CitywideInternetResources {
    static let all: [SavedResource] = [
        SavedResource(
            id: SavedResource.makeID(category: .internet, title: "Xfinity Internet Essentials", address: "Available where Xfinity service is offered"),
            category: .internet,
            title: "Xfinity Internet Essentials",
            subtitle: "For households at or below 200% of the federal poverty level",
            address: "Available where Xfinity service is offered — check coverage online",
            phone: "8558468376",
            milesAway: nil,
            details: [
                "Two plans: Internet Essentials at $14.95/month (75 Mbps) or Internet Essentials Plus at $29.95/month (100 Mbps), both with no data cap and equipment included.",
                "Qualify by income (at or below 200% of the federal poverty guidelines) or by participating in a program like SNAP, Medicaid, housing assistance, or the National School Lunch Program.",
                "You can't have had Xfinity service in the last 90 days, and can't have Comcast debt older than a year.",
                "Stacking the FCC Lifeline discount can bring the cost down further — ask about combining the two when you apply."
            ],
            savedDate: Date(),
            website: "https://www.xfinity.com/learn/internet-service/internet-essentials",
            isCitywideResource: true
        ),
        SavedResource(
            id: SavedResource.makeID(category: .internet, title: "PCs for People — Low-Cost Internet", address: "Ships nationwide — verify coverage on their website first"),
            category: .internet,
            title: "PCs for People — Low-Cost Internet",
            subtitle: "Nationwide 4G/5G hotspot service, no credit check",
            address: "Ships nationwide — verify coverage on their website first",
            phone: "",
            milesAway: nil,
            details: [
                "Prepaid mobile hotspot internet, with monthly plans generally in the $10–16 range plus a one-time device cost — pricing has changed over time, so confirm the current rate on their site.",
                "Qualify with income at or below 200% of the federal poverty level, or enrollment in an income-based assistance program.",
                "No credit check and no long-term contract; devices ship directly to your home, so this works even outside Xfinity's coverage area."
            ],
            savedDate: Date(),
            website: "https://www.pcsforpeople.org/internet/",
            isCitywideResource: true
        ),
        SavedResource(
            id: SavedResource.makeID(category: .internet, title: "FCC Lifeline Discount", address: "Apply online at lifelinesupport.org or by phone"),
            category: .internet,
            title: "FCC Lifeline Discount",
            subtitle: "A monthly discount that stacks with other low-cost plans",
            address: "Apply online at lifelinesupport.org or by phone",
            phone: "8002349473",
            milesAway: nil,
            details: [
                "A federal discount of $9.25 a month (up to $34.25 on Tribal lands) applied directly to a participating provider's phone or internet bill — it isn't a stand-alone service on its own.",
                "Qualify with household income at or below 135% of the federal poverty guidelines, or enrollment in SNAP, Medicaid, SSI, Federal Public Housing Assistance, or Veterans Pension.",
                "Only one Lifeline discount per household, and annual re-verification is required to keep it active.",
                "The old Affordable Connectivity Program's extra $30/month discount ended in June 2024 and hasn't been renewed by Congress — Lifeline remains active on its own and is the current federal option."
            ],
            savedDate: Date(),
            website: "https://www.lifelinesupport.org/",
            isCitywideResource: true
        )
    ]
}

//
//  CitywideFoodResources.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/22/26.
//

import Foundation

// A hand-curated set of Chicago-wide emergency food, SNAP/benefits, and
// meal-delivery resources. Like CitywideHousingResources and
// CitywideInternetResources, these aren't tied to one address or ZIP code —
// they're services every Chicago resident can use no matter where they live
// (or, in Nourishing Hope's case, a single physical site that isn't in the
// delegate_agencies.csv offline dataset, so it wouldn't otherwise surface in
// a ZIP-based search), so they're pinned above the ZIP-distance results in
// the Food finder instead of being sorted by mileage.
//
// Contact info and eligibility verified against chicagosfoodbank.org,
// 211metrochicago.org, nourishinghopechi.org, chicago.gov, and cps.edu as of
// July 2026. Programs, hours, and phone numbers can change, so each card
// links back to its source page and encourages confirming details before
// visiting in person.
enum CitywideFoodResources {
    static let all: [SavedResource] = [
        SavedResource(
            id: SavedResource.makeID(category: .food, title: "Find a Food Pantry Near You", address: "Search by address or zip code — chicagosfoodbank.org"),
            category: .food,
            title: "Find a Food Pantry Near You",
            subtitle: "Free groceries and hot meals, open to anyone who asks",
            address: "Search by address or zip code — chicagosfoodbank.org",
            phone: "7732473663",
            milesAway: nil,
            details: [
                "The Greater Chicago Food Depository's Find Food map lists hours, locations, and details for its full network of food pantries, soup kitchens, and mobile distributions across Chicago and Cook County — filterable by day, distance, and services offered.",
                "No ID or proof of need is required at most sites, and the network serves anyone regardless of immigration status or criminal history.",
                "If a location or program isn't showing up here yet, searching the live map directly may turn up more up-to-date options nearby."
            ],
            savedDate: Date(),
            website: "https://www.chicagosfoodbank.org/find-food-2/",
            isCitywideResource: true
        ),
        SavedResource(
            id: SavedResource.makeID(category: .food, title: "Help Applying for SNAP/Link Benefits", address: "Call 211 (available 24/7) or the Food Depository"),
            category: .food,
            title: "Help Applying for SNAP/Link Benefits",
            subtitle: "Free, confidential application help",
            address: "Call 211 (available 24/7) or the Food Depository",
            phone: "2113624401",
            milesAway: nil,
            details: [
                "211 Metro Chicago connects callers to a trained Resource Navigator who can help apply for SNAP/Link, Medicaid, and other public benefits — dial 211, text your zip code to 898-211, or use the chat at 211metrochicago.org.",
                "The Greater Chicago Food Depository also offers free SNAP/Link and Medicaid application help through its Food & Medical Benefits program, reachable at 773-247-3663.",
                "Both options are confidential and available regardless of whether you already visit a food pantry."
            ],
            savedDate: Date(),
            website: "https://www.chicagosfoodbank.org/get-help/benefits-outreach/",
            isCitywideResource: true
        ),
        SavedResource(
            id: SavedResource.makeID(category: .food, title: "Nourishing Hope — Sheridan Market", address: "3945 N. Sheridan Rd, Chicago, IL 60613"),
            category: .food,
            title: "Nourishing Hope — Sheridan Market",
            subtitle: "Choice-based food pantry, online market, and home delivery",
            address: "3945 N. Sheridan Rd, Chicago, IL 60613",
            phone: "7735251777",
            milesAway: nil,
            details: [
                "Serves any Chicago resident whose household income falls below government guidelines (no proof of income required, just a verbal attestation) — no address or neighborhood restriction to visit in person or use the Online Market.",
                "Offers a full choice-based shopping experience or a faster pre-packed 'Express' option, plus on-site social services like benefits help and mental health counseling.",
                "Monthly home grocery delivery is available for seniors and people with disabilities who can't pick up in person, but delivery itself is limited to a specific service area (south of Devon Ave, north of 79th St, west of Western Ave) — call to check eligibility for delivery specifically."
            ],
            savedDate: Date(),
            website: "https://nourishinghopechi.org/",
            isCitywideResource: true
        ),
        SavedResource(
            id: SavedResource.makeID(category: .food, title: "Senior Home-Delivered Meals", address: "Call 312-744-4016 (Mon–Fri, 9am–5pm)"),
            category: .food,
            title: "Senior Home-Delivered Meals",
            subtitle: "Ages 60+, homebound or otherwise isolated",
            address: "Call 312-744-4016 (Mon–Fri, 9am–5pm)",
            phone: "3127444016",
            milesAway: nil,
            details: [
                "The City's Senior Services Information and Assistance Call Center screens callers for home-delivered meals — generally two meals per day, delivered on weekdays — for residents 60 and older who are frail, homebound, or isolated.",
                "The same call center can also connect seniors to other City of Chicago senior programs and public benefits screening.",
                "311 can also route senior meal requests to this program."
            ],
            savedDate: Date(),
            website: "https://www.chicago.gov/content/city/en/depts/fss/provdrs/senior/svcs/home-delivered-meals.html",
            isCitywideResource: true
        ),
        SavedResource(
            id: SavedResource.makeID(category: .food, title: "CPS Student Meals & Healthy CPS Hotline", address: "Call 773-553-KIDS (5437), Mon–Fri, 8am–5pm"),
            category: .food,
            title: "CPS Student Meals & Healthy CPS Hotline",
            subtitle: "For CPS families needing food or benefits help",
            address: "Call 773-553-KIDS (5437), Mon–Fri, 8am–5pm",
            phone: "7735535437",
            milesAway: nil,
            details: [
                "All CPS students receive free breakfast and lunch at school every school day at no charge, regardless of household income.",
                "The Healthy CPS Hotline connects families to a Children and Family Benefits Unit coordinator for help enrolling in or renewing SNAP and Medicaid, plus referrals to food pantries and other emergency resources.",
                "Families whose school is closed or who can't pick up meals in person can also ask about meal delivery through their school or network."
            ],
            savedDate: Date(),
            website: "https://www.cps.edu/services-and-supports/health-and-wellness/medical-food-benefits/supplemental-nutrition-assistance-program/",
            isCitywideResource: true
        )
    ]
}

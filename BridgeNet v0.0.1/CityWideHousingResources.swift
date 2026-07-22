//
//  CitywideHousingResources.swift
//  BridgeNet v0.0.1
//
//  Created by 20 BGCC Loan Library on 7/22/26.
//

import Foundation

// A hand-curated set of Chicago-wide homelessness and housing-crisis resources.
// Unlike the CSV-backed listings, these aren't tied to one address or ZIP code —
// they're services every Chicago resident can use no matter where they live, so
// they're pinned above the ZIP-distance results in the Housing finder instead of
// being sorted by mileage.
//
// Contact info and eligibility verified against city.gov, All Chicago
// (allchicago.org), and 211 Metro Chicago (211metrochicago.org) as of July 2026.
// Programs and phone numbers can change, so each card links back to its source
// page and encourages confirming details before visiting in person.
//
// Chicago's Plan to End Homelessness, the Point-in-Time Count, and the Shelter
// Infrastructure Initiative are intentionally left out — they're policy, data,
// and infrastructure-funding efforts rather than services a person can directly
// contact for help.
enum CitywideHousingResources {
    static let all: [SavedResource] = [
        SavedResource(
            id: SavedResource.makeID(category: .housing, title: "Need Shelter Right Now? Call 311", address: "Call 311 (available 24/7)"),
            category: .housing,
            title: "Need Shelter Right Now? Call 311",
            subtitle: "Open to all Chicago residents — no screening required",
            address: "Call 311 (available 24/7)",
            phone: "311",
            milesAway: nil,
            details: [
                "311 connects you to Chicago's Mobile Crisis Response and Shelter Referral Program, which can arrange transportation to an open shelter bed.",
                "If you can't reach 311, you can also go directly to a hospital emergency room or police station to request shelter."
            ],
            savedDate: Date(),
            website: "https://www.chicago.gov/content/city/en/depts/fss/provdrs/emerg/svcs/MCRSRP.html",
            isCitywideResource: true
        ),
        SavedResource(
            id: SavedResource.makeID(category: .housing, title: "Chicago Coordinated Entry System (CES)", address: "Phone Access Point: 312-971-4178"),
            category: .housing,
            title: "Chicago Coordinated Entry System (CES)",
            subtitle: "For anyone experiencing homelessness or housing instability",
            address: "Phone Access Point: 312-971-4178",
            phone: "3129714178",
            milesAway: nil,
            details: [
                "CES is the standard starting point for Chicago's housing programs — an assessment matches you with available shelter, rapid re-housing, and permanent housing based on need.",
                "Completing an assessment doesn't guarantee immediate housing since resources are limited, but it's required to access most housing programs.",
                "You can also call 311 or visit a walk-in Access Point in person."
            ],
            savedDate: Date(),
            website: "https://www.chicago.gov/content/city/en/depts/fss/provdrs/emerg/svcs/system-planning-and-coordination.html",
            isCitywideResource: true
        ),
        SavedResource(
            id: SavedResource.makeID(category: .housing, title: "Shelter Placement & Resource Center (SPARC)", address: "2241 S. Halsted St, Chicago, IL 60608"),
            category: .housing,
            title: "Shelter Placement & Resource Center (SPARC)",
            subtitle: "Single adults only",
            address: "2241 S. Halsted St, Chicago, IL 60608",
            phone: "7735263707",
            milesAway: nil,
            details: [
                "24/7 walk-in intake for single adults, offering shelter placement plus interim food, showers, and overflow shelter while a bed becomes available.",
                "Families with children should call 311 instead of going to SPARC directly."
            ],
            savedDate: Date(),
            website: "https://www.chicago.gov/content/city/en/depts/fss/provdrs/emerg/svcs/shelter-placement-and-resource-center--sparc--information-.html",
            isCitywideResource: true
        ),
        SavedResource(
            id: SavedResource.makeID(category: .housing, title: "Emergency Homeless Assessment & Response Center (EHARC)", address: "924 N. Christiana Ave, Chicago, IL 60651"),
            category: .housing,
            title: "Emergency Homeless Assessment & Response Center (EHARC)",
            subtitle: "For families awaiting shelter placement",
            address: "924 N. Christiana Ave, Chicago, IL 60651",
            phone: "",
            milesAway: nil,
            details: [
                "Run by The Salvation Army (also known as Shield of Hope), EHARC is the hub access point for families under the Coordinated Entry System.",
                "Families receive a diversion assessment and, where eligible, diversion services aimed at avoiding a shelter stay altogether.",
                "Call 311 first — DFSS staff will direct families here if needed."
            ],
            savedDate: Date(),
            website: "https://www.chicago.gov/content/city/en/depts/fss/provdrs/emerg/svcs/emergency-homeless-assessment-and-response-center--eharc-.html",
            isCitywideResource: true
        ),
        SavedResource(
            id: SavedResource.makeID(category: .housing, title: "Youth Homelessness Resources", address: "Multiple drop-in centers citywide"),
            category: .housing,
            title: "Youth Homelessness Resources",
            subtitle: "Ages 14–24",
            address: "Multiple drop-in centers citywide — contact each for hours",
            phone: "",
            milesAway: nil,
            details: [
                "City-supported drop-in centers help young people with food, hygiene supplies, laundry, and case management toward housing, mental health, and job or school readiness.",
                "Streetlight Chicago (streetlightchicago.org) is a free app and website built for unstably housed youth ages 16–24 to find shelter, food, and health resources.",
                "Hours and services vary by location, so call ahead to confirm."
            ],
            savedDate: Date(),
            website: "https://www.chicago.gov/content/city/en/depts/fss/provdrs/emerg/svcs/anyone-who-needs-resources-for-youth-experiencing-homelessness.html",
            isCitywideResource: true
        ),
        SavedResource(
            id: SavedResource.makeID(category: .housing, title: "Drop-In Centers for Individuals & Families", address: "Multiple locations citywide"),
            category: .housing,
            title: "Drop-In Centers for Individuals & Families",
            subtitle: "Basic needs plus case management",
            address: "Multiple locations citywide — contact each for hours",
            phone: "",
            milesAway: nil,
            details: [
                "City-funded drop-in centers offer food, hygiene items, and laundry along with housing, mental health, and job-readiness support.",
                "Case managers help connect visitors to longer-term housing and other services.",
                "Each center sets its own hours and offerings, so confirm before visiting."
            ],
            savedDate: Date(),
            website: "https://www.chicago.gov/content/city/en/depts/fss/provdrs/emerg/svcs/drop-in-centers-for-individuals-and-families-experiencing-homele.html",
            isCitywideResource: true
        ),
        SavedResource(
            id: SavedResource.makeID(category: .housing, title: "Rental Assistance Program (Homelessness Prevention)", address: "Call 311, 211 Metro Chicago, or visit a DFSS Community Service Center"),
            category: .housing,
            title: "Rental Assistance Program (Homelessness Prevention)",
            subtitle: "For households at risk of losing their housing",
            address: "Call 311, 211 Metro Chicago, or visit a DFSS Community Service Center",
            phone: "311",
            milesAway: nil,
            details: [
                "Short-term financial help for rent, utilities, and arrears for residents facing an economic crisis or eviction, plus budgeting-focused case management.",
                "211 Metro Chicago's Homelessness Prevention Call Center screens callers for available funds; if you don't qualify there, they'll point you to other resources.",
                "Disponible en español — pregunte por el Programa de Asistencia para el Pago de Alquiler."
            ],
            savedDate: Date(),
            website: "https://www.chicago.gov/content/city/en/depts/fss/provdrs/emerg/svcs/homeless_prevention.html",
            isCitywideResource: true
        ),
        SavedResource(
            id: SavedResource.makeID(category: .housing, title: "Rapid Re-Housing (RRH)", address: "Accessed through a Coordinated Entry System assessment"),
            category: .housing,
            title: "Rapid Re-Housing (RRH)",
            subtitle: "For households currently experiencing homelessness",
            address: "Accessed through a Coordinated Entry System assessment",
            phone: "",
            milesAway: nil,
            details: [
                "Helps individuals and families move quickly from homelessness into permanent housing, with short-term rent help and case management to prevent falling back into homelessness.",
                "You can't apply directly — a Coordinated Entry System assessment determines who is referred to RRH based on need."
            ],
            savedDate: Date(),
            website: "https://www.chicago.gov/content/city/en/depts/fss/provdrs/emerg/svcs/rapidrehousing.html",
            isCitywideResource: true
        ),
        SavedResource(
            id: SavedResource.makeID(category: .housing, title: "Homeless Outreach & Prevention (HOP)", address: "Street outreach citywide — request a visit through 311"),
            category: .housing,
            title: "Homeless Outreach & Prevention (HOP)",
            subtitle: "For people sleeping outside or unsheltered",
            address: "Street outreach citywide — request a visit through 311",
            phone: "311",
            milesAway: nil,
            details: [
                "DFSS's outreach team and delegate agencies engage unsheltered residents near train tracks, bridges, the river, viaducts, alleys, parks, and CTA stations.",
                "Outreach staff work to connect people directly to services and shelter or housing, rather than requiring a visit to an office."
            ],
            savedDate: Date(),
            website: "https://www.chicago.gov/content/city/en/depts/fss/provdrs/emerg/svcs/homeless_outreachandengagement.html",
            isCitywideResource: true
        )
    ]
}

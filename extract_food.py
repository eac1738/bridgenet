import pypdf
import json
import re
from geopy.geocoders import Nominatim
import time

# 1. Initialize tools
reader = pypdf.PdfReader("food_data.pdf")
geolocator = Nominatim(user_agent="chicago_pantry_app_builder_v3")
pantries = []

# Valid Chicago area zip code prefixes
CHICAGO_PREFIXES = ("606", "607", "608")

print("=== STARTING CHICAGO-ONLY PDF EXTRACTION ===")

# Combine all pages into one text block
full_document_text = ""
for page in reader.pages:
    full_document_text += page.extract_text() + "\n"

# 2. Process the text block line by line
lines = full_document_text.split("\n")
for index, line in enumerate(lines):
    # Search for any 5-digit zip code in the current line
    zip_match = re.search(r"\b\d{5}\b", line)
    
    if zip_match:
        detected_zip = zip_match.group(0)
        
        # STAGE 1 FILTER: Skip the line entirely if it is not a Chicago zip prefix
        if not detected_zip.startswith(CHICAGO_PREFIXES):
            continue
            
        full_address = line.strip()
        
        # Look backwards up to 3 lines to find the pantry name
        pantry_name = "Chicago Area Food Pantry"
        for offset in range(1, 4):  # Look 1, 2, and 3 lines back
            if index - offset >= 0:
                possible_name = lines[index - offset].strip()
                # Ignore generic structural layout headers
                if possible_name and possible_name.lower() not in ["address", "your location:", "radius:"]:
                    pantry_name = possible_name
                    break
        
        print(f"📍 Found Chicago Match -> Name: {pantry_name} | Address: {full_address}")
        
        # 3. Convert Chicago address into map coordinates
        try:
            print(f"   Fetching coordinates for: {full_address}...")
            location = geolocator.geocode(full_address, timeout=10)
            
            if location:
                pantries.append({
                    "name": pantry_name,
                    "address": full_address,
                    "zipCode": detected_zip,
                    "latitude": location.latitude,
                    "longitude": location.longitude
                })
            else:
                # Fallback if map look-up fails
                print("   ⚠️ Address lookup failed. Saving with fallback center coordinates.")
                pantries.append({
                    "name": pantry_name,
                    "address": full_address,
                    "zipCode": detected_zip,
                    "latitude": 41.8781,
                    "longitude": -87.6298
                })
            
            # Sleep 1 second to respect OpenStreetMap usage policies
            time.sleep(1)
            
        except Exception as e:
            print(f"   Skipping coordinate lookup due to network error: {e}")

# 4. Save the filtered results to your JSON database
with open("pantries.json", "w") as f:
    json.dump(pantries, f, indent=4)

print(f"\n🎉 SUCCESS! Filtered out suburbs. Saved {len(pantries)} Chicago locations to 'pantries.json'.")

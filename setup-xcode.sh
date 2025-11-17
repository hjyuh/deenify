#!/bin/bash

# Deenify Xcode Project Setup Script
# Run this to create the Xcode project with all files properly configured

echo "🚀 Setting up Deenify Xcode Project..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed or not in PATH"
    exit 1
fi

cd "$(dirname "$0")"

# Create the Xcode project using swift package
echo "📦 Creating Xcode project..."

# Create Package.swift for SPM
cat > Package.swift << 'EOF'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Deenify",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Deenify",
            targets: ["Deenify"]),
    ],
    targets: [
        .target(
            name: "Deenify",
            path: "Deenify")
    ]
)
EOF

# Generate Xcode project from SPM
swift package generate-xcodeproj

if [ -f "Deenify.xcodeproj/project.pbxproj" ]; then
    echo "✅ Xcode project created: Deenify.xcodeproj"
else
    echo "⚠️  SPM method didn't work, creating project manually..."

    # Alternative: Use xcodegen if available, or manual creation
    echo "📝 Please follow manual setup instructions below:"
    echo ""
    echo "Manual Setup Steps:"
    echo "1. Open Xcode"
    echo "2. File > New > Project"
    echo "3. Choose: iOS > App"
    echo "4. Product Name: Deenify"
    echo "5. Interface: SwiftUI"
    echo "6. Language: Swift"
    echo "7. Save in: $(pwd)"
    echo "8. Then drag all folders from Deenify/ into the project"
    echo ""
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. open Deenify.xcodeproj (or create manually if needed)"
echo "2. Add CloudKit capability"
echo "3. Run on simulator or device"
echo ""
echo "Need help? Check Deenify/README.md for full instructions"
EOF

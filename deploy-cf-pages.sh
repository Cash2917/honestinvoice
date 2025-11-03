#!/bin/bash

# Simple Cloudflare Pages Deployment
# Deploy only the frontend to Cloudflare Pages

echo "🚀 Deploying HonestInvoice to Cloudflare Pages..."

# Build the application
echo "Building application..."
cd honestinvoice

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Build for production
echo "Building for production..."
npm run build:simple

if [ ! -d "dist" ]; then
    echo "❌ Build failed - dist directory not found!"
    exit 1
fi

echo "✅ Build successful!"

# Deploy to Cloudflare Pages
echo "Deploying to Cloudflare Pages..."

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "Installing Wrangler CLI..."
    npm install -g wrangler
fi

# Deploy
npx wrangler pages deploy dist --project-name=honestinvoice

if [ $? -eq 0 ]; then
    echo "🎉 Successfully deployed to Cloudflare Pages!"
    echo "Your app will be available at: https://honestinvoice.pages.dev"
else
    echo "❌ Deployment failed!"
    exit 1
fi
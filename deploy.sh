#!/bin/bash

# HonestInvoice Production Deployment Script
# This script deploys the entire HonestInvoice application to Cloudflare Pages + Supabase

set -e  # Exit on any error

echo "🚀 Starting HonestInvoice Production Deployment..."
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    print_status "Checking system requirements..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js 18+ first."
        exit 1
    fi
    
    NODE_VERSION=$(node --version | cut -d'v' -f2)
    print_status "Node.js version: $NODE_VERSION"
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed. Please install npm first."
        exit 1
    fi
    
    print_success "System requirements check passed!"
}

# Install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    cd honestinvoice
    
    # Install frontend dependencies
    npm install
    
    print_success "Dependencies installed successfully!"
}

# Build frontend
build_frontend() {
    print_status "Building frontend application..."
    
    cd honestinvoice
    
    # Clean previous build
    rm -rf dist
    
    # Build for production
    npm run build:simple
    
    if [ ! -d "dist" ]; then
        print_error "Build failed - dist directory not found!"
        exit 1
    fi
    
    print_success "Frontend built successfully!"
}

# Deploy to Cloudflare Pages
deploy_to_cloudflare() {
    print_status "Deploying to Cloudflare Pages..."
    
    # Check if wrangler is installed
    if ! command -v wrangler &> /dev/null; then
        print_warning "Wrangler CLI not found. Installing..."
        npm install -g wrangler
    fi
    
    # Get Cloudflare project name
    read -p "Enter your Cloudflare Pages project name (default: honestinvoice): " CF_PROJECT
    CF_PROJECT=${CF_PROJECT:-honestinvoice}
    
    # Deploy to Cloudflare Pages
    npx wrangler pages deploy dist --project-name="$CF_PROJECT"
    
    if [ $? -eq 0 ]; then
        print_success "Deployed to Cloudflare Pages successfully!"
    else
        print_error "Failed to deploy to Cloudflare Pages"
        exit 1
    fi
}

# Deploy Supabase Edge Functions
deploy_supabase_functions() {
    print_status "Deploying Supabase Edge Functions..."
    
    # Check if Supabase CLI is installed
    if ! command -v supabase &> /dev/null; then
        print_warning "Supabase CLI not found. Installing..."
        npm install -g supabase
    fi
    
    # Get Supabase project ID
    read -p "Enter your Supabase project ID (default: hqlefdadfjdxxzzbtjqk): " SUPABASE_PROJECT_ID
    SUPABASE_PROJECT_ID=${SUPABASE_PROJECT_ID:-hqlefdadfjdxxzzbtjqk}
    
    # Login to Supabase
    print_status "Please login to Supabase CLI..."
    supabase login
    
    # Link to project
    supabase link --project-ref "$SUPABASE_PROJECT_ID"
    
    # Deploy all edge functions
    print_status "Deploying edge functions..."
    
    for func_dir in supabase/functions/*/; do
        func_name=$(basename "$func_dir")
        print_status "Deploying function: $func_name"
        supabase functions deploy "$func_name"
    done
    
    print_success "All Supabase Edge Functions deployed successfully!"
}

# Run database migrations
run_database_migrations() {
    print_status "Running database migrations..."
    
    # Get Supabase project ID
    read -p "Enter your Supabase project ID (default: hqlefdadfjdxxzzbtjqk): " SUPABASE_PROJECT_ID
    SUPABASE_PROJECT_ID=${SUPABASE_PROJECT_ID:-hqlefdadfjdxxzzbtjqk}
    
    # Apply migrations in chronological order
    for migration in supabase/migrations/*.sql; do
        if [ -f "$migration" ]; then
            migration_name=$(basename "$migration")
            print_status "Applying migration: $migration_name"
            supabase db push --project-ref "$SUPABASE_PROJECT_ID" --db-url "postgresql://postgres:$POSTGRES_PASSWORD@db.$SUPABASE_PROJECT_ID.supabase.co:5432/postgres" "$migration"
        fi
    done
    
    print_success "Database migrations completed!"
}

# Setup environment variables
setup_environment() {
    print_status "Setting up environment variables..."
    
    print_warning "Please ensure these environment variables are set in Cloudflare Pages:"
    echo "  - VITE_SUPABASE_URL=https://$SUPABASE_PROJECT_ID.supabase.co"
    echo "  - VITE_SUPABASE_ANON_KEY=<your-anon-key>"
    echo "  - VITE_STRIPE_PUBLISHABLE_KEY=<your-stripe-publishable-key>"
    echo "  - STRIPE_SECRET_KEY=<your-stripe-secret-key> (for Edge Functions)"
    
    echo ""
    print_status "Configure these in:"
    echo "  1. Cloudflare Pages: Project Settings > Environment Variables"
    echo "  2. Supabase Edge Functions: Use Supabase Dashboard > Settings > API"
}

# Final verification
verify_deployment() {
    print_status "Verifying deployment..."
    
    echo ""
    print_success "🎉 Deployment completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Configure custom domain (honestinvoice.com) in Cloudflare Pages"
    echo "2. Set up SSL certificate"
    echo "3. Configure DNS records"
    echo "4. Test all application features"
    echo "5. Monitor edge function logs in Supabase Dashboard"
    echo ""
    print_status "Application URLs:"
    echo "  - Cloudflare Preview: https://$CF_PROJECT.pages.dev"
    echo "  - Custom Domain: https://honestinvoice.com (after DNS setup)"
    echo ""
    print_success "Happy invoicing! 🚀"
}

# Main deployment flow
main() {
    echo "HonestInvoice Production Deployment"
    echo "===================================="
    echo ""
    
    # Check requirements
    check_requirements
    
    # Build frontend
    install_dependencies
    build_frontend
    
    # Deploy components
    deploy_to_cloudflare
    deploy_supabase_functions
    run_database_migrations
    
    # Setup
    setup_environment
    
    # Verify
    verify_deployment
}

# Run main function
main "$@"
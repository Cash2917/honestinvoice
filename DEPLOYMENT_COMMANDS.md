# HonestInvoice Deployment Commands

Since you don't have terminal access right now, here are the deployment commands you can run when you have access:

## 🚀 Quick Deploy (Cloudflare Pages Only)

```bash
# Navigate to your project directory
cd honestinvoice-xxfinalxx

# Run the simple deploy script
chmod +x deploy-cf-pages.sh
./deploy-cf-pages.sh
```

## 🔧 Full Deployment (Frontend + Backend)

```bash
# Run the complete deployment script
chmod +x deploy.sh
./deploy.sh
```

This will:
1. ✅ Build the React frontend
2. ✅ Deploy to Cloudflare Pages  
3. ✅ Deploy Supabase Edge Functions
4. ✅ Run database migrations

## 📝 Manual Commands

If you prefer to run commands manually:

### 1. Build Frontend
```bash
cd honestinvoice
npm install
npm run build:simple
```

### 2. Deploy to Cloudflare Pages
```bash
npx wrangler pages deploy dist --project-name=honestinvoice
```

### 3. Deploy Supabase Edge Functions (if needed)
```bash
# Install Supabase CLI first
npm install -g supabase

# Login and link project
supabase login
supabase link --project-ref hqlefdadfjdxxzzbtjqk

# Deploy all functions
supabase functions deploy create-invoice
supabase functions deploy create-subscription
supabase functions deploy process-payment
supabase functions deploy stripe-webhook
supabase functions deploy admin-dashboard
supabase functions deploy admin-users-management
supabase functions deploy api-v1
supabase functions deploy create-admin-user
supabase functions deploy rate-limiter
supabase functions deploy send-email
```

## 🌐 Production URLs

After deployment, your app will be available at:
- **Cloudflare Preview**: `https://honestinvoice.pages.dev`
- **Custom Domain**: `https://honestinvoice.com` (after DNS setup)

## ⚙️ Environment Variables

Make sure these are set in Cloudflare Pages:
```
NODE_VERSION = 18.19.0
NODE_ENV = production
VITE_SUPABASE_URL = https://hqlefdadfjdxxzzbtjqk.supabase.co
VITE_SUPABASE_ANON_KEY = <your-anon-key>
VITE_STRIPE_PUBLISHABLE_KEY = <your-stripe-key>
```

## 📊 Monitoring

After deployment:
- Check Cloudflare Pages for build logs
- Monitor Supabase Edge Function logs
- Test all features before going live

Your HonestInvoice subscription system is ready to go live! 🚀
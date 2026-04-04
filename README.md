# OptiReg — Eye-Care Professional Registration Platform

A clinical-grade onboarding and Rx-powered product intelligence platform for eye-care professionals. Built as a zero-cost, mobile-first web app.

---

## Project Structure

```
optireg/
├── index.html       ← Registration app (6-step form + OTP)
├── dashboard.html   ← Protected dashboard (reads real profile data)
├── config.js        ← ⚙️  Your Supabase credentials go here
├── schema.sql       ← Run once in Supabase SQL editor
└── vercel.json      ← Auto-deploy config for Vercel
```

---

## Setup in 5 steps

### 1. Create a Supabase project
Go to [supabase.com](https://supabase.com) → New project → choose a name and region.

### 2. Run the database schema
In your Supabase dashboard → **SQL Editor** → paste the contents of `schema.sql` → Run.  
This creates 3 tables (`profiles`, `professional_details`, `practice_info`) with Row Level Security.

### 3. Enable Phone Auth
Supabase dashboard → **Authentication** → **Sign In / Providers** → **Phone** → Enable.  
For development, add a test number in the "Test Phone Numbers" field:
```
+917000000001=123456
```
This lets you test the full OTP flow without a real SMS provider.

### 4. Add your credentials
Open `config.js` and replace the two values:
```js
var SUPABASE_URL     = 'https://YOUR_PROJECT.supabase.co';
var SUPABASE_ANON_KEY = 'your-publishable-key-here';
```
Get these from: Supabase dashboard → **Settings** → **API**  
Use the **anon / publishable** key — never the service_role key in frontend code.

### 5. Deploy to Vercel
- Push this repo to GitHub
- Go to [vercel.com](https://vercel.com) → New Project → Import from GitHub
- Vercel auto-detects the config and deploys instantly
- Every `git push` to `main` triggers a new deployment automatically

---

## Testing the full flow

1. Open the deployed URL
2. Fill in the registration form
3. Use `+917000000001` as mobile, `123456` as the OTP
4. Complete all 6 steps and hit **Create professional account**
5. You'll be redirected to the dashboard showing your real profile data from Supabase

---

## Phase Roadmap

| Phase | Status | What it includes |
|-------|--------|-----------------|
| 1 | ✅ Done | Full registration UI — 6 steps, mobile + desktop |
| 2 | ✅ Done | Supabase auth, OTP, form → DB, JWT session, dashboard |
| 3 | 🔜 Next | Rx matching engine — rule-based product scoring |
| 4 | 🔜 | Smart overlay, auto-trigger, comparison mode |
| 5 | 🔜 | AI Rx image upload, ML personalization |

---

## Going live with real SMS

When you're ready for real users, create a free [Twilio](https://twilio.com) account ($15 free credit) and add your credentials in the Supabase Phone Auth settings:
- Twilio Account SID
- Twilio Auth Token  
- Twilio Message Service SID

No code changes needed — just update the Supabase dashboard settings.

---

## Security notes

- Row Level Security (RLS) is enabled on all 3 tables — users can only access their own data
- The `anon` key in `config.js` is safe for frontend use — RLS enforces data isolation
- Never commit a `service_role` key to GitHub

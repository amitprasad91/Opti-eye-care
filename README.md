
# OptiReg — Eye-Care Professional Platform

A clinical-grade registration, authentication and Rx-powered product intelligence platform for eye-care professionals. Mobile-first, zero cost to run.

---

## Project Structure

```
optireg/
├── index.html            ← Registration (6-step form + OTP)
├── login.html            ← Login (phone OTP + email/password)
├── dashboard.html        ← Protected dashboard + profile edit
├── rx.html               ← Rx entry + smart product matching
├── reset-password.html   ← Password reset callback
├── config.js             ← Your Supabase credentials go here
├── schema.sql            ← Phase 2: profiles, professional_details, practice_info
├── schema-phase3.sql     ← Phase 3: prescriptions + products (30 seed SKUs)
└── vercel.json           ← Static deploy config
```

---

## Quick Setup

### 1. Create a Supabase project
Go to [supabase.com](https://supabase.com) → New project → choose name and region (free tier).

### 2. Run the database schemas
Supabase dashboard → **SQL Editor** → run `schema.sql` first, then `schema-phase3.sql`.

### 3. Enable Phone Auth
Supabase → **Authentication** → **Sign In / Providers** → **Phone** → Enable.

For development (no SMS needed), add test numbers in the Phone settings:
```
918013354342=123456,918777590395=123456
```
Format: country code + number (no plus sign) = OTP

### 4. Add your credentials
Open `config.js`:
```js
var SUPABASE_URL     = 'https://YOUR_PROJECT.supabase.co';
var SUPABASE_ANON_KEY = 'your-publishable-key-here';
```
Get both from: Supabase → **Settings** → **API**. Use the **anon / publishable** key only.

### 5. Deploy on GitHub Pages
Settings → Pages → Deploy from branch `main` → `/ (root)` → Save.
Live at: `https://amitprasad91.github.io/Opti-eye-care/`

---

## Testing the full flow

**Registration:** Open `index.html` → fill 6 steps → use test mobile → OTP `123456` → dashboard

**Login:** Open `login.html` → Phone OTP tab or Email/password tab → dashboard

**Rx Matching:** Dashboard → New Rx → enter OD/OS values → Match products → filter + compare

---

## Phase Roadmap

| Phase | Status | What it includes |
|-------|--------|-----------------|
| 1 | ✅ Done | 6-step registration UI, validation, review step, mobile + desktop |
| 2 | ✅ Done | Supabase auth, OTP, DB submission, login, dashboard, forgot password |
| 3 | ✅ Done | Rx entry, scoring engine, product matching overlay, filter, compare, history |
| 4 | 🔜 Next | Auto-trigger overlay, personalised recommendations, availability sync |
| 5 | 🔜 Later | AI Rx image scan (OCR), ML-based personalisation |

---

## Key Features

**Registration (index.html)**
- 6-step form: Basic info, Role, Practice, Location, Review, Consent
- Checks for duplicate mobile/email before OTP — no wasted codes
- OTP timer: 2:00 countdown, amber at 30s, disabled after expiry
- Resend cooldown: 30s between resend attempts
- Abandoned session detection — resumes at step 2 if OTP was verified
- Draft saves to localStorage — survives page refresh
- Review step with Edit shortcuts per section

**Login (login.html)**
- Phone OTP tab + Email/password tab
- Checks if number is registered before sending OTP
- Same OTP timer and resend cooldown as registration
- Forgot password → email reset link → reset-password.html

**Dashboard (dashboard.html)**
- Protected — redirects unauthenticated users to login instantly
- Edit modals for personal, professional, and practice details
- Recent prescriptions panel with quick Match links

**Rx Matching (rx.html)**
- Auto-detects Rx type live: Myopia, Hyperopia, Astigmatism, Presbyopia, Compound, Plano
- Scoring engine 0-100 with hard filters (sphere range, cylinder max, SV blocked for add power)
- Results overlay: ranked cards with colour-coded match scores
- 9 filter chips + compare up to 3 products side-by-side
- Save Rx history — one-click reload or re-match

---

## Database

**schema.sql (Phase 2):** profiles, professional_details, practice_info — all with RLS

**schema-phase3.sql (Phase 3):** prescriptions, products (30 SKUs: Zeiss, Hoya, Essilor, Nikon, Rodenstock — Basic/Mid/Premium tiers)

---

## Going Live with Real SMS
Create a free [Twilio](https://twilio.com) account and add credentials in Supabase Phone Auth settings. No code changes needed.

---

## Security
- `anon` key is safe for frontend — RLS enforces data isolation per user
- Never commit `service_role` key to GitHub
- OTP expires in 120 seconds — no replay attacks after expiry

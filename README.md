# Rebuilt

Rebuilt is a Flutter MVP for reusing leftover construction and renovation materials. It is a portfolio project for Product Builder, AI Product, and Founder's Office roles.

> Status: working prototype. No production data, credentials, or deployment configuration are included.

## The problem

Usable tiles, paint, flooring, fixtures, and timber are often discarded because creating a local listing takes too much effort. Buyers may only need a small quantity and should not need to buy a full new pack.

## Product concept

Rebuilt is a mobile-first marketplace for those leftover materials. A seller chooses a photo, receives an AI-assisted draft, reviews the facts, and publishes. Buyers browse listings, inspect details, and send inquiries.

AI stays assistive: it drafts observable details and asks questions rather than inventing quantity, dimensions, brand, price, or collection information.

## Current features

- Email/password authentication and Google/Apple OAuth entry points
- Account onboarding with contact and location details
- Buy, Sell, and Messages screens with a curated demo catalog
- Photo selection and editable AI-assisted listing drafts
- Listing details, buyer inquiries, and seller activity counts
- Profile, privacy/account, Terms, and Privacy Policy screens
- Supabase Auth, database, Storage, and Edge Function integration boundaries

## Core workflow

1. A visitor signs in or creates an account.
2. The seller selects a photo in Sell.
3. An authenticated Edge Function creates a structured draft.
4. The seller checks and edits the listing.
5. The app uploads the image and saves the listing.
6. Buyers browse, open details, and send an inquiry.

## Technology

| Layer | Technology |
| --- | --- |
| Mobile app | Flutter, Dart, Material 3 |
| Media | image_picker |
| Backend | Supabase Auth, Postgres, Storage, Edge Functions |
| AI | Supabase Edge Function with a server-side Gemini API key |

## Run locally

Install Flutter packages and provide your own services at runtime:

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

The AI function reads its provider key only from the server-side secret store. Never put a provider key, Supabase service-role key, token, private endpoint, signing file, or copied `.env` file into this repository.

## Screenshots and demo

The walkthrough uses demo catalog data only and contains no user accounts, project URLs, API keys, or tokens.

[Watch the 22-second Rebuilt portfolio walkthrough](https://d2ol7oe51mr4n9.cloudfront.net/user_3JBnsq039oGw7v2NP5uUUIpu2g6/0a333fbf-9146-440e-bdb0-d478e1ab387e.mp4)

The video covers marketplace browsing, listing details, an AI-assisted draft, buyer messages, and the seller profile.

## Limitations

This is an MVP. Payments, delivery, moderation, notifications, real-time chat, production infrastructure, and real user data are not included.

## Security

The public version excludes runtime credentials, production URLs, database exports, real user content, and signing configuration. The application reads Supabase settings via Dart defines; the AI key stays server-side.

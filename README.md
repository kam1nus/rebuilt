# Rebuilt

Rebuilt is a Flutter MVP for reusing leftover construction and renovation materials. It is a portfolio project for Product Builder, AI Product, and Founder's Office roles.

> Status: working prototype. No production data, credentials, or deployment configuration are included.

## Product

A seller chooses a photo, receives an AI-assisted listing draft, checks the facts, and publishes. Buyers browse listings, open details, and send inquiries. AI drafts observable details and asks questions instead of inventing quantity, dimensions, brand, price, or collection information.

## Current features

- Email/password authentication and Google/Apple OAuth entry points
- Account onboarding, curated marketplace catalog, Sell and Messages screens
- Photo selection, editable AI drafts, buyer inquiries, seller activity counts
- Profile, privacy, Terms, and account controls
- Flutter, Dart, Material 3, Supabase Auth, Postgres, Storage, and Edge Functions

## Run locally

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

Keep provider keys, Supabase service-role keys, tokens, private endpoints, signing files, and copied `.env` files out of source control. The AI provider key belongs only in the server-side secret store.

## Demo

[Watch the 22-second Rebuilt portfolio walkthrough](https://d2ol7oe51mr4n9.cloudfront.net/user_3JBnsq039oGw7v2NP5uUUIpu2g6/c54327cf-fc12-4778-b885-f1f823aa197b.mp4)

The video covers marketplace browsing, listing details, an AI-assisted draft, buyer messages, and the seller profile.

## Limitations

This MVP does not include payments, delivery, moderation, notifications, real-time chat, production infrastructure, or real user data.

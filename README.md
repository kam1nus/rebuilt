# Rebuilt

Rebuilt is a Flutter MVP for reusing leftover construction and renovation materials. It is a portfolio project for Product Builder, AI Product, and Founder's Office roles.

> Status: working prototype. No production data, credentials, or deployment configuration are included.

## Product

A seller chooses a photo, receives an AI-assisted listing draft, checks the facts, and publishes. Buyers browse listings, open details, and send inquiries.

## Product walkthrough

### Browse materials

![Marketplace feed](https://d2ol7oe51mr4n9.cloudfront.net/user_3JBnsq039oGw7v2NP5uUUIpu2g6/724bb509-64c2-4ea7-a10c-e96346c9b8ce.jpg)

A mobile-first feed helps buyers discover leftover materials nearby.

### Filter by category

![Category filters](https://d2ol7oe51mr4n9.cloudfront.net/user_3JBnsq039oGw7v2NP5uUUIpu2g6/20e32dcb-5192-4d81-9ca2-4c63597420c7.jpg)

Categories narrow the catalog without requiring a complex search flow.

### Review a listing

![Listing detail](https://d2ol7oe51mr4n9.cloudfront.net/user_3JBnsq039oGw7v2NP5uUUIpu2g6/d4fbbaae-0d3a-4f4a-9f71-5f7e54fb09a8.jpg)

Buyers can inspect a listing before sending an inquiry.

### Create an AI-assisted draft

![AI listing draft](https://d2ol7oe51mr4n9.cloudfront.net/user_3JBnsq039oGw7v2NP5uUUIpu2g6/540379a6-116e-4161-b491-a98a48196380.jpg)

AI drafts observable details. The seller remains responsible for reviewing quantity, price, and collection information.

### Track seller activity

![Seller profile](https://d2ol7oe51mr4n9.cloudfront.net/user_3JBnsq039oGw7v2NP5uUUIpu2g6/3b8e5aef-9e2a-4726-8323-52dfe3be97ce.jpg)

The profile shows active listings, views, and buyer inquiries.

## Current features

- Email/password authentication and Google/Apple OAuth entry points
- Account onboarding, curated marketplace catalog, Sell and Messages screens
- Photo selection, editable AI drafts, buyer inquiries, seller activity counts
- Flutter, Dart, Material 3, Supabase Auth, Postgres, Storage, and Edge Functions

## Run locally

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

Keep provider keys, Supabase service-role keys, tokens, private endpoints, signing files, and copied `.env` files out of source control.

## Limitations

This MVP does not include payments, delivery, moderation, notifications, real-time chat, production infrastructure, or real user data.

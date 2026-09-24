# Rebuilt

**Rebuilt** is a Flutter MVP for making leftover construction and renovation materials easier to reuse instead of discard. It is a portfolio project demonstrating product discovery, mobile UX, backend integration, and an AI-assisted listing workflow.

> Status: working prototype. The repository contains the application code and Supabase Edge Function source, but no production data, credentials, or deployed-project configuration.

## The problem

Renovation projects regularly leave behind usable tiles, paint, fixtures, flooring, timber, and other materials. These items are often thrown away because listing them takes time: the seller needs photos, a title, a description, dimensions, quantity, price, and a way to answer buyers. At the same time, local buyers may need small amounts of material without paying for a full new pack.

## Product concept

Rebuilt is a local, mobile-first marketplace focused on those leftover materials. A seller selects a photo, receives an AI-generated listing draft, fills in the facts that a photo cannot prove, and publishes it. Buyers can browse active listings, open a detail page, and send an inquiry to the seller.

The product deliberately keeps AI in an assistive role: it drafts observable material details and asks follow-up questions rather than inventing quantity, dimensions, brand, price, or pickup information.

## Target users

- Homeowners and renters finishing a renovation
- Contractors and tradespeople with surplus material
- Small renovation teams that want to reduce material waste
- Local buyers looking for an affordable small quantity of a specific material

## Core workflow

1. A visitor creates an account or signs in.
2. The seller opens **Sell** and chooses a photo from the device.
3. The app sends the image to an authenticated Edge Function.
4. The function asks a server-side AI provider to return a structured, evidence-based draft.
5. The seller reviews and edits the title, description, quantity, dimensions, condition, price, and pickup details.
6. On publish, the photo is uploaded to storage and the listing is saved to the database.
7. Buyers browse available items, view details, and submit an inquiry. The seller sees received inquiries and simple listing metrics in their profile.

## Current features

- Email/password authentication through Supabase
- Buy and Sell mobile screens with an honest empty state
- Photo selection from the device library
- AI-assisted material identification and structured listing drafts
- Follow-up questions for details that cannot be reliably inferred from an image
- Editable listing information before publishing
- Supabase-backed listing storage and public image URLs
- Listing detail view and buyer inquiry flow
- Seller profile with active-listing, unique-view, and inquiry counts
- Row-level-security-oriented backend design, with seller-owned edits and profile data

## Architecture and tech stack

| Layer | Technology | Responsibility |
| --- | --- | --- |
| Mobile app | Flutter / Dart / Material 3 | Product UX, authentication state, marketplace UI, listing flows |
| Media | `image_picker` | Selects a listing image from the device |
| Backend | Supabase | Auth, Postgres data, Storage, Edge Functions |
| AI integration | Supabase Edge Function + Gemini API | Server-side image analysis and structured draft generation |

The current MVP is intentionally compact: most Flutter UI, domain mapping, and data access live in `lib/main.dart`, while the AI boundary is isolated in `supabase/functions/describe-material/index.ts`. That separation keeps the AI key on the server and lets the app call the function only as an authenticated user.

## Repository layout

```text
lib/main.dart                              Flutter application and marketplace flows
supabase/functions/describe-material/      Authenticated AI listing-draft function
supabase/templates/                        Auth email template
test/                                      Widget tests
.env.example                               Safe configuration reference only
```

## Run locally

### Prerequisites

- Flutter SDK compatible with Dart `^3.13.2`
- A Supabase project you control
- A Supabase publishable/anon key for that project
- Supabase CLI, only if you want to deploy the AI Edge Function
- An AI-provider key, stored only as an Edge Function secret

### App configuration

1. Copy `.env.example` to a local `.env` file as a reference. Do not commit the copied file.
2. Create the required Supabase Auth, database, Storage, and Edge Function resources in your own project. This repository intentionally does not include an exported production database or project URL.
3. Install Flutter packages:

   ```bash
   flutter pub get
   ```

4. Run with configuration passed at the command line. Substitute values from your own project; never add them to source code:

   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
     --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
   ```

### AI Edge Function

The app invokes `describe-material` only for authenticated users. The function reads `GEMINI_API_KEY` from the provider's server-side secret store. Set the secret in your Supabase project, then deploy:

```bash
supabase secrets set GEMINI_API_KEY=YOUR_PROVIDER_KEY
supabase functions deploy describe-material
```

Do not place the provider key in Flutter, `.env.example`, screenshots, issue comments, commits, or client-side code.

## Screenshots and demo

Screenshots and a short walkthrough video can be added here when they contain only demo data and no personal information, project URLs, API keys, or account tokens.

- Screenshot placeholder: `docs/screenshots/marketplace.png`
- Demo placeholder: add a link to a redacted walkthrough video

## What is implemented vs. planned

| Implemented in the prototype | Planned / not included in this repository |
| --- | --- |
| Auth, listing creation, browsing, photo upload, inquiries, seller metrics, AI draft flow | Production deployment configuration and real project URL |
| Server-side AI-key access pattern | Database migrations / infrastructure-as-code export |
| Editable AI-generated drafts with uncertainty questions | Payments, delivery, escrow, moderation tooling |
| Mobile-first Flutter UI | Push/email notifications and buyer-seller chat |
| Basic seller performance counts | Search ranking, geo search, saved searches, analytics dashboard |

## Current limitations

- This is an MVP rather than a production marketplace.
- The repository does not ship a Supabase project schema or a deployed backend, so an independent local setup needs matching tables, policies, storage bucket, and Edge Function configuration.
- AI output is a draft and must be reviewed by the seller. It is designed not to claim unseen facts, but it is not a substitute for human verification.
- There are no payments, shipping, notifications, moderation workflow, or real-time chat yet.
- The UI is currently English-first and has been tested as a prototype, not as a released app.

## Security and publication policy

This public version intentionally excludes:

- `.env` files and all runtime credentials
- Supabase project URL and publishable key
- service-role keys, user tokens, client secrets, signing files, and local platform configuration
- production database exports, private endpoints, and real user content

The `.gitignore` is configured to keep common local configuration and signing files out of commits. Before pushing changes, scan staged files and Git history for accidental credentials. If a secret is ever committed, revoke or rotate it at the provider immediately; deleting the file in a later commit is not sufficient.

## Portfolio context

Rebuilt was built as a product-oriented prototype: identify a narrow, real-world workflow, reduce the effort at the point of friction, and make the AI behavior transparent and editable. It is intended to be discussed in applications for Product Builder, AI Product, and Founder's Office roles.

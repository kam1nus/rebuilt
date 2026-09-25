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




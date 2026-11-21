# AnimeNova Complete Admin Edition

This package expands the supplied static AnimeNova prototype with a full admin interface and a Supabase production database starter.

## What is included

- Admin overview with live local-preview counts and recent catalogue entries
- Anime catalogue CRUD, status, featured toggle, genre, year, type, score, poster, banner-ready data and official provider link
- Episode manager with episode number, title, authorized video URL and WebVTT subtitle URL
- Media library view for catalogue posters
- Demo user directory view
- Advertisement placement manager
- Website name, accent colour, tagline, footer and maintenance-mode preview settings
- Security/deployment status panel
- JSON backup and restore
- `supabase/schema.sql` with tables, Row Level Security policies, admin role helper, media bucket and admin bootstrap instructions

## Run the local preview

1. Extract this folder.
2. Open `index.html` in a browser, or deploy the folder to Netlify.
3. Click **Admin** in the top bar.
4. All edits in this static preview are stored in the current browser's local storage. Use **Backup / restore** to export a JSON backup.

## Important: local preview is not production security

The current website is a static HTML app. It does not yet authenticate administrators against Supabase or sync its browser data to the cloud. The dashboard's Security panel explains this state. Do not use real passwords in the demo account form, and do not publish private user information.

## Set up Supabase for production

1. Create a Supabase project.
2. In the Supabase SQL Editor, run `supabase/schema.sql`.
3. Enable the sign-in method(s) you intend to support in **Authentication → Providers**.
4. Create your own account through Supabase Auth.
5. Open **Authentication → Users**, copy your user UUID, and run the admin bootstrap `UPDATE public.profiles ...` statement at the bottom of `supabase/schema.sql` with your UUID.
6. Verify that a normal account cannot insert, update or delete catalogue rows, while the admin account can.
7. Connect the frontend to Supabase using the project's URL and **anon/public key** only. Keep the service-role key on a trusted server or serverless function; never place it in `index.html`, GitHub, or a public environment variable.
8. Migrate local catalogue entries using the JSON backup as a source, then upload posters to the `anime-media` bucket and store their public URLs in the `poster_url` / `banner_url` columns.

The SQL schema is a backend foundation, not a completed frontend-to-cloud integration. A developer still needs to wire Supabase Auth, queries, uploads and realtime updates into the frontend before shared accounts and cross-device admin edits work.

## Authorized video and copyright

Only add video files and subtitle tracks that you own or are licensed/authorized to distribute. For other titles, use the official provider's viewing page. This project does not scrape websites, bypass access controls, or host unauthorized streams.

## Deploy to Netlify

Deploy the `AnimeNova-Complete` folder (the one containing `index.html` and `netlify.toml`) to your Netlify site. Test the deployed copy before replacing a live production deployment.

# AnimeNova — Complete Admin Edition

A responsive anime discovery front end with a comprehensive browser-local admin dashboard and a Supabase production database starter.

## Included
- Responsive homepage, catalogue search and filters, anime detail view, episode player and watchlist
- Admin overview and statistics
- Anime catalogue management: add/edit/delete, status, featured titles, tags, official links and poster management
- Individual episode manager with authorized video and WebVTT subtitle URLs
- Poster media library, demo user list, ad placements and website settings
- JSON backup and restore
- Supabase SQL schema with Row Level Security and admin-role bootstrap

## Quick start
Open `index.html` in a browser or deploy the `AnimeNova-Complete` folder to Netlify. Click **Admin** to open the dashboard.

## Important
The front end is still a static local preview: browser data is not shared across visitors, and admin access is not protected by server authentication. `supabase/schema.sql` and `SETUP.md` provide the database and security setup foundation, but frontend Supabase integration is still required for production. Never expose a Supabase service-role key or store real passwords in browser storage.

Use only video and subtitle URLs you own or are authorized to distribute. Otherwise, link to official viewing providers. The app does not scrape or unlock copyrighted streams.

For full setup instructions, see [SETUP.md](SETUP.md).

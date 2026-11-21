# AnimeNova Complete Netlify Prototype

A single-folder, static Netlify prototype based on the supplied AnimeNova V3 ZIP. It brings the requested first-milestone screens and demo interactions together in one project.

## Included
- Responsive homepage with trending and latest sections
- Anime catalogue with title search, genre, year and type filters
- Dedicated in-app anime details view and episode list
- HTML5 video player supporting an authorized video URL and WebVTT subtitle URL per episode
- Demo registration/sign-in, watchlist, ratings and comments
- Browser-local admin dashboard: add/edit/delete anime, poster upload, episode metadata, official viewing URL
- Configurable ad placements for homepage, details and player views
- JSON backup and restore
- Netlify SPA fallback configuration

## Deploy to Netlify
1. Extract this ZIP.
2. Open https://app.netlify.com/drop and sign in.
3. Drag the **AnimeNova-Complete** folder (the folder containing `index.html` and `netlify.toml`) into Netlify Drop.
4. Netlify will publish a new site. To update an existing site, use its Netlify dashboard and deploy the updated folder there; do not overwrite your existing live site until you have tested the deployment.

## Important prototype limitations
This is a static front-end demo. It does **not** provide secure production authentication, shared accounts, shared admin permissions, a cloud database, or durable shared poster storage. Admin edits, demo accounts, comments, ratings, watchlists, and ad configuration are saved only in the current browser's local storage. Anyone using that same browser profile can inspect or modify local data. Do not use real passwords or sensitive information.

For production, connect a backend such as Supabase: enable Auth, create tables for anime/episodes/watchlists/comments/ratings/ads, configure Row Level Security, use a private admin role, and store poster assets in a protected bucket. Never put a service-role key in front-end code.

## Authorized video and subtitles
The player accepts direct media URLs that you own or have permission to distribute. Add episodes in Admin using one line per episode:
`Episode 1 | https://your-authorized-video.mp4 | https://your-subtitles.vtt`
The subtitle URL should point to a valid WebVTT (`.vtt`) file. If you do not have distribution rights, link to the official streaming provider instead. This project does not scrape, rehost, or unlock copyrighted streams.

## Ads and accounts
The ad placements are manual demo slots; they are not an ad-network integration and do not generate revenue automatically. Use an ad network only if the site and account meet its current eligibility and age requirements. Since the site owner is a minor, a parent/guardian should handle any payment, ad-network, or business account and review the provider's terms.

# AnimeNova — Supabase-connected edition

## Included

- Supabase JS v2 client configured with the project URL and publishable key you supplied.
- Supabase Auth email/password sign-up, sign-in and sign-out.
- Admin-only dashboard visibility and client-side checks, backed by database Row Level Security (RLS).
- Cloud catalogue reads and anime create/update/delete.
- Cloud episode reads and create/delete.
- Poster upload to the `anime-media` Storage bucket.
- Cloud site settings and advertisement placements.
- User profile list for admins (profile IDs are shown because the public `profiles` table intentionally does not expose email addresses).

## Required one-time Supabase setup

1. In Supabase Dashboard → SQL Editor, run `supabase/schema.sql`. If you already ran the same schema successfully, you do not need to run it again.
2. In Authentication → Providers, enable Email sign-in.
3. Deploy this folder to your website host (or open `index.html` locally for a basic test).
4. In AnimeNova, choose **Sign in → Create account** and register your own account. Confirm the email if Supabase asks you to.
5. In Supabase Dashboard → Authentication → Users, copy the UUID for your account.
6. In SQL Editor, promote only your own account using the exact UUID:

```sql
update public.profiles
set role = 'admin'
where id = 'PASTE-YOUR-AUTH-USER-UUID-HERE';
```

7. Sign out and sign back in to refresh the profile role. The Admin button should then appear.

## Important security notes

- The browser contains only the Supabase publishable key. This key is intended for public client apps; RLS is what protects database records.
- Never add a `service_role` key, secret API key, database password, or personal account password to this repository.
- The SQL bootstrap step is required to grant admin access. New sign-ups are ordinary users and cannot promote themselves.
- Keep RLS enabled. Do not add broad anonymous write policies.
- The `anime-media` bucket allows public reads of images and admin-only uploads/updates/deletes. Do not upload private documents.
- Episode video URLs must point to media you own or are licensed/authorized to distribute. Otherwise, use the official viewing link.

## Data notes

- Cloud catalogue starts empty unless you add records or migrate your existing local backup. The earlier sample titles are not automatically inserted into Supabase.
- Existing localStorage data remains in that browser as a backup but is no longer the source of truth once cloud loading succeeds.
- The user directory lists profile display names, role and UUID; retrieving Auth email addresses requires a trusted server-side admin API, not a browser key.
- Supabase email confirmation settings and redirect URLs may need configuration for your deployed domain under Authentication → URL Configuration.

## Deploy

Deploy the contents of `AnimeNova-Complete/` (the directory containing `index.html` and `netlify.toml`) to Netlify or another static host.

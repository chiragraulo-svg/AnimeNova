-- AnimeNova production database starter for Supabase.
-- Run in Supabase SQL Editor. Never expose the service_role key in browser code.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'AnimeNova user',
  role text not null default 'user' check (role in ('user','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.anime (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  synopsis text not null default '',
  genre text not null default 'Other',
  release_year integer check (release_year between 1900 and 2100),
  media_type text not null default 'TV' check (media_type in ('TV','Movie','OVA','ONA','Special')),
  status text not null default 'Upcoming' check (status in ('Ongoing','Completed','Upcoming','On hold')),
  rating numeric(3,1) not null default 0 check (rating between 0 and 10),
  poster_url text,
  banner_url text,
  official_url text,
  featured boolean not null default false,
  published boolean not null default false,
  catalogue_tag text not null default 'NEW',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.episodes (
  id uuid primary key default gen_random_uuid(),
  anime_id uuid not null references public.anime(id) on delete cascade,
  season_number integer not null default 1 check (season_number > 0),
  episode_number integer not null check (episode_number > 0),
  title text not null default '',
  authorized_video_url text,
  subtitle_vtt_url text,
  thumbnail_url text,
  published boolean not null default false,
  created_at timestamptz not null default now(),
  unique (anime_id, season_number, episode_number)
);

create table if not exists public.watch_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  anime_id uuid not null references public.anime(id) on delete cascade,
  episode_id uuid not null references public.episodes(id) on delete cascade,
  progress_seconds integer not null default 0 check (progress_seconds >= 0),
  duration_seconds integer not null default 0 check (duration_seconds >= 0),
  completed boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (user_id, episode_id)
);

create table if not exists public.ad_placements (
  id uuid primary key default gen_random_uuid(),
  placement_key text not null unique check (placement_key in ('home','details','player')),
  label text not null default 'ADVERTISEMENT',
  image_url text,
  destination_url text,
  enabled boolean not null default false,
  updated_at timestamptz not null default now()
);

create table if not exists public.site_settings (
  setting_key text primary key,
  setting_value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.audit_logs (
  id bigint generated always as identity primary key,
  actor_id uuid references auth.users(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id text,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists anime_published_featured_idx on public.anime (published, featured);
create index if not exists anime_title_search_idx on public.anime using gin (to_tsvector('simple', title));
create index if not exists episodes_anime_number_idx on public.episodes (anime_id, season_number, episode_number);
create index if not exists watch_progress_user_updated_idx on public.watch_progress (user_id, updated_at desc);

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1)));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.anime enable row level security;
alter table public.episodes enable row level security;
alter table public.watch_progress enable row level security;
alter table public.ad_placements enable row level security;
alter table public.site_settings enable row level security;
alter table public.audit_logs enable row level security;

-- Profiles: users can see/update only their own basic profile; admins can manage all profiles.
drop policy if exists "profile read own or admin" on public.profiles;
create policy "profile read own or admin" on public.profiles for select
using (id = auth.uid() or public.is_admin());
drop policy if exists "admin manage profiles" on public.profiles;
create policy "admin manage profiles" on public.profiles for all
using (public.is_admin()) with check (public.is_admin());

-- Public visitors can read only published titles; admins can manage all titles.
drop policy if exists "public read published anime" on public.anime;
create policy "public read published anime" on public.anime for select using (published or public.is_admin());
drop policy if exists "admin manage anime" on public.anime;
create policy "admin manage anime" on public.anime for all using (public.is_admin()) with check (public.is_admin());

-- Episodes are visible only when both the episode and parent title are published.
drop policy if exists "public read published episodes" on public.episodes;
create policy "public read published episodes" on public.episodes for select using (
  public.is_admin() or (published and exists (
    select 1 from public.anime a where a.id = anime_id and a.published
  ))
);
drop policy if exists "admin manage episodes" on public.episodes;
create policy "admin manage episodes" on public.episodes for all using (public.is_admin()) with check (public.is_admin());

-- Watch progress is private to the signed-in account that owns it.
drop policy if exists "users manage own watch progress" on public.watch_progress;
create policy "users manage own watch progress" on public.watch_progress for all
using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Only enabled ad placements are public.
drop policy if exists "public read enabled ads" on public.ad_placements;
create policy "public read enabled ads" on public.ad_placements for select using (enabled or public.is_admin());
drop policy if exists "admin manage ads" on public.ad_placements;
create policy "admin manage ads" on public.ad_placements for all using (public.is_admin()) with check (public.is_admin());

-- Settings are readable to visitors; only admins can change them.
drop policy if exists "public read site settings" on public.site_settings;
create policy "public read site settings" on public.site_settings for select using (true);
drop policy if exists "admin manage site settings" on public.site_settings;
create policy "admin manage site settings" on public.site_settings for all using (public.is_admin()) with check (public.is_admin());

-- Audit logs are private to admins; inserts should be made by trusted server-side code.
drop policy if exists "admin read audit logs" on public.audit_logs;
create policy "admin read audit logs" on public.audit_logs for select using (public.is_admin());
drop policy if exists "admin insert audit logs" on public.audit_logs;
create policy "admin insert audit logs" on public.audit_logs for insert with check (public.is_admin());

-- Create the public-readable media bucket. Admin-only writes are enforced below.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('anime-media', 'anime-media', true, 5242880, array['image/jpeg','image/png','image/webp','image/avif'])
on conflict (id) do nothing;

drop policy if exists "public read anime media" on storage.objects;
create policy "public read anime media" on storage.objects for select
using (bucket_id = 'anime-media');
drop policy if exists "admin upload anime media" on storage.objects;
create policy "admin upload anime media" on storage.objects for insert
with check (bucket_id = 'anime-media' and public.is_admin());
drop policy if exists "admin update anime media" on storage.objects;
create policy "admin update anime media" on storage.objects for update
using (bucket_id = 'anime-media' and public.is_admin())
with check (bucket_id = 'anime-media' and public.is_admin());
drop policy if exists "admin delete anime media" on storage.objects;
create policy "admin delete anime media" on storage.objects for delete
using (bucket_id = 'anime-media' and public.is_admin());

-- ADMIN BOOTSTRAP (run only after creating your own account with Supabase Auth):
-- 1. Find your user UUID in Authentication -> Users.
-- 2. Replace YOUR_AUTH_USER_UUID below, then run this statement separately:
-- update public.profiles set role = 'admin' where id = 'YOUR_AUTH_USER_UUID';

-- My Space saved titles (fresh installs).
create table if not exists public.saved_anime (
  user_id uuid not null references auth.users(id) on delete cascade,
  anime_id uuid not null references public.anime(id) on delete cascade,
  saved_type text not null check (saved_type in ('watchlist','favourite')),
  created_at timestamptz not null default now(),
  primary key (user_id, anime_id, saved_type)
);
alter table public.saved_anime enable row level security;
drop policy if exists "users manage own saved anime" on public.saved_anime;
create policy "users manage own saved anime" on public.saved_anime for all
using (user_id = auth.uid()) with check (user_id = auth.uid());
create or replace function public.prevent_self_role_change()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() = old.id and not public.is_admin() and new.role <> old.role then
    raise exception 'Users cannot change their own role';
  end if;
  return new;
end;
$$;
drop trigger if exists protect_profile_role on public.profiles;
create trigger protect_profile_role before update on public.profiles
for each row execute function public.prevent_self_role_change();
drop policy if exists "users update own profile" on public.profiles;
create policy "users update own profile" on public.profiles for update
using (id = auth.uid()) with check (id = auth.uid());
create index if not exists saved_anime_user_type_idx on public.saved_anime(user_id,saved_type,created_at desc);

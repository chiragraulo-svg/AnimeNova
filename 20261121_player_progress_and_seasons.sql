-- AnimeNova player upgrade: season support + private account watch progress.
-- Run once in Supabase SQL Editor on an existing AnimeNova database.
-- This migration preserves existing anime and episode rows.

alter table public.episodes
  add column if not exists season_number integer not null default 1;

-- Allow episode numbers to restart at 1 in each season.
alter table public.episodes
  drop constraint if exists episodes_anime_id_episode_number_key;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'episodes_anime_season_episode_key'
      and conrelid = 'public.episodes'::regclass
  ) then
    alter table public.episodes
      add constraint episodes_anime_season_episode_key
      unique (anime_id, season_number, episode_number);
  end if;
end $$;

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

drop index if exists public.episodes_anime_number_idx;
create index episodes_anime_number_idx
  on public.episodes (anime_id, season_number, episode_number);
create index if not exists watch_progress_user_updated_idx
  on public.watch_progress (user_id, updated_at desc);

alter table public.watch_progress enable row level security;
drop policy if exists "users manage own watch progress" on public.watch_progress;
create policy "users manage own watch progress" on public.watch_progress
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

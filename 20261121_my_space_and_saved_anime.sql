-- AnimeNova My Space: private watchlist/favourites and safe profile editing.
-- Run once in Supabase SQL Editor after the player progress migration.

create table if not exists public.saved_anime (
  user_id uuid not null references auth.users(id) on delete cascade,
  anime_id uuid not null references public.anime(id) on delete cascade,
  saved_type text not null check (saved_type in ('watchlist','favourite')),
  created_at timestamptz not null default now(),
  primary key (user_id, anime_id, saved_type)
);

alter table public.saved_anime enable row level security;
drop policy if exists "users manage own saved anime" on public.saved_anime;
create policy "users manage own saved anime" on public.saved_anime
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Allow a user to update their own display name, but never their role.
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
create policy "users update own profile" on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

create index if not exists saved_anime_user_type_idx
  on public.saved_anime (user_id, saved_type, created_at desc);

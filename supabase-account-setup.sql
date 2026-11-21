-- Game Vault V1.5.3: email-authenticated, per-user cloud storage.
-- Run once in Supabase SQL Editor for the Game Vault project.
create table if not exists public.gv_account_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.gv_account_data enable row level security;
revoke all on public.gv_account_data from anon;
grant select,insert,update,delete on public.gv_account_data to authenticated;
drop policy if exists gv_account_select on public.gv_account_data;
drop policy if exists gv_account_insert on public.gv_account_data;
drop policy if exists gv_account_update on public.gv_account_data;
drop policy if exists gv_account_delete on public.gv_account_data;
create policy gv_account_select on public.gv_account_data for select to authenticated using ((select auth.uid()) = user_id);
create policy gv_account_insert on public.gv_account_data for insert to authenticated with check ((select auth.uid()) = user_id);
create policy gv_account_update on public.gv_account_data for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy gv_account_delete on public.gv_account_data for delete to authenticated using ((select auth.uid()) = user_id);

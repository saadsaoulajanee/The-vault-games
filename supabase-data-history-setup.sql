-- The Game Vault: last five DATA snapshots per signed-in account.
-- Run once in the same Supabase project as supabase-account-setup.sql.
create table if not exists public.gv_data_versions (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 data jsonb not null,
 label text not null default 'Manual snapshot',
 created_at timestamptz not null default now()
);
create index if not exists gv_data_versions_user_created on public.gv_data_versions(user_id,created_at desc);
alter table public.gv_data_versions enable row level security;
revoke all on public.gv_data_versions from anon;
grant select,insert,delete on public.gv_data_versions to authenticated;
drop policy if exists gv_versions_select on public.gv_data_versions;
drop policy if exists gv_versions_insert on public.gv_data_versions;
drop policy if exists gv_versions_delete on public.gv_data_versions;
create policy gv_versions_select on public.gv_data_versions for select to authenticated using ((select auth.uid())=user_id);
create policy gv_versions_insert on public.gv_data_versions for insert to authenticated with check ((select auth.uid())=user_id);
create policy gv_versions_delete on public.gv_data_versions for delete to authenticated using ((select auth.uid())=user_id);
create or replace function public.gv_trim_versions() returns trigger language plpgsql security definer set search_path='' as $$
begin
 delete from public.gv_data_versions where id in (
  select id from public.gv_data_versions where user_id=new.user_id
  order by created_at desc,id desc offset 5
 );
 return new;
end$$;
drop trigger if exists gv_versions_keep_five on public.gv_data_versions;
create trigger gv_versions_keep_five after insert on public.gv_data_versions for each row execute function public.gv_trim_versions();

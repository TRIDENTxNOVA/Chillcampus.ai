-- Private learner data and AI request throttling for Chill Campus.ai.
-- Apply with: supabase db push
create table if not exists public.learner_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint learner_state_object check (jsonb_typeof(state) = 'object')
);

alter table public.learner_state enable row level security;
grant select, insert, update on public.learner_state to authenticated;
revoke all on public.learner_state from anon;

create policy "Learners can read their own state"
  on public.learner_state for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Learners can create their own state"
  on public.learner_state for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Learners can update their own state"
  on public.learner_state for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- Keep uploaded files private and scoped to a learner's own folder.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'learner-uploads',
  'learner-uploads',
  false,
  10485760,
  array['application/pdf','text/plain','image/png','image/jpeg']
)
on conflict (id) do update set
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "Learners can list their own uploads"
  on storage.objects for select to authenticated
  using (bucket_id = 'learner-uploads' and (storage.foldername(name))[1] = (select auth.uid()::text));

create policy "Learners can upload to their own folder"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'learner-uploads' and (storage.foldername(name))[1] = (select auth.uid()::text));

create policy "Learners can delete their own uploads"
  on storage.objects for delete to authenticated
  using (bucket_id = 'learner-uploads' and (storage.foldername(name))[1] = (select auth.uid()::text));

-- The AI function uses the service role to enforce a rolling per-account request limit.
create table if not exists public.ai_request_windows (
  user_id uuid not null references auth.users(id) on delete cascade,
  window_started_at timestamptz not null,
  request_count integer not null default 0 check (request_count >= 0),
  primary key (user_id, window_started_at)
);
alter table public.ai_request_windows enable row level security;
revoke all on public.ai_request_windows from anon, authenticated;
grant all on public.ai_request_windows to service_role;

create or replace function public.consume_ai_request(
  p_user_id uuid,
  p_window_seconds integer default 60,
  p_max_requests integer default 12
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_window timestamptz;
  v_count integer;
begin
  if p_window_seconds < 1 or p_max_requests < 1 then
    return false;
  end if;
  v_window := to_timestamp(floor(extract(epoch from clock_timestamp()) / p_window_seconds) * p_window_seconds);
  delete from public.ai_request_windows where window_started_at < clock_timestamp() - interval '7 days';
  insert into public.ai_request_windows(user_id, window_started_at, request_count)
  values (p_user_id, v_window, 1)
  on conflict (user_id, window_started_at)
  do update set request_count = public.ai_request_windows.request_count + 1
  returning request_count into v_count;
  return v_count <= p_max_requests;
end;
$$;
revoke all on function public.consume_ai_request(uuid, integer, integer) from public, anon, authenticated;
grant execute on function public.consume_ai_request(uuid, integer, integer) to service_role;

-- Add optimistic concurrency control so concurrent devices cannot silently overwrite learner state.
alter table public.learner_state
  add column if not exists revision bigint not null default 1;

create or replace function public.save_learner_state(
  p_expected_revision bigint,
  p_state jsonb
)
returns table(saved_revision bigint, saved_state jsonb)
language plpgsql
security invoker
set search_path = ''
as $function$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception using errcode = '28000', message = 'authentication required';
  end if;

  if p_state is null or jsonb_typeof(p_state) <> 'object' then
    raise exception using errcode = '22023', message = 'state must be a JSON object';
  end if;

  return query
    insert into public.learner_state as current_state (user_id, state, updated_at, revision)
    values (v_user_id, p_state, now(), 1)
    on conflict (user_id) do update
      set state = excluded.state,
          updated_at = now(),
          revision = current_state.revision + 1
      where current_state.revision = p_expected_revision
    returning current_state.revision, current_state.state;
end;
$function$;

revoke all on function public.save_learner_state(bigint, jsonb) from public, anon;
grant execute on function public.save_learner_state(bigint, jsonb) to authenticated;

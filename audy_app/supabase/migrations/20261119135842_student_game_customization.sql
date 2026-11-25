alter table public.child_game_configs
  add column applies_to_student boolean not null default false,
  add constraint child_game_configs_student_game check (
    not applies_to_student or game_key in ('flashcard', 'minipuzzle', 'emotion', 'fruit_catching_bear')
  );

create function caretaker_private.save_config(
  target_child uuid, target_game text, config_payload jsonb,
  expected_revision integer, apply_to_student boolean
) returns integer
language plpgsql security definer set search_path = '' as $$
declare
  actor uuid := caretaker_private.assert_adult();
  saved public.child_game_configs;
  next_revision integer;
begin
  perform 1 from public.caretaker_preferences where caretaker_id = actor for update;
  if not exists (
    select 1 from public.caretaker_children c join public.profiles p on p.id = c.child_id
    where c.caretaker_id = actor and c.child_id = target_child and c.is_in_care and p.role = 'child'
  ) then
    raise exception using errcode = '42501', message = 'Child is not in your care list';
  end if;
  if not caretaker_private.valid_config(target_game, config_payload)
      or (apply_to_student is true and target_game not in ('flashcard', 'minipuzzle', 'emotion', 'fruit_catching_bear')) then
    raise exception using errcode = '22023', message = 'Invalid game configuration';
  end if;

  perform pg_advisory_xact_lock(hashtextextended(target_child::text || target_game, 0));
  select * into saved from public.child_game_configs
    where child_id = target_child and game_key = target_game for update;
  if coalesce(saved.revision, 0) is distinct from expected_revision then
    raise exception using errcode = '40001', message = 'Configuration revision conflict';
  end if;
  -- The pre-activation client may still edit a preview but cannot change a live profile.
  if apply_to_student is null and saved.applies_to_student is true then
    raise exception using errcode = '0A000', message = 'Update AUDY to edit settings used in Student play';
  end if;

  next_revision := coalesce(saved.revision, 0) + 1;
  insert into public.child_game_configs (child_id, game_key, payload, revision, updated_by, applies_to_student)
  values (target_child, target_game, config_payload, next_revision, actor, coalesce(apply_to_student, false))
  on conflict (child_id, game_key) do update set
    payload = excluded.payload, revision = excluded.revision, updated_by = actor,
    updated_at = now(), applies_to_student = excluded.applies_to_student;
  return next_revision;
end $$;

create or replace function caretaker_private.save_config(
  target_child uuid, target_game text, config_payload jsonb, expected_revision integer
) returns integer
language sql security invoker set search_path = '' as $$
  select caretaker_private.save_config(target_child, target_game, config_payload, expected_revision, null)
$$;

create function public.caretaker_save_student_game_config(
  target_child uuid, target_game text, config_payload jsonb,
  expected_revision integer, apply_to_student boolean
) returns integer
language sql security invoker set search_path = '' as $$
  select caretaker_private.save_config(target_child, target_game, config_payload, expected_revision, apply_to_student)
$$;

create function caretaker_private.student_game_config(target_game text, known_revision integer)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  actor uuid := auth.uid();
  saved public.child_game_configs;
begin
  if actor is null or not exists (select 1 from public.profiles where id = actor and role = 'child') then
    raise exception using errcode = '42501', message = 'Student access required';
  end if;
  if target_game is null or target_game not in ('flashcard', 'minipuzzle', 'emotion', 'fruit_catching_bear') then
    return jsonb_build_object('status', 'default');
  end if;
  select * into saved from public.child_game_configs
    where child_id = actor and game_key = target_game and applies_to_student;
  if not found then
    return jsonb_build_object('status', 'default');
  end if;
  if saved.revision = known_revision then
    return jsonb_build_object('status', 'unchanged', 'revision', saved.revision);
  end if;
  return jsonb_build_object('status', 'active', 'payload', saved.payload,
    'schema_version', saved.schema_version, 'revision', saved.revision);
end $$;

create function public.student_game_config(target_game text, known_revision integer)
returns jsonb language sql stable security invoker set search_path = '' as $$
  select caretaker_private.student_game_config(target_game, known_revision)
$$;

revoke all on function caretaker_private.save_config(uuid,text,jsonb,integer,boolean),
  public.caretaker_save_student_game_config(uuid,text,jsonb,integer,boolean),
  caretaker_private.student_game_config(text,integer), public.student_game_config(text,integer)
from public, anon;
grant execute on function caretaker_private.save_config(uuid,text,jsonb,integer,boolean),
  public.caretaker_save_student_game_config(uuid,text,jsonb,integer,boolean),
  caretaker_private.student_game_config(text,integer), public.student_game_config(text,integer)
to authenticated;

notify pgrst, 'reload schema';

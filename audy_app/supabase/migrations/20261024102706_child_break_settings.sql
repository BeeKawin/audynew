-- Break thresholds are separate from preview-only game settings.
create table public.child_break_settings (
  child_id uuid primary key references public.profiles(id) on delete cascade,
  games_before_break integer not null default 5 check(games_before_break between 1 and 20),
  schema_version integer not null default 1 check(schema_version > 0),
  revision integer not null default 1 check(revision > 0),
  updated_by uuid references public.profiles(id) on delete set null,
  updated_at timestamptz not null default now()
);
create index child_break_settings_updated_by_idx on public.child_break_settings(updated_by);
alter table public.child_break_settings enable row level security;
revoke all on public.child_break_settings from public,anon,authenticated;
grant select on public.child_break_settings to authenticated;
create policy caretaker_read_break_settings on public.child_break_settings
for select to authenticated using(caretaker_private.can_read_config(child_id));

create function caretaker_private.save_break_settings(target_child uuid, game_threshold integer, expected_revision integer)
returns jsonb language plpgsql security definer set search_path='' as $$
declare actor uuid := caretaker_private.assert_adult(); saved public.child_break_settings;
begin
  if game_threshold is null or game_threshold not between 1 and 20 or expected_revision is null or expected_revision < 0 then
    raise exception using errcode='22023',message='Use a threshold between 1 and 20 games';
  end if;
  if not exists(select 1 from public.caretaker_children c join public.profiles p on p.id=c.child_id
    where c.caretaker_id=actor and c.child_id=target_child and c.is_in_care and p.role='child') then
    raise exception using errcode='42501',message='Child is not in your care list';
  end if;
  if expected_revision=0 then
    insert into public.child_break_settings(child_id,games_before_break,updated_by)
    values(target_child,game_threshold,actor) on conflict(child_id) do nothing returning * into saved;
  else
    update public.child_break_settings set games_before_break=game_threshold,
      revision=revision+1,updated_by=actor,updated_at=now()
    where child_id=target_child and revision=expected_revision and schema_version=1 returning * into saved;
  end if;
  if saved.child_id is null then
    raise exception using errcode='40001',message='Reload the latest break settings before saving';
  end if;
  return to_jsonb(saved);
end $$;
create function public.caretaker_save_break_settings(target_child uuid, game_threshold integer, expected_revision integer)
returns jsonb language sql security invoker set search_path='' as $$
  select caretaker_private.save_break_settings(target_child,game_threshold,expected_revision)
$$;

create function caretaker_private.student_break_settings() returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare actor uuid:=auth.uid(); result jsonb;
begin
  if actor is null or not exists(select 1 from public.profiles where id=actor and role='child') then
    raise exception using errcode='42501',message='Student access required';
  end if;
  select jsonb_build_object('games_before_break',s.games_before_break,'schema_version',s.schema_version,'revision',s.revision)
    into result from public.child_break_settings s where s.child_id=actor;
  return coalesce(result,jsonb_build_object('games_before_break',5,'schema_version',1,'revision',0));
end $$;
create function public.student_break_settings() returns jsonb
language sql stable security invoker set search_path='' as $$ select caretaker_private.student_break_settings() $$;

revoke all on function caretaker_private.save_break_settings(uuid,integer,integer),
  public.caretaker_save_break_settings(uuid,integer,integer),
  caretaker_private.student_break_settings(),public.student_break_settings() from public,anon;
grant execute on function caretaker_private.save_break_settings(uuid,integer,integer),
  public.caretaker_save_break_settings(uuid,integer,integer),
  caretaker_private.student_break_settings(),public.student_break_settings() to authenticated;

-- Additive: legacy role values, analytical policies and game tables are untouched.
create schema if not exists caretaker_private;
revoke all on schema caretaker_private from public, anon;
grant usage on schema caretaker_private to authenticated;

create table public.caretaker_children (
  caretaker_id uuid not null references public.profiles(id) on delete cascade,
  child_id uuid not null references public.profiles(id) on delete cascade,
  legacy_parent boolean not null default false,
  legacy_teacher boolean not null default false,
  direct_link boolean not null default false,
  is_in_care boolean not null default false,
  created_at timestamptz not null default now(),
  primary key(caretaker_id,child_id),
  check(caretaker_id<>child_id),
  check(legacy_parent or legacy_teacher or direct_link)
);
create index caretaker_children_child_idx on public.caretaker_children(child_id);
create table public.caretaker_preferences (
  caretaker_id uuid primary key references public.profiles(id) on delete cascade,
  planned_child_count integer not null default 1 check(planned_child_count>=0),
  revision integer not null default 1 check(revision>0),
  updated_at timestamptz not null default now()
);
create table public.child_game_configs (
  child_id uuid not null references public.profiles(id) on delete cascade,
  game_key text not null check(game_key in ('social_chat','flashcard','minipuzzle','emotion','fruit_catching_bear')),
  schema_version integer not null default 1 check(schema_version=1),
  payload jsonb not null,
  revision integer not null default 1 check(revision>0),
  updated_by uuid references public.profiles(id) on delete set null,
  updated_at timestamptz not null default now(),
  primary key(child_id,game_key)
);
create index child_game_configs_updated_by_idx on public.child_game_configs(updated_by);
alter table public.caretaker_children enable row level security;
alter table public.caretaker_preferences enable row level security;
alter table public.child_game_configs enable row level security;
revoke all on public.caretaker_children,public.caretaker_preferences,public.child_game_configs from anon,authenticated;
grant select on public.caretaker_children,public.caretaker_preferences,public.child_game_configs to authenticated;

create function caretaker_private.assert_adult() returns uuid
language plpgsql security definer set search_path='' as $$
declare actor uuid:=auth.uid();
begin
  if actor is null or not exists(select 1 from public.profiles where id=actor and role in ('parent','teacher','caretaker')) then
    raise exception using errcode='42501',message='Caretaker access required';
  end if;
  return actor;
end $$;
create policy caretaker_own_links on public.caretaker_children for select to authenticated
using(caretaker_id=(select auth.uid()));
create policy caretaker_own_preferences on public.caretaker_preferences for select to authenticated
using(caretaker_id=(select auth.uid()));
create function caretaker_private.can_read_config(target uuid) returns boolean
language sql stable security definer set search_path='' as $$
  select exists(select 1 from public.caretaker_children c join public.profiles p on p.id=c.caretaker_id
    where c.caretaker_id=(select auth.uid()) and c.child_id=target and p.role in ('parent','teacher','caretaker'));
$$;
create policy caretaker_linked_config on public.child_game_configs for select to authenticated
using(caretaker_private.can_read_config(child_id));

-- Retain both sources if one account appears in both old relationship fields.
insert into public.caretaker_children(caretaker_id,child_id,legacy_parent,legacy_teacher,is_in_care)
select adult.id,child.id,coalesce(bool_or(child.parent_id=adult.id),false),coalesce(bool_or(child.teacher_id=adult.id),false),true
from public.profiles child join public.profiles adult on adult.id in (child.parent_id,child.teacher_id)
where child.role='child' and adult.role in ('parent','teacher','caretaker') and child.id<>adult.id
group by adult.id,child.id;
insert into public.caretaker_preferences(caretaker_id,planned_child_count)
select p.id,count(c.child_id)::integer from public.profiles p left join public.caretaker_children c on c.caretaker_id=p.id
where p.role in ('parent','teacher','caretaker') group by p.id;

create function caretaker_private.roster() returns jsonb
language plpgsql security definer set search_path='' as $$
declare actor uuid:=caretaker_private.assert_adult(); result jsonb;
begin
  insert into public.caretaker_preferences(caretaker_id) values(actor) on conflict do nothing;
  select jsonb_build_object('planned_count',p.planned_child_count,'revision',p.revision,'children',
    coalesce((select jsonb_agg(jsonb_build_object('id',ch.id,'name',ch.name,'age',ch.age,'created_at',ch.created_at,'is_in_care',c.is_in_care)
      order by ch.created_at,ch.id) from public.caretaker_children c join public.profiles ch on ch.id=c.child_id
      where c.caretaker_id=actor and ch.role='child'),'[]'::jsonb)) into result
  from public.caretaker_preferences p where p.caretaker_id=actor;
  return result;
end $$;
create function public.caretaker_roster() returns jsonb language sql security invoker set search_path='' as $$select caretaker_private.roster()$$;

create function caretaker_private.link_child(child_email text) returns void
language plpgsql security definer set search_path='' as $$
declare actor uuid:=caretaker_private.assert_adult(); target uuid; affected integer;
begin
  select id into target from public.profiles where role='child' and lower(email)=lower(trim(child_email));
  if target is null then raise exception using errcode='22023',message='Child account unavailable'; end if;
  insert into public.caretaker_preferences(caretaker_id) values(actor) on conflict do nothing;
  perform 1 from public.caretaker_preferences where caretaker_id=actor for update;
  insert into public.caretaker_children(caretaker_id,child_id,direct_link) values(actor,target,true)
  on conflict(caretaker_id,child_id) do update set direct_link=true where not caretaker_children.direct_link;
  get diagnostics affected=row_count;
  if affected>0 then update public.caretaker_preferences set revision=revision+1,updated_at=now() where caretaker_id=actor; end if;
end $$;
create function public.caretaker_link_child(child_email text) returns void language sql security invoker set search_path='' as $$select caretaker_private.link_child(child_email)$$;

create function caretaker_private.save_roster(planned_count integer,child_ids uuid[],expected_revision integer) returns void
language plpgsql security definer set search_path='' as $$
declare actor uuid:=caretaker_private.assert_adult(); current_revision integer;
begin
  select revision into current_revision from public.caretaker_preferences where caretaker_id=actor for update;
  if current_revision is distinct from expected_revision then raise exception using errcode='40001',message='Roster revision conflict';end if;
  if planned_count is null or planned_count<0 or child_ids is null or cardinality(child_ids)>planned_count
    or cardinality(child_ids)<>(select count(distinct x) from unnest(child_ids) x)
    or exists(select 1 from unnest(child_ids) id where not exists(select 1 from public.caretaker_children c join public.profiles p on p.id=c.child_id where c.caretaker_id=actor and c.child_id=id and p.role='child')) then
    raise exception using errcode='22023',message='Invalid care list';
  end if;
  update public.caretaker_children set is_in_care=(child_id=any(child_ids)) where caretaker_id=actor;
  update public.caretaker_preferences set planned_child_count=planned_count,revision=revision+1,updated_at=now() where caretaker_id=actor;
end $$;
create function public.caretaker_save_roster(planned_count integer,child_ids uuid[],expected_revision integer) returns void language sql security invoker set search_path='' as $$select caretaker_private.save_roster(planned_count,child_ids,expected_revision)$$;

create function caretaker_private.valid_subset(value jsonb,allowed jsonb,minimum integer) returns boolean
language sql immutable set search_path='' as $$
select jsonb_typeof(value)='array' and jsonb_array_length(value)>=minimum and value<@allowed
and jsonb_array_length(value)=(select count(distinct x) from jsonb_array_elements(value) x);
$$;
create function caretaker_private.valid_config(game text,p jsonb) returns boolean
language plpgsql immutable set search_path='' as $$
declare card jsonb; image text; item jsonb; field text; allowed text[];
begin
  if p is null or jsonb_typeof(p)<>'object' or octet_length(p::text)>2097152 then return false;end if;
  case game
  when 'social_chat' then
    if not (p->>'input_mode'=any(array['text_and_voice','text_only']) and p->>'reply_speech'=any(array['automatic','on_tap']) and p->'listen_seconds'<@'[15,30,45]'::jsonb and p->'pause_seconds'<@'[3,5,8]'::jsonb and jsonb_typeof(p->'starter_phrases')='array' and jsonb_array_length(p->'starter_phrases')<=6) then return false;end if;
    for item in select * from jsonb_array_elements(p->'starter_phrases') loop if jsonb_typeof(item)<>'string' or length(trim(item#>>'{}')) not between 1 and 80 or (item#>>'{}')<>trim(item#>>'{}') then return false;end if;end loop;
    if (select count(*)<>count(distinct x) from jsonb_array_elements(p->'starter_phrases') x) then return false;end if;
    allowed:=array['input_mode','reply_speech','listen_seconds','pause_seconds','starter_phrases'];
  when 'flashcard' then
    if not(p->>'difficulty'=any(array['child_choice','easy','medium','hard']) and p->>'language'=any(array['app','en','th']) and p->>'preview_pace'=any(array['2_seconds','3_seconds','5_seconds','manual']) and jsonb_typeof(p->'auto_speak')='boolean' and jsonb_typeof(p->'use_custom_cards')='boolean' and jsonb_typeof(p->'custom_cards')='array' and jsonb_array_length(p->'custom_cards')<=20) then return false;end if;
    if p->'use_custom_cards'='true'::jsonb and jsonb_array_length(p->'custom_cards')=0 then return false;end if;
    for card in select * from jsonb_array_elements(p->'custom_cards') loop
      if jsonb_typeof(card)<>'object' or jsonb_typeof(card->'id')<>'string' or length(card->>'id') not between 1 and 64 or jsonb_typeof(card->'word')<>'string' or length(trim(card->>'word')) not between 1 and 40 or not(card->>'category'=any(array['noun','pronoun','verb','adjective','adverb'])) then return false;end if;
      image:=card->>'image_url';
      if image is not null and image<>'' then
        if image like 'data:image/jpeg;base64,%' or image like 'data:image/png;base64,%' then
          if octet_length(decode(split_part(image,',',2),'base64'))>131072 then return false;end if;
        elsif image!~'^assets/images/games/flashcard/[a-zA-Z0-9_/-]+\.png$' then return false;
        end if;
      end if;
    end loop;
    if (select count(*)<>count(distinct x->>'id') or count(*)<>count(distinct ((x->>'category')||':'||lower(trim(x->>'word')))) from jsonb_array_elements(p->'custom_cards') x) then return false;end if;
    allowed:=array['difficulty','language','preview_pace','auto_speak','use_custom_cards','custom_cards'];
  when 'minipuzzle' then
    if not caretaker_private.valid_subset(p->'enabled_types','["pattern","oddOneOut","puzzle"]',1) then return false;end if;
    foreach field in array array['pattern_difficulty','odd_one_out_difficulty','puzzle_difficulty'] loop if not(p->>field=any(array['child_choice','easy','medium','hard'])) then return false;end if;end loop;
    if not(p->>'advance_mode'=any(array['automatic_900ms','automatic_1800ms','manual']) and jsonb_typeof(p->'show_guide')='boolean') then return false;end if;
    allowed:=array['enabled_types','pattern_difficulty','odd_one_out_difficulty','puzzle_difficulty','advance_mode','show_guide'];
  when 'emotion' then
    if not(caretaker_private.valid_subset(p->'target_emotions','["happy","sad","angry","scared"]',2) and p->'choice_count'<@'[2,4]'::jsonb and p->'round_count'<@'[1,3,5]'::jsonb and (p->>'choice_count')::integer<=jsonb_array_length(p->'target_emotions') and p->>'image_mode'=any(array['varied','consistent']) and p->>'advance_mode'=any(array['automatic_1500ms','automatic_3000ms','manual']) and jsonb_typeof(p->'show_guide')='boolean') then return false;end if;
    allowed:=array['target_emotions','choice_count','round_count','image_mode','advance_mode','show_guide'];
  when 'fruit_catching_bear' then
    if not(p->>'fall_speed'=any(array['slow','standard','fast']) and p->'spawn_interval_ms'<@'[900,1200,1500]'::jsonb and p->'bomb_probability'<@'[0,0.1,0.2]'::jsonb and p->'bomb_grace_count'<@'[2,5,10]'::jsonb and p->'duration_seconds'<@'[null,30,60,120]'::jsonb and caretaker_private.valid_subset(p->'fruit_ids','["4","5","6","7","8","9"]',1) and jsonb_typeof(p->'show_guide')='boolean') then return false;end if;
    if p->'bomb_probability'='0'::jsonb and p->'duration_seconds'='null'::jsonb then return false;end if;
    allowed:=array['fall_speed','spawn_interval_ms','bomb_probability','bomb_grace_count','duration_seconds','fruit_ids','show_guide'];
  else return false;
  end case;
  -- Required fields must exist; SQL NULL must never bypass a validation branch.
  if not(p ?& allowed) or exists(select 1 from jsonb_object_keys(p) k where not(k=any(allowed))) then return false;end if;
  foreach field in array allowed loop
    if p->field='null'::jsonb and field<>'duration_seconds' then return false;end if;
    if field=any(array['listen_seconds','pause_seconds','choice_count','round_count','spawn_interval_ms','bomb_grace_count']) and (jsonb_typeof(p->field)<>'number' or (p->>field)!~'^[0-9]+$') then return false;end if;
    if field='bomb_probability' and jsonb_typeof(p->field)<>'number' then return false;end if;
    if field='duration_seconds' and (jsonb_typeof(p->field) not in ('null','number') or (jsonb_typeof(p->field)='number' and (p->>field)!~'^[0-9]+$')) then return false;end if;
  end loop;
  return true;
exception when others then return false;
end $$;

alter table public.child_game_configs add constraint child_game_config_valid check(caretaker_private.valid_config(game_key,payload));
create function caretaker_private.save_config(target_child uuid,target_game text,config_payload jsonb,expected_revision integer) returns integer
language plpgsql security definer set search_path='' as $$
declare actor uuid:=caretaker_private.assert_adult(); current_revision integer; next_revision integer;
begin
  -- Serializes saves, first inserts and revocation of this Caretaker's care selection.
  perform 1 from public.caretaker_preferences where caretaker_id=actor for update;
  if not exists(select 1 from public.caretaker_children c join public.profiles p on p.id=c.child_id where c.caretaker_id=actor and c.child_id=target_child and c.is_in_care and p.role='child') then raise exception using errcode='42501',message='Child is not in your care list';end if;
  if not caretaker_private.valid_config(target_game,config_payload) then raise exception using errcode='22023',message='Invalid game configuration';end if;
  perform pg_advisory_xact_lock(hashtextextended(target_child::text||target_game,0));
  select revision into current_revision from public.child_game_configs where child_id=target_child and game_key=target_game for update;
  if coalesce(current_revision,0) is distinct from expected_revision then raise exception using errcode='40001',message='Configuration revision conflict';end if;
  next_revision:=coalesce(current_revision,0)+1;
  insert into public.child_game_configs(child_id,game_key,payload,revision,updated_by) values(target_child,target_game,config_payload,next_revision,actor)
  on conflict(child_id,game_key) do update set payload=excluded.payload,revision=excluded.revision,updated_by=actor,updated_at=now();
  return next_revision;
end $$;
create function public.caretaker_save_config(target_child uuid,target_game text,config_payload jsonb,expected_revision integer) returns integer language sql security invoker set search_path='' as $$select caretaker_private.save_config(target_child,target_game,config_payload,expected_revision)$$;

create function caretaker_private.sync_legacy_links() returns trigger
language plpgsql security definer set search_path='' as $$
declare actor uuid;
begin
  -- Lock affected adult preferences in stable order before changing associations.
  for actor in select distinct id from unnest(array[old.parent_id,old.teacher_id,new.parent_id,new.teacher_id]) id where id is not null order by id loop
    insert into public.caretaker_preferences(caretaker_id,planned_child_count) select actor,0 from public.profiles where id=actor and role in ('parent','teacher','caretaker') on conflict do nothing;
    perform 1 from public.caretaker_preferences where caretaker_id=actor for update;
    delete from public.caretaker_children where caretaker_id=actor and child_id=new.id and not direct_link and (new.role<>'child' or (new.parent_id is distinct from actor and new.teacher_id is distinct from actor));
    update public.caretaker_children set legacy_parent=(new.role='child' and new.parent_id is not distinct from actor),legacy_teacher=(new.role='child' and new.teacher_id is not distinct from actor) where caretaker_id=actor and child_id=new.id;
    if new.role='child' and actor in (new.parent_id,new.teacher_id) then
      insert into public.caretaker_children(caretaker_id,child_id,legacy_parent,legacy_teacher)
      select actor,new.id,new.parent_id is not distinct from actor,new.teacher_id is not distinct from actor from public.profiles where id=actor and role in ('parent','teacher','caretaker') and actor<>new.id
      on conflict(caretaker_id,child_id) do update set legacy_parent=excluded.legacy_parent,legacy_teacher=excluded.legacy_teacher;
    end if;
    update public.caretaker_preferences set revision=revision+1,updated_at=now() where caretaker_id=actor;
  end loop;
  return new;
end $$;
create trigger caretaker_sync_legacy after insert or update of parent_id,teacher_id,role on public.profiles for each row execute function caretaker_private.sync_legacy_links();

-- New authorization uses the stored role, so direct client role changes are forbidden.
create function caretaker_private.protect_role() returns trigger language plpgsql set search_path='' as $$
begin
  if auth.uid() is not null and new.role is distinct from old.role then raise exception using errcode='42501',message='Role changes require an administrator';end if;
  return new;
end $$;
create trigger caretaker_protect_role before update of role on public.profiles for each row execute function caretaker_private.protect_role();

revoke all on all functions in schema caretaker_private from public,anon,authenticated;
grant execute on function caretaker_private.roster(),caretaker_private.link_child(text),caretaker_private.save_roster(integer,uuid[],integer),caretaker_private.save_config(uuid,text,jsonb,integer),caretaker_private.can_read_config(uuid) to authenticated;
revoke all on function public.caretaker_roster(),public.caretaker_link_child(text),public.caretaker_save_roster(integer,uuid[],integer),public.caretaker_save_config(uuid,text,jsonb,integer) from public,anon;
grant execute on function public.caretaker_roster(),public.caretaker_link_child(text),public.caretaker_save_roster(integer,uuid[],integer),public.caretaker_save_config(uuid,text,jsonb,integer) to authenticated;
notify pgrst,'reload schema';

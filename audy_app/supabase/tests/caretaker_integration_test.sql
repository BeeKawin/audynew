-- Run in a transaction; fixtures and all their writes are rolled back.
insert into auth.users(id,email,raw_user_meta_data) values
('11111111-1111-4111-8111-111111111111','caretaker-fixture@invalid.test','{"name":"Caretaker fixture","age":0,"role":"caretaker"}'),
('22222222-2222-4222-8222-222222222222','child-fixture@invalid.test','{"name":"Child fixture","age":8,"role":"child"}'),
('33333333-3333-4333-8333-333333333333','other-fixture@invalid.test','{"name":"Other fixture","age":0,"role":"teacher"}');

do $$begin
  if not caretaker_private.valid_config('emotion','{"target_emotions":["happy","sad","angry","scared"],"choice_count":4,"round_count":3,"image_mode":"varied","advance_mode":"manual","show_guide":true}') then raise exception 'valid emotion rejected';end if;
  if caretaker_private.valid_config('emotion','{"target_emotions":["happy","sad"],"choice_count":4,"round_count":3,"image_mode":"varied","advance_mode":"manual","show_guide":true}') then raise exception 'invalid choice count accepted';end if;
  if caretaker_private.valid_config('flashcard','{}') then raise exception 'missing fields accepted';end if;
  if caretaker_private.valid_config('fruit_catching_bear','{"fall_speed":"standard","spawn_interval_ms":900,"bomb_probability":0,"bomb_grace_count":2,"duration_seconds":null,"fruit_ids":["4"],"show_guide":true}') then raise exception 'unbounded bomb-free game accepted';end if;
end $$;

set local role authenticated;
select set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
select public.caretaker_roster();
select public.caretaker_link_child('CHILD-FIXTURE@invalid.test');
select public.caretaker_link_child('child-fixture@invalid.test');
do $$declare r jsonb;begin
  r:=public.caretaker_roster();
  if jsonb_array_length(r->'children')<>1 then raise exception 'duplicate child link';end if;
  perform public.caretaker_save_roster(2,array['22222222-2222-4222-8222-222222222222']::uuid[],(r->>'revision')::integer);
end $$;
select public.caretaker_save_config('22222222-2222-4222-8222-222222222222','social_chat','{"input_mode":"text_only","reply_speech":"on_tap","listen_seconds":30,"pause_seconds":3,"starter_phrases":[]}',0);
do $$begin
  if (select count(*) from public.child_game_configs where child_id='22222222-2222-4222-8222-222222222222')<>1 then raise exception 'linked config not readable';end if;
  begin
    perform public.caretaker_save_config('22222222-2222-4222-8222-222222222222','social_chat','{"input_mode":"text_only","reply_speech":"on_tap","listen_seconds":30,"pause_seconds":3,"starter_phrases":[]}',0);
    raise exception 'stale revision accepted';
  exception when serialization_failure then null;end;
  begin
    update public.child_game_configs set revision=99;
    raise exception 'direct configuration write allowed';
  exception when insufficient_privilege then null;end;
  begin
    update public.profiles set role='child' where id=auth.uid();
    raise exception 'client role change allowed';
  exception when insufficient_privilege then null;end;
end $$;

select set_config('request.jwt.claim.sub','33333333-3333-4333-8333-333333333333',true);
do $$begin
  if exists(select 1 from public.child_game_configs where child_id='22222222-2222-4222-8222-222222222222') then raise exception 'unlinked account can read child config';end if;
  begin
    perform public.caretaker_save_config('22222222-2222-4222-8222-222222222222','social_chat','{}',1);
    raise exception 'unlinked account wrote config';
  exception when insufficient_privilege then null;end;
end $$;
select public.caretaker_link_child('child-fixture@invalid.test');
do $$declare r jsonb;begin r:=public.caretaker_roster();perform public.caretaker_save_roster(1,array['22222222-2222-4222-8222-222222222222']::uuid[],(r->>'revision')::integer);end $$;
select public.caretaker_save_config('22222222-2222-4222-8222-222222222222','social_chat','{"input_mode":"text_and_voice","reply_speech":"automatic","listen_seconds":45,"pause_seconds":5,"starter_phrases":["hello"]}',1);

select set_config('request.jwt.claim.sub','22222222-2222-4222-8222-222222222222',true);
do $$begin
  if exists(select 1 from public.child_game_configs where child_id=auth.uid()) then raise exception 'Student can read preview settings';end if;
  begin perform public.caretaker_roster();raise exception 'Student can use Caretaker RPC';exception when insufficient_privilege then null;end;
end $$;
reset role;
select set_config('request.jwt.claim.sub','',true);
-- Legacy changes must update provenance without changing the new direct links.
update public.profiles set teacher_id='33333333-3333-4333-8333-333333333333' where id='22222222-2222-4222-8222-222222222222';
update public.profiles set teacher_id=null where id='22222222-2222-4222-8222-222222222222';
do $$begin
  if not exists(select 1 from public.caretaker_children where caretaker_id='33333333-3333-4333-8333-333333333333' and child_id='22222222-2222-4222-8222-222222222222' and direct_link and not legacy_teacher) then raise exception 'legacy sync removed direct relationship';end if;
  if exists(select 1 from public.game_sessions where student_id='22222222-2222-4222-8222-222222222222') then raise exception 'configuration wrote analytical sessions';end if;
end $$;
set local role anon;
do $$begin
  begin perform public.caretaker_roster();raise exception 'anonymous RPC execution allowed';exception when insufficient_privilege then null;end;
end $$;
reset role;
select 'Caretaker database integration checks passed' as result;

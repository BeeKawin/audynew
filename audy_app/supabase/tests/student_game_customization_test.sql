-- Run inside a transaction and roll back the fixture accounts.
insert into auth.users (id, email, raw_user_meta_data) values
('63300000-0000-4000-8000-000000000001', 'cfg-adult@invalid.test', '{"name":"Caretaker","age":0,"role":"caretaker"}'),
('63300000-0000-4000-8000-000000000002', 'cfg-child@invalid.test', '{"name":"Student A","age":8,"role":"child"}'),
('63300000-0000-4000-8000-000000000003', 'cfg-other@invalid.test', '{"name":"Student B","age":9,"role":"child"}');

select set_config('audy.test_emotion', '{"target_emotions":["happy","sad"],"choice_count":2,"round_count":5,"image_mode":"consistent","advance_mode":"manual","show_guide":false}', true);
set local role authenticated;
select set_config('request.jwt.claim.sub', '63300000-0000-4000-8000-000000000001', true);
select public.caretaker_link_child('cfg-child@invalid.test');
select public.caretaker_save_roster(
  1, array['63300000-0000-4000-8000-000000000002']::uuid[],
  (public.caretaker_roster()->>'revision')::int
);
select public.caretaker_save_config(
  '63300000-0000-4000-8000-000000000002', 'emotion', current_setting('audy.test_emotion')::jsonb, 0
);
do $$
begin
  begin
    perform public.student_game_config('emotion', null);
    raise exception 'Adult can read the Student RPC';
  exception when insufficient_privilege then null; end;
end $$;

select set_config('request.jwt.claim.sub', '63300000-0000-4000-8000-000000000002', true);
do $$
begin
  if public.student_game_config('emotion', null) <> '{"status":"default"}'::jsonb then
    raise exception 'Preview leaked into Student play';
  end if;
end $$;

select set_config('request.jwt.claim.sub', '63300000-0000-4000-8000-000000000001', true);
select public.caretaker_save_student_game_config(
  '63300000-0000-4000-8000-000000000002', 'emotion', current_setting('audy.test_emotion')::jsonb, 1, true
);
do $$
begin
  begin
    perform public.caretaker_save_config(
      '63300000-0000-4000-8000-000000000002', 'emotion', current_setting('audy.test_emotion')::jsonb, 2
    );
    raise exception 'Old app could edit live settings';
  exception when feature_not_supported then null; end;
  begin
    perform public.caretaker_save_student_game_config(
      '63300000-0000-4000-8000-000000000002', 'emotion', current_setting('audy.test_emotion')::jsonb, 1, false
    );
    raise exception 'A stale revision replaced live settings';
  exception when serialization_failure then null; end;
  begin
    perform public.caretaker_save_student_game_config(
      '63300000-0000-4000-8000-000000000002', 'social_chat',
      '{"input_mode":"text_only","reply_speech":"on_tap","listen_seconds":30,"pause_seconds":3,"starter_phrases":[]}', 0, true
    );
    raise exception 'Social Chat activation was allowed';
  exception when invalid_parameter_value then null; end;
end $$;

select set_config('request.jwt.claim.sub', '63300000-0000-4000-8000-000000000002', true);
do $$
declare result jsonb;
begin
  result := public.student_game_config('emotion', null);
  if result <> jsonb_build_object('status','active','payload',current_setting('audy.test_emotion')::jsonb,'revision',2,'schema_version',1) then
    raise exception 'Student got unexpected data %', result;
  end if;
  if public.student_game_config('emotion', 2) <> '{"status":"unchanged","revision":2}'::jsonb then
    raise exception 'Revision optimization failed';
  end if;
  if exists (select 1 from public.child_game_configs) then
    raise exception 'Student can read the raw table';
  end if;
  begin
    perform public.caretaker_save_student_game_config(auth.uid(), 'emotion', '{}'::jsonb, 2, false);
    raise exception 'Student can save their configuration';
  exception when insufficient_privilege then null; end;
end $$;

select set_config('request.jwt.claim.sub', '63300000-0000-4000-8000-000000000003', true);
do $$
begin
  if public.student_game_config('emotion', 2) <> '{"status":"default"}'::jsonb then
    raise exception 'Another student’s settings were exposed';
  end if;
end $$;

select set_config('request.jwt.claim.sub', '63300000-0000-4000-8000-000000000001', true);
select public.caretaker_save_student_game_config(
  '63300000-0000-4000-8000-000000000002', 'emotion', current_setting('audy.test_emotion')::jsonb, 2, false
);
select set_config('request.jwt.claim.sub', '63300000-0000-4000-8000-000000000002', true);
do $$
begin
  if public.student_game_config('emotion', 2) <> '{"status":"default"}'::jsonb then
    raise exception 'Deactivation did not replace a cached revision';
  end if;
end $$;

set local role anon;
do $$
begin
  begin
    perform public.student_game_config('emotion', null);
    raise exception 'Anonymous Student lookup was allowed';
  exception when insufficient_privilege then null; end;
end $$;
reset role;

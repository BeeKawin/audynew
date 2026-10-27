begin;
insert into auth.users(id,email,raw_user_meta_data) values
('b1111111-1111-4111-8111-111111111111','break-adult@invalid.test','{"name":"Adult","role":"caretaker","age":0}'),
('b2222222-2222-4222-8222-222222222222','break-child@invalid.test','{"name":"Child","role":"child","age":8}'),
('b3333333-3333-4333-8333-333333333333','break-other@invalid.test','{"name":"Other","role":"teacher","age":0}'),
('b4444444-4444-4444-8444-444444444444','break-child-two@invalid.test','{"name":"Child two","role":"child","age":9}');
set local role authenticated;
select set_config('request.jwt.claim.sub','b2222222-2222-4222-8222-222222222222',true);
do $$begin
  if public.student_break_settings()->>'games_before_break'<>'5' then raise exception 'Missing settings must default to five';end if;
end $$;
select set_config('request.jwt.claim.sub','b1111111-1111-4111-8111-111111111111',true);
select public.caretaker_link_child('break-child@invalid.test');
select public.caretaker_link_child('break-child-two@invalid.test');
do $$declare r jsonb;begin
  begin perform public.caretaker_save_break_settings('b2222222-2222-4222-8222-222222222222',3,0);
    raise exception 'Unselected child write allowed';exception when insufficient_privilege then null;end;
  r:=public.caretaker_roster();
  perform public.caretaker_save_roster(2,array['b2222222-2222-4222-8222-222222222222','b4444444-4444-4444-8444-444444444444']::uuid[],(r->>'revision')::integer);
  r:=public.caretaker_save_break_settings('b2222222-2222-4222-8222-222222222222',1,0);
  if r->>'games_before_break'<>'1' or r->>'revision'<>'1' then raise exception 'First save failed';end if;
  perform public.caretaker_save_break_settings('b4444444-4444-4444-8444-444444444444',20,0);
  begin perform public.caretaker_save_break_settings('b2222222-2222-4222-8222-222222222222',5,0);
    raise exception 'Stale save allowed';exception when serialization_failure then null;end;
  begin perform public.caretaker_save_break_settings('b2222222-2222-4222-8222-222222222222',0,1);
    raise exception 'Zero allowed';exception when invalid_parameter_value then null;end;
  begin perform public.caretaker_save_break_settings('b2222222-2222-4222-8222-222222222222',21,1);
    raise exception 'Threshold over 20 allowed';exception when invalid_parameter_value then null;end;
  begin perform public.caretaker_save_break_settings('b2222222-2222-4222-8222-222222222222',null,1);
    raise exception 'Null allowed';exception when invalid_parameter_value then null;end;
  r:=public.caretaker_save_break_settings('b2222222-2222-4222-8222-222222222222',5,1);
  if r->>'revision'<>'2' then raise exception 'Reset save failed';end if;
  begin update public.child_break_settings set games_before_break=10;
    raise exception 'Direct write allowed';exception when insufficient_privilege then null;end;
  begin perform public.student_break_settings();raise exception 'Adult used Student RPC';exception when insufficient_privilege then null;end;
end $$;
select set_config('request.jwt.claim.sub','b2222222-2222-4222-8222-222222222222',true);
do $$begin
  if public.student_break_settings()->>'games_before_break'<>'5' then raise exception 'Child received wrong threshold';end if;
  if exists(select 1 from public.child_break_settings) then raise exception 'Student read adult metadata';end if;
  begin perform public.caretaker_save_break_settings(auth.uid(),10,2);
    raise exception 'Student saved threshold';exception when insufficient_privilege then null;end;
end $$;
select set_config('request.jwt.claim.sub','b4444444-4444-4444-8444-444444444444',true);
do $$begin
  if public.student_break_settings()->>'games_before_break'<>'20' then raise exception 'Child settings mixed';end if;
end $$;
select set_config('request.jwt.claim.sub','b3333333-3333-4333-8333-333333333333',true);
do $$begin
  if exists(select 1 from public.child_break_settings) then raise exception 'Unrelated adult read threshold';end if;
  begin perform public.caretaker_save_break_settings('b2222222-2222-4222-8222-222222222222',3,2);
    raise exception 'Unrelated adult saved';exception when insufficient_privilege then null;end;
end $$;
set local role anon;
do $$begin
  begin perform public.student_break_settings();raise exception 'Anonymous Student RPC';exception when insufficient_privilege then null;end;
  begin perform public.caretaker_save_break_settings('b2222222-2222-4222-8222-222222222222',3,2);
    raise exception 'Anonymous write';exception when insufficient_privilege then null;end;
end $$;
reset role;
do $$begin
  if exists(select 1 from public.game_sessions where student_id in ('b2222222-2222-4222-8222-222222222222','b4444444-4444-4444-8444-444444444444')) then
    raise exception 'Break settings wrote game sessions';end if;
end $$;
select 'Break defaults, range, persistence, conflicts, child isolation and access checks passed' as result;
rollback;

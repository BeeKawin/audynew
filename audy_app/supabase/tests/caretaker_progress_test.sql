begin;
insert into auth.users(id,email,raw_user_meta_data) values
('a1111111-1111-4111-8111-111111111111','progress-adult@invalid.test','{"name":"Fixture adult","role":"caretaker","age":0}'),
('a2222222-2222-4222-8222-222222222222','progress-child@invalid.test','{"name":"Fixture child","role":"child","age":8}'),
('a3333333-3333-4333-8333-333333333333','progress-other@invalid.test','{"name":"Fixture other","role":"parent","age":0}');
insert into public.student_stats(student_id,learning_points,games_played,day_streak)
values('a2222222-2222-4222-8222-222222222222',275,42,3);
insert into public.game_sessions(student_id,game_type,difficulty,correct_actions,total_actions,accuracy_percent,stars_earned,duration_seconds,session_ended_at)
select 'a2222222-2222-4222-8222-222222222222','emotion_classify','easy',2,3,66.67,2,10,now()-n*interval '1 minute'
from generate_series(1,205) n;

set local role authenticated;
select set_config('request.jwt.claim.sub','a1111111-1111-4111-8111-111111111111',true);
select public.caretaker_link_child('progress-child@invalid.test');
do $$declare r jsonb;begin
  begin
    perform public.caretaker_child_progress('a2222222-2222-4222-8222-222222222222');
    raise exception 'Unselected child progress was readable';
  exception when insufficient_privilege then null;end;
  r:=public.caretaker_roster();
  perform public.caretaker_save_roster(1,array['a2222222-2222-4222-8222-222222222222']::uuid[],(r->>'revision')::integer);
  r:=public.caretaker_child_progress('a2222222-2222-4222-8222-222222222222');
  if (r->'stats'->>'learning_points')::integer<>275 or (r->'stats'->>'games_played')::integer<>42 then
    raise exception 'Stored counters changed';end if;
  if jsonb_array_length(r->'sessions')<>200 then raise exception 'History limit incorrect';end if;
  if (r->'sessions'->0->>'session_ended_at')::timestamptz < (r->'sessions'->199->>'session_ended_at')::timestamptz then
    raise exception 'History ordering incorrect';end if;
  r:=public.caretaker_roster();
  perform public.caretaker_save_roster(1,array[]::uuid[],(r->>'revision')::integer);
  begin
    perform public.caretaker_child_progress('a2222222-2222-4222-8222-222222222222');
    raise exception 'Deselected child progress was readable';
  exception when insufficient_privilege then null;end;
end $$;
select set_config('request.jwt.claim.sub','a3333333-3333-4333-8333-333333333333',true);
do $$begin
  begin perform public.caretaker_child_progress('a2222222-2222-4222-8222-222222222222');
    raise exception 'Unrelated adult read progress';exception when insufficient_privilege then null;end;
end $$;
select set_config('request.jwt.claim.sub','a2222222-2222-4222-8222-222222222222',true);
do $$begin
  begin perform public.caretaker_child_progress(auth.uid());
    raise exception 'Student used adult progress RPC';exception when insufficient_privilege then null;end;
end $$;
set local role anon;
do $$begin
  begin perform public.caretaker_child_progress('a2222222-2222-4222-8222-222222222222');
    raise exception 'Anonymous progress access';exception when insufficient_privilege then null;end;
end $$;
reset role;
do $$begin
  if (select count(*) from public.game_sessions where student_id='a2222222-2222-4222-8222-222222222222')<>205 then
    raise exception 'Progress reads modified history';end if;
end $$;
select 'Progress access, history and unchanged counters verified' as result;
rollback;

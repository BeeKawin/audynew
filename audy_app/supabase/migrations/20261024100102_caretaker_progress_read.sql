-- A read-only adapter: existing analytical tables, policies and calculations stay unchanged.
create function caretaker_private.child_progress(target_child uuid) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare actor uuid := caretaker_private.assert_adult();
begin
  if not exists (
    select 1 from public.caretaker_children c join public.profiles p on p.id=c.child_id
    where c.caretaker_id=actor and c.child_id=target_child and c.is_in_care and p.role='child'
  ) then
    raise exception using errcode='42501', message='Child is not in your care list';
  end if;
  return jsonb_build_object(
    'stats', (select to_jsonb(s) from public.student_stats s where s.student_id=target_child),
    'sessions', coalesce((select jsonb_agg(to_jsonb(s) order by s.session_ended_at desc)
      from (select * from public.game_sessions where student_id=target_child
        order by session_ended_at desc limit 200) s), '[]'::jsonb),
    'assignments', coalesce((select jsonb_agg(to_jsonb(a) order by a.created_at desc)
      from public.assignments a where a.student_id=target_child), '[]'::jsonb)
  );
end $$;
create function public.caretaker_child_progress(target_child uuid) returns jsonb
language sql stable security invoker set search_path='' as $$
  select caretaker_private.child_progress(target_child)
$$;
revoke all on function caretaker_private.child_progress(uuid) from public,anon;
revoke all on function public.caretaker_child_progress(uuid) from public,anon;
grant execute on function caretaker_private.child_progress(uuid) to authenticated;
grant execute on function public.caretaker_child_progress(uuid) to authenticated;

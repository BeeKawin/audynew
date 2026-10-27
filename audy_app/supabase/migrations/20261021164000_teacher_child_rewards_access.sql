drop policy if exists "Children and linked parents can view rewards"
on public.child_rewards;

drop policy if exists "Linked parents can create rewards"
on public.child_rewards;

drop policy if exists "Children and linked parents can update reward progress"
on public.child_rewards;

drop policy if exists "Linked parents can delete rewards"
on public.child_rewards;

create policy "Children and linked caregivers can view rewards"
on public.child_rewards
for select
to authenticated
using (
  child_id = (select auth.uid())
  or exists (
    select 1
    from public.profiles child_profile
    where child_profile.id = child_rewards.child_id
      and (
        child_profile.parent_id = (select auth.uid())
        or child_profile.teacher_id = (select auth.uid())
      )
  )
);

create policy "Linked caregivers can create rewards"
on public.child_rewards
for insert
to authenticated
with check (
  created_by = (select auth.uid())
  and exists (
    select 1
    from public.profiles child_profile
    where child_profile.id = child_rewards.child_id
      and (
        child_profile.parent_id = (select auth.uid())
        or child_profile.teacher_id = (select auth.uid())
      )
  )
);

create policy "Children and linked caregivers can update reward progress"
on public.child_rewards
for update
to authenticated
using (
  child_id = (select auth.uid())
  or exists (
    select 1
    from public.profiles child_profile
    where child_profile.id = child_rewards.child_id
      and (
        child_profile.parent_id = (select auth.uid())
        or child_profile.teacher_id = (select auth.uid())
      )
  )
)
with check (
  child_id = (select auth.uid())
  or exists (
    select 1
    from public.profiles child_profile
    where child_profile.id = child_rewards.child_id
      and (
        child_profile.parent_id = (select auth.uid())
        or child_profile.teacher_id = (select auth.uid())
      )
  )
);

create policy "Caregivers can delete rewards they created"
on public.child_rewards
for delete
to authenticated
using (
  created_by = (select auth.uid())
  and exists (
    select 1
    from public.profiles child_profile
    where child_profile.id = child_rewards.child_id
      and (
        child_profile.parent_id = (select auth.uid())
        or child_profile.teacher_id = (select auth.uid())
      )
  )
);

drop policy if exists "Children and linked parents can view achievements"
on public.child_achievements;

create policy "Children and linked caregivers can view achievements"
on public.child_achievements
for select
to authenticated
using (
  child_id = (select auth.uid())
  or exists (
    select 1
    from public.profiles child_profile
    where child_profile.id = child_achievements.child_id
      and (
        child_profile.parent_id = (select auth.uid())
        or child_profile.teacher_id = (select auth.uid())
      )
  )
);

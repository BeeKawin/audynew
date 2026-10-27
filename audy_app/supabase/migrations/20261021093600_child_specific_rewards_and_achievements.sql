create table public.child_rewards (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references public.profiles(id) on delete cascade,
  created_by uuid not null default auth.uid() references auth.users(id) on delete cascade,
  prize text not null check (char_length(trim(prize)) between 1 and 120),
  condition_type text not null check (
    condition_type in (
      'emotionClassify',
      'emotionMimic',
      'miniPuzzle',
      'sortingGame',
      'reactionTime',
      'reading',
      'socialChat'
    )
  ),
  target_count integer not null check (target_count between 1 and 100),
  current_progress integer not null default 0 check (current_progress >= 0),
  is_completed boolean not null default false,
  is_claimed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index child_rewards_child_id_idx on public.child_rewards(child_id);
create index child_rewards_created_by_idx on public.child_rewards(created_by);

alter table public.child_rewards enable row level security;
revoke all on table public.child_rewards from anon, authenticated;
grant select, delete on table public.child_rewards to authenticated;
grant insert (
  child_id,
  created_by,
  prize,
  condition_type,
  target_count,
  current_progress,
  is_completed,
  is_claimed,
  created_at,
  updated_at
) on table public.child_rewards to authenticated;
grant update (
  current_progress,
  is_completed,
  is_claimed,
  updated_at
) on table public.child_rewards to authenticated;

create policy "Children and linked parents can view rewards"
on public.child_rewards
for select
to authenticated
using (
  child_id = (select auth.uid())
  or exists (
    select 1
    from public.profiles child_profile
    where child_profile.id = child_rewards.child_id
      and child_profile.parent_id = (select auth.uid())
  )
);

create policy "Linked parents can create rewards"
on public.child_rewards
for insert
to authenticated
with check (
  created_by = (select auth.uid())
  and exists (
    select 1
    from public.profiles child_profile
    where child_profile.id = child_rewards.child_id
      and child_profile.parent_id = (select auth.uid())
  )
);

create policy "Children and linked parents can update reward progress"
on public.child_rewards
for update
to authenticated
using (
  child_id = (select auth.uid())
  or exists (
    select 1
    from public.profiles child_profile
    where child_profile.id = child_rewards.child_id
      and child_profile.parent_id = (select auth.uid())
  )
)
with check (
  child_id = (select auth.uid())
  or exists (
    select 1
    from public.profiles child_profile
    where child_profile.id = child_rewards.child_id
      and child_profile.parent_id = (select auth.uid())
  )
);

create policy "Linked parents can delete rewards"
on public.child_rewards
for delete
to authenticated
using (
  exists (
    select 1
    from public.profiles child_profile
    where child_profile.id = child_rewards.child_id
      and child_profile.parent_id = (select auth.uid())
  )
);

create table public.child_achievements (
  child_id uuid not null references public.profiles(id) on delete cascade,
  achievement_key text not null check (char_length(trim(achievement_key)) between 1 and 80),
  unlocked_at timestamptz not null default now(),
  primary key (child_id, achievement_key)
);

alter table public.child_achievements enable row level security;
revoke all on table public.child_achievements from anon, authenticated;
grant select on table public.child_achievements to authenticated;
grant insert (child_id, achievement_key, unlocked_at)
  on table public.child_achievements to authenticated;

create policy "Children and linked parents can view achievements"
on public.child_achievements
for select
to authenticated
using (
  child_id = (select auth.uid())
  or exists (
    select 1
    from public.profiles child_profile
    where child_profile.id = child_achievements.child_id
      and child_profile.parent_id = (select auth.uid())
  )
);

create policy "Children can record their own achievements"
on public.child_achievements
for insert
to authenticated
with check (child_id = (select auth.uid()));

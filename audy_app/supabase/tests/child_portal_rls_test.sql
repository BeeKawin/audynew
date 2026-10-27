begin;
select plan(9);

select ok(
  to_regclass('public.child_rewards') is not null,
  'child_rewards exists'
);
select ok(
  to_regclass('public.child_achievements') is null,
  'the removed achievement table is absent'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.child_rewards'::regclass),
  'child_rewards has RLS enabled'
);
select ok(
  not has_table_privilege('anon', 'public.child_rewards', 'select'),
  'anonymous users cannot read child rewards'
);
select ok(
  has_table_privilege('authenticated', 'public.child_rewards', 'select'),
  'authenticated users receive reward select privileges before RLS filtering'
);
select ok(
  has_column_privilege(
    'authenticated',
    'public.child_rewards',
    'current_progress',
    'update'
  ),
  'authenticated users can update reward progress before RLS filtering'
);
select ok(
  not has_column_privilege(
    'authenticated',
    'public.child_rewards',
    'prize',
    'update'
  ),
  'reward descriptions cannot be changed through the client'
);
select is(
  (select count(*)::integer from pg_policies where schemaname = 'public' and tablename = 'child_rewards'),
  4,
  'child_rewards has one policy for each allowed operation'
);
select ok(
  to_regclass('public.child_rewards_child_id_idx') is not null,
  'child reward relationship checks are indexed'
);

select * from finish();
rollback;

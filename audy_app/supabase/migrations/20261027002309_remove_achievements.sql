-- Achievement records, indexes, grants and policies belong to the removed feature.
-- RESTRICT is deliberate: an unexpected dependency must stop this migration.
drop table if exists public.child_achievements restrict;

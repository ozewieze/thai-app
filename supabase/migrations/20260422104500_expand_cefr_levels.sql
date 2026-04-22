-- Expand CEFR support from A1-only to full CEFR range.

alter table public.lessons
  drop constraint if exists lessons_cefr_level_check;

alter table public.lessons
  add constraint lessons_cefr_level_check
  check (cefr_level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2'));

alter table public.vocabulary_master
  drop constraint if exists vocabulary_master_cefr_level_check;

alter table public.vocabulary_master
  add constraint vocabulary_master_cefr_level_check
  check (cefr_level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2'));

alter table public.grammar_master
  drop constraint if exists grammar_master_cefr_level_check;

alter table public.grammar_master
  add constraint grammar_master_cefr_level_check
  check (cefr_level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2'));

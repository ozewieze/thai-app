insert into public.lessons (
  lesson_key,
  slug,
  cefr_level,
  section_key,
  lesson_type,
  title,
  subtitle,
  sequence_number,
  access_tier,
  is_published
)
values
  (
    'a1-dialog-05',
    'enjoying-the-snack',
    'A1',
    'dialogs',
    'dialog',
    'Dialog 5',
    'Enjoying the snack',
    5,
    'free',
    true
  )
  
on conflict (lesson_key) do update
set
  slug = excluded.slug,
  cefr_level = excluded.cefr_level,
  section_key = excluded.section_key,
  lesson_type = excluded.lesson_type,
  title = excluded.title,
  subtitle = excluded.subtitle,
  sequence_number = excluded.sequence_number,
  access_tier = excluded.access_tier,
  is_published = excluded.is_published,
  updated_at = now();
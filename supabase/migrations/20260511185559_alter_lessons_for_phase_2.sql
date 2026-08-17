alter table public.lessons
add column slug text,
add column section_key text,
add column subtitle text,
add column access_tier text;

alter table public.lessons
drop constraint lessons_lesson_type_check;

alter table public.lessons
add constraint lessons_lesson_type_check
check (lesson_type in ('dialog', 'revision', 'theme', 'story'));

alter table public.lessons
add constraint lessons_section_key_check
check (section_key in ('dialogs', 'themes', 'stories', 'focus'));

alter table public.lessons
add constraint lessons_access_tier_check
check (access_tier in ('free', 'premium'));

alter table public.lessons
drop constraint lessons_sequence_number_unique;

alter table public.lessons
add constraint lessons_level_section_sequence_unique
unique (cefr_level, section_key, sequence_number);

alter table public.lessons
add constraint lessons_slug_unique
unique (slug);
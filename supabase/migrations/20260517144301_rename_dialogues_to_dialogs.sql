alter table public.dialogues
rename to dialogs;

alter table public.dialogs
rename constraint dialogues_lesson_id_unique to dialogs_lesson_id_unique;

alter table public.dialogs
rename constraint dialogues_lesson_fk to dialogs_lesson_fk;

alter table public.dialogs
rename constraint dialogues_register_check to dialogs_register_check;

drop policy if exists "Dialogues of published lessons are readable by everyone"
on public.dialogs;

create policy "Dialogs of published lessons are readable by everyone"
on public.dialogs
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.lessons l
    where l.id = dialogs.lesson_id
      and l.is_published = true
  )
);
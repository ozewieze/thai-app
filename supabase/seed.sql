-- =========================================
-- Optional cleanup for lesson vertical slice
-- =========================================

-- =========================================
-- Lessons
-- =========================================
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
    'a1-dialog-01',
    'greetings-and-introductions',
    'A1',
    'dialogs',
    'dialog',
    'Dialog 1',
    'Greetings and introductions',
    1,
    'free',
    true
  ),
  (
    'a1-dialog-02',
    'how-are-you',
    'A1',
    'dialogs',
    'dialog',
    'Dialog 2',
    'How are you?',
    2,
    'free',
    true
  ),
  (
    'a1-dialog-03',
    'where-are-you',
    'A1',
    'dialogs',
    'dialog',
    'Dialog 3',
    'Where are you?',
    3,
    'free',
    true
  ),
  (
    'a1-dialog-04',
    'what-is-this',
    'A1',
    'dialogs',
    'dialog',
    'Dialog 4',
    'What is this?',
    4,
    'free',
    true
  ),
  (
    'a1-dialog-05',
    'simple-plans',
    'A1',
    'dialogs',
    'dialog',
    'Dialog 5',
    'Simple plans',
    5,
    'free',
    true
  ),  
  (
    'a1-revision-01',
    'revision-1-5',
    'A1',
    'dialogs',
    'revision',
    'Revision 1',
    'Review Dialogs 1–5',
    6,
    'free',
    true
  );
-- =========================================
-- Dialogues
-- =========================================

-- =========================================
-- Revisions
-- =========================================
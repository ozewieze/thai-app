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
  ),
  (
    'a1-dialog-premium-01',
    'placeholder-premium-1',
    'A1',
    'dialogs',
    'dialog',
    'Dialog 6',
    'Premium placeholder 1',
    7,
    'premium',
    true
  ),
  (
    'a1-dialog-premium-02',
    'placeholder-premium-2',
    'A1',
    'dialogs',
    'dialog',
    'Dialog 7',
    'Premium placeholder 2',
    8,
    'premium',
    true
  ),
  (
    'a1-dialog-premium-03',
    'placeholder-premium-3',
    'A1',
    'dialogs',
    'dialog',
    'Dialog 8',
    'Premium placeholder 3',
    9,
    'premium',
    true
  ),
  (
    'a1-dialog-premium-04',
    'placeholder-premium-4',
    'A1',
    'dialogs',
    'dialog',
    'Dialog 9',
    'Premium placeholder 4',
    10,
    'premium',
    true
  ),
  (
    'a1-dialog-premium-05',
    'placeholder-premium-5',
    'A1',
    'dialogs',
    'dialog',
    'Dialog 10',
    'Premium placeholder 5',
    11,
    'premium',
    true
  ),
  (
    'a1-revision-premium-01',
    'placeholder-premium-revision-1',
    'A1',
    'dialogs',
    'revision',
    'Revision 2',
    'Premium placeholder revision',
    12,
    'premium',
    true
  );
-- =========================================
-- Dialogues
-- =========================================

-- =========================================
-- Revisions
-- =========================================
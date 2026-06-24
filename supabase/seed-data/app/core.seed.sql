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
    'where-are-you-going',
    'A1',
    'dialogs',
    'dialog',
    'Dialog 2',
    'Where are you going?',
    2,
    'free',
    true
  ),
  (
    'a1-dialog-03',
    'at-the-cafe',
    'A1',
    'dialogs',
    'dialog',
    'Dialog 3',
    'At the café',
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
-- Lesson grammar
-- =========================================

-- moved to a later seed file so grammar_master exists first

-- =========================================
-- Lesson pattern
-- =========================================

-- moved to a later seed file so pattern_master exists first


-- =========================================
-- Lesson vocabulary
-- =========================================

-- moved to a later seed file so vocabulary_master exists first
-- =========================================
-- Dialogues
-- =========================================

-- =========================================
-- Revisions
-- =========================================

-- =========================================
-- Character profiles
-- =========================================

insert into public.character_profiles (
  character_key,
  display_name,
  display_name_thai,
  role_summary,
  age_impression,
  default_tone,
  default_usage
)
values
  (
    'narin',
    'Narin',
    'นริน',
    'Central anchor character; calm, socially capable, dependable, connector between groups.',
    'adult',
    array['calm', 'approachable', 'socially_confident', 'believable'],
    array['first_meetings', 'practical_daily_scenes', 'bridge_between_character_clusters']
  ),
  (
    'mali',
    'Mali',
    'มะลิ',
    'Adult woman with a polished, professional-adjacent presence; organized and polite.',
    'adult',
    array['calm', 'polite', 'organized', 'mature'],
    array['workplace_adjacent_scenes', 'cafe_scenes', 'shopping', 'scheduling', 'introductions']
  ),
  (
    'ploy',
    'Ploy',
    'พลอย',
    'Relaxed younger urban adult; casual and modern.',
    'younger_adult',
    array['casual', 'modern', 'relaxed', 'approachable'],
    array['friends', 'errands', 'food', 'transport', 'social_invitations']
  ),
  (
    'dao',
    'Dao',
    'ดาว',
    'Warm and friendly adult woman; gentle and supportive.',
    'adult',
    array['warm', 'gentle', 'approachable', 'friendly'],
    array['hospitality', 'helping_situations', 'family_like_interactions', 'soft_conversational_practice']
  ),
  (
    'lin',
    'Lin',
    'ลิน',
    'Youngest adult figure; study-oriented, modest, careful.',
    'early_20s',
    array['studious', 'modest', 'careful', 'polite'],
    array['learner_identification', 'school', 'study', 'questions', 'uncertainty']
  ),
  (
    'suda',
    'Suda',
    'สุดา',
    'Middle-aged grounding figure; practical, caring, neighborhood/home anchor.',
    'middle_aged',
    array['warm', 'practical', 'caring', 'grounded'],
    array['food', 'home', 'neighborhood', 'routine', 'advice', 'caregiving']
  ),
  (
    'kiet',
    'Kiet',
    'เกียรติ',
    'Friendly practical man; colleague or peer type.',
    'around_35',
    array['friendly', 'practical', 'approachable', 'grounded'],
    array['work', 'helping', 'activities', 'peer_conversations', 'scheduling']
  ),
  (
    'arun',
    'Arun',
    'อรุณ',
    'Older established man; calm authority presence.',
    'around_44',
    array['calm', 'reliable', 'authoritative', 'composed'],
    array['respectful_hierarchy', 'work', 'advice', 'organization', 'teacher_like_interactions']
  )
on conflict (character_key) do update
set
  display_name = excluded.display_name,
  display_name_thai = excluded.display_name_thai,
  role_summary = excluded.role_summary,
  age_impression = excluded.age_impression,
  default_tone = excluded.default_tone,
  default_usage = excluded.default_usage,
  updated_at = now();

-- =========================================
-- Relationship pairs
-- =========================================

insert into public.relationship_pairs (
  character_a_id,
  character_b_id,
  start_state,
  current_stage,
  function_summary,
  allowed_progression,
  is_active
)
values
  (
    (select id from public.character_profiles where character_key = 'mali'),
    (select id from public.character_profiles where character_key = 'narin'),
    'first_meeting',
    'early',
    'Opening introductions and polite small talk.',
    array['acquaintance', 'comfortable_contact', 'close_bond_or_subtle_romantic_potential'],
    true
  ),
  (
    (select id from public.character_profiles where character_key = 'kiet'),
    (select id from public.character_profiles where character_key = 'narin'),
    'established_friends_or_colleagues',
    'stable',
    'Work, errands, and casual practical talk.',
    array['stable_friendship', 'shared_history'],
    true
  ),
  (
    (select id from public.character_profiles where character_key = 'arun'),
    (select id from public.character_profiles where character_key = 'narin'),
    'respectful_junior_senior_connection',
    'early',
    'Polite advice, work, and scheduling.',
    array['trusted_professional_relationship'],
    true
  ),
  (
    (select id from public.character_profiles where character_key = 'dao'),
    (select id from public.character_profiles where character_key = 'mali'),
    'friendly_acquaintance',
    'early',
    'Warm adult conversation and support.',
    array['trusted_friendship'],
    true
  ),
  (
    (select id from public.character_profiles where character_key = 'dao'),
    (select id from public.character_profiles where character_key = 'suda'),
    'warm_neighborhood_bond',
    'stable',
    'Home, food, care, and practical help.',
    array['family_like_trust'],
    true
  ),
  (
    (select id from public.character_profiles where character_key = 'lin'),
    (select id from public.character_profiles where character_key = 'mali'),
    'respectful_mentor_like_link',
    'early',
    'Questions, study, and guidance.',
    array['warm_mentor_friend'],
    true
  ),
  (
    (select id from public.character_profiles where character_key = 'lin'),
    (select id from public.character_profiles where character_key = 'ploy'),
    'new_friendly_connection',
    'early',
    'Casual social contrast and modern daily interactions.',
    array['relaxed_friendship'],
    true
  ),
  (
    (select id from public.character_profiles where character_key = 'lin'),
    (select id from public.character_profiles where character_key = 'suda'),
    'warm_older_younger_bond',
    'early',
    'Advice, food, care, and daily life.',
    array['dependable_supportive_relation'],
    true
  ),
  (
    (select id from public.character_profiles where character_key = 'arun'),
    (select id from public.character_profiles where character_key = 'kiet'),
    'senior_colleague_or_respected_connection',
    'early',
    'Hierarchy, work, and guidance.',
    array['professional_trust'],
    true
  );

  -- =========================================
-- Relationship pair rules
-- =========================================

  insert into public.relationship_pair_rules (
  relationship_pair_id,
  rule_key,
  rule_text
)
values
  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'mali'
        and b.character_key = 'narin'
    ),
    'lesson_1_can_start_here',
    'This pair may begin the curriculum as a first meeting in greetings and introductions.'
  ),
  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'mali'
        and b.character_key = 'narin'
    ),
    'keep_growth_gradual',
    'Do not move this pair too quickly into intimacy; let familiarity develop over multiple lessons.'
  ),
  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'mali'
        and b.character_key = 'narin'
    ),
    'no_fast_romance',
    'Romantic potential must remain subtle and should not appear in early A1 lessons.'
  ),

  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'kiet'
        and b.character_key = 'narin'
    ),
    'keep_stable',
    'This pair should remain easy, practical, and stable across lessons.'
  ),
  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'kiet'
        and b.character_key = 'narin'
    ),
    'lightly_informal',
    'Their tone may be relaxed, but it should stay grounded and natural.'
  ),

  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'arun'
        and b.character_key = 'narin'
    ),
    'respect_hierarchy',
    'Arun should consistently receive slightly more respectful interaction.'
  ),
  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'arun'
        and b.character_key = 'narin'
    ),
    'slow_relaxation_only',
    'The relationship may become warmer later, but only gradually.'
  ),

  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'dao'
        and b.character_key = 'mali'
    ),
    'friendly_warmth',
    'This pair should feel calm, warm, and supportive.'
  ),
  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'dao'
        and b.character_key = 'mali'
    ),
    'no_conflict_needed',
    'Do not force tension; this pair works best through warm everyday interaction.'
  ),

  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'dao'
        and b.character_key = 'suda'
    ),
    'supportive',
    'This pair should feel practical, caring, and dependable.'
  ),
  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'dao'
        and b.character_key = 'suda'
    ),
    'neighborly_warmth',
    'Their connection should feel naturally warm and neighborhood-based.'
  ),

  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'lin'
        and b.character_key = 'mali'
    ),
    'older_younger_respect',
    'Lin should speak with a slightly more careful tone toward Mali.'
  ),
  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'lin'
        and b.character_key = 'mali'
    ),
    'gentle_guidance',
    'Mali may guide Lin, but without sounding teacher-heavy or overly formal.'
  ),

  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'lin'
        and b.character_key = 'ploy'
    ),
    'light',
    'This pair can feel socially light, modern, and easy.'
  ),
  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'lin'
        and b.character_key = 'ploy'
    ),
    'casual',
    'Their dialogue may be more casual than Lin has with older adults.'
  ),

  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'lin'
        and b.character_key = 'suda'
    ),
    'respectful',
    'Lin should remain respectful and slightly careful with Suda.'
  ),
  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'lin'
        and b.character_key = 'suda'
    ),
    'safe_supportive',
    'This pair should feel emotionally safe, warm, and helpful.'
  ),

  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'arun'
        and b.character_key = 'kiet'
    ),
    'respect_hierarchy',
    'Kiet should treat Arun with consistent but natural respect.'
  ),
  (
    (
      select rp.id
      from public.relationship_pairs rp
      join public.character_profiles a on a.id = rp.character_a_id
      join public.character_profiles b on b.id = rp.character_b_id
      where a.character_key = 'arun'
        and b.character_key = 'kiet'
    ),
    'calm_tone',
    'This pair should stay composed, practical, and work-appropriate.'
  );

  
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
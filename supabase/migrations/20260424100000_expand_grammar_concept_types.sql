-- Expand grammar concept_type support to match the seeded CSV data.

alter table public.grammar_master
  drop constraint if exists grammar_master_concept_type_check;

alter table public.grammar_master
  add constraint grammar_master_concept_type_check
  check (
    concept_type is null
    or concept_type in (
      'sentence_pattern',
      'modifier_pattern',
      'question_pattern',
      'pronoun_system',
      'negation',
      'verb_pattern',
      'location_pattern',
      'tense_aspect',
      'functional_expression',
      'politeness',
      'particle',
      'classifier_pattern',
      'quantity',
      'comparison',
      'time_expression'
    )
  );

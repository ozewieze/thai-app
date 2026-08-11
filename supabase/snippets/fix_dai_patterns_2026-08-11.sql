-- ============================================================
-- Correctie van de ได้-rijen in pattern_master en grammar_master
-- 2026-08-11
--
-- Aanleiding: pattern_master beschreef de bevestigende ability-vorm als
-- 'ได้ + VERB'. Dat spreekt zijn eigen buren tegen -- de vraagvorm is
-- 'VERB + ได้ไหม' en de ontkenning 'VERB + ไม่ได้', allebei postverbaal --
-- en het is precies de positie waar de betekenis omslaat: ná de
-- werkwoordgroep is ได้ "kunnen", ervóór hoort het bij het verleden.-


begin;

-- ------------------------------------------------------------
-- 1. pattern_master
-- ------------------------------------------------------------

-- De bevestigende vorm: volgorde omgedraaid, sleutel meegenomen zodat
-- hij bij verb_dai_mai en verb_mai_dai past, en de positie in de
-- omschrijving gezet. Die ontbrak, en dat is hoe de fout kon blijven
-- staan.
update public.pattern_master set
  pattern_key       = 'verb_dai',
  title             = 'Can do',
  pattern_formula   = 'VERB PHRASE + ได้',
  short_explanation = 'Placed after the whole verb phrase to say that something can be done.'
where pattern_key = 'dai_verb';

-- De preverbale vorm: de vorm klopte, de betekenis niet. Onvermogen is
-- verb_mai_dai; ไม่ได้ vóór de werkwoordgroep ontkent het verleden. De
-- oude omschrijving zei "cannot do or did not do" -- twee dingen die
-- door elkaar liepen. pattern_type gaat mee van ability_frame naar
-- negation_frame, net als mai_verb.
update public.pattern_master set
  title             = 'Did not do',
  pattern_formula   = 'ไม่ได้ + VERB PHRASE',
  short_explanation = 'Placed before the verb phrase to say that something did not happen.',
  pattern_type      = 'negation_frame'
where pattern_key = 'mai_dai_verb';

-- De vraagvorm en de ontkenning gelijktrekken: ook daar staat ได้ achter
-- de hele werkwoordgroep, niet achter het werkwoord alleen. Zonder deze
-- twee zou de gecorrigeerde bevestigende vorm alleen komen te staan.
update public.pattern_master set
  pattern_formula = 'VERB PHRASE + ได้ไหม'
where pattern_key = 'verb_dai_mai';

update public.pattern_master set
  pattern_formula = 'VERB PHRASE + ไม่ได้'
where pattern_key = 'verb_mai_dai';

-- ------------------------------------------------------------
-- 2. grammar_master
-- ------------------------------------------------------------
-- Geen inhoudelijke fouten, maar open deuren: een positieneutrale
-- omschrijving is precies wat een taalmodel als vrijbrief leest om er
-- weer 'ได้ + VERB' van te maken.

update public.grammar_master set
  short_explanation = 'Use ได้ after the whole verb phrase to say someone can do something.'
where concept_key = 'ability_dai';

update public.grammar_master set
  short_explanation = 'Use ได้ after the whole verb phrase to say someone may do something or had the chance to do it.'
where concept_key = 'opportunity_or_permission_dai';

update public.grammar_master set
  short_explanation = 'Use ไม่ได้ after the whole verb phrase to say someone cannot do something or is not allowed to.'
where concept_key = 'inability_or_not_allowed_mai_dai';

-- achievement_do_successfully_dai blijft ongewijzigd: die zegt al
-- "after some verbs" en draagt de positie dus wel.

commit;

-- ------------------------------------------------------------
-- 3. Controle
-- ------------------------------------------------------------
-- Verwacht: verb_dai bestaat, dai_verb niet meer, en alle vier de
-- ได้-formules staan postverbaal behalve mai_dai_verb.

select pattern_key, title, pattern_formula, pattern_type
from public.pattern_master
where pattern_formula like '%ได้%'
order by pattern_key;

select concept_key, short_explanation
from public.grammar_master
where concept_key in (
  'ability_dai',
  'opportunity_or_permission_dai',
  'inability_or_not_allowed_mai_dai',
  'achievement_do_successfully_dai'
)
order by concept_key;

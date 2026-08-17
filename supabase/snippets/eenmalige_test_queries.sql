do $$
declare
  v_lesson_id   bigint;
  v_lesson_key  text;
  v_note_id     bigint;
  v_eg_block_id bigint;
  v_note_order  integer;
  v_vocab_id    bigint;
  v_vocab_word  text;
begin
  -- 1. Kies de eerste gepubliceerde les met minstens één target-woord.
  select l.id, l.lesson_key
    into v_lesson_id, v_lesson_key
  from public.lessons l
  where l.is_published = true
    and exists (
      select 1
      from public.lesson_vocabulary lv
      where lv.lesson_id = l.id
        and lv.role = 'target'
    )
  order by l.sequence_number nulls last, l.id
  limit 1;

  if v_lesson_id is null then
    raise exception
      'Geen gepubliceerde les met een target-woord gevonden. Publiceer eerst een les met vocab.';
  end if;

  raise notice 'Seed koppelt aan les: % (id=%)', v_lesson_key, v_lesson_id;

  -- 2. Language Note met alle vijf bloktypes.
  --    Idempotent: alleen aanmaken als deze titel nog niet bestaat
  --    voor deze les.
  if not exists (
    select 1
    from public.language_notes
    where lesson_id = v_lesson_id
      and title = 'Ja/nee-vragen met ไหม'
  ) then
    select coalesce(max(display_order), 0) + 1
      into v_note_order
    from public.language_notes
    where lesson_id = v_lesson_id;

    insert into public.language_notes (lesson_id, title, display_order)
    values (v_lesson_id, 'Ja/nee-vragen met ไหม', v_note_order)
    returning id into v_note_id;

    -- Tekstblokken (heading blijft null, content verplicht).
    insert into public.language_note_blocks
      (language_note_id, display_order, block_type, heading, content)
    values
      (v_note_id, 1, 'subheading', null, 'Wat is ไหม?'),
      (v_note_id, 2, 'paragraph',  null,
        'Je maakt een ja/nee-vraag door ไหม achter de zin te zetten.'
        || E'\n\n' ||
        'De toon van ไหม is stijgend; het staat altijd aan het eind.'),
      (v_note_id, 3, 'formula',    null, '[zin] + ไหม');

    -- example_group apart: we hebben zijn id nodig voor de voorbeelden.
    insert into public.language_note_blocks
      (language_note_id, display_order, block_type, heading, content)
    values
      (v_note_id, 4, 'example_group', 'Voorbeelden',
        'Let op de stijgende toon aan het eind.')
    returning id into v_eg_block_id;

    -- block_type defaultt op 'example_group' en voldoet zo aan de
    -- samengestelde FK (block_id, block_type).
    insert into public.language_note_examples
      (block_id, display_order, thai_script, paiboon, translation_en)
    values
      (v_eg_block_id, 1, 'สบายดีไหม', 'sà-baai-dii mǎi', 'How are you?'),
      (v_eg_block_id, 2, 'อร่อยไหม',  'à-ròi mǎi',       'Is it tasty?');

    insert into public.language_note_blocks
      (language_note_id, display_order, block_type, heading, content)
    values
      (v_note_id, 5, 'usage_tip', null,
        'In informele spraak hoor je soms มั้ย in plaats van ไหม.');

    raise notice 'Language Note aangemaakt (id=%), 5 blokken + 2 voorbeelden.', v_note_id;
  else
    raise notice 'Language Note bestond al; overgeslagen.';
  end if;

  -- 3. Vocabulary examples voor het eerste target-woord van de les.
  --    Idempotent: alleen als dat woord nog geen voorbeelden heeft
  --    (zo overschrijven we nooit echte content).
  select vm.id, vm.thai_script
    into v_vocab_id, v_vocab_word
  from public.lesson_vocabulary lv
  join public.vocabulary_master vm on vm.id = lv.vocabulary_id
  where lv.lesson_id = v_lesson_id
    and lv.role = 'target'
  order by lv.display_order nulls last, lv.id
  limit 1;

  if v_vocab_id is not null
     and not exists (
       select 1 from public.vocabulary_examples where vocabulary_id = v_vocab_id
     )
  then
    insert into public.vocabulary_examples
      (vocabulary_id, display_order, thai_script, paiboon, translation_en)
    values
      (v_vocab_id, 1, v_vocab_word || ' ครับ',
        '(seed-voorbeeld) … kráp', 'Seed example 1 for ' || v_vocab_word),
      (v_vocab_id, 2, v_vocab_word || ' ค่ะ',
        '(seed-voorbeeld) … kâ',   'Seed example 2 for ' || v_vocab_word);
    raise notice 'Twee vocabulary_examples toegevoegd aan woord "%" (id=%).',
      v_vocab_word, v_vocab_id;
  else
    raise notice
      'Vocab-voorbeelden overgeslagen (geen target-woord, of woord had al voorbeelden).';
  end if;
end $$;
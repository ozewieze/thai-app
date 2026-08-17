-- ============================================================
-- Verificatie: kan een Language Note-seed idempotent zijn?
-- ============================================================
-- Draaien met:
--   psql postgresql://postgres:postgres@127.0.0.1:5432/postgres \
--     -P pager=off -f supabase/qa/verify_language_note_upsert_keys.sql
--
-- Dit script schrijft niets: alles staat in één transactie die op
-- `rollback` eindigt. Het hoort daarom thuis in qa/ en niet in
-- maintenance/.
--
-- Achtergrond. De seeds van Language Notes moeten idempotent zijn,
-- net als de leslink-seeds sinds 2026-08-02: het bestand opnieuw
-- draaien is de manier om een correctie door te voeren. Dat vraagt
-- `insert ... on conflict ... do update`, en dat vraagt een sleutel om
-- op te botsen. De vraag die dit script beantwoordt is: welke van de
-- bestaande unique constraints kán die sleutel zijn?
--
-- Het script is bewust herhaalbaar vóór én ná de sleutelmigratie
-- (20260803120000_add_language_note_natural_keys.sql). Sectie 5 en 6
-- slaan zichzelf over zolang die migratie nog niet gedraaid is.
-- ============================================================

begin;

\echo ''
\echo '=== 1. indimmediate per unique index op de vier LN-tabellen ==='
\echo '    Verwacht: de drie *_order_unique staan op f (deferrable),'
\echo '    de vier partiele concept-indexen op t.'
\echo ''

select
  t.relname                        as tabel,
  c.relname                        as index_naam,
  i.indimmediate                   as bruikbaar_als_arbiter,
  (i.indpred is not null)          as partieel
from pg_index i
join pg_class c on c.oid = i.indexrelid
join pg_class t on t.oid = i.indrelid
where t.relname in (
        'language_notes',
        'language_note_blocks',
        'language_note_examples',
        'language_note_concepts')
  and i.indisunique
order by t.relname, c.relname;

\echo ''
\echo '=== 2. Waarom indimmediate hier de doorslag geeft ==='
\echo '    Postgres kiest de arbiter-index in infer_arbiter_indexes() en'
\echo '    slaat elke index over waarvan indimmediate false is. Die vlag'
\echo '    wordt gezet als `not deferrable` -- DEFERRABLE INITIALLY'
\echo '    IMMEDIATE geeft dus indimmediate = false. "Initially immediate"'
\echo '    verplaatst alleen het startpunt binnen de transactie; het'
\echo '    verandert de eigenschap van de index niet.'
\echo ''
\echo '    LET OP -- dit is een UITVOERINGSFOUT, geen planfout. Gemeten op'
\echo '    2026-08-03: `explain (costs off) insert ... on conflict'
\echo '    (lesson_id, display_order) ...` slaagt gewoon en toont'
\echo '    "Conflict Arbiter Indexes: language_notes_lesson_order_unique".'
\echo '    Pas bij het werkelijk uitvoeren weigert Postgres. Wie dit met'
\echo '    EXPLAIN probeert te verifieren, concludeert dus het'
\echo '    tegenovergestelde van de waarheid.'
\echo ''
\echo '    De drie proeven hieronder voeren dus echt uit. Ze vangen de'
\echo '    fout op in plaats van eraan te bezwijken, en controleren of het'
\echo '    werkelijk de arbiter-fout is. Zonder die controle zou een'
\echo '    willekeurige andere fout als bewijs tellen, en dan meet het'
\echo '    script iets anders dan het denkt. Concreet: na de'
\echo '    sleutelmigratie loopt een rij zonder note_key eerst tegen NOT'
\echo '    NULL aan, en die fout komt vóór de arbiter-controle. De probes'
\echo '    vullen de sleutelkolommen daarom in zodra ze bestaan.'
\echo ''

do $$
declare
  v_arbiter_fout constant text := 'ON CONFLICT does not support deferrable';
  v_heeft_keys   boolean;
  v_sql          text;
  v_naam         text;
begin
  select exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name   = 'language_notes'
      and column_name  = 'note_key')
  into v_heeft_keys;

  foreach v_naam in array array['2a', '2b', '2c'] loop
    v_sql := case v_naam
      -- 2a. arbiter via kolomlijst
      when '2a' then format($sql$
        insert into public.language_notes (lesson_id, title, display_order %s)
        values (
          (select id from public.lessons where lesson_key = 'a1-dialog-03'),
          'qa-probe', 1 %s)
        on conflict (lesson_id, display_order) do update
          set title = excluded.title
      $sql$,
        case when v_heeft_keys then ', note_key' else '' end,
        case when v_heeft_keys then ', ''zz-qa-arbiter-probe''' else '' end)

      -- 2b. dezelfde constraint, maar op naam aangeroepen
      when '2b' then format($sql$
        insert into public.language_notes (lesson_id, title, display_order %s)
        values (
          (select id from public.lessons where lesson_key = 'a1-dialog-03'),
          'qa-probe', 1 %s)
        on conflict on constraint language_notes_lesson_order_unique do update
          set title = excluded.title
      $sql$,
        case when v_heeft_keys then ', note_key' else '' end,
        case when v_heeft_keys then ', ''zz-qa-arbiter-probe''' else '' end)

      -- 2c. dezelfde vraag voor blocks. language_note_id 0 bestaat niet,
      -- maar dat doet er niet toe: de arbiter-controle komt vóór de
      -- foreign key. Blijkt dat ooit andersom, dan meldt de classificatie
      -- hieronder dat als ONDUIDELIJK in plaats van het te verzwijgen.
      when '2c' then format($sql$
        insert into public.language_note_blocks (language_note_id, display_order, block_type, content %s)
        values (0, 1, 'paragraph', 'qa-probe' %s)
        on conflict (language_note_id, display_order) do update
          set content = excluded.content
      $sql$,
        case when v_heeft_keys then ', block_key' else '' end,
        case when v_heeft_keys then ', ''b1''' else '' end)
    end;

    begin
      execute v_sql;
      raise notice '% ONVERWACHT GESLAAGD -- de deferrable constraint werd wel als arbiter geaccepteerd. Herzie de sleutelmigratie.', v_naam;
    exception when others then
      if position(v_arbiter_fout in sqlerrm) > 0 then
        raise notice '% verwacht geweigerd: %', v_naam, sqlerrm;
      else
        raise notice '% ONDUIDELIJK -- geweigerd, maar om een andere reden: %', v_naam, sqlerrm;
      end if;
    end;
  end loop;
end $$;

\echo ''
\echo '=== 3. Triggers op de LN-tabellen en op de dialoogtabellen ==='
\echo '    Verwacht: uitsluitend BEFORE UPDATE (updated_at) op notes,'
\echo '    blocks en examples. Geen enkele trigger op'
\echo '    language_note_concepts, dialogs of dialog_blocks.'
\echo ''
\echo '    Waarom dit ertoe doet: een BEFORE INSERT-trigger vuurt voordat'
\echo '    Postgres het conflict detecteert, dus TG_OP is dan INSERT en'
\echo '    de on-conflict-tak wordt niet bereikt. Dat kostte op 2026-08-02'
\echo '    een migratie op de state machines'
\echo '    (20260802120000_single_introduction_allow_reseed.sql). Staat'
\echo '    hier geen BEFORE INSERT, dan speelt dat probleem hier niet.'
\echo ''
\echo '    Tweede gevolg: omdat de updated_at-trigger bij UPDATE al vuurt,'
\echo '    hoort `updated_at = now()` NIET in de do-update-clausule van de'
\echo '    LN-seeds. De dialoogseed schrijft die regel wel, en terecht --'
\echo '    dialogs en dialog_blocks hebben geen updated_at-trigger.'
\echo ''

select
  tgrelid::regclass::text as tabel,
  tgname                  as trigger_naam,
  case when (tgtype & 2) = 2 then 'BEFORE' else 'AFTER' end as timing,
  concat_ws(', ',
    case when (tgtype &  4) =  4 then 'INSERT' end,
    case when (tgtype &  8) =  8 then 'DELETE' end,
    case when (tgtype & 16) = 16 then 'UPDATE' end) as gebeurtenis
from pg_trigger
where not tgisinternal
  and tgrelid::regclass::text in (
        'language_notes',
        'language_note_blocks',
        'language_note_examples',
        'language_note_concepts',
        'dialogs',
        'dialog_blocks')
order by 1, 2;

\echo ''
\echo '=== 4. Zijn de vier LN-tabellen leeg? ==='
\echo '    Bepaalt of de sleutelmigratie de kolommen direct op NOT NULL'
\echo '    kan zetten of eerst moet backfillen. Verwacht: overal 0.'
\echo ''

select 'language_notes'         as tabel, count(*) from public.language_notes
union all--union all betekent dat de rijen van de vier queries onder elkaar komen, zodat je in één oogopslag ziet of er ergens iets staat.
select 'language_note_blocks',   count(*) from public.language_note_blocks
union all
select 'language_note_examples', count(*) from public.language_note_examples
union all
select 'language_note_concepts', count(*) from public.language_note_concepts
order by 1;

\echo ''
\echo '=== 5. Na de sleutelmigratie: upsert op note_key ==='
\echo '    Slaat zichzelf over zolang de migratie niet gedraaid is.'
\echo '    Verwacht daarna: tweemaal invoegen levert een gewijzigde titel'
\echo '    op en precies een rij.'
\echo ''

do $$
declare
  v_note_id bigint;
  v_titel   text;
  v_aantal  int;
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name   = 'language_notes'
      and column_name  = 'note_key')
  then
    raise notice '5  overgeslagen: kolom language_notes.note_key bestaat nog niet.';
    return;
  end if;

  execute $sql$
    insert into public.language_notes (lesson_id, note_key, title, display_order)
    values (
      (select id from public.lessons where lesson_key = 'a1-dialog-03'),
      'zz-qa-probe-note-1', 'Eerste titel', 1)
    on conflict (note_key) do update
      set title         = excluded.title,
          display_order = excluded.display_order
  $sql$;

  execute $sql$
    insert into public.language_notes (lesson_id, note_key, title, display_order)
    values (
      (select id from public.lessons where lesson_key = 'a1-dialog-03'),
      'zz-qa-probe-note-1', 'Tweede titel', 1)
    on conflict (note_key) do update
      set title         = excluded.title,
          display_order = excluded.display_order
  $sql$;

  select id, title into v_note_id, v_titel
  from public.language_notes where note_key = 'zz-qa-probe-note-1';

  select count(*) into v_aantal
  from public.language_notes where note_key = 'zz-qa-probe-note-1';

  if v_aantal = 1 and v_titel = 'Tweede titel' then
    raise notice '5  geslaagd: 1 rij, titel bijgewerkt naar "%".', v_titel;
  else
    raise notice '5  MISLUKT: % rijen, titel "%".', v_aantal, v_titel;
  end if;

  -- 5b. herordenen moet blijven werken: display_order is deferrable,
  -- dus twee notes mogen binnen een transactie van plaats wisselen.
  execute $sql$
    insert into public.language_notes (lesson_id, note_key, title, display_order)
    values (
      (select id from public.lessons where lesson_key = 'a1-dialog-03'),
      'zz-qa-probe-note-2', 'Tweede note', 2)
    on conflict (note_key) do update set title = excluded.title
  $sql$;

  set constraints public.language_notes_lesson_order_unique deferred;
  update public.language_notes set display_order = 2 where note_key = 'zz-qa-probe-note-1';
  update public.language_notes set display_order = 1 where note_key = 'zz-qa-probe-note-2';
  set constraints public.language_notes_lesson_order_unique immediate;

  raise notice '5b geslaagd: display_order omgewisseld binnen de transactie; de deferrable constraint doet nog waarvoor ze deferrable is.';
end $$;

\echo ''
\echo '=== 6. Arbiter voor language_note_concepts ==='
\echo '    De vier partiele unique indexen zijn niet-deferrable en dus wel'
\echo '    bruikbaar, mits het predicaat in de infer-clausule staat.'
\echo '    Verwacht: met predicaat geslaagd, zonder predicaat geweigerd.'
\echo ''

do $$
declare
  v_note_id bigint;
  v_aantal  int;
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name   = 'language_notes'
      and column_name  = 'note_key')
  then
    raise notice '6  overgeslagen: kolom language_notes.note_key bestaat nog niet.';
    return;
  end if;

  execute $sql$
    select id from public.language_notes where note_key = 'zz-qa-probe-note-1'
  $sql$ into v_note_id;

  if v_note_id is null then
    raise notice '6  overgeslagen: sectie 5 heeft geen proefnote aangemaakt.';
    return;
  end if;

  -- 6a. met predicaat
  begin
    execute format($sql$
      insert into public.language_note_concepts (language_note_id, lesson_id, lesson_vocabulary_id)
      select %s,
             lv.lesson_id,
             lv.id
      from public.lesson_vocabulary lv
      where lv.lesson_id     = (select id from public.lessons where lesson_key = 'a1-dialog-03')
        and lv.vocabulary_id = (select id from public.vocabulary_master where source_key = 'hot')
      on conflict (lesson_vocabulary_id, language_note_id)
        where lesson_vocabulary_id is not null
      do nothing
    $sql$, v_note_id);
    -- tweede keer: moet 0 rijen toevoegen
    execute format($sql$
      insert into public.language_note_concepts (language_note_id, lesson_id, lesson_vocabulary_id)
      select %s, lv.lesson_id, lv.id
      from public.lesson_vocabulary lv
      where lv.lesson_id     = (select id from public.lessons where lesson_key = 'a1-dialog-03')
        and lv.vocabulary_id = (select id from public.vocabulary_master where source_key = 'hot')
      on conflict (lesson_vocabulary_id, language_note_id)
        where lesson_vocabulary_id is not null
      do nothing
    $sql$, v_note_id);

    select count(*) into v_aantal
    from public.language_note_concepts where language_note_id = v_note_id;

    if v_aantal = 1 then
      raise notice '6a geslaagd: partiele index werkt als arbiter, tweede run voegde niets toe.';
    else
      raise notice '6a MISLUKT: % rijen na twee runs.', v_aantal;
    end if;
  exception when others then
    raise notice '6a MISLUKT: %', sqlerrm;
  end;

  -- 6b. zonder predicaat
  begin
    execute format($sql$
      insert into public.language_note_concepts (language_note_id, lesson_id, lesson_vocabulary_id)
      select %s, lv.lesson_id, lv.id
      from public.lesson_vocabulary lv
      where lv.lesson_id     = (select id from public.lessons where lesson_key = 'a1-dialog-03')
        and lv.vocabulary_id = (select id from public.vocabulary_master where source_key = 'cool')
      on conflict (lesson_vocabulary_id, language_note_id) do nothing
    $sql$, v_note_id);
    raise notice '6b ONVERWACHT GESLAAGD -- zonder predicaat werd de partiele index toch gekozen.';
  exception when others then
    raise notice '6b verwacht geweigerd: %', sqlerrm;
  end;
end $$;

\echo ''
\echo '=== Einde. Alles wordt teruggedraaid. ==='
rollback;

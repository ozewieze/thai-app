alter table public.character_profiles enable row level security;
alter table public.relationship_pairs enable row level security;
alter table public.relationship_pair_rules enable row level security;


create policy "Character profiles are readable by everyone"
on public.character_profiles
for select
to anon, authenticated
using (true);


create policy "Active relationship pairs are readable by everyone"
on public.relationship_pairs
for select
to anon, authenticated
using (
  is_active = true
);


create policy "Rules of active relationship pairs are readable by everyone"
on public.relationship_pair_rules
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.relationship_pairs rp
    where rp.id = relationship_pair_rules.relationship_pair_id
      and rp.is_active = true
  )
);
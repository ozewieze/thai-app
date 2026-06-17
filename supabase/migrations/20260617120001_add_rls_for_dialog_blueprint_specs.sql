-- Enable RLS on dialog_blueprint_specs.
-- Dit is een interne auteurstabel (geen app-gebruikersdata).
-- Er is bewust geen publieke policy: de tabel is geblokkeerd voor
-- anon en authenticated via de API.

alter table public.dialog_blueprint_specs enable row level security;

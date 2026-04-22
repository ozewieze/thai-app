select tablename, policyname, cmd, roles
from pg_policies
where schemaname = 'public'
order by tablename, policyname;
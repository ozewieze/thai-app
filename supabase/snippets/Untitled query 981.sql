select pattern_key, title, pattern_formula, pattern_type
from public.pattern_master
where pattern_formula like '%ได้%'
order by pattern_key;

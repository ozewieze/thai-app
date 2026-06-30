-- kolommen zichtbaar op dialog_blocks?
select column_name, data_type
from information_schema.columns
where table_name = 'dialog_blocks'
  and column_name in ('full_start_ms', 'full_end_ms');


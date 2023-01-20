create or replace view check_national_code as 
	select *,
	((cast(substring(natcod, 1, 1) as int) * 10 +
	 cast(substring(natcod, 2, 1) as int) * 9 +
	 cast(substring(natcod, 3, 1) as int) * 8 +
	 cast(substring(natcod, 4, 1) as int) * 7 +
	 cast(substring(natcod, 5, 1) as int) * 6 +
	 cast(substring(natcod, 6, 1) as int) * 5 +
	 cast(substring(natcod, 7, 1) as int) * 4 +
	 cast(substring(natcod, 8, 1) as int) * 3 +
	 cast(substring(natcod, 9, 1) as int) * 2) % 11
	) as ctrl_bit
	from customer;
	
-- Sample
select cid, name, natcod,
(case 
 	when ctrl_bit < 2 then ctrl_bit = cast(substring(natcod, 10, 1) as int) 
 	else ctrl_bit = 11 - cast(substring(natcod, 10, 1) as int)
 end) as is_valid 
from check_national_code;
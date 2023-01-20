create or replace function transact(id varchar(10), type char(1)) returns table(voucherid varchar(10), trndate date, trntime time, amount bigint, sourcedep int, desdep int, branch_id int, trn_desc varchar(255)) language plpgsql as $$
declare f_date date;
declare counter int;
declare tar record;
declare row record;
begin
	return query select * from trn_src_des where trn_src_des.voucherid = id;
	select * into tar from trn_src_des where trn_src_des.voucherid = id;

	if type = 'l' and exists(select * from deposit where dep_id = tar.sourcedep) then
		select 0 into counter;
		select max(t.trndate) into f_date from trn_src_des as t where t.desdep = tar.sourcedep and t.trndate <= tar.trndate;
		for row in (select * from trn_src_des where trn_src_des.trndate = f_date and trn_src_des.amount = tar.amount) loop
			return query select * from transact(row.voucherid, 'l'); end loop;
		for row in (select * from trn_src_des where trn_src_des.desdep = tar.sourcedep and trn_src_des.trndate = f_date and trn_src_des.amount <> tar.amount) loop
			select counter + row.amount into counter;
			return query select * from transact(row.voucherid, 'l'); end loop;
		for row in (select * from trn_src_des where trn_src_des.desdep = tar.sourcedep and trn_src_des.trndate < f_date order by trndate desc, trntime desc) loop
			select counter + row.amount into counter;
			exit when (counter > tar.amount * 1.1);
			return query select * from transact(row.voucherid, 'l');
			exit when (counter > tar.amount); end loop;
	elsif type = 'r' and exists(select dep_id from deposit where dep_id = tar.desdep) then
		select 0 into counter;
		select min(t.trndate) into f_date from trn_src_des as t where t.sourcedep = tar.desdep and t.trndate >= tar.trndate;
		for row in (select * from trn_src_des where trn_src_des.trndate = f_date and trn_src_des.amount = tar.amount) loop
			return query select * from transact(row.voucherid, 'r'); end loop;
		for row in (select * from trn_src_des where trn_src_des.sourcedep = tar.desdep and trn_src_des.trndate = f_date and trn_src_des.amount <> tar.amount) loop
			select counter + row.amount into counter;
			return query select * from transact(row.voucherid, 'r'); end loop;
		for row in (select * from trn_src_des where trn_src_des.sourcedep = tar.desdep and trn_src_des.trndate > f_date order by trndate, trntime) loop
			select counter + row.amount into counter;
			exit when (counter > tar.amount * 1.1);
			return query select * from transact(row.voucherid, 'r');
			exit when (counter > tar.amount); end loop;
	end if;
end $$;

-- Sample
select *
from
    (select *
     from transact('5', 'r')
     union select *
     from transact('5', 'l')) as t
order by trndate,
         trntime
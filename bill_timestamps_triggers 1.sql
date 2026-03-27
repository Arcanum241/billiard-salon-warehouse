if not exists (select 1 from information_schema.columns where table_schema = 'Billiard' and table_name = 'Customer' and column_name = 'modified_on')
    exec('alter table Billiard.Customer add modified_on datetime null')

if not exists (select 1 from information_schema.columns where table_schema = 'Billiard' and table_name = 'Staff' and column_name = 'modified_on')
    exec('alter table Billiard.Staff add modified_on datetime null')

if not exists (select 1 from information_schema.columns where table_schema = 'Billiard' and table_name = 'Tabless' and column_name = 'modified_on')
    exec('alter table Billiard.Tabless add modified_on datetime null')

if not exists (select 1 from information_schema.columns where table_schema = 'Billiard' and table_name = 'Service_' and column_name = 'modified_on')
    exec('alter table Billiard.Service_ add modified_on datetime null')

if not exists (select 1 from information_schema.columns where table_schema = 'Billiard' and table_name = 'Session_' and column_name = 'modified_on')
    exec('alter table Billiard.Session_ add modified_on datetime null')

if not exists (select 1 from information_schema.columns where table_schema = 'Billiard' and table_name = 'Payment' and column_name = 'modified_on')
    exec('alter table Billiard.Payment add modified_on datetime null')

go

create or alter trigger Billiard.trg_customer_timestamp
on Billiard.Customer
after insert, update
as
begin
    update Billiard.Customer
    set modified_on = getdate()
    from Billiard.Customer c
    inner join inserted i on c.Customer_id = i.Customer_id
end

go

create or alter trigger Billiard.trg_staff_timestamp
on Billiard.Staff
after insert, update
as
begin
    update Billiard.Staff
    set modified_on = getdate()
    from Billiard.Staff s
    inner join inserted i on s.Staff_id = i.Staff_id
end

go

create or alter trigger Billiard.trg_tabless_timestamp
on Billiard.Tabless
after insert, update
as
begin
    update Billiard.Tabless
    set modified_on = getdate()
    from Billiard.Tabless t
    inner join inserted i on t.Table_id = i.Table_id
end

go

create or alter trigger Billiard.trg_service_timestamp
on Billiard.Service_
after insert, update
as
begin
    update Billiard.Service_
    set modified_on = getdate()
    from Billiard.Service_ s
    inner join inserted i on s.Service_id = i.Service_id
end

go

create or alter trigger Billiard.trg_session_timestamp
on Billiard.Session_
after insert, update
as
begin
    update Billiard.Session_
    set modified_on = getdate()
    from Billiard.Session_ s
    inner join inserted i on s.Session_id_ = i.Session_id_
end

go

create or alter trigger Billiard.trg_payment_timestamp
on Billiard.Payment
after insert, update
as
begin
    update Billiard.Payment
    set modified_on = getdate()
    from Billiard.Payment p
    inner join inserted i on p.Payment_id = i.Payment_id
end

go

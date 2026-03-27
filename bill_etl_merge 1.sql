merge into billiard.dim_customer as target
using (
    select Customer_id, Name, Email, Phone
    from Billiard.Customer
) as source
on target.customer_id = source.Customer_id
when matched then
    update set
        target.customer_name = source.Name,
        target.customer_email = source.Email,
        target.customer_phone = source.Phone
when not matched by target then
    insert (customer_id, customer_name, customer_email, customer_phone)
    values (source.Customer_id, source.Name, source.Email, source.Phone)
when not matched by source then
    delete;

go

merge into billiard.dim_staff as target
using (
    select Staff_id, StaffName, Role
    from Billiard.Staff
) as source
on target.staff_id = source.Staff_id
when matched then
    update set
        target.staff_name = source.StaffName,
        target.staff_role = source.Role
when not matched by target then
    insert (staff_id, staff_name, staff_role)
    values (source.Staff_id, source.StaffName, source.Role)
when not matched by source then
    delete;

go

merge into billiard.dim_billiardtable as target
using (
    select Table_id, TableType, HourlyRate
    from Billiard.Tabless
) as source
on target.table_number = source.Table_id
when matched then
    update set
        target.table_type = source.TableType,
        target.hourly_rate = source.HourlyRate
when not matched by target then
    insert (table_number, table_type, hourly_rate)
    values (source.Table_id, source.TableType, source.HourlyRate)
when not matched by source then
    delete;

go

merge into billiard.dim_service as target
using (
    select distinct Service_id, ServiceName, ServiceCost
    from Billiard.Service_
) as source
on target.service_id = source.Service_id
when matched then
    update set
        target.service_name = source.ServiceName,
        target.service_cost = source.ServiceCost
when not matched by target then
    insert (service_id, service_name, service_cost)
    values (source.Service_id, source.ServiceName, source.ServiceCost)
when not matched by source then
    delete;

go

merge into billiard.dim_date as target
using (
    select distinct
        cast(convert(varchar(8), d, 112) as int) as date_key,
        d as full_date,
        year(d) as cal_year,
        month(d) as cal_month,
        day(d) as cal_day
    from (
        select cast(StartTime as date) as d from Billiard.Session_
        union
        select cast(EndTime as date) from Billiard.Session_
        union
        select cast(PaymentDate as date) from Billiard.Payment
    ) dates
    where d is not null
) as source
on target.date_key = source.date_key
when matched then
    update set
        target.full_date = source.full_date,
        target.cal_year = source.cal_year,
        target.cal_month = source.cal_month,
        target.cal_day = source.cal_day
when not matched by target then
    insert (date_key, full_date, cal_year, cal_month, cal_day)
    values (source.date_key, source.full_date, source.cal_year, source.cal_month, source.cal_day);

go

merge into billiard.fact_session as target
using (
    select
        s.Session_id_,
        c.customer_key,
        t.table_key,
        st.staff_key,
        cast(convert(varchar(8), s.StartTime, 112) as int) as start_date_key,
        cast(convert(varchar(8), s.EndTime, 112) as int) as end_date_key,
        s.TotalTime,
        null as amount_billed
    from Billiard.Session_ s
    join billiard.dim_customer c on s.Customer_id = c.customer_id
    join billiard.dim_billiardtable t on s.Table_id = t.table_number
    join billiard.dim_staff st on s.Staff_id = st.staff_id
) as source
on target.session_id = source.Session_id_
when not matched by target then
    insert (session_id, customer_key, table_key, staff_key, start_date_key, end_date_key, total_time_hours, amount_billed)
    values (source.Session_id_, source.customer_key, source.table_key, source.staff_key, source.start_date_key, source.end_date_key, source.TotalTime, source.amount_billed)
when not matched by source then
    delete;

go

merge into billiard.fact_payment as target
using (
    select
        p.Payment_id,
        fs.session_key,
        cast(convert(varchar(8), p.PaymentDate, 112) as int) as payment_date_key,
        p.Amount,
        p.PaymentStatus
    from Billiard.Payment p
    join billiard.fact_session fs on p.Session_id_ = fs.session_id
) as source
on target.payment_id = source.Payment_id
when not matched by target then
    insert (payment_id, session_key, payment_date_key, payment_amount, payment_status)
    values (source.Payment_id, source.session_key, source.payment_date_key, source.Amount, source.PaymentStatus)
when not matched by source then
    delete;

go

merge into billiard.fact_session_service as target
using (
    select
        fs.session_key,
        ds.service_key,
        ds.service_cost
    from Billiard.Service_ sv
    join billiard.fact_session fs on sv.Session_id_ = fs.session_id
    join billiard.dim_service ds on sv.Service_id = ds.service_id
) as source
on target.session_key = source.session_key and target.service_key = source.service_key
when not matched by target then
    insert (session_key, service_key, service_cost)
    values (source.session_key, source.service_key, source.service_cost)
when not matched by source then
    delete;

go

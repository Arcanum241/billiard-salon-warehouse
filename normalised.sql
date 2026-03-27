

drop table if exists billiard.session_services
drop table if exists billiard.payments
drop table if exists billiard.sessions
drop table if exists billiard.billiardtables
drop table if exists billiard.tabletypes
drop table if exists billiard.services
drop table if exists billiard.staff
drop table if exists billiard.customers
go

create table billiard.customers (
    customerid int primary key,
    customername varchar(255),
    customeremail varchar(255) unique,
    customerphone varchar(50),
    modifiedon datetime default getdate()
)

create table billiard.staff (
    staffid int primary key,
    staffname varchar(255),
    staffrole varchar(100),
    modifiedon datetime default getdate()
)

create table billiard.tabletypes (
    tabletypeid int primary key,
    typename varchar(50) unique,
    modifiedon datetime default getdate()
)

create table billiard.billiardtables (
    tablenumber int primary key,
    tabletypeid int,
    hourlyrate decimal(10, 2),
    modifiedon datetime default getdate(),
    foreign key (tabletypeid) references billiard.tabletypes(tabletypeid)
)

create table billiard.services (
    serviceid int primary key,
    servicename varchar(100),
    servicecost decimal(10, 2),
    modifiedon datetime default getdate()
)

create table billiard.sessions (
    sessionid int primary key,
    customerid int,
    tablenumber int,
    staffid int,
    starttime datetime,
    endtime datetime,
    totaltimehours float,
    amountbilled decimal(10, 2),
    modifiedon datetime default getdate(),
    foreign key (customerid) references billiard.customers(customerid),
    foreign key (tablenumber) references billiard.billiardtables(tablenumber),
    foreign key (staffid) references billiard.staff(staffid)
)

create table billiard.session_services (
    sessionid int,
    serviceid int,
    modifiedon datetime default getdate(),
    primary key (sessionid, serviceid),
    foreign key (sessionid) references billiard.sessions(sessionid),
    foreign key (serviceid) references billiard.services(serviceid)
)

create table billiard.payments (
    paymentid int primary key,
    sessionid int,
    paymentdate date,
    paymentamount decimal(10, 2),
    paymentstatus varchar(50),
    modifiedon datetime default getdate(),
    foreign key (sessionid) references billiard.sessions(sessionid)
)
go

create or alter trigger billiard.trg_customers_mod on billiard.customers
after update
as
begin
    update billiard.customers set modifiedon = getdate()
    from billiard.customers inner join inserted ins on billiard.customers.customerid = ins.customerid
end
go

create trigger billiard.trg_staff_mod on billiard.staff
after update
as
begin
    update billiard.staff set modifiedon = getdate()
    from billiard.staff inner join inserted ins on billiard.staff.staffid = ins.staffid
end
go

create trigger billiard.trg_tabletypes_mod on billiard.tabletypes
after update
as
begin
    update billiard.tabletypes set modifiedon = getdate()
    from billiard.tabletypes inner join inserted ins on billiard.tabletypes.tabletypeid = ins.tabletypeid
end
go

create trigger billiard.trg_billiardtables_mod on billiard.billiardtables
after update
as
begin
    update billiard.billiardtables set modifiedon = getdate()
    from billiard.billiardtables inner join inserted ins on billiard.billiardtables.tablenumber = ins.tablenumber
end
go

create trigger billiard.trg_services_mod on billiard.services
after update
as
begin
    update billiard.services set modifiedon = getdate()
    from billiard.services inner join inserted ins on billiard.services.serviceid = ins.serviceid
end
go

create trigger billiard.trg_sessions_mod on billiard.sessions
after update
as
begin
    update billiard.sessions set modifiedon = getdate()
    from billiard.sessions inner join inserted ins on billiard.sessions.sessionid = ins.sessionid
end
go

create trigger billiard.trg_session_services_mod on billiard.session_services
after update
as
begin
    update billiard.session_services set modifiedon = getdate()
    from billiard.session_services inner join inserted ins on billiard.session_services.sessionid = ins.sessionid and billiard.session_services.serviceid = ins.serviceid
end
go

create trigger billiard.trg_payments_mod on billiard.payments
after update
as
begin
    update billiard.payments set modifiedon = getdate()
    from billiard.payments inner join inserted ins on billiard.payments.paymentid = ins.paymentid
end
go

insert into billiard.customers (customerid, customername, customeremail, customerphone)
select 
    dense_rank() over (order by customer_email) as customerid,
    customer_name, 
    customer_email, 
    customer_phone
from billiard.[billiard salon management]
where customer_email is not null
group by customer_name, customer_email, customer_phone

insert into billiard.staff (staffid, staffname, staffrole)
select 
    dense_rank() over (order by staff_name) as staffid,
    staff_name, 
    staff_role
from billiard.[billiard salon management]
where staff_name is not null
group by staff_name, staff_role

insert into billiard.tabletypes (tabletypeid, typename)
select 
    dense_rank() over (order by table_type) as tabletypeid,
    table_type
from billiard.[billiard salon management]
where table_type is not null
group by table_type

insert into billiard.billiardtables (tablenumber, tabletypeid, hourlyrate)
select distinct 
    b.table_number, 
    tt.tabletypeid, 
    b.hourly_rate
from billiard.[billiard salon management] b
join billiard.tabletypes tt on b.table_type = tt.typename
where b.table_number is not null

insert into billiard.services (serviceid, servicename, servicecost)
select 
    dense_rank() over (order by service_name) as serviceid,
    service_name, 
    service_cost
from billiard.[billiard salon management]
where service_name is not null
group by service_name, service_cost

insert into billiard.sessions (sessionid, customerid, tablenumber, staffid, starttime, endtime, totaltimehours, amountbilled)
select distinct 
    b.session_id, 
    c.customerid, 
    b.table_number, 
    st.staffid, 
    cast(b.start_time as datetime) as starttime, 
    cast(b.end_time as datetime) as endtime, 
    b.[total_time_hours], 
    b.amount_billed
from billiard.[billiard salon management] b
join billiard.customers c on b.customer_email = c.customeremail
join billiard.staff st on b.staff_name = st.staffname

insert into billiard.session_services (sessionid, serviceid)
select distinct 
    b.session_id, 
    s.serviceid
from billiard.[billiard salon management] b
join billiard.services s on b.service_name = s.servicename
where b.service_name is not null

insert into billiard.payments (paymentid, sessionid, paymentdate, paymentamount, paymentstatus)
select 
    row_number() over (order by t.session_id, t.payment_date) as paymentid,
    t.session_id, 
    cast(t.payment_date as date) as paymentdate, 
    t.payment_amount, 
    t.payment_status
from (
    select distinct 
        session_id, 
        payment_date, 
        payment_amount, 
        payment_status
    from billiard.[billiard salon management]
    where payment_date is not null
) t
go


select * from Billiard.customers
select * from Billiard.dim_customer



update billiard.customers set customername = upper(customername) where customerid = 1





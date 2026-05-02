create database transport 
use transport
create table Worker_types (
Worker_type_id int identity ,
Worker_type_name varchar(15) not null,
constraint PK_Worker_tyepes#Worker_tyepe_id primary key(Worker_type_id) 
)
create table workers(
Worker_id int identity,
Worker_type_id int not null,
Identity_number varchar(10) not null,
First_name varchar(15) not null,
Last_name varchar(15) not null,
Phone_number varchar(10) not null,
License_number varchar(8) not null,
constraint PK_workers#worker_id primary key(Worker_id),
constraint FK_Worker_tyepe foreign key (Worker_type_id)
references Worker_types(Worker_type_id)
)
create table Cities (
City_id int identity,
City_name varchar(50) not null,
constraint PK_citys#city_id primary key(City_id) 
)
create table Stations (
Station_id int identity,
Station_name varchar(50) not null,
City_id int not null,
constraint PK_Stations#Station_id primary key(Station_id),
constraint FK_Cities#Stations foreign key (City_id)
references Cities(City_id)
)
create table Lines (
Line_id int identity,
Line_number  int unique not null,
Starting_point int not null,
Ending_point int not null,
Travel_time int not null,
constraint PK_lines#line_id primary key(Line_id),
constraint FK_Cities#Station_start foreign key (Starting_point)
references Stations(Station_id),
constraint FK_Citys#Station_end foreign key (Ending_point)
references Stations(Station_id)
)
create table Routes (
Route_id int identity,
Line_id int not null,
Station_id int not null,
Stop_order int not null,
constraint PK_Routes#Route_id primary key(Route_id),
constraint FK_Lines#Routes foreign key (Line_id)
references Lines(Line_id),
constraint FK_Stations#Routes foreign key (Station_id)
references Stations(Station_id)
)
create table Travels (
Travel_id int identity,
Line_id int not null,
Worker_id int not null,
Exit_date_time datetime not null,
constraint PK_Travels#Travels_id primary key(Travel_id),
constraint FK_Lines#Travels foreign key (Line_id)
references Lines(Line_id),
constraint FK_Travels#Workers foreign key (Worker_id)
references Workers(Worker_id)
)
insert into  Worker_types(Worker_type_name)
values('נהג אוטובוס'),
('פקח'),
('מנהל תחנה'),
('מתפעל קווים')
insert into workers(Worker_type_id,Identity_number,First_name,Last_name,Phone_number,License_number)
values(1,'123456789','David','Levi','0501234567','87654321'),
(1,'234567891', 'Michael','Cohen', '0509876543', '76543210' ),
(2, '345678912', 'Yael', 'Ben ami', '0549876543', '65432109'),
(3, '456789123', 'Chaim', 'Peretz', '0532223344', '54321098')
insert into Cities (City_name)
values ('Jerusalem'),
('Tel Aviv'),
('Haifa'),
('Beer shba'),
('Ashdod')
insert into Stations(Station_name,City_id)
values ('Jerusalem Central Station',1),
('Tel Aviv Central Station',2),
('Azrieli Mall',2),
('Haifa Central Train Station',3),
('Beersheba Central Station',4)
insert into Lines (Line_number,Starting_point,Ending_point,Travel_time)
values (405,2,1,60),
(940,2,3,50),
(18,3,4,40),
(1,5,2,90)
insert into Routes (Line_id, Station_id, Stop_order)
values (1,2,1),
(1,3,2),
(1,1,3),
(2,2,1),
(2,2,3)
insert into Travels (Line_id,Worker_id,Exit_date_time)
values (1,1,'2025-02-27 08:00:00'),
(1, 2, '2025-02-27 12:00:00'),
(2,1,'2025-02-27 10:00:00'),
(3,2,'2025-02-27 15:30:00')
select * from Worker_types
select * from workers
select * from Cities
select * from Stations
select * from Lines
select * from Routes
select * from Travels
----------------


----מחזיר כמה נסיעות לעובד מסוים
alter function dbo.FN_travelOfWorker(@idWorker int, @yaer int, @month int)
returns int
as
begin
declare @count int
set @count=(
select (select COUNT(*) from Travels t
where t.Worker_id=w.Worker_id
and month(t.Exit_date_time)=@month
and year(t.Exit_date_time)=@yaer)
from workers w
where w.Worker_id= @idWorker
)
return(@count)
end
--לראות שעובד
select dbo.FN_travelOfWorker(1,2025,2)

--כמות נסיעות לכל עובד בחודשי השנה
go
declare @month_ int =1
while @month_ <=12
begin
print 'month:' + cast(@month_ as varchar)
select *, dbo.FN_travelOfWorker(Worker_id,2025,@month_) as count_of_travel from workers
set @month_=(@month_ )+1
end 
go


alter procedure PR_travels_workers (@month int , @year int)
as
begin
select Worker_id, dbo.FN_travelOfWorker(Worker_id,@year,@month) as numberOfTravels,'bus driver' as workerTypsName
from workers
where Worker_type_id=1
union
select Worker_id, dbo.FN_travelOfWorker(Worker_id,@year,@month) as numberOfTravels,'inspector' as workerTypsName
from workers
where Worker_type_id=2
end

exec PR_travels_workers @month=3, @year=2025

go



alter function dbo.check_number(@identityNumber varchar(15))
returns varchar(10)
as
begin
    declare @status varchar(10)
    set @identityNumber = LTRIM(RTRIM(@identityNumber))
    
    if len(@identityNumber) = 9
        set @status = 'teru'
    else
        set @status = 'false'
    
    return(@status)
end

select dbo.check_number('329080592')

alter procedure PR_addWorker(
@identity_number varchar(9),
@Worker_type_id int,
@First_name varchar(15),
@Last_name varchar(15),
@Phone_number varchar(10),
@License_number varchar(8)
)
as
begin
if(select Identity_number from workers where Identity_number=@identity_number) is not null
begin
print 'העובד קיים'
end
else 
begin
declare @foundIdentity_number varchar (9)
set  @foundIdentity_number=dbo.check_number(@identity_number)
if @foundIdentity_number='false'
print 'תעודת זהות לא תקינה'
else
begin
insert into workers(identity_number,Worker_type_id,First_name,Last_name,Phone_number,License_number)
values (
@identity_number ,
@Worker_type_id,
@First_name ,
@Last_name ,
@Phone_number ,
@License_number 
)
print 'העובד נוסף בהצלחה'
end
end
end

exec  PR_addWorker @identity_number='024006884', @Worker_type_id=2, @First_name='Noam' ,@Last_name = 'Yafen',  @Phone_number ='0506247879', @License_number ='32165498'
go


create table Stations_log(
Station_name varchar(50),
City_id int not null,
date_log datetime not null,
type_log varchar(10) not null
)
select * from Stations_log

create trigger TR_UID_Stations_log
on Stations
for update,insert,delete
as
begin
insert into Stations_log(Station_name,City_id,date_log,type_log)
select i.Station_name, i.City_id,getdate(),
case when d.Station_id is not null then 'update' else 'insert' end
from inserted i 
left join deleted d
on i.Station_id=d.Station_id
union
select  d.Station_name, d.City_id, getdate(),
'delelte'
from deleted d
left join inserted i
on i.Station_id=d.Station_id
where i.Station_id is null
end

go
insert into Stations(Station_name,City_id)
values('Centeral Station',5)
select * from Stations_log

DELETE FROM Stations WHERE Station_id = 6

create view travel 
as
select w.Worker_id,w.First_name,w.Last_name,l.Line_number,s.Station_name as 'first station',s_2.Station_name as 'last station'
from workers w
join Travels t on t.Worker_id=w.Worker_id
 join Lines l
on l.Line_id=t.Line_id
 join Stations s
on s.Station_id=l.Starting_point
 join Stations s_2 
on s_2.Station_id=l.Ending_point

select * from travel


alter procedure PR_addTravel(
@Worker_id int,
@Exit_date_time datetime,
@Line_id int
)
as begin 
if(select Exit_date_time from Travels
where Worker_id = @Worker_id and Exit_date_time=@Exit_date_time ) is not null
begin
select
':העובד תפוס ואלו פרטי הנסיעה השמורים לו'
 exec PR_unavailable @worker_id = @Worker_id, @time = @Exit_date_time
 end
else
begin
begin try
insert into Travels(Line_id,Worker_id,Exit_date_time)
values(@Line_id,@Worker_id,@Exit_date_time)
print 'הנסיעה נוספה בהצלחה'
end try
begin catch
print 'ארע שגיאה, כנראה אחד הנתונים  שגוי, נסה להכניס שוב!'
end catch
end
end
go
---
create procedure PR_unavailable(
@worker_id int,
@time datetime
)
as
begin
select * from Travels
where Worker_id=@worker_id and Exit_date_time=@time
end


exec PR_addTravel @Line_id=88,@Worker_id=1,@Exit_date_time=25
exec PR_addTravel @Line_id=2,@Worker_id=1,@Exit_date_time='2025-02-27 20:00:00.000'

select * from Travels
--מיספור נסיעות לכל עובד
select *, ROW_NUMBER()over(partition by Worker_id order by Exit_date_time) as numberOfWorker
from Travels


---
alter procedure pr_deleteStationAndLine(
@station_id int,
@line_id int
)
as
begin
   begin transaction
   begin try
   delete from Lines
   where Line_id=@line_id
   delete from Stations
   where Station_id=@station_id
   commit
   end try
   begin catch
   rollback
   print
   'error! go to chek!!'
   end catch
   end

   exec pr_deleteStationAndLine @station_id=5,@line_id=5






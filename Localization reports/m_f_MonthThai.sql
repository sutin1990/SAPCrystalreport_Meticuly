SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select name, type from sysobjects where name like 'm_f_MonthThai' and type = 'FN')
begin
	drop function m_f_MonthThai
end
go
create FUNCTION m_f_MonthThai
(
	@period int
)
RETURNS nvarchar(30)
AS
BEGIN
--select dbo.m_f_MonthThai(201807)
declare @year nvarchar(4), @month nvarchar(20) , @dt datetime, @dts nvarchar(10), @PeriodName nvarchar(30)

set @dts = convert(nvarchar(10) , @period) + '01'

if isdate(@dts) = 0
begin
	set @PeriodName = '**Invalid Period [' + convert(varchar(10) , @period) + ']**'
	return @PeriodName
end

select @year = convert(nvarchar(4),  convert(int, left(@dts,4) ) + 543 ), @month = substring(@dts,5,2)


select @month = case @month 
	when '01' then N'มกราคม'
	when '02' then N'กุมภาพันธ์'
	when '03' then N'มีนาคม'
	when '04' then N'เมษายน'
	when '05' then N'พฤษภาคม'
	when '06' then N'มิถุนายน'
	when '07' then N'กรกฏาคม'
	when '08' then N'สิงหาคม'
	when '09' then N'กันยายน'
	when '10' then N'ตุลาคม'
	when '11' then N'พฤศจิกายน'
	when '12' then N'ธันวาคม'
	else 'Invalid Month'
	end

set @PeriodName =@month + ' ' + @year  
return @PeriodName 

END
GO



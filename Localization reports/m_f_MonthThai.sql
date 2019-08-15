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
	when '01' then N'���Ҥ�'
	when '02' then N'����Ҿѹ��'
	when '03' then N'�չҤ�'
	when '04' then N'����¹'
	when '05' then N'����Ҥ�'
	when '06' then N'�Զع�¹'
	when '07' then N'�á�Ҥ�'
	when '08' then N'�ԧ�Ҥ�'
	when '09' then N'�ѹ��¹'
	when '10' then N'���Ҥ�'
	when '11' then N'��Ȩԡ�¹'
	when '12' then N'�ѹ�Ҥ�'
	else 'Invalid Month'
	end

set @PeriodName =@month + ' ' + @year  
return @PeriodName 

END
GO



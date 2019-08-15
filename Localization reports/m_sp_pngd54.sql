if exists (select name from sysobjects where name like 'm_sp_pngd54' and type = 'P')
begin
	drop procedure m_sp_pngd54
end
go

create procedure m_sp_PNGD54 (@DocNum int) as
set nocount on
declare @msg nvarchar(255)
/*
exec m_sp_pngd54 611090423
exec m_sp_pngd54 611090424
exec m_sp_pngd54 611090441


*/
--select * from OVPM where docentry = 995

--select * from vpm6 where wtcode like 'W5%'

--select * from OVPM where docnum = 611090439  
if not exists (select pmt.DocNum from ovpm pmt inner join vpm6 pmtwt on pmt.DocEntry = pmtwt.DocNum  where pmt.DocNum = @DocNum)
begin
	set @msg = 'Document Number ['+convert(varchar(15), @docnum ) + '] does not exists in WT 54 File' 
	goto exit_proc
end
declare @company_name nvarchar(80), @branch_name nvarchar(80), @branch_code nvarchar(5), @brach_taxID nvarchar(15), 
	@U_M_BUILD_NAME nvarchar(80),
	@U_M_ROOM_NO nvarchar(80),
	@U_M_FLOOR_NO nvarchar(80),
	@U_M_VILLAGE_NAME nvarchar(80),
	@U_M_ADD_NO nvarchar(80),
	@U_M_MOO_NO nvarchar(80),
	@U_M_SOI nvarchar(80),
	@U_M_STREET_NAME nvarchar(80),
	@U_M_TAMBON nvarchar(80),
	@U_M_AMPHUR nvarchar(80),
	@U_M_PROVINCE nvarchar(80),
	@U_M_POSTAL_CODE nvarchar(80)

select @company_name = CompnyName from oadm
set @branch_code = '00000'
if not exists(select name from [dbo].[@M_BRANCH] where code = @branch_code) 
begin
	raiserror('Invalid branch no %s',16,4, @branch_code)
	return
end
select @branch_name = name , @brach_taxID = [U_M_Branch_TaxId], 
	@U_M_BUILD_NAME = isnull([U_M_BUILD_NAME],'') ,
	@U_M_ROOM_NO = isnull([U_M_ROOM_NO],''),
	@U_M_FLOOR_NO = isnull([U_M_FLOOR_NO],''),
	@U_M_VILLAGE_NAME = isnull([U_M_VILLAGE_NAME],''),
	@U_M_ADD_NO = isnull([U_M_ADD_NO],''),
	@U_M_MOO_NO = isnull([U_M_MOO_NO],''),
	@U_M_SOI = isnull([U_M_SOI],''),
	@U_M_STREET_NAME = isnull([U_M_STREET_NAME],''),
	@U_M_TAMBON = isnull([U_M_TAMBON],''),
	@U_M_AMPHUR = isnull([U_M_AMPHUR],''),
	@U_M_PROVINCE = isnull([U_M_PROVINCE],''), 
	@U_M_POSTAL_CODE = isnull([U_M_POSTAL_CODE],'') 
from [@M_BRANCH] where  code = @branch_code


select
@company_name CompanyName, 
@branch_code branch_code,
@branch_name branch_name, 
@brach_taxID brach_taxID, 
@U_M_BUILD_NAME U_M_BUILD_NAME, 
@U_M_ROOM_NO U_M_ROOM_NO, 
@U_M_FLOOR_NO U_M_FLOOR_NO, 
@U_M_VILLAGE_NAME U_M_VILLAGE_NAME, 
@U_M_ADD_NO U_M_ADD_NO, 
@U_M_MOO_NO U_M_MOO_NO, 
@U_M_SOI U_M_SOI, 
@U_M_STREET_NAME U_M_STREET_NAME, 
@U_M_TAMBON U_M_TAMBON, 
@U_M_AMPHUR U_M_AMPHUR,  
@U_M_PROVINCE U_M_PROVINCE, 
@U_M_POSTAL_CODE U_M_POSTAL_CODE,
case wt.WTCode when 'W512' then '2' else '1' end  TaxSettleType,
inv.streetB, convert(nvarchar(80), inv.BuildingB) BuildingB, inv.StateB, inv.CountryB,
pmt.DocNum, pmt.TaxDate, pmt.Comments, wt.WTCode, wt.WTName, convert(int,wt.Rate)as Rate, sum(pmtwt.TaxbleAmnt) TaxableAmt, sum(pmtwt.wtsum) WTAmt, sum(pmtwt.TaxbleAmnt + pmtwt.wtsum) Total
from ovpm pmt
	inner join VPM2 pmtd on pmt.DocEntry = pmtd.DocNum
	inner join PCH12 inv on pmtd.docentry = inv.docentry
	inner join vpm6 pmtwt on pmtd.docnum = pmtwt.docnum and pmtd.InvoiceId = pmtwt.InvoiceId
	inner join OWHT wt on pmtwt.WTCode = wt.WTCode
where pmtwt.WTCode like 'W5%'
and pmt.DocNum = @DocNum
group by inv.streetB, convert(nvarchar(80), inv.BuildingB), inv.StateB, inv.CountryB, pmt.DocNum, pmt.TaxDate, pmt.Comments, wt.WTCode, wt.WTName, wt.Rate

exit_proc:
if @msg <> ''
begin
	raiserror(@msg,16,4)
end
return


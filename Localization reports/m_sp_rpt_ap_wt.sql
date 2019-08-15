if exists (select name from sysobjects where name like 'm_sp_rpt_ap_wt' and type = 'P')
begin
	drop procedure m_sp_rpt_ap_wt
end
go

create procedure m_sp_rpt_ap_wt (@Period int, @TypWTReprt nvarchar(5) ) as

set nocount on
-- exec m_sp_rpt_ap_wt 201811, 'C'
declare @start_date datetime, @end_date datetime, @Branch_NO varchar(6), @period_name nvarchar(30)
set @Branch_NO = '00000'
set @start_date = left(convert(varchar(6), @Period) ,4) + '-' + right(convert(varchar(6), @Period) ,2) + '-1'
set @end_date = dateadd(SECOND, -1,  dateadd(month, 1,  @start_date ))

set @period_name = dbo.m_f_MonthThai(@Period)

declare @company_name nvarchar(80), @branch_name nvarchar(80), @brach_taxID nvarchar(15), @branch_taxAddress nvarchar(255), @vat_name nvarchar(20)

select @company_name = CompnyName from oadm

if not exists(select name from [dbo].[@M_BRANCH] where code = @Branch_NO) 
begin
	raiserror('Invalid branch no %s',16,4, @Branch_NO)
	return
end
if @TypWTReprt not in ('C','P')
begin
	raiserror('Please select only P (personal) or C (Company)',16,4 )
	return
end

select @branch_name = name , @brach_taxID = [U_M_Branch_TaxId], @branch_taxAddress = 
isnull([U_M_BUILD_NAME],'') + ' ' + isnull([U_M_ROOM_NO],'')+ ' '+ isnull([U_M_FLOOR_NO],'')+ ' '+ isnull([U_M_VILLAGE_NAME],'')+ ' '+ isnull([U_M_ADD_NO],'')+ ' '+ isnull([U_M_MOO_NO],'')+ ' '+ isnull([U_M_SOI],'')
+ ' '+ isnull([U_M_STREET_NAME],'')+ ' '+ isnull([U_M_TAMBON],'')+ ' '+ isnull([U_M_AMPHUR],'')+ ' '+ isnull([U_M_PROVINCE],'')+ ' '+ isnull([U_M_POSTAL_CODE],'') 

from [@M_BRANCH] where  code = @Branch_NO


select 
	@Branch_NO BrancNumber,
	@branch_name BranchAddress,
	@brach_taxID BrachtaxID,
	@period_name PeriodName,
	pmt.docnum PaymentNumber ,
	pmt.CardCode VenCode,
	VouAddress.GlbLocNumB VenTaxID,
	VouAddress.StreetB VenName,
	case cus.TypWTReprt when 'C' then VouAddress.BlockB else '00000' end VenBranch,
	isnull(convert(nvarchar(50),VouAddress.BuildingB),NULL) VenBuildingAndFloor,
	VouAddress.Address2B VenHouseNo,
	VouAddress.StreetNoB VenStreetName,
	VouAddress.Address3B VenTAMBON,
	VouAddress.CityB VenAMPHUR,
	t8.Name VenPROVINCE,
	VouAddress.ZipCodeB VenZipCode,
	pmt.TaxDate PaymentDate,
	pmt.U_M_WTDocNo WTDocNo,
	wt.WTCode WTCode,
	wt.WTName WTName,
	wt.Rate WTRate,
	sum(pmtwt.TaxbleAmnt) ServiceAmt,
	sum(pmtwt.WTSum) WTAmt
FROM  [dbo].[OVPM] pmt
	INNER JOIN VPM2 pmtdet on pmt.DocEntry = pmtdet.DocNum
	INNER JOIN PCH12 VouAddress on pmtdet.DocEntry = VouAddress.DocEntry
	INNER  JOIN [dbo].[VPM6] pmtwt  ON  pmtdet.DocNum  = pmtwt.[DocNum] and pmtdet.InvoiceId = pmtwt.InvoiceId
	INNER  JOIN [dbo].[OWHT] wt  ON  pmtwt.[WTCode] = wt.[WTCode]
	INNER  JOIN [dbo].[OCRD] cus  ON  cus.[CardCode] = pmt.[CardCode] 
	LEFT JOIN [dbo].[OCST] T8 on VouAddress.StateB = T8.Code
where 
	pmt.Canceled = 'N'
	and wt.wtcode not like 'W5%'
	and pmt.TaxDate between @start_date and @end_date
	and cus.TypWTReprt = @TypWTReprt
group by 
	pmt.docnum ,
	pmt.CardCode ,
	VouAddress.GlbLocNumB ,
	VouAddress.StreetB ,
	cus.TypWTReprt , VouAddress.BlockB ,
	isnull(convert(nvarchar(50),VouAddress.BuildingB),NULL),
	VouAddress.Address2B ,
	VouAddress.StreetNoB ,
	VouAddress.Address3B ,
	VouAddress.CityB ,
	t8.Name ,
	VouAddress.ZipCodeB ,
	pmt.TaxDate ,
	pmt.U_M_WTDocNo ,
	wt.WTCode ,
	wt.WTName ,
	wt.Rate 
	order by pmt.DocNum
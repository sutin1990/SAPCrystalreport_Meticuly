/****** Object:  StoredProcedure [dbo].[m_sp_rpt_ap_vat]    Script Date: 12/11/61 14:04:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[m_sp_rpt_ap_vat] (@Branch_NO nvarchar(10), @Period int, @vatgroup nvarchar(5) ) as

set nocount on
-- exec m_sp_rpt_ap_vat '00000', 201808, 'VP7'
declare @start_date datetime, @end_date datetime, @period_Name nvarchar(30)

select @period_Name = dbo.m_f_MonthThai(@Period)

set @start_date = left(convert(varchar(6), @Period) ,4) + '-' + right(convert(varchar(6), @Period) ,2) + '-1'
set @end_date = dateadd(SECOND, -1,  dateadd(month, 1,  @start_date ))

if isnumeric(@Branch_NO) = 1
begin
	set @branch_no = right('00000'+@Branch_NO,5)
end

declare @company_name nvarchar(80), @branch_name nvarchar(80), @brach_taxID nvarchar(15), @branch_taxAddress nvarchar(255), @vat_name nvarchar(20)

select @company_name = CompnyName from oadm

if not exists(select name from [dbo].[@M_BRANCH] where code = @Branch_NO) 
begin
	raiserror('Invalid branch no %s',16,4, @Branch_NO)
	return
end

if @vatgroup = null
begin
	set @vatgroup = 'VS7'
end

if not exists (select  name from OVTG where code = @vatgroup and Category = 'I')
begin
	raiserror('Invalid tax no %s catagory: Input VAT',16,4, @vatgroup)
	return
end
select  @vat_name = name from OVTG where code = @vatgroup

select @branch_name = name , @brach_taxID = [U_M_Branch_TaxId], @branch_taxAddress = 
isnull([U_M_BUILD_NAME],'') + ' ' + isnull([U_M_ROOM_NO],'')+ ' '+ isnull([U_M_FLOOR_NO],'')+ ' '+ isnull([U_M_VILLAGE_NAME],'')+ ' '+ isnull([U_M_ADD_NO],'')+ ' '+ isnull([U_M_MOO_NO],'')+ ' '+ isnull([U_M_SOI],'')
+ ' '+ isnull([U_M_STREET_NAME],'')+ ' '+ isnull([U_M_TAMBON],'')+ ' '+ isnull([U_M_AMPHUR],'')+ ' '+ isnull([U_M_PROVINCE],'')+ ' '+ isnull([U_M_POSTAL_CODE],'') 

from [@M_BRANCH] where  code = @Branch_NO
--select @start_date, @end_date


create table #output (
	Branch_NO nvarchar(15) not null,
	doc_source nvarchar(5) null,
	doc_number int null,
	ven_code nvarchar(15) null,
	ven_name nvarchar(100) null,
	ven_taxID nvarchar(15) null, --เลขประจำตัวผู้เสียภาษีผู้ขาย
	inv_taxNumber nvarchar(25) null, --เลขที่ใบกำกับภาษี
	 
	inv_branchID nvarchar(15) null, --รหัสสาขาของผู้ขาย
	inv_vatCode nvarchar(3) null,
	inv_vatRate decimal(16,4) null,
	inv_taxDate datetime null,
	inv_goods_amt money null,
	inv_tax_amt money null, 
	inv_total_amt money null,
	inv_JE_TransId int,
)

insert #output (Branch_NO, doc_source, 
inv_taxDate, doc_number, inv_taxNumber, ven_code, ven_name, ven_taxID, inv_branchID,  
inv_vatCode, inv_vatRate, inv_goods_amt, inv_tax_amt, inv_total_amt, inv_JE_TransId)

/* AP Invoice and Reserve Invoice */
select 
	case when len(U_M_Branch_No) = 0 then '00000' else isnull(U_M_Branch_No, '00000') end  BranchCode, 'PU' doc_source,
	TaxDate inv_tax_date, DocNum doc_number,  NumAtCard inv_taxNumber, a.cardcode ven_code, d.streetb ven_name, d.GlbLocNumB ven_taxID, left(d.BlockB,13)  inv_branchID, 
	vatgroup inv_vatCode, VatPrcnt inv_vatRate, base_amt - a.DiscSum - DpmAmnt inv_goods_amt, vat_amt - DpmVat inv_tax_amt, base_amt- a.DiscSum - DpmAmnt + vat_amt - DpmVat inv_total_amt, a.TransId
from OPCH a 
	inner join CRD1 c on a.CardCode = c.CardCode and a.PayToCode = c.[Address] and c.AdresType = 'B'
	inner join PCH12 d on a.docentry = d.docentry
	inner join (select DocEntry DocEntry, vatgroup, VatPrcnt, sum(totalsumsy) base_amt, sum(vatsum) vat_amt from pch1 --where vatgroup = 'VP7' -- @vatgroup		
					group by  DocEntry, vatgroup, VatPrcnt ) b on a.DocEntry = b.DocEntry
where 
	a.canceled = 'N' and
	case when len(U_M_Branch_No) = 0 then '00000' else isnull(U_M_Branch_No, '00000') end  = @Branch_NO and docdate between @start_date and @end_date and vatgroup = @vatgroup
/* Credit Memo */
union
select 
	case when len(U_M_Branch_No) = 0 then '00000' else isnull(U_M_Branch_No, '00000') end  BranchCode, 'PC' doc_source,
	TaxDate inv_tax_date, DocNum doc_number,  NumAtCard inv_taxNumber, a.cardcode ven_code, d.streetb ven_name, d.GlbLocNumB ven_taxID, left(d.BlockB,13)  inv_branchID, 
	vatgroup inv_vatCode, VatPrcnt inv_vatRate, (base_amt- a.DiscSum) * -1 inv_goods_amt, -vat_amt inv_tax_amt, (base_amt - a.DiscSum + vat_amt) *-1 inv_total_amt, a.TransId
from orpc a 
	inner join CRD1 c on a.CardCode = c.CardCode and a.PayToCode = c.[Address] and c.AdresType = 'B'
	inner join RPC12 d on a.docentry = d.docentry
	inner join (select DocEntry DocEntry, vatgroup, VatPrcnt, sum(totalsumsy) base_amt, sum(vatsum) vat_amt from RPC1 --where vatgroup = 'VP7' -- @vatgroup		
					group by  DocEntry, vatgroup, VatPrcnt ) b on a.DocEntry = b.DocEntry
where 
	a.canceled = 'N' and
	case when len(U_M_Branch_No) = 0 then '00000' else isnull(U_M_Branch_No, '00000') end  = @Branch_NO and docdate between @start_date and @end_date and vatgroup = @vatgroup
/* AP Down Payment*/
union
select 
	case when len(U_M_Branch_No) = 0 then '00000' else isnull(U_M_Branch_No, '00000') end  BranchCode, 'DT' doc_source,
	TaxDate inv_tax_date, DocNum doc_number,  NumAtCard inv_taxNumber, a.cardcode ven_code, d.streetb ven_name, d.GlbLocNumB ven_taxID, left(d.BlockB,13)  inv_branchID, 
	vatgroup inv_vatCode, VatPrcnt inv_vatRate, dpmAmnt inv_goods_amt, vat_amt inv_tax_amt, dpmAmnt + vat_amt inv_total_amt, a.TransId
from ODPO a 
	inner join CRD1 c on a.CardCode = c.CardCode and a.PayToCode = c.[Address] and c.AdresType = 'B'
	inner join DPO12 d on a.docentry = d.docentry
	inner join (select DocEntry DocEntry, vatgroup, VatPrcnt, sum(totalsumsy) base_amt, sum(vatsum) vat_amt from DPO1 --where vatgroup = 'VP7' -- @vatgroup		
					group by  DocEntry, vatgroup, VatPrcnt ) b on a.DocEntry = b.DocEntry
where 
	a.canceled = 'N' and
	case when len(U_M_Branch_No) = 0 then '00000' else isnull(U_M_Branch_No, '00000') end  = @Branch_NO and docdate between @start_date and @end_date and vatgroup = @vatgroup
/* Journal Entry*/
union
select
	 case when len(U_M_TaxCoBranch) = 0 then '00000' else isnull(U_M_TaxCoBranch, '00000') end  BranchCode, 'JE' doc_source,
	T0.TaxDate inv_tax_date, T0.Number doc_number,  T0.U_M_TaxInvNo inv_taxNumber, T0.U_M_TaxAPCode ven_code, T2.CardName ven_name, T2.LicTradNum ven_taxID, T0.U_M_TaxAPBranch inv_branchID, 
	T1.VatGroup inv_vatCode, T1.vatrate inv_vatRate, case when (t1.Debit - T1.Credit) > 0 then T1.BaseSum else -t1.BaseSum end inv_goods_amt, (t1.Debit - T1.Credit) inv_tax_amt, case when (t1.Debit - T1.Credit) > 0 then T1.BaseSum else -t1.BaseSum end  + (t1.Debit - T1.Credit) inv_total_amt, t0.TransId
from OJDT  T0
	inner join jdt1 T1 on T0.transid = T1.transid and t0.TransType  = 30 /* JE only */
	left join ocrd T2 on T0.U_M_TaxAPCode = T2.cardcode 
	inner join ovtg T3 on T1.VatGroup = T3.code
where  case when len(U_M_TaxCoBranch) = 0 then '00000' else isnull(U_M_TaxCoBranch, '00000') end  = @Branch_NO and T0.RefDate between @start_date and @end_date and T1.VatGroup = @vatgroup

select @company_name company_name, @branch_name Branch_name, @period_Name Period_Name, @brach_taxID brach_taxID, @branch_taxAddress branch_taxAddress, @vat_name vat_name,
Branch_NO, doc_source, doc_number, ven_code, ven_name, ven_taxID, inv_taxNumber, inv_branchID, inv_vatCode, inv_vatRate, inv_taxDate , inv_goods_amt, inv_tax_amt, inv_total_amt, 
format(inv_taxDate, 'd MMM yyyy', 'th') inv_taxDate_s, a.inv_JE_TransId
from #output a 
  order by a.inv_taxDate , a.doc_source,  a.doc_number
drop table #output
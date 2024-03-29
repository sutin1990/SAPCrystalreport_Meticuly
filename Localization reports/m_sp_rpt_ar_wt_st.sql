USE [IMED_201810-09]
GO
/****** Object:  StoredProcedure [dbo].[m_sp_rpt_ar_wt_st]    Script Date: 11/1/2018 10:13:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[m_sp_rpt_ar_wt_st] (@Years int,@Month int  ) as
set nocount on
-- exec m_sp_rpt_ar_wt_st 2018,10 
declare @start_date datetime, @end_date datetime, @Branch_NO varchar(6), @period_name nvarchar(30)
set @Branch_NO = '00000'
--set @start_date = left(convert(varchar(6), @Period) ,4) + '-' + right(convert(varchar(6), @Period) ,2) + '-1'
set @start_date = convert(varchar(6), @Years) + '-' + convert(varchar(6), @Month)  + '-1'
set @end_date = dateadd(SECOND, -1,  dateadd(month, 1,  @start_date ))

--set @period_name = dbo.m_f_MonthThai(@Period)
--set @period_name = dbo.m_f_MonthThai(convert(varchar(6),@Years)+convert(varchar(2),@Month))

declare @company_name nvarchar(80), @branch_name nvarchar(80), @brach_taxID nvarchar(15), @branch_taxAddress nvarchar(255), @vat_name nvarchar(20)

select @company_name = CompnyName from oadm

if not exists(select name from [dbo].[@M_BRANCH] where code = @Branch_NO) 
begin
	raiserror('Invalid branch no %s',16,4, @Branch_NO)
	return
end

select @branch_name = name , @brach_taxID = [U_M_Branch_TaxId], @branch_taxAddress = 
isnull([U_M_BUILD_NAME],'') + ' ' + isnull([U_M_ROOM_NO],'')+ ' '+ isnull([U_M_FLOOR_NO],'')+ ' '+ isnull([U_M_VILLAGE_NAME],'')+ ' '+ isnull([U_M_ADD_NO],'')+ ' '+ isnull([U_M_MOO_NO],'')+ ' '+ isnull([U_M_SOI],'')
+ ' '+ isnull([U_M_STREET_NAME],'')+ ' '+ isnull([U_M_TAMBON],'')+ ' '+ isnull([U_M_AMPHUR],'')+ ' '+ isnull([U_M_PROVINCE],'')+ ' '+ isnull([U_M_POSTAL_CODE],'') 

from [@M_BRANCH] where  code = @Branch_NO

select format(@start_date,'MMMM yyyy', 'th') Period, 
rct.DocEntry, rct.DocNum PaymentNo , format(rct.DocDate,'ddMMyyyy', 'th') DocDate, rct.U_M_WTDocNo CertificatNo,   rct.CardCode, rct.CardName, cus.glbllocnum VendorTaxID, inv.NumAtCard InvoiceNo, wt.WTCode, wt.WTName, rctwt.TaxbleAmnt, rctwt.WTSum ,  rctwt.TaxbleAmnt + rctwt.WTSum Total
from 	orct rct 
	inner join crd1 cus on rct.CardCode = cus.CardCode and rct.PayToCode = cus.[Address]
	inner join rct2 rctdet on rct.docentry = rctdet.docnum 
	inner join oinv inv on rctdet.baseabs = inv.DocEntry
	inner join rct6 rctwt on rctdet.docnum = rctwt.DocNum and rctdet.InvoiceID = rctwt.invoiceID
	inner join OWHT wt  ON  wt.[WTCode] = rctwt.WTCode
where rct.DocDate between @start_date and @end_date
/*
select * from rct6 where duedate >= '2018-10-1'
select -- format(@start_date,'MMMM yyyy', 'th') Period, 
rct.DocEntry, rct.DocNum PaymentNo , rct.DocDate, rct.U_M_WTDocNo CertificatNo,   rct.CardCode, rct.CardName, cus.glbllocnum VendorTaxID, inv.NumAtCard InvoiceNo, wt.WTCode, wt.WTName, rctwt.TaxbleAmnt, rctwt.WTSum ,  rctwt.TaxbleAmnt + rctwt.WTSum Total
from 	orct rct 
	inner join crd1 cus on rct.CardCode = cus.CardCode and rct.PayToCode = cus.[Address]
	inner join rct2 rctdet on rct.docentry = rctdet.docnum 
	inner join rct6 rctwt on rct.docentry = rctwt.DocNum and rctdet.DocLine = rctwt.invoiceID
	inner join oinv inv on rctdet.docentry = inv.DocEntry 

	inner join OWHT wt  ON  rctwt.WTCode = wt.[WTCode]
where rct.DocDate between '2018-10-1' and '2018-10-31'
*/

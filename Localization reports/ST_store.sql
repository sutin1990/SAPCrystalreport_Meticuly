USE [IMED_201810-09]
GO
/****** Object:  StoredProcedure [dbo].[m_sp_rpt_ap_wt]    Script Date: 10/25/2018 8:35:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[m_sp_rpt_ap_wt] (@Years int,@Month int, @TypWTReprt nvarchar(5) ) as

set nocount on
-- exec m_sp_rpt_ap_wt 2018,10,'P'
declare @start_date datetime, @end_date datetime, @Branch_NO varchar(6), @period_name nvarchar(30)
set @Branch_NO = '00000'
--set @start_date = left(convert(varchar(6), @Period) ,4) + '-' + right(convert(varchar(6), @Period) ,2) + '-1'
set @start_date = convert(varchar(6),@Years) + '-' + convert(varchar(6),@Month) + '-1'
set @end_date = dateadd(SECOND, -1,  dateadd(month, 1,  @start_date ))

--set @period_name = dbo.m_f_MonthThai(@Period)
set @period_name = dbo.m_f_MonthThai(convert(varchar(6),@Years)+convert(varchar(6),@Month))

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
@company_name CompanyName,
@Branch_NO BrancNumber,
@branch_name BranchAddress,
@brach_taxID BrachtaxID,
@period_name PeriodName,
 CONVERT(int, format( t0.taxdate, 'yyyyMM'))  YearMonth,
t0.docnum PaymentNumber ,
t0.CardCode CustomerCode,
t7.glbllocnum CustomerTaxID,
t7.street CustomerName,
case TypWTReprt when 'C' then t7.[Address] else '00000' end CustomerBranch,
t7.building CusBuilding,
t8.Name CusState,
t7.ZipCode CusZipCode,
t0.TaxDate PaymentDate,
t0.U_M_WTDocNo WTDocNo,
t1.WTCode WTCode,
t5.WTName WTName,
t5.Rate WTRate,
t1.TaxbleAmnt ServiceAmt,
t1.WTSum WTAmt
FROM  [dbo].[OVPM] T0  
INNER  JOIN [dbo].[VPM6] T1  ON  T1.[DocNum] = T0.[DocEntry]  
INNER  JOIN [dbo].[OWHT] T5  ON  T5.[WTCode] = T1.[WTCode]   
INNER  JOIN [dbo].[OCRD] T6  ON  T6.[CardCode] = T0.[CardCode] 
LEFT JOIN  [dbo].[CRD1] T7 on T0.[CardCode] = T7.[CardCode] and T0.[PayToCode] = T7.[Address]
LEFT JOIN [dbo].[OCST] T8 on T7.State = T8.Code
where 
t6.TypWTReprt = @TypWTReprt
and t0.TaxDate between @start_date and @end_date
and t0.Canceled = 'N'

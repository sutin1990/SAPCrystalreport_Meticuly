USE [IMED_201810-09]
GO
/****** Object:  StoredProcedure [dbo].[m_sp_rpt_ap_wt_file_st]    Script Date: 10/30/2018 4:31:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[m_sp_rpt_ap_wt_file_st] (@Years int,@Month int, @TypWTReprt nvarchar(5) )  as
set nocount on
-- exec m_sp_rpt_ap_wt_file_st 2018,08,'C'
declare @Period int,@val varchar(6)
set @val = convert(varchar(4),@Years)+convert(varchar(2),format(convert(datetime,@Month)-1,'dd'))

set @Period = CONVERT(int,@val)

create table #t (
	BrancNumber	nvarchar(	6	)	,
	BranchAddress	nvarchar(	200	)	,
	BrachtaxID	nvarchar(	13	)	,
	PeriodName	nvarchar(	80	)	,
	PaymentNumber	Int			,
	VendorCode	nvarchar(	15	)	,
	VendorTaxID	nvarchar(	15	)	,
	VendorName	nvarchar(	200	)	,
	VendorBranch	nvarchar(	80	)	,
	VendorBuilding	nvarchar(	100	)	,
	VendorState	nvarchar(	80	)	,
	VendorZipCode	nvarchar(	20	)	,
	PaymentDate	datetime			,
	WTDocNo	nvarchar(	20	)	,
	WTCode	nvarchar(	8	)	,
	WTName	nvarchar(	100	)	,
	WTRate	decimal(	16,4	)	,
	ServiceAmt	money		,	
	WTAmt	money			
)
insert #t
exec m_sp_rpt_ap_wt @Period, @TypWTReprt

create table #output (
line int not null identity(1,1),
Data nvarchar(2000)
)

declare @SENDER_NID nvarchar(13), @TaxType nvarchar(8), @TAX_MONTH nvarchar(2), @Tax_Year nvarchar(4), @TOT_NUM nvarchar(7), @TOT_AMT nvarchar(15), @TOT_TAX nvarchar(15), @GTOT_TAX nvarchar(15), @USER_ID nvarchar(20)

insert #output (data)
select isnull(VendorTaxID,'') +'|'
+isnull(VendorBranch,'')+'|'
+isnull(VendorName,'')+'|'
+isnull(VendorBuilding,'')+'|'
+isnull(VendorState,'')+'|'
+isnull(VendorZipCode,'')+'|'
+format(PaymentDate,'dd/MM/yyyy','th') +'|'
+isnull(WTCode,'')+'|'
+format(isnull(WTRate,0), '##0.00')+'|'
+format(isnull(ServiceAmt,0), '##0.00')+'|'
+format(isnull(WTAmt,0), '##0.00')+'|'
+'1'
from #t
--select 'H|0000|'+@SENDER_NID+'|000000|1|'+@TaxType+'|'+@SENDER_NID+'|000000|สำนักงานใหญ๋|1|1|1|0|'+@TAX_MONTH+'|'+@Tax_Year+'|V|00|'+@TOT_NUM+'|'+@TOT_AMT+'|'+@TOT_TAX+'|0.00|'+@GTOT_TAX+'|0.00|'+@USER_ID+'|1'
--select * from #output
select convert(varchar(10),LIne) + '|' + data data from #output
drop table #t
drop table #output
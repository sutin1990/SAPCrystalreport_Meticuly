USE [SAP_MET_testcost]
GO
/****** Object:  StoredProcedure [dbo].[m_sp_rpt_Production_Detail_LoadMaster]    Script Date: 8/8/2019 11:57:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[m_sp_rpt_Production_Detail_LoadMaster]
	--@DocKey@ INT
AS
--m_sp_rpt_Production_Detail_LoadMaster 
------------------------------------------
select * from [dbo].[@MFC_ROUTEINSPECT]
--where U_AbsEntry = 3
 --where U_DocEntry = @DocKey@ --and U_StgEntry = @Ustgentry


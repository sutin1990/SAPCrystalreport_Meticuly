USE [SAP_MET_testcost]
GO
/****** Object:  StoredProcedure [dbo].[m_sp_rpt_Production_Detail]    Script Date: 8/6/2019 10:37:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[m_sp_rpt_Production_Detail]
	--@DocKey@ INT
AS
--m_sp_rpt_Production_Detail 117
------------------------------------------
select * from [dbo].[@M_INSPECT_RESULT] --where U_DocEntry = @DocKey@ --and U_StgEntry = @Ustgentry


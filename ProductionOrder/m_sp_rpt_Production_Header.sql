USE [SAP_MET_testcost]
GO
/****** Object:  StoredProcedure [dbo].[m_sp_rpt_Production_Header]    Script Date: 8/7/2019 10:58:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[m_sp_rpt_Production_Header]
	@DocKey@ INT
AS
--m_sp_rpt_Production_Header 117
------------------------------------------

 select I.IWeight1,I.IWght1Unit,I.ItemName,W.* from OWOR W
 inner join OITM I on W.ItemCode = I.ItemCode and I.ItmsGrpCod = W.DocEntry
  where W.DocEntry = @DocKey@


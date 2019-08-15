USE [SAP_MET_testcost]
GO
/****** Object:  StoredProcedure [dbo].[m_sp_rpt_Production_Resource]    Script Date: 8/6/2019 11:54:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[m_sp_rpt_Production_Resource]
@DocKey@ INT
AS
--m_sp_rpt_Production_Resource 117
------------------------------------------
select  w4.StgEntry, w1.* from WOR1 w1
inner join WOR4 w4 on w1.StageId = w4.StageId and w4.DocEntry = @DocKey@
where  w1.DocEntry = @DocKey@ and w1.ItemType = 290
order by w1.LineNum



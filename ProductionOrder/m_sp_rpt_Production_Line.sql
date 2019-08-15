USE [SAP_MET_testcost]
GO
/****** Object:  StoredProcedure [dbo].[m_sp_rpt_Production_Line]    Script Date: 8/7/2019 10:45:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[m_sp_rpt_Production_Line]
	@DocKey@ INT
AS
--m_sp_rpt_Production_Line 117
------------------------------------------

-- select * from OWOR where DocEntry = @DocKey@
 select st.Code,st.[Desc],st.U_WorkingArea,w4.* from WOR4 w4
inner join ORST st on w4.StgEntry = st.AbsEntry
where w4.DocEntry = @DocKey@



-- =============================================
-- Author:		Rafał Kubowicz
-- =============================================
CREATE PROCEDURE [dbo].[uspCheckSession] 
	-- Add the parameters for the stored procedure here
	@ses_id as nvarchar(200),
	@session_time as int,
	--@login as nvarchar(50),
	@status as nvarchar(50) output
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @active1 as int; 
    -- Insert statements for procedure here

	set @active1 = (select count(*) from tblSessions where ID_SES = @ses_id and  Active = 1 and lastupdate > = DATEADD(s,-@session_time,getdate()) 
	)
		
	--jezeli aktywna sesja to update czasu trwania
				
				--	insert into logs values ('session time: ' + convert(nvarchar(50),@session_time))
				--	insert into logs values ('session id: ' + @ses_id)
				--	insert into logs values ('@active: ' + convert(nvarchar(1),@active1))
						

	If @active1 >= 1 
				
		begin
		update tblSessions set LastUpdate = getdate() where ID_SES = @ses_id and Active = 1 
		select @status = 'exist'
		end
			
	else

	-- jezli sesja juz nie jest aktywna to wyzeruj wszystkie sesje usera
	begin 
	--update tblSessions set Active = 0 where login = @login
	select @status = 'not_exist'
	end

		
END

GO
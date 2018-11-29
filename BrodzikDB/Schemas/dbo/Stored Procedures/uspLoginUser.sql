-- =============================================
-- Author:		Rafał Kubowicz
-- =============================================
CREATE PROCEDURE [dbo].[uspLoginUser] 
	-- Add the parameters for the stored procedure here
	@login as nvarchar(50),
	@pass_hash as nvarchar(500),
	@ses_id as nvarchar(200),
	@session_time as int
	
AS
BEGIN
	
	declare @max_bad_pass as int;
	set @max_bad_pass = 5;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @saved_pass_hash as nvarchar(500); 
	declare @isActive as bit;


	SELECT @saved_pass_hash = PasswordHash from tblUser where LoginName = @login ;
	SELECT @isActive = IsActive from tblUser where LoginName = @login ;
	
	
	If @pass_hash = @saved_pass_hash and @isActive = 1

			begin
					--Weryfikacja czy sesja juz istnieje

					declare @userId as integer
					SELECT @userId = userID from tblUser where LoginName = @login

				

					declare @return_status as nvarchar(100)
					execute  [dbo].[uspCheckSession] 
					   @ses_id
					  ,@session_time
					  --,@login
					  ,@status = @return_status output
					
					
					if @return_status = 'exist' 
					begin
					select 'exist' as answer
					insert into log.tblApplicationEventLog values (getdate(),'Zalogwanie z sukcesem - Sesja już istaniała',null,@userId)
					end

					else
					begin
						insert into [dbo].[tblSessions] values (@ses_id,@login,getdate(),getdate(),1)
						select 'ok' as answer
						--update main_users set bad_login_count = 0 where Login = @login
						--insert into [dbo].[log_login_to_system] values (getdate(),@login,1)
						insert into log.tblApplicationEventLog values (getdate(),'Zalogwanie z sukcesem',null,@userId)
					end

							
			end
			
	else
	
	begin 
		
		if @isActive = 0 
			begin
				insert into log.tblApplicationEventLog values (getdate(),'BŁĄD LOGOWANIA - Konto nie aktywne',@login,1)
			end
			else
			begin
				insert into log.tblApplicationEventLog values (getdate(),'BŁĄD LOGOWANIA',@login,1)
			end

	
		select 'not' as answer
	end
	
END
GO
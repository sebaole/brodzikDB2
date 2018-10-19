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

	SELECT @saved_pass_hash = PasswordHash from tblUser where LoginName = @login ;
	
	
	If @pass_hash = @saved_pass_hash 

			begin
					--Weryfikacja czy sesja juz istnieje

					declare @return_status as nvarchar(100)
					execute  [dbo].[uspCheckSession] 
					   @ses_id
					  ,@session_time
					  --,@login
					  ,@status = @return_status output
					
					
					if @return_status = 'exist' 
					begin
					select 'exist' as answer
					end

					else
					begin
						insert into [dbo].[tblSessions] values (@ses_id,@login,getdate(),getdate(),1)
						select 'ok' as answer
						--update main_users set bad_login_count = 0 where Login = @login
						--insert into [dbo].[log_login_to_system] values (getdate(),@login,1)

					end

							
			end
			
	else
	begin 

	-- zwiekszenie licznika blednych prób 
	--update main_users set bad_login_count = bad_login_count + 1 where Login = @login

	--insert into [dbo].[log_login_to_system] values (getdate(),@login,0)

	select 'not' as answer
	--
	-- zablokowanie jeżeli przekroczona wartość licznika
		--declare @curr_bad_pass as integer;
		--SELECT @curr_bad_pass = bad_login_count from main_users  where login =  @login ;
			
			--If @curr_bad_pass = @max_bad_pass 
			--begin
			--update main_users set fl_aktywny = 0 where Login = @login
			--end
			---

	end
	
END

GO
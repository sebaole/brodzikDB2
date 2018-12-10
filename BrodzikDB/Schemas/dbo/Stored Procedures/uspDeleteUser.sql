CREATE PROCEDURE [dbo].[uspDeleteUser]
(
	 @LoginName		NCHAR(9)
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue			SMALLINT = 0
		,@UserID				INT
		,@DeletedOrderStatusID	TINYINT
	
	SET @UserID = (SELECT UserID FROM dbo.tblUser WHERE LoginName = @LoginName AND LoginName <> 'XXXXXXXXX')
	SET @DeletedOrderStatusID = (SELECT OrderStatusID FROM dict.tblOrderStatus WHERE StatusCode = 'DELETED')

	BEGIN TRY
		/* some extra validations here */
		IF @UserID IS NULL
			BEGIN
				RAISERROR(N'Podany Login nie istnieje', 16, 1)
			END

		IF EXISTS	(
					SELECT 1
					FROM dbo.tblOrder O
					INNER JOIN dbo.vwOrderLatestStatus LS
						ON O.OrderID = LS.OrderID
					WHERE 
						O.UserID = @UserID
						AND LS.StatusCode IN (N'INPROGRESS', N'INDELIVERY')
					)
			BEGIN
				RAISERROR(N'Nie można usunąć konta gdy Twoje zamówienie jest realizowane', 16, 1)
			END
		
		BEGIN TRAN
					
			/* target sql statements here */
			UPDATE dbo.tblUser
			SET 
				[LoginName]		= 'XXXXXXXXX'
				,[PhoneNumber]	= 'XXXXXXXXX'
				,[Email]		= 'XXXXXXXXX'		
				,[FirstName]	= 'XXXXXXXXX'
				,[LastName]		= 'XXXXXXXXX'
				,[CompanyName]	= 'XXXXXXXXX'
				,[NIP]			= 'XXXXXXXXX'
				,[IsActive]		= 0
			WHERE UserID = @UserID

			UPDATE dbo.tblAddress
			SET
				 [Street]					= 'XXXXXXXXX'
				,[NumberLine1]				= 'XXXXXXXXX'
				,[NumberLine2]				= 'XXXXXXXXX'
				,[City]						= 'XXXXXXXXX'
				,[State]					= 'XXXXXXXXX'
				,[ZipCode]					= 'XX-XXX'
				,[ContactPersonFirstName]	= 'XXXXXXXXX'
				,[ContactPersonLastName]	= 'XXXXXXXXX'
				,[ContactPhoneNumber]		= 'XXXXXXXXX'
			WHERE UserID = @UserID

			INSERT INTO dbo.tblOrderHistory
			(
				 [OrderID]
				,[OrderStatusID]
			)
			SELECT 
				O.OrderID
				,[OrderStatusID] = @DeletedOrderStatusID
			FROM dbo.tblOrder O
			INNER JOIN dbo.vwOrderLatestStatus LS
				ON O.OrderID = LS.OrderID
			WHERE 
				O.UserID = @UserID
				AND LS.StatusCode IN (N'NEW')

		COMMIT

	END TRY
	BEGIN CATCH

		SET @ReturnValue = -1

		IF @@TRANCOUNT > 0 ROLLBACK TRAN
  
		/* raise an error */
		;THROW

	END CATCH

RETURN @ReturnValue

END
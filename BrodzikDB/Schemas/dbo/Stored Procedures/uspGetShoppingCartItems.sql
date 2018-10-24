CREATE PROCEDURE [dbo].[uspGetShoppingCartItems]
(
	 @LoginName	NCHAR(9)
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue	SMALLINT = 0
		,@UserID		INT

	SET @UserID = (SELECT UserID FROM dbo.tblUser WHERE LoginName = @LoginName)

	BEGIN TRY

		/* some extra validations here */
		
		BEGIN TRAN
					
			/* target sql statements here */
			;WITH CTE AS
			(
			SELECT
				 SC.ProductID
				,SC.Quantity
				,P.ProductName
				,[UnitPrice] = IIF(U.IsBusinessClient = 1, P.UnitWholesalePrice, P.UnitRetailPrice)
				,V.VATRate
			FROM dbo.tblShoppingCart SC
			INNER JOIN dbo.tblProduct P
				ON SC.ProductID = P.ProductID
			INNER JOIN dbo.tblUser U
				ON SC.UserID = U.UserID
			INNER JOIN dict.tblVATRate V
				ON P.VATID = V.VATID
			WHERE	
				SC.UserID = @UserID
				AND SC.DateExpired >= GETDATE()
			)

			SELECT
				 ProductID
				,ProductName
				,Quantity
				,UnitPrice
				,VATRate
				,[GrossPrice] = VATRate * [UnitPrice]
			FROM CTE 

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

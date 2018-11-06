CREATE PROCEDURE [dbo].[uspGetShoppingCartItems]
(
	  @LoginName		NCHAR(9)
	 ,@DeliveryDate		DATETIME = NULL
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
				,[UnitPrice] = IIF(U.IsWholesalePriceActive = 1, P.UnitWholesalePrice, P.UnitRetailPrice)
				,V.VATRate
				,SC.DeliveryDate
				,PC.CategoryName
			FROM dbo.tblShoppingCart SC
			INNER JOIN dbo.tblProduct P
				ON SC.ProductID = P.ProductID
				AND P.IsActive = 1 -- return only available products
			INNER JOIN dict.tblProductCategory PC
				ON P.CategoryID = PC.CategoryID
			INNER JOIN dbo.tblUser U
				ON SC.UserID = U.UserID
			INNER JOIN dict.tblVATRate V
				ON P.VATID = V.VATID
			WHERE	
				SC.UserID = @UserID
				AND SC.DateExpired >= GETDATE()
				AND (SC.DeliveryDate = @DeliveryDate OR @DeliveryDate IS NULL)
			)

			SELECT
				 ProductID
				,ProductName
				,Quantity
				,UnitPrice
				,VATRate
				,[GrossPrice] = ROUND((VATRate * [UnitPrice]) + [UnitPrice], 2)
				,DeliveryDate
				,CategoryName
			FROM CTE 
			WHERE Quantity > 0 -- safe check

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

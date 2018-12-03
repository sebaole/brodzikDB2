CREATE PROCEDURE [dbo].[uspGetShoppingCartSummary]
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
			SELECT 
				[ItemsCount] = COUNT(*)
				,[TotalValue] = SUM(
									SC.Quantity * 

										IIF(U.IsKDR = 1 AND PC.IsKDRActive = 1,

												ROUND	(
														IIF(U.IsWholesalePriceActive = 1, P.UnitWholesalePrice, P.UnitRetailPrice) * (1 + V.VATRate)
														,2
														) - [KDRGrossDiscount],
									
												ROUND	(
														IIF(U.IsWholesalePriceActive = 1, P.UnitWholesalePrice, P.UnitRetailPrice) * (1 + V.VATRate)
														,2
														)
											)

									)
									

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

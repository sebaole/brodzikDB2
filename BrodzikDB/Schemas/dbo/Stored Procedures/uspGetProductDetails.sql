CREATE PROCEDURE [dbo].[uspGetProductDetails]
(
	@ProductID	INT
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue	SMALLINT = 0

	BEGIN TRY

		/* some extra validations here */
		IF NOT EXISTS (SELECT 1 FROM dbo.tblProduct WHERE ProductID = @ProductID)
			BEGIN
				RAISERROR ('ProductID %i does not exist', 16, 1, @ProductID)
			END
		
		BEGIN TRAN

			SELECT 
				P.ProductID
				,PC.CategoryName
				,P.CategoryID
				,P.Ingredients
				,P.LongDescription
				,P.UnitRetailPrice
				,P.UnitWholesalePrice
				,V.VATRate
			FROM dbo.tblProduct P
			INNER JOIN dict.tblProductCategory PC
				ON P.CategoryID = PC.CategoryID
			INNER JOIN dict.tblVATRate V
				ON P.VATID = V.VATID
			WHERE P.ProductID = @ProductID
		
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
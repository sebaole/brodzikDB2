CREATE PROCEDURE [dbo].[uspGetProducts]
(
	 @CategoryName	NVARCHAR(64) = NULL
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue	SMALLINT = 0

	BEGIN TRY

		/* some extra validations here */
		
		BEGIN TRAN
					
			/* target sql statements here */
			SELECT
				P.ProductID		
				,PC.CategoryName	
				,P.[ProductName]			
				,P.[ShortDescription]		
				,P.[LongDescription]		
				,P.[Ingredients]			
				,P.[Weight]				
				,P.[UnitOfWeight]			
				,P.[UnitRetailPrice]		
				,P.[UnitWholesalePrice]	
				,V.VATRate			
				,P.[IsMonday]				
				,P.[IsTuesday]			
				,P.[IsWednesday]			
				,P.[IsThursday]			
				,P.[IsFriday]				
				,P.[IsSaturday]			
				,P.[IsSunday]				
			FROM dbo.tblProduct P
			INNER JOIN dict.tblProductCategory PC
				ON P.CategoryID = PC.CategoryID
			INNER JOIN dict.tblVATRate V
				ON P.VATID = V.VATID
			WHERE (PC.CategoryName = @CategoryName OR @CategoryName IS NULL)
				AND P.IsActive = 1
		
		COMMIT

	END TRY
	BEGIN CATCH

		SET @ReturnValue = -1

		IF @@TRANCOUNT > 0 ROLLBACK TRAN
  
		/* raise an error */
		DECLARE
			 @ErrorMessage	NVARCHAR(4000)
			,@ErrorSeverity	INT
			,@ErrorState	INT

		SET @ErrorMessage	= ERROR_MESSAGE()
		SET @ErrorSeverity	= ERROR_SEVERITY()
		SET @ErrorState		= ERROR_STATE()

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)

	END CATCH

RETURN @ReturnValue

END

CREATE PROCEDURE [dbo].[uspGetProducts]
(
	 @CategoryName		NVARCHAR(64) = NULL
	,@IncludeInactive	BIT = 1
	,@LoginName			NCHAR(9) = NULL
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
			;WITH CTE_Cart AS
			(
			SELECT
				ProductID
				--,DeliveryDate
				,[QuantityInCart] = SUM(Quantity)
			FROM dbo.tblShoppingCart
			WHERE 
				UserID = @UserID
				AND DateExpired >= GETDATE()
			GROUP BY ProductID
			)

			SELECT
				P.ProductID		
				,PC.CategoryName	
				,P.[ProductName]			
				,P.[ShortDescription]		
				,P.[LongDescription]		
				,P.[Ingredients]			
				,P.[Weight]				
				,[UnitOfWeight] = LOWER(P.[UnitOfWeight])			
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
				,[QuantityInCart] = ISNULL(SC.QuantityInCart, 0)
			FROM dbo.tblProduct P
			INNER JOIN dict.tblProductCategory PC
				ON P.CategoryID = PC.CategoryID
			INNER JOIN dict.tblVATRate V
				ON P.VATID = V.VATID
			LEFT JOIN CTE_Cart SC
				ON P.ProductID = SC.ProductID
			WHERE (PC.CategoryName = @CategoryName OR @CategoryName IS NULL)
				AND (P.IsActive = 1 OR P.IsActive = ~(@IncludeInactive))
		
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

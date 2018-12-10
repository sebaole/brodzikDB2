CREATE PROCEDURE [dbo].[uspGetProducts]
(
	 @CategoryName		NVARCHAR(64) = NULL
	,@IncludeInactive	BIT = 1
	,@LoginName			NCHAR(9) = NULL
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
		IF NOT EXISTS (SELECT 1 FROM dict.tblProductCategory WHERE CategoryName = @CategoryName) AND @CategoryName IS NOT NULL
			BEGIN
				RAISERROR('CategoryName %s nie istnieje', 16, 1, @CategoryName)
			END

		IF NOT EXISTS (SELECT 1 FROM dbo.tblUser WHERE LoginName = @LoginName) AND @LoginName IS NOT NULL
			BEGIN
				RAISERROR('Login %s nie istnieje', 16, 1, @LoginName)
			END

		IF TRY_CAST(@DeliveryDate AS DATE) IS NULL AND @DeliveryDate IS NOT NULL
			BEGIN
				RAISERROR ('Coś nie tak z datą dostawy', 16, 1)
			END

		BEGIN TRAN
					
			/* target sql statements here */
			;WITH CTE_Cart AS
			(
			SELECT
				ProductID
				,[QuantityInCart] = SUM(Quantity)
			FROM dbo.tblShoppingCart
			WHERE 
				UserID = @UserID
				AND DateExpired >= GETDATE()
				AND (DeliveryDate = @DeliveryDate OR @DeliveryDate IS NULL)
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

CREATE PROCEDURE [dbo].[uspAddProduct]
(
	 @CategoryName			NVARCHAR(64)
	,@ProductName			NVARCHAR(128) 
	,@ShortDescription		NVARCHAR(64) = NULL
	,@LongDescription		NVARCHAR(256) = NULL
	,@Ingredients			NVARCHAR(256) 
	,@Weight				DECIMAL(10,2) 
	,@UnitOfWeight			NVARCHAR(8) 
	,@UnitRetailPrice		MONEY
	,@UnitWholesalePrice	MONEY
	,@VATRate				DECIMAL(5,4)
	,@IsMonday				BIT 
	,@IsTuesday				BIT 
	,@IsWednesday			BIT 
	,@IsThursday			BIT 
	,@IsFriday				BIT 
	,@IsSaturday			BIT 
	,@IsSunday				BIT
	,@ProductID				INT OUTPUT
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue	SMALLINT = 0
		,@CategoryID	SMALLINT
		,@VATID			TINYINT

	BEGIN TRY

		/* some extra validations here */
		SET @CategoryID	= (SELECT CategoryID FROM dict.tblProductCategory WHERE CategoryName = @CategoryName)
		SET @VATID	= (SELECT VATID FROM dict.tblVATRate WHERE VATRate = @VATRate)

		IF @CategoryID IS NULL
			BEGIN
				RAISERROR ('Incorrect value for @CategoryName = %s', 16, 1, @CategoryName)
			END

		IF @VATID IS NULL
			BEGIN
				RAISERROR ('Incorrect VATRate', 16, 1)
				--RAISERROR ('Incorrect value for @VATRate = %f', 16, 1, @VATRate)
			END
		
		BEGIN TRAN
					
			/* target sql statements here */
			INSERT INTO dbo.tblProduct
			(
				 [CategoryID]			
				,[ProductName]			
				,[ShortDescription]		
				,[LongDescription]		
				,[Ingredients]			
				,[Weight]				
				,[UnitOfWeight]			
				,[UnitRetailPrice]		
				,[UnitWholesalePrice]	
				,[VATID]				
				,[IsMonday]				
				,[IsTuesday]			
				,[IsWednesday]			
				,[IsThursday]			
				,[IsFriday]				
				,[IsSaturday]			
				,[IsSunday]				
			)
			VALUES
			(
				 @CategoryID			
				,@ProductName			
				,@ShortDescription		
				,@LongDescription		
				,@Ingredients			
				,@Weight				
				,@UnitOfWeight			
				,@UnitRetailPrice		
				,@UnitWholesalePrice	
				,@VATID				
				,@IsMonday				
				,@IsTuesday			
				,@IsWednesday			
				,@IsThursday			
				,@IsFriday				
				,@IsSaturday			
				,@IsSunday				
			)

			SET @ProductID = SCOPE_IDENTITY()
		
		COMMIT

	END TRY
	BEGIN CATCH

		SET @ProductID = NULL
		SET @ReturnValue = -1

		IF @@TRANCOUNT > 0 ROLLBACK TRAN
  
		/* raise an error */
		;THROW

	END CATCH

RETURN @ReturnValue

END
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
	,@IsActive				BIT = 1
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
				RAISERROR ('Nieprawidłowa wartość dla parametru @CategoryName = %s', 16, 1, @CategoryName)
			END

		IF @VATID IS NULL
			BEGIN
				RAISERROR ('Nieprawidłowa wartość dla parametru @VATRate', 16, 1)
				--RAISERROR ('Incorrect value for @VATRate = %f', 16, 1, @VATRate)
			END
		
		BEGIN TRAN
			/* target sql statements here */

			IF @ProductID IS NULL
				BEGIN
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
						,[IsActive]
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
						,@IsActive
					)

					SET @ProductID = SCOPE_IDENTITY()
				END
			ELSE
				BEGIN
					UPDATE dbo.tblProduct
					SET
						 [CategoryID] =  @CategoryID
						,[ProductName] = @ProductName
						,[ShortDescription] = @ShortDescription
						,[LongDescription] = @LongDescription
						,[Ingredients] = @Ingredients
						,[Weight] = @Weight
						,[UnitOfWeight] = @UnitOfWeight
						,[UnitRetailPrice] = @UnitRetailPrice
						,[UnitWholesalePrice] = @UnitWholesalePrice
						,[VATID] = @VATID
						,[IsMonday] = @IsMonday
						,[IsTuesday] = @IsTuesday
						,[IsWednesday] = @IsWednesday
						,[IsThursday] = @IsThursday
						,[IsFriday] = @IsFriday
						,[IsSaturday] = @IsSaturday
						,[IsSunday] = @IsSunday
						,[IsActive] = @IsActive
					WHERE ProductID = @ProductID
				END
		
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
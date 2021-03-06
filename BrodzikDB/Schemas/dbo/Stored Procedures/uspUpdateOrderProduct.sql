﻿CREATE PROCEDURE [dbo].[uspUpdateOrderProduct]
(
	 @OrderID					INT
	,@ProductID					INT
	,@Quantity					TINYINT = NULL
	,@GrossPriceWithDiscount	MONEY = NULL
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue	SMALLINT = 0

	BEGIN TRY

		/* some extra validations here */
		IF @Quantity IS NULL AND @GrossPriceWithDiscount IS NULL
			BEGIN
				RAISERROR ('Musisz podać przynajmniej 1 parametr do zaktualizowania', 16, 1)
			END

		IF @Quantity < 0 OR @GrossPriceWithDiscount < 0
			BEGIN
				RAISERROR ('Podane wartości są nielogiczne', 16, 1)
			END

		IF @Quantity = 0 AND (SELECT COUNT([ProductID]) FROM dbo.tblOrderItem WHERE OrderID = @OrderID) = 1
			BEGIN
				RAISERROR ('Nie możesz usunąć wszystkich produktów z zamówienia', 16, 1)
			END
	
		BEGIN TRAN
					
			/* target sql statements here */
			
			IF @Quantity = 0
				BEGIN
					DELETE
					FROM dbo.tblOrderItem 
					WHERE 
						OrderID = @OrderID 
						AND ProductID = @ProductID
				END
			ELSE
				BEGIN
					UPDATE dbo.tblOrderItem 
					SET
						Quantity = ISNULL(@Quantity, Quantity)
						,GrossPriceWithDiscount = ISNULL(@GrossPriceWithDiscount, GrossPriceWithDiscount)
					WHERE 
						OrderID = @OrderID 
						AND ProductID = @ProductID
				END
	
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
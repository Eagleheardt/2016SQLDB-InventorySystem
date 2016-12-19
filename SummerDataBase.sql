/*
USE master
DROP DATABASE dbJagMarket
*/


CREATE DATABASE dbJagMarket
GO

USE dbJagMarket
GO

--Create tables
PRINT 'Tables Being Created ...'
GO

CREATE TABLE tblUser
(
 UserID INT IDENTITY (160000,1) PRIMARY KEY,
 UserName NVARCHAR (30) NOT NULL,
 BillStreetNum NVARCHAR (7) NOT NULL,
 BillStreetName NVARCHAR(30) NOT NULL,
 BillStreetName2 NVARCHAR(30),
 BillCity NVARCHAR (25) NOT NULL,
 BillSt CHAR (2) NOT NULL,
 BillZIP CHAR (5) NOT NULL,
 ShipToStreetNum NVARCHAR (7) NOT NULL,
 ShipToStreetName NVARCHAR(30) NOT NULL,
 ShipToStreetName2 NVARCHAR(30),
 ShipToCity NVARCHAR (25) NOT NULL,
 ShipToSt CHAR (2) NOT NULL,
 ShipToZIP CHAR (5) NOT NULL,
 CreditLimit SMALLMONEY NOT NULL 
 --about 200k in credit is enough for one person
 )
 GO

 CREATE TABLE tblProductCategories
 (
 CategoryID INT IDENTITY (1,1) PRIMARY KEY,
 Name NVARCHAR (15)
 )

CREATE TABLE tblProduct
(
 ProductID INT IDENTITY(20160000,1) PRIMARY KEY,
 CategoryID INT FOREIGN KEY REFERENCES tblProductCategories(CategoryID),
 ProductName NVARCHAR(20) NOT NULL,
 ShortDesc NVARCHAR(20) NOT NULL,
 LongDesc NVARCHAR (200) NOT NULL,
 OnHand INT, OnOrder INT, 
 WholesalePrice SMALLMONEY NOT NULL,

 )
 GO

 CREATE TABLE tblInvoice
 (
 InvoiceID INT IDENTITY (20160000,1) PRIMARY KEY,
 UserID INT FOREIGN KEY REFERENCES tblUser(UserID),
 ProcessDate DATE NOT NULL,
 ShipDate DATE NOT NULL,
 Salesman NVARCHAR (7) NOT NULL,
 TotlCost SMALLMONEY NOT NULL,
 Terms NVARCHAR (255)
 )
 GO

 CREATE TABLE tblLineItem
 (
 InvoiceID INT FOREIGN KEY REFERENCES tblInvoice(InvoiceID),
 ProductID INT FOREIGN KEY REFERENCES tblProduct(ProductID),
 Amount INT NOT NULL,
 Cost SMALLMONEY NOT NULL
 )
 GO

--Echo a print statement that confirms result.
PRINT 'Tables successfully constructed...'
GO

CREATE PROCEDURE sp_FixInvoiceDate (@InvoiceID INT)
AS
BEGIN
UPDATE tblInvoice
SET ProcessDate = convert(varchar, getdate(), 101), 
ShipDate = DATEADD (DAY,3 , convert(varchar, getdate(), 101))
WHERE InvoiceID = @InvoiceID
END
GO

CREATE PROCEDURE sp_UpdateCost (@InvoiceID INT)
AS
BEGIN
BEGIN TRY 
UPDATE tblInvoice 
SET TotlCost = (SELECT SUM (Cost) FROM tblLineItem WHERE tblLineItem.InvoiceID = @InvoiceID) 
--Sets the total cost on the invoice to the total cost of all items on our junction table
--that match the invoice ID+
WHERE InvoiceID = @InvoiceID
END TRY
BEGIN CATCH
UPDATE tblInvoice 
SET TotlCost = 0
END CATCH
EXEC sp_FixInvoiceDate @InvoiceID
END
GO

PRINT 'Making Stored Procs...'
PRINT 'tblUser Methods'
GO

CREATE PROCEDURE sp_AddMyUser(@UserName NVARCHAR (30), @BillStreetNum NVARCHAR (7),
							@BillStreetName NVARCHAR(30), @BillStreetName2 NVARCHAR(30),
							@BillCity NVARCHAR (25), @BillSt CHAR (2), @BillZIP CHAR (5),
							@ShipToStreetNum NVARCHAR (7), @ShipToStreetName NVARCHAR(30),
							@ShipToStreetName2 NVARCHAR(30), @ShipToCity NVARCHAR (25),
							@ShipToSt CHAR (2), @ShipToZIP CHAR (5), @CreditLimit SMALLMONEY)
AS
BEGIN
INSERT INTO tblUser (UserName, BillStreetNum,
					BillStreetName, BillStreetName2,
					BillCity, BillSt, BillZIP,
					ShipToStreetNum, ShipToStreetName,
					ShipToStreetName2, ShipToCity,
					ShipToSt, ShipToZIP, CreditLimit)

VALUES (@UserName, @BillStreetNum,
		@BillStreetName, @BillStreetName2,
		@BillCity, @BillSt, @BillZIP,
		@ShipToStreetNum, @ShipToStreetName,
		@ShipToStreetName2, @ShipToCity,
		@ShipToSt, @ShipToZIP, @CreditLimit)
END
GO

CREATE PROCEDURE sp_EditUser(@UserID INT, @UserName NVARCHAR (30), @BillStreetNum NVARCHAR (7),
							@BillStreetName NVARCHAR(30), @BillStreetName2 NVARCHAR(30),
							@BillCity NVARCHAR (25), @BillSt CHAR (2), @BillZIP CHAR (5),
							@ShipToStreetNum NVARCHAR (7), @ShipToStreetName NVARCHAR(30),
							@ShipToStreetName2 NVARCHAR(30), @ShipToCity NVARCHAR (25),
							@ShipToSt CHAR (2), @ShipToZIP CHAR (5), @CreditLimit SMALLMONEY)
AS
BEGIN
UPDATE tblUser 

SET UserName = @UserName, BillStreetNum = @BillStreetNum,
	BillStreetName = @BillStreetName, BillStreetName2 = @BillStreetName2,
	BillCity = @BillCity, BillSt = @BillSt, BillZIP = @BillZIP,
	ShipToStreetNum = @ShipToStreetNum, @ShipToStreetName = @BillStreetName,
	ShipToStreetName2 = @ShipToStreetName2, ShipToCity = @ShipToCity,
	ShipToSt = @ShipToSt, ShipToZIP = @ShipToZIP, CreditLimit = @CreditLimit

WHERE UserID = @UserID
END
GO

CREATE PROCEDURE sp_DelUser (@UserID INT)
AS
BEGIN
DELETE FROM tblUser
WHERE UserID = @UserID
END
GO

CREATE PROCEDURE sp_GetUserInvoices (@UserID INT)
AS
BEGIN
SELECT *
FROM tblInvoice
WHERE tblInvoice.UserID = @UserID 
AND TotlCost > 0
END
GO

CREATE PROCEDURE sp_GetAllUsers 
AS
BEGIN
SELECT * FROM tblUser
END
GO

CREATE PROCEDURE sp_GetOneUser (@UserID INT)
AS
BEGIN
SELECT * FROM tblUser
WHERE UserID = @UserID
END
GO

PRINT 'tblProduct Methods'
GO

CREATE PROCEDURE sp_AddProduct(@ProductName NVARCHAR(20), @ShortDesc NVARCHAR(20),
								@LongDesc NVARCHAR (200), @WholesalePrice SMALLMONEY,
								@CategoryID INT)

AS
BEGIN
INSERT INTO tblProduct (ProductName, ShortDesc, LongDesc, WholesalePrice, CategoryID)
VALUES (@ProductName, @ShortDesc, @LongDesc, @WholesalePrice, @CategoryID)
END
GO

CREATE PROCEDURE sp_EditProduct (@ProductID INT, @ProductName NVARCHAR(20),
								@ShortDesc NVARCHAR(20),@LongDesc NVARCHAR (200), 
								@WholesalePrice SMALLMONEY, @CategoryID INT)
AS
BEGIN
UPDATE tblProduct

SET ProductName = @ProductName, ShortDesc = @ShortDesc,
	LongDesc = @LongDesc, WholesalePrice = @WholesalePrice,
	CategoryID = @CategoryID

WHERE ProductID = @ProductID
END
GO

CREATE PROCEDURE sp_DelProduct (@ProductID INT)
AS
BEGIN
DELETE FROM tblProduct
WHERE ProductID = @ProductID
END
GO

CREATE PROCEDURE sp_GetAllProducts 
AS
BEGIN
SELECT * FROM tblProduct
END
GO

CREATE PROCEDURE sp_GetOneProduct (@ProductID INT)
AS
BEGIN
SELECT * FROM tblProduct
WHERE ProductID = @ProductID 
END
GO

CREATE PROCEDURE sp_AddToItem (@itemID INT, @amount INT)
AS
BEGIN
UPDATE tblProduct
SET OnHand = OnHand + @amount
WHERE ProductID = @itemID 
END
GO
--adds quantity of items in stock

CREATE PROCEDURE sp_PlaceOrder (@itemID INT, @amount INT)
AS
BEGIN
UPDATE tblProduct
SET  OnOrder = OnOrder + @amount
WHERE ProductID = @itemID 
END
GO

PRINT 'tblInvoice Methods'
GO

CREATE PROCEDURE sp_MakeInvoice (@UserID INT)
AS
BEGIN
INSERT INTO tblInvoice (UserID, ProcessDate, ShipDate, Salesman, TotlCost, Terms)
VALUES (@UserID, convert(varchar, getdate(), 101), 
DATEADD (DAY,3 , convert(varchar, getdate(), 101)), 'WebSite', 0, 'None yet')
END
GO

CREATE PROCEDURE sp_GetTheInvoice (@InvoiceID INT)
AS
BEGIN
SELECT *
FROM tblInvoice
WHERE InvoiceID = @InvoiceID
END
GO

CREATE PROCEDURE sp_EditInvoice (@InvoiceID INT, @Terms NVARCHAR(255))
AS
BEGIN
UPDATE tblInvoice
SET Terms = @Terms
WHERE InvoiceID = @InvoiceID
EXEC sp_FixInvoiceDate @InvoiceID
END
GO

CREATE PROCEDURE sp_DelInvoice (@InvoiceID INT)
AS
BEGIN
DELETE FROM tblInvoice
WHERE InvoiceID = @InvoiceID
END
GO

CREATE PROCEDURE sp_GetAllInvoices
AS
BEGIN
SELECT * FROM tblInvoice 
END
GO

CREATE PROCEDURE sp_GetOneInvoice (@InvoiceID INT)
AS
BEGIN
SELECT tblProduct.ProductName AS ProductName, tblProduct.ProductID AS SKUNum,
tblProduct.ShortDesc AS ShortDesc, tblLineItem.Amount AS ItemAmount,
tblProduct.WholesalePrice AS UnitPrice, tblLineItem.Cost AS LineCost,
tblInvoice.TotlCost AS GrandTotal, tblInvoice.ProcessDate AS Processed,
tblInvoice.ShipDate AS Shipped, tblInvoice.Terms AS Terms,
tblInvoice.InvoiceID AS ID, tblInvoice.Salesman AS Seller,
tblUser.UserName AS UserName
FROM tblLineItem, tblProduct, tblInvoice, tblUser, tblProductCategories
WHERE tblLineItem.InvoiceID = @InvoiceID AND 
tblInvoice.InvoiceID = @InvoiceID AND 
tblLineItem.ProductID = tblProduct.ProductID AND
tblUser.UserID = tblInvoice.UserID AND
tblProduct.CategoryID = tblProductCategories.CategoryID
ORDER BY tblProductCategories.CategoryID ASC, SKUNum ASC
END
GO

PRINT 'Line Item methods'
GO

CREATE PROCEDURE sp_EditLineItem (@InvoiceID INT, @ProductID INT, @Amount INT)
AS
BEGIN
UPDATE tblLineItem 
SET Amount = @Amount, 
	Cost = ((SELECT WholesalePrice FROM tblProduct WHERE ProductID = @ProductID) * @Amount)

WHERE InvoiceID = @InvoiceID AND ProductID = @ProductID
--Sets the total cost of the line automatically
--gets the cost of the item and multiplies it by the amount
EXEC sp_UpdateCost @InvoiceID
END
GO

CREATE PROCEDURE sp_GetLineItem (@InvoiceID INT, @ProductID INT)
AS
BEGIN
SELECT *
FROM tblLineItem
WHERE InvoiceID = @InvoiceID AND ProductID = @ProductID
END
GO

CREATE PROCEDURE sp_DelLineItem (@InvoiceID INT, @ProductID INT)
AS
BEGIN
DELETE FROM tblLineItem
WHERE InvoiceID = @InvoiceID AND ProductID = @ProductID
EXEC sp_UpdateCost @InvoiceID
END
GO

CREATE PROCEDURE sp_AddLineItem (@InvoiceID INT, @ProductID INT, @Amount INT)
AS
BEGIN
IF EXISTS (SELECT * FROM tblLineItem WHERE InvoiceID = @InvoiceID AND ProductID = @ProductID)
BEGIN
DECLARE @localAmt INT
SET @localAmt = (SELECT Amount FROM tblLineItem WHERE InvoiceID = @InvoiceID AND ProductID = @ProductID)
DECLARE @localFinalAmt INT
SET @localFinalAmt = (@Amount + @localAmt)
IF (@localFinalAmt <= 0)
BEGIN
EXEC sp_DelLineItem @InvoiceID, @ProductID
RETURN
END
EXEC sp_EditLineItem @InvoiceID, @ProductID, @localFinalAmt 
END
ELSE
BEGIN
INSERT INTO tblLineItem (InvoiceID, ProductID, Amount, Cost)
VALUES (@InvoiceID, @ProductID, @Amount, 
((SELECT WholesalePrice FROM tblProduct WHERE ProductID = @ProductID) * @Amount))
--Sets the total cost of the line automatically
--gets the cost of the item and multiplies it by the amount
END
EXEC sp_UpdateCost @InvoiceID
END
GO

CREATE PROCEDURE sp_GetMaxUserInvoice (@UserID INT)
AS
BEGIN
SELECT MAX (tblInvoice.InvoiceID) AS LastInvoice
FROM tblInvoice
WHERE tblInvoice.UserID = @UserID
END
GO

CREATE PROCEDURE sp_AddCategory(@Name NVARCHAR (15))
AS
BEGIN
INSERT INTO tblProductCategories (Name) 
VALUES(@Name)
END
GO

CREATE PROCEDURE sp_EditCategory (@CategoryID INT, @Name NVARCHAR(15))
AS
BEGIN
UPDATE tblProductCategories
SET Name = @Name
WHERE CategoryID = @CategoryID
END
GO

CREATE PROCEDURE sp_DelCategory (@CategoryID INT)
AS
BEGIN
DELETE FROM tblProductCategories
WHERE CategoryID = @CategoryID
END
GO

CREATE PROCEDURE sp_GetAllCategories
AS
BEGIN
SELECT * FROM tblProductCategories 
END
GO

CREATE PROCEDURE sp_GetOneCategory (@CategoryID INT)
AS
BEGIN
SELECT * FROM tblProductCategories 
WHERE CategoryID = @CategoryID
END
GO

SET NOCOUNT ON

/*
EXEC sp_AddMyUser '@UserName','@BillStreetNum','@BillStreetName','@BillStreetName2', 
						'@BillCity','@BillSt','@BillZIP','@ShipToStreetNum',
						'@ShipToStreetName','@ShipToStreetName2','@ShipToCity','@ShipToSt',
						'@ShipToZIP', 1000

*/
--Parameter examples

EXEC sp_AddCategory 'Bush'
EXEC sp_AddCategory 'Fungus'
EXEC sp_AddCategory 'Tree'
EXEC sp_AddCategory 'Vine'
EXEC sp_AddCategory 'Flower'
EXEC sp_AddCategory 'Pepper'
EXEC sp_AddCategory 'Fruit'



EXEC sp_AddMyUser 'James 234','12A','Harrison Rd.','','Tyler','TX','12345','12A','Harrison Rd.','','Tyler','TX','12345', 1000
EXEC sp_AddMyUser 'Walter 314','9000','Shady Ln.','','Mackintosh','WA','54687','12A','Harrison Rd.','','Tyler','TX','12345', 1000
EXEC sp_AddMyUser 'Rick','23','Turnin Ln.','','Oahu','HI','12456','12A','Harrison Rd.','','Tyler','TX','12345', 1000
EXEC sp_AddMyUser 'N','1664','Double Tree Ct.','','Banks','CA','32587','12A','Harrison Rd.','','Tyler','TX','12345', 1000
EXEC sp_AddMyUser 'Magsen','E','S West St.','','Sands','FL','54895','12A','Harrison Rd.','','Tyler','TX','12345', 1000


--EXEC sp_AddProduct '@ProductName','@ShortDesc','@LongDesc',1,'@Category'
EXEC sp_AddProduct 'Hydrangea','Blue, French','Inspire serenity within you.',22.50,1
EXEC sp_AddProduct 'Holly','Prickly, Berries','Lovely green bush, with red berries. Watch out though, you will get pricked!',15.33,1
EXEC sp_AddProduct 'Hibiscus','Tall, Pink or Yellow','Flutes of color come off this bush.',55.25,1
EXEC sp_AddProduct 'Elderberry','Fruity, Familiar','Colorful clumps of color can be seen all round this bush.',75,1
EXEC sp_AddProduct 'Bayberry','Cones of Color','Also called "Sweet Gale" this bush has great berries!',85,1
EXEC sp_AddProduct 'Chanterelles','Flute of Yellow','They form symbiotic associations with plants, making them very difficult to cultivate.',99.99,2
EXEC sp_AddProduct 'Morchella','Have ridges','Sought by thousands of enthusiasts every spring for their supreme taste and the thrill of the hunt, and are highly prized by gourmet cooks.',50.50,2
EXEC sp_AddProduct 'Portobello','Large and lovely','Cultivated in more than seventy countries, this is a mature Agaricus bisporus',45.45,2
EXEC sp_AddProduct 'Shiitake','Flavorful and Unique','Brown and delicious',30.32,2
EXEC sp_AddProduct 'Button','Small and cute','This is an immature Agaricus bisporus. Tasty and tiny.',21.78,2
EXEC sp_AddProduct 'Porcini','Fat and Bulbous','Tastes great!',5.54,2
EXEC sp_AddProduct 'Oak Tree','Big, Mighty','Hard and Durable.',12.23,3
EXEC sp_AddProduct 'Magic Tree','Level 75 WC','This tree shimmers with a magical force.',99.99,3
EXEC sp_AddProduct 'Maple Tree','O, Canada','Wonderful Maple Goodness!',50.23,3
EXEC sp_AddProduct 'Dogwood Tree','Not from dogs','Fragrant, lovely.',20.12,3
EXEC sp_AddProduct 'Pine Tree','Tall, Sappy','Long needles, tall lean tree.',10.20,3
EXEC sp_AddProduct 'Willow Tree','Weeping','Sways calmly in the breeze',42.21,3
EXEC sp_AddProduct 'Orange','Sweet and Tangy','Fresh from Florida',10.20,7
EXEC sp_AddProduct 'Lemon','Yellow, Sour','Have a fresh squeezed glass',25.25,7
EXEC sp_AddProduct 'Lime','Green, Sour','Great tree!',25.25,7
EXEC sp_AddProduct 'Apple','Red, Delicious','Crisp and fresh',25.25,7
EXEC sp_AddProduct 'Fig','Newtonian','Lovely figs.',12.12,7
EXEC sp_AddProduct 'Lantana','Verbena','Small flowers of wonder.',13.69,5
EXEC sp_AddProduct 'Rose','Whats my name?','Lovely red roses.',5.50,5
EXEC sp_AddProduct 'Buttercup','Cupped, not butter','Wonderful flowers.',5.52,5
EXEC sp_AddProduct 'Poppy','Dont sleep','Probably no opium.',3.25,5
EXEC sp_AddProduct 'Carnation','Cute and Festive','Perfect for the big dance.',1.50,5
EXEC sp_AddProduct 'Jade','Tropical','Emerald and lovely.',5.63,4
EXEC sp_AddProduct 'Jasmine','Fragrant','Grows out of control.',3.96,4
EXEC sp_AddProduct 'Wisteria','Hanging Grapes','Purple Madness.',2.42,4
EXEC sp_AddProduct 'Ivy','Classic','Green, no flowers, fast growing.',3.13,4
EXEC sp_AddProduct 'Moonvine','Cool, Dewey','White flowers, visible at night, wither in the day.',2.35,4
EXEC sp_AddProduct 'Cayenne','40k SHU','Red, long thin cayenne.',2.25,6
EXEC sp_AddProduct 'Habanero','120K SHU','Orange, Cuban, hot.',1.69,6
EXEC sp_AddProduct 'Red Habanero','550K SHU','Warming up.',5.95,6
EXEC sp_AddProduct 'Ghost Pepper','1.1M SHU','Almost there.',5.95,6
EXEC sp_AddProduct 'Carolina Reaper','2.2M SHU','Hottest Pepper in the World.',5.95,6

/*
EXEC sp_MakeInvoice 160000

EXEC sp_AddLineItem 20160001, 20160011, 5
EXEC sp_AddLineItem 20160001, 20160002, 5
EXEC sp_AddLineItem 20160001, 20160012, 5
EXEC sp_AddLineItem 20160001, 20160013, 5
EXEC sp_AddLineItem 20160001, 20160019, 5
EXEC sp_AddLineItem 20160001, 20160021, 5
EXEC sp_AddLineItem 20160001, 20160001, 5
EXEC sp_AddLineItem 20160001, 20160000, 5

EXEC sp_GetUserInvoices 160000 --UserID
EXEC sp_GetOneInvoice 20160013 --InvoiceID

SELECT * FROM tblLineItem
SELECT * FROM tblInvoice

*/


SET NOCOUNT OFF

PRINT 'All data inserted successfully!'
GO
/*
USE master
DROP DATABASE dbJagMarket
*/

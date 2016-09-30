CREATE TABLE active_password_resets (
     ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
     MobilePhoneNumber VARCHAR(20) NOT NULL,
     Status INT NOT NULL,
     CreationTime DATETIME NOT NULL,
     LastStepTime DATETIME NOT NULL,
     UserName VARCHAR(15) NOT NULL
)
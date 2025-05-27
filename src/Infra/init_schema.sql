-- Create 'AppUsers' table if it does not exist
IF NOT EXISTS (
    SELECT * FROM sys.tables WHERE name = 'AppUsers' AND type = 'U'
)
BEGIN
    CREATE TABLE AppUsers (
        id INT IDENTITY(1,1) PRIMARY KEY,
        username NVARCHAR(100) NOT NULL,
        email NVARCHAR(255) NOT NULL UNIQUE,
        password NVARCHAR(255) NOT NULL,
        createdAt DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
        updatedAt DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
    );
END

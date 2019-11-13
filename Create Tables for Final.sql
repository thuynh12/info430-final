-- Drop tables if need to
Drop Table Countries
Drop Table Regions
Drop Table Entries
Go 

Create Table Regions (
    Region_ID int identity primary key not null,
    RegionName nvarchar(100)
)
Go

Create Table Countries (
    Country_ID int identity primary key not null,
    Region_ID int not null,
    ISO_Code nvarchar(5),
    CountryName nvarchar(100),
    Foreign key (Region_ID) references Regions(Region_ID)
)
Go

Create Table Entries (
    Entry_ID int identity primary key not null,
    Country_ID int,
    EntryYear datetime,
	hf_score float,
    hf_rank float,
    hf_quartile float,
    pf_score float,
    ef_score float, 
    ef_legal_military float,
    pf_expression float,
    pf_religion float,
    Foreign Key (Country_ID) references Countries(Country_ID)
)
Go

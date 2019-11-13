-- Insert all regions into Regions table
Insert Into Regions (RegionName)
Select Distinct region
From [human-freedom-index]
Go

Select * From Regions
Go 


-- Insert all countries into Countries table
Insert Into Countries (Region_ID, ISO_Code, CountryName)
Select Distinct Region_ID, ISO_code, countries
From [human-freedom-index] As h
Inner Join Regions As r
On r.RegionName = h.region
Go

Select * From Countries
Go


-- Insert all entries/freedoms into Entries table
Insert Into Entries (Country_ID, EntryYear, hf_score, hf_rank, hf_quartile, pf_score, ef_score, ef_legal_military, pf_expression, pf_religion)
Select Country_ID, Cast([year] As date), Cast(hf_score As float), Cast(hf_rank As float), Cast(hf_quartile As float), Cast(pf_score As float),
	 Cast(ef_score As float), Cast(ef_legal_military As float), Cast(pf_expression As float), Cast(pf_religion As float)
From [human-freedom-index] As h
Inner Join Countries As c
On c.CountryName = h.countries
Go 

Select * From Entries
Go


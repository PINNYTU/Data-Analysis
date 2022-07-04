## Use Case
In the 5 years since The Mosaic Council started, this nonprofit has made impressive strides in its mission to help create a better world. Mosaic values the adage that charity begins at home and focuses on doing work for its local community. To serve its overall mission, Mosaic also partners with globally focused humanitarian agencies. One of its more successful local programs helps communities interested in establishing fruit and vegetable gardens. In addition to beautifying neighborhoods and building a sense of community, the gardens provide fresh produce to local food banks and shelters.

This is where you come in: You just got a welcome call from Mosaic’s Executive Director, Yasmine Vazquez, about a new venture Mosaic has been asked to lead. Yasmine reached out to you because you’ve worked with Mosaic in the past, helping get its org off the ground, so you schedule some time on your calendar and head down to Mosaic's offices.

You learn that Mosaic has a new project unlike anything its done before, an opportunity too exciting to pass up. Building on previous success with community gardens, Mosaic has been asked to form and manage a seed trust and oversee the distribution of seeds to small farms around the globe. Mosaic will work directly with international agencies, which will be responsible for delivering seeds to farmers that will participate in the program.

In the planning session you spend time discussing the program and Mosaic's goals for it. Mosaic has already piloted the program and accumulated some data that you’ll use to get started. Mosaic has acknowledged that there are several unknowns, which may prevent expanding this project. As you dive in to the project, you're thinking that CRM Analytics can help them gain a better understanding of the data they currently have, which can help them plan for the future. Yasmine is not familiar with CRM Analytics, but after you give her the rundown she’s open to try it.

Key Stakeholders
Mosaic’s stakeholders have been important in the past when it comes to driving requests, defining data needs, and directing what needs to happen. Plus they’re the go-to people for questions or approvals.

Yasmine Vazquez, Executive Director

Hadiqa Stevens, Program Manager

Tonya Cartwright, Volunteer Director

Philip Lin, Volunteer

Danielle Pitt, Volunteer

Benito Cruz, Volunteer

AMER Development Coordinator (unfilled)

EMEA Development Coordinator (unfilled)

LATAM Development Coordinator (unfilled)

APAC Development Coordinator (unfilled)

The Mosaic Council’s organizational chart

Standard Objects
Account--Contains Seed Bank agencies imported from the Agency Data.txt file
External Files
Agency Detail--Recently added fields that weren't added to the Account object

Global Climates--Temperature data per region

Temperature Mapping Classes--Supplemental file used for calculating temperature classes

Seed Chart--Inventory of crop seeds

Seed Bank Orders--Seed order history by agency

Entity Relationship Diagram
Entity relationship diagram of Seed Bank files

Seed Bank Agencies dataset originates from the Salesforce Account object-which contains records imported from an external file, Agency Data.txt.
New fields were later added to Agency Detail.txt since the import, and the Seed Bank Agencies dataset needs to be updated with those fields.
Each agency must have temperature data which will come from the Global Climates.txt file.
Each seed must also have temperature data that will come from the Temperature Mapping Classes.txt file.
Seed Bank Orders dataset maintains orders placed by agencies in the Seed Bank Agencies dataset and the seeds the agencies ordered listed in the Seed Bank dataset.
Business Requirements
Assemble Your Team
Mosaic’s project volunteers all have their own areas of Salesforce expertise, such as creating and navigating reports and dashboards, or functional knowledge of databases. They’re all excited and ready to roll up their sleeves and jump right in. Your job is to take what each volunteer brings to the table, and enable them to work with CRM Analytics and make Mosaic’s seed distribution goals into reality.

You want to give everyone a chance to help-after all, that's what they do best. But, first you need to learn what each of them can do as you determine the permissions they'll need for their new roles working with CRM Analytics. Philip, Danielle, and Benito couldn’t be more excited about the opportunity.

Benito is Mosaic's go-to expert on Salesforce reporting. You think he's ideal for dashboard development and validating datasets.

Danielle and Philip are comfortable with Salesforce core and databases in general, so they can also help with dataset validation and will likely take on data preparation and adminstration tasks once your job is done.

Yasmine, Hadiqa, and Tonya are the managers and principal contacts for the Seed Bank program, and they’ll be the ones deciding which information is most important to draw from the data. From your analysis, they won't have an active role with administration and maintenance, they will be the endusers.

Create Seed Bank Agencies dataset
Mosaic will be working directly with international agencies, which will be responsible for distributing seeds to farmers participating in the program. Yasmine has asked Tonya to manage this aspect of the project.

Partial listing of Mosaic’s international agency partners

Tonya explains that Danielle and Philip imported the records from a flat file, Agency Data.txt, into the Account object, saving Mosaic a lot of time lost on manual data entry. However, since the import, Mosaic had to collect additional data for reporting purposes related to the agencies and the regions they represent. They’ve documented the latest updates to Agency Detail.txt, but they haven’t added the fields to the Account object yet.

You explain custom fields won’t be necessary and that you can add them in CRM Analytics when you create a new dataset for the Seed Bank. Tonya is pleased, since the added fields are Seed Bank-specific and she’d like to limit records going into CRM Analytics to just those associated with the Seed Bank.

Going over the fields, you come across one, Acres, that looks quite specific. Tonya explains that the Acres field will be used to determine if a given farm has enough land to cultivate a specific crop, since local agencies have already gone through the process of documenting the average size, in acres, of farms participating in the program.

In your process you will create a new Seed Bank Agencies dataset.

Load the pre-populated Account object.
Load the Agency Detail.txt file to update the Account object with the recently added fields since the initial import.
Create a filter to select records associated with the Seed Bank project from the Account object.
Add the custom fields from the Agency Detail.txt file to the Account object.
Register the Account object as the new Seed Bank Agencies dataset.
Yasmine is curious to see what Mosaic will be able to do with the new datasets you'll be creating. With that in mind, you show Benito how to create lenses from the datasets for the executive team to experiment with.
Note
Notes
When creating datasets, make sure you are setting the correct field types for each column. You might have to change some default values.

Since Summer '22 release Data Manager page has a new look. To manage dataflows open Data Manager (Legacy) at the bottom of the page.

Dataflow Name: Load Seed Bank Agencies

Data Components

Node Name	Description	Fields
Load Account	Loads the Account object	
Input fields:
Account Name
Account Number
Account Phone
Shipping City
Shipping Country
Shipping State/Province
Shipping Street
Shipping Postal Code
Load Agency Detail	Loads the Agency Detail.txt file	
Input fields:
AccountNumber
SubRegion
Region
Latitude
Longitude
Currency
Acres
Operations

Node Name	Description
ID Agency Records	Create a field, IsAgency, to flag records in the Accounts object associated with the Seed Bank project. (Hint: Seed Bank Agency records are the only ones with a documented phone number.)
Filter Agency Records	Use IsAgency to filter records in the Accounts object associated with the Seed Bank project.
Add Agency Fields	Adds the following fields from the Agency Detail.txt file to the Account object in the dataflow. Use account number from both sources as the key. Set the Relationship to AgencyDetail.
Currency
Acres
SubRegion
Region
Latitude
Longitude
Create Seed Bank Agencies	Registers the Seed Bank identified records from the Account object as the new Seed Bank Agencies dataset.
Dataset Alias: seed_bank_agencies
Output fields:
Account Name
Account Number
Account Phone
Shipping City
Shipping Country
Shipping State/Province
Shipping Street
Shipping Postal Code
AgencyDetail.Latitude
AgencyDetail.Longitude
AgencyDetail.Currency
AgencyDetail.Acres
AgencyDetail.SubRegion
AgencyDetail.Region
Lens

Build a Top 5 Agencies lens that displays the top 5 agencies participating in the Seed Bank Project.

From the Analytics Studio tab, get to Datasets.

Click the Seed Bank Agencies dataset.

Click the (+) under Bars and select Account Name.

Click the Count of Rows header on the chart to list the values in descending order.

Place your mouse on the first bar in the chart and highlight 5 bars.

Click the Focus button.

Click the Save button, add the title Top 5 Agencies and select Mosaic as the App.

Click the Save button when complete. Click the X next to the new lens tab to close.

Build a Seed Bank
Mosaic has a local seed vendor that promised to donate seeds and advice for the Seed Bank. Mosaic has the vendor’s inventory file of donated seeds. Hadiqa manages the relationship with the vendor. On top of that, she’s Mosaic’s resident horticultural guru. She’ll help you with her product expertise as you build a seed bank in CRM Analytics. Hadiqa goes over the seed file with you during your consultation.

Partial listing of the seed inventory file

Hadiqa confirms that the data doesn’t have any glaring anomalies. However, there are project requirements that require some changes to the file before it can be useful.

Calculate Acreage
Seed donations are made in bulk, noting the number of seeds per pound. The value can be as low as 5 seeds per pound (for avocado seeds), or as high as 1,000,000 (for celery seeds).

Hadiqa also tells you about the Spacing field, which documents seed spacing. This sounds a lot like the Acres field, and you ask her if they’re the same. She explains that the fields are related, but not the same. Spacing stores the amount of space, in square inches, that each seed needs to grow. In some regions, farmers don’t have as much land—some an acre or less. Mosaic will need to know if a farmer’s land can accommodate a certain number of seeds, especially if requests come in for multiple seed types. According to Hadiqa, the best way to figure this out is by knowing how many acres are required per pound of seeds.

Create a dataflow that loads the seed data into a new Seed Bank dataset. In addition, the process must include a step to create a new Acreage field.

In your process you will create a new Seed Bank dataset.

Load records from Seed Chart.txt.
Create an Acreage field that calculates the amount of land for each crop seed.
Register the new Seed Bank dataset.
Create a lens from the Seed Bank dataset.
Dataflow Name: Load Seed Bank

Data Components

Node Name	Description	Fields
Load Seed Chart	Loads the Seed Chart.txt file	Input fields:
Seed ID
Seed Type
Seed
Spacing
Seeds_Pound
Quantity_Pounds
Lifecycle
Temperature
Operations

Node Name	Description
Calculate Acreage	Uses the following formula to create a new field, Acreage, (Seeds_Pound*Spacing)/6272640 [square inches per acre]. Set the Precision to 18 and Scale to 6.
Create Seed Bank	Registers the Seed Bank dataset
Dataset Alias: seed_bank
Output fields:
Acreage
Seed ID
Seed Type
Seed
Spacing
Seeds_Pound
Quantity_Pounds
Lifecycle
Temperature
Lens

Build a Top 5 Crop Seeds lens that displays acreage for the top 5 seeds in the Seed Bank.

From the Analytics Studio tab, get to Datasets.

Click the Seed Bank dataset.

Click Count of Rows under Bar Length and select Sum | Acreage

Click the (+) under Bars and select Seed.

Click the Sum of Acreage header on the chart to list the values in descending order.

Place your mouse on the first bar in the chart and highlight 5 bars.

Click the Focus button.

Click the Save button, add the title Top 5 Crop Seeds and Mosaic for the App.

Click the Save button when complete. Click the X next to the new lens tab to close.

Control Who Sees What
Mosaic is adding staff for the Seed Bank project, and Yasmine wants to limit visibility for those roles to just those regions they will manage.

AMER Development Coordinator--North America and US Territories

EMEA Development Coordinator--Europe, Middle East, and Asia regions

LATAM Development Coordinator--Latin America regions

APAC Development Coordinator--Asia Pacific regions

Under her guidance, Philip set up security within the org to make it possible for these roles to view only agencies within their assigned regions. Also, they should only view their region’s orders from the Seed Bank Orders dataset. Yasmine, Tonya, and Hadiqa will view every order and agency.

Determine Optimal Climates
Hadiqa has consulted with Mosaic’s seed vendor about the best environment for each seed to thrive. Each seed in the inventory file lists a temperature range in Fahrenheit. This is important information, since a crop that requires lots of sun and humidity wouldn’t do well in a locale that’s cool. As a result, when requests come in, Mosaic wants to know if a region can accommodate the requested seed type.

Hadiqa asked Danielle, who studies at a local university, if she can get climate data from her school’s Atmospheric Sciences Department. Danielle came back with a column-separated values file that contains year, temperature, and country. The university gave her data going back to 1991, but the seed vendor said that one year of data is enough for your purposes.

Partial listing of the university’s climate data

The vendor also mentioned that Mosaic may want to consider using temperature classes as a simpler alternative. Temperature classes include Polar, Cool, Tropical, and Continental. Combined, those zones cover the globe. Most regions and crop seeds will carry multiple temperature classes. For example, Afghanistan is Continental for most of the year and Cool during the winter months. Cabbage seeds can grow in regions that are Cool, Continental, or Tropical.

Hadiqa likes this method because it’s simpler than trying to gauge temperature ranges between an agency's region and crop seeds.

Temperature Class	Temperature Range (Fahrenheit)
Tropical	Greater than 85F
Continental	51F to 85F
Cool	25F to 50F
Polar	Less than 25F
To help Mosaic send seeds to matching climates, a temperature class needs to be added to each agency and seed inventory record.

The previous dataflows for the Seed Bank Agencies and Seed Bank datasets are working very well, and for testing purposes you’re thinking it may be best to add modifications to new dataflows. Download copies of the Load Seed Bank Agencies and Load Seed Bank dataflows and upload them into new dataflows as described below.

In your process you will add a TempClass field to the Seed Bank Agencies and Seed Bank datasets.

Upload the Load Seed Bank Agencies dataflow into a new Load Seed Bank Agencies w/Climate Data dataflow.
Upload the Load Seed Bank dataflow into a new Load Seed Bank w/Temperature Classification dataflow.
Calculate a new TempClass field for the Seed Bank Agencies dataset using data from the Global Climates.txt file.
Calculate a new TempClass field for the Seed Bank dataset using data from the Temperature Classes Mapping.txt file.
Create lenses from each dataset displaying the top temperature class.
Dataflow Name: Load Seed Bank Agencies w/Climate Data

Data Components

Node Name	Description	Output Fields
Load Climate	Loads the Global Climates.txt file	
Temperature
Date
Country
**Operations**
Node Name	Description
Filter 2015	Identifies climate data from the year 2015 in Global Climates.txt
Add Temp Class	Uses data from Global Climates.txt to calculate a new TempClass field. Set the default TempClass to Continental.
Augment TempClass	Adds the TempClass field to the Seed Bank Agencies dataset. The field will store one or multiple temperature class values. Use Country from both sources as the key and set the Relationship to Climate.
Create Seed Bank Agencies	Registers the Seed Bank Agencies dataset with the new TempClass field.
Dataset Alias: seed_bank_agencies
Climate.TempClass
Account Name
Account Number
Account Phone
Shipping City
Shipping Country
Shipping State/Province
Shipping Street
Shipping Postal Code
AgencyDetail.Latitude
AgencyDetail.Longitude
AgencyDetail.Currency
AgencyDetail.Acres
AgencyDetail.SubRegion
AgencyDetail.Region
Lens

Build an Agency Temp Class lens that displays the top temperature class.

From the Analytics Studio tab, get to Datasets.

Click the Seed Bank Agencies dataset.

Click the (+) under Bars and select [Climate].TempClass.

Click the Count of Rows header on the chart to list the values in descending order.

Click the first bar in the chart to highlight.

Click the Focus button.

Click the Save button, add the title Agency Temp Class and Mosaic as the App.

Click the Save button when complete. Click the X next to the new lens tab to close.

New Dataflow Name - Load Seed Bank w/Temperature Classification

Data Components

Node Name	Description	Output Fields
Load Temp Class Mapping	Loads the Temperature Classes Mapping.txt file	
TempKey
TempClass
**Operations**
Node Name	Description
Define Temp Range	Identifies the low and high temperatures from the Seed Bank Temperature field.
Add Temp Class	Use the temperature classes table above to help you calculate a new key field to join to the TempKey field in the Temperature Classes Mapping file.
Augment Temp Class	Augments the TempClass field from the Temperature Classes Mapping file to the Seed Bank dataset. The field will store one or multiple temperature class values. Set the Relationship to Climate.
CleanUp	Use this node to drop fields not listed in the Create Seed Bank output.
Create Seed Bank	Registers the Seed Bank dataset with the new Temp Class field.
Dataset Alias: seed_bank
Climate.TempClass
Acreage
Seed ID
Seed Type
Seed
Spacing
Seeds_Pound
Quantity_Pounds
Lifecycle
Temperature
Lens

Build an Seed Bank Temp Class lens that displays the top temperature class.

From the Analytics Studio tab, get to Datasets.

Click the Seed Bank dataset.

Click the (+) under Bars and select [Climate].TempClass.

Click the Count of Rows header on the chart to list the values in descending order.

Click the first bar in the chart to highlight.

Click the Focus button.

Click the Save button, add the title Seed Bank Temp Class and Mosaic for the App.

Click the Save button when complete. Click the X next to the new lens tab to close.

Diagnose and Troubleshoot an Unsuccessful Data Load

You’ve made great progress developing data loading processes, but you have a previously scheduled site visit with another client coming up and will be away for a week. While you’re away you call to check in. A relieved Danielle gets your call and tells you that she and Philip need your help with one of the dataload jobs.

Tonya and Hadiqa want to do targeted analysis of each seed bank agency’s order from the seed bank. Previous orders had been manually documented in a Seed Bank Orders spreadsheet.

Partial listing of orders from the Seed Bank Orders file

The types of queries Tonya and Hadiqa will do in their analyses include:

Orders by agency

Orders by temperature class

Seed type and quantity by agency

Much of the data they’ll need along with the orders exists in the Seed Bank Agencies dataset.

Instead of building a new dataflow and dataset, Danielle and Philip tried updating the Load Seed Bank Agencies dataflow by adding the Seed Bank Orders file. Danielle tells you they accidentally deleted some nodes and tried restoring them; however, the dataflow won’t run. She’s also not sure if they used the right nodes and whether they were set up correctly.

You commend Danielle and Philip for their initiative and assure her the dataflow can be fixed. You ask her to download the dataflow JSON and email it to you to look over.

For this challenge, you need to diagnose and repair the dataflow, Load Seed Bank Agencies with Seed Orders [Broken], and restore it as a new Load Order History dataflow, then build a lens for Tonya and Hadiqa to review.

In your process you will:

Upload the Load Seed Bank Agencies with Seed Orders [Broken] dataflow into a new dataflow, Load Order History.
Diagnose and repair the dataflow as needed.
Save and run the dataflow.
Create a lens from the Order History dataset.
Lens

Build a Top 5 Seed Bank Orders lens that displays the top 5 orders from the Seed Bank.

From the Analytics Studio tab, get to Datasets.
Click the Order History dataset.
Click the Count of Rows under Bar Length and select Sum | Quantity Ordered.
Click the (+) under Bars and select Seed_ID.
Click the Sum of Quantity Ordered header on the chart to list the values in descending order.
Place your mouse on the first bar in the chart and highlight 5 bars.
Click the Focus button.
Click the Save button, add the title Top 5 Seed Bank Orders and save to the Mosaic App.
Click the Save button when complete. Click the X next to the new lens tab to close.

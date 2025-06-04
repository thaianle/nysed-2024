# NYSED School Report Card Project

## Description of the project (Updated June 4, 2025)

![Photo of a library](https://github.com/thaianle/nysed-2024/blob/main/illustration/books.jpg "Source: Pixabay")

_Source: [Pixabay](https://pixabay.com/photos/books-library-room-school-study-2596809/)_

An ongoing data analysis project using PostgreSQL, using the [2023-24 School Report Card Database](https://data.nysed.gov/downloads.php) from the New York State Education Department (NYSED).

The raw database and README files, directly downloaded from the NYSED website in May 2025, is stored in the [data](https://github.com/thaianle/nysed-2024/tree/main/data) folder.

The database was originally a Microsoft Access database (.accdb), and I migrated it to PostgreSQL using the "Export to an ODBC Database" setting.

To preserve as much original data as possible, I kept most parts of the original table and column names along with some minor modifications. I added underscores for table names (such as **Annual_Regents_Exams**), and wrapped table and column names in double quotes ("") in my queries for case sensitivity reasons.

The analysis files contain the [source code](https://github.com/thaianle/nysed-2024/blob/main/analysis.sql) as a SQL file, and another [Markdown file](https://github.com/thaianle/nysed-2024/blob/main/analysis.md) serving as a "notebook", containing both the source code and its interpretation.
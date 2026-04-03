# Loan Status Project

This project automates a loan status validation process using Robot Framework, Autosphere, and Python.

The bot:
- downloads the daily Excel input file
- reads all loan rows
- checks each `TP Code` on the web application
- searches banks in fixed order
- matches the correct person using `Name` and `Phone Number`
- decides `Approve/Reject` based on the status color
- saves the final output Excel file
- creates a ZIP file in `dd_MM_yyyy.zip` format
- uploads the ZIP file back to the website

## Tools Used

- Robot Framework
- Autosphere.Browser
- Python
- pandas

## Project Files

- `LoanStatusProject.robot`  
  Main automation workflow and Robot Framework keywords using `Autosphere.Browser`.

- `LoanStatusProject.py`  
  Python helper file for reading Excel, saving output, and creating the ZIP file.

- `RequirementsChecklist.md`  
  Notes and inferred requirements used while building the project.

## Project Logic

The automation follows this logic:

1. Download the Excel file from the website.
2. Read all rows from the Excel file.
3. For each row, take:
   - `Name`
   - `Phone Number`
   - `TP Code`
4. Search banks in this order:
   - `SBI`
   - `ICICI`
   - `HDFC`
   - `AXIS`
5. If the `TP Code` is not found in any bank, mark the row as:
   - `Reject`
   - `Reason = TP Code not found in any bank`
6. If the `TP Code` opens a valid result table, match the person row using:
   - `Name`
   - `Phone Number`
7. If the person is not found in the result table, mark the row as:
   - `Reject`
   - `Reason = Person not found in TP result table`
8. If the person row is found:
   - green status = `Approve`
   - red status = `Reject`
9. Save the final output to `LoanStatusOutput.xlsx`
10. Create a ZIP file with the format `dd_MM_yyyy.zip`
11. Upload the ZIP file and submit the report

## How To Run

Run the final full process:

```powershell
autosphere -d results ./LoanStatusProject.robot
```

This command should be run in an Autosphere-enabled Robot Framework environment because the project currently uses:

```robot
Library    Autosphere.Browser
```

If using plain Robot Framework/Selenium, the browser library may need to be adapted, for example:

```robot
Library    SeleniumLibrary
```


## Notes

- This project was built step by step from sample data and observed website behavior.
- Some business rules were inferred from the test website flow.
- The browser automation now uses the enterprise library `Autosphere.Browser`.
- Generated screenshots, log files, Excel outputs, ZIP files, and downloaded input files are ignored through `.gitignore`.

# Loan Status Project Requirements Checklist

Use this file to collect the business rules before building the automation logic.

## Project Objective

Build an automation that reads loan data from Excel, validates each record using TP code lookup on the website, updates `Approve/Reject` and `Reason`, saves the final report, creates a ZIP file, and sends the final output by email.TP Code validation is the primary decision point, and the bot should stop row processing early when the lookup result already determines Approve/Reject.

## Project Scope

- Read input data from Excel
- Process each record one by one
- Use TP code as the main validation key
- Detect whether TP lookup returns valid data or `No Data Available`
- Update output columns such as `Approve/Reject` and `Reason`
- Save the final processed file
- Create a ZIP file of the final report
- Send the ZIP/report by email

## Current Working Assumptions

- `TP Code` is the main lookup field
- If TP lookup shows `No Data Available`, the row should be rejected
- If TP lookup shows a valid table, the row should continue as a valid match
- Duplicate TP codes are allowed and should still be processed row by row
- `Approve/Reject` and `Reason` will be written back to the report
- ZIP and email are final delivery steps after processing completes

## 1. Input File Questions

- What is the exact input file name and format?
- Are the columns always the same in every file?
- Is there only one worksheet or multiple worksheets?
- Are there any blank rows to ignore?
- Are `Name`, `Phone Number`, `Company`, and `TP Code` always present?

## 2. Bank Selection Questions

- How do we decide which bank to open for each Excel row?
- Is bank chosen from `Company`?
- Is bank chosen from `TP Code`?
- Is there a fixed mapping table like `Company -> Bank Name`?
- If bank cannot be identified, should the row be rejected?

## 3. TP Code Validation Questions

- Should the bot check whether the Excel `TP Code` exists on the bank details page?
- Should the TP code match exactly?
- If TP code is not found, should result be `Reject`?
- If TP code is found, should result be `Approve`?
- If duplicate TP codes exist, what should the bot do?

## 4. Approve/Reject Logic

- What is the exact rule for `Approve`?
- What is the exact rule for `Reject`?
- Can a row be rejected for more than one reason?
- If data is missing in Excel, should it be `Reject` or skipped?

## 5. Reason Column Rules

- What reason should be written when TP code is not found?
- What reason should be written when bank is not found?
- What reason should be written when input data is invalid?
- Should `Reason` stay blank for approved rows?

## 6. Output Questions

- Should the bot update the same Excel file or create a new output file?
- Should the output include only `Approve/Reject` and `Reason`?
- Should the bot save after every row or once at the end?
- What should the output file name be?

## 7. Website Behavior Questions

- Does the user need to click one bank at a time to see TP code details?
- Does the bank page always open in the same area or a new page?
- Is pagination present in TP code results?
- Are there wait times, popups, or CAPTCHA on this site?

## 8. Exception Handling

- What should happen if the website does not load?
- What should happen if a bank name is missing on the page?
- What should happen if TP code table is empty?
- Should failed rows be logged separately?

## 9. Sample Rule Table

Fill examples like this after checking more records:

| Company | Bank Name | TP Code Example | Expected Result | Reason |
| --- | --- | --- | --- | --- |
| HP | SBI | 2783787332 | Reject | TP Code not found |
| DXC | ? | 2783787332 | ? | ? |
| Infosys | ? | 4546754610 | ? | ? |

## 10. Final Questions Before Build

- What part should be automated first: web lookup, Excel update, or both?
- Do you want the project in Robot Framework only, or Robot plus Python helper?
- Should we build a simple version first and improve later?

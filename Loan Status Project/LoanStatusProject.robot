*** Settings ***
Library           Autosphere.Browser
Library           Collections
Library           OperatingSystem
Library           LoanStatusProject.py


*** Variables ***
${URL}            https://botsdna.com/LoanStatus/
${BROWSER}        Chrome
${INPUT_FILE}     TodayLoans.xlsx
${OUTPUT_FILE}    LoanStatusOutput.xlsx
${UPLOAD_INPUT}   xpath=//input[@id='reportFile']
${SUBMIT_BUTTON}  xpath=//button[@type='button']
${NO_DATA_MSG}    xpath=//h1[normalize-space()='No Data Available']
${STATUS_TABLE}   xpath=//table[.//b[normalize-space()='Name'] and .//b[normalize-space()='Phone Number'] and .//b[normalize-space()='Status']]
@{BANKS}          SBI    ICICI    HDFC    AXIS


*** Keywords ***
Open Browser With Download Folder
    ${prefs}=      Create Dictionary    download.default_directory=${EXECDIR}
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}

    Create Webdriver    ${BROWSER}    options=${options}
    Go To    ${URL}
    Maximize Browser Window

Download Excel File
    ${download_button}=    Set Variable
    ...    xpath=//a[span[@id="yesterdayDate"]]
    Wait Until Element Is Visible    ${download_button}    15s
    Click Element    ${download_button}
    Sleep    5s

Read And Log Excel Data
    @{rows}=    Read Loan Data    ${EXECDIR}/${INPUT_FILE}
    ${row_count}=    Get Length    ${rows}
    Log To Console    Total rows read: ${row_count}
    FOR    ${row}    IN    @{rows}
        Log To Console    ${row}
    END
    RETURN    ${rows}

Open Bank Details
    [Arguments]    ${bank_name}
    ${bank_locator}=    Set Variable    xpath=//a[normalize-space()='${bank_name}']
    Wait Until Element Is Visible    ${bank_locator}    10s
    Click Element    ${bank_locator}

Open TP Code Details
    [Arguments]    ${tp_code}
    ${tp_locator}=    Set Variable    xpath=//a[normalize-space()='${tp_code}']
    ${tp_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${tp_locator}    3s
    IF    not ${tp_visible}
        RETURN    ${FALSE}
    END
    Click Element    ${tp_locator}
    RETURN    ${TRUE}

TP Code Has Data
    [Arguments]    ${tp_code}
    ${tp_opened}=    Open TP Code Details    ${tp_code}
    IF    not ${tp_opened}
        RETURN    ${FALSE}
    END
    ${no_data}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${NO_DATA_MSG}    2s
    IF    ${no_data}
        RETURN    ${FALSE}
    END
    Wait Until Element Is Visible    ${STATUS_TABLE}    10s
    RETURN    ${TRUE}

Check TP Code For Current Page
    [Arguments]    ${bank_name}    ${tp_code}
    Open Bank Details    ${bank_name}
    ${has_data}=    TP Code Has Data    ${tp_code}
    IF    ${has_data}
        Log To Console    TP Code ${tp_code} has data under ${bank_name}
    ELSE
        Log To Console    TP Code ${tp_code} returned No Data Available under ${bank_name}
    END
    RETURN    ${has_data}

Find Bank For TP Code
    [Arguments]    ${tp_code}
    Go To    ${URL}
    FOR    ${bank_name}    IN    @{BANKS}
        ${has_data}=    Check TP Code For Current Page    ${bank_name}    ${tp_code}
        IF    ${has_data}
            RETURN    ${bank_name}
        END
        Go To    ${URL}
    END
    RETURN    ${EMPTY}

Get Status Cell Locator
    [Arguments]    ${name}    ${phone}
    ${phone_text}=    Convert To String    ${phone}
    ${row_locator}=    Set Variable
    ...    xpath=//tr[td[normalize-space()='${name}'] and td[normalize-space()='${phone_text}']]
    ${row_found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${row_locator}    5s
    IF    not ${row_found}
        RETURN    ${EMPTY}
    END
    ${status_locator}=    Set Variable    ${row_locator}/td[last()]
    RETURN    ${status_locator}

Get Decision From Status Cell
    [Arguments]    ${status_locator}
    ${status_cell}=    Get WebElement    ${status_locator}
    ${bg_color}=    Execute Javascript    return window.getComputedStyle(arguments[0]).backgroundColor;    ARGUMENTS    ${status_cell}
    ${bg_color}=    Convert To String    ${bg_color}
    ${is_green}=    Run Keyword And Return Status    Should Contain    ${bg_color}    0, 128, 0
    ${is_red}=      Run Keyword And Return Status    Should Contain    ${bg_color}    255, 0, 0
    IF    ${is_green}
        RETURN    Approve    Status is green
    END
    IF    ${is_red}
        RETURN    Reject    Status is red
    END
    RETURN    Review    Unrecognized status color: ${bg_color}

Process Loan Row
    [Arguments]    ${row}
    ${name}=       Get From Dictionary    ${row}    Name
    ${phone}=      Get From Dictionary    ${row}    Phone Number
    ${tp_code}=    Get From Dictionary    ${row}    TP Code

    Log To Console    Processing row: ${name} | ${phone} | ${tp_code}
    ${bank_name}=    Find Bank For TP Code    ${tp_code}

    IF    not $bank_name
        Set To Dictionary    ${row}    Approve/Reject=Reject    Reason=TP Code not found in any bank
    ELSE
        ${status_locator}=    Get Status Cell Locator    ${name}    ${phone}
        IF    not $status_locator
            Set To Dictionary    ${row}    Approve/Reject=Reject    Reason=Person not found in TP result table
        ELSE
            ${decision}    ${reason}=    Get Decision From Status Cell    ${status_locator}
            Set To Dictionary    ${row}    Approve/Reject=${decision}    Reason=${reason}
        END
    END
    RETURN    ${row}

Process First Excel Row
    ${rows}=    Read And Log Excel Data
    ${first_row}=    Get From List    ${rows}    0
    ${updated_row}=    Process Loan Row    ${first_row}
    ${output_path}=    Save Loan Output    ${rows}    ${EXECDIR}/${OUTPUT_FILE}
    Log To Console    Output saved to: ${output_path}

Process All Loan Rows And Save Output
    ${rows}=    Read And Log Excel Data
    FOR    ${index}    ${row}    IN ENUMERATE    @{rows}
        ${updated_row}=    Process Loan Row    ${row}
        Set List Value    ${rows}    ${index}    ${updated_row}
    END
    ${output_path}=    Save Loan Output    ${rows}    ${EXECDIR}/${OUTPUT_FILE}
    Log To Console    Output saved to: ${output_path}

Run Sample TP Checks
    Go To    ${URL}
    ${sbi_has_data}=    Check TP Code For Current Page    SBI    8757575476
    Log To Console    SBI 8757575476 result: ${sbi_has_data}
    Go To    ${URL}
    ${icici_no_data}=    Check TP Code For Current Page    ICICI    8543289757
    Log To Console    ICICI 8543289757 result: ${icici_no_data}

Create Zip For Output File
    ${zip_path}=    Create Report Zip    ${EXECDIR}/${OUTPUT_FILE}    ${EXECDIR}
    Log To Console    Zip created: ${zip_path}
    RETURN    ${zip_path}

Upload Zipped Report
    [Arguments]    ${zip_path}
    Wait Until Element Is Visible    ${UPLOAD_INPUT}    15s
    Choose File    ${UPLOAD_INPUT}    ${zip_path}
    Wait Until Element Is Visible    ${SUBMIT_BUTTON}    10s
    Click Element    ${SUBMIT_BUTTON}
    Sleep    4s
    Capture Page Screenshot    final-submission.png

Process Loan File And Upload Report
    Process All Loan Rows And Save Output
    ${zip_path}=    Create Zip For Output File
    Go To    ${URL}
    Upload Zipped Report    ${zip_path}

Close Browser Session
    Close Browser


*** Test Cases ***
Process Loan File Zip And Upload
    Open Browser With Download Folder
    Download Excel File
    Process Loan File And Upload Report
    Close Browser Session

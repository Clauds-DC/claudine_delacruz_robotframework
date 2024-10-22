*** Settings ***
Library  SeleniumLibrary
Library  ../Libraries//Users.py
Library  Collections
Resource  ../Resources/SampleResource.resource
Variables  ../Variables//variable.py

Suite Setup  Launch Browser

*** Variables ***

*** Test Cases ***
TEST CASE NO. 1
    Fetch Data
    Sleep    2s
    Login User  demo  demo
    Add All Users
    Verify Created Users
    Display All Users
    Sleep  2s

TEST CASE NO. 2
    Check Customers With Zero Orders

*** Keywords ***
Launch Browser
    [Arguments]  ${url}=https://marmelab.com/react-admin-demo
    ${options}  Set Variable  add_argument("--start-maximized")
    Open Browser  ${url}  chrome  remote_url=192.168.254.100:4444  options=${options}

    # 10.127.132.44 - citco

Input Text
    [Arguments]  ${locator}  ${text}
    SeleniumLibrary.Input Text  ${locator}  ${text}
    Sleep  1s

Login User
    [Arguments]  ${user}  ${password}
    Wait Until Element Is Visible  //button
    Input Text  name:username  ${user}
    Input Text  name:password  ${password}
    Click Button  //button

Go To Link
    [Arguments]  ${text}
    Click Element  //a[text()="${text}"]
    Wait Until Element Is Visible  //tbody//tr

Fetch Data
    ${users}   get_users_via_api
    Set Suite Variable   ${USERS}   ${users}
    ${num_of_users}    Get Length    ${USERS}
    Log To Console     Fetched ${num_of_users} users from the API

Open Add Identity Modal
    Click Element   //a[@aria-label="Create"]
    Wait Until Element Is Visible    ${identity_txt_firstName}   timeout=40s

Add All Users
    ${added_names_list}  Create List
    FOR    ${user}    IN    @{USERS}
        Go To Link   Customers
        Open Add Identity Modal
        Add User   ${user}

        Append To List    ${added_names_list}     ${user['name']}
        # Log to Console    "added user - ${user['name']}"

        # Break the loop unconditionally - for testing
        # Exit For Loop

    END
    
    Set Suite Variable    ${ADDED_NAMES_LIST}    ${added_names_list}
    ${added_names_list_len}   Get Length    ${added_names_list}
    Set Suite Variable    ${ADDED_NAMES_LIST_LEN}    ${added_names_list_len}


Verify Created Users
    # Got to Customer Page
    Go To Link   Customers
    Sleep    5s

    # Get Customer Table Data
    ${cust_table_data}  Get WebElements    //tbody//tr
    ${cust_table_data_len}    Get Length    ${cust_table_data}
    ${is_all_displayed}  Set Variable  True
    ${cust_table_names_list}  Create List

    # Loop into cust_table_data
    FOR  ${index}  IN RANGE  1  ${cust_table_data_len}+1
        ${cust_name}  Get Text  //tbody//tr[${index}]/td[2]
        ${consolidated_cust_name}  Evaluate   r"""${cust_name}""".replace("\\n", "").strip()[1:]
        Append To List    ${cust_table_names_list}  ${consolidated_cust_name}
        # Log To Console    "Verify Created Users - ${consolidated_cust_name} - actual: ${cust_name}"
    END

    # Check if added users really exists on customer table data
    FOR  ${index}  IN RANGE  0  ${ADDED_NAMES_LIST_LEN}

        ${exists}=  Evaluate  '${ADDED_NAMES_LIST}[${index}]' in @{cust_table_names_list}
        IF  not ${exists} 
            ${is_all_displayed}  Set Variable  False
            Log To Console    "Added User does not exists - ${ADDED_NAMES_LIST}[${index}]"
        END
    END

    # Display if all verified
    IF  ${is_all_displayed}
        Log To Console    \n##############################################\nAll User Created are Displayed\n##############################################
    ELSE
        Log To Console    \n##############################################\nAll User Created are Not Displayed\n##############################################
    END

    Sleep    5s

Add User
    [Arguments]  ${user}
    ${name}       Set Variable  ${user['name']}
    ${firstName}  Evaluate  " ".join("${name}".split()[:-1]).strip()
    ${lastName}   Evaluate  " ".join("${name}".split()[-1:]).strip()
    
    ${email}      Set Variable  ${user['email']}
    ${birthday}   Set Variable  ${user['birthday']}
    ${address}    Set Variable  ${user['address']['street']}
    ${city}       Set Variable  ${user['address']['city']}
    ${stateAbbr}  Set Variable  ${user['address']['state']}
    ${zipcode}    Set Variable  ${user['address']['zipcode']}
    ${password}   Generate Password  

    # Log To Console  First Name: ${firstName}
    # Log To Console  Last Name: ${lastName}
    
    Input Text  ${identity_txt_firstName}  ${firstName}
    Input Text  ${identity_txt_lastName}  ${lastName}
    Input Text  ${identity_txt_email}   ${email}
    Input Date  ${identity_txt_birthday}  ${birthday}
    Input Text  ${identity_txt_address}  ${address}
    Input Text  ${identity_txt_city}  ${city}
    Input Text  ${identity_txt_stateAbbr}  ${stateAbbr}
    Input Text  ${identity_txt_zipcode}  ${zipcode}
    
    Input Text  ${identity_txt_password}  ${password}
    Input Text  ${identity_txt_confirm_password}  ${password}

    Click Element  ${identity_btn_save}
    Sleep  2s

Input Date
    [Arguments]  ${locator}  ${date}
    Click Element At Coordinates  ${locator}  0  0
    Press Keys  None  ${date}

Display All Users

    # Get Customer Table Data
    ${cust_table_data}  Get WebElements    //tbody//tr
    ${cust_table_data_len}    Get Length    ${cust_table_data}
    ${cust_orders_list}  Create List
    

    FOR    ${index}    IN RANGE    1    ${cust_table_data_len}+1
        
        ${user_create_row}  Set Variable  Existing User
        # Check names if existing on our actual added users
        ${cust_name}  Get Text  //tbody//tr[${index}]/td[2]
        ${consolidated_cust_name}  Evaluate   r"""${cust_name}""".replace("\\n", "").strip()[1:]

        
        # ${exists}=  Evaluate  "${consolidated_cust_name}" in @{ADDED_NAMES_LIST}
        # IF  ${exists}
        IF  "${consolidated_cust_name}" in @{ADDED_NAMES_LIST}
            ${user_create_row}  Set Variable  Test Created User
        END
        
        # Access Table Customer Data
        ${cust_last_seen}  Get Text    //tbody//tr[${index}]//td[3]
        ${cust_orders}    Get Text    //tbody//tr[${index}]//td[4]
        ${cust_total_spent}    Get Text    //tbody//tr[${index}]//td[5]
        ${cust_lastest_purchase}    Get Text    //tbody//tr[${index}]//td[6]
        ${cust_news}    Get Text    //tbody//tr[${index}]//td[7]
        ${cust_segment}  Get Text  //tbody//tr[${index}]//td[8]
        
        # Logging
        Log To Console    \n---------- USER ${index} ----------
        Log To Console    ${user_create_row} : ${consolidated_cust_name}
        Log To Console    Last Seen : ${cust_last_seen}
        Log To Console    Orders : ${cust_orders}
        Log To Console    Total Spent : ${cust_total_spent}
        Log To Console    Latest Purchase : ${cust_lastest_purchase}
        Log To Console    News : ${cust_news}
        Log To Console    Segment : ${cust_segment}
        Log To Console    ----------------------------------
        

        # Orders for 2nd test Case
        IF  ${cust_orders} == 0
            Append To List    ${cust_orders_list}    ${consolidated_cust_name}
        END

    END
    
    Set Suite Variable    ${CUST_ORDER_WITH_ZERO_LIST}    ${cust_orders_list}


Check Customers With Zero Orders

    ${zero_order_len}  Get Length  ${CUST_ORDER_WITH_ZERO_LIST}

    IF  ${zero_order_len} >= 1
        Fail    Users with zero orders found: ${CUST_ORDER_WITH_ZERO_LIST}
    END

    
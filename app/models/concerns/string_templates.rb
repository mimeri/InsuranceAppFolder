module StringTemplates

  extend ActiveSupport::Concern

  def get_authentication_string
    "<Authentication>
      <UserName>#{SNAP_USERNAME}</UserName>
      <Password>#{SNAP_PASSWORD}</Password>
      <PortfolioCode>#{SNAP_PORTFOLIO_CODE}</PortfolioCode>
      <UserType>#{SNAP_USER_TYPE}</UserType>
     </Authentication>"
  end

  def quote_import_placeholder_xml(financing_term_val,premium)
    "<?xml version='1.0' encoding='utf-8' standalone='yes'?>
      <Request>
         #{get_authentication_string}
         <Data>
          <tq:QuoteInfo xmlns:tq='TemporaryQuote'>
            <tq:CustomerInfo  Quoting_For='#{SNAP_QUOTING_FOR}'
                              Name_1='PlaceholderFirstName'
                              Address_Line_1='PlaceholderAddress'
                              City='PlaceholderCity'
                              Region='BC'
                              Country='CA'
                              Postal_Code='A1A1A1'
                              Quote_Profile='Personal'
                              Quote_Configuration='#{QUOTING_CONFIGURATION[financing_term_val]}'
                              Contact_Name='Hayward API'
                              Payment_Method='Regular'
                              Retained_By_Broker='False' />
            <tq:PolicyInfo>
              <tq:Policy_Count>1</tq:Policy_Count>
              <tq:Policy  Policy_Number='tbi'
                          Effective_Date='#{Date.current.strftime("%-m/%d/%Y")}'
                          Coverage_Code='gl'
                          Policy_Term='#{financing_term_val[0..1]}'
                          Carrier_Code='#{SNAP_CARRIER_CODE}'
                          Premium='#{premium}' />
             </tq:PolicyInfo>
          </tq:QuoteInfo>
         <RequestOptions>
           <ReturnQuoteInfo>true</ReturnQuoteInfo>
           <ReturnPFA>false</ReturnPFA>
          </RequestOptions>
        </Data>
      </Request>"
  end

  def quote_import_xml(customer,policy,transaction)

    first_part =
        %(<?xml version="1.0" encoding="utf-8" standalone="yes"?>
          <Request>
            #{get_authentication_string})

    second_part =
        %(<Data>
          <tq:QuoteInfo xmlns:tq="TemporaryQuote">
            <tq:CustomerInfo Quoting_For="a00314"
                             Name_1="#{customer.name}"
                             Name_2=""
                             Name_3=""
                             Address_Name=""
                             Address_Line_1="#{customer.address}"
                             Address_Line_2=""
                             Address_Line_3=""
                             City="#{customer.city}"
                             Region="#{customer.province}"
                             Country="CA"
                             Postal_Code="#{customer.postal_code}"
                             Additional_Address_Line_1=""
                             Additional_Address_Line_2=""
                             Additional_Address_Line_3=""
                             Additional_City=""
                             Additional_Region=""
                             Additional_Country=""
                             Additional_Postal_Code=""
                             E-Mail="#{customer.email}"
                             Time_in_Business=""
                             Drivers_License=""
                             Tax_Id=""
                             Main_Fax=""
                             Main_Phone="#{customer.phone}"
                             Home_Phone=""
                             Agent_Code=""
                             Agent_Name=""
                             Agent_Address=""
                             Agent_City=""
                             Agent_Region=""
                             Agent_Postal_Code=""
                             Agent_Phone=""
                             Quote_Profile=""
                             Quote_Configuration="#{QUOTING_CONFIGURATION[policy.financing_term]}"
                             Is_Renewal=""
                             WhichPage=""
                             Bank_Name=""
                             Routing_Number=""
                             Account_Number=""
                             Account_Type=""
                             Contact_Name="Hayward API"
                             Industry_Type=""
                             Payment_Method="Regular"
                             Retained_By_Broker="False"
                             Quote_Status=""
                             Document_Status=""
                             Contract_Status=""
            />
            <tq:PolicyInfo>
              <tq:Policy_Count>1</tq:Policy_Count>
              <tq:Policy Policy_Number="#{policy.id}"
                         Effective_Date="#{transaction.effective_date.strftime("%-m/%d/%Y")}"
                         Coverage_Code="gl"
                         Policy_Term="#{policy.financing_term[0..1]}"
                         Days_To_Cancel=""
                         Carrier_Code="#{SNAP_CARRIER_CODE}"
                         Carrier_Name=""
                         Carrier_Address=""
                         Carrier_City=""
                         Carrier_Region=""
                         Carrier_Postal_Code=""
                         Carrier_Country=""
                         Carrier_Phone=""
                         GA_Code=""
                         GA_Name=""
                         GA_Address=""
                         GA_City=""
                         GA_Region=""
                         GA_Postal_Code=""
                         GA_Country=""
                         GA_Phone=""
                         SL1_Code=""
                         SL1_Name=""
                         SL1_Address=""
                         SL1_City=""
                         SL1_Region=""
                         SL1_Postal_Code=""
                         SL1_Country=""
                         SL2_Code=""
                         SL2_Name=""
                         SL2_Address=""
                         SL2_City=""
                         SL2_Region=""
                         SL2_Postal_Code=""
                         SL2_Country=""
                         SL3_Code=""
                         SL3_Name=""
                         SL3_Address=""
                         SL3_City=""
                         SL3_Region=""
                         SL3_Postal_Code=""
                         SL3_Country=""
                         SL4_Code=""
                         SL4_Name=""
                         SL4_Address=""
                         SL4_City=""
                         SL4_Region=""
                         SL4_Postal_Code=""
                         SL4_Country=""
                         Premium="#{transaction.total_premium - policy.transferred_premium}"
                         Earned_Taxes_Fees=""
                         Financed_Taxes_Fees=""
                         Return_Method=""
                         Minimum_Earned_Premium_Percent=""
                         Commission_Percent=""
                         Is_Assigned_Risk=""
                         Is_Auditable=""
                         Is_Filing=""
               />
            </tq:PolicyInfo>
            <tq:TermsInfo Rate_Chart=""
                          Earned_Broker_Fee=""
                          Financed_Broker_Fee=""
            />
          </tq:QuoteInfo>
          <RequestOptions>
            <ReturnQuoteInfo>true</ReturnQuoteInfo>
            <ReturnPFA>true</ReturnPFA>
          </RequestOptions>
        </Data>
      </Request>)
    (first_part + second_part)
  end

  def get_account_xml(quote_number)
    "<Request>
      #{get_authentication_string}
      <Data>
       <QuoteNumber>#{quote_number}</QuoteNumber>
      </Data>
     </Request>"
  end

  def update_account_xml(account_number,customer)
    "<?xml version='1.0' encoding='utf-16' standalone='yes'?>
    <Request>
     #{get_authentication_string}
    <Data>
      <AccountNumber>#{account_number}</AccountNumber>
		  <Primary_Address_Line_1>#{customer.address}</Primary_Address_Line_1>
		  <Primary_Address_Line_2></Primary_Address_Line_2>
		  <Primary_Address_City>#{customer.city}</Primary_Address_City>
		  <Primary_Address_Region>#{customer.province}</Primary_Address_Region>
		  <Primary_Address_Postal_Code>#{customer.province}</Primary_Address_Postal_Code>
		  <Contact_Email>#{customer.email}</Contact_Email>
		  <Contact_Main_Phone>#{customer.phone}</Contact_Main_Phone>
     </Data>
    </Request>"
  end

end
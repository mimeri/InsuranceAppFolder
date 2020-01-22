$(document).on('turbolinks:load', function() {

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// INITIALIZE ////////////////////////////////////////////////////

    update_current_date();

    /* get variables from previous page */
    let model_year_val = $(model_year_id).val();
    const odometer_val = $("[data-id='odometer']").val();

    /* initialize 2nd page variables */
    let coverage_type_val = null;
    let policy_term_val = null;
    let oem_body_parts_val = null;

    let billing_type_initially_populated = false;

    /* change variables according to previous page */
    let selected_coverage_type = $(newapplication_coverage_type_id).val();
    let selected_policy_term = $(newapplication_policy_term_id).val();
    let selected_billing_type = $(newapplication_billing_type_id).val();

    change_coverage_type();
    change_policy_term();
    change_oem_body_parts();
    set_billing_type();
    change_financing_term();

    /* submit form initially */
    step2_submit_form();

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// FUNCTIONS /////////////////////////////////////////////////////

    /* ----------------------------------- FIELD SETTERS -------------------------------------------------*/

    function update_coverage_type(){
        coverage_type_val = $(coverage_type_id).val();
        $(newapplication_coverage_type_id).val(coverage_type_val).change();
    }

    function update_policy_term(){
        policy_term_val = $(policy_term_id).val();
        $(newapplication_policy_term_id).val(policy_term_val).change();
    }

    function update_oem_body_parts(){
        oem_body_parts_val = $(oem_body_parts_id).val();
        $(newapplication_oem_body_parts_id).val(oem_body_parts_val).change();
    }

    function update_billing_type(){
        billing_type_val = $(billing_type_id).val();
        $(newapplication_billing_type_id).val(billing_type_val).change();
    }

    function update_financing_term(){
        financing_term_val = $(financing_term_id).val();
        $(newapplication_financing_term_id).val(financing_term_val).change();
    }

    function set_coverage_type(include_full_replacement){
        $(coverage_type_id+' option').remove();
        if (include_full_replacement === true){
            appendOption(coverage_type_id,'Full Replacement','Full Replacement');
            appendOption(coverage_type_id,'Limited Depreciation', 'Limited Depreciation');
            if (coverage_type_options.includes(selected_coverage_type)){
                $(coverage_type_id).val(selected_coverage_type).change();
            }
        }
        else{
            appendOption(coverage_type_id,'Limited Depreciation', 'Limited Depreciation');
            $(coverage_type_id).val('Limited Depreciation').change();
        }
        selected_coverage_type = null;
        update_coverage_type();
        disableInputGivenLength(coverage_type_id_nohash);
    }

    // max (integer) is maximum policy term
    // eg: set_policy_term(3) yields options '3 years' and '2 years'
    function set_policy_term(max) {
        $(policy_term_id+' option').remove();

        for (var i=max; i>=2; i--){
            let string = i+' years';
            appendOption(policy_term_id,string,string);
        }

        selected_policy_term_num = parseInt(selected_policy_term.charAt(0));

        if (!isNaN(selected_policy_term_num)){
            if (selected_policy_term_num <= max){
                $(policy_term_id).val(selected_policy_term).change();
            }
            else{
                $(policy_term_id).val(max+' years').change();
            }
        }
        selected_policy_term = null;
        update_policy_term();
        disableInputGivenLength(policy_term_id_nohash);
    }

    function set_oem_body_parts(eligible_option) {
        $(oem_body_parts_id+' option').remove();
        appendOption(oem_body_parts_id,eligible_option,eligible_option);
        $(oem_body_parts_id).val(eligible_option).change();
        update_oem_body_parts();
        disableInputGivenLength(oem_body_parts_id_nohash);
    }

    function set_billing_type(){
        if (!billing_type_initially_populated){
            $(billing_type_id+' option').remove();
            appendOption(billing_type_id,'Broker Bill','Broker Bill');
            appendOption(billing_type_id,'Direct Bill','Direct Bill');
            billing_type_initially_populated = true;
        }

        if (billing_type_options.includes(selected_billing_type)){
            $(billing_type_id).val($(newapplication_billing_type_id).val()).change();
            selected_billing_type = null;
        }
        else{
            $(billing_type_id).val('Broker Bill').change();

        }
        update_billing_type();
    }


    function set_financing_term(selected){
        $(financing_term_id+' option').remove();

        if (billing_type_val === 'Direct Bill'){

            if (policy_term_val === '5 years'){
                appendOption(financing_term_id,'48 months','48 months');
                appendOption(financing_term_id,'36 months','36 months');
                appendOption(financing_term_id,'24 months','24 months');
                if (five_year_financing_term_options.includes(selected)){
                    $(financing_term_id).val(selected).change();
                }
            }
            else if (policy_term_val === '4 years'){
                appendOption(financing_term_id,'36 months','36 months');
                appendOption(financing_term_id,'24 months','24 months');
                if (four_year_financing_term_options.includes(selected)){
                    $(financing_term_id).val(selected).change();
                }
            }
            else if (policy_term_val === '3 years'){
                appendOption(financing_term_id,'24 months','24 months');
                $(financing_term_id).val('24 months').change();
            }
            else if (policy_term_val === '2 years'){
                appendOption(financing_term_id,'12 months','12 months');
                $(financing_term_id).val('12 months').change();
            }
        }
        update_financing_term();
    }

    /* ----------------------------------- HANDLE CHANGES -------------------------------------------------*/

    // coverage_type AFFECTED BY model_year
    function change_coverage_type(){
        if (model_year_val >= (current_year - 1) && odometer_val <= max_odometer){
            // FR available
            set_coverage_type(true);
        }
        else{
            // FR not available
            set_coverage_type(false);
        }
    }

    // policy_term AFFECTED BY model_year
    function change_policy_term(){
        max = get_max_policy_term(model_year_val);
        set_policy_term(max);
    }

    // oem_body_parts AFFECTED BY model_year, coverage_type and policy_term
    function change_oem_body_parts(){
        let model_year = parseInt(model_year_val);
        if ( isFullReplacement(coverage_type_val) && (model_year >= year_two) ){
            if (policy_term_val === '2 years'){
                set_oem_body_parts(yes2Years);
            }
            else{
                set_oem_body_parts(yes3Years);
            }
        }
        else{
            set_oem_body_parts(notEligible);
        }
    }

    // PREVIOUS CHANGE_OEM_BODY_PARTS
    // function change_oem_body_parts(){
    //     let model_year = parseInt(model_year_val);
    //
    //     if (isFullReplacement(coverage_type_val)){
    //         if ((model_year === year_two) || (policy_term_val === '2 years')){
    //             set_oem_body_parts(yes2Years);
    //         }
    //         else if ((model_year > year_two) && (policy_term_val !== '2 years')){
    //             set_oem_body_parts(yes3Years);
    //         }
    //     }
    //     else{
    //         set_oem_body_parts(notEligible);
    //     }
    // }

    // financing_term AFFECTED BY billing_type and policy_term
    function change_financing_term(){
        if (billing_type_val === 'Broker Bill'){
            $(".financing_term").hide();
        }
        else if (billing_type_val === 'Direct Bill'){
            $(".financing_term").show();
        }
        set_financing_term($(newapplication_financing_term_id).val());
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// COVERAGE TYPE /////////////////////////////////////////////////

    $(coverage_type_id).change(function(e) {
        update_coverage_type();
        change_oem_body_parts();
        if (e.originalEvent){
            step2_submit_form(e);
        }
    });

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// POLICY TERM ///////////////////////////////////////////////////

    $(policy_term_id).change(function(e) {
        update_policy_term();
        change_oem_body_parts();
        change_financing_term();
        if (e.originalEvent){
            step2_submit_form(e);
        }
    });

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// OEM BODY PARTS ////////////////////////////////////////////////

    $(oem_body_parts_id).change(function(e) {
        update_oem_body_parts();
        if (e.originalEvent){
            step2_submit_form(e);
        }
    });

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// BILLING TYPE //////////////////////////////////////////////////

    $(billing_type_id).change(function(e) {
        update_billing_type();
        change_financing_term();
        if (e.originalEvent){
            step2_submit_form(e);
        }
    });

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////// FINANCING TERM /////////////////////////////////////////////////

    $(financing_term_id).change(function(e) {
        update_financing_term();
        if (e.originalEvent){
            step2_submit_form(e);
        }
    });

});
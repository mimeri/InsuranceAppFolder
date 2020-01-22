$(document).on('turbolinks:load', function() {

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// INITIALIZE ////////////////////////////////////////////////////

    update_current_date();

    /* variables */
    let model_year_val = $(model_year_id).val();
    let coverage_type_val = $(coverage_type_id).val();
    let policy_term_val = $(policy_term_id).val();
    let oem_body_parts_val = $(oem_body_parts_id).val();
    let billing_type_val = $(billing_type_id).val();
    let financing_term_val = $(financing_term_id).val();

    /* selected */
    let selected_coverage_type = model_year_val;
    let selected_policy_term = policy_term_val;
    let selected_oem_body_parts = oem_body_parts_val;
    let selected_financing_term = financing_term_val;

    change_oem_body_parts();
    change_financing_term();
    change_button_color(dealer_category_not_tesla_id);

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// FUNCTIONS /////////////////////////////////////////////////////

    function change_button_color(input){
        $(dealer_category_not_tesla_id).next('label').removeClass(radio_button_color);
        $(dealer_category_tesla_id).next('label').removeClass(radio_button_color);
        $(dealer_category_private_sale_id).next('label').removeClass(radio_button_color);
        $(dealer_category_out_of_province_id).next('label').removeClass(radio_button_color);
        $(input).next('label').addClass(radio_button_color);
    }

    /* ----------------------------------- FIELD UPDATERS -------------------------------------------------*/

    function update_model_year(){
        model_year_val = $(model_year_id).val();
    }

    function update_coverage_type(){
        coverage_type_val = $(coverage_type_id).val();
        selected_coverage_type = coverage_type_val;
    }

    function update_policy_term(){
        policy_term_val = $(policy_term_id).val();
        selected_policy_term = policy_term_val
    }

    function update_oem_body_parts(){
        oem_body_parts_val = $(oem_body_parts_id).val();
        selected_oem_body_parts = oem_body_parts_val;
    }

    function update_billing_type(){
        billing_type_val = $(billing_type_id).val();
    }

    function update_financing_term(){
        financing_term_val = $(financing_term_id).val();
        selected_financing_term = financing_term_val;
    }


    /* ----------------------------------- FIELD SETTERS -------------------------------------------------*/

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
        update_coverage_type();
    }

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
        update_policy_term();
    }

    function set_oem_body_parts(eligible_option) {
        $(oem_body_parts_id+' option').remove();
        appendOption(oem_body_parts_id,eligible_option,eligible_option);
        $(oem_body_parts_id).val(eligible_option).change();
        update_oem_body_parts();
        // document.getElementById("quickquote_oem_body_parts").disabled=true;
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
        if (model_year_val >= (current_year - 1)){
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
        set_financing_term(selected_financing_term);
    }

    //////////////////////////////////////// MODEL YEAR /////////////////////////////////////////////////

    $(model_year_id).change(function(){
        update_model_year();
        change_coverage_type();
        change_policy_term();
        change_oem_body_parts();
    });

    /////////////////////////////////////// COVERAGE TYPE ///////////////////////////////////////////////

    $(coverage_type_id).change(function(){
        update_coverage_type();
        change_oem_body_parts();
    });

    ///////////////////////////////////////  POLICY TERM ////////////////////////////////////////////////

    $(policy_term_id).change(function(){
       update_policy_term();
       change_oem_body_parts();
       change_financing_term();
    });

    //////////////////////////////////////// OEM BODY PARTS ////////////////////////////////////////////////

    $(oem_body_parts_id).change(function(){
       update_oem_body_parts();
    });

    //////////////////////////////////////// BILLING TYPE //////////////////////////////////////////////////

    $(billing_type_id).change(function() {
        update_billing_type();
        change_financing_term();
    });

    /////////////////////////////////////// FINANCING TERM /////////////////////////////////////////////////

    $(financing_term_id).change(function() {
        update_financing_term();
    });

    ///////////////////////////////////// DEALER CATEGORY //////////////////////////////////////////////////

    $(dealer_category_not_tesla_id).on('click', function() {
        change_button_color(dealer_category_not_tesla_id);
    });

    $(dealer_category_tesla_id).on('click', function() {
        change_button_color(dealer_category_tesla_id);
    });

    $(dealer_category_private_sale_id).on('click', function() {
        change_button_color(dealer_category_private_sale_id);
    });

    $(dealer_category_out_of_province_id).on('click', function() {
        change_button_color(dealer_category_out_of_province_id);
    });

    /////////////////////////////////////// SUBMIT BUTTON //////////////////////////////////////////////////

});







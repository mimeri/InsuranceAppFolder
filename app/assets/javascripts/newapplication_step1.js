$(document).on('turbolinks:load', function() {

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// INITIALIZE ////////////////////////////////////////////////////

    update_current_date();

    /* Store initial values */
    let model_year_val = $(newapplication_model_year_id).val();
    let purchase_date_year_val = $(newapplication_purchase_date_year_id).val();
    let purchase_date_month_val = $(newapplication_purchase_date_month_id).val();
    let purchase_date_day_val = $(newapplication_purchase_date_day_id).val();
    let use_rate_class_val = $(newapplication_use_rate_class_id).val();

    /* Default values */
    change_purchase_date_year();
    change_purchase_date_day();
    change_gvw();
    check_radio_buttons();

    disableInputGivenLength("newapplication_broker_id");

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// FUNCTIONS /////////////////////////////////////////////////////

    function change_button_color(input){
        $(newapplication_dealer_category_not_tesla_id).next('label').removeClass(radio_button_color);
        $(newapplication_dealer_category_tesla_id).next('label').removeClass(radio_button_color);
        $(newapplication_dealer_category_private_sale_id).next('label').removeClass(radio_button_color);
        $(newapplication_dealer_category_out_of_province_id).next('label').removeClass(radio_button_color);
        $(input).next('label').addClass(radio_button_color);
    }

    function check_radio_buttons(){

        if ($(newapplication_dealer_category_not_tesla_id).is(':checked')){
            $(".dealer").show();
            change_button_color(newapplication_dealer_category_not_tesla_id);
        }
        else if ($(newapplication_dealer_category_tesla_id).is(':checked')){
            $(".dealer").show();
            change_button_color(newapplication_dealer_category_tesla_id);
        }
        else if ($(newapplication_dealer_category_private_sale_id).is(':checked')){
            $(".dealer").hide();
            change_button_color(newapplication_dealer_category_private_sale_id);
        }
        else if ($(newapplication_dealer_category_out_of_province_id).is(':checked')){
            $(".dealer").hide();
            change_button_color(newapplication_dealer_category_out_of_province_id);
        }
    }

    /* -------------------------------------- HELPERS -----------------------------------------------------*/

    function daysInMonth(month,year){
        return new Date(year, month, 0).getDate();
    }

    /* ---------------------------------- FIELD SETTERS ---------------------------------------------------*/

    // max = maximum number of days in the month
    function set_purchase_date_day(max,year_changed){

        if (typeof year_changed === 'undefined'){
            year_changed = false;
        }

        // store value day value user selected in order to decide whether to keep it selected
        let selectedOption = $(newapplication_purchase_date_day_id).find(":selected").text();

        $(newapplication_purchase_date_day_id+' option').remove(); // remove all options in order to re-populate

        // add days starting from 1st to max
        for (var i=1; i<=max; i++){
            i_s = i.toString();
            $(newapplication_purchase_date_day_id).append(new Option(i_s,i_s));
        }

        if (selectedOption <= max){
            $(newapplication_purchase_date_day_id).val(selectedOption);
        }
        else if(selectedOption === '29' && purchase_date_month_val === '2' && year_changed){
            $(newapplication_purchase_date_day_id).val('28');
        }

        purchase_date_day_val = $(newapplication_purchase_date_day_id).val();
    }

    function set_purchase_date_year(min,max,selected){
        $(newapplication_purchase_date_year_id+' option').remove();


        for (var i=max; i>=min; i--){

            i_s = i.toString();

            if (selected === i_s){
                $(newapplication_purchase_date_year_id).append(new Option(i_s,i)).val(i);
            }
            else{
                $(newapplication_purchase_date_year_id).append(new Option(i_s,i));
            }
        }
        purchase_date_year_val = $(newapplication_purchase_date_year_id).val();
    }

    /* ----------------------------------- HANDLE CHANGES -------------------------------------------------*/

    // purchase_date_year AFFECTED BY model_year
    function change_purchase_date_year(){
        update_current_date();
        let selected_purchase_year = $(newapplication_purchase_date_year_id).find(":selected").text();
        model_year_int = parseInt(model_year_val);
        set_purchase_date_year(model_year_int-2,current_year,selected_purchase_year);
    }

    // purchase_date_day AFFECTED BY purchase_date_month AND purchase_date_year (leap years)
    function change_purchase_date_day(year_changed){
        if (year_changed === null){
            year_changed = false;
        }
        let selected_month = $(newapplication_purchase_date_month_id).val();
        let selected_year = $(newapplication_purchase_date_year_id).val();
        let max_days = daysInMonth(selected_month,selected_year);
        set_purchase_date_day(max_days,year_changed);
    }

    // gvw AFFECTED BY use_rate_class
    function change_gvw(){
        if (['011 - FARM USE','012 - ARTISAN USE','014 - FISHER USE'].includes(use_rate_class_val)){
            $(".gvw").show();
        }
        else{
            $("#newapplication_gvw").val("");
            $(".gvw").hide();
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////// MODEL YEAR /////////////////////////////////////////////////////

    // model_year AFFECTS purchase_date_year
    $(newapplication_model_year_id).change(function(){
        model_year_val = $(newapplication_model_year_id).val();
        change_purchase_date_year();
    });

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////// PURCHASE DATE - YEAR ///////////////////////////////////////////////

    // purchase_date_year AFFECTS purchase_date_day
    $(newapplication_purchase_date_year_id).change(function(){
        purchase_date_year_val = $(newapplication_purchase_date_year_id).val();
        change_purchase_date_day(true);
    });

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////// PURCHASE DATE - MONTH //////////////////////////////////////////////

    // purchase_date_month AFFECTS purchase_date_day
    $(newapplication_purchase_date_month_id).change(function(){
        purchase_date_month_val = $(newapplication_purchase_date_month_id).val();
        change_purchase_date_day();
    });


    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////// PURCHASE DATE - DAY ///////////////////////////////////////////////


    $(newapplication_purchase_date_day_id).change(function(){
        purchase_date_day_val = $(newapplication_purchase_date_day_id).val();
    });

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////// USE RATE CLASS //////////////////////////////////////////////////

    // use_rate_class AFFECTS gvw field availability
    $(newapplication_use_rate_class_id).change(function(){
        use_rate_class_val = $(newapplication_use_rate_class_id).val();
        change_gvw();
    });

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////// DEALER CATEGORY //////////////////////////////////////////////////

    $(newapplication_dealer_category_not_tesla_id).on('click', function() {
        $(".dealer").show();
        change_button_color(newapplication_dealer_category_not_tesla_id);
    });

    $(newapplication_dealer_category_tesla_id).on('click', function() {
        $(".dealer").show();
        change_button_color(newapplication_dealer_category_tesla_id);
    });

    $(newapplication_dealer_category_private_sale_id).on('click', function() {
        document.getElementById("newapplication_dealer").value = '';
        $(".dealer").hide();
        change_button_color(newapplication_dealer_category_private_sale_id);
    });

    $(newapplication_dealer_category_out_of_province_id).on('click', function() {
        document.getElementById("newapplication_dealer").value = '';
        $(".dealer").hide();
        change_button_color(newapplication_dealer_category_out_of_province_id);
    });

    $(newapplication_dealer_id).autocomplete({
        minLength : 0,
        source: $(newapplication_dealer_id).data('autocomplete-source'),
    }).focus(function() {
        $(this).autocomplete("search", $(this).val());
    });

    $("#new_newapplication").submit(function(){
        document.getElementById("newapplication_broker_id").disabled=false;
    });

    $("#edit_newapplication").submit(function(){
        document.getElementById("newapplication_broker_id").disabled=false;
    });

});
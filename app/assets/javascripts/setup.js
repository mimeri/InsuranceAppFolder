// VARIABLE NAMES //
const yes3Years = "Yes - 3 years";
const yes2Years = "Yes - 2 years";
const notEligible = "Not Eligible";

//submit quickquote form function defined here
function submit_form(id){
    let form = $(id)[0];
    Rails.fire(form, 'submit');
}

// QUICKQUOTE FIELDS ///////////////////////////////////////////////////////////////////////////////////////
const quickquote_string = "quickquote_";
// quickquote field id's without #
const broker_id_id_nohash = quickquote_string+"broker_id";
const model_year_id_nohash = quickquote_string+"model_year";
const dealer_category_not_tesla_id_nohash = quickquote_string+"dealer_category_not_tesla";
const dealer_category_tesla_id_nohash = quickquote_string+"dealer_category_tesla";
const dealer_category_private_sale_id_nohash = quickquote_string+"dealer_category_private_sale";
const dealer_category_out_of_province_id_nohash = quickquote_string+"dealer_category_out_of_province";
const coverage_type_id_nohash = quickquote_string+"coverage_type";
const policy_term_id_nohash = quickquote_string+'policy_term';
const oem_body_parts_id_nohash = quickquote_string+'oem_body_parts';
const billing_type_id_nohash = quickquote_string+'billing_type';
const financing_term_id_nohash = quickquote_string+'financing_term';
// quickquote field id's with #
const broker_id_id = "#"+broker_id_id_nohash;
const model_year_id = "#"+model_year_id_nohash;
const dealer_category_not_tesla_id = "#"+dealer_category_not_tesla_id_nohash;
const dealer_category_tesla_id = "#"+dealer_category_tesla_id_nohash;
const dealer_category_private_sale_id = "#"+dealer_category_private_sale_id_nohash;
const dealer_category_out_of_province_id = "#"+dealer_category_out_of_province_id_nohash;
const coverage_type_id = "#"+coverage_type_id_nohash;
const policy_term_id = "#"+policy_term_id_nohash;
const oem_body_parts_id = "#"+oem_body_parts_id_nohash;
const billing_type_id = "#"+billing_type_id_nohash;
const financing_term_id = "#"+financing_term_id_nohash;
///////////////////////////////////////////////////////////////////////////////////////////////////////////

// newapplication field id's
const newapplication_string = "#newapplication_";
const newapplication_model_year_id = newapplication_string+"model_year";
const newapplication_purchase_date_year_id =  newapplication_string+"purchase_date_1i";
const newapplication_purchase_date_month_id = newapplication_string+"purchase_date_2i";
const newapplication_purchase_date_day_id = newapplication_string+"purchase_date_3i";
const newapplication_dealer_category_not_tesla_id = newapplication_string+"dealer_category_not_tesla";
const newapplication_dealer_category_tesla_id = newapplication_string+"dealer_category_tesla";
const newapplication_dealer_category_private_sale_id = newapplication_string+"dealer_category_private_sale";
const newapplication_dealer_category_out_of_province_id = newapplication_string+"dealer_category_out_of_province";
const newapplication_dealer_id = newapplication_string+"dealer";
const newapplication_use_rate_class_id = newapplication_string+"use_rate_class";
const newapplication_odometer_id = newapplication_string+"odometer";

const newapplication_coverage_type_id = newapplication_string+"coverage_type";
const newapplication_policy_term_id = newapplication_string+'policy_term';
const newapplication_oem_body_parts_id = newapplication_string+'oem_body_parts';
const newapplication_billing_type_id = newapplication_string+'billing_type';
const newapplication_financing_term_id = newapplication_string+'financing_term';
const newapplication_insured_type_id = newapplication_string+'insured_type';

// constant values
const max_odometer = 40000;

/* date values */

let current_date = null;
let current_year = null;
let one_year_ago = null;
let one_year_ago_date = null;
let year_two = null;
let year_four = null;
let max_year = null;
let min_year = null;

////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// FUNCTIONS /////////////////////////////////////////////////////

function isFullReplacement(coverage_type){
    return (coverage_type === 'Full Replacement');
}

function get_year(dateString){
    return parseInt(dateString.substr(0,4));
}

function update_current_date(){
    current_date = new Date().toLocaleDateString("en-CA",{timeZone: "America/Los_Angeles"}).replace(/\u200E/g, '');
    current_year = get_year(current_date);
    one_year_ago = current_year - 1;
    one_year_ago_date = one_year_ago.toString()+current_date.substr(4);
    year_two = current_year - 1;
    year_four = current_year - 3;
    max_year = current_year + 1;
    min_year = current_year - 10;
    return current_date;
}

function get_max_policy_term(model_year){

    let max = 5;
    if (parseInt(model_year) === current_year-8 ){
        max = 4;
    }
    else if (parseInt(model_year) === current_year-9 ){
        max = 3;
    }
    else if (parseInt(model_year) === current_year-10 ){
        max = 2;
    }
    return max;
}

function appendOption(id,option_text,value){
    let o = new Option(option_text, value);
    $(o).html(option_text);
    $(id).append(o);
}

function disableInputGivenLength(id_without_hash){
    document.getElementById(id_without_hash).disabled = $('#' + id_without_hash + ' option').length < 2;
}

function add_spinner(div){
    $(div).html("<i class='fas fa-sync fa-spin fa-2x'></i>");
    $(div).addClass('center');
}

function step2_submit_form(){

    add_spinner("#quickquote_result");
    $('#step2NextButton').prop('disabled',true);

    field_option_array = [coverage_type_id_nohash,policy_term_id_nohash,oem_body_parts_id_nohash,billing_type_id_nohash];
    field_option_disabled_array = [];
    field_option_array_length = field_option_array.length;

    for (var i=0; i<field_option_array_length; i++){
        field_option_disabled_array.push($("#"+field_option_array[i]).is(':disabled'));
        document.getElementById(field_option_array[i]).disabled=false;
    }

    submit_form("#quickquote_form");

    for (var i=0; i<field_option_array_length; i++){
        if (field_option_disabled_array[i]){
            document.getElementById(field_option_array[i]).disabled=true;
        }
    }
}

function isEmptyOrSpaces(str){
    return str === null || str.match(/^\s*$/) !== null;
}

function create_datepicker(id,endDateIsToday){

    flatpickr_obj =
        flatpickr(id, {
            altFormat: 'F j, Y',
            altInput: true,
            dateFormat: 'Y-m-d',
            position: 'below'
        });

    if (endDateIsToday === true){
        update_current_date();
        flatpickr_obj.set('maxDate', current_date);
    }

}

function toggle_date_filter(string,date_fields_div){
    if (string === "") {
        $(date_fields_div).hide();
    }
    else{
        $(date_fields_div).show();
    }
}

// field options

coverage_type_options = ['Full Replacement','Limited Depreciation'];
policy_term_options = ['5 years','4 years','3 years','2 years'];
oem_body_parts_options = [notEligible,yes3Years,yes2Years];
billing_type_options = ['Broker Bill','Direct Bill'];
financing_term_options = ['48 months','36 months','24 months','12 months'];

five_year_financing_term_options = ['48 months','36 months','24 months'];
four_year_financing_term_options = ['36 months','24 months'];

months_list = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sept','Oct','Nov','Dec'];

//////// from step 2 /////////////

let billing_type_val = null;
let financing_term_val = null;

const radio_button_color = "text-primary";




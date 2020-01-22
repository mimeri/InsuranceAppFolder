$(document).on('turbolinks:load', function() {

    const filter_type_id = "#transaction_report_attribute_filter";
    const date_range_select_id = "#transaction_report_date_range_type";
    const date_class = ".transaction-date-field";
    const date_fields_div = "#transactionReportDateFields";
    const start_date_id = "#transaction_report_start_custom_date";
    const end_date_id = "#transaction_report_end_custom_date";
    const submit_id = "#transactionReportSubmitButton";

    let date_range_select_val = $(date_range_select_id).val();

    create_pickadate(start_date_id);

    create_pickadate(end_date_id);

    toggle_date_filter($(filter_type_id).val(),date_fields_div);

    $(filter_type_id).on('change', function(){
        toggle_date_filter($(filter_type_id).val(),date_fields_div);
        if ($(filter_type_id).val() === ""){
            $(date_range_select_id).val('Current month').change();
        }
    });

    $(date_class).hide();

    $(date_range_select_id).change(function(){
        date_range_select_val = $(date_range_select_id).val();
        if (date_range_select_val === "Custom Date Range"){
            $(date_class).show();
        }
        else{
            $(date_class).hide();
        }
    });

    $(submit_id).on('click', function(){
       $(".alert").remove();
    });

});
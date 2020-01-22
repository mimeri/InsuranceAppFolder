$(document).on('turbolinks:load', function() {

    const newapplication_table_id = "#recall_application_table";
    const start_date_id = "#recall_application_date_filter_start";
    const end_date_id = "#recall_application_date_filter_end";
    const date_fields_div = "#searchApplicationDateFields";
    const filter_type_id = "#recall_application_date_filter_type";

    create_pickadate(start_date_id);

    create_pickadate(end_date_id);

    toggle_date_filter($(filter_type_id).val(),date_fields_div);

    $(filter_type_id).on('change', function(){
        toggle_date_filter($(filter_type_id).val(),date_fields_div);
    });

    $(newapplication_table_id).dataTable({
        "dom": '<"top"i>rt<"bottom"lp><"clear">',
        "scrollY": "500px",
        "scrollX": true,
        "scrollCollapse": true,
        "processing": true,
        "serverSide": true,
        "order": [9, "desc"],
        "ajax": {
            "url": $(newapplication_table_id).data('source')
        },
        "pagingType": "full_numbers",
        "columns": [
            {"data": "name", "width": "220px"},
            {"data": "status", "width": "110px"},
            {"data": "coverage_type", "width": "140px"},
            {"data": "vehicle", "width": "200px"},
            {"data": "billing_type", "width": "120px"},
            {"data": "vin", "width": "170px"},
            {"data": "reg_num", "width": "100px"},
            {"data": "broker_name", "width": "220px"},
            {"data": "user_name", "width": "220px"},
            {"data": "updated_at", "width": "140px"},
            {"data": "created_at", "width": "140px"}
        ]
        // pagingType is optional, if you want full pagination controls.
        // Check dataTables documentation to learn more about
        // available options.
    }).yadcf([
        {
            column_number: 0,
            filter_type: "text",
            filter_delay: 200
        },
        {
            column_number: 1,
            data: ["Complete","Incomplete"],
            filter_default_label: "Select",
            filter_match_mode: 'exact'
        },
        {
            column_number: 2,
            data: ["Full Replacement","Limited Depreciation"],
            filter_default_label: "Select",
            filter_match_mode: 'exact'
        },
        {
            column_number: 3,
            filter_type: "text",
            filter_delay: 200
        },
        {
            column_number: 4,
            data: ["Broker Bill","Direct Bill"],
            filter_default_label: "Select",
            filter_match_mode: 'exact'
        },
        {
            column_number: 5,
            filter_type: "text",
            filter_delay: 200
        },
        {
            column_number: 6,
            filter_type: "text",
            filter_delay: 200
        },
        {
            column_number: 7,
            filter_type: "text",
            filter_delay: 200
        },
        {
            column_number: 8,
            filter_type: "text",
            filter_delay: 200
        }
    ], 'tfoot');

});
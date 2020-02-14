$(document).on('turbolinks:load', function() {

    const policy_table_id = "#policy_table";
    const start_date_id = "#search_policy_date_filter_start";
    const end_date_id = "#search_policy_date_filter_end";
    const date_fields_div = "#searchPolicyDateFields";
    const filter_type_id = "#search_policy_date_filter_type";
    const update_all_transactions_id = "#confirmUpdateAllTransactionsModalSubmit";
    const body_id = "#searchPolicyTableDiv";

    create_datepicker(start_date_id);

    create_datepicker(end_date_id);

    toggle_date_filter($(filter_type_id).val(),date_fields_div);

    $(filter_type_id).on('change', function(){
        toggle_date_filter($(filter_type_id).val(),date_fields_div);
    });

    $(update_all_transactions_id).on('click', function(){
        add_spinner(body_id);
        $(body_id).append("Updating all transactions and resetting all table filters. This may take a while to load, please wait...");
    });

    $(policy_table_id).dataTable({
        "dom": '<"top"i>rt<"bottom"lp><"clear">',
        "scrollY": "500px",
        "scrollX": true,
        "scrollCollapse": true,
        "processing": true,
        "serverSide": true,
        "destroy": true, // necessary if we are constantly refreshing page
        "order": [13, "desc"],
        "ajax": {
            "url": $(policy_table_id).data('source')
        },
        "pagingType": "full_numbers",
        "columns": [
            {"data": "id", "width": "85px"},
            {"data": "transaction_type", "width": "140px"},
            {"data": "name", "width": "220px"},
            {"data": "status", "width": "110px"},
            {"data": "coverage_type", "width": "140px"},
            {"data": "effective", "width": "100px"},
            {"data": "expiry", "width": "100px"},
            {"data": "vehicle", "width": "200px"},
            {"data": "billing_type", "width": "120px"},
            {"data": "vin", "width": "170px"},
            {"data": "reg_num", "width": "100px"},
            {"data": "broker_name", "width": "220px"},
            {"data": "user_name", "width": "220px"},
            {"data": "created_at", "width": "140px"},
            {"data": "snap_status", "width": "110px"},
            {"data": "quote_number", "width": "155px"},
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
            data: ["new","cancelled"],
            filter_default_label: "Select",
            filter_match_mode: 'exact'
        },
        {
            column_number: 2,
            filter_type: "text",
            filter_delay: 200
        },
        {
            column_number: 3,
            data: ["bound","cancelled","void","expired","transferred"],
            filter_default_label: "Select",
            filter_match_mode: 'exact'
        },
        {
            column_number: 4,
            data: ["Full Replacement","Limited Depreciation"],
            filter_default_label: "Select",
            filter_match_mode: 'exact'
        },
        {
            column_number: 7,
            filter_type: "text",
            filter_delay: 200
        },
        {
            column_number: 8,
            data: ["Broker Bill","Direct Bill"],
            filter_default_label: "Select",
            filter_match_mode: 'exact'
        },
        {
            column_number: 9,
            filter_type: "text",
            filter_delay: 200
        },
        {
            column_number: 10,
            filter_type: "text",
            filter_delay: 200
        },
        {
            column_number: 11,
            filter_type: "text",
            filter_delay: 200
        },
        {
            column_number: 12,
            filter_type: "text",
            filter_delay: 200
        },
        {
            column_number: 14,
            data: ["Not active","Active","Cancelled"],
            filter_default_label: "Select",
            filter_match_mode: 'exact'
        },
        {
            column_number: 15,
            filter_type: "text",
            filter_delay: 200
        }
    ], 'tfoot');

});
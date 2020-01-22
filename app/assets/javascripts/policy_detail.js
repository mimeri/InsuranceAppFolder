$(document).on('turbolinks:load', function() {

    // Print Forms Modal
    $("#printFormsModalButton").on('click', function(){
        const modal_id = "#printFormsModal";
        const broker_id = "#printpdf_broker_check";
        const insured_id = '#printpdf_insured_check';
        const cancellation_broker_id = "#printpdf_cancellation_broker_check";
        const cancellation_insured_id = "#printpdf_cancellation_insured_check";
        const financing_contract_form_id = "#printpdf_financing_contract_form";
        const release_of_interest_id = "#printpdf_release_of_interest";

        const checkbox_array = [broker_id,insured_id,cancellation_broker_id,cancellation_insured_id,financing_contract_form_id,release_of_interest_id];

        const submit_id = "#printFormsModalSubmitButton";

        function check_checkboxes(){
            let counter = 0;
            let enable = false;
            while ((enable === false) && (counter < checkbox_array.length)){
                enable = ($(checkbox_array[counter]).is(':checked'));
                counter++;
            }
            if (enable === true){
                $(submit_id).prop('disabled',false);
            }
            else if (enable === false){
                $(submit_id).prop('disabled', true);
            }
        }

        $(broker_id).change(function(){
            check_checkboxes();
        });

        $(insured_id).change(function(){
            check_checkboxes();
        });

        $(cancellation_broker_id).change(function(){
            check_checkboxes();
        });

        $(cancellation_insured_id).change(function(){
            check_checkboxes();
        });

        $(financing_contract_form_id).change(function(){
            check_checkboxes();
        });

        $(release_of_interest_id).change(function () {
           check_checkboxes();
        });

        $(modal_id).on('hidden.bs.modal', function(){
            $(this).find('form')[0].reset();
        });

        $(submit_id).on('click', function() {
            $('#printFormsForm').submit();
        });

    });


    // Edit Customer Modal
    $("#editCustomerModalButton").on('click', function(){
        const modal_id = "#editCustomerModal";
        const last_name_class = '.insured_last_name';
        const last_name_id = 'customer_info_last_name';
        const first_name_label = 'customer_info_first_name_label';
        const insured_type_id = "#customer_info_insured_type";
        const province_id = "customer_info_province";

        document.getElementById(province_id).disabled=true;

        change_last_name();

        function change_last_name(){
            if ($(insured_type_id).val() === 'Person'){
                $(last_name_class).css('visibility','visible');
                document.getElementById(first_name_label).innerHTML = "First name:";
            }
            else if ($(insured_type_id).val() === 'Company'){
                document.getElementById(last_name_id).value = '';
                $(last_name_class).css('visibility','hidden');
                document.getElementById(first_name_label).innerHTML = "Company name:";
            }
        }

        $(insured_type_id).change(function() {
            change_last_name();
        });

        $(modal_id).on('hidden.bs.modal', function(){
            $(this).find('form')[0].reset();
        });

        $('#editCustomerModalSubmitButton').on('click', function() {
            document.getElementById(province_id).disabled=false;
            $('#editCustomerForm').submit();
        });
    });

    // Edit Policy Modal
    $("#editPolicyModalButton").on('click', function(){
        const modal_id = "#editPolicyModal";

        $(modal_id).on('hidden.bs.modal', function(){
            $(this).find('form')[0].reset();
        });

        $('#editPolicyModalSubmitButton').on('click', function() {
            $('#editPolicyForm').submit();
        });
    });

    // Transfer Policy Modal
    $("#confirmTransferPolicyModalButton").on('click', function(){
        $("#confirmTransferPolicyModalSubmitButton").on('click', function() {
            $("#confirmTransferPolicyForm").submit();
        });
    });

    // Void Policy Modal
    $("#confirmVoidPolicyModalButton").on('click', function(){

        const modal_id = "#confirmVoidPolicyModal";
        const agent_comments_field = "#void_policy_agent_comments";
        const submit_button = "#confirmVoidPolicyModalSubmitButton";

        if (isEmptyOrSpaces($(agent_comments_field).val())){
            $(submit_button).prop('disabled',true);
        }

        $(agent_comments_field).on('change paste keyup', function() {
            agent_comments_val = $(agent_comments_field).val();
            if (isEmptyOrSpaces(agent_comments_val)){
                $(submit_button).prop('disabled',true);
            }
            else{
                $(submit_button).prop('disabled',false);
            }
        });

        $(modal_id).on('hidden.bs.modal', function(){
            $(this).find('form')[0].reset();
        });

        $(submit_button).on('click', function() {
            $("#confirmVoidPolicyForm").submit();
        });
    });

    // add spinner to confirmCancelPolicyModal
    function submitConfirmCancelPolicyModal(){
        submit_form('#cancel_quote_form');
        add_spinner("#cancel_quote_result");
    }

    // Cancel Policy Modal
    $("#confirmCancelPolicyModalButton").on('click', function(){

        submitConfirmCancelPolicyModal();

        const modal_id = "#confirmCancelPolicyModal";
        const date_id = "#cancel_policy_effective_date";
        const submit_button = "#confirmCancelPolicyModalSubmitButton";
        const agent_comments_field = "#cancel_policy_agent_comments";

        if (isEmptyOrSpaces($(agent_comments_field).val())){
            $(submit_button).prop('disabled',true);
        }

        create_pickadate(date_id,true);

        $(agent_comments_field).on('change paste keyup', function() {
            agent_comments_val = $(agent_comments_field).val();
            if (isEmptyOrSpaces(agent_comments_val)){
                $(submit_button).prop('disabled',true);
            }
            else{
                $(submit_button).prop('disabled',false);
            }
        });

        $(date_id).on('change', function(){
            $('#effective_date').val($(date_id).val());
            submitConfirmCancelPolicyModal();
        });

        $(modal_id).on('hidden.bs.modal', function(){
            $(this).find('form')[0].reset();
        });

        $(submit_button).on('click', function() {
          $("#confirmCancelPolicyForm").submit();
        });
    });

    // Edit Transaction Modal
    $("#editTransactionModalButton").on('click', function(){
        const modal_id = "#editTransactionModal";

        $(modal_id).on('hidden.bs.modal', function(){
            $(this).find('form')[0].reset();
        });

        $('#editTransactionModalSubmitButton').on('click', function() {
            $('#editTransactionForm').submit();
        });
    });

    // Edit Cancellation Transaction Modal
    $("#editCancellationTransactionModalButton").on('click', function(){

        const modal_id = "#editCancellationTransactionModal";

        $(modal_id).on('hidden.bs.modal', function(){
            $(this).find('form')[0].reset();
        });

        $('#editCancellationTransactionModalSubmitButton').on('click', function() {
            $('#editCancellationTransactionForm').submit();
        });
    });

});
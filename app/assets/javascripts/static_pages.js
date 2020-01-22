$(document).on('turbolinks:load', function() {

    const submit_id = "#downloadButton";
    const download_form_id = "#download_download_form";

    $(submit_id).prop('disabled', true);

    $(download_form_id).on('change', function(){

        if ($(download_form_id).val() === ""){
            $(submit_id).prop('disabled', true);
        }
        else{
            $(submit_id).prop('disabled', false);
        }
    });

});
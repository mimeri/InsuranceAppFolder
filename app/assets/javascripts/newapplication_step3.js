$(document).on('turbolinks:load', function() {

    const last_name_class = '.insured_last_name';
    const last_name_id = 'newapplication_last_name';
    const first_name_label = 'first_name_label';

    if (document.getElementById("newapplication_province") != null){
        document.getElementById("newapplication_province").disabled=true;
    }


    change_last_name();

    function change_last_name(){
        if ($(newapplication_insured_type_id).val() === 'Person'){
            $(last_name_class).css('visibility','visible');
            document.getElementById("first_name_label").innerHTML = "First name:";
        }
        else if ($(newapplication_insured_type_id).val() === 'Company'){
            document.getElementById(last_name_id).value = '';
            $(last_name_class).css('visibility','hidden');
            document.getElementById(first_name_label).innerHTML = "Company name:";
        }
    }

    $(newapplication_insured_type_id).change(function() {
        change_last_name();
    });


    $("#edit_newapplication").submit(function(){
        if (document.getElementById("newapplication_province") != null){
            document.getElementById("newapplication_province").disabled=false;
        }
        document.getElementById("newapplication_make").disabled=false;
    });


});
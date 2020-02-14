$(document).on('turbolinks:load', function() {

    $('#toggle_password_button').on('click', function(){

        let password_input = document.getElementById('change_password_password');
        let eye_icon =  document.getElementById('toggle_password_icon');

        if (password_input.type === "password"){
            password_input.type = "text";
            eye_icon.setAttribute('data-icon','eye-slash');
        }
        else{
            password_input.type = "password";
            eye_icon.setAttribute('data-icon','eye');
        }

    });

});
$(document).on('turbolinks:load', function() {

    // Confirm Bind Modal
    $("#confirmBindModalButton").on('click', function(){
        $('#confirmBindModalSubmitButton').on('click', function() {
            $('#bindForm').submit();
        });
    });

    // Confirm Same Name Modal
    $("#confirmSameNameModalButton").on('click', function(){
        $('#confirmSameNameModalSubmitButton').on('click', function() {
            $('#bindForm').submit();
        });
    });

});
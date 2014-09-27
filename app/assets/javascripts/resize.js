$(document).ready(function() {
    var sizeArea = function() {
        var form = $('form').first(), th = 0;
        $('#form_container').height(($('body').height() - $('body>h2').outerHeight()) * .90);
        $('#form_container>:first(h1),form>:not(ul), form>ul>:not(#li_1), form>ul>#li_1>.description').each(function() {
            th += $(this).outerHeight(true);
        });
        th += (form.outerHeight(true) - form.height());
        form.find('textarea').height($('#form_container').height() - th - 15);
    };

    sizeArea();

    //$(window).load(function() {
        $(window).resize(sizeArea);
    //});
});

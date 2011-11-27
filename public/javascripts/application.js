$(document).ready(function() {
    var documentShow = null;
    var backgroundOld = null;
    var tokenOld = null;

    // function goToByScroll(token) {
    //     $('html,body').animate({
    //         scrollTop: $(".document [data-shingle-signature-token=" + token + "]").offset().top
    //     },
    //     'slow');
    // };

    $('.shingle-signature').live("click",
    function() {
        var tmp = $('#document-' + $(this).attr("data-document-id"));
        var token = $(this).attr("data-shingle-signature-token");

        if (tokenOld != null) {
            $("[data-shingle-signature-token=" + tokenOld + "]").each(
		        function() {
		            $(this).css("background-color", backgroundOld);
		        });
        };
				
				backgroundOld = $(this).css('background-color');
				tokenOld = token;

        $("[data-shingle-signature-token=" + token + "]").each(
        function() {
            $(this).css("background-color", "#FFDEAD");
        });

        if (documentShow != null) {
            if (tmp.attr("id") != documentShow.attr("id")) {
                documentShow.hide();
                documentShow = tmp;
                documentShow.show("fast");
            };
        } else {
            documentShow = tmp;
            documentShow.show("slow");
        };

        // goToByScroll(token);
    });
});
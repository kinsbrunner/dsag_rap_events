sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"de/brandeis/dmo/design/test/integration/pages/DesignList",
	"de/brandeis/dmo/design/test/integration/pages/DesignObjectPage"
], function (JourneyRunner, DesignList, DesignObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('de/brandeis/dmo/design') + '/test/flp.html#app-preview',
        pages: {
			onTheDesignList: DesignList,
			onTheDesignObjectPage: DesignObjectPage
        },
        async: true
    });

    return runner;
});


sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"de/brandeis/dmo/processbo/test/integration/pages/ProcessBOList",
	"de/brandeis/dmo/processbo/test/integration/pages/ProcessBOObjectPage"
], function (JourneyRunner, ProcessBOList, ProcessBOObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('de/brandeis/dmo/processbo') + '/test/flp.html#app-preview',
        pages: {
			onTheProcessBOList: ProcessBOList,
			onTheProcessBOObjectPage: ProcessBOObjectPage
        },
        async: true
    });

    return runner;
});


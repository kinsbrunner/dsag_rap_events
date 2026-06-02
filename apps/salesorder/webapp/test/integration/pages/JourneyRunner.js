sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"de/brandeis/dmo/salesorder/test/integration/pages/SalesOrderList",
	"de/brandeis/dmo/salesorder/test/integration/pages/SalesOrderObjectPage"
], function (JourneyRunner, SalesOrderList, SalesOrderObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('de/brandeis/dmo/salesorder') + '/test/flp.html#app-preview',
        pages: {
			onTheSalesOrderList: SalesOrderList,
			onTheSalesOrderObjectPage: SalesOrderObjectPage
        },
        async: true
    });

    return runner;
});


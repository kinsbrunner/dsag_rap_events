sap.ui.define(['sap/fe/test/ListReport'], function(ListReport) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ListReport(
        {
            appId: 'de.brandeis.dmo.processbo',
            componentId: 'ProcessBOList',
            contextPath: '/ProcessBO'
        },
        CustomPageDefinitions
    );
});
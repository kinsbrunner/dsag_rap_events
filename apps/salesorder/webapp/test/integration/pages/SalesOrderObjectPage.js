sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'de.brandeis.dmo.salesorder',
            componentId: 'SalesOrderObjectPage',
            contextPath: '/SalesOrder'
        },
        CustomPageDefinitions
    );
});
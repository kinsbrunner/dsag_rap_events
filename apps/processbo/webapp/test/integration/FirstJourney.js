sap.ui.define([
    "sap/ui/test/opaQunit",
    "./pages/JourneyRunner"
], function (opaTest, runner) {
    "use strict";

    function journey() {
        QUnit.module("First journey");

        opaTest("Start application", function (Given, When, Then) {
            Given.iStartMyApp();

            Then.onTheProcessBOList.iSeeThisPage();
            Then.onTheProcessBOList.onTable().iCheckColumns(7, {"ProcessID":{"header":"Process-ID"},"Status":{"header":"Status"},"errorDescription":{"header":"Error Description"},"DesignTeam":{"header":"DesignTeam"},"Salesorder":{"header":"Salesorder"},"Material":{"header":"Material"},"Billofmaterial":{"header":"Billofmaterial"}});

        });


        opaTest("Navigate to ObjectPage", function (Given, When, Then) {
            // Note: this test will fail if the ListReport page doesn't show any data
            
            When.onTheProcessBOList.onFilterBar().iExecuteSearch();
            
            Then.onTheProcessBOList.onTable().iCheckRows();

            When.onTheProcessBOList.onTable().iPressRow(0);
            Then.onTheProcessBOObjectPage.iSeeThisPage();

        });

        opaTest("Teardown", function (Given, When, Then) { 
            // Cleanup
            Given.iTearDownMyApp();
        });
    }

    runner.run([journey]);
});
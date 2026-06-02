sap.ui.define([
    "sap/ui/test/opaQunit",
    "./pages/JourneyRunner"
], function (opaTest, runner) {
    "use strict";

    function journey() {
        QUnit.module("First journey");

        opaTest("Start application", function (Given, When, Then) {
            Given.iStartMyApp();

            Then.onTheDesignList.iSeeThisPage();
            Then.onTheDesignList.onTable().iCheckColumns(7, {"DesignID":{"header":"DesignID"},"Status":{"header":"Status"},"errorDescription":{"header":"Error Description"},"DesignTeam":{"header":"DesignTeam"},"Salesorder":{"header":"Salesorder"},"Material":{"header":"Material"},"Billofmaterial":{"header":"Billofmaterial"}});

        });


        opaTest("Navigate to ObjectPage", function (Given, When, Then) {
            // Note: this test will fail if the ListReport page doesn't show any data
            
            When.onTheDesignList.onFilterBar().iExecuteSearch();
            
            Then.onTheDesignList.onTable().iCheckRows();

            When.onTheDesignList.onTable().iPressRow(0);
            Then.onTheDesignObjectPage.iSeeThisPage();

        });

        opaTest("Teardown", function (Given, When, Then) { 
            // Cleanup
            Given.iTearDownMyApp();
        });
    }

    runner.run([journey]);
});
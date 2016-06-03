# predix-backend-setup

Usage:

$ cd /Users/204071207/GIT_repo/back-end-setup

1. $ groovy destroyServices.groovy

          IMPORTANT: run manually:

          $ cf delete-orphaned-routes

          Really delete orphaned routes?>> y
          Getting routes as Jacob.Grimberg@ge.com ...

          Deleting route pm-tmp-hello-world-app-bornitic-cloudlet.run.aws-usw02-pr.ice.predix.io...
          OK


          $ cf routes
          Getting routes as Jacob.Grimberg@ge.com ...

          space   host   domain   apps
          No routes found


2. verify:

   cf apps
   cf services

3. $ cf delete-orphaned-routes

4. $ ./pm_setup.sh

   currently, till bug fixed, need to run it 2 times

5. $ ./pm-configure-uaa.sh -u admin -s https://2a065b75-3079-4c02-bbeb-9b236a811418.predix-uaa.run.aws-usw02-pr.ice.predix.io

    get url for uaa from "cf env <app-name>"


IMPORTANT: set end-point for pm toools:
pm api <url for predix mobile>

6. $ ./pm-add-developer.sh -e jacob@ge.com -p Test123


7. $ uaac member add pm.admin jacob@ge.com

# Onboarding-scripts
Template scripts for extenders to onboard their products with.

##Onboard-to-gateway.sh 
Is a template script that allows an extender to define details of a Rest service that can be incorporated into the Zowe gateway. 
The extender can define details of how the service will appear in the API catalog and specific information regarding uri contexts.
When the end user runs the script they have to fill in certain other parameters such as the location of the service and the end result is the creation of the necessary definitions for the Gateway server to recognise the service and integrate into the catalog.

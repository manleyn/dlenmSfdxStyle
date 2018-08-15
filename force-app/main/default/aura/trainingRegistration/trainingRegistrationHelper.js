({
    closeAllSections : function(component, event, helper){
    	component.set("v.section1Icon", "utility:chevronright");
        $A.util.removeClass(component.find("section1"), "slds-is-open");
        component.set("v.section2Icon", "utility:chevronright");
        $A.util.removeClass(component.find("section2"), "slds-is-open");
        component.set("v.section3Icon", "utility:chevronright");
        $A.util.removeClass(component.find("section3"), "slds-is-open");
    },
    submitRegistration : function(component, event, helper) {
        var action = component.get("c.submitRegistration");

        action.setParams({ l : component.get('v.newLeads'),
                           ce : { ScheduledCourseId__c : component.get('v.scheduledCourseId') },
                           cpi : component.get('v.newCPI') });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var cpiRet = response.getReturnValue();
                component.set('v.cpiName', cpiRet.Name);
                var compEvent = component.getEvent("serverCall");
                compEvent.setParams({"success" : true });
                compEvent.setParams({"message" : "RegComplete"});
                compEvent.fire();
            }
            else {
                console.log(response.getErrors[0].message);
                var compEvent = component.getEvent("serverCall");
                compEvent.setParams({"success" : false });
                compEvent.setParams({"message" : "Error:" + response.getErrors[0].message});
                compEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    currentRegistrantCount : function(component, event, helper) {
        var action = component.get("c.currentRegistrantCount");
        action.setParams({ scheduledCourseId : component.get('v.scheduledCourseId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.currRegCount', response.getReturnValue());
                var compEvent = component.getEvent("serverCall");
                compEvent.setParams({"success" : true });
                compEvent.setParams({"message" : "RegBlocked"});
                compEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    displayScheduledCourseInfo : function(component, event, helper) {
        var action = component.get("c.getScheduledCourseInfo");
        action.setParams({ scheduledCourseId : component.get('v.scheduledCourseId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.scheduledCourse', response.getReturnValue());
            } else {
                helper.hidePageShowError(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    getFieldInfo : function(component, event, helper) {
        var action = component.get("c.getFieldInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.fieldInfo', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getScheduledCourseId : function(component, event, helper) {
		// the function that reads the url parameters
        var getUrlParameter = function getUrlParameter(sParam) {
            var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;

            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');

                if (sParameterName[0] === sParam) {
                    return sParameterName[1] === undefined ? '' : sParameterName[1];
                }
            }

            // if you got this far then either the param is missing or there are no parameters
            return '';
        };

        //set the src param value to my src attribute
        var courseId = getUrlParameter('courseid')
        if (courseId === ''){
            helper.hidePageShowError(component, event, helper);
        } else {
            component.set("v.scheduledCourseId", courseId);
        }
	},
    hidePageShowError : function(component, event, helper) {
        $A.util.removeClass(component.find('regFormError'), "slds-hide");
        $A.util.addClass(component.find('courseHeaderInfo'), "slds-hide");
        $A.util.addClass(component.find('regForm'), "slds-hide");
    }
})
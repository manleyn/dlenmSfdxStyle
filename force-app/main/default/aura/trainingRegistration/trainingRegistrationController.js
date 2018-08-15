({
	doInit : function (component, event, helper) {
		helper.getScheduledCourseId(component, event, helper);
        helper.displayScheduledCourseInfo(component, event, helper);
		helper.currentRegistrantCount(component, event, helper);
        helper.getFieldInfo(component, event, helper);
    },
    paymentOptionChange : function (component, event, helper) {
        var payOption =  component.find("paymentMethod").get("v.value");

        var checkPOOptions = component.find("checkPOOptions");
        var ccOptions = component.find("ccOptions");

	    $A.util.addClass(checkPOOptions, "slds-hide");
        $A.util.addClass(ccOptions, "slds-hide");
        if (payOption === 'Check' || payOption === 'Purchase Order') {
					$A.util.toggleClass(checkPOOptions, "slds-hide");
        } else if (payOption === 'Credit Card') {
					$A.util.toggleClass(ccOptions, "slds-hide");
        }
    },
    addNewLead : function (component, event, helper) {
        var newLeads = component.get('v.newLeads');
		var currRegCount = component.get('v.currRegCount');
		var scheduledCourse = component.get('v.scheduledCourse');

		if ( (currRegCount + newLeads.length + 1) > scheduledCourse.MaxNoRegistrations__c ){ // check to see if adding 1 more registrant goes over the limit
			var toastEvent = $A.get("e.force:showToast");
		    toastEvent.setParams({
		        mode: 'sticky',
				type: 'warning',
				title: 'Registration Full:',
		        message: 'Unable to add attendee. This class will be full with your current number of attendees.',
		    });
		    toastEvent.fire();
		} else {
		    newLeads.push({'sobjectType':'Lead','LeadSource':'Web','Lead_Type__c':'AIM4SCubed'});
		    component.set('v.newLeads', newLeads);
		}
    },
    submit : function (component, event, helper) {
        var byPassValidation = false;
        var payMethod = component.find('paymentMethod');

        if (payMethod.get('v.validity').valid || byPassValidation) {
            var allValid = true; // assume true
            if (component.get('v.newCPI.PaymentMethod__c') != 'Credit Card'){
                 allValid = component.find('checkPO').reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                 }, true);
            }

            if (allValid) {
                var chk = component.find('reqSection3Field');
                allValid = chk.get('v.validity').valid;
                chk.showHelpMessageIfInvalid();
            }

            if (allValid || byPassValidation) {
                helper.submitRegistration(component, event, helper);
            }
        } else {
            payMethod.showHelpMessageIfInvalid();
        }

    },
    handleServerCall: function (component, event) {
        var success = event.getParam("success");
		var message = event.getParam("message");
        if (success && message === "RegComplete"){
            var regForm = component.find('regForm');
            $A.util.toggleClass(regForm, "slds-hide");
            var regSuccess = component.find('regSuccess');
            $A.util.toggleClass(regSuccess, "slds-hide");
        } else if (success && message === "RegBlocked"){
			var scheduledCourse = component.get('v.scheduledCourse');
			var currRegCount = component.get('v.currRegCount');
			if (currRegCount >= scheduledCourse.MaxNoRegistrations__c) {
				var regForm = component.find('regForm');
				$A.util.toggleClass(regForm, "slds-hide");
				var regBlocked = component.find('regBlocked');
				$A.util.toggleClass(regBlocked, "slds-hide");
			}
		} else if (!success){
			helper.hidePageShowError(component, event, helper);
		}
    },
    removeLead: function (component, event, helper) {
        var newLeads = component.get('v.newLeads');
        var idx = event.getSource().get("v.value");
        newLeads.splice(idx, 1);
        component.set('v.newLeads', newLeads);
    },
    accordianNav: function (component, event, helper) {
        var byPassValidation = false;
        var navSource = event.getSource().get("v.value");
        if (navSource === 'section1_next'){
            var allValid = component.find('reqSection1Field').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
             }, true);

            if (allValid || byPassValidation){
                // close sections
                helper.closeAllSections(component, event, helper);
                // open section2
                $A.util.toggleClass(component.find("section2"), "slds-is-open");
                component.set("v.section2Icon", "utility:chevrondown");

                // add leads to costInfo
                var newLeads = component.get('v.newLeads');
                var costInfo = [];
                for (var i = 0; i < newLeads.length; i++){
                    var obj = {};
                    obj.firstName = newLeads[i].FirstName;
                    obj.lastName = newLeads[i].LastName;
                    obj.cost = component.get('v.scheduledCourse.Cost__c');
                    costInfo.push(obj);
                }
                component.set('v.costInfo', costInfo);
            }
        }

        if (navSource === "section2_next"){
            var allValid = component.find('reqSection2Field').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
             }, true);

            if (allValid || byPassValidation){
                // close sections
                helper.closeAllSections(component, event, helper);
                // open section3
                $A.util.toggleClass(component.find("section3"), "slds-is-open");
                component.set("v.section3Icon", "utility:chevrondown");
            }
        }

        if (navSource === "section2_prev"){
            // close sections
            helper.closeAllSections(component, event, helper);
            // open section3
            $A.util.toggleClass(component.find("section1"), "slds-is-open");
            component.set("v.section1Icon", "utility:chevrondown");
        }

        if (navSource === "section3_prev"){
            // close sections
            helper.closeAllSections(component, event, helper);
            // open section3
            $A.util.toggleClass(component.find("section2"), "slds-is-open");
            component.set("v.section2Icon", "utility:chevrondown");
        }

    },
	formatPhone: function(component, event, helper) {
		var s = event.getSource().get("v.value");
		var s2 = (""+s).replace(/\D/g, '');
		var m = s2.match(/^(\d{3})(\d{3})(\d{4})$/);
		if (m) {
			event.getSource().set('v.value', m[1] + "-" + m[2] + "-" + m[3]);
		}
	}
})
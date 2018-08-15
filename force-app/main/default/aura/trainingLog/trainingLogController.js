({
	getCourses : function (component, event, helper) {
        helper.displayScheduledCourses(component, event, helper);
    },
	handleRowAction: function (component, event, helper) {
		var action = event.getParam('action');
		var row = event.getParam('row');
		switch (action.name) {
			case 'markAbsent':
				helper.markAbsent(component, row, helper);
				break;
			case 'markAttended':
				helper.markAttended(component, row, helper);
				break;
			case 'addNotes':
				helper.showNotes(component, event, helper, row);
				break;
		}
	},
	hideNotes : function (component, event, helper){
		helper.toggleNotes(component, event, helper);
	},
	getRoster : function (component, event, helper) {
		helper.showSpinner(component);
        helper.getRoster(component, event, helper);
    },
	saveNotes : function (component, event, helper) {
		var row = component.get('v.rowForNotes');
        helper.updateNotes(component, helper, row.Id, row.Notes);
		helper.toggleNotes(component, event, helper);
    },
	showDaysForCourse : function (component, event, helper) {
		var scheduledCourses = component.get('v.scheduledCourses');
		var selectedCourseId = component.get('v.selectedCourseId');
        for (var i = 0; i < scheduledCourses.length; i++){
			if (scheduledCourses[i].Id === selectedCourseId){
				component.set('v.selectedCourse', scheduledCourses[i]);
				var selectedDay = component.find('selectedDay');
                selectedDay.set("v.disabled",false);
			}
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
        }
    }
})
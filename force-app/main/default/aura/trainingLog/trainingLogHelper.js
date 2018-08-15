({
    displayScheduledCourses : function(component, event, helper) {
        var action = component.get("c.getAllTrainings");
        action.setParams({ courseType : component.get('v.selectedCourseType'), publishedOnly : false });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var courses = response.getReturnValue();
                for (var i = 0; i < courses.length; i++){
                    courses[i].Name = courses[i].WebCourseName__c;
                    var d1 = helper.parseDate(courses[i].ScheduledCourseDays__r[0].ScheduledDate__c);
                    courses[i].Name += ' (' + $A.localizationService.formatDate(d1, "MMM d, YY");
                    var d2 = helper.parseDate(courses[i].ScheduledCourseDays__r[courses[i].ScheduledCourseDays__r.length-1].ScheduledDate__c);
                    courses[i].Name += ' - ' + $A.localizationService.formatDate(d2, "MMM d, YY") + ')';
                }
                component.set('v.scheduledCourses', courses);
                var selectedCourse = component.find('selectedCourse');
                selectedCourse.set("v.disabled",false);
            } else {
                helper.hidePageShowError(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    getRoster : function(component, event, helper) {
        var action = component.get("c.getRosterList");
        action.setParams({ scheduledCourseDayId : component.get('v.selectedCourseDayId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var rosterList = helper.massageRosterList(JSON.parse(response.getReturnValue()));
                var actions = helper.getRowActions.bind(this, component);
        		component.set('v.rosterColumns', [
                        {label: 'Trainee Name', fieldName: 'Name', type: 'text'},
                        {label: 'Trainee Email', fieldName: 'Email', type: 'email'},
                        {label: 'Status', fieldName: 'Status', type: 'text'},
                        {label: 'Notes', fieldName: 'Notes', type: 'text'},
        				{label: 'Attended?', fieldName: 'AttendedYesNo',  cellAttributes: { class: {fieldName: '__class'} } },
        				{type: 'action', typeAttributes: { rowActions: actions } }
                    ]);
                component.set('v.rosterList', rosterList);
                helper.hideSpinner(component);
            } else {
                helper.hidePageShowError(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    massageRosterList : function(rosterList) {
        for (var i = 0; i < rosterList.length; i++){
            if (rosterList[i].Attended == 'true'){
                rosterList[i].__class = 'attended';
                rosterList[i].AttendedYesNo = 'Yes';
            } else {
                rosterList[i].__class = 'abscent';
                rosterList[i].AttendedYesNo = 'No';
            }
        }
        return rosterList;
    },
    hidePageShowError : function(component, event, helper) {
        $A.util.toggleClass(component.find('loggerForm'), "slds-hide");
        $A.util.toggleClass(component.find('errorInfo'), "slds-hide");
    },
    getRowActions : function (component, row, doneCallback) {
        var actions = [];
        if (row['Attended'] == 'true') {
            actions.push({
                'label': 'Mark Absent',
                'iconName': 'utility:error',
                'name': 'markAbsent'
            });
        } else {
            actions.push({
                'label': 'Mark Attended',
                'iconName': 'utility:check',
                'name': 'markAttended'
            });
        }
        actions.push({
            'label': 'Add Notes',
            'iconName': 'utility:note',
            'name': 'addNotes'
        });
        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    },
    showNotes : function (component, event, helper, row){
        component.set('v.rowForNotes', row);
        helper.toggleNotes(component, event, helper);
    },
    toggleNotes : function (component, event, helper){
		var n = component.find('notesModel');
		$A.util.toggleClass(n, "slds-hide");
	},
    markAbsent: function (cmp, row, helper) {
        var rows = cmp.get('v.rosterList');
        var rowIndex = rows.indexOf(row);
        var caId = rows[rowIndex]['Id'];
        helper.updateAttendanceState(cmp, helper, caId, false);
    },
    markAttended: function (cmp, row, helper) {
        var rows = cmp.get('v.rosterList');
        var rowIndex = rows.indexOf(row);
        var caId = rows[rowIndex]['Id'];
        helper.updateAttendanceState(cmp, helper, caId, true);
    },
    updateAttendanceState : function(component, helper, id, attendedBoolean) {
        helper.showSpinner(component);
        var action = component.get("c.updateAttendance");
        action.setParams({ caId : id, attended : attendedBoolean});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                helper.getRoster(component, event, helper);
            } else {
                helper.hidePageShowError(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    updateNotes : function(component, helper, id, notes) {
        helper.showSpinner(component);
        var action = component.get("c.updateNotesText");
        action.setParams({ caId : id, notesText : notes});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                helper.getRoster(component, event, helper);
            } else {
                helper.hidePageShowError(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    showSpinner : function(component){
        $A.util.removeClass(component.find('mySpinner'), 'slds-hide');
    },
    hideSpinner : function(component){
        setTimeout(function(){
			$A.util.addClass(component.find('mySpinner'), 'slds-hide');
		}, 300);
    },
    parseDate : function(input) { // parse date in yyyy-mm-dd format
        var parts = input.split('-');
        // new Date(year, month [, day [, hours[, minutes[, seconds[, ms]]]]])
        return new Date(parts[0], parts[1]-1, parts[2]); // Note: months are 0-based
    }
})
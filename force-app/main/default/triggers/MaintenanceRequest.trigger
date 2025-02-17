trigger MaintenanceRequest on Case (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        MaintenanceRequestHelper.processClosedRequests(Trigger.new, Trigger.oldMap);
    }
}
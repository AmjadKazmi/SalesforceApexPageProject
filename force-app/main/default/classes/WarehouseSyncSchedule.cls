public with sharing class WarehouseSyncSchedule implements Schedulable{
      public void execute(SchedulableContext ctx) {
        System.debug('Scheduling Queueable Job...');
        System.enqueueJob(new WarehouseCalloutService());
    }
}
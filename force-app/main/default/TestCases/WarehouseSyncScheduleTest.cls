@isTest
public with sharing class WarehouseSyncScheduleTest {
  @isTest static void testExecute() {
    Test.startTest();
    // Schedule the job
    String cronExp = '0 0 1 * * ?';
    String jobId = System.schedule('Test WarehouseSyncSchedule', cronExp, new WarehouseSyncSchedule());
    // Verify the job is scheduled
    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
              FROM CronTrigger WHERE Id = :jobId];
    System.assertEquals(cronExp, ct.CronExpression);
    System.assertNotEquals(null, ct.NextFireTime);
    Test.stopTest();
  }
}
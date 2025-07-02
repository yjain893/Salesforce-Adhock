/**
 * @description Test class for CandidateSummaryBatchUtil
 * @author Generated
 * @date 2024
 */
@isTest
private class CandidateSummaryBatchUtilTest {
    
    /**
     * @description Test data setup
     */
    @TestSetup
    static void makeData() {
        List<Contact> testContacts = new List<Contact>();
        
        // Create contacts that need summary generation
        for (Integer i = 0; i < 3; i++) {
            Contact contact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact' + i,
                Email = 'test.contact' + i + '@example.com',
                Is_Notes_Generated__c = false
            );
            testContacts.add(contact);
        }
        
        // Create contacts that already have summaries
        for (Integer i = 3; i < 5; i++) {
            Contact contact = new Contact(
                FirstName = 'Processed',
                LastName = 'Contact' + i,
                Email = 'processed.contact' + i + '@example.com',
                Is_Notes_Generated__c = true
            );
            testContacts.add(contact);
        }
        
        insert testContacts;
    }
    
    /**
     * @description Test executing batch with default parameters
     */
    @isTest
    static void testExecuteBatchDefault() {
        Test.startTest();
        
        CandidateSummaryBatchUtil.BatchJobResult result = CandidateSummaryBatchUtil.executeBatch();
        
        Test.stopTest();
        
        System.assertEquals('SUCCESS', result.status, 'Batch execution should succeed');
        System.assertNotEquals(null, result.jobId, 'Job ID should not be null');
        System.assertEquals('Batch job submitted successfully', result.message, 'Success message should match');
    }
    
    /**
     * @description Test executing batch with custom batch size
     */
    @isTest
    static void testExecuteBatchCustomSize() {
        Test.startTest();
        
        CandidateSummaryBatchUtil.BatchJobResult result = CandidateSummaryBatchUtil.executeBatch(50);
        
        Test.stopTest();
        
        System.assertEquals('SUCCESS', result.status, 'Batch execution should succeed');
        System.assertNotEquals(null, result.jobId, 'Job ID should not be null');
    }
    
    /**
     * @description Test getting batch job status
     */
    @isTest
    static void testGetBatchJobStatus() {
        Test.startTest();
        
        // Execute a batch job first
        Id jobId = CandidateSummaryBatch.executeBatch();
        
        // Get the job status
        CandidateSummaryBatchUtil.BatchJobStatus status = CandidateSummaryBatchUtil.getBatchJobStatus(jobId);
        
        Test.stopTest();
        
        System.assertNotEquals(null, status, 'Status should not be null');
        System.assertEquals(jobId, status.jobId, 'Job ID should match');
        System.assertNotEquals(null, status.status, 'Status should not be null');
    }
    
    /**
     * @description Test getting batch job status with invalid ID
     */
    @isTest
    static void testGetBatchJobStatusInvalid() {
        Test.startTest();
        
        // Use a fake job ID
        Id fakeJobId = '7071234567890123456'; // Valid 18-character ID format but non-existent
        CandidateSummaryBatchUtil.BatchJobStatus status = CandidateSummaryBatchUtil.getBatchJobStatus(fakeJobId);
        
        Test.stopTest();
        
        System.assertNotEquals(null, status, 'Status should not be null');
        System.assertEquals(fakeJobId, status.jobId, 'Job ID should match');
        System.assertEquals('NOT_FOUND', status.status, 'Status should be NOT_FOUND');
    }
    
    /**
     * @description Test getting active batch jobs
     */
    @isTest
    static void testGetActiveBatchJobs() {
        Test.startTest();
        
        // Execute a batch job
        CandidateSummaryBatch.executeBatch();
        
        // Get active jobs
        List<CandidateSummaryBatchUtil.BatchJobStatus> activeJobs = CandidateSummaryBatchUtil.getActiveBatchJobs();
        
        Test.stopTest();
        
        // In test context, the job may not appear as active immediately
        System.assertNotEquals(null, activeJobs, 'Active jobs list should not be null');
        // Note: In test context, active jobs might be empty due to test execution behavior
    }
    
    /**
     * @description Test getting batch job history
     */
    @isTest
    static void testGetBatchJobHistory() {
        Test.startTest();
        
        // Execute a batch job
        CandidateSummaryBatch.executeBatch();
        
        // Get job history
        List<CandidateSummaryBatchUtil.BatchJobStatus> history = CandidateSummaryBatchUtil.getBatchJobHistory(7);
        
        Test.stopTest();
        
        System.assertNotEquals(null, history, 'History list should not be null');
        // In test context, we may or may not have history depending on execution timing
    }
    
    /**
     * @description Test getting batch job history with null parameter
     */
    @isTest
    static void testGetBatchJobHistoryNullDays() {
        Test.startTest();
        
        List<CandidateSummaryBatchUtil.BatchJobStatus> history = CandidateSummaryBatchUtil.getBatchJobHistory(null);
        
        Test.stopTest();
        
        System.assertNotEquals(null, history, 'History list should not be null');
    }
    
    /**
     * @description Test scheduling batch job
     */
    @isTest
    static void testScheduleBatch() {
        Test.startTest();
        
        String cronExpression = '0 0 2 * * ?'; // Daily at 2 AM
        CandidateSummaryBatchUtil.ScheduleResult result = 
            CandidateSummaryBatchUtil.scheduleBatch(cronExpression, 'Test Batch Schedule');
        
        Test.stopTest();
        
        System.assertEquals('SUCCESS', result.status, 'Schedule should succeed');
        System.assertNotEquals(null, result.scheduledJobId, 'Scheduled job ID should not be null');
    }
    
    /**
     * @description Test scheduling batch job with default name
     */
    @isTest
    static void testScheduleBatchDefaultName() {
        Test.startTest();
        
        String cronExpression = '0 0 3 * * ?'; // Daily at 3 AM
        CandidateSummaryBatchUtil.ScheduleResult result = 
            CandidateSummaryBatchUtil.scheduleBatch(cronExpression, null);
        
        Test.stopTest();
        
        System.assertEquals('SUCCESS', result.status, 'Schedule should succeed');
        System.assertNotEquals(null, result.scheduledJobId, 'Scheduled job ID should not be null');
    }
    
    /**
     * @description Test unscheduling batch job
     */
    @isTest
    static void testUnscheduleBatch() {
        Test.startTest();
        
        // First schedule a job
        String cronExpression = '0 0 4 * * ?'; // Daily at 4 AM
        String jobName = 'Test Unschedule Job';
        CandidateSummaryBatchUtil.ScheduleResult scheduleResult = 
            CandidateSummaryBatchUtil.scheduleBatch(cronExpression, jobName);
        
        // Then unschedule it
        CandidateSummaryBatchUtil.ScheduleResult unscheduleResult = 
            CandidateSummaryBatchUtil.unscheduleBatch(jobName);
        
        Test.stopTest();
        
        System.assertEquals('SUCCESS', scheduleResult.status, 'Schedule should succeed');
        System.assertEquals('SUCCESS', unscheduleResult.status, 'Unschedule should succeed');
    }
    
    /**
     * @description Test unscheduling non-existent batch job
     */
    @isTest
    static void testUnscheduleBatchNotFound() {
        Test.startTest();
        
        CandidateSummaryBatchUtil.ScheduleResult result = 
            CandidateSummaryBatchUtil.unscheduleBatch('Non-existent Job');
        
        Test.stopTest();
        
        System.assertEquals('ERROR', result.status, 'Unschedule should fail for non-existent job');
        System.assert(result.message.contains('No scheduled job found'), 'Error message should indicate job not found');
    }
    
    /**
     * @description Test getting contacts needing summary count
     */
    @isTest
    static void testGetContactsNeedingSummaryCount() {
        Test.startTest();
        
        Integer count = CandidateSummaryBatchUtil.getContactsNeedingSummaryCount();
        
        Test.stopTest();
        
        System.assertEquals(3, count, 'Should return 3 contacts needing summary (from test setup)');
    }
    
    /**
     * @description Test wrapper classes
     */
    @isTest
    static void testWrapperClasses() {
        // Test BatchJobResult
        CandidateSummaryBatchUtil.BatchJobResult result = 
            new CandidateSummaryBatchUtil.BatchJobResult('testId', 'SUCCESS', 'Test message');
        
        System.assertEquals('testId', result.jobId, 'Job ID should match');
        System.assertEquals('SUCCESS', result.status, 'Status should match');
        System.assertEquals('Test message', result.message, 'Message should match');
        
        // Test BatchJobStatus with parameters
        CandidateSummaryBatchUtil.BatchJobStatus status = 
            new CandidateSummaryBatchUtil.BatchJobStatus('testId', 'COMPLETED', 'Test status');
        
        System.assertEquals('testId', status.jobId, 'Job ID should match');
        System.assertEquals('COMPLETED', status.status, 'Status should match');
        System.assertEquals('Test status', status.message, 'Message should match');
        
        // Test ScheduleResult
        CandidateSummaryBatchUtil.ScheduleResult scheduleResult = 
            new CandidateSummaryBatchUtil.ScheduleResult('scheduleId', 'SUCCESS', 'Scheduled successfully');
        
        System.assertEquals('scheduleId', scheduleResult.scheduledJobId, 'Schedule ID should match');
        System.assertEquals('SUCCESS', scheduleResult.status, 'Status should match');
        System.assertEquals('Scheduled successfully', scheduleResult.message, 'Message should match');
    }
}
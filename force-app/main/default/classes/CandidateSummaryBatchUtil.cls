/**
 * @description Utility class for managing CandidateSummaryBatch jobs
 * @author Generated
 * @date 2024
 */
public class CandidateSummaryBatchUtil {
    
    // Constants
    private static final String BATCH_CLASS_NAME = 'CandidateSummaryBatch';
    private static final String SCHEDULED_JOB_NAME = 'Candidate Summary Generation';
    
    /**
     * @description Execute the candidate summary batch job
     * @param batchSize Optional batch size (default: 200)
     * @return BatchJobResult containing job ID and status
     */
    public static BatchJobResult executeBatch(Integer batchSize) {
        try {
            Id jobId = CandidateSummaryBatch.executeBatch(batchSize);
            return new BatchJobResult(jobId, 'SUCCESS', 'Batch job submitted successfully');
        } catch (Exception e) {
            return new BatchJobResult(null, 'ERROR', 'Failed to submit batch job: ' + e.getMessage());
        }
    }
    
    /**
     * @description Execute the candidate summary batch job with default size
     * @return BatchJobResult containing job ID and status
     */
    public static BatchJobResult executeBatch() {
        return executeBatch(200);
    }
    
    /**
     * @description Get the status of a batch job
     * @param jobId The batch job ID
     * @return BatchJobStatus containing job details
     */
    public static BatchJobStatus getBatchJobStatus(Id jobId) {
        try {
            AsyncApexJob job = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems,
                       CreatedDate, CompletedDate, ExtendedStatus, MethodName
                FROM AsyncApexJob
                WHERE Id = :jobId
                LIMIT 1
            ];
            
            return new BatchJobStatus(job);
            
        } catch (QueryException e) {
            return new BatchJobStatus(jobId, 'NOT_FOUND', 'Job not found: ' + e.getMessage());
        } catch (Exception e) {
            return new BatchJobStatus(jobId, 'ERROR', 'Error retrieving job status: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get all active candidate summary batch jobs
     * @return List of BatchJobStatus for active jobs
     */
    public static List<BatchJobStatus> getActiveBatchJobs() {
        List<BatchJobStatus> activeJobs = new List<BatchJobStatus>();
        
        try {
            List<AsyncApexJob> jobs = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems,
                       CreatedDate, CompletedDate, ExtendedStatus, MethodName
                FROM AsyncApexJob
                WHERE ApexClass.Name = :BATCH_CLASS_NAME
                AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
                ORDER BY CreatedDate DESC
            ];
            
            for (AsyncApexJob job : jobs) {
                activeJobs.add(new BatchJobStatus(job));
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving active batch jobs: ' + e.getMessage());
        }
        
        return activeJobs;
    }
    
    /**
     * @description Get recent batch job history
     * @param numberOfDays Number of days to look back (default: 7)
     * @return List of BatchJobStatus for recent jobs
     */
    public static List<BatchJobStatus> getBatchJobHistory(Integer numberOfDays) {
        if (numberOfDays == null || numberOfDays <= 0) {
            numberOfDays = 7;
        }
        
        List<BatchJobStatus> jobHistory = new List<BatchJobStatus>();
        
        try {
            DateTime cutoffDate = DateTime.now().addDays(-numberOfDays);
            
            List<AsyncApexJob> jobs = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems,
                       CreatedDate, CompletedDate, ExtendedStatus, MethodName
                FROM AsyncApexJob
                WHERE ApexClass.Name = :BATCH_CLASS_NAME
                AND CreatedDate >= :cutoffDate
                ORDER BY CreatedDate DESC
                LIMIT 50
            ];
            
            for (AsyncApexJob job : jobs) {
                jobHistory.add(new BatchJobStatus(job));
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving batch job history: ' + e.getMessage());
        }
        
        return jobHistory;
    }
    
    /**
     * @description Schedule the candidate summary batch job
     * @param cronExpression Cron expression for scheduling
     * @param jobName Optional job name (default: 'Candidate Summary Generation')
     * @return ScheduleResult containing schedule details
     */
    public static ScheduleResult scheduleBatch(String cronExpression, String jobName) {
        try {
            if (String.isBlank(jobName)) {
                jobName = SCHEDULED_JOB_NAME;
            }
            
            // Check if a job with this name already exists
            List<CronTrigger> existingJobs = [
                SELECT Id, CronJobDetail.Name
                FROM CronTrigger
                WHERE CronJobDetail.Name = :jobName
                AND State = 'WAITING'
            ];
            
            if (!existingJobs.isEmpty()) {
                return new ScheduleResult(null, 'ERROR', 'A scheduled job with this name already exists');
            }
            
            CandidateSummaryBatchScheduler scheduler = new CandidateSummaryBatchScheduler();
            String scheduledJobId = System.schedule(jobName, cronExpression, scheduler);
            
            return new ScheduleResult(scheduledJobId, 'SUCCESS', 'Batch job scheduled successfully');
            
        } catch (Exception e) {
            return new ScheduleResult(null, 'ERROR', 'Failed to schedule batch job: ' + e.getMessage());
        }
    }
    
    /**
     * @description Unschedule a scheduled batch job
     * @param jobName The name of the scheduled job to remove
     * @return ScheduleResult containing operation result
     */
    public static ScheduleResult unscheduleBatch(String jobName) {
        try {
            List<CronTrigger> scheduledJobs = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name = :jobName
                AND State = 'WAITING'
            ];
            
            if (scheduledJobs.isEmpty()) {
                return new ScheduleResult(null, 'ERROR', 'No scheduled job found with name: ' + jobName);
            }
            
            System.abortJob(scheduledJobs[0].Id);
            return new ScheduleResult(scheduledJobs[0].Id, 'SUCCESS', 'Scheduled job removed successfully');
            
        } catch (Exception e) {
            return new ScheduleResult(null, 'ERROR', 'Failed to unschedule batch job: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get count of contacts that need summary generation
     * @return Integer count of contacts where Is_Notes_Generated__c = false
     */
    public static Integer getContactsNeedingSummaryCount() {
        try {
            return [
                SELECT COUNT()
                FROM Contact
                WHERE Is_Notes_Generated__c = false
                AND Email != null
            ];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error getting contacts count: ' + e.getMessage());
            return 0;
        }
    }
    
    /**
     * @description Wrapper class for batch job execution results
     */
    public class BatchJobResult {
        public Id jobId { get; set; }
        public String status { get; set; }
        public String message { get; set; }
        
        public BatchJobResult(Id jobId, String status, String message) {
            this.jobId = jobId;
            this.status = status;
            this.message = message;
        }
    }
    
    /**
     * @description Wrapper class for batch job status information
     */
    public class BatchJobStatus {
        public Id jobId { get; set; }
        public String status { get; set; }
        public String message { get; set; }
        public Integer numberOfErrors { get; set; }
        public Integer jobItemsProcessed { get; set; }
        public Integer totalJobItems { get; set; }
        public DateTime createdDate { get; set; }
        public DateTime completedDate { get; set; }
        public String extendedStatus { get; set; }
        
        public BatchJobStatus(AsyncApexJob job) {
            this.jobId = job.Id;
            this.status = job.Status;
            this.numberOfErrors = job.NumberOfErrors;
            this.jobItemsProcessed = job.JobItemsProcessed;
            this.totalJobItems = job.TotalJobItems;
            this.createdDate = job.CreatedDate;
            this.completedDate = job.CompletedDate;
            this.extendedStatus = job.ExtendedStatus;
            this.message = buildStatusMessage(job);
        }
        
        public BatchJobStatus(Id jobId, String status, String message) {
            this.jobId = jobId;
            this.status = status;
            this.message = message;
        }
        
        private String buildStatusMessage(AsyncApexJob job) {
            String msg = 'Status: ' + job.Status;
            if (job.TotalJobItems > 0) {
                msg += ' | Progress: ' + job.JobItemsProcessed + '/' + job.TotalJobItems;
            }
            if (job.NumberOfErrors > 0) {
                msg += ' | Errors: ' + job.NumberOfErrors;
            }
            return msg;
        }
    }
    
    /**
     * @description Wrapper class for schedule operation results
     */
    public class ScheduleResult {
        public String scheduledJobId { get; set; }
        public String status { get; set; }
        public String message { get; set; }
        
        public ScheduleResult(String scheduledJobId, String status, String message) {
            this.scheduledJobId = scheduledJobId;
            this.status = status;
            this.message = message;
        }
    }
}
/**
 * @description Scheduler class for CandidateSummaryBatch
 * @author Generated
 * @date 2024
 */
public class CandidateSummaryBatchScheduler implements Schedulable {
    
    private Integer batchSize;
    
    /**
     * @description Default constructor with default batch size
     */
    public CandidateSummaryBatchScheduler() {
        this.batchSize = 200;
    }
    
    /**
     * @description Constructor with custom batch size
     * @param batchSize The batch size to use
     */
    public CandidateSummaryBatchScheduler(Integer batchSize) {
        this.batchSize = (batchSize != null && batchSize > 0) ? batchSize : 200;
    }
    
    /**
     * @description Execute method called by the scheduler
     * @param sc SchedulableContext
     */
    public void execute(SchedulableContext sc) {
        System.debug('CandidateSummaryBatchScheduler: Executing scheduled batch job');
        
        try {
            // Check if there are contacts that need summary generation
            Integer contactsCount = CandidateSummaryBatchUtil.getContactsNeedingSummaryCount();
            
            if (contactsCount > 0) {
                System.debug('CandidateSummaryBatchScheduler: Found ' + contactsCount + ' contacts needing summary generation');
                
                // Execute the batch job
                Id batchJobId = CandidateSummaryBatch.executeBatch(batchSize);
                System.debug('CandidateSummaryBatchScheduler: Batch job started with ID: ' + batchJobId);
                
            } else {
                System.debug('CandidateSummaryBatchScheduler: No contacts found needing summary generation');
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'CandidateSummaryBatchScheduler: Error executing scheduled batch: ' + e.getMessage());
            
            // In production, you might want to send an alert or create a log record
            // For now, just log the error
        }
    }
}
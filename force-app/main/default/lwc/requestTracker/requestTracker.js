import { LightningElement, track, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getCases from '@salesforce/apex/TicketController.getCases';


export default class RequestTracker extends LightningElement {
    @track columns = [
        { status: 'New', label: 'Open', cases: [] }, 
        { status: 'Working', label: 'Working', cases: [] },
        { status: 'Escalated', label: 'Escalated', cases: [] },
        { status: 'Closed', label: 'Closed', cases: [] },
        
    ];

    wiredCasesResult;

    @wire(getCases)
    wiredCases(result) {
        this.wiredCasesResult = result;
        const { error, data } = result;
        if (data) {
            this.processCases(data);
        } else if (error) {
            console.error('Error fetching cases:', error);
        }
    }

    

    processCases(data) {
        let newColumns = [...this.columns]; 
        newColumns.forEach(col => col.cases = []);  
       
        data.forEach(cs => {
            const column = newColumns.find(col => col.status === cs.Status);
            if (column) column.cases.push(cs);
        });

        this.columns = newColumns;
    }

    handleDrag(event) {
        event.dataTransfer.setData("caseId", event.target.dataset.id);
    }

    allowDrop(event) {
        event.preventDefault();
    }

    async handleDrop(event) {
        event.preventDefault();
        const caseId = event.dataTransfer.getData("caseId");
        const newStatus = event.currentTarget.dataset.status;
                
        // Update case status using LDS
        try {
            await updateRecord({ fields: { Id: caseId, Status: newStatus } }).
                then(() => refreshApex(this.wiredCasesResult));
            this.dispatchEvent(new CustomEvent('caseupdated', {
        detail: { updated: true } }));
        } catch (error) {
            console.error('Error updating case:', error);
        }
    }


}
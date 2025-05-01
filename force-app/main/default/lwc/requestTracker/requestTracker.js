import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getCases from '@salesforce/apex/TicketController.getCases';
import productDetails from '@salesforce/apex/TicketController.productDetailsForCaseID';
import { MessageContext, subscribe } from 'lightning/messageService';
import CASE_CREATED_CHANNEL from '@salesforce/messageChannel/CaseCreatedChannel__c';


export default class RequestTracker extends NavigationMixin(LightningElement) {
    @track columns = [
        { status: 'New', label: 'Open', cases: [] },
        { status: 'Working', label: 'Working', cases: [] },
        { status: 'Escalated', label: 'Escalated', cases: [] },
        { status: 'Closed', label: 'Closed', cases: [] },
    ];

    wiredCasesResult;
    caseDataForChild = [];
    mouseHoverTrue = false;
    productDetailsData;
    
    @wire(MessageContext) messageContext;
    
    connectedCallback() {
        this.subscribeToMessageChannel();
    }
    subscribeToMessageChannel() {
        subscribe(this.messageContext, CASE_CREATED_CHANNEL, (message) => {
            this.handleMessage(message);
        });
    }
    handleMessage(message) {
        if (message) {
            refreshApex(this.wiredCasesResult);
        }
    }

    @wire(getCases)
    wiredCases(result) {
        this.wiredCasesResult = result;
        const { error, data } = result;
        if (data && data.length>0) {
            this.processCases(data);
            this.caseDataForChild = JSON.stringify([...data.map(cs => cs.Id)]);
        } else if (error) {
            console.error('Error fetching cases:', error);
        }
    } 

    /**
     * Fetches product details for the cases.
     * @param {*} param0 
     */
    @wire(productDetails, { caseIds: '$caseDataForChild' })     
    wiredProductDetails({ error, data }) {
            if (data) {
                this.productDetailsData = this.tranformProductDetailsData(data);
            } else if(error) {
                console.error('error', error);
            }
    }

    /**
     * transform the data to a format that can be used in the child component.
     * @param {*} data 
     * @returns 
     */

    tranformProductDetailsData(data) {
        return Object.keys(data).reduce((acc, id) => {
            const products = data[id];
            acc[id] = {};
            for (let i = 0; i < products.length; i += 2) {
            acc[id][products[i]] = products[i + 1];
            }
            return acc;
        }, {});
    }

    processCases(data) {
        const newColumns = this.columns.map(col => ({ ...col, cases: [] }));

        data.forEach(cs => {
            console.log('Parent Case ID:', cs.Id); // Debugging line
            const column = newColumns.find(col => col.status === cs.Status);
            if (column) {
                column.cases.push({
                    ...cs,
                    formattedCreatedDate: this.formatDate(cs.CreatedDate),
                    cardClass: this.getCardClass(cs.Status)
                });
            }
        });

        this.columns = newColumns;
    }

    getCardClass(status) {
        console.log('Status:', status);
    switch (status) {
        case 'New':
            return 'jira-card card-new';
        case 'Working':
            return 'jira-card card-working';
        case 'Escalated':
            return 'jira-card card-escalated';
        case 'Closed':
            return 'jira-card card-closed';
        default:
            return '';
    }
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
            await updateRecord({ fields: { Id: caseId, Status: newStatus } })
                .then(() => refreshApex(this.wiredCasesResult));
            this.dispatchEvent(new CustomEvent('caseupdated', {
                detail: { updated: true }
            }));
        } catch (error) {
            console.error('Error updating case:', error);
        }
    }
    
    /**
     * Formats the date in a DD MMMM YYYY format.
     * @param {*} date 
     * @returns 
     */
    formatDate(date) {
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
        return new Date(date).toLocaleDateString(undefined, options);
    }
    /**
     * Navigates to the record page for a specific case.
     * @param {CustomEvent} event The event containing the case ID.
     * used currentTarget instead of target because the event is dispatched from the lightning-card component 
     * and not the button.
     * @author:Amjad Ali
     * @date : 2025-03-20
     */

    async caseDetails(event) {  
        const caseId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }    
}